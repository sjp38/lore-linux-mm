Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 6C9656B0036
	for <linux-mm@kvack.org>; Fri, 10 May 2013 09:28:22 -0400 (EDT)
Date: Fri, 10 May 2013 09:28:19 -0400
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: Re: [RFC 2/2] virtio_balloon: auto-ballooning support
Message-ID: <20130510092819.322798b7@redhat.com>
In-Reply-To: <20130510092046.17be9bbb@redhat.com>
References: <1368111229-29847-1-git-send-email-lcapitulino@redhat.com>
	<1368111229-29847-3-git-send-email-lcapitulino@redhat.com>
	<20130509211516.GC16446@optiplex.redhat.com>
	<20130510092046.17be9bbb@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, riel@redhat.com, mst@redhat.com, amit.shah@redhat.com, anton@enomsg.org

On Fri, 10 May 2013 09:20:46 -0400
Luiz Capitulino <lcapitulino@redhat.com> wrote:

> On Thu, 9 May 2013 18:15:19 -0300
> Rafael Aquini <aquini@redhat.com> wrote:
> 
> > On Thu, May 09, 2013 at 10:53:49AM -0400, Luiz Capitulino wrote:
> > > Automatic ballooning consists of dynamically adjusting the guest's
> > > balloon according to memory pressure in the host and in the guest.
> > > 
> > > This commit implements the guest side of automatic balloning, which
> > > basically consists of registering a shrinker callback with the kernel,
> > > which will try to deflate the guest's balloon by the amount of pages
> > > being requested. The shrinker callback is only registered if the host
> > > supports the VIRTIO_BALLOON_F_AUTO_BALLOON feature bit.
> > > 
> > > Automatic inflate is performed by the host.
> > > 
> > > Here are some numbers. The test-case is to run 35 VMs (1G of RAM each)
> > > in parallel doing a kernel build. Host has 32GB of RAM and 16GB of swap.
> > > SWAP IN and SWAP OUT correspond to the number of pages swapped in and
> > > swapped out, respectively.
> > > 
> > > Auto-ballooning disabled:
> > > 
> > > RUN  TIME(s)  SWAP IN  SWAP OUT
> > > 
> > > 1    634      930980   1588522
> > > 2    610      627422   1362174
> > > 3    649      1079847  1616367
> > > 4    543      953289   1635379
> > > 5    642      913237   1514000
> > > 
> > > Auto-ballooning enabled:
> > > 
> > > RUN  TIME(s)  SWAP IN  SWAP OUT
> > > 
> > > 1    629      901      12537
> > > 2    624      981      18506
> > > 3    626      573      9085
> > > 4    631      2250     42534
> > > 5    627      1610     20808
> > > 
> > > Signed-off-by: Luiz Capitulino <lcapitulino@redhat.com>
> > > ---
> > 
> > Nice work Luiz! Just allow me a silly question, though. 
> 
> I have 100% more chances of committing sillynesses than you, so please
> go ahead.
> 
> > Since your shrinker
> > doesn't change the balloon target size,
> 
> Which target size are you referring to? The one in the host (member num_pages
> of VirtIOBalloon in QEMU)?
> 
> If it the one in the host, then my understanding is that that member is only
> used to communicate the new balloon target to the guest. The guest driver
> will only read it when told (by the host) to do so, and when it does the
> target value will be correct.
> 
> Am I right?
> 
> > as soon as the shrink round finishes the
> > balloon will re-inflate again, won't it? Doesn't this cause a sort of "balloon
> > thrashing" scenario, if both guest and host are suffering from memory pressure?

Forgot to say that I didn't observe this in my testing. But I'll try harder
as soon as we clarify which target size we're talking about.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
