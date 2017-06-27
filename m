Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 80F4D6B03AE
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 12:09:17 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id z10so29991097pff.1
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 09:09:17 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id u18si2332613plj.279.2017.06.27.09.09.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Jun 2017 09:09:16 -0700 (PDT)
From: Prakash Sangappa <prakash.sangappa@oracle.com>
Subject: [RFC PATCH v2] userfaultfd: Add feature to request for a signal
 delivery
Message-ID: <ff16daf5-7ba0-3dc2-7f73-eb7db8336df7@oracle.com>
Date: Tue, 27 Jun 2017 09:08:40 -0700
MIME-Version: 1.0
Content-Type: multipart/alternative;
 boundary="------------96F7F87A7D87C44A8ED72EAF"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Christoph Hellwig <hch@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Michal Hocko <mhocko@kernel.org>

This is a multi-part message in MIME format.
--------------96F7F87A7D87C44A8ED72EAF
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit

Applications like the database use hugetlbfs for performance reason.
Files on hugetlbfs filesystem are created and huge pages allocated
using fallocate() API. Pages are deallocated/freed using fallocate() hole
punching support. These files are mmap'ed and accessed by many
single threaded processes as shared memory.  The database keeps
track of which offsets in the hugetlbfs file have pages allocated.

Any access to mapped address over holes in the file, which can occur due
to bugs in the application, is considered invalid and expect the process
to simply receive a SIGBUS.  However, currently when a hole in the file is
accessed via the mmap'ed address, kernel/mm attempts to automatically
allocate a page at page fault time, resulting in implicitly filling the
hole in the file. This may not be the desired behavior for applications
like the database that want to explicitly manage page allocations of
hugetlbfs files. The requirement here is for a way to prevent the kernel
from implicitly allocating a page  to fill holes in hugetbfs file.

This can be achieved using userfaultfd mechanism to intercept page-fault
events when mmap'ed address over holes in the file are accessed, and
prevent kernel from implicitly filling the hole. However, currently using
userfaultfd would require each of the database processes to use a monitor
thread and the setup cost associated with it,  is considered an overhead.

It would be better if userfaultd mechanism could have a way to request
simply sending a signal,for the robustness use case described above.
This would not require the use of a monitor thread.

This patch adds the feature to userfaultfd mechanism to request for a
SIGBUS signal delivery to the faulting process, instead of the
page-fault event.

See following for previous discussion about a different solution
to the above database requirement, leading to this proposal to enhance
userfaultfd, as suggested by Andrea.

http://www.spinics.net/lists/linux-mm/msg129224.html

Signed-off-by: Prakash <prakash.sangappa@oracle.com>
---
  fs/userfaultfd.c                 |  5 +++++
  include/uapi/linux/userfaultfd.h | 10 +++++++++-
  2 files changed, 14 insertions(+), 1 deletion(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 1d622f2..5686d6d2 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -371,6 +371,11 @@ int handle_userfault(struct vm_fault *vmf, unsigned 
long reason)
      VM_BUG_ON(reason & ~(VM_UFFD_MISSING|VM_UFFD_WP));
      VM_BUG_ON(!(reason & VM_UFFD_MISSING) ^ !!(reason & VM_UFFD_WP));

+    if (ctx->features & UFFD_FEATURE_SIGBUS) {
+        goto out;
+    }
+
      /*
       * If it's already released don't get it. This avoids to loop
       * in __get_user_pages if userfaultfd_release waits on the
diff --git a/include/uapi/linux/userfaultfd.h 
b/include/uapi/linux/userfaultfd.h
index 3b05953..d39d5db 100644
--- a/include/uapi/linux/userfaultfd.h
+++ b/include/uapi/linux/userfaultfd.h
@@ -23,7 +23,8 @@
                 UFFD_FEATURE_EVENT_REMOVE |    \
                 UFFD_FEATURE_EVENT_UNMAP |        \
                 UFFD_FEATURE_MISSING_HUGETLBFS |    \
-               UFFD_FEATURE_MISSING_SHMEM)
+               UFFD_FEATURE_MISSING_SHMEM |        \
+               UFFD_FEATURE_SIGBUS)
  #define UFFD_API_IOCTLS                \
      ((__u64)1 << _UFFDIO_REGISTER |        \
       (__u64)1 << _UFFDIO_UNREGISTER |    \
@@ -153,6 +154,12 @@ struct uffdio_api {
       * UFFD_FEATURE_MISSING_SHMEM works the same as
       * UFFD_FEATURE_MISSING_HUGETLBFS, but it applies to shmem
       * (i.e. tmpfs and other shmem based APIs).
+     *
+     * UFFD_FEATURE_SIGBUS feature means no page-fault
+     * (UFFD_EVENT_PAGEFAULT) event will be delivered, instead
+     * a SIGBUS signal will be sent to the faulting process.
+     * The application process can enable this behavior by adding
+     * it to uffdio_api.features.
       */
  #define UFFD_FEATURE_PAGEFAULT_FLAG_WP (1<<0)
  #define UFFD_FEATURE_EVENT_FORK            (1<<1)
@@ -161,6 +168,7 @@ struct uffdio_api {
  #define UFFD_FEATURE_MISSING_HUGETLBFS (1<<4)
  #define UFFD_FEATURE_MISSING_SHMEM        (1<<5)
  #define UFFD_FEATURE_EVENT_UNMAP        (1<<6)
+#define UFFD_FEATURE_SIGBUS            (1<<7)
      __u64 features;

      __u64 ioctls;
-- 
2.7.4

--------------96F7F87A7D87C44A8ED72EAF
Content-Type: text/html; charset=utf-8
Content-Transfer-Encoding: 8bit

<html>
  <head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8">
  </head>
  <body bgcolor="#FFFFFF" text="#000000">
    <tt>Applications like the database use hugetlbfs for performance
      reason. </tt><tt><br>
    </tt><tt> Files on hugetlbfs filesystem are created and huge pages
      allocated </tt><tt><br>
    </tt><tt> using fallocate() API. Pages are deallocated/freed using
      fallocate() hole </tt><tt><br>
    </tt><tt> punching support. These files are mmap'ed and accessed by
      many </tt><tt><br>
    </tt><tt> single threaded processes as shared memory.A  The database
      keeps </tt><tt><br>
    </tt><tt> track of which offsets in the hugetlbfs file have pages
      allocated. </tt><tt><br>
    </tt><tt> </tt><tt><br>
    </tt><tt> Any access to mapped address over holes in the file, which
      can occur due </tt><tt><br>
    </tt><tt> to bugs in the application, is considered invalid and
      expect the process </tt><tt><br>
    </tt><tt> to simply receive a SIGBUS.A  However, currently when a
      hole in the file is </tt><tt><br>
    </tt><tt> accessed via the mmap'ed address, kernel/mm attempts to
      automatically </tt><tt><br>
    </tt><tt> allocate a page at page fault time, resulting in
      implicitly filling the </tt><tt><br>
    </tt><tt> hole in the file. This may not be the desired behavior for
      applications </tt><tt><br>
    </tt><tt> like the database that want to explicitly manage page
      allocations of </tt><tt><br>
    </tt><tt> hugetlbfs files. The requirement here is for a way to
      prevent the kernel </tt><tt><br>
    </tt><tt> from implicitly allocating a pageA  to fill holes in
      hugetbfs file.</tt><tt><br>
    </tt><tt> </tt><tt><br>
    </tt><tt> This can be achieved using userfaultfd mechanism to
      intercept page-fault</tt><tt><br>
    </tt><tt> events when mmap'ed address over holes in the file are
      accessed, and</tt><tt><br>
    </tt><tt> prevent kernel from implicitly filling the hole. However,
      currently using</tt><tt><br>
    </tt><tt> userfaultfd would require each of the database processes
      to use a monitor </tt><tt><br>
    </tt><tt> thread and the setup cost associated with it,A  is
      considered an overhead. </tt><tt><br>
    </tt><tt> </tt><tt><br>
    </tt><tt> It would be better if userfaultd mechanism could have a
      way to request</tt><tt><br>
    </tt><tt>simply sending a signal,</tt><tt> for the robustness use
      case described above.</tt><tt><br>
      This would not require the use of a monitor thread.<br>
    </tt><tt> </tt><tt><br>
    </tt><tt> This patch adds the feature to userfaultfd mechanism to
      request for a </tt><tt><br>
    </tt><tt>SIGBUS signal delivery to the faulting process, instead of
      the </tt><tt><br>
    </tt><tt>page-fault event.</tt><tt><br>
    </tt><tt> </tt><tt><br>
    </tt><tt> See following for previous discussion about a different
      solution</tt><tt><br>
    </tt><tt>to the above database requirement, leading to this proposal
      to enhance </tt><tt><br>
    </tt><tt>userfaultfd, as suggested by Andrea. </tt><tt><br>
    </tt><tt> </tt><tt><br>
    </tt><tt> </tt><tt><a class="moz-txt-link-freetext"
        href="http://www.spinics.net/lists/linux-mm/msg129224.html">http://www.spinics.net/lists/linux-mm/msg129224.html</a></tt><tt>
    </tt><tt><br>
    </tt><tt> </tt><tt><br>
    </tt><tt> Signed-off-by: Prakash </tt><tt><a
        class="moz-txt-link-rfc2396E"
        href="mailto:prakash.sangappa@oracle.com">&lt;prakash.sangappa@oracle.com&gt;</a></tt><tt>
    </tt><tt><br>
    </tt><tt> --- </tt><tt><br>
    </tt><tt> A fs/userfaultfd.cA A A A A A A A A A A A A A A A  |A  5 +++++ </tt><tt><br>
    </tt><tt> A include/uapi/linux/userfaultfd.h | 10 +++++++++- </tt><tt><br>
    </tt><tt> A 2 files changed, 14 insertions(+), 1 deletion(-) </tt><tt><br>
    </tt><tt> </tt><tt><br>
    </tt><tt> diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c </tt><tt><br>
    </tt><tt> index 1d622f2..5686d6d2 100644 </tt><tt><br>
    </tt><tt> --- a/fs/userfaultfd.c </tt><tt><br>
    </tt><tt> +++ b/fs/userfaultfd.c </tt><tt><br>
    </tt><tt> @@ -371,6 +371,11 @@ int handle_userfault(struct vm_fault
      *vmf, unsigned long reason) </tt><tt><br>
    </tt><tt> A A A A  VM_BUG_ON(reason &amp;
      ~(VM_UFFD_MISSING|VM_UFFD_WP)); </tt><tt><br>
    </tt><tt> A A A A  VM_BUG_ON(!(reason &amp; VM_UFFD_MISSING) ^ !!(reason
      &amp; VM_UFFD_WP)); </tt><tt><br>
    </tt><tt> </tt><tt><br>
    </tt><tt> +A A A  if (ctx-&gt;features &amp; UFFD_FEATURE_SIGBUS) { </tt><tt><br>
    </tt><tt> +A A A A A A A  goto out; </tt><tt><br>
    </tt><tt> +A A A  } </tt><tt><br>
    </tt><tt> + </tt><tt><br>
    </tt><tt> A A A A  /* </tt><tt><br>
    </tt><tt> A A A A A  * If it's already released don't get it. This avoids
      to loop </tt><tt><br>
    </tt><tt> A A A A A  * in __get_user_pages if userfaultfd_release waits
      on the </tt><tt><br>
    </tt><tt> diff --git a/include/uapi/linux/userfaultfd.h
      b/include/uapi/linux/userfaultfd.h </tt><tt><br>
    </tt><tt> index 3b05953..d39d5db 100644 </tt><tt><br>
    </tt><tt> --- a/include/uapi/linux/userfaultfd.h </tt><tt><br>
    </tt><tt> +++ b/include/uapi/linux/userfaultfd.h </tt><tt><br>
    </tt><tt> @@ -23,7 +23,8 @@ </tt><tt><br>
    </tt><tt> A A A A A A A A A A A A A A A  UFFD_FEATURE_EVENT_REMOVE |A A A  \ </tt><tt><br>
    </tt><tt> A A A A A A A A A A A A A A A  UFFD_FEATURE_EVENT_UNMAP |A A A A A A A  \ </tt><tt><br>
    </tt><tt> A A A A A A A A A A A A A A A  UFFD_FEATURE_MISSING_HUGETLBFS |A A A  \ </tt><tt><br>
    </tt><tt> -A A A A A A A A A A A A A A  UFFD_FEATURE_MISSING_SHMEM) </tt><tt><br>
    </tt><tt> +A A A A A A A A A A A A A A  UFFD_FEATURE_MISSING_SHMEM |A A A A A A A  \ </tt><tt><br>
    </tt><tt> +A A A A A A A A A A A A A A  UFFD_FEATURE_SIGBUS) </tt><tt><br>
    </tt><tt> A #define UFFD_API_IOCTLSA A A A A A A A A A A A A A A  \ </tt><tt><br>
    </tt><tt> A A A A  ((__u64)1 &lt;&lt; _UFFDIO_REGISTER |A A A A A A A  \ </tt><tt><br>
    </tt><tt> A A A A A  (__u64)1 &lt;&lt; _UFFDIO_UNREGISTER |A A A  \ </tt><tt><br>
    </tt><tt> @@ -153,6 +154,12 @@ struct uffdio_api { </tt><tt><br>
    </tt><tt> A A A A A  * UFFD_FEATURE_MISSING_SHMEM works the same as </tt><tt><br>
    </tt><tt> A A A A A  * UFFD_FEATURE_MISSING_HUGETLBFS, but it applies to
      shmem </tt><tt><br>
    </tt><tt> A A A A A  * (i.e. tmpfs and other shmem based APIs). </tt><tt><br>
    </tt><tt> +A A A A  * </tt><tt><br>
    </tt><tt> +A A A A  * UFFD_FEATURE_SIGBUS feature means no page-fault </tt><tt><br>
    </tt><tt> +A A A A  * (UFFD_EVENT_PAGEFAULT) event will be delivered,
      instead </tt><tt><br>
    </tt><tt> +A A A A  * a SIGBUS signal will be sent to the faulting
      process. </tt><tt><br>
    </tt><tt> +A A A A  * The application process can enable this behavior
      by adding </tt><tt><br>
    </tt><tt> +A A A A  * it to uffdio_api.features. </tt><tt><br>
    </tt><tt> A A A A A  */ </tt><tt><br>
    </tt><tt> A #define UFFD_FEATURE_PAGEFAULT_FLAG_WPA A A A A A A 
      (1&lt;&lt;0) </tt><tt><br>
    </tt><tt> A #define UFFD_FEATURE_EVENT_FORKA A A A A A A A A A A  (1&lt;&lt;1) </tt><tt><br>
    </tt><tt> @@ -161,6 +168,7 @@ struct uffdio_api { </tt><tt><br>
    </tt><tt> A #define UFFD_FEATURE_MISSING_HUGETLBFSA A A A A A A 
      (1&lt;&lt;4) </tt><tt><br>
    </tt><tt> A #define UFFD_FEATURE_MISSING_SHMEMA A A A A A A  (1&lt;&lt;5) </tt><tt><br>
    </tt><tt> A #define UFFD_FEATURE_EVENT_UNMAPA A A A A A A  (1&lt;&lt;6) </tt><tt><br>
    </tt><tt> +#define UFFD_FEATURE_SIGBUSA A A A A A A A A A A  (1&lt;&lt;7) </tt><tt><br>
    </tt><tt> A A A A  __u64 features; </tt><tt><br>
    </tt><tt> </tt><tt><br>
    </tt><tt> A A A A  __u64 ioctls; </tt><tt><br>
    </tt><tt> </tt><tt><span class="moz-txt-tag">--A <br>
      </span></tt><tt>2.7.4 </tt><br>
  </body>
</html>

--------------96F7F87A7D87C44A8ED72EAF--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
