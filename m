Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 5C61E6B002B
	for <linux-mm@kvack.org>; Tue, 11 Dec 2012 20:12:27 -0500 (EST)
MIME-Version: 1.0
Message-ID: <9c96c9e7-4f6e-4e78-a207-009293c37b89@default>
Date: Tue, 11 Dec 2012 17:12:18 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: zram /proc/swaps accounting weirdness
References: <c8728036-07da-49ce-b4cb-c3d800790b53@default>
 <20121211062601.GD22698@blaptop>
 <d4ab3d29-f29d-4236-bbba-d93b633a18e7@default>
In-Reply-To: <d4ab3d29-f29d-4236-bbba-d93b633a18e7@default>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>, Minchan Kim <minchan@kernel.org>
Cc: Nitin Gupta <ngupta@vflare.org>, Luigi Semenzato <semenzato@google.com>, linux-mm@kvack.org, Bob Liu <lliubbo@gmail.com>

> From: Dan Magenheimer
> Subject: RE: zram /proc/swaps accounting weirdness
>=20
> > > Can you explain how this could happen if num_writes never
> > > exceeded 1863?  This may be harmless in the case where
> >
> > Odd.
> > I tried to reproduce it with zram and real swap device without
> > zcache but failed. Does the problem happen only if enabling zcache
> > together?
>=20
> I also cannot reproduce it with only zram, without zcache.
> I can only reproduce with zcache+zram.  Since zcache will
> only "fall through" to zram when the frontswap_store() call
> in swap_writepage() fails, I wonder if in both cases swap_writepage()
> is being called in large (e.g. SWAPFILE_CLUSTER-sized) blocks
> of pages?  When zram-only, the entire block of pages always gets
> sent to zram, but with zcache only a small randomly-positioned
> fraction fail frontswap_store(), but the SWAPFILE_CLUSTER-sized
> blocks have already been pre-reserved on the swap device and
> become only partially-filled?

Urk.  Never mind.  My bad.  When a swap page is compressed in
zcache, it gets accounted in the swap subsystem as an "inuse"
page for the backing swap device.  (Frontswap provides a
page-by-page "fronting store" for the swap device.)  That explains
why Used is so high for the "zram swap device" even though
zram has only compressed a fraction of the pages... the
remaining (much larger) number of pages have been compressed
by/in zcache.

Move along, there are no droids here. :-(

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
