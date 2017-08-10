Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id CE2CB6B02B4
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 15:17:13 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id z195so4001906wmz.8
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 12:17:13 -0700 (PDT)
Received: from mail-wm0-x22c.google.com (mail-wm0-x22c.google.com. [2a00:1450:400c:c09::22c])
        by mx.google.com with ESMTPS id p6si6527476edd.172.2017.08.10.12.17.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Aug 2017 12:17:11 -0700 (PDT)
Received: by mail-wm0-x22c.google.com with SMTP id i66so30577825wmg.0
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 12:17:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAPz6YkUNu1uH057ENuH+Umq5J=J24my0p91mvYMtEb4Vy6Dhqg@mail.gmail.com>
References: <20170808132554.141143-1-dancol@google.com> <20170810001557.147285-1-dancol@google.com>
 <20170810043831.GB2249@bbox> <20170810084617.GI23863@dhcp22.suse.cz>
 <r0251soju3fo.fsf@dancol.org> <20170810105852.GM23863@dhcp22.suse.cz> <CAPz6YkUNu1uH057ENuH+Umq5J=J24my0p91mvYMtEb4Vy6Dhqg@mail.gmail.com>
From: Tim Murray <timmurray@google.com>
Date: Thu, 10 Aug 2017 12:17:07 -0700
Message-ID: <CAEe=SxkgPUEkHdQm+M49EBc_Y_bEnNbe5fed3yALUx2eUbMrGQ@mail.gmail.com>
Subject: Re: [PATCH RFC v2] Add /proc/pid/smaps_rollup
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sonny Rao <sonnyrao@chromium.org>
Cc: Michal Hocko <mhocko@kernel.org>, Daniel Colascione <dancol@google.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Joel Fernandes <joelaf@google.com>, Al Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, Robert Foss <robert.foss@collabora.com>, linux-api@vger.kernel.org, Luigi Semenzato <semenzato@google.com>

I've looked into this a fair bit on the Android side, so I can provide
some context. There are two main reasons why Android gathers PSS
information:

1. Android devices can show the user the amount of memory used per
application via the settings app. This is a less important use case.
2. We log PSS to help identify leaks in applications. We have found an
enormous number of bugs (in the Android platform, in Google's own
apps, and in third-party applications) using this data.

To do this, system_server (the main process in Android userspace) will
sample the PSS of a process three seconds after it changes state (for
example, app is launched and becomes the foreground application) and
about every ten minutes after that. The net result is that PSS
collection is regularly running on at least one process in the system
(usually a few times a minute while the screen is on, less when screen
is off due to suspend). PSS of a process is an incredibly useful stat
to track, and we aren't going to get rid of it. We've looked at some
very hacky approaches using RSS ("take the RSS of the target process,
subtract the RSS of the zygote process that is the parent of all
Android apps") to reduce the accounting time, but it regularly
overestimated the memory used by 20+ percent. Accordingly, I don't
think that there's a good alternative to using PSS.

We started looking into PSS collection performance after we noticed
random frequency spikes while a phone's screen was off; occasionally,
one of the CPU clusters would ramp to a high frequency because there
was 200-300ms of constant CPU work from a single thread in the main
Android userspace process. The work causing the spike (which is
reasonable governor behavior given the amount of CPU time needed) was
always PSS collection. As a result, Android is burning more power than
we should be on PSS collection.

The other issue (and why I'm less sure about improving smaps as a
long-term solution) is that the number of VMAs per process has
increased significantly from release to release. After trying to
figure out why we were seeing these 200-300ms PSS collection times on
Android O but had not noticed it in previous versions, we found that
the number of VMAs in the main system process increased by 50% from
Android N to Android O (from ~1800 to ~2700) and varying increases in
every userspace process. Android M to N also had an increase in the
number of VMAs, although not as much. I'm not sure why this is
increasing so much over time, but thinking about ASLR and ways to make
ASLR better, I expect that this will continue to increase going
forward. I would not be surprised if we hit 5000 VMAs on the main
Android process (system_server) by 2020.

If we assume that the number of VMAs is going to increase over time,
then doing anything we can do to reduce the overhead of each VMA
during PSS collection seems like the right way to go, and that means
outputting an aggregate statistic (to avoid whatever overhead there is
per line in writing smaps and in reading each line from userspace).

Also, Dan sent me some numbers from his benchmark measuring PSS on
system_server (the big Android process) using smaps vs smaps_rollup:

using smaps:
iterations:1000 pid:1163 pss:220023808
 0m29.46s real 0m08.28s user 0m20.98s system

using smaps_rollup:
iterations:1000 pid:1163 pss:220702720
 0m04.39s real 0m00.03s user 0m04.31s system

On Thu, Aug 10, 2017 at 11:56 AM, Sonny Rao <sonnyrao@chromium.org> wrote:
> On Thu, Aug 10, 2017 at 3:58 AM, Michal Hocko <mhocko@kernel.org> wrote:
>> On Thu 10-08-17 03:23:23, Daniel Colascione wrote:
>>> Thanks for taking a look at the patch!
>>>
>>> On Thu, Aug 10 2017, Michal Hocko wrote:
>>> > [CC linux-api - the patch was posted here
>>> > http://lkml.kernel.org/r/20170810001557.147285-1-dancol@google.com]
>>> >
>>> > On Thu 10-08-17 13:38:31, Minchan Kim wrote:
>>> >> On Wed, Aug 09, 2017 at 05:15:57PM -0700, Daniel Colascione wrote:
>>> >> > /proc/pid/smaps_rollup is a new proc file that improves the
>>> >> > performance of user programs that determine aggregate memory
>>> >> > statistics (e.g., total PSS) of a process.
>>> >> >
>>> >> > Android regularly "samples" the memory usage of various processes in
>>> >> > order to balance its memory pool sizes. This sampling process involves
>>> >> > opening /proc/pid/smaps and summing certain fields. For very large
>>> >> > processes, sampling memory use this way can take several hundred
>>> >> > milliseconds, due mostly to the overhead of the seq_printf calls in
>>> >> > task_mmu.c.
>>> >
>>> > Have you tried to reduce that overhead? E.g. by replacing seq_printf by
>>> > something more simple
>>> > http://lkml.kernel.org/r/20160817130320.GC20703@dhcp22.suse.cz?
>>>
>>> I haven't tried that yet, but if I'm reading that thread correctly, it
>>> looks like using more efficient printing primitives gives us a 7%
>>> speedup. The smaps_rollup patch gives us a much bigger speedup while
>>> reusing almost all the smaps code, so it seems easier and simpler than a
>>> bunch of incremental improvements to smaps. And even an efficient smaps
>>> would have to push 2MB through seq_file for the 3000-VMA process case.
>>
>> The thing is that more users would benefit from a more efficient
>> /proc/pid/smaps call. Maybe we can use some caching tricks etc...  We
>> should make sure that existing options should be attempted before a new
>> user visible interface is added. It is kind of sad that the real work
>> (pte walk) is less expensive than formating the output and copying it to
>> the userspace...
>>
>>> > How often you you need to read this information?
>>>
>>> It varies depending on how often processes change state.  We sample a
>>> short time (tens of seconds) after processes change state (e.g., enters
>>> foreground) and every few minutes thereafter. We're particularly
>>> concerned from an energy perspective about needlessly burning CPU on
>>> background samples.
>>
>> Please make sure this is documented in the patch along with some numbers
>> ideally.
>>
>> [...]
>>
>>> >> FYI, there was trial but got failed at that time so in this time,
>>> >> https://marc.info/?l=linux-kernel&m=147310650003277&w=2
>>> >> http://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1229163.html
>>> >
>>> > Yes I really disliked the previous attempt and this one is not all that
>>> > better. The primary unanswered question back then was a relevant
>>> > usecase. Back then it was argued [1] that PSS was useful for userspace
>>> > OOM handling but arguments were rather dubious. Follow up questions [2]
>>> > shown that the useage of PSS was very workload specific. Minchan has
>>> > noted some usecase as well but not very specific either.
>>>
>>> Anyway, I see what you mean about PSS being iffy for user-space OOM
>>> processing (because PSS doesn't tell you how much memory you get back in
>>> exchange for killing a given process at a particular moment). We're not
>>> using it like that.
>>>
>>> Instead, we're using the PSS samples we collect asynchronously for
>>> system-management tasks like fine-tuning oom_adj_score, memory use
>>> tracking for debugging, application-level memory-use attribution, and
>>> deciding whether we want to kill large processes during system idle
>>> maintenance windows. Android has been using PSS for these purposes for a
>>> long time; as the average process VMA count has increased and and
>>> devices become more efficiency-conscious, PSS-collection inefficiency
>>> has started to matter more. IMHO, it'd be a lot safer to optimize the
>>> existing PSS-collection model, which has been fine-tuned over the years,
>>> instead of changing the memory tracking approach entirely to work around
>>> smaps-generation inefficiency.
>>
>> This is really vague. Please be more specific.
>
> I actually think this is really similar to the Chrome OS use case --
> we need to do proper accounting of memory from user space, and we need
> something more accurate than what we have now (usually RSS) to figure
> it out.  I'm not sure what is vague about that statement?
>
> PSS is not perfect but in closed systems where we have some knowledge
> about what is being shared amongst process, PSS is much better than
> RSS and readily available.  So, I disagree that this is a dubious
> usage -- if there's a better metric for making this kind of decision,
> please share it.
>
> Also I realized there's another argument for presenting this
> information outside of smaps which is that we expose far less
> information about a process and it's address space via something like
> this, so it's much better for isolation to have a separate file with
> different permissions.  Right now the process in charge of accounting
> for memory usage also gains knowledge about each process's address
> space which is unnecessary.
>
> IMHO, the fact that multiple folks have independently asked for this
> seems like an argument that something like this is needed.
>
>
>> --
>> Michal Hocko
>> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
