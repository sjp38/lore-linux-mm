Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7856C6B00F0
	for <linux-mm@kvack.org>; Thu, 13 Jan 2011 17:08:09 -0500 (EST)
From: Satoru Moriya <satoru.moriya@hds.com>
Date: Thu, 13 Jan 2011 17:05:20 -0500
Subject: RE: [RFC][PATCH 0/2] Tunable watermark
Message-ID: <65795E11DBF1E645A09CEC7EAEE94B9C3B8DF647@USINDEVS02.corp.hds.com>
References: <65795E11DBF1E645A09CEC7EAEE94B9C3A30A295@USINDEVS02.corp.hds.com>
 <alpine.DEB.2.00.1101071416450.23577@chino.kir.corp.google.com>
 <AANLkTikQPXWkEJwN5fV2vnUS37Fs+GNzFXuFkKXcnzmu@mail.gmail.com>
 <alpine.DEB.2.00.1101071436220.23858@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1101071436220.23858@chino.kir.corp.google.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>, Ying Han <yinghan@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Randy Dunlap <rdunlap@xenotime.net>, "dle-develop@lists.sourceforge.net" <dle-develop@lists.sourceforge.net>, Seiji Aguchi <seiji.aguchi@hds.com>
List-ID: <linux-mm.kvack.org>

On 01/07/2011 05:39 PM, David Rientjes wrote:

> The semantics of any watermark is to trigger events to happen at a=20
> specific level, so they should be static with respect to a frame of=20
> reference (which in the VM case is the min watermark with respect to the=
=20
> size of the zone).  If you're going to adjust the min watermark, it's the=
n=20
> _mandatory_ to adjust the others to that frame of reference, you shouldn'=
t=20
> need to tune them independently.

Currently watermark[low,high] are set by following calculation (lowmem case=
).

watermark[low]  =3D watermark[min] * 1.25
watermark[high] =3D watermark[min] * 1.5

So the difference between watermarks are following:

min <-- min/4 --> low <-- min/4 --> high

I think the differences, "min/4", are too small in my case.
Of course I can make them bigger if I set min_free_kbytes to bigger value.=
=20
But it means kernel keeps more free memory for PF_MEMALLOC case unnecessari=
ly.

So I suggest changing coefficients(1.25, 1.5). Also it's better
to make them accessible from user space to tune in response to application
requirements.

> The problem that Satoru is reporting probably has nothing to do with the=
=20
> watermarks themselves but probably requires more aggressive action by=20
> kswapd and/or memory compaction.

More aggressive action may reduce the possibility of the problem reported.
But we can't avoid the problem completely because applications may
allocate/access faster than reclaiming/compaction.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
