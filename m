Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 6CD816B0032
	for <linux-mm@kvack.org>; Thu, 23 May 2013 18:00:37 -0400 (EDT)
Date: Thu, 23 May 2013 15:00:35 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v8 5/9] vmalloc: introduce remap_vmalloc_range_partial
Message-Id: <20130523150035.73dc8457e895155897ef8781@linux-foundation.org>
In-Reply-To: <20130523052524.13864.11784.stgit@localhost6.localdomain6>
References: <20130523052421.13864.83978.stgit@localhost6.localdomain6>
	<20130523052524.13864.11784.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
Cc: vgoyal@redhat.com, ebiederm@xmission.com, cpw@sgi.com, kumagai-atsushi@mxc.nes.nec.co.jp, lisa.mitchell@hp.com, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, zhangyanfei@cn.fujitsu.com, jingbai.ma@hp.com, linux-mm@kvack.org, riel@redhat.com, walken@google.com, hughd@google.com, kosaki.motohiro@jp.fujitsu.com

On Thu, 23 May 2013 14:25:24 +0900 HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com> wrote:

> We want to allocate ELF note segment buffer on the 2nd kernel in
> vmalloc space and remap it to user-space in order to reduce the risk
> that memory allocation fails on system with huge number of CPUs and so
> with huge ELF note segment that exceeds 11-order block size.
> 
> Although there's already remap_vmalloc_range for the purpose of
> remapping vmalloc memory to user-space, we need to specify user-space
> range via vma. Mmap on /proc/vmcore needs to remap range across
> multiple objects, so the interface that requires vma to cover full
> range is problematic.
> 
> This patch introduces remap_vmalloc_range_partial that receives
> user-space range as a pair of base address and size and can be used
> for mmap on /proc/vmcore case.
> 
> remap_vmalloc_range is rewritten using remap_vmalloc_range_partial.
> 
> ...
>
> +int remap_vmalloc_range_partial(struct vm_area_struct *vma, unsigned long uaddr,
> +				void *kaddr, unsigned long size)
>  {
>  	struct vm_struct *area;
> -	unsigned long uaddr = vma->vm_start;
> -	unsigned long usize = vma->vm_end - vma->vm_start;
>  
> -	if ((PAGE_SIZE-1) & (unsigned long)addr)
> +	size = PAGE_ALIGN(size);
> +
> +	if (((PAGE_SIZE-1) & (unsigned long)uaddr) ||
> +	    ((PAGE_SIZE-1) & (unsigned long)kaddr))
>  		return -EINVAL;

hm, that's ugly.


Why don't we do this:

From: Andrew Morton <akpm@linux-foundation.org>
Subject: include/linux/mm.h: add PAGE_ALIGNED() helper

To test whether an address is aligned to PAGE_SIZE.

Cc: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, 
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/linux/mm.h |    3 +++
 1 file changed, 3 insertions(+)

diff -puN include/linux/mm.h~a include/linux/mm.h
--- a/include/linux/mm.h~a
+++ a/include/linux/mm.h
@@ -52,6 +52,9 @@ extern unsigned long sysctl_admin_reserv
 /* to align the pointer to the (next) page boundary */
 #define PAGE_ALIGN(addr) ALIGN(addr, PAGE_SIZE)
 
+/* test whether an address (unsigned long or pointer) is aligned to PAGE_SIZE */
+#define PAGE_ALIGNED(addr)	IS_ALIGNED((unsigned long)addr, PAGE_SIZE)
+
 /*
  * Linux kernel virtual memory manager primitives.
  * The idea being to have a "virtual" mm in the same way
_


(I'd have thought we already had such a thing, but we don't seem to)


Then this:

From: Andrew Morton <akpm@linux-foundation.org>
Subject: vmalloc-introduce-remap_vmalloc_range_partial-fix

use PAGE_ALIGNED()

Cc: Atsushi Kumagai <kumagai-atsushi@mxc.nes.nec.co.jp>
Cc: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Lisa Mitchell <lisa.mitchell@hp.com>
Cc: Vivek Goyal <vgoyal@redhat.com>
Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/vmalloc.c |    8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff -puN include/linux/vmalloc.h~vmalloc-introduce-remap_vmalloc_range_partial-fix include/linux/vmalloc.h
diff -puN mm/vmalloc.c~vmalloc-introduce-remap_vmalloc_range_partial-fix mm/vmalloc.c
--- a/mm/vmalloc.c~vmalloc-introduce-remap_vmalloc_range_partial-fix
+++ a/mm/vmalloc.c
@@ -1476,10 +1476,9 @@ static void __vunmap(const void *addr, i
 	if (!addr)
 		return;
 
-	if ((PAGE_SIZE-1) & (unsigned long)addr) {
-		WARN(1, KERN_ERR "Trying to vfree() bad address (%p)\n", addr);
+	if (WARN(!PAGE_ALIGNED(addr), "Trying to vfree() bad address (%p)\n",
+			addr));
 		return;
-	}
 
 	area = remove_vm_area(addr);
 	if (unlikely(!area)) {
@@ -2170,8 +2169,7 @@ int remap_vmalloc_range_partial(struct v
 
 	size = PAGE_ALIGN(size);
 
-	if (((PAGE_SIZE-1) & (unsigned long)uaddr) ||
-	    ((PAGE_SIZE-1) & (unsigned long)kaddr))
+	if (!PAGE_ALIGNED(uaddr) || !PAGE_ALIGNED(kaddr))
 		return -EINVAL;
 
 	area = find_vm_area(kaddr);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
