Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 19D036B0047
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 13:42:25 -0500 (EST)
Subject: Re: [RFC] nfs: use 4*rsize readahead size
From: Trond Myklebust <Trond.Myklebust@netapp.com>
In-Reply-To: <19341.19446.356359.99958@stoffel.org>
References: <20100224024100.GA17048@localhost>
	 <20100224032934.GF16175@discord.disaster>
	 <20100224041822.GB27459@localhost>
	 <20100224052215.GH16175@discord.disaster> <20100224061247.GA8421@localhost>
	 <20100224073940.GJ16175@discord.disaster> <20100226074916.GA8545@localhost>
	 <20100302031021.GA14267@localhost>
	 <1267539563.3099.43.camel@localhost.localdomain>
	 <19341.19446.356359.99958@stoffel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Tue, 02 Mar 2010 13:42:19 -0500
Message-ID: <1267555339.3099.127.camel@localhost.localdomain>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: John Stoffel <john@stoffel.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Dave Chinner <david@fromorbit.com>, "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2010-03-02 at 12:33 -0500, John Stoffel wrote:=20
> >>>>> "Trond" =3D=3D Trond Myklebust <Trond.Myklebust@netapp.com> writes:
>=20
> Trond> On Tue, 2010-03-02 at 11:10 +0800, Wu Fengguang wrote:=20
> >> Dave,
> >>=20
> >> Here is one more test on a big ext4 disk file:
> >>=20
> >> 16k	39.7 MB/s
> >> 32k	54.3 MB/s
> >> 64k	63.6 MB/s
> >> 128k	72.6 MB/s
> >> 256k	71.7 MB/s
> >> rsize =3D=3D> 512k  71.7 MB/s
> >> 1024k	72.2 MB/s
> >> 2048k	71.0 MB/s
> >> 4096k	73.0 MB/s
> >> 8192k	74.3 MB/s
> >> 16384k	74.5 MB/s
> >>=20
> >> It shows that >=3D128k client side readahead is enough for single disk
> >> case :) As for RAID configurations, I guess big server side readahead
> >> should be enough.
>=20
> Trond> There are lots of people who would like to use NFS on their
> Trond> company WAN, where you typically have high bandwidths (up to
> Trond> 10GigE), but often a high latency too (due to geographical
> Trond> dispersion).  My ping latency from here to a typical server in
> Trond> NetApp's Bangalore office is ~ 312ms. I read your test results
> Trond> with 10ms delays, but have you tested with higher than that?
>=20
> If you have that high a latency, the low level TCP protocol is going
> to kill your performance before you get to the NFS level.  You really
> need to open up the TCP window size at that point.  And it only gets
> worse as the bandwidth goes up too. =20

Yes. You need to open the TCP window in addition to reading ahead
aggressively.

> There's no good solution, because while you can get good throughput at
> points, latency is going to suffer no matter what.

It depends upon your workload. Sequential read and write should still be
doable if you have aggressive readahead and open up for lots of parallel
write RPCs.

Cheers
  Trond

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
