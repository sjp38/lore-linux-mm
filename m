Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 9E1896B004D
	for <linux-mm@kvack.org>; Mon, 16 Jul 2012 04:31:26 -0400 (EDT)
Received: by ghrr18 with SMTP id r18so5681198ghr.14
        for <linux-mm@kvack.org>; Mon, 16 Jul 2012 01:31:25 -0700 (PDT)
Date: Mon, 16 Jul 2012 01:30:48 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v2 -mm] memcg: prevent from OOM with too many dirty
 pages
In-Reply-To: <20120713082150.GA1448@tiehlicka.suse.cz>
Message-ID: <alpine.LSU.2.00.1207160111280.3936@eggly.anvils>
References: <1340117404-30348-1-git-send-email-mhocko@suse.cz> <20120619150014.1ebc108c.akpm@linux-foundation.org> <20120620101119.GC5541@tiehlicka.suse.cz> <alpine.LSU.2.00.1207111818380.1299@eggly.anvils> <20120712070501.GB21013@tiehlicka.suse.cz>
 <20120712141343.e1cb7776.akpm@linux-foundation.org> <alpine.LSU.2.00.1207121539150.27721@eggly.anvils> <20120713082150.GA1448@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Fengguang Wu <fengguang.wu@intel.com>

On Fri, 13 Jul 2012, Michal Hocko wrote:
> On Thu 12-07-12 15:42:53, Hugh Dickins wrote:
> > On Thu, 12 Jul 2012, Andrew Morton wrote:
> > > 
> > > I wasn't planning on 3.5, given the way it's been churning around.
> > 
> > I don't know if you had been intending to send it in for 3.5 earlier;
> > but I'm sorry if my late intervention on may_enter_fs has delayed it.
> 
> Well I should investigate more when the question came up...
>  
> > > How about we put it into 3.6 and tag it for a -stable backport, so
> > > it gets a bit of a run in mainline before we inflict it upon -stable
> > > users?
> > 
> > That sounds good enough to me, but does fall short of Michal's hope.
> 
> I would be happier if it went into 3.5 already because the problem (OOM
> on too many dirty pages) is real and long term (basically since ever).
> We have the patch in SLES11-SP2 for quite some time (the original one
> with the may_enter_fs check) and it helped a lot.
> The patch was designed as a band aid primarily because it is very simple
> that way and with a hope that the real fix will come later.
> The decision is up to you Andrew, but I vote for pushing it as soon as
> possible and try to come up with something more clever for 3.6.

Once I got to trying dd in memcg to FS on USB stick, yes, I very much
agree that the problem is real and well worth fixing, and that your
patch takes us most of the way there.

But Andrew's caution has proved to be well founded: in the last
few days I've found several problems with it.

I guess it makes more sense to go into detail in the patch I'm about
to send, fixing up what is (I think) currently in mmotm.

But in brief: my insistence on may_enter_fs actually took us backwards
on ext4, because that does __GFP_NOFS page allocations when writing.
I still don't understand how this showed up in none of my testing at
the end of the week, and only hit me today (er, yesterday).  But not
as big a problem as I thought at first, because loop also turns off
__GFP_IO, so we can go by that instead.

And though I found your patch works most of the time, one in five
or ten attempts would OOM just as before: we actually have a problem
also with PageWriteback pages which are not PageReclaim, but the
answer is to mark those PageReclaim.

Patch follows separately in a moment.  I'm pretty happy with it now,
but I've not yet tried xfs, btrfs, vfat, tmpfs.  I notice now that
you specifically describe testing on ext3, but don't mention ext4:
I wonder if you got bogged down in the problems I've fixed on that.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
