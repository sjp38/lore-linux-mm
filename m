Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id EF9696B008A
	for <linux-mm@kvack.org>; Tue, 11 Dec 2012 19:34:32 -0500 (EST)
MIME-Version: 1.0
Message-ID: <d4ab3d29-f29d-4236-bbba-d93b633a18e7@default>
Date: Tue, 11 Dec 2012 16:34:24 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: zram /proc/swaps accounting weirdness
References: <c8728036-07da-49ce-b4cb-c3d800790b53@default>
 <20121211062601.GD22698@blaptop>
In-Reply-To: <20121211062601.GD22698@blaptop>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Nitin Gupta <ngupta@vflare.org>, Luigi Semenzato <semenzato@google.com>, linux-mm@kvack.org

> From: Minchan Kim [mailto:minchan@kernel.org]
> Subject: Re: zram /proc/swaps accounting weirdness
>=20
> Hi Dan,
>=20
> On Fri, Dec 07, 2012 at 03:57:08PM -0800, Dan Magenheimer wrote:
> > While playing around with zcache+zram (see separate thread),
> > I was watching stats with "watch -d".
> >
> > It appears from the code that /sys/block/num_writes only
> > increases, never decreases.  In my test, num_writes got up
>=20
> Never decreasement is natural.

Agreed.
=20
> > to 1863.  /sys/block/disksize is 104857600.
> >
> > I have two swap disks, one zram (pri=3D60), one real (pri=3D-1),
> > and as a I watched /proc/swaps, the "Used" field grew rapidly
> > and reached the Size (102396k) of the zram swap, and then
> > the second swap disk (a physical disk partition) started being
> > used.  Then for awhile, the Used field for both swap devices
> > was changing (up and down).
> >
> > Can you explain how this could happen if num_writes never
> > exceeded 1863?  This may be harmless in the case where
>=20
> Odd.
> I tried to reproduce it with zram and real swap device without
> zcache but failed. Does the problem happen only if enabling zcache
> together?

I also cannot reproduce it with only zram, without zcache.
I can only reproduce with zcache+zram.  Since zcache will
only "fall through" to zram when the frontswap_store() call
in swap_writepage() fails, I wonder if in both cases swap_writepage()
is being called in large (e.g. SWAPFILE_CLUSTER-sized) blocks
of pages?  When zram-only, the entire block of pages always gets
sent to zram, but with zcache only a small randomly-positioned
fraction fail frontswap_store(), but the SWAPFILE_CLUSTER-sized
blocks have already been pre-reserved on the swap device and
become only partially-filled?

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
