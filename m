Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 1EE4A6B0072
	for <linux-mm@kvack.org>; Fri, 26 Oct 2012 09:43:29 -0400 (EDT)
Message-ID: <1351258992.16863.77.camel@twins>
Subject: Re: [PATCH 1/2] numa, mm: drop redundant check in
 do_huge_pmd_numa_page()
From: Peter Zijlstra <peterz@infradead.org>
Date: Fri, 26 Oct 2012 15:43:12 +0200
In-Reply-To: <20121026134129.GA31306@otc-wbsnb-06>
References: 
	<1351256077-1594-1-git-send-email-kirill.shutemov@linux.intel.com>
	 <1351256885.16863.62.camel@twins> <20121026134129.GA31306@otc-wbsnb-06>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: linux-mm@kvack.org, Will Deacon <will.deacon@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org

On Fri, 2012-10-26 at 16:41 +0300, Kirill A. Shutemov wrote:
> On Fri, Oct 26, 2012 at 03:08:05PM +0200, Peter Zijlstra wrote:
> > On Fri, 2012-10-26 at 15:54 +0300, Kirill A. Shutemov wrote:
> > > From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> > >=20
> > > We check if the pmd entry is the same as on pmd_trans_huge() in
> > > handle_mm_fault(). That's enough.
> > >=20
> > > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> >=20
> > Ah indeed, Will mentioned something like this on IRC as well, I hadn't
> > gotten around to looking at it -- now have, thanks!
> >=20
> > Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> >=20
> > That said, where in handle_mm_fault() do we wait for a split to
> > complete? We have a pmd_trans_huge() && !pmd_trans_splitting(), so a
> > fault on a currently splitting pmd will fall through.
> >=20
> > Is it the return from the fault on unlikely(pmd_trans_huge()) ?
>=20
> Yes, this code will catch it:
>=20
> 	/* if an huge pmd materialized from under us just retry later */
> 	if (unlikely(pmd_trans_huge(*pmd)))
> 		return 0;
>=20
> If the pmd is under splitting it's still a pmd_trans_huge().

OK, so then we simply keep taking the same fault until the split is
complete? Wouldn't it be better to wait for it instead of spin on
faults?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
