Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f53.google.com (mail-la0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id 5F12E6B0038
	for <linux-mm@kvack.org>; Sat, 25 Jul 2015 12:25:51 -0400 (EDT)
Received: by lagw2 with SMTP id w2so28876876lag.3
        for <linux-mm@kvack.org>; Sat, 25 Jul 2015 09:25:50 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id oq3si10613010lbb.125.2015.07.25.09.25.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 25 Jul 2015 09:25:48 -0700 (PDT)
Date: Sat, 25 Jul 2015 19:24:56 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm v9 0/8] idle memory tracking
Message-ID: <20150725162456.GM8100@esperanza>
References: <cover.1437303956.git.vdavydov@parallels.com>
 <20150721163402.43ad2527d9b8caa476a1c9e1@linux-foundation.org>
 <20150722162353.GM23374@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150722162353.GM23374@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andres Lagar-Cavilla <andreslc@google.com>, Minchan Kim <minchan@kernel.org>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg
 Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David
 Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Kees Cook <keescook@chromium.org>

On Wed, Jul 22, 2015 at 07:23:53PM +0300, Vladimir Davydov wrote:
> On Tue, Jul 21, 2015 at 04:34:02PM -0700, Andrew Morton wrote:
> > On Sun, 19 Jul 2015 15:31:09 +0300 Vladimir Davydov <vdavydov@parallels.com> wrote:

> > > Documentation/vm/pagemap.txt           |  22 ++-
> > 
> > I think we'll need quite a lot more than this to fully describe the
> > interface?
> 
> Agree, the documentation sucks :-( Will try to forge something more
> thorough.

The incremental patch is attached. Could you please merge it into
proc-add-kpageidle-file?
---
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH] Documentation: Add idle page tracking description

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>

diff --git a/Documentation/vm/00-INDEX b/Documentation/vm/00-INDEX
index 081c49777abb..6a5e2a102a45 100644
--- a/Documentation/vm/00-INDEX
+++ b/Documentation/vm/00-INDEX
@@ -14,6 +14,8 @@ hugetlbpage.txt
 	- a brief summary of hugetlbpage support in the Linux kernel.
 hwpoison.txt
 	- explains what hwpoison is
+idle_page_tracking.txt
+	- description of the idle page tracking feature.
 ksm.txt
 	- how to use the Kernel Samepage Merging feature.
 numa
diff --git a/Documentation/vm/idle_page_tracking.txt b/Documentation/vm/idle_page_tracking.txt
new file mode 100644
index 000000000000..d0f332d544c4
--- /dev/null
+++ b/Documentation/vm/idle_page_tracking.txt
@@ -0,0 +1,94 @@
+MOTIVATION
+
+The idle page tracking feature allows to track which memory pages are being
+accessed by a workload and which are idle. This information can be useful for
+estimating the workload's working set size, which, in turn, can be taken into
+account when configuring the workload parameters, setting memory cgroup limits,
+or deciding where to place the workload within a compute cluster.
+
+USER API
+
+If CONFIG_IDLE_PAGE_TRACKING was enabled on compile time, a new read-write file
+is present on the proc filesystem, /proc/kpageidle.
+
+The file implements a bitmap where each bit corresponds to a memory page. The
+bitmap is represented by an array of 8-byte integers, and the page at PFN #i is
+mapped to bit #i%64 of array element #i/64, byte order is native. When a bit is
+set, the corresponding page is idle.
+
+A page is considered idle if it has not been accessed since it was marked idle
+(for more details on what "accessed" actually means see the IMPLEMENTATION
+DETAILS section). To mark a page idle one has to set the bit corresponding to
+the page by writing to the file. A value written to the file is OR-ed with the
+current bitmap value.
+
+Only accesses to user memory pages are tracked. These are pages mapped to a
+process address space, page cache and buffer pages, swap cache pages. For other
+page types (e.g. SLAB pages) an attempt to mark a page idle is silently ignored,
+and hence such pages are never reported idle.
+
+For huge pages the idle flag is set only on the head page, so one has to read
+/proc/kpageflags in order to correctly count idle huge pages.
+
+Reading from or writing to /proc/kpageidle will return -EINVAL if you are not
+starting the read/write on an 8-byte boundary, or if the size of the read/write
+is not a multiple of 8 bytes. Writing to this file beyond max PFN will return
+-ENXIO.
+
+That said, in order to estimate the amount of pages that are not used by a
+workload one should:
+
+ 1. Mark all the workload's pages as idle by setting corresponding bits in the
+    /proc/kpageidle bitmap. The pages can be found by reading /proc/pid/pagemap
+    if the workload is represented by a process, or by filtering out alien pages
+    using /proc/kpagecgroup in case the workload is placed in a memory cgroup.
+
+ 2. Wait until the workload accesses its working set.
+
+ 3. Read /proc/kpageidle and count the number of bits set. If one wants to
+    ignore certain types of pages, e.g. mlocked pages since they are not
+    reclaimable, he or she can filter them out using /proc/kpageflags.
+
+See Documentation/vm/pagemap.txt for more information about /proc/pid/pagemap,
+/proc/kpageflags, and /proc/kpagecgroup.
+
+IMPLEMENTATION DETAILS
+
+The kernel internally keeps track of accesses to user memory pages in order to
+reclaim unreferenced pages first on memory shortage conditions. A page is
+considered referenced if it has been recently accessed via a process address
+space, in which case one or more PTEs it is mapped to will have the Accessed bit
+set, or marked accessed explicitly by the kernel (see mark_page_accessed()). The
+latter happens when:
+
+ - a userspace process reads or writes a page using a system call (e.g. read(2)
+   or write(2))
+
+ - a page that is used for storing filesystem buffers is read or written,
+   because a process needs filesystem metadata stored in it (e.g. lists a
+   directory tree)
+
+ - a page is accessed by a device driver using get_user_pages()
+
+When a dirty page is written to swap or disk as a result of memory reclaim or
+exceeding the dirty memory limit, it is not marked referenced.
+
+The idle memory tracking feature adds a new page flag, the Idle flag. This flag
+is set manually, by writing to /proc/kpageidle (see the USER API section), and
+cleared automatically whenever a page is referenced as defined above.
+
+When a page is marked idle, the Accessed bit must be cleared in all PTEs it is
+mapped to, otherwise we will not be able to detect accesses to the page coming
+from a process address space. To avoid interference with the reclaimer, which,
+as noted above, uses the Accessed bit to promote actively referenced pages, one
+more page flag is introduced, the Young flag. When the PTE Accessed bit is
+cleared as a result of setting or updating a page's Idle flag, the Young flag
+is set on the page. The reclaimer treats the Young flag as an extra PTE
+Accessed bit and therefore will consider such a page as referenced.
+
+Since the idle memory tracking feature is based on the memory reclaimer logic,
+it only works with pages that are on an LRU list, other pages are silently
+ignored. That means it will ignore a user memory page if it is isolated, but
+since there are usually not many of them, it should not affect the overall
+result noticeably. In order not to stall scanning of /proc/kpageidle, locked
+pages may be skipped too.
diff --git a/Documentation/vm/pagemap.txt b/Documentation/vm/pagemap.txt
index 538735465693..cff513e28a13 100644
--- a/Documentation/vm/pagemap.txt
+++ b/Documentation/vm/pagemap.txt
@@ -71,15 +71,8 @@ There are five components to pagemap:
    memory cgroup each page is charged to, indexed by PFN. Only available when
    CONFIG_MEMCG is set.
 
- * /proc/kpageidle.  This file implements a bitmap where each bit corresponds
-   to a page, indexed by PFN. When the bit is set, the corresponding page is
-   idle. A page is considered idle if it has not been accessed since it was
-   marked idle. To mark a page idle one should set the bit corresponding to the
-   page by writing to the file. A value written to the file is OR-ed with the
-   current bitmap value. Only user memory pages can be marked idle, for other
-   page types input is silently ignored. Writing to this file beyond max PFN
-   results in the ENXIO error. Only available when CONFIG_IDLE_PAGE_TRACKING is
-   set.
+ * /proc/kpageidle.  This file comprises API of the idle page tracking feature.
+   See Documentation/vm/idle_page_tracking.txt for more details.
 
 Short descriptions to the page flags:
 
diff --git a/mm/Kconfig b/mm/Kconfig
index a1de09926171..90fa89175102 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -666,4 +666,4 @@ config IDLE_PAGE_TRACKING
 	  be useful to tune memory cgroup limits and/or for job placement
 	  within a compute cluster.
 
-	  See Documentation/vm/pagemap.txt for more details.
+	  See Documentation/vm/idle_page_tracking.txt for more details.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
