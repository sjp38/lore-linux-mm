Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 7C06C6B0002
	for <linux-mm@kvack.org>; Sun, 17 Feb 2013 18:54:03 -0500 (EST)
Date: Sun, 17 Feb 2013 15:54:02 -0800 (PST)
From: dormando <dormando@rydia.net>
Subject: Re: extra free kbytes tunable
In-Reply-To: <511EB5CB.2060602@redhat.com>
Message-ID: <alpine.DEB.2.02.1302171551350.10836@dflat>
References: <alpine.DEB.2.02.1302111734090.13090@dflat> <A5ED84D3BB3A384992CBB9C77DEDA4D414A98EBF@USINDEM103.corp.hds.com> <511EB5CB.2060602@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Seiji Aguchi <seiji.aguchi@hds.com>, Satoru Moriya <satoru.moriya@hds.com>, Randy Dunlap <rdunlap@xenotime.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "lwoodman@redhat.com" <lwoodman@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hughd@google.com" <hughd@google.com>



On Fri, 15 Feb 2013, Rik van Riel wrote:

> On 02/15/2013 05:21 PM, Seiji Aguchi wrote:
> > Rik, Satoru,
> >
> > Do you have any comments?
>
> IIRC at the time the patch was rejected as too inelegant.
>
> However, nobody else seems to have come up with a better plan, and
> there are users in need of a fix for this problem.
>
> I would still like to see a fix for the problem merged upstream.

I merged in the cleanups to your original patch, rebased it off of linus'
master from a day or two ago and re-sent (not sure how to preserve
authorship in that case? Apologies for goofing it).

I'm willing to argue it, or investigate better options. I'm going to be
stuck maintaining this patch since we can't really afford to have
production hang, or waste 12g+ of RAM per box.

> > > -----Original Message-----
> > > From: linux-kernel-owner@vger.kernel.org
> > > [mailto:linux-kernel-owner@vger.kernel.org] On Behalf Of dormando
> > > Sent: Monday, February 11, 2013 9:01 PM
> > > To: Rik van Riel
> > > Cc: Randy Dunlap; Satoru Moriya; linux-kernel@vger.kernel.org;
> > > linux-mm@kvack.org; lwoodman@redhat.com; Seiji Aguchi;
> > > akpm@linux-foundation.org; hughd@google.com
> > > Subject: extra free kbytes tunable
> > >
> > > Hi,
> > >
> > > As discussed in this thread:
> > > http://marc.info/?l=linux-mm&m=131490523222031&w=2
> > > (with this cleanup as well: https://lkml.org/lkml/2011/9/2/225)
> > >
> > > A tunable was proposed to allow specifying the distance between pages_min
> > > and the low watermark before kswapd is kicked in to
> > > free up pages. I'd like to re-open this thread since the patch did not
> > > appear to go anywhere.
> > >
> > > We have a server workload wherein machines with 100G+ of "free" memory
> > > (used by page cache), scattered but frequent random io
> > > reads from 12+ SSD's, and 5gbps+ of internet traffic, will frequently hit
> > > direct reclaim in a few different ways.
> > >
> > > 1) It'll run into small amounts of reclaim randomly (a few hundred
> > > thousand).
> > >
> > > 2) A burst of reads or traffic can cause extra pressure, which kswapd
> > > occasionally responds to by freeing up 40g+ of the pagecache all
> > > at once
> > > (!) while pausing the system (Argh).
> > >
> > > 3) A blip in an upstream provider or failover from a peer causes the
> > > kernel to allocate massive amounts of memory for retransmission
> > > queues/etc, potentially along with buffered IO reads and (some, but not
> > > often a ton) of new allocations from an application. This
> > > paired with 2) can cause the box to stall for 15+ seconds.
> > >
> > > We're seeing this more in 3.4/3.5/3.6, saw it less in 2.6.38. Mass
> > > reclaims are more common in newer kernels, but reclaims still happen
> > > in all kernels without raising min_free_kbytes dramatically.
> > >
> > > I've found that setting "lowmem_reserve_ratio" to something like "1 1 32"
> > > (thus protecting the DMA32 zone) causes 2) to happen less often, and is
> > > generally less violent with 1).
> > >
> > > Setting min_free_kbytes to 15G or more, paired with the above, has been
> > > the best at mitigating the issue. This is simply trying to raise
> > > the distance between the min and low watermarks. With min_free_kbytes set
> > > to 15000000, that gives us a whopping 1.8G (!!!) of
> > > leeway before slamming into direct reclaim.
> > >
> > > So, this patch is unfortunate but wonderful at letting us reclaim 10G+ of
> > > otherwise lost memory. Could we please revisit it?
> > >
> > > I saw a lot of discussion on doing this automatically, or making kswapd
> > > more efficient to it, and I'd love to do that. Beyond making
> > > kswapd psychic I haven't seen any better options yet.
> > >
> > > The issue is more complex than simply having an application warn of an
> > > impending allocation, since this can happen via read load on
> > > disk or from kernel page allocations for the network, or a combination of
> > > the two (or three, if you add the app back in).
> > >
> > > It's going to get worse as we push machines with faster SSD's and bigger
> > > networks. I'm open to any ideas on how to make kswapd
> > > more efficient in our case, or really anything at all that works.
> > >
> > > I have more details, but cut it down as much as I could for this mail.
> > >
> > > Thanks,
> > > -Dormando
> > > --
> > > To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> > > the body of a message to majordomo@vger.kernel.org More
> > > majordomo info at  http://vger.kernel.org/majordomo-info.html
> > > Please read the FAQ at  http://www.tux.org/lkml/
>
>
> --
> All rights reversed
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
