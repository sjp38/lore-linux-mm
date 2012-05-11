Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id C5D268D0001
	for <linux-mm@kvack.org>; Fri, 11 May 2012 17:20:33 -0400 (EDT)
Received: by qafl39 with SMTP id l39so2193002qaf.9
        for <linux-mm@kvack.org>; Fri, 11 May 2012 14:20:32 -0700 (PDT)
Message-ID: <4FAD829E.2030707@gmail.com>
Date: Fri, 11 May 2012 17:20:30 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2 v3] drm/exynos: added userptr feature.
References: <1335188594-17454-4-git-send-email-inki.dae@samsung.com> <1336544259-17222-1-git-send-email-inki.dae@samsung.com> <1336544259-17222-3-git-send-email-inki.dae@samsung.com> <CAH3drwZBb=XBYpx=Fv=Xv0hajic51V9RwzY_-CpjKDuxgAj9Qg@mail.gmail.com> <001501cd2e4d$c7dbc240$579346c0$%dae@samsung.com> <4FAB4AD8.2010200@kernel.org> <002401cd2e7a$1e8b0ed0$5ba12c70$%dae@samsung.com> <4FAB68CF.8000404@kernel.org> <CAAQKjZM0a-Lg8KYwWi+LwAXJPFYLKqWaKbuc4iUGVKyoStXu_w@mail.gmail.com> <4FAB782C.306@kernel.org> <003301cd2e89$13f78c00$3be6a400$%dae@samsung.com> <4FAC0091.7070606@gmail.com> <4FAC623E.7090209@kernel.org> <4FAC7EBA.1080708@gmail.com> <CAH3drwb-HKmCbf6RxK5OEyAgukBTDLxt0Rf4ZNsygGuZ5SB=5g@mail.gmail.com>
In-Reply-To: <CAH3drwb-HKmCbf6RxK5OEyAgukBTDLxt0Rf4ZNsygGuZ5SB=5g@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Inki Dae <inki.dae@samsung.com>, InKi Dae <daeinki@gmail.com>, airlied@linux.ie, dri-devel@lists.freedesktop.org, kyungmin.park@samsung.com, sw0312.kim@samsung.com, linux-mm@kvack.org

(5/10/12 11:01 PM), Jerome Glisse wrote:
> On Thu, May 10, 2012 at 10:51 PM, KOSAKI Motohiro
> <kosaki.motohiro@gmail.com>  wrote:
>> (5/10/12 8:50 PM), Minchan Kim wrote:
>>>
>>> Hi KOSAKI,
>>>
>>> On 05/11/2012 02:53 AM, KOSAKI Motohiro wrote:
>>>
>>>>>>> let's assume that one application want to allocate user space memory
>>>>>>> region using malloc() and then write something on the region. as you
>>>>>>> may know, user space buffer doen't have real physical pages once
>>>>>>> malloc() call so if user tries to access the region then page fault
>>>>>>> handler would be triggered
>>>>>>
>>>>>>
>>>>>>
>>>>>> Understood.
>>>>>>
>>>>>>> and then in turn next process like swap in to fill physical frame
>>>>>>> number
>>>>>>
>>>>>> into entry of the page faulted.
>>>>>>
>>>>>>
>>>>>> Sorry, I can't understand your point due to my poor English.
>>>>>> Could you rewrite it easiliy? :)
>>>>>>
>>>>>
>>>>> Simply saying, handle_mm_fault would be called to update pte after
>>>>> finding
>>>>> vma and checking access right. and as you know, there are many cases to
>>>>> process page fault such as COW or demand paging.
>>>>
>>>>
>>>> Hmm. If I understand correctly, you guys misunderstand mlock. it doesn't
>>>> page pinning
>>>> nor prevent pfn change. It only guarantee to don't make swap out. e.g.
>>>
>>>
>>>
>>> Symantic point of view, you're right but the implementation makes sure
>>> page pinning.
>>>
>>>> memory campaction
>>>> feature may automatically change page physical address.
>>>
>>>
>>>
>>> I tried it last year but decided drop by realtime issue.
>>> https://lkml.org/lkml/2011/8/29/295
>>>
>>> so I think mlock is a kind of page pinning. If elsewhere I don't realized
>>> is doing, that place should be fixed.
>>> Or my above patch should go ahead.
>>
>>
>> Thanks pointing out. I didn't realized your patch didn't merged. I think it
>> should go ahead. think autonuma case,
>> if mlock disable autonuma migration, that's bug.  I don't think we can
>> promise mlock don't change physical page.
>> I wonder if any realtime guys page migration is free lunch. they should
>> disable both auto migration and compaction.
>>
>> And, think if application explictly use migrate_pages(2) or admins uses
>> cpusets. driver code can't assume such scenario
>> doesn't occur, yes?
>>
>>
>
> I am ok with patch being merge as is if you add restriction for the
> ioctl to be root only and a big comment stating that user ptr thing is
> just abusing the kernel API and that it should not be replicated by
> other driver except if fully understanding that all hell might break
> loose with it.

Oh, apology. I didn't intend to assist as is merge. Basically I agree with
minchan. Is should be replaced get_user_pages(). I only intended to clarify
pros/cons and where is original author's intention. If I understand correctly,
MADV_DONT_FORK is best solution for this case.




> If you know it's only the ddx that will use it and that their wont be
> fork that better to not worry about but again state it in the comment
> about the ioctl.
>
> I really wish there was some magical VM_DRIVER_MAPPED flags that would
> add the proper restriction to other memory code while keeping fork
> behavior consistant (ie cow). But such things would need massive
> chirurgy of the linux mm code.
>
> Cheers,
> Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
