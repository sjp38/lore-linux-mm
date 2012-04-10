Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 7CDF56B004A
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 13:25:25 -0400 (EDT)
Received: by lbao2 with SMTP id o2so45715lba.14
        for <linux-mm@kvack.org>; Tue, 10 Apr 2012 10:25:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120410092944.GC3789@suse.de>
References: <1332950783-31662-1-git-send-email-mgorman@suse.de>
	<1332950783-31662-2-git-send-email-mgorman@suse.de>
	<CALWz4iymXkJ-88u9Aegc2DjwO2vZp3xVuw_5qTRW2KgPP8ti=g@mail.gmail.com>
	<20120410082454.GA3789@suse.de>
	<20120410092944.GC3789@suse.de>
Date: Tue, 10 Apr 2012 10:25:23 -0700
Message-ID: <CALWz4iw7aTi9mVos98SuLe_vibmhrY19oQvMN36aBwp0exH7DQ@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm: vmscan: Remove lumpy reclaim
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Hugh Dickins <hughd@google.com>

On Tue, Apr 10, 2012 at 2:29 AM, Mel Gorman <mgorman@suse.de> wrote:
> On Tue, Apr 10, 2012 at 09:24:54AM +0100, Mel Gorman wrote:
>> On Fri, Apr 06, 2012 at 04:52:09PM -0700, Ying Han wrote:
>> > On Wed, Mar 28, 2012 at 9:06 AM, Mel Gorman <mgorman@suse.de> wrote:
>> > > Lumpy reclaim had a purpose but in the mind of some, it was to kick
>> > > the system so hard it trashed. For others the purpose was to complic=
ate
>> > > vmscan.c. Over time it was giving softer shoes and a nicer attitude =
but
>> > > memory compaction needs to step up and replace it so this patch send=
s
>> > > lumpy reclaim to the farm.
>> > >
>> > > Here are the important notes related to the patch.
>> > >
>> > > 1. The tracepoint format changes for isolating LRU pages.
>> > >
>> > > 2. This patch stops reclaim/compaction entering sync reclaim as this
>> > > =A0 was only intended for lumpy reclaim and an oversight. Page migra=
tion
>> > > =A0 has its own logic for stalling on writeback pages if necessary a=
nd
>> > > =A0 memory compaction is already using it. This is a behaviour chang=
e.
>> > >
>> > > 3. RECLAIM_MODE_SYNC no longer exists. pageout() does not stall
>> > > =A0 on PageWriteback with CONFIG_COMPACTION has been this way for a =
while.
>> > > =A0 I am calling it out in case this is a surpise to people.
>> >
>> > Mel,
>> >
>> > Can you point me the commit making that change? I am looking at
>> > v3.4-rc1 where set_reclaim_mode() still set RECLAIM_MODE_SYNC for
>> > COMPACTION_BUILD.
>> >
>>
>> You're right.
>>
>> There is only one call site that passes sync=3D=3Dtrue for set_reclaim_m=
ode() in
>> vmscan.c and that is only if should_reclaim_stall() returns true. It had=
 the
>> comment "Only stall on lumpy reclaim" but the comment is not accurate
>> and that mislead me.
>>
>> Thanks, I'll revisit the patch.
>>
>
> Just to be clear, I think the patch is right in that stalling on page
> writeback was intended just for lumpy reclaim.

I see mismatch between the comment "Only stall on lumpy reclaim" and
the actual implementation in should_reclaim_stall(). Not sure what is
intended, but based on the code, both lumpy and compaction reclaim
will be stalled under PageWriteback.

I've split out the patch
> that stops reclaim/compaction entering sync reclaim but the end result
> of the series is the same.

I think that make senses to me for compaction due to its migrating page nat=
ure.

Unfortunately we do not have tracing to record
> how often reclaim waited on writeback during compaction so my historical
> data does not indicate how often it happened. However, it may partially
> explain occasionaly complaints about interactivity during heavy writeback
> when THP is enabled (the bulk of the stalls were due to something else bu=
t
> on rare occasions disabling THP was reported to make a small unquantifabl=
e
> difference). I'll enable ftrace to record how often mm_vmscan_writepage()
> used RECLAIM_MODE_SYNC during tests for this series and include that
> information in the changelog.

Thanks for looking into it.

--Ying

> --
> Mel Gorman
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
