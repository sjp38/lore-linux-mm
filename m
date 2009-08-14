Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 9FE566B005A
	for <linux-mm@kvack.org>; Fri, 14 Aug 2009 18:10:49 -0400 (EDT)
Received: by qyk36 with SMTP id 36so1514378qyk.12
        for <linux-mm@kvack.org>; Fri, 14 Aug 2009 15:10:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <adafxbu3vqt.fsf@cisco.com>
References: <200908122007.43522.ngupta@vflare.org>
	 <alpine.DEB.1.10.0908130931400.28013@asgard.lang.hm>
	 <87f94c370908131115r680a7523w3cdbc78b9e82373c@mail.gmail.com>
	 <alpine.DEB.1.10.0908131342460.28013@asgard.lang.hm>
	 <87f94c370908131428u75dfe496x1b7d90b94833bf80@mail.gmail.com>
	 <46b8a8850908131520s747e045cnd8db9493e072939d@mail.gmail.com>
	 <87f94c370908131719l7d84c5d0x2157cfeeb2451bce@mail.gmail.com>
	 <46b8a8850908131758s781b07f6v2729483c0e50ae7a@mail.gmail.com>
	 <87f94c370908141433h111f819j550467bf31c60776@mail.gmail.com>
	 <adafxbu3vqt.fsf@cisco.com>
Date: Fri, 14 Aug 2009 18:10:50 -0400
Message-ID: <87f94c370908141510p1752183elf32c879c0510ebc4@mail.gmail.com>
Subject: Re: Discard support
From: Greg Freemyer <greg.freemyer@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Roland Dreier <rdreier@cisco.com>
Cc: Richard Sharpe <realrichardsharpe@gmail.com>, david@lang.hm, Markus Trippelsdorf <markus@trippelsdorf.de>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nitin Gupta <ngupta@vflare.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-scsi@vger.kernel.org, linux-ide@vger.kernel.org, Linux RAID <linux-raid@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Aug 14, 2009 at 5:56 PM, Roland Dreier<rdreier@cisco.com> wrote:
>
> =A0> It seems to me that unmap is not all that different, why do we need =
to
> =A0> do it even close in time proximity to the deletes? =A0With a bitmap,=
 we
> =A0> have total timing control of when the unmaps are forwarded down to t=
he
> =A0> device. =A0I like that timing control much better than a cache and
> =A0> coalesce approach.
>
> The trouble I see with a bitmap is the amount of memory it consumes. =A0I=
t
> seems that discards must be tracked on no bigger than 4KB sectors (and
> possibly even 512 byte sectors). =A0But even with 4KB, then, say, a 32 TB
> volume (just 16 * 2TB disks, or even lower end with thin provisioning)
> requires 1 GB of bitmap memory. =A0Which is a lot just to store, let alon=
e
> walk over etc.

Have the filesystem guys created any efficient extent tree tracking solutio=
ns?

I mean a 16TB filesystem obviously has to track the freespace somehow
that does not require 1GB of ram.  Can that logic be leveraged in
block to track freespace?  That obviously assumes its not too cpu
intensive to do so.

If a leaf in the extent tracking tree becomes big enough, it could
even be sent down from the block layer and that leaf deleted.  ie. If
a leaf of the tree grows to represent X contiguous blocks, then a
discard could be sent down to the device and the leaf representing
those free blocks deleted.

The new topo info about block devices might be able to help optimize
the minimum size of a coalesced discard.

Greg
--
Greg Freemyer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
