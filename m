Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 880546B004D
	for <linux-mm@kvack.org>; Thu, 10 May 2012 22:51:40 -0400 (EDT)
Received: by qcsd16 with SMTP id d16so2214715qcs.14
        for <linux-mm@kvack.org>; Thu, 10 May 2012 19:51:39 -0700 (PDT)
Message-ID: <4FAC7EBA.1080708@gmail.com>
Date: Thu, 10 May 2012 22:51:38 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2 v3] drm/exynos: added userptr feature.
References: <1335188594-17454-4-git-send-email-inki.dae@samsung.com> <1336544259-17222-1-git-send-email-inki.dae@samsung.com> <1336544259-17222-3-git-send-email-inki.dae@samsung.com> <CAH3drwZBb=XBYpx=Fv=Xv0hajic51V9RwzY_-CpjKDuxgAj9Qg@mail.gmail.com> <001501cd2e4d$c7dbc240$579346c0$%dae@samsung.com> <4FAB4AD8.2010200@kernel.org> <002401cd2e7a$1e8b0ed0$5ba12c70$%dae@samsung.com> <4FAB68CF.8000404@kernel.org> <CAAQKjZM0a-Lg8KYwWi+LwAXJPFYLKqWaKbuc4iUGVKyoStXu_w@mail.gmail.com> <4FAB782C.306@kernel.org> <003301cd2e89$13f78c00$3be6a400$%dae@samsung.com> <4FAC0091.7070606@gmail.com> <4FAC623E.7090209@kernel.org>
In-Reply-To: <4FAC623E.7090209@kernel.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Inki Dae <inki.dae@samsung.com>, 'InKi Dae' <daeinki@gmail.com>, 'Jerome Glisse' <j.glisse@gmail.com>, airlied@linux.ie, dri-devel@lists.freedesktop.org, kyungmin.park@samsung.com, sw0312.kim@samsung.com, linux-mm@kvack.org

(5/10/12 8:50 PM), Minchan Kim wrote:
> Hi KOSAKI,
>
> On 05/11/2012 02:53 AM, KOSAKI Motohiro wrote:
>
>>>>> let's assume that one application want to allocate user space memory
>>>>> region using malloc() and then write something on the region. as you
>>>>> may know, user space buffer doen't have real physical pages once
>>>>> malloc() call so if user tries to access the region then page fault
>>>>> handler would be triggered
>>>>
>>>>
>>>> Understood.
>>>>
>>>>> and then in turn next process like swap in to fill physical frame
>>>>> number
>>>> into entry of the page faulted.
>>>>
>>>>
>>>> Sorry, I can't understand your point due to my poor English.
>>>> Could you rewrite it easiliy? :)
>>>>
>>>
>>> Simply saying, handle_mm_fault would be called to update pte after
>>> finding
>>> vma and checking access right. and as you know, there are many cases to
>>> process page fault such as COW or demand paging.
>>
>> Hmm. If I understand correctly, you guys misunderstand mlock. it doesn't
>> page pinning
>> nor prevent pfn change. It only guarantee to don't make swap out. e.g.
>
>
> Symantic point of view, you're right but the implementation makes sure page pinning.
>
>> memory campaction
>> feature may automatically change page physical address.
>
>
> I tried it last year but decided drop by realtime issue.
> https://lkml.org/lkml/2011/8/29/295
>
> so I think mlock is a kind of page pinning. If elsewhere I don't realized is doing, that place should be fixed.
> Or my above patch should go ahead.

Thanks pointing out. I didn't realized your patch didn't merged. I think it should go ahead. think autonuma case,
if mlock disable autonuma migration, that's bug.  I don't think we can promise mlock don't change physical page.
I wonder if any realtime guys page migration is free lunch. they should disable both auto migration and compaction.

And, think if application explictly use migrate_pages(2) or admins uses cpusets. driver code can't assume such scenario
doesn't occur, yes?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
