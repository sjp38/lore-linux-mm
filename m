Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 1CC456B0032
	for <linux-mm@kvack.org>; Thu, 23 May 2013 18:24:47 -0400 (EDT)
Date: Thu, 23 May 2013 15:24:45 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v8 9/9] vmcore: support mmap() on /proc/vmcore
Message-Id: <20130523152445.17549682ae45b5aab3f3cde0@linux-foundation.org>
In-Reply-To: <20130523052547.13864.83306.stgit@localhost6.localdomain6>
References: <20130523052421.13864.83978.stgit@localhost6.localdomain6>
	<20130523052547.13864.83306.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
Cc: vgoyal@redhat.com, ebiederm@xmission.com, cpw@sgi.com, kumagai-atsushi@mxc.nes.nec.co.jp, lisa.mitchell@hp.com, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, zhangyanfei@cn.fujitsu.com, jingbai.ma@hp.com, linux-mm@kvack.org, riel@redhat.com, walken@google.com, hughd@google.com, kosaki.motohiro@jp.fujitsu.com

On Thu, 23 May 2013 14:25:48 +0900 HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com> wrote:

> This patch introduces mmap_vmcore().
> 
> Don't permit writable nor executable mapping even with mprotect()
> because this mmap() is aimed at reading crash dump memory.
> Non-writable mapping is also requirement of remap_pfn_range() when
> mapping linear pages on non-consecutive physical pages; see
> is_cow_mapping().
> 
> Set VM_MIXEDMAP flag to remap memory by remap_pfn_range and by
> remap_vmalloc_range_pertial at the same time for a single
> vma. do_munmap() can correctly clean partially remapped vma with two
> functions in abnormal case. See zap_pte_range(), vm_normal_page() and
> their comments for details.
> 
> On x86-32 PAE kernels, mmap() supports at most 16TB memory only. This
> limitation comes from the fact that the third argument of
> remap_pfn_range(), pfn, is of 32-bit length on x86-32: unsigned long.

More reviewing and testing, please.


From: Andrew Morton <akpm@linux-foundation.org>
Subject: vmcore-support-mmap-on-proc-vmcore-fix

use min(), switch to conventional error-unwinding approach

Cc: Atsushi Kumagai <kumagai-atsushi@mxc.nes.nec.co.jp>
Cc: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Lisa Mitchell <lisa.mitchell@hp.com>
Cc: Vivek Goyal <vgoyal@redhat.com>
Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 fs/proc/vmcore.c |   27 ++++++++++-----------------
 1 file changed, 10 insertions(+), 17 deletions(-)

diff -puN fs/proc/vmcore.c~vmcore-support-mmap-on-proc-vmcore-fix fs/proc/vmcore.c
--- a/fs/proc/vmcore.c~vmcore-support-mmap-on-proc-vmcore-fix
+++ a/fs/proc/vmcore.c
@@ -218,9 +218,7 @@ static int mmap_vmcore(struct file *file
 	if (start < elfcorebuf_sz) {
 		u64 pfn;
 
-		tsz = elfcorebuf_sz - start;
-		if (size < tsz)
-			tsz = size;
+		tsz = min(elfcorebuf_sz - (size_t)start, size);
 		pfn = __pa(elfcorebuf + start) >> PAGE_SHIFT;
 		if (remap_pfn_range(vma, vma->vm_start, pfn, tsz,
 				    vma->vm_page_prot))
@@ -236,15 +234,11 @@ static int mmap_vmcore(struct file *file
 	if (start < elfcorebuf_sz + elfnotes_sz) {
 		void *kaddr;
 
-		tsz = elfcorebuf_sz + elfnotes_sz - start;
-		if (size < tsz)
-			tsz = size;
+		tsz = min(elfcorebuf_sz + elfnotes_sz - (size_t)start, size);
 		kaddr = elfnotes_buf + start - elfcorebuf_sz;
 		if (remap_vmalloc_range_partial(vma, vma->vm_start + len,
-						kaddr, tsz)) {
-			do_munmap(vma->vm_mm, vma->vm_start, len);
-			return -EAGAIN;
-		}
+						kaddr, tsz))
+			goto fail;
 		size -= tsz;
 		start += tsz;
 		len += tsz;
@@ -257,16 +251,12 @@ static int mmap_vmcore(struct file *file
 		if (start < m->offset + m->size) {
 			u64 paddr = 0;
 
-			tsz = m->offset + m->size - start;
-			if (size < tsz)
-				tsz = size;
+			tsz = min_t(size_t, m->offset + m->size - start, size);
 			paddr = m->paddr + start - m->offset;
 			if (remap_pfn_range(vma, vma->vm_start + len,
 					    paddr >> PAGE_SHIFT, tsz,
-					    vma->vm_page_prot)) {
-				do_munmap(vma->vm_mm, vma->vm_start, len);
-				return -EAGAIN;
-			}
+					    vma->vm_page_prot))
+				goto fail;
 			size -= tsz;
 			start += tsz;
 			len += tsz;
@@ -277,6 +267,9 @@ static int mmap_vmcore(struct file *file
 	}
 
 	return 0;
+fail:
+	do_munmap(vma->vm_mm, vma->vm_start, len);
+	return -EAGAIN;
 }
 
 static const struct file_operations proc_vmcore_operations = {
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
