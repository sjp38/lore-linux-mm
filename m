Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 64CA86B02B0
	for <linux-mm@kvack.org>; Fri, 23 Jul 2010 17:12:35 -0400 (EDT)
Received: by bwz9 with SMTP id 9so2219565bwz.14
        for <linux-mm@kvack.org>; Fri, 23 Jul 2010 14:12:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1007231244440.5317@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1007201936210.8728@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1007201939430.8728@chino.kir.corp.google.com>
	<20100723123618.3b2b8824.akpm@linux-foundation.org>
	<alpine.DEB.2.00.1007231244440.5317@chino.kir.corp.google.com>
Date: Sat, 24 Jul 2010 00:12:32 +0300
Message-ID: <AANLkTikESJCnC2yYJ8dLFEF+2P7azfiqv2-sSr0D51Y9@mail.gmail.com>
Subject: Re: [patch 3/6] fs: remove dependency on __GFP_NOFAIL
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Jens Axboe <axboe@kernel.dk>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 23, 2010 at 10:51 PM, David Rientjes <rientjes@google.com> wrot=
e:
> On Fri, 23 Jul 2010, Andrew Morton wrote:
>
>> > The kmalloc() in bio_integrity_prep() is failable, so remove __GFP_NOF=
AIL
>> > from its mask.
>> >
>> > Cc: Jens Axboe <jens.axboe@oracle.com>
>> > Signed-off-by: David Rientjes <rientjes@google.com>
>> > ---
>> > =A0fs/bio-integrity.c | =A0 =A02 +-
>> > =A01 files changed, 1 insertions(+), 1 deletions(-)
>> >
>> > diff --git a/fs/bio-integrity.c b/fs/bio-integrity.c
>> > --- a/fs/bio-integrity.c
>> > +++ b/fs/bio-integrity.c
>> > @@ -413,7 +413,7 @@ int bio_integrity_prep(struct bio *bio)
>> >
>> > =A0 =A0 /* Allocate kernel buffer for protection data */
>> > =A0 =A0 len =3D sectors * blk_integrity_tuple_size(bi);
>> > - =A0 buf =3D kmalloc(len, GFP_NOIO | __GFP_NOFAIL | q->bounce_gfp);
>> > + =A0 buf =3D kmalloc(len, GFP_NOIO | q->bounce_gfp);
>> > =A0 =A0 if (unlikely(buf =3D=3D NULL)) {
>> > =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "could not allocate integrity =
buffer\n");
>> > =A0 =A0 =A0 =A0 =A0 =A0 return -EIO;
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ^^^ =A0what?
>
> Right, I'm not sure why that decision was made, but it looks like it can
> be changed over to -ENOMEM without harming anything. =A0I'm concerned tha=
t
> the printk will spam the kernel log endlessly, though, if we're really oo=
m
> and GFP_NOIO has no hope of freeing memory. =A0This code has never been
> active, so I'd like to wait for some feedback from Al and Jens (now with =
a
> corrected email address, jens.axboe@oracle.com bounced) to see if we want
> to return -ENOMEM, if the printk is really necessary, and if it would be
> better to just convert this to a loop with a congestion_wait() instead of
> returning from bio_integrity_prep().

Btw, you probably want __GFP_NOWARN here if you expect the allocation
to fail under normal conditions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
