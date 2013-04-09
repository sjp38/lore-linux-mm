Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 707C56B0005
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 03:42:59 -0400 (EDT)
Message-ID: <5163C6A5.5050307@parallels.com>
Date: Tue, 9 Apr 2013 11:43:33 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 02/28] vmscan: take at least one pass with shrinkers
References: <1364548450-28254-1-git-send-email-glommer@parallels.com> <1364548450-28254-3-git-send-email-glommer@parallels.com> <20130408084202.GA21654@lge.com> <51628412.6050803@parallels.com> <20130408090131.GB21654@lge.com> <51628877.5000701@parallels.com> <20130409005547.GC21654@lge.com> <20130409012931.GE17758@dastard> <20130409020505.GA4218@lge.com>
In-Reply-To: <20130409020505.GA4218@lge.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, containers@lists.linux-foundation.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, hughd@google.com, yinghan@google.com, Theodore Ts'o <tytso@mit.edu>, Al Viro <viro@zeniv.linux.org.uk>

On 04/09/2013 06:05 AM, Joonsoo Kim wrote:
> I don't think so.
> Yes, lowmem_shrink() return number of (in)active lru pages
> when nr_to_scan is 0. And in shrink_slab(), we divide it by lru_pages.
> lru_pages can vary where shrink_slab() is called, anyway, perhaps this
> logic makes total_scan below 128.
> 
You may benefit from looking at the lowmemory patches in this patchset
itself. We modified the shrinker API to separate the count and scan
phases. With this, the whole nr_to_scan == 0 disappears and the code
gets easier to follow.

>> > 
>> > And, interestingly enough, when the file cache has been pruned down
>> > to it's smallest possible size, that's when the shrinker *won't run*
>> > because the that's when the total_scan will be smaller than the
>> > batch size and hence shrinker won't get called.
>> > 
>> > The shrinker is hacky, abuses the shrinker API, and doesn't appear
>> > to do what it is intended to do.  You need to fix the shrinker, not
>> > use it's brokenness as an excuse to hold up a long overdue shrinker
>> > rework.
> Agreed. I also think shrinker rework is valuable and I don't want
> to become a stopper for this change. But, IMHO, at least, we should
> notify users of shrinker API to know how shrinker API behavior changed,

Except that the behavior didn't change.

> because this is unexpected behavior change when they used this API.
> When they used this API, they can assume that it is possible to control
> logic with seeks and return value(when nr_to_scan=0), but with this patch,
> this assumption is broken.
> 

Jonsoo, you are still missing the point. nr_to_scan=0 has nothing to do
with this, or with this patch. nr_to_scan will reach 0 ANYWAY if you
shrink all objects you have to shrink, which is a *very* common thing to
happen.

The only case changed here is where this happen when attempting to
shrink a small number of objects that is smaller than the batch size.

Also, again, the nr_to_scan=0 checks in the shrinker calls have nothing
to do with that. They reflect the situation *BEFORE* the shrinker was
called. So how many objects we shrunk afterwards have zero to do with
it. This is just the shrinker API using the magic value of 0 to mean :
"don't shrink, just tell me how much do you have", vs a positive number
meaning "try to shrink as much as nr_to_scan objects".



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
