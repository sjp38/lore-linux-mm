Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 4BA6D6B0169
	for <linux-mm@kvack.org>; Fri, 29 Jul 2011 04:38:57 -0400 (EDT)
Received: by gyg13 with SMTP id 13so3095643gyg.14
        for <linux-mm@kvack.org>; Fri, 29 Jul 2011 01:38:55 -0700 (PDT)
Date: Fri, 29 Jul 2011 17:38:47 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH]vmscan: add block plug for page reclaim
Message-ID: <20110729083847.GB1843@barrios-desktop>
References: <1311130413.15392.326.camel@sli10-conroe>
 <CAEwNFnDj30Bipuxrfe9upD-OyuL4v21tLs0ayUKYUfye5TcGyA@mail.gmail.com>
 <1311142253.15392.361.camel@sli10-conroe>
 <CAEwNFnD3iCMBpZK95Ks+Z7DYbrzbZbSTLf3t6WXDQdeHrE6bLQ@mail.gmail.com>
 <1311144559.15392.366.camel@sli10-conroe>
 <4E287EC0.4030208@fusionio.com>
 <1311311695.15392.369.camel@sli10-conroe>
 <4E2B17A6.6080602@fusionio.com>
 <20110727164523.c2b1d569.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110727164523.c2b1d569.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jens Axboe <jaxboe@fusionio.com>, Shaohua Li <shaohua.li@intel.com>, "mgorman@suse.de" <mgorman@suse.de>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

On Wed, Jul 27, 2011 at 04:45:23PM -0700, Andrew Morton wrote:
> On Sat, 23 Jul 2011 20:49:10 +0200
> Jens Axboe <jaxboe@fusionio.com> wrote:
> 
> > > I can observe the average request size changes. Before the patch, the
> > > average request size is about 90k from iostat (but the variation is
> > > big). With the patch, the request size is about 100k and variation is
> > > small.
> > 
> > That's a good win right there, imho.
> 
> yup.  Reduced CPU consumption on that path isn't terribly exciting IMO,
> but improved request size is significant.

Fair enough.
He didn't write down it in the description.
At least, The description should include request size and variation instead of
CPU consumption thing.

Shaohua, Please rewrite the description although it's annoying.

> 
> Using an additional 44 bytes of stack on that path is also
> significant(ly bad).  But we need to fix that problem anyway.  One way
> we could improve things in mm/vmscan.c is to move the blk_plug into
> scan_control then get the scan_control off the stack in some manner. 
> That's easy for kswapd: allocate one scan_control per kswapd at
> startup.  Doing it for direct-reclaim would be a bit trickier...

Stack diet in direct reclaim...
Of course, it's a matter as I pointed out in this patch
but frankly speaking, it's very annoying to consider stack usage
whenever we add something in direct reclaim path.
I think better solution is to avoid write in direct reclaim like the approach of Mel.
I vote the approach.
So now I will not complain the stack usage in this patch but focus on Mel's patch

> 
> 
> 
> And I have the usual maintainability whine.  If someone comes up to
> vmscan.c and sees it calling blk_start_plug(), how are they supposed to
> work out why that call is there?  They go look at the blk_start_plug()
> definition and it is undocumented.  I think we can do better than this?

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
