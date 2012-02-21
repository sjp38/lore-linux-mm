Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id B4C386B004D
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 03:30:03 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id C081D3EE0B6
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 17:30:01 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A8F5345DE50
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 17:30:01 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8F16445DE4F
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 17:30:01 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7ED561DB8037
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 17:30:01 +0900 (JST)
Received: from m022.s.css.fujitsu.com (m022.s.css.fujitsu.com [10.0.81.62])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3CCEC1DB802F
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 17:30:01 +0900 (JST)
Message-ID: <4F43561F.2020905@jp.fujitsu.com>
Date: Tue, 21 Feb 2012 17:30:23 +0900
From: Naotaka Hamaguchi <n.hamaguchi@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: mmap() sometimes succeeds even if the region to map
 is invalid.
References: <4F3E1319.6050304@jp.fujitsu.com> <alpine.LSU.2.00.1202171703260.24948@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1202171703260.24948@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@gmail.com>

Hi Hugh,

> 1. Should a negative offset necessarily return -EINVAL?  At present I
>     can mmap() /dev/kmem on x86_64 and see what's at 0xffff880000000000:
>     why should that say -EINVAL?  (I admit that my example wanted to say
>     0xffffffff81000000, where /proc/kallsyms locates _text, but that did
>     disappoint me with -EINVAL, because mmap_kmem() only understands the
>     direct map, not the further layouts which architectures may use.)
>
> 2. We will have bugs if you manage to mmap an area crossing from pgoff
>     -1 to pgoff 0, but I thought the existing checks prevented that.

>> -       if ((pgoff + (len>>  PAGE_SHIFT))<  pgoff)
>> +       if ((off + len)<  off)
>>                  return -EOVERFLOW;
>
> I think you are taking away the 32-bit kernel's ability to mmap() files
> up to MAX_LFS_FILESIZE.

Thanks, I see. I drop this patch.

BTW, I think the current error check of EOVERFLOW is meaningless, isn't it?

mm/mmap.c
===================================================================
unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
                         unsigned long len, unsigned long prot,
                         unsigned long flags, unsigned long pgoff)
{
...
        /* offset overflow? */
         if ((pgoff + (len >> PAGE_SHIFT)) < pgoff)
                return -EOVERFLOW;
...
===================================================================

Thanks,
Naotaka Hamaguchi

(2012/02/18 11:00), Hugh Dickins wrote:
> On Fri, 17 Feb 2012, Naotaka Hamaguchi wrote:
>> This patch fixes two bugs of mmap():
>>   1. mmap() succeeds even if "offset" argument is a negative value, although
>>      it should return EINVAL in such case. Currently I have only checked
>>      it on x86_64 because (a) x86 seems to OK to accept a negative offset
>>      for mapping 2GB-4GB regions, and (b) I don't know about other
>>      architectures at all (I'll make it if needed).
>>
>>   2. mmap() would succeed if "offset" + "length" get overflow, although
>>      it should return EOVERFLOW.
>
> I'm not convinced that either of these is a problem.  Do you see an
> actual bug arising from these, or is it just that you think the Linux
> mmap() permits more than you expect from your reading of POSIX?
>
> 1. Should a negative offset necessarily return -EINVAL?  At present I
>     can mmap() /dev/kmem on x86_64 and see what's at 0xffff880000000000:
>     why should that say -EINVAL?  (I admit that my example wanted to say
>     0xffffffff81000000, where /proc/kallsyms locates _text, but that did
>     disappoint me with -EINVAL, because mmap_kmem() only understands the
>     direct map, not the further layouts which architectures may use.)
>
> 2. We will have bugs if you manage to mmap an area crossing from pgoff
>     -1 to pgoff 0, but I thought the existing checks prevented that.
>
> mmap() should be permitting as far as it safely can; but it's a bug
> if a fault on an offset beyond (page-rounded-up) end-of-file does not
> then give SIGBUS.
>
>>
>> The detail of these problems is as follows:
>>
>> 1. mmap() succeeds even if "offset" argument is a negative value, although
>>     it should return EINVAL in such case.
>>
>> POSIX says the type of the argument "off" is "off_t", which
>> is equivalent to "long" for all architecture, so it is allowed to
>> give a negative "off" to mmap().
>>
>> In such case, it is actually regarded as big positive value
>> because the type of "off" is "unsigned long" in the kernel.
>> For example, off=-4096 (-0x1000) is regarded as
>> off = 0xfffffffffffff000 (x86_64) and as off = 0xfffff000 (x86).
>> It results in mapping too big offset region.
>>
>> 2. mmap() would succeed if "offset" + "length" get overflow, although
>>     it should return EOVERFLOW.
>>
>> The overflow check of mmap() almost doesn't work.
>>
>> In do_mmap_pgoff(file, addr, len, prot, flags, pgoff),
>> the existing overflow check logic is as follows.
>>
>> ------------------------------------------------------------------------
>> do_mmap_pgoff(struct file *file, unsigned long addr,
>> 		unsigned long len, unsigned long prot,
>> 		unsigned long flags, unsigned long pgoff)
>> {
>> 	if ((pgoff + (len>>  PAGE_SHIFT))<  pgoff)
>> 		return -EOVERFLOW;
>> }
>> ------------------------------------------------------------------------
>>
>> However, for example on x86_64, if we give off=0x1000 and
>> len=0xfffffffffffff000, but EOVERFLOW is not returned.
>> It is because the checking is based on the page offset,
>> not on the byte offset.
>>
>> To fix this bug, I convert this overflow check from page
>> offset base to byte offset base.
>>
>> Signed-off-by: Naotaka Hamaguchi<n.hamaguchi@jp.fujitsu.com>
>> ---
>>   arch/x86/kernel/sys_x86_64.c |    3 +++
>>   mm/mmap.c                    |    3 ++-
>>   2 files changed, 5 insertions(+), 1 deletions(-)
>>
>> diff --git a/arch/x86/kernel/sys_x86_64.c b/arch/x86/kernel/sys_x86_64.c
>> index 0514890..ddefd6c 100644
>> --- a/arch/x86/kernel/sys_x86_64.c
>> +++ b/arch/x86/kernel/sys_x86_64.c
>> @@ -90,6 +90,9 @@ SYSCALL_DEFINE6(mmap, unsigned long, addr, unsigned long, len,
>>          if (off&  ~PAGE_MASK)
>>                  goto out;
>>
>> +       if ((off_t) off<  0)
>> +               goto out;
>> +
>>          error = sys_mmap_pgoff(addr, len, prot, flags, fd, off>>  PAGE_SHIFT);
>>   out:
>>          return error;
>> diff --git a/mm/mmap.c b/mm/mmap.c
>> index 3f758c7..2fa99cd 100644
>> --- a/mm/mmap.c
>> +++ b/mm/mmap.c
>> @@ -948,6 +948,7 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
>>          vm_flags_t vm_flags;
>>          int error;
>>          unsigned long reqprot = prot;
>> +       unsigned long off = pgoff<<  PAGE_SHIFT;
>>
>>          /*
>>           * Does the application expect PROT_READ to imply PROT_EXEC?
>> @@ -971,7 +972,7 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
>>                  return -ENOMEM;
>>
>>          /* offset overflow? */
>> -       if ((pgoff + (len>>  PAGE_SHIFT))<  pgoff)
>> +       if ((off + len)<  off)
>>                  return -EOVERFLOW;
>
> I think you are taking away the 32-bit kernel's ability to mmap() files
> up to MAX_LFS_FILESIZE.
>
> Hugh
>
>>
>>          /* Too many mappings? */
>> --
>> 1.7.7.4
>>
>> Best Regards,
>> Naotaka Hamaguchi
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
