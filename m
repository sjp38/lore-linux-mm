Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id 02E0F6B0005
	for <linux-mm@kvack.org>; Mon,  7 Mar 2016 06:40:15 -0500 (EST)
Received: by mail-qg0-f54.google.com with SMTP id t4so93298321qge.0
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 03:40:14 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t79si16401802qkt.80.2016.03.07.03.40.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Mar 2016 03:40:14 -0800 (PST)
Date: Mon, 7 Mar 2016 13:40:06 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [Qemu-devel] [RFC qemu 0/4] A PV solution for live migration
 optimization
Message-ID: <20160307110852-mutt-send-email-mst@redhat.com>
References: <20160303174615.GF2115@work-vm>
 <F2CBF3009FA73547804AE4C663CAB28E03770E33@SHSMSX101.ccr.corp.intel.com>
 <20160304081411.GD9100@rkaganb.sw.ru>
 <F2CBF3009FA73547804AE4C663CAB28E0377160A@SHSMSX101.ccr.corp.intel.com>
 <20160304102346.GB2479@rkaganb.sw.ru>
 <F2CBF3009FA73547804AE4C663CAB28E0414516C@shsmsx102.ccr.corp.intel.com>
 <20160304163246-mutt-send-email-mst@redhat.com>
 <F2CBF3009FA73547804AE4C663CAB28E041452EA@shsmsx102.ccr.corp.intel.com>
 <20160305214748-mutt-send-email-mst@redhat.com>
 <F2CBF3009FA73547804AE4C663CAB28E04146308@shsmsx102.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <F2CBF3009FA73547804AE4C663CAB28E04146308@shsmsx102.ccr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Li, Liang Z" <liang.z.li@intel.com>
Cc: Roman Kagan <rkagan@virtuozzo.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, "ehabkost@redhat.com" <ehabkost@redhat.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "quintela@redhat.com" <quintela@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "rth@twiddle.net" <rth@twiddle.net>, riel@redhat.com

On Mon, Mar 07, 2016 at 06:49:19AM +0000, Li, Liang Z wrote:
> > > No. And it's exactly what I mean. The ballooned memory is still
> > > processed during live migration without skipping. The live migration code is
> > in migration/ram.c.
> > 
> > So if guest acknowledged VIRTIO_BALLOON_F_MUST_TELL_HOST, we can
> > teach qemu to skip these pages.
> > Want to write a patch to do this?
> > 
> 
> Yes, we really can teach qemu to skip these pages and it's not hard.  
> The problem is the poor performance, this PV solution

Balloon is always PV. And do not call patches solutions please.

> is aimed to make it more
> efficient and reduce the performance impact on guest.

We need to get a bit beyond this.  You are making multiple
changes, it seems to make sense to split it all up, and analyse each
change separately.  If you don't this patchset will be stuck: as you
have seen people aren't convinced it actually helps with real workloads.

> > > >
> > > > > > > The only advantage of ' inflating the balloon before live
> > > > > > > migration' is simple,
> > > > > > nothing more.
> > > > > >
> > > > > > That's a big advantage.  Another one is that it does something
> > > > > > useful in real- world scenarios.
> > > > > >
> > > > >
> > > > > I don't think the heave performance impaction is something useful
> > > > > in real
> > > > world scenarios.
> > > > >
> > > > > Liang
> > > > > > Roman.
> > > >
> > > > So fix the performance then. You will have to try harder if you want
> > > > to convince people that the performance is due to bad host/guest
> > > > interface, and so we have to change *that*.
> > > >
> > >
> > > Actually, the PV solution is irrelevant with the balloon mechanism, I
> > > just use it to transfer information between host and guest.
> > > I am not sure if I should implement a new virtio device, and I want to
> > > get the answer from the community.
> > > In this RFC patch, to make things simple, I choose to extend the
> > > virtio-balloon and use the extended interface to transfer the request and
> > free_page_bimap content.
> > >
> > > I am not intend to change the current virtio-balloon implementation.
> > >
> > > Liang
> > 
> > And the answer would depend on the answer to my question above.
> > Does balloon need an interface passing page bitmaps around?
> 
> Yes, I need a new interface.

Possibly, but you will need to justify this at some level if you care
about upstreaming your patches.

> > Does this speed up any operations?
> 
> No, a new interface will not speed up anything, but it is the easiest way to solve the compatibility issue.

A bunch of new code is often easier to write than to figure
out the old one, but if we keep piling it up we'll end up
with an unmaintainable mess. So we are rather careful
about adding new interfaces, and we try to make them generic
sometimes even at cost of slight inefficiencies.

> > OTOH what if you use the regular balloon interface with your patches?
> >
> 
> The regular balloon interfaces have their specific function and I can't use them in my patches.
> If using these regular interface, I have to do a lot of changes to keep the compatibility. 

Why can't you?

What exactly do we need to change?

If we put things in terms of the balloon, that supports
adding and removing pages.

Using these terms, let's enumerate:
- a new method (e.g. new virtqueue) that adds and immediately removes page in a balloon
	clearly, you can add then remove using the existing interfaces
	is a single command significantly faster than using existing two vqs?
- a new kind of request that says "add (and immediately remove?) as many pages as you can"
	sounds rather benign
- a new kind of message that adds multiple pages using a bitmap
  	(instead of an address list)
	again, is this significantly faster?

Does not look like compatibility is an issue, to me.


At some level, your patches look like page hints.
If we have more patches in mind that use page hints,
then a new hint device might make sense.

However, people experimented with page hints in the past, so far this
always went nowhere.  E.g. I CC Rick who saw some problems when page
hints interact with huge pages. Rick, could you elaborate please?


-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
