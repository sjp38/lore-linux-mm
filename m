Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 45CB56B0169
	for <linux-mm@kvack.org>; Wed, 27 Jul 2011 21:34:55 -0400 (EDT)
Subject: Re: [PATCH]vmscan: add block plug for page reclaim
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <20110727181527.c4f6d806.akpm@linux-foundation.org>
References: <1311130413.15392.326.camel@sli10-conroe>
	 <CAEwNFnDj30Bipuxrfe9upD-OyuL4v21tLs0ayUKYUfye5TcGyA@mail.gmail.com>
	 <1311142253.15392.361.camel@sli10-conroe>
	 <CAEwNFnD3iCMBpZK95Ks+Z7DYbrzbZbSTLf3t6WXDQdeHrE6bLQ@mail.gmail.com>
	 <1311144559.15392.366.camel@sli10-conroe>	<4E287EC0.4030208@fusionio.com>
	 <1311311695.15392.369.camel@sli10-conroe>	<4E2B17A6.6080602@fusionio.com>
	 <20110727164523.c2b1d569.akpm@linux-foundation.org>
	 <1311815060.15392.375.camel@sli10-conroe>
	 <20110727181527.c4f6d806.akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 28 Jul 2011 09:34:52 +0800
Message-ID: <1311816892.15392.379.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jens Axboe <jaxboe@fusionio.com>, Minchan Kim <minchan.kim@gmail.com>, "mgorman@suse.de" <mgorman@suse.de>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

On Thu, 2011-07-28 at 09:15 +0800, Andrew Morton wrote:
> On Thu, 28 Jul 2011 09:04:20 +0800 Shaohua Li <shaohua.li@intel.com> wrote:
> 
> > > Using an additional 44 bytes of stack on that path is also
> > > significant(ly bad).  But we need to fix that problem anyway.  One way
> > > we could improve things in mm/vmscan.c is to move the blk_plug into
> > > scan_control then get the scan_control off the stack in some manner. 
> > > That's easy for kswapd: allocate one scan_control per kswapd at
> > > startup.  Doing it for direct-reclaim would be a bit trickier...
> > unfortunately, the direct-reclaim case is what cares about stack.
> > 
> > BTW, the scan_control can be dieted. may_unmap/may_swap/may_writepage
> > can be a bit. swappiness < 100, so can be a char. order <= 11, can be a
> > char. should I do it to cut the size?
> 
> All five will fit in a 32-bit word, at some expense in code size.
oh, I missed the code size will increase, so it's not good then.

> But I think first it would be better to work on a way of getting it all
> off the stack, along with the blk_plug.
> 
> Could be done with a per-cpu array and CPU pinning, but CPU pinning is
> a bit expensive nowadays.  Could put a scan_control* into the
> tack_struct, but that's dopey.
looks it should be per task, as reclaim could sleep. either putting it
to task_struct or allocating it, both are not good.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
