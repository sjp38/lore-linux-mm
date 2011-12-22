Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 3D59B6B004D
	for <linux-mm@kvack.org>; Thu, 22 Dec 2011 04:35:39 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 6228B3EE0BC
	for <linux-mm@kvack.org>; Thu, 22 Dec 2011 18:35:37 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3FB3E45DEB3
	for <linux-mm@kvack.org>; Thu, 22 Dec 2011 18:35:37 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1EFE145DEB2
	for <linux-mm@kvack.org>; Thu, 22 Dec 2011 18:35:37 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 11A231DB8038
	for <linux-mm@kvack.org>; Thu, 22 Dec 2011 18:35:37 +0900 (JST)
Received: from m024.s.css.fujitsu.com (m024.s.css.fujitsu.com [10.0.81.64])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C2BD61DB8042
	for <linux-mm@kvack.org>; Thu, 22 Dec 2011 18:35:36 +0900 (JST)
Message-ID: <4EF2F9EB.7000006@jp.fujitsu.com>
Date: Thu, 22 Dec 2011 18:35:39 +0900
From: Naotaka Hamaguchi <n.hamaguchi@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH] mm: mmap system call does not return EOVERFLOW
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org

In the system call mmap(), if the value of "offset" plus "length"
exceeds the offset maximum of "off_t", the error EOVERFLOW should be
returned.

------------------------------------------------------------------------
void *mmap(void *addr, size_t length, int prot, int flags,
       	   int fd, off_t offset)
------------------------------------------------------------------------

Here is the detail how EOVERFLOW is returned:

The argument "offset" is shifted right by PAGE_SHIFT bits
in sys_mmap(mmap systemcall).

------------------------------------------------------------------------
sys_mmap(unsigned long addr, unsigned long len,
	unsigned long prot, unsigned long flags,
	unsigned long fd, unsigned long off)
{
	error = sys_mmap_pgoff(addr, len, prot, flags, fd, off >> PAGE_SHIFT);
}
------------------------------------------------------------------------

In sys_mmap_pgoff(addr, len, prot, flags, fd, pgoff), do_mmap_pgoff()
is called as follows:

------------------------------------------------------------------------
sys_mmap_pgoff(unsigned long addr, unsigned long len,
		unsigned long prot, unsigned long flags,
		unsigned long fd, unsigned long pgoff)
{
	retval = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
}
------------------------------------------------------------------------

In do_mmap_pgoff(file, addr, len, prot, flags, pgoff),
the code path which returns with the error EOVERFLOW exists already.

------------------------------------------------------------------------
do_mmap_pgoff(struct file *file, unsigned long addr,
		unsigned long len, unsigned long prot,
		unsigned long flags, unsigned long pgoff)
{
	if ((pgoff + (len >> PAGE_SHIFT)) < pgoff)
		return -EOVERFLOW;
}
------------------------------------------------------------------------

However, in this case, giving off=0xfffffffffffff000 and
len=0xfffffffffffff000 on x86_64 arch, EOVERFLOW is not
returned. It is because the argument, "off" and "len" are shifted right
by PAGE_SHIFT bits and thus the condition "(pgoff + (len >> PAGE_SHIFT)) < pgoff"
never becomes true.

To fix this bug, it is necessary to compare "off" plus "len"
with "off" by units of "off_t". The patch is here:

Signed-off-by: Naotaka Hamaguchi <n.hamaguchi@jp.fujitsu.com>
---
 mm/mmap.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index eae90af..e74e736 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -948,6 +948,7 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
        vm_flags_t vm_flags;
        int error;
        unsigned long reqprot = prot;
+       off_t off = pgoff << PAGE_SHIFT;
 
        /*
         * Does the application expect PROT_READ to imply PROT_EXEC?
@@ -971,7 +972,7 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
                return -ENOMEM;
 
        /* offset overflow? */
-       if ((pgoff + (len >> PAGE_SHIFT)) < pgoff)
+       if ((off + len) < off)
                return -EOVERFLOW;
 
        /* Too many mappings? */
-- 
1.7.7.4
---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
