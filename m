Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id AA1BE6B0012
	for <linux-mm@kvack.org>; Sun, 15 May 2011 11:27:51 -0400 (EDT)
Date: Sun, 15 May 2011 23:27:47 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: Kernel falls apart under light memory pressure (i.e. linking
 vmlinux)
Message-ID: <20110515152747.GA25905@localhost>
References: <BANLkTi=XqROAp2MOgwQXEQjdkLMenh_OTQ@mail.gmail.com>
 <m2fwokj0oz.fsf@firstfloor.org>
 <BANLkTikhj1C7+HXP_4T-VnJzPefU2d7b3A@mail.gmail.com>
 <20110512054631.GI6008@one.firstfloor.org>
 <BANLkTi=fk3DUT9cYd2gAzC98c69F6HXX7g@mail.gmail.com>
 <BANLkTikofp5rHRdW5dXfqJXb8VCAqPQ_7A@mail.gmail.com>
 <20110514165346.GV6008@one.firstfloor.org>
 <BANLkTik6SS9NH7XVSRBoCR16_5veY0MKBw@mail.gmail.com>
 <20110514174333.GW6008@one.firstfloor.org>
 <BANLkTinst+Ryox9VZ-s7gdXKa574XXqt5w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <BANLkTinst+Ryox9VZ-s7gdXKa574XXqt5w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andi Kleen <andi@firstfloor.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Lutomirski <luto@mit.edu>, LKML <linux-kernel@vger.kernel.org>

On Sun, May 15, 2011 at 09:37:58AM +0800, Minchan Kim wrote:
> On Sun, May 15, 2011 at 2:43 AM, Andi Kleen <andi@firstfloor.org> wrote:
> > Copying back linux-mm.
> >
> >> Recently, we added following patch.
> >> https://lkml.org/lkml/2011/4/26/129
> >> If it's a culprit, the patch should solve the problem.
> >
> > It would be probably better to not do the allocations at all under
> > memory pressure. A Even if the RA allocation doesn't go into reclaim
> 
> Fair enough.
> I think we can do it easily now.
> If page_cache_alloc_readahead(ie, GFP_NORETRY) is fail, we can adjust
> RA window size or turn off a while. The point is that we can use the
> fail of __do_page_cache_readahead as sign of memory pressure.
> Wu, What do you think?

No, disabling readahead can hardly help.

The sequential readahead memory consumption can be estimated by

                2 * (number of concurrent read streams) * (readahead window size)

And you can double that when there are two level of readaheads.

Since there are hardly any concurrent read streams in Andy's case,
the readahead memory consumption will be ignorable.

Typically readahead thrashing will happen long before excessive
GFP_NORETRY failures, so the reasonable solutions are to

- shrink readahead window on readahead thrashing
  (current readahead heuristic can somehow do this, and I have patches
  to further improve it)

- prevent abnormal GFP_NORETRY failures
  (when there are many reclaimable pages)


Andy's OOM memory dump (incorrect_oom_kill.txt.xz) shows that there are

- 8MB   active+inactive file pages
- 160MB active+inactive anon pages
- 1GB   shmem pages
- 1.4GB unevictable pages

Hmm, why are there so many unevictable pages?  How come the shmem
pages become unevictable when there are plenty of swap space?

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
