Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id AB2A08D0039
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 10:08:16 -0500 (EST)
Message-ID: <4D6FAED0.5010000@tao.ma>
Date: Thu, 03 Mar 2011 23:08:00 +0800
From: Tao Ma <tm@tao.ma>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 4/5] mm: Add hit/miss accounting for Page Cache
References: <no> <1299055090-23976-4-git-send-email-namei.unix@gmail.com> <20110302084542.GA20795@elte.hu> <4D6F077B.3060400@tao.ma> <20110303093422.GC18252@elte.hu>
In-Reply-To: <20110303093422.GC18252@elte.hu>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Liu Yuan <namei.unix@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jaxboe@fusionio.com, akpm@linux-foundation.org, fengguang.wu@intel.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, =?ISO-8859-1?Q?Fr=E9d=E9ric_Weisbecker?= <fweisbec@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Thomas Gleixner <tglx@linutronix.de>, Arnaldo Carvalho de Melo <acme@redhat.com>, Tom Zanussi <tzanussi@gmail.com>

On 03/03/2011 05:34 PM, Ingo Molnar wrote:
> * Tao Ma<tm@tao.ma>  wrote:
>
>> On 03/02/2011 04:45 PM, Ingo Molnar wrote:
>>> * Liu Yuan<namei.unix@gmail.com>   wrote:
>>>
>>>> +		if (likely(!retry_find)&&   page&&   PageUptodate(page))
>>>> +			page_cache_acct_hit(inode->i_sb, READ);
>>>> +		else
>>>> +			page_cache_acct_missed(inode->i_sb, READ);
>>> Sigh.
>>>
>>> This would make such a nice tracepoint or sw perf event. It could be collected in a
>>> 'count' form, equivalent to the stats you are aiming for here, or it could even be
>>> traced, if someone is interested in such details.
>>>
>>> It could be mixed with other events, enriching multiple apps at once.
>>>
>>> But, instead of trying to improve those aspects of our existing instrumentation
>>> frameworks, mm/* is gradually growing its own special instrumentation hacks, missing
>>> the big picture and fragmenting the instrumentation space some more.
>> Thanks for the quick response. Actually our team(including Liu) here are planing
>> to add some debug info to the mm parts for analyzing the application behavior and
>> hope to find some way to improve our application's performance. We have searched
>> the trace points in mm, but it seems to us that the trace points isn't quite
>> welcomed there. Only vmscan and writeback have some limited trace points added.
>> That's the reason we first tried to add some debug info like this patch. You does
>> shed some light on our direction. Thanks.
> Yes, it's very much a 'critical mass' phenomenon: the moment there's enough
> tracepoints, above some magic limit, things happen quickly and everyone finds the
> stuff obviously useful.
>
> Before that limit it's all pretty painful.
yeah.
>> btw, what part do you think is needed to add some trace point?  We
>> volunteer to add more if you like.
> Whatever part you find useful in your daily development work!
>
> Tracepoints are pretty flexible. The bit that is missing and which is very important
> for the MM is the collapse into 'summaries' and the avoidance of tracing overhead
> when only a summary is wanted. Please see Wu Fengguang's reply in this thread about
> the 'dump state' facility he and Steve added to recover large statistics.
We are looking into it now. Thanks for the hint.
> I suspect the hit/miss histogram you are building in this patch could be recovered
> via that facility initially?
>
> The next step would generalize that approach - it is non-trivial but powerful :-)
>
> The idea is to allow non-trivial histograms and summaries to be built out of simple
> events, via the filter engine.
>
> It would require an extension of tracing to really allow a filter expression to be
> defined over existing events, which would allow the maintenance of a persistent
> 'sum' variable - probably within the perf ring-buffer. We already have filter
> support, that would have to be extended with a notion of 'persistent variables'.
>
> So right now, if you define a tracepoint in that spot, we already support such
> filter expressions:
>
>       'bdev == sda1&&  page_state == PageUptodate'
>
> You can inject such filter expressions into /debug/tracing/events/*/*/filter today,
> and you can use filters in perf record --filter '...' as well.
>
> To implement 'fast statistics', the filter engine would have to be extended to
> support (simple) statements like:
>
> 	if (bdev == sda1&&  page_state == PageUptodate)'
> 		var0++;
>
> And:
>
> 	if (bdev == sda1&&  page_state != PageUptodate)'
> 		var1++;
>
> Only a very minimal type of C syntax would be supported - not a full C parser.
>
> That way the 'var0' portion of the perf ring-buffer (which would not be part of the
> regular, overwritten ring-buffer) would act as a 'hits' variable that you could
> recover. The 'var1' portion would be the 'misses' counter.
>
> Individual trace events would only twiddle var0 and var1 - they would not inject a
> full-blown event into the ring-buffer, so statistics would be very fast.
>
> This method is very extensible and could be used for far more things than just MM
> statistics. In theory all of /proc statistics collection could be replaced and made
> optional that way, just by adding the right events to the right spots in the kernel.
> That is obviously a very long-term project.
It looks really fantastic for us. OK, we will try to figure out when and 
how we can work on this issue. Great thanks.

Regards,
Tao

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
