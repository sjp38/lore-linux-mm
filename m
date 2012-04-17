Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 7C6DC6B004A
	for <linux-mm@kvack.org>; Tue, 17 Apr 2012 15:26:24 -0400 (EDT)
Message-ID: <4F8DC3DC.7040408@redhat.com>
Date: Tue, 17 Apr 2012 15:26:20 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: Followup: [PATCH -mm] make swapin readahead skip over holes
References: <7297ae3b-f3e1-480b-838f-69b0e09a733d@default> <4F8C7D59.1000402@redhat.com> <f81dcf86-fb34-4e39-923b-3fd1862e60c6@default>
In-Reply-To: <f81dcf86-fb34-4e39-923b-3fd1862e60c6@default>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On 04/17/2012 11:20 AM, Dan Magenheimer wrote:

> In other words, you are both presuming a "swap workload"
> that is more sequential than random for which this patch
> improves performance, and assuming a "swap device"
> for which the cost of a seek is high enough to overcome
> the costs of filling the swap cache with pages that won't
> be used.

Indeed, on spinning media the cost of seeking to
a cluster and reading one page is essentially the
same as the cost of seeking to a cluster and
reading the whole thing.


> While it is easy to write a simple test/benchmark that
> swaps a lot (and we probably all have similar test code
> that writes data into a huge bigger-than-RAM array and then
> reads it back), such a test/benchmark is usually sequential,
> so one would assume most swap testing is done with a
> sequential-favoring workload.

Lots of programs allocate fairly large memory
objects, and access them again in the same
large chunks.

Take a look at a desktop application like a
web browser, for example.

> The kernbench workload
> apparently exercises swap quite a bit more randomly and
> your patch makes it run slower for low and high levels
> of swapping, while faster for moderate swapping.

The kernbench workload consists of a large number
of fairly small, short lived processes. I suspect
this is a very non-typical workload to run into
swap, on today's systems.

A more typical workload consists of multiple large
processes, with the working set moving from one
part of memory (now inactive) to somewhere else.

We need to maximize swap IO throughput in order to
allow the system to quickly move to the new working
set.

> I also suspect (without proof) that the patch will
> result in lower performance on non-rotating devices, such
> as SSDs.
>
> (Sure one can change the swap cluster size to 1, but how
> many users or even sysadmins know such a thing even
> exists... so the default is important.)

If the default should be changed for some systems,
that is worth doing.

How does your test run with smaller swap cluster
sizes?

Would a swap cluster of 4 or 5 be closer to optimal
for a 1GB system?

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
