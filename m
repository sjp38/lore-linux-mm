Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 38A516B0B07
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 14:19:15 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id r65-v6so14982178pfa.8
        for <linux-mm@kvack.org>; Fri, 16 Nov 2018 11:19:15 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id be7-v6si30356877plb.267.2018.11.16.11.19.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Nov 2018 11:19:13 -0800 (PST)
Date: Fri, 16 Nov 2018 14:19:10 -0500
From: Sasha Levin <sashal@kernel.org>
Subject: Re: [PATCH AUTOSEL 3.18 8/9] mm/vmstat.c: assert that vmstat_text is
 in sync with stat_items_size
Message-ID: <20181116191910.GJ1706@sasha-vm>
References: <20181113055252.79406-1-sashal@kernel.org>
 <20181113055252.79406-8-sashal@kernel.org>
 <20181115140810.e3292c83467544f6a1d82686@linux-foundation.org>
 <20181115223718.GB1706@sasha-vm>
 <20181115144719.d26dc7a2d47fade8d41a83d5@linux-foundation.org>
 <20181115230118.GC1706@sasha-vm>
 <20181116085525.GC14706@dhcp22.suse.cz>
 <20181116181904.GH1706@sasha-vm>
 <20181116184457.GA11906@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20181116184457.GA11906@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org, linux-kernel@vger.kernel.org, Jann Horn <jannh@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Oleg Nesterov <oleg@redhat.com>, Christoph Lameter <clameter@sgi.com>, Kemi Wang <kemi.wang@intel.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org

On Fri, Nov 16, 2018 at 07:44:57PM +0100, Michal Hocko wrote:
>On Fri 16-11-18 13:19:04, Sasha Levin wrote:
>> On Fri, Nov 16, 2018 at 09:55:25AM +0100, Michal Hocko wrote:
>[...]
>> > > Race condition with memory hotplug due to missing locks:
>> > >
>> > > 	https://marc.info/?l=linux-mm&m=154211934011188&w=2
>> >
>> > Memory hotplug locking is dubious at best and this patch doesn't really
>> > fix it. It fixes a theoretical problem. I am not aware anybody would be
>> > hitting in practice. We need to rework the locking quite extensively.
>>
>> The word "theoretical" used in the stable rules file does not mean
>> that we need to have actual reports of users hitting bugs before we
>> start backporting the relevant patch, it simply suggests that there
>> needs to be a reasonable explanation of how this issue can be hit.
>>
>> For this memory hotplug patch in particular, I use the hv_balloon driver
>> at this very moment (running a linux guest on windows, with "dynamic
>> memory" enabled). Should I wait for it to crash before I can fix it?
>>
>> Is the upstream code perfect? No, but that doesn't mean that it's not
>> working at all, and if there are users they expect to see fixes going in
>> and not just sitting idly waiting for a big rewrite that will come in a
>> few years.
>>
>> Memory hotplug fixes are not something you think should go to stable?
>> Andrew sent a few of them to stable, so that can't be the case.
>
>I am not arguing about hotplug fixes in general. I was arguing that this
>particular one is a theoretical one and hotplug locking is quite subtle.
>E.g. 381eab4a6ee mm/memory_hotplug: fix online/offline_pages called w.o. mem_hotplug_lock
>http://lkml.kernel.org/r/20181114070909.GB2653@MiWiFi-R3L-srv
>So in general unless the issue is really triggered easily I am rather
>conservative.

We have millions of machines running linux, everything is triggered
"easily" at that scale.

>> > > Raising an OOM event that causes issues in userspace when no OOM has
>> > > actually occured:
>> > >
>> > > 	https://marc.info/?l=linux-mm&m=154211939811582&w=2
>> >
>> > The patch makes sense I just do not think this is a stable material. The
>> > semantic of the event was and still is suboptimal.
>>
>> I really fail to understand your reasoning about -stable here. This
>> patch is something people actually hit in the field, spent time on
>> triaging and analysing it, and submitting a fix which looks reasonably
>> straightforward.
>>
>> That fix was acked by quite a few folks (including yourself) and merged
>> in. And as far as we can tell, it actually fixed the problem.
>>
>> Why is it not stable material?
>
>Because the semantic of the OOM event is quite tricky itself. We have
>discussed this patch and concluded that the updated one is more
>sensible. But it is not yet clear whether this is actually what other
>users expect as well. That to me does sound quite risky for a stable
>kernel.

So there's another patch following this one that fixes it? Sure - can I
take both?

Users expect to not have their containers die randomly, if you're saying
that you're still working on a fix for that then that is a different
story than saying "we fixed it, but it should not go to stable".

And let's also draw a line there, users will not wait for the OOM event
logic to be perfect before they can expect their workloads to run
without issues.

>> My understanding is that you're concerned with the patch itself being
>> "suboptimal", but in that case - why did you ack it?
>>
>> > > I think that all 3 cases represent a "real" bug users can hit, and I
>> > > honestly don't know why they were not tagged for stable.
>> >
>> > It would be much better to ask in the respective email thread rather
>> > than spamming mailing with AUTOSEL patches which rarely get any
>> > attention.
>>
>> I actually tried it, but the comments I got is that it gets in the way
>> and people preferred something they can filter.
>
>which means that AUTOSEL just goes to /dev/null...

Or just not get mixed with the process? for some people it's easier to
see AUTOSEL mails with the way it works now rather than if they suddenly
show up as a continuation of a weeks old thread.

>> > We have been through this discussion several times already and I thought
>> > we have agreed that those subsystems which are seriously considering stable
>> > are opted out from the AUTOSEL automagic. Has anything changed in that
>> > regards.
>>
>> I checked in with Andrew to get his input on this, he suggested that
>> these patches should be sent to linux-mm and he'll give it a close look.
>
>If Andrew is happy to get AUTOSEL patches then I will not object of
>course but let's not merge these patches without and expclicit OK.

This is fair. I think that the process has caused some unnecessary
friction: we all want the same result but just disagree on the means :)

I won't merge any mm/ AUTOSEL patches until this gets clearer.

--
Thanks,
Sasha
