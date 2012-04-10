Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 79B126B004A
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 04:24:59 -0400 (EDT)
Date: Tue, 10 Apr 2012 09:24:54 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 1/2] mm: vmscan: Remove lumpy reclaim
Message-ID: <20120410082454.GA3789@suse.de>
References: <1332950783-31662-1-git-send-email-mgorman@suse.de>
 <1332950783-31662-2-git-send-email-mgorman@suse.de>
 <CALWz4iymXkJ-88u9Aegc2DjwO2vZp3xVuw_5qTRW2KgPP8ti=g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CALWz4iymXkJ-88u9Aegc2DjwO2vZp3xVuw_5qTRW2KgPP8ti=g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Hugh Dickins <hughd@google.com>

On Fri, Apr 06, 2012 at 04:52:09PM -0700, Ying Han wrote:
> On Wed, Mar 28, 2012 at 9:06 AM, Mel Gorman <mgorman@suse.de> wrote:
> > Lumpy reclaim had a purpose but in the mind of some, it was to kick
> > the system so hard it trashed. For others the purpose was to complicate
> > vmscan.c. Over time it was giving softer shoes and a nicer attitude but
> > memory compaction needs to step up and replace it so this patch sends
> > lumpy reclaim to the farm.
> >
> > Here are the important notes related to the patch.
> >
> > 1. The tracepoint format changes for isolating LRU pages.
> >
> > 2. This patch stops reclaim/compaction entering sync reclaim as this
> >   was only intended for lumpy reclaim and an oversight. Page migration
> >   has its own logic for stalling on writeback pages if necessary and
> >   memory compaction is already using it. This is a behaviour change.
> >
> > 3. RECLAIM_MODE_SYNC no longer exists. pageout() does not stall
> >   on PageWriteback with CONFIG_COMPACTION has been this way for a while.
> >   I am calling it out in case this is a surpise to people.
> 
> Mel,
> 
> Can you point me the commit making that change? I am looking at
> v3.4-rc1 where set_reclaim_mode() still set RECLAIM_MODE_SYNC for
> COMPACTION_BUILD.
> 

You're right.

There is only one call site that passes sync==true for set_reclaim_mode() in
vmscan.c and that is only if should_reclaim_stall() returns true. It had the
comment "Only stall on lumpy reclaim" but the comment is not accurate
and that mislead me.

Thanks, I'll revisit the patch.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
