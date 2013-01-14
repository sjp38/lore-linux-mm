Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id E98826B006E
	for <linux-mm@kvack.org>; Mon, 14 Jan 2013 07:04:54 -0500 (EST)
Date: Mon, 14 Jan 2013 10:05:01 -0200
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: Re: [RFC 2/2] virtio_balloon: add auto-ballooning support
Message-ID: <20130114100501.603ce8a4@doriath.home>
In-Reply-To: <20130111204317.GB11436@amit.redhat.com>
References: <1355861850-2702-1-git-send-email-lcapitulino@redhat.com>
	<1355861850-2702-3-git-send-email-lcapitulino@redhat.com>
	<20130111204317.GB11436@amit.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Amit Shah <amit.shah@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, riel@redhat.com, aquini@redhat.com, mst@redhat.com, agl@us.ibm.com

On Sat, 12 Jan 2013 02:13:17 +0530
Amit Shah <amit.shah@redhat.com> wrote:

> On (Tue) 18 Dec 2012 [18:17:30], Luiz Capitulino wrote:
> > The auto-ballooning feature automatically performs balloon inflate or
> > deflate based on host and guest memory pressure. This can help to
> > avoid swapping or worse in both, host and guest.
> > 
> > Auto-ballooning has a host and a guest part. The host performs
> > automatic inflate by requesting the guest to inflate its balloon
> > when the host is facing memory pressure. The guest performs
> > automatic deflate when it's facing memory pressure itself. It's
> > expected that auto-inflate and auto-deflate will balance each
> > other over time.
> > 
> > This commit implements the guest side of auto-ballooning.
> > 
> > To perform automatic deflate, the virtio_balloon driver registers
> > a shrinker callback, which will try to deflate the guest's balloon
> > on guest memory pressure just like if it were a cache. The shrinker
> > callback is only registered if the host supports the
> > VIRTIO_BALLOON_F_AUTO_BALLOON feature bit.
> 
> I'm wondering if guest should auto-deflate even when the AUTO_BALLOON
> feature isn't supported by the host: if a guest is under pressure,
> there's no way for it to tell the host and wait for the host to
> deflate the balloon, so it may be beneficial to just go ahead and
> deflate the balloon for all hosts.

I see two problems with this. First, this will automagically override
balloon changes done by the user; and second, if we don't have the
auto-inflate part and if the host starts facing memory pressure, VMs
may start getting OOM.

> Similarly, on the host side, management can configure a VM to either
> enable or disable auto-balloon (the auto-inflate part).  So even the
> host can do away with the feature advertisement and negotiation.
> 
> Is there some use-case I'm missing where doing these actions after
> feature negotiation is beneficial?
> 
> > FIXMEs
> > 
> >  o the guest kernel seems to spin when the host is performing a long
> >    auto-inflate
> 
> Is this introduced by the current patches?  I'd assume it happens even
> without it -- these patches just introduce some heuristics, the
> mechanism has stayed the same.

Good point, I'll check that.

> > Signed-off-by: Luiz Capitulino <lcapitulino@redhat.com>
> > ---
> >  drivers/virtio/virtio_balloon.c     | 54 +++++++++++++++++++++++++++++++++++++
> >  include/uapi/linux/virtio_balloon.h |  1 +
> >  2 files changed, 55 insertions(+)
> 
> Patch looks good, just one thing:
> 
> > +	/*
> > +	 * If the current balloon size is greater than the number of
> > +	 * pages being reclaimed by the kernel, deflate only the needed
> > +	 * amount. Otherwise deflate everything we have.
> > +	 */
> > +	if (nr_pages > sc->nr_to_scan) {
> > +		new_target = nr_pages - sc->nr_to_scan;
> > +	} else {
> > +		new_target = 0;
> > +	}
> 
> This looks better:
> 
> 	new_target = 0;
> 	if (nr_pages > sc->nr_to_scan) {
> 		new_target = nr_pages - sc->nr_to_scan;
> 	}

Ok.

> 
> 
> Thanks,
> 		Amit
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
