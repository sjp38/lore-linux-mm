Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 116B26B0044
	for <linux-mm@kvack.org>; Fri, 23 Mar 2012 08:05:36 -0400 (EDT)
Received: by ghrr18 with SMTP id r18so3355337ghr.14
        for <linux-mm@kvack.org>; Fri, 23 Mar 2012 05:05:35 -0700 (PDT)
Date: Fri, 23 Mar 2012 05:05:09 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: Possible Swapfile bug
In-Reply-To: <4F6BC8A8.6080202@storytotell.org>
Message-ID: <alpine.LSU.2.00.1203230440360.31745@eggly.anvils>
References: <4F6B5236.20805@storytotell.org> <20120322124635.85fd4673.akpm@linux-foundation.org> <4F6BC8A8.6080202@storytotell.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Mattax <jmattax@storytotell.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyu@jp.fujitsu.com, cesarb@cesarb.net, emunson@mgebm.net, penberg@kernel.org, linux-mm@kvack.org

On Thu, 22 Mar 2012, Jason Mattax wrote:
> On 03/22/2012 01:46 PM, Andrew Morton wrote:
> > On Thu, 22 Mar 2012 10:24:22 -0600
> > Jason Mattax<jmattax@storytotell.org>  wrote:
> > 
> > > Swapon very slow with swapfiles.
> > > 
> > > After upgrading the kernel my swap file loads very slowly, while a swap
> > > partition is unaffected. With the newer kernel (2.6.33.1) I get
> > > 
> > > # time swapon -v /var/swapfile
> > > swapon on /var/swapfile
> > > swapon: /var/swapfile: found swap signature: version 1, page-size 4,
> > > same byte order
> > > swapon: /var/swapfile: pagesize=4096, swapsize=6442450944,
> > > devsize=6442450944
> > > 
> > > real    4m35.355s
> > > user    0m0.001s
> > > sys    0m1.786s
> > > 
> > > while with the older kernel (2.6.32.27) I get
> > > # time swapon -v /var/swapfile
> > > swapon on /var/swapfile
> > > swapon: /var/swapfile: found swap signature: version 1, page-size 4,
> > > same byte order
> > > swapon: /var/swapfile: pagesize=4096, swapsize=6442450944,
> > > devsize=6442450944
> > > 
> > > real    0m1.158s
> > > user    0m0.000s
> > > sys     0m0.876s
> > > 
> > > this stays true even for new swapfiles I create with dd.
> > > 
> > > the file is on an OCZ Vertex2 SSD.
> > Probably the vertex2 discard problem.
> > 
> > We just merged a patch which will hopefully fix it:
> > 
> > --- a/mm/swapfile.c~swap-dont-do-discard-if-no-discard-option-added
> > +++ a/mm/swapfile.c
> > @@ -2103,7 +2103,7 @@ SYSCALL_DEFINE2(swapon, const char __use
> >   			p->flags |= SWP_SOLIDSTATE;
> >   			p->cluster_next = 1 + (random32() % p->highest_bit);
> >   		}
> > -		if (discard_swap(p) == 0&&  (swap_flags&  SWAP_FLAG_DISCARD))
> > +		if ((swap_flags&  SWAP_FLAG_DISCARD)&&  discard_swap(p) == 0)
> >   			p->flags |= SWP_DISCARDABLE;
> >   	}
> > 
> > 
> > But Hugh doesn't like it and won't tell us why :)
> > 
> 
> Patch worked like a charm for me, thanks.

Thanks for your reports: as Andrew points out, this issue has just
now surfaced; though there was one report of it fourteen months ago.

I'm not surprised that you saw no problem on 2.6.32.27, but I am
very surprised that you see the problem on 2.6.33.1 - I'm wondering
if that's a typo for something else, or a distro kernel which actually
contains changes from later releases?

I would expect the slowdown to occur sometime around 2.6.35 (perhaps
one before or after), when use of barriers in the block layer was
deprecated in favour of waiting on completion.  That made discard
significantly slower - but unavoidably so.  It appears now that the use
of barriers before was incorrect, or potentially incorrect: and if you
had started real swapping within 4m35s of swapon on 2.6.32.7, then you
might have been open to data corruption and mysterious segfaults.

Might: it would have depended upon unspecified behaviour in the drive.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
