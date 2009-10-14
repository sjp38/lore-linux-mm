Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 37EEE6B004F
	for <linux-mm@kvack.org>; Wed, 14 Oct 2009 14:35:04 -0400 (EDT)
From: Frans Pop <elendil@planet.nl>
Subject: Re: [Bug #14141] order 2 page allocation failures in iwlagn
Date: Wed, 14 Oct 2009 20:34:56 +0200
References: <3onW63eFtRF.A.xXH.oMTxKB@chimera> <200910141510.11059.elendil@planet.nl> <20091014154026.GC5027@csn.ul.ie>
In-Reply-To: <20091014154026.GC5027@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline
Message-Id: <200910142034.58826.elendil@planet.nl>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Kernel Testers List <kernel-testers@vger.kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Reinette Chatre <reinette.chatre@intel.com>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Mohamed Abbas <mohamed.abbas@intel.com>, "John W. Linville" <linville@tuxdriver.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Some initial results; all negative I'm afraid.

On Wednesday 14 October 2009, Mel Gorman wrote:
> This is what I found. The following were the possible commits that might
> be causing the problem.

> 56e49d2..f166777 -- reclaim
> =A0=A0=A0=A0=A0=A0=A0=A0I would have considered this strong candidates ex=
cept again, the
> =A0=A0=A0=A0=A0=A0=A0=A0last good commit happened after this point. If ot=
her obvious
> =A0=A0=A0=A0=A0=A0=A0=A0candidates don't crop up, it might be worth doubl=
e checking
> =A0=A0=A0=A0=A0=A0=A0=A0within this range, particularly commit 56e49d2 vm=
scan: evict
> =A0=A0=A0=A0=A0=A0=A0=A0use-once pages first as it is targeted at streami=
ng-IO workloads
> =A0=A0=A0=A0=A0=A0=A0=A0which would include your music workload.

Reverted 56e49d2 on top of .31.1; no change.

> 5c87ead..e9bb35d -- inactive ratio changes
> =A0=A0=A0=A0=A0=A0=A0=A0These patches should be harmless but just in case=
, please
> =A0=A0=A0=A0=A0=A0=A0=A0compare the output of
> =A0=A0=A0=A0=A0=A0=A0=A0# grep inactive_ratio /proc/zoneinfo
> =A0=A0=A0=A0=A0=A0=A0=A0on 2.6.30 and 2.6.31 and make sure the ratios are=
 the same.

The same for both (and for .32). DMA: 1; DMA32: 3

> =A0=A0=A0=A0=A0=A0=A0=A0Commit b70d94e altered how zonelists were selecte=
d during
> =A0=A0=A0=A0=A0=A0=A0=A0allocation. This was tested fairly heavily but if=
 the testing
> =A0=A0=A0=A0=A0=A0=A0=A0missed something, it would mean that some allocat=
ions are not
> =A0=A0=A0=A0=A0=A0=A0=A0using the zones they should be.

Reverted on top of .31.1; no change.

> =A0=A0=A0=A0=A0=A0=A0=A0Commit bc75d33 is totally harmless but it mentions
> =A0=A0=A0=A0=A0=A0=A0=A0min_free_kbytes. I checked on my machine to make =
sure
> =A0=A0=A0=A0=A0=A0=A0=A0min_free_kbytes was the same on both 2.6.30 and 2=
=2E6.31. Can you
> =A0=A0=A0=A0=A0=A0=A0=A0check that this is true for your machine? If min_=
free_kbytes
> =A0=A0=A0=A0=A0=A0=A0=A0decreased, it could explain GFP_ATOMIC failures.

Virtually identical. .30: 5704; .31/.32: 5711

> After this point, your analysis indicates that things are already broken
> but lets look at some of the candidates anyway. =A0Out of curiousity,
> was CONFIG_UNEVICTABLE_LRU unset in your .config for 2.6.30? I could
> only find your 2.6.31 .config. If it was, it might be worth reverting
> 6837765963f1723e80ca97b1fae660f3a60d77df and unsetting it in 2.6.31 and
> seeing what happens.

CONFIG_UNEVICTABLE_LRU was set and during bisections I've always accepted=20
the default, which was "y".

> Commit ee993b135ec75a93bd5c45e636bb210d2975159b altered how lumpy
> reclaim works but it should have been harmless. It does not cleanly
> revert but it's easy to manually revert.

Reverted on top of .31.1; no change.

I'll do some more digging in the 'akpm' merge.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
