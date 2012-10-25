Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id E78C66B0070
	for <linux-mm@kvack.org>; Thu, 25 Oct 2012 08:20:09 -0400 (EDT)
Message-ID: <1351167554.23337.14.camel@twins>
Subject: Re: [patch for-3.7] mm, mempolicy: fix printing stack contents in
 numa_maps
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Thu, 25 Oct 2012 14:19:14 +0200
In-Reply-To: <alpine.DEB.2.00.1210241659260.22819@chino.kir.corp.google.com>
References: <20121008150949.GA15130@redhat.com>
	 <CAHGf_=pr1AYeWZhaC2MKN-XjiWB7=hs92V0sH-zVw3i00X-e=A@mail.gmail.com>
	 <alpine.DEB.2.00.1210152055150.5400@chino.kir.corp.google.com>
	 <CAHGf_=rLjQbtWQLDcbsaq5=zcZgjdveaOVdGtBgBwZFt78py4Q@mail.gmail.com>
	 <alpine.DEB.2.00.1210152306320.9480@chino.kir.corp.google.com>
	 <CAHGf_=pemT6rcbu=dBVSJE7GuGWwVFP+Wn-mwkcsZ_gBGfaOsg@mail.gmail.com>
	 <alpine.DEB.2.00.1210161657220.14014@chino.kir.corp.google.com>
	 <alpine.DEB.2.00.1210161714110.17278@chino.kir.corp.google.com>
	 <20121017040515.GA13505@redhat.com>
	 <alpine.DEB.2.00.1210162222100.26279@chino.kir.corp.google.com>
	 <CA+1xoqe74R6DX8Yx2dsp1MkaWkC1u6yAEd8eWEdiwi88pYdPaw@mail.gmail.com>
	 <alpine.DEB.2.00.1210241633290.22819@chino.kir.corp.google.com>
	 <CA+1xoqd6MEFP-eWdnWOrcz2EmE6tpd7UhgJyS8HjQ8qrGaMMMw@mail.gmail.com>
	 <alpine.DEB.2.00.1210241659260.22819@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Sasha Levin <levinsasha928@gmail.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, bhutchings@solarflare.com, Konstantin Khlebnikov <khlebnikov@openvz.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 2012-10-24 at 17:08 -0700, David Rientjes wrote:
> Ok, this looks the same but it's actually a different issue:=20
> mpol_misplaced(), which now only exists in linux-next and not in 3.7-rc2,=
=20
> calls get_vma_policy() which may take the shared policy mutex.  This=20
> happens while holding page_table_lock from do_huge_pmd_numa_page() but=
=20
> also from do_numa_page() while holding a spinlock on the ptl, which is=
=20
> coming from the sched/numa branch.
>=20
> Is there anyway that we can avoid changing the shared policy mutex back=
=20
> into a spinlock (it was converted in b22d127a39dd ["mempolicy: fix a race=
=20
> in shared_policy_replace()"])?
>=20
> Adding Peter, Rik, and Mel to the cc.=20

Urgh, crud I totally missed that.

So the problem is that we need to compute if the current page is placed
'right' while holding pte_lock in order to avoid multiple pte_lock
acquisitions on the 'fast' path.

I'll look into this in a bit, but one thing that comes to mind is having
both a spnilock and a mutex and require holding both for modification
while either one is sufficient for read.

That would allow sp_lookup() to use the spinlock, while insert and
replace can hold both.

Not sure it will work for this, need to stare at this code a little
more.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
