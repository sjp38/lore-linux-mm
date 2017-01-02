Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 774C06B0069
	for <linux-mm@kvack.org>; Mon,  2 Jan 2017 02:39:32 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id n3so50822167wjy.6
        for <linux-mm@kvack.org>; Sun, 01 Jan 2017 23:39:32 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id vf6si44990061wjc.38.2017.01.01.23.39.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 01 Jan 2017 23:39:30 -0800 (PST)
Subject: Re: [PATCH] mm: Drop "PFNs busy" printk in an expected path.
References: <20161229023131.506-1-eric@anholt.net>
 <20161229091256.GF29208@dhcp22.suse.cz> <87wpeitzld.fsf@eliezer.anholt.net>
 <xa1td1ga74v7.fsf@mina86.com> <20161230105200.GE13301@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <08f3d2e7-4410-8cb2-351f-99a6d28836cc@suse.cz>
Date: Mon, 2 Jan 2017 08:39:23 +0100
MIME-Version: 1.0
In-Reply-To: <20161230105200.GE13301@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Michal Nazarewicz <mina86@mina86.com>
Cc: Eric Anholt <eric@anholt.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-stable <stable@vger.kernel.org>, "Robin H. Johnson" <robbat2@orbis-terrarum.net>, Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 12/30/2016 11:52 AM, Michal Hocko wrote:
> On Thu 29-12-16 23:22:20, Michal Nazarewicz wrote:
>> On Thu, Dec 29 2016, Eric Anholt wrote:
>>> Michal Hocko <mhocko@kernel.org> writes:
>>>
>>>> This has been already brought up
>>>> http://lkml.kernel.org/r/20161130092239.GD18437@dhcp22.suse.cz and there
>>>> was a proposed patch for that which ratelimited the output
>>>> http://lkml.kernel.org/r/20161130132848.GG18432@dhcp22.suse.cz resp.
>>>> http://lkml.kernel.org/r/robbat2-20161130T195244-998539995Z@orbis-terrarum.net
>>>>
>>>> then the email thread just died out because the issue turned out to be a
>>>> configuration issue. Michal indicated that the message might be useful
>>>> so dropping it completely seems like a bad idea. I do agree that
>>>> something has to be done about that though. Can we reconsider the
>>>> ratelimit thing?

Agree about ratelimiting.

>>> I agree that the rate of the message has gone up during 4.9 -- it used
>>> to be a few per second.
>>
>> Sounds like a regression which should be fixed.
>>
>> This is why I dona??t think removing the message is a good idea.  If you
>> suddenly see a lot of those messages, something changed for the worse.
>> If you remove this message, you will never know.
> 
> I agree, that removing the message completely is not going to help to
> find out regressions. Swamping logs with zillions of messages is,
> however, not acceptable. It just causes even more problems. See the
> previous report.
> 
>>> However, if this is an expected path during normal operation,
>>
>> This depends on your definition of a??expecteda?? and a??normala??.
>>
>> In general, I would argue that the fact those ever happen is a bug
>> somewhere in the kernel a?? if memory is allocated as movable, it should
>> be movable damn it!
> 
> Yes, it should be movable but there is no guarantee it is movable
> immediately. Those pages might be pinned for some time. This is
> unavoidable AFAICS.

There was a VM_PINNED patchset some years ago from PeterZ where
long-term pins would use wrappers over get_page() that would e.g.
migrate the page from CMA blocks or movable zones. That's possible
solution, but it would always be a bit of a whack-a-mole with code that
would do longer than expected pins, but not use the VM_PINNED API.

> So while this might be a regression which should be investigated there
> should be another fix to prevent from swamping the logs as well.

Yeah, the logs indicated rather static pfn's being logged, so either
really long-term pins or maybe outright wrong migratetype used by the
allocation, possibly as regression. page_owner functionality would make
it possible to confirm the wrong migratetype and dump the allocating
stacktrace. Perhaps we can enhance the printk's here to do exactly that
automatically if page_owner is enabled, which would make it easier for
bug reporters.

If it's pinning, then it's trickier. Joonsoo added relevant tracepoints
recently, but it's easy to flood the system with tracing output,
especially when one would want backtraces of the pins.

It should be also possible to check for such problematic pages
periodically (outside of CMA attempts) via some script that would
combine kpagecount and page_owner output.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
