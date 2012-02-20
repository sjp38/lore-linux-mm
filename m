Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 19F386B004D
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 02:23:44 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id CA4463EE0AE
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 16:23:41 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B151A45DEB3
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 16:23:41 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9770645DE9E
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 16:23:41 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 852CF1DB803F
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 16:23:41 +0900 (JST)
Received: from m025.s.css.fujitsu.com (m025.s.css.fujitsu.com [10.0.81.65])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 400A11DB803E
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 16:23:41 +0900 (JST)
Message-ID: <4F41F50C.1010508@jp.fujitsu.com>
Date: Mon, 20 Feb 2012 16:23:56 +0900
From: Naotaka Hamaguchi <n.hamaguchi@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: mmap() sometimes succeeds even if the region to map
 is invalid.
References: <4F3E1319.6050304@jp.fujitsu.com> <D958900912E20642BCBC71664EFECE3E6DD198A7AE@BGMAIL02.nvidia.com>
In-Reply-To: <D958900912E20642BCBC71664EFECE3E6DD198A7AE@BGMAIL02.nvidia.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Venu Byravarasu <vbyravarasu@nvidia.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>

Hi Venu,

>> 1. mmap() succeeds even if "offset" argument is a negative value, although
>>     it should return EINVAL in such case.
>
>> In such case, it is actually regarded as big positive value
>> because the type of "off" is "unsigned long" in the kernel.
>> For example, off=-4096 (-0x1000) is regarded as
>> off = 0xfffffffffffff000 (x86_64) and as off = 0xfffff000 (x86).
>> It results in mapping too big offset region.
>
> It is not true always.
>
> Considering your example, say if page size is 4k, then PAGE_MASK = 0xFFF
> hence (off&  ~PAGE_MASK) will be true and " -EINVAL" will be returned.

Is PAGE_MASK 0xfffffffffffff000 (x86_64) and 0xfffff000 (x86), isn't it?
Or am I missing something?

arch/x86/include/asm/page_types.h
=================================================
...
#define PAGE_SHIFT      12
#define PAGE_SIZE       (_AC(1,UL) << PAGE_SHIFT)
#define PAGE_MASK       (~(PAGE_SIZE-1))
...
=================================================

Thanks,
Naotaka Hamaguchi

(2012/02/17 18:04), Venu Byravarasu wrote:
>> The detail of these problems is as follows:
>
>> 1. mmap() succeeds even if "offset" argument is a negative value, although
>>     it should return EINVAL in such case.
>
>> In such case, it is actually regarded as big positive value
>> because the type of "off" is "unsigned long" in the kernel.
>> For example, off=-4096 (-0x1000) is regarded as
>> off = 0xfffffffffffff000 (x86_64) and as off = 0xfffff000 (x86).
>> It results in mapping too big offset region.
>
> It is not true always.
>
> Considering your example, say if page size is 4k, then PAGE_MASK = 0xFFF
> hence (off&  ~PAGE_MASK) will be true and " -EINVAL" will be returned.
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
