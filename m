Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 27CE46B004A
	for <linux-mm@kvack.org>; Sun,  8 Apr 2012 09:50:27 -0400 (EDT)
From: Alex Lemberg <Alex.Lemberg@sandisk.com>
Date: Sun, 8 Apr 2012 06:50:16 -0700
Subject: RE: swap on eMMC and other flash
Message-ID: <D70D75BB1A02CA42A3E28AA542D282303A0661B561@MILMBMIPV3.sdcorp.global.sandisk.com>
References: <201203301744.16762.arnd@arndb.de>
 <201204021145.43222.arnd@arndb.de>
 <alpine.LSU.2.00.1204020734560.1847@eggly.anvils>
 <201204021455.25029.arnd@arndb.de>
In-Reply-To: <201204021455.25029.arnd@arndb.de>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: "linaro-kernel@lists.linaro.org" <linaro-kernel@lists.linaro.org>, Rik van Riel <riel@redhat.com>, "linux-mmc@vger.kernel.org" <linux-mmc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Luca Porzio (lporzio)" <lporzio@micron.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Hyojin Jeong <syr.jeong@samsung.com>, "kernel-team@android.com" <kernel-team@android.com>, Yejin Moon <yejin.moon@samsung.com>, Hugh Dickins <hughd@google.com>, Yaniv Iarovici <Yaniv.Iarovici@sandisk.com>

Hi Arnd,

Regarding time to issue discard/TRIM commands:
It would be advised to issue the discard command immediately after deleting=
/freeing a SWAP cluster (i.e. as soon as it becomes available).

Regarding SWAP page size:
Working with as large as SWAP pages as possible would be recommended (prefe=
rably 64KB). Also, writing in a sequential manner as much as possible while=
 swapping large quantities of data is also advisable.

SWAP pages and corresponding transactions should be aligned to the SWAP pag=
e size (i.e. 64KB above), the alignment should correspond to the physical s=
torage "LBA 0", i.e. to the first LBA of the storage device (and not to a l=
ogical/physical partition).

Thanks,
Alex

> -----Original Message-----
> From: Arnd Bergmann [mailto:arnd@arndb.de]
> Sent: Monday, April 02, 2012 5:55 PM
> To: Hugh Dickins
> Cc: linaro-kernel@lists.linaro.org; Rik van Riel; linux-
> mmc@vger.kernel.org; Alex Lemberg; linux-kernel@vger.kernel.org; Luca
> Porzio (lporzio); linux-mm@kvack.org; Hyojin Jeong; kernel-
> team@android.com; Yejin Moon
> Subject: Re: swap on eMMC and other flash
>
> On Monday 02 April 2012, Hugh Dickins wrote:
> > On Mon, 2 Apr 2012, Arnd Bergmann wrote:
> > >
> > > Another option would be batched discard as we do it for file
> systems:
> > > occasionally stop writing to swap space and scanning for areas that
> > > have become available since the last discard, then send discard
> > > commands for those.
> >
> > I'm not sure whether you've missed "swapon --discard", which switches
> > on discard_swap_cluster() just before we allocate from a new cluster;
> > or whether you're musing that it's no use to you because you want to
> > repurpose the swap cluster to match erase block: I'm mentioning it in
> > case you missed that it's already there (but few use it, since even
> > done at that scale it's often more trouble than it's worth).
>
> I actually argued that discard_swap_cluster is exactly the right thing
> to do, especially when clusters match erase blocks on the less capable
> devices like SD cards.
>
> Luca was arguing that on some hardware there is no point in ever
> submitting a discard just before we start reusing space, because
> at that point it the hardware already discards the old data by
> overwriting the logical addresses with new blocks, while
> issuing a discard on all blocks as soon as they become available
> would make a bigger difference. I would be interested in hearing
> from Hyojin Jeong and Alex Lemberg what they think is the best
> time to issue a discard, because they would know about other hardware
> than Luca.
>
>       Arnd

PLEASE NOTE: The information contained in this electronic mail message is i=
ntended only for the use of the designated recipient(s) named above. If the=
 reader of this message is not the intended recipient, you are hereby notif=
ied that you have received this message in error and that any review, disse=
mination, distribution, or copying of this message is strictly prohibited. =
If you have received this communication in error, please notify the sender =
by telephone or e-mail (as shown above) immediately and destroy any and all=
 copies of this message in your possession (whether hard copies or electron=
ically stored copies).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
