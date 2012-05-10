Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 9839E6B0044
	for <linux-mm@kvack.org>; Thu, 10 May 2012 03:56:53 -0400 (EDT)
Message-ID: <4FAB74C9.30702@kernel.org>
Date: Thu, 10 May 2012 16:56:57 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2 v3] drm/exynos: added userptr feature.
References: <1335188594-17454-4-git-send-email-inki.dae@samsung.com> <1336544259-17222-1-git-send-email-inki.dae@samsung.com> <1336544259-17222-3-git-send-email-inki.dae@samsung.com> <CAH3drwZBb=XBYpx=Fv=Xv0hajic51V9RwzY_-CpjKDuxgAj9Qg@mail.gmail.com> <001501cd2e4d$c7dbc240$579346c0$%dae@samsung.com> <4FAB4AD8.2010200@kernel.org> <4FAB65D7.6080003@gmail.com> <4FAB6DDB.7020504@kernel.org> <CAH9JG2UY_xPznFU7qQcR4aPXaN+AkJKv__hW7soXjchxM95XFA@mail.gmail.com>
In-Reply-To: <CAH9JG2UY_xPznFU7qQcR4aPXaN+AkJKv__hW7soXjchxM95XFA@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kyungmin Park <kyungmin.park@samsung.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Inki Dae <inki.dae@samsung.com>, Jerome Glisse <j.glisse@gmail.com>, airlied@linux.ie, dri-devel@lists.freedesktop.org, sw0312.kim@samsung.com, linux-mm@kvack.org

On 05/10/2012 04:31 PM, Kyungmin Park wrote:

> On 5/10/12, Minchan Kim <minchan@kernel.org> wrote:
>> On 05/10/2012 03:53 PM, KOSAKI Motohiro wrote:
>>
>>> (5/10/12 12:58 AM), Minchan Kim wrote:
>>>> On 05/10/2012 10:39 AM, Inki Dae wrote:
>>>>
>>>>> Hi Jerome,
>>>>>
>>>>>> -----Original Message-----
>>>>>> From: Jerome Glisse [mailto:j.glisse@gmail.com]
>>>>>> Sent: Wednesday, May 09, 2012 11:46 PM
>>>>>> To: Inki Dae
>>>>>> Cc: airlied@linux.ie; dri-devel@lists.freedesktop.org;
>>>>>> kyungmin.park@samsung.com; sw0312.kim@samsung.com; linux-mm@kvack.org
>>>>>> Subject: Re: [PATCH 2/2 v3] drm/exynos: added userptr feature.
>>>>>>
>>>>>> On Wed, May 9, 2012 at 2:17 AM, Inki Dae<inki.dae@samsung.com>  wrote:
>>>>>>> this feature is used to import user space region allocated by
>>>>>>> malloc()
>>>>>> or
>>>>>>> mmaped into a gem. and to guarantee the pages to user space not to be
>>>>>>> swapped out, the VMAs within the user space would be locked and then
>>>>>> unlocked
>>>>>>> when the pages are released.
>>>>>>>
>>>>>>> but this lock might result in significant degradation of system
>>>>>> performance
>>>>>>> because the pages couldn't be swapped out so we limit user-desired
>>>>>> userptr
>>>>>>> size to pre-defined.
>>>>>>>
>>>>>>> Signed-off-by: Inki Dae<inki.dae@samsung.com>
>>>>>>> Signed-off-by: Kyungmin Park<kyungmin.park@samsung.com>
>>>>>>
>>>>>>
>>>>>> Again i would like feedback from mm people (adding cc). I am not sure
>>>>>
>>>>> Thank you, I missed adding mm as cc.
>>>>>
>>>>>> locking the vma is the right anwser as i said in my previous mail,
>>>>>> userspace can munlock it in your back, maybe VM_RESERVED is better.
>>>>>
>>>>> I know that with VM_RESERVED flag, also we can avoid the pages from
>>>>> being
>>>>> swapped out. but these pages should be unlocked anytime we want
>>>>> because we
>>>>> could allocate all pages on system and lock them, which in turn, it may
>>>>> result in significant deterioration of system performance.(maybe other
>>>>> processes requesting free memory would be blocked) so I used
>>>>> VM_LOCKED flags
>>>>> instead. but I'm not sure this way is best also.
>>>>>
>>>>>> Anyway even not considering that you don't check at all that process
>>>>>> don't go over the limit of locked page see mm/mlock.c RLIMIT_MEMLOCK
>>>>>
>>>>> Thank you for your advices.
>>>>>
>>>>>> for how it's done. Also you mlock complete vma but the userptr you get
>>>>>> might be inside say 16M vma and you only care about 1M of userptr, if
>>>>>> you mark the whole vma as locked than anytime a new page is fault in
>>>>>> the vma else where than in the buffer you are interested then it got
>>>>>> allocated for ever until the gem buffer is destroy, i am not sure of
>>>>>> what happen to the vma on next malloc if it grows or not (i would
>>>>>> think it won't grow at it would have different flags than new
>>>>>> anonymous memory).
>>>>
>>>>
>>>> I don't know history in detail because you didn't have sent full
>>>> patches to linux-mm and
>>>> I didn't read the below code, either.
>>>> Just read your description and reply of Jerome. Apparently, there is
>>>> something I missed.
>>>>
>>>> Your goal is to avoid swap out some user pages which is used in kernel
>>>> at the same time. Right?
>>>> Let's use get_user_pages. Is there any issue you can't use it?
>>>
>>> Maybe because get_user_pages() is fork unsafe? dunno.
>>
>>
>> If there is such problem, I think user program should handle it by
>> MADV_DONTFORK
>> and make to allow write by only parent process.
> Please read the original patches and discuss the root cause. Does it
> harm to pass user space memory to kernel space and how to make is
> possible at DRM?


Where can I read original discussion history?
I am not expert of DRAM so I can answer only mm stuff and it's why Jerome ccing mm-list.
About mm stuff, I think it's no harm for kernel to use user space memory if it uses carefully.
If you are saying about permission, at least, DRM code can check it by can_do_mlock and checking lock_limit.
If you are saying another security, I'm not right person to discuss it.
please Ccing security@kernel.org.

Thanks.

> 
> Thank you,
> Kyungmin Park
>>
>> --
>> Kind regards,
>> Minchan Kim
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Fight unfair telecom internet charges in Canada: sign
>> http://stopthemeter.ca/
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
