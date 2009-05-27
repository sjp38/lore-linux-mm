Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 1987E6B004D
	for <linux-mm@kvack.org>; Wed, 27 May 2009 12:38:29 -0400 (EDT)
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n4RGbAfx003639
	for <linux-mm@kvack.org>; Wed, 27 May 2009 10:37:10 -0600
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n4RGd3B7210052
	for <linux-mm@kvack.org>; Wed, 27 May 2009 10:39:03 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n4RGd1KE018299
	for <linux-mm@kvack.org>; Wed, 27 May 2009 10:39:03 -0600
Date: Wed, 27 May 2009 17:38:58 +0100
From: Eric B Munson <ebmunson@us.ibm.com>
Subject: Re: [PATCH 1/2] x86: Ignore VM_LOCKED when determining if
	hugetlb-backed page tables can be shared or not
Message-ID: <20090527163858.GB5145@us.ibm.com>
References: <1243422749-6256-1-git-send-email-mel@csn.ul.ie> <1243422749-6256-2-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="uZ3hkaAS1mZxFaxD"
Content-Disposition: inline
In-Reply-To: <1243422749-6256-2-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, stable@kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, starlight@binnacle.cx, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, wli@movementarian.org
List-ID: <linux-mm.kvack.org>


--uZ3hkaAS1mZxFaxD
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, 27 May 2009, Mel Gorman wrote:

> On x86 and x86-64, it is possible that page tables are shared beween shar=
ed
> mappings backed by hugetlbfs. As part of this, page_table_shareable() che=
cks
> a pair of vma->vm_flags and they must match if they are to be shared. All
> VMA flags are taken into account, including VM_LOCKED.
>=20
> The problem is that VM_LOCKED is cleared on fork(). When a process with a
> shared memory segment forks() to exec() a helper, there will be shared VM=
As
> with different flags. The impact is that the shared segment is sometimes
> considered shareable and other times not, depending on what process is
> checking.
>=20
> What happens is that the segment page tables are being shared but the cou=
nt is
> inaccurate depending on the ordering of events. As the page tables are fr=
eed
> with put_page(), bad pmd's are found when some of the children exit. The
> hugepage counters also get corrupted and the Total and Free count will
> no longer match even when all the hugepage-backed regions are freed. This
> requires a reboot of the machine to "fix".
>=20
> This patch addresses the problem by comparing all flags except VM_LOCKED =
when
> deciding if pagetables should be shared or not for hugetlbfs-backed mappi=
ng.
>=20
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> Acked-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>

I tested this patch using 2.6.30-rc7 and the libhugetlbfs test suite on x86=
_64.
Everything looks good to me.

Acked-by: Eric B Munson <ebmunson@us.ibm.com>
Tested-by: Eric B Munson <ebmunson@us.ibm.com>

--uZ3hkaAS1mZxFaxD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkodbKIACgkQsnv9E83jkzogbQCgpQE/pgIniPcRRWpJbQTOGOQ4
MFYAn0Fv0NvaqT1BJ5bwn67fMf5y/iUC
=Ofoc
-----END PGP SIGNATURE-----

--uZ3hkaAS1mZxFaxD--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
