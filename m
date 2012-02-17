Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id D12CC6B007E
	for <linux-mm@kvack.org>; Fri, 17 Feb 2012 03:42:45 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id EA91F3EE0C5
	for <linux-mm@kvack.org>; Fri, 17 Feb 2012 17:42:43 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id CE0E045DE4E
	for <linux-mm@kvack.org>; Fri, 17 Feb 2012 17:42:43 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A8BF545DD74
	for <linux-mm@kvack.org>; Fri, 17 Feb 2012 17:42:43 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9A4EF1DB803C
	for <linux-mm@kvack.org>; Fri, 17 Feb 2012 17:42:43 +0900 (JST)
Received: from m021.s.css.fujitsu.com (m021.s.css.fujitsu.com [10.0.81.61])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 461AA1DB802C
	for <linux-mm@kvack.org>; Fri, 17 Feb 2012 17:42:43 +0900 (JST)
Message-ID: <4F3E1319.6050304@jp.fujitsu.com>
Date: Fri, 17 Feb 2012 17:43:05 +0900
From: Naotaka Hamaguchi <n.hamaguchi@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH] mm: mmap() sometimes succeeds even if the region to map is
 invalid.
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>

This patch fixes two bugs of mmap():
 1. mmap() succeeds even if "offset" argument is a negative value, although
    it should return EINVAL in such case. Currently I have only checked
    it on x86_64 because (a) x86 seems to OK to accept a negative offset
    for mapping 2GB-4GB regions, and (b) I don't know about other
    architectures at all (I'll make it if needed).

 2. mmap() would succeed if "offset" + "length" get overflow, although
    it should return EOVERFLOW.

The detail of these problems is as follows:

1. mmap() succeeds even if "offset" argument is a negative value, although
   it should return EINVAL in such case.

POSIX says the type of the argument "off" is "off_t", which
is equivalent to "long" for all architecture, so it is allowed to
give a negative "off" to mmap().

In such case, it is actually regarded as big positive value
because the type of "off" is "unsigned long" in the kernel. 
For example, off=-4096 (-0x1000) is regarded as 
off = 0xfffffffffffff000 (x86_64) and as off = 0xfffff000 (x86).
It results in mapping too big offset region.

2. mmap() would succeed if "offset" + "length" get overflow, although
   it should return EOVERFLOW.

The overflow check of mmap() almost doesn't work.

In do_mmap_pgoff(file, addr, len, prot, flags, pgoff),
the existing overflow check logic is as follows.

------------------------------------------------------------------------
do_mmap_pgoff(struct file *file, unsigned long addr,
		unsigned long len, unsigned long prot,
		unsigned long flags, unsigned long pgoff)
{
	if ((pgoff + (len >> PAGE_SHIFT)) < pgoff)
		return -EOVERFLOW;
}
------------------------------------------------------------------------

However, for example on x86_64, if we give off=0x1000 and
len=0xfffffffffffff000, but EOVERFLOW is not returned.
It is because the checking is based on the page offset,
not on the byte offset.

To fix this bug, I convert this overflow check from page
offset base to byte offset base. 

Signed-off-by: Naotaka Hamaguchi <n.hamaguchi@jp.fujitsu.com>
---
 arch/x86/kernel/sys_x86_64.c |    3 +++
 mm/mmap.c                    |    3 ++-
 2 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/arch/x86/kernel/sys_x86_64.c b/arch/x86/kernel/sys_x86_64.c
index 0514890..ddefd6c 100644
--- a/arch/x86/kernel/sys_x86_64.c
+++ b/arch/x86/kernel/sys_x86_64.c
@@ -90,6 +90,9 @@ SYSCALL_DEFINE6(mmap, unsigned long, addr, unsigned long, len,
        if (off & ~PAGE_MASK)
                goto out;

+       if ((off_t) off < 0)
+               goto out;
+
        error = sys_mmap_pgoff(addr, len, prot, flags, fd, off >> PAGE_SHIFT);
 out:
        return error;
diff --git a/mm/mmap.c b/mm/mmap.c
index 3f758c7..2fa99cd 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -948,6 +948,7 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
        vm_flags_t vm_flags;
        int error;
        unsigned long reqprot = prot;
+       unsigned long off = pgoff << PAGE_SHIFT;

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

Best Regards,
Naotaka Hamaguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
