Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f179.google.com (mail-qc0-f179.google.com [209.85.216.179])
	by kanga.kvack.org (Postfix) with ESMTP id 68F7F6B0036
	for <linux-mm@kvack.org>; Tue,  6 May 2014 12:54:16 -0400 (EDT)
Received: by mail-qc0-f179.google.com with SMTP id x3so6373702qcv.38
        for <linux-mm@kvack.org>; Tue, 06 May 2014 09:54:16 -0700 (PDT)
Received: from mail-qg0-x230.google.com (mail-qg0-x230.google.com [2607:f8b0:400d:c04::230])
        by mx.google.com with ESMTPS id n7si5397315qas.171.2014.05.06.09.54.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 May 2014 09:54:14 -0700 (PDT)
Received: by mail-qg0-f48.google.com with SMTP id i50so8163859qgf.7
        for <linux-mm@kvack.org>; Tue, 06 May 2014 09:54:14 -0700 (PDT)
Date: Tue, 6 May 2014 12:54:08 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [RFC] Heterogeneous memory management (mirror process address
 space on a device mmu).
Message-ID: <20140506165405.GE6731@gmail.com>
References: <1399038730-25641-1-git-send-email-j.glisse@gmail.com>
 <20140506102925.GD11096@twins.programming.kicks-ass.net>
 <CA+55aFzt47Jpp-KK-ocLGgzYt_w-vheqFLfaGZOUSjwVrgGUtw@mail.gmail.com>
 <20140506150014.GA6731@gmail.com>
 <CA+55aFwM-g01tCZ1NknwvMeSMpwyKyTm6hysN-GmrZ_APtk7UA@mail.gmail.com>
 <20140506153315.GB6731@gmail.com>
 <CA+55aFzzPtTkC22WvHNy6srN9PFzer0-_mgRXWO03NwmCdfy4g@mail.gmail.com>
 <53690E29.7060602@redhat.com>
 <CA+55aFwQWRKpcaR_-GvhMbUXE-n5yjEi_a_Um7=Bb_xbdQtFFg@mail.gmail.com>
 <53691214.80906@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <53691214.80906@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Linda Wang <lwang@redhat.com>, Kevin E Martin <kem@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Dave Airlie <airlied@redhat.com>, Jeff Law <law@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, "Sander, Ben" <ben.sander@amd.com>, "Stoner, Greg" <Greg.Stoner@amd.com>, "Bridgman, John" <John.Bridgman@amd.com>, "Mantor, Michael" <Michael.Mantor@amd.com>, "Blinzer, Paul" <Paul.Blinzer@amd.com>, "Morichetti, Laurent" <Laurent.Morichetti@amd.com>, "Deucher, Alexander" <Alexander.Deucher@amd.com>, "Gabbay, Oded" <Oded.Gabbay@amd.com>, Davidlohr Bueso <davidlohr@hp.com>

On Tue, May 06, 2014 at 12:47:16PM -0400, Rik van Riel wrote:
> On 05/06/2014 12:34 PM, Linus Torvalds wrote:
> > On Tue, May 6, 2014 at 9:30 AM, Rik van Riel <riel@redhat.com> wrote:
> >>
> >> The GPU runs a lot faster when using video memory, instead
> >> of system memory, on the other side of the PCIe bus.
> > 
> > The nineties called, and they want their old broken model back.
> > 
> > Get with the times. No high-performance future GPU will ever run
> > behind the PCIe bus. We still have a few straggling historical
> > artifacts, but everybody knows where the future is headed.
> > 
> > They are already cache-coherent because flushing caches etc was too
> > damn expensive. They're getting more so.
> 
> I suppose that VRAM could simply be turned into a very high
> capacity CPU cache for the GPU, for the case where people
> want/need an add-on card.
> 
> With a few hundred MB of "CPU cache" on the video card, we
> could offload processing to the GPU very easily, without
> having to worry about multiple address or page table formats
> on the CPU side.
> 
> A new generation of GPU hardware seems to come out every
> six months or so, so I guess we could live with TLB
> invalidations to the first generations of hardware being
> comically slow :)
> 

I do not want to speak for any GPU manufacturer but i think it is safe
to say that there will be dedicated memory for GPU for a long time. It
is not going anywhere soon and it is a lot more than few hundred MB,
think several GB. If you think about 4k, 8k screen you really gonna want
8GB at least on desktop computer and for compute you will likely see
16GB or 32GB as common size.

Again i stress that there is nothing on the horizon that let me believe
that regular memory associated to CPU will ever come close to the bandwith
that exist with memory associated to GPU. It is already more than 10 times
faster on GPU and as far as i know the gap will grow even more in the next
generation.

So dedicated memory to gpu should not be discarded as something that is
vanishing quite the contrary it should be acknowledge as something that is
here to stay a lot longer afaict.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
