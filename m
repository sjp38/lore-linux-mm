Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id C0E8B6B0109
	for <linux-mm@kvack.org>; Tue,  8 May 2012 04:32:36 -0400 (EDT)
Message-ID: <4FA8DA23.3030609@kernel.org>
Date: Tue, 08 May 2012 17:32:35 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] vmevent: Implement special low-memory attribute
References: <20120501132409.GA22894@lizard> <20120501132620.GC24226@lizard> <4FA35A85.4070804@kernel.org> <20120504073810.GA25175@lizard> <CAOJsxLH_7mMMe+2DvUxBW1i5nbUfkbfRE3iEhLQV9F_MM7=eiw@mail.gmail.com> <CAHGf_=qcGfuG1g15SdE0SDxiuhCyVN025pQB+sQNuNba4Q4jcA@mail.gmail.com> <20120507121527.GA19526@lizard> <4FA82056.2070706@gmail.com> <CAOJsxLHQcDZSHJZg+zbptqmT9YY0VTkPd+gG_zgMzs+HaV_cyA@mail.gmail.com> <CAHGf_=q1nbu=3cnfJ4qXwmngMPB-539kg-DFN2FJGig8+dRaNw@mail.gmail.com> <CAOJsxLFAavdDbiLnYRwe+QiuEHSD62+Sz6LJTk+c3J9gnLVQ_w@mail.gmail.com> <CAHGf_=pSLfAue6AR5gi5RQ7xvgTxpZckA=Ja1fO1AkoO1o_DeA@mail.gmail.com>
In-Reply-To: <CAHGf_=pSLfAue6AR5gi5RQ7xvgTxpZckA=Ja1fO1AkoO1o_DeA@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Pekka Enberg <penberg@kernel.org>, Anton Vorontsov <anton.vorontsov@linaro.org>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

On 05/08/2012 04:11 PM, KOSAKI Motohiro wrote:

> On Tue, May 8, 2012 at 1:53 AM, Pekka Enberg <penberg@kernel.org> wrote:
>> On Tue, May 8, 2012 at 8:42 AM, KOSAKI Motohiro
>> <kosaki.motohiro@gmail.com> wrote:
>>>> That said, I think you are being unfair to Anton who's one of the few
>>>> that's actually taking the time to implement this properly instead of
>>>> settling for an out-of-tree hack.
>>>
>>> Unfair? But only I can talk about technical comment. To be honest, I
>>> really dislike
>>> I need say the same explanation again and again. A lot of people don't read
>>> past discussion. And as far as the patches take the same mistake, I must say
>>> the same thing. It is just PITA.
>>
>> Unfair because you are trying to make it look as if Anton is only
>> concerned with his specific use case. That's simply not true.
> 
> However current proposal certainly don't refer past discuss and don't work
> many environment.
> 
> 
>> On Tue, May 8, 2012 at 8:42 AM, KOSAKI Motohiro
>> <kosaki.motohiro@gmail.com> wrote:
>>> I don't disagree vmevent notification itself, but I must disagree lie
>>> notification.
>>> And also, To make just idea statistics doesn't make sense at all. How do an
>>> application choose the right events? If that depend on hardware configuration,
>>> userland developers can't write proper applications.
>>
>> That's exactly the problem we're trying to tackle here! We _want_ the
>> ABI to provide sane, well-defined events that solve real world
>> problems.
> 
> Ok, sane. Then I take my time a little and review current vmevent code briefly.
> (I read vmevent/core branch in pekka's tree. please let me know if
> there is newer
> repositry)
> 
> I think following thing should be fixed.
> 
> 1) sample_period is brain damaged idea. If people ONLY need to
> sampling stastics, they
>   only need to read /proc/vmstat periodically. just remove it and
> implement push notification.
>   _IF_ someone need unfrequent level trigger, just use
> "usleep(timeout); read(vmevent_fd)"
>  on userland code.
> 2) VMEVENT_ATTR_STATE_ONE_SHOT is misleading name. That is effect as
> edge trigger
>   shot. not only once.
> 3) vmevent_fd() seems sane interface. but it has name space unaware.
> maybe we discuss how
>   to harmonize name space feature.  No hurry. but we have to think
> that issue since at beginning.
> 4) Currently, vmstat have per-cpu batch and vmstat updating makes 3
> second delay at maximum.
>   This is fine for usual case because almost userland watcher only
> read /proc/vmstat per second.
>   But, for vmevent_fd() case, 3 seconds may be unacceptable delay. At
> worst, 128 batch x 4096
>   x 4k pagesize = 2G bytes inaccurate is there.
> 5) __VMEVENT_ATTR_STATE_VALUE_WAS_LT should be removed from userland
> exporting files.
>   When exporing kenrel internal, always silly gus used them and made unhappy.
> 6) Also vmevent_event must hide from userland.
> 7) vmevent_config::size must be removed. In 20th century, M$ API
> prefer to use this technique. But
>   They dropped the way because a lot of application don't initialize
> size member and they can't use
>    it for keeping upper compitibility.
> 8) memcg unaware
> 9) numa unaware
> 10) zone unaware


I would like to add a concern.

11) understand storage speed.

As I mentioned, system can have various storage type(SSD, disk, eMMC, ramfs)
In some system, user can tolerate ramfs and SSD write or swapout.
We should consdier that to make it really useful.

The problem is user can't know it in advance so it should be detected by kernel.
Unfortunately, it's not easy now.

The idea is that we can make some levels in advane and explain it to user

Level 1: It a immediate response to user when kernel decide there are not fast-reclaimable pages any more.
Level 2: It's rather slower response than level 1 but kernel will consider it as reclaimable target
Level 3: It's slowest response because kernel will consider page needed long time to reclaim as reclaimable target.

It doesn't expose any internal of kernel and can implment it in internal.
For simple example,

Level 1: non-mapped clean page
Level 2: Level 1 + mapped clean-page
Level 3: Level 2 + dirty pages
 
So users of vmevent_fd can select his level.
Of course, latency sensitive application with slow stoarge would select Level 1.
Some application might use Level 4(Level 3 + half of swap) because it has very fast storage.

And application receives event can make strategy folloing as.

When it receives level 1 notification, it could request to others if it can release their own buffers.
When it receives level 2 notification, it could request to suicide if it's not critical application.
When it receives level 3 notification, it could kill others. 

It's a just example and my point is we should storage speed to make it general.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
