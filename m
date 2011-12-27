Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 0DA726B0062
	for <linux-mm@kvack.org>; Tue, 27 Dec 2011 01:21:48 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 5795E3EE0BC
	for <linux-mm@kvack.org>; Tue, 27 Dec 2011 15:21:47 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 89F3745DF59
	for <linux-mm@kvack.org>; Tue, 27 Dec 2011 15:21:46 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 60EE345DF58
	for <linux-mm@kvack.org>; Tue, 27 Dec 2011 15:21:46 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 55BB01DB803C
	for <linux-mm@kvack.org>; Tue, 27 Dec 2011 15:21:46 +0900 (JST)
Received: from m021.s.css.fujitsu.com (m021.s.css.fujitsu.com [10.0.81.61])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 02A55EF8004
	for <linux-mm@kvack.org>; Tue, 27 Dec 2011 15:21:46 +0900 (JST)
Message-ID: <4EF96406.6080102@jp.fujitsu.com>
Date: Tue, 27 Dec 2011 15:21:58 +0900
From: Naotaka Hamaguchi <n.hamaguchi@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: mmap system call does not return EOVERFLOW
References: <4EF2F9EB.7000006@jp.fujitsu.com> <4EF36BDA.5080105@gmail.com>
In-Reply-To: <4EF36BDA.5080105@gmail.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi, Kosaki-san

> Which version are you looking at? Current code seems to don't have
> sys_mmap().

This sys_mmap() means the entrance of mmap system call for x86_64.

----------------------------------------------------------------------
arch/x86/kernel/sys_x86_64.c:
  84 SYSCALL_DEFINE6(mmap, unsigned long, addr, unsigned long, len,
  85                 unsigned long, prot, unsigned long, flags,
  86                 unsigned long, fd, unsigned long, off)
  87 {
  88         long error;
  89         error = -EINVAL;
  90         if (off & ~PAGE_MASK)
  91                 goto out;
  92 
  93         error = sys_mmap_pgoff(addr, len, prot, flags, fd, off >> PAGE_SHIFT);
  94 out:
  95         return error;
  96 }
----------------------------------------------------------------------

This function calls sys_mmap_pgoff, which has the argument
"off >> PAGE_SHIFT". It means that sys_mmap_pgoff does not use off,
which is the argument of sys_mmap, with no change, but uses the value
obtained after off is shifted right by PAGE_SHIFT bits.

In mmap system call for x86, the following sys_mmap_pgoff is the
entrance in kernel.

----------------------------------------------------------------------
arch/x86/kernel/syscall_table_32.S:
...
 194         .long sys_mmap_pgoff
...

mm/mmap.c:
1080 SYSCALL_DEFINE6(mmap_pgoff, unsigned long, addr, unsigned long, len,
1081                 unsigned long, prot, unsigned long, flags,
1082                 unsigned long, fd, unsigned long, pgoff)
...
1111         down_write(&current->mm->mmap_sem);
1112         retval = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
1113         up_write(&current->mm->mmap_sem);
----------------------------------------------------------------------

> value. We have
> no reason to make artificial limit. Why don't you meke a overflow
> check in sys_mmap()?

I consider it is better to make an overflow check in do_mmap_pgoff.
There are two reasons:

1. If we make an overflow check in the entrance of system call, we
   have to check in sys_mmap for x86_64 and in sys_mmap_pgoff for
   x86. It means that we have to check for each architecture
   individually. Therefore, it is more effective to make an
   overflow check in do_mmap_pgoff because both sys_mmap and
   sys_mmap_pgoff call do_mmap_pgoff.

2. Because the argument "offset" of sys_mmap is a multiple
   of the page size(otherwise, EINVAL is returned.), no information
   is lost after shifting right by PAGE_SHIFT bits. Therefore
   to make an overflow check in do_mmap_pgoff is equivalent
   to check in sys_mmap.

Best Regards,
Naotaka Hamaguchi

(2011/12/23 2:41), KOSAKI Motohiro wrote:
>> The argument "offset" is shifted right by PAGE_SHIFT bits
>> in sys_mmap(mmap systemcall).
>>
>> ------------------------------------------------------------------------
>> sys_mmap(unsigned long addr, unsigned long len,
>> 	unsigned long prot, unsigned long flags,
>> 	unsigned long fd, unsigned long off)
>> {
>> 	error = sys_mmap_pgoff(addr, len, prot, flags, fd, off>>   PAGE_SHIFT);
>> }
>> ------------------------------------------------------------------------
> 
> Hm.
> Which version are you looking at? Current code seems to don't have
> sys_mmap().
> 
> 
> 
> 
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
