Date: Thu, 20 Mar 2008 12:22:07 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [1/2] vmalloc: Show vmalloced areas via /proc/vmallocinfo
In-Reply-To: <20080319210436.191bb8fe@laptopd505.fenrus.org>
Message-ID: <Pine.LNX.4.64.0803201141250.10592@schroedinger.engr.sgi.com>
References: <20080318222701.788442216@sgi.com> <20080318222827.291587297@sgi.com>
 <20080319210436.191bb8fe@laptopd505.fenrus.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arjan van de Ven <arjan@infradead.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 19 Mar 2008, Arjan van de Ven wrote:

> > +	proc_create("vmallocinfo",S_IWUSR|S_IRUGO, NULL,
> why should non-root be able to read this? sounds like a security issue (info leak) to me...

Well I copied from the slabinfo logic (leaking info for slabs is okay?).

Lets restrict it to root then:



Subject: vmallocinfo: Only allow root to read /proc/vmallocinfo

Change permissions for /proc/vmallocinfo to only allow read
for root.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 fs/proc/proc_misc.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

Index: linux-2.6.25-rc5-mm1/fs/proc/proc_misc.c
===================================================================
--- linux-2.6.25-rc5-mm1.orig/fs/proc/proc_misc.c	2008-03-20 12:14:20.215358835 -0700
+++ linux-2.6.25-rc5-mm1/fs/proc/proc_misc.c	2008-03-20 12:23:01.920887750 -0700
@@ -1002,8 +1002,7 @@ void __init proc_misc_init(void)
 	proc_create("slab_allocators", 0, NULL, &proc_slabstats_operations);
 #endif
 #endif
-	proc_create("vmallocinfo",S_IWUSR|S_IRUGO, NULL,
-						&proc_vmalloc_operations);
+	proc_create("vmallocinfo",S_IRUSR, NULL, &proc_vmalloc_operations);
 	proc_create("buddyinfo", S_IRUGO, NULL, &fragmentation_file_operations);
 	proc_create("pagetypeinfo", S_IRUGO, NULL, &pagetypeinfo_file_ops);
 	proc_create("vmstat", S_IRUGO, NULL, &proc_vmstat_file_operations);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
