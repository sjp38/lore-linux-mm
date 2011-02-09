Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 9B5868D0039
	for <linux-mm@kvack.org>; Wed,  9 Feb 2011 18:30:10 -0500 (EST)
Date: Thu, 10 Feb 2011 00:30:06 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [RFC PATCH 0/5] IO-less balance dirty pages
Message-ID: <20110209233006.GC3064@quack.suse.cz>
References: <1296783534-11585-1-git-send-email-jack@suse.cz>
 <4D4EE05D.4050906@panasas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4D4EE05D.4050906@panasas.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>

On Sun 06-02-11 19:54:37, Boaz Harrosh wrote:
> On 02/04/2011 03:38 AM, Jan Kara wrote:
> > The basic idea (implemented in the third patch) is that processes throttled
> > in balance_dirty_pages() wait for enough IO to complete. The waiting is
> > implemented as follows: Whenever we decide to throttle a task in
> > balance_dirty_pages(), task adds itself to a list of tasks that are throttled
> > against that bdi and goes to sleep waiting to receive specified amount of page
> > IO completions. Once in a while (currently HZ/10, in patch 5 the interval is
> > autotuned based on observed IO rate), accumulated page IO completions are
> > distributed equally among waiting tasks.
> > 
> > This waiting scheme has been chosen so that waiting time in
> > balance_dirty_pages() is proportional to
> >   number_waited_pages * number_of_waiters.
> > In particular it does not depend on the total number of pages being waited for,
> > thus providing possibly a fairer results.
> > 
> > I gave the patches some basic testing (multiple parallel dd's to a single
> > drive) and they seem to work OK. The dd's get equal share of the disk
> > throughput (about 10.5 MB/s, which is nice result given the disk can do
> > about 87 MB/s when writing single-threaded), and dirty limit does not get
> > exceeded. Of course much more testing needs to be done but I hope it's fine
> > for the first posting :).
> 
> So what is the disposition of Wu's patches in light of these ones?
> * Do they replace Wu's, or Wu's just get rebased ontop of these at a
>   later stage?
  They are meant as a replacement.

> * Did you find any hard problems with Wu's patches that delay them for
>   a long time?
  Wu himself wrote that the current patchset probably won't fly because it
fluctuates too much. So he decided to try to rewrite patches from per-bdi
limits to global limits when he has time...

> * Some of the complicated stuff in Wu's patches are the statistics and
>   rate control mechanics. Are these the troubled area? Because some of
>   these are actually some things that I'm interested in, and that appeal
>   to me the most.
  Basically yes, this logic seems to be the problematic one.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
