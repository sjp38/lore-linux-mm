Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 4555C6B0062
	for <linux-mm@kvack.org>; Tue, 19 Mar 2013 06:01:16 -0400 (EDT)
Date: Tue, 19 Mar 2013 10:01:11 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 03/10] mm: vmscan: Flatten kswapd priority loop
Message-ID: <20130319100111.GB2055@suse.de>
References: <1363525456-10448-1-git-send-email-mgorman@suse.de>
 <1363525456-10448-4-git-send-email-mgorman@suse.de>
 <CAJd=RBAnEeC5D17AmQJHhbo-ST0fZ6+dmYSBzSnN8v4wtm6STQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CAJd=RBAnEeC5D17AmQJHhbo-ST0fZ6+dmYSBzSnN8v4wtm6STQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Mi@jasper.es

On Mon, Mar 18, 2013 at 03:02:10PM +0800, Hillf Danton wrote:
> On Sun, Mar 17, 2013 at 9:04 PM, Mel Gorman <mgorman@suse.de> wrote:
> >
> > +               /* If no reclaim progress then increase scanning priority */
> > +               if (sc.nr_reclaimed - nr_reclaimed == 0)
> > +                       raise_priority = true;
> >
> >                 /*
> > -                * Fragmentation may mean that the system cannot be
> > -                * rebalanced for high-order allocations in all zones.
> > -                * At this point, if nr_reclaimed < SWAP_CLUSTER_MAX,
> > -                * it means the zones have been fully scanned and are still
> > -                * not balanced. For high-order allocations, there is
> > -                * little point trying all over again as kswapd may
> > -                * infinite loop.
> > -                *
> > -                * Instead, recheck all watermarks at order-0 as they
> > -                * are the most important. If watermarks are ok, kswapd will go
> > -                * back to sleep. High-order users can still perform direct
> > -                * reclaim if they wish.
> > +                * Raise priority if scanning rate is too low or there was no
> > +                * progress in reclaiming pages
> 2) this comment is already included also in the above one?
> 
> >                  */
> > -               if (sc.nr_reclaimed < SWAP_CLUSTER_MAX)
> > -                       order = sc.order = 0;
> > -
> > -               goto loop_again;
> > -       }
> > +               if (raise_priority || sc.nr_reclaimed - nr_reclaimed == 0)
> 1) duplicated reclaim check with the above one, merge error?
> 

Yes, thanks. Duplicated check removed now.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
