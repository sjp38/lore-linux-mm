Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 7991B6B0062
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 23:43:35 -0500 (EST)
Date: Wed, 16 Jan 2013 13:43:33 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 2/2] mm: forcely swapout when we are out of page cache
Message-ID: <20130116044333.GA11461@blaptop>
References: <1357712474-27595-1-git-send-email-minchan@kernel.org>
 <1357712474-27595-3-git-send-email-minchan@kernel.org>
 <20130109162602.53a60e77.akpm@linux-foundation.org>
 <20130110022306.GB14685@blaptop>
 <20130110135828.c88bcaf1.akpm@linux-foundation.org>
 <20130111044327.GB6183@blaptop>
 <20130115160957.9ef860d7.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130115160957.9ef860d7.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Sonny Rao <sonnyrao@google.com>, Bryan Freed <bfreed@google.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>

On Tue, Jan 15, 2013 at 04:09:57PM -0800, Andrew Morton wrote:
> On Fri, 11 Jan 2013 13:43:27 +0900
> Minchan Kim <minchan@kernel.org> wrote:
> 
> > Hi Andrew,
> > 
> > On Thu, Jan 10, 2013 at 01:58:28PM -0800, Andrew Morton wrote:
> > > On Thu, 10 Jan 2013 11:23:06 +0900
> > > Minchan Kim <minchan@kernel.org> wrote:
> > > 
> > > > > I have a feeling that laptop mode has bitrotted and these patches are
> > > > > kinda hacking around as-yet-not-understood failures...
> > > > 
> > > > Absolutely, this patch is last guard for unexpectable behavior.
> > > > As I mentioned in cover-letter, Luigi's problem could be solved either [1/2]
> > > > or [2/2] but I wanted to add this as last resort in case of unexpected
> > > > emergency. But you're right. It's not good to hide the problem like this path
> > > > so let's drop [2/2].
> > > > 
> > > > Also, I absolutely agree it has bitrotted so for correcting it, we need a
> > > > volunteer who have to inverstigate power saveing experiment with long time.
> > > > So [1/2] would be band-aid until that.
> > > 
> > > I'm inclined to hold off on 1/2 as well, really.
> > 
> > Then, what's your plan?
> 
> My plan is to sit here until someone gets down and fully tests and
> fixes laptop-mode.  Making it work properly, reliably and as-designed.
> 
> Or perhaps someone wants to make the case that we just don't need it
> any more (SSDs are silent!) and removes it all.
> 
> > > 
> > > The point of laptop_mode isn't to save power btw - it is to minimise
> > > the frequency with which the disk drive is spun up.  By deferring and
> > > then batching writeout operations, basically.
> > 
> > I don't get it. Why should we minimise such frequency?
> 
> Because my laptop was going clickety every minute and was keeping me
> awake.
> 
> > It's for saving the power to increase batter life.
> 
> It might well have that effect, dunno.  That wasn't my intent.  Testing
> needed!
> 
> > As I real all document about laptop_mode, they all said about the power
> > or battery life saving.
> > 
> > 1. Documentation/laptops/laptop-mode.txt
> > 2. http://linux.die.net/man/8/laptop_mode
> > 3. http://samwel.tk/laptop_mode/
> > 3. http://www.thinkwiki.org/wiki/Laptop-mode 
> 
> Documentation creep ;)
> 
> Ten years ago, gad: http://lwn.net/Articles/1652/

Odd, I grep it in linux-history.git and found this.
http://git.kernel.org/?p=linux/kernel/git/tglx/history.git;a=commit;h=93d33a4885a483c708ccb7d24b56e0d5fef7bcab

It seem to be first commit about laptop_mode but it still said about battery life
, NOT clickety. But unfortunately, it had no number, measure method and even no
side-effect when the memory pressure is severe so we couldn't sure how it helped
about batter life without reclaim problem so the VM problem have been exported
since we apply f80c067[mm: zone_reclaim: make isolate_lru_page() filter-aware].

So let's apply [1/2] in mainline and even stable to fix the problem.
After that, we can add warning to laptop_mode so user who have used it will claim their
requirements. With it, we can know they need it for power saving, clickety or
, both so we can make requirement lists. From then, we can start to do someting.
If we are luck, we can remove it totally if any user doesn't claim.

What do you think about it?

> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
