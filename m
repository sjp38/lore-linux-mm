Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id C1A826B0035
	for <linux-mm@kvack.org>; Wed, 22 Jan 2014 14:30:24 -0500 (EST)
Received: by mail-pb0-f53.google.com with SMTP id md12so811091pbc.12
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 11:30:24 -0800 (PST)
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTP id n8si10938774pax.334.2014.01.22.11.30.22
        for <linux-mm@kvack.org>;
        Wed, 22 Jan 2014 11:30:23 -0800 (PST)
Message-ID: <1390419019.2372.89.camel@dabdike.int.hansenpartnership.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] really large storage sectors - going
 beyond 4096 bytes
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Wed, 22 Jan 2014 11:30:19 -0800
In-Reply-To: <52E0106B.5010604@redhat.com>
References: <20131220093022.GV11295@suse.de> <52DF353D.6050300@redhat.com>
			 <20140122093435.GS4963@suse.de> <52DFD168.8080001@redhat.com>
			 <20140122143452.GW4963@suse.de> <52DFDCA6.1050204@redhat.com>
			 <20140122151913.GY4963@suse.de>
			 <1390410233.1198.7.camel@ret.masoncoding.com>
			 <1390411300.2372.33.camel@dabdike.int.hansenpartnership.com>
			 <1390413819.1198.20.camel@ret.masoncoding.com>
		 <1390414439.2372.53.camel@dabdike.int.hansenpartnership.com>
		 <52E00B28.3060609@redhat.com>
	 <1390415703.2372.62.camel@dabdike.int.hansenpartnership.com>
	 <52E0106B.5010604@redhat.com>
Content-Type: text/plain; charset="ISO-8859-15"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ric Wheeler <rwheeler@redhat.com>
Cc: "linux-ide@vger.kernel.org" <linux-ide@vger.kernel.org>, "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>, Chris Mason <clm@fb.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mgorman@suse.de" <mgorman@suse.de>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>

On Wed, 2014-01-22 at 13:39 -0500, Ric Wheeler wrote:
> On 01/22/2014 01:35 PM, James Bottomley wrote:
> > On Wed, 2014-01-22 at 13:17 -0500, Ric Wheeler wrote:
[...]
> >> I think that the key to having the file system work with larger
> >> sectors is to
> >> create them properly aligned and use the actual, native sector size as
> >> their FS
> >> block size. Which is pretty much back the original challenge.
> > Only if you think laying out stuff requires block size changes.  If a 4k
> > block filesystem's allocation algorithm tried to allocate on a 16k
> > boundary for instance, that gets us a lot of the performance without
> > needing a lot of alteration.
> 
> The key here is that we cannot assume that writes happen only during 
> allocation/append mode.

But that doesn't matter at all, does it?  If the file is sector aligned,
then the write is aligned.  If the write is short on a large block fs,
well we'd just have to do the RMW in the OS anyway ... is that any
better than doing it in the device?

> Unless the block size enforces it, we will have non-aligned, small
> block IO done 
> to allocated regions that won't get coalesced.

We always get that if it's the use pattern ... the question merely
becomes who bears the burden of RMW.

> > It's not even obvious that an ignorant 4k layout is going to be so
> > bad ... the RMW occurs only at the ends of the transfers, not in the
> > middle.  If we say 16k physical block and average 128k transfers,
> > probabalistically we misalign on 6 out of 31 sectors (or 19% of the
> > time).  We can make that better by increasing the transfer size (it
> > comes down to 10% for 256k transfers.
> 
> This really depends on the nature of the device. Some devices could
> produce very 
> erratic performance

Yes, we get that today with misaligned writes to the 4k devices.

>  or even (not today, but some day) reject the IO.

I really doubt this.  All 4k drives today do RMW ... I don't see that
changing any time soon.

> >> Teaching each and every file system to be aligned at the storage
> >> granularity/minimum IO size when that is larger than the physical
> >> sector size is
> >> harder I think.
> > But you're making assumptions about needing larger block sizes.  I'm
> > asking what can we do with what we currently have?  Increasing the
> > transfer size is a way of mitigating the problem with no FS support
> > whatever.  Adding alignment to the FS layout algorithm is another.  When
> > you've done both of those, I think you're already at the 99% aligned
> > case, which is "do we need to bother any more" territory for me.
> >
> 
> I would say no, we will eventually need larger file system block sizes.
> 
> Tuning and getting 95% (98%?) of the way there with alignment and IO
> scheduler 
> does help a lot. That is what we do today and it is important when
> looking for 
> high performance.
> 
> However, this is more of a short term work around for a lack of a
> fundamental 
> ability to do the right sized file system block for a specific class
> of device. 
> As such, not a crisis that must be solved today, but rather something
> that I 
> think is definitely worth looking at so we can figure this out over
> the next 
> year or so.

But this, I think, is the fundamental point for debate.  If we can pull
alignment and other tricks to solve 99% of the problem is there a need
for radical VM surgery?  Is there anything coming down the pipe in the
future that may move the devices ahead of the tricks?

James



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
