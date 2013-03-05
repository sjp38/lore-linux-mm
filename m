Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id E7A046B0007
	for <linux-mm@kvack.org>; Mon,  4 Mar 2013 21:12:29 -0500 (EST)
Date: Tue, 5 Mar 2013 13:02:05 +1100
From: Paul Mackerras <paulus@samba.org>
Subject: Re: [PATCH -V1 09/24] powerpc: Decode the pte-lp-encoding bits
 correctly.
Message-ID: <20130305020205.GB2888@iris.ozlabs.ibm.com>
References: <1361865914-13911-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1361865914-13911-10-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <20130304054848.GE27523@drongo>
 <87y5e31jem.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <87y5e31jem.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Mon, Mar 04, 2013 at 05:11:53PM +0530, Aneesh Kumar K.V wrote:
> Paul Mackerras <paulus@samba.org> writes:
> >> +static inline int hpte_actual_psize(struct hash_pte *hptep, int psize)
> >> +{
> >> +	unsigned int mask;
> >> +	int i, penc, shift;
> >> +	/* Look at the 8 bit LP value */
> >> +	unsigned int lp = (hptep->r >> LP_SHIFT) & ((1 << LP_BITS) - 1);
> >> +
> >> +	penc = 0;
> >> +	for (i = 0; i < MMU_PAGE_COUNT; i++) {
> >> +		/* valid entries have a shift value */
> >> +		if (!mmu_psize_defs[i].shift)
> >> +			continue;
> >> +
> >> +		/* encoding bits per actual page size */
> >> +		shift = mmu_psize_defs[i].shift - 11;
> >> +		if (shift > 9)
> >> +			shift = 9;
> >> +		mask = (1 << shift) - 1;
> >> +		if ((lp & mask) == mmu_psize_defs[psize].penc[i])
> >> +			return i;
> >> +	}
> >> +	return -1;
> >> +}
> >
> > This doesn't look right to me.  First, it's not clear what the 11 and
> > 9 refer to, and I think the 9 should be LP_BITS (i.e. 8).  Secondly,
> > the mask for the comparison needs to depend on the actual page size
> > not the base page size.
> 
> That 11 should be 12.That depends on the fact that we have below mapping

And the 12 should be LP_SHIFT, shouldn't it?

>  rrrr rrrz 	a?JPY8KB
> 
> Yes, that 9 should be LP_BITs. 
> 
> We are generating mask based on actual page size above (variable i in
> the for loop).

OK, yes, you're right.

> > I don't see where in this function you set the penc[] elements for
> > invalid actual page sizes to -1.
> 
> We do the below
> 
> --- a/arch/powerpc/mm/hash_utils_64.c
> +++ b/arch/powerpc/mm/hash_utils_64.c
> @@ -125,7 +125,7 @@ static struct mmu_psize_def mmu_psize_defaults_old[] = {
>         [MMU_PAGE_4K] = {
>                 .shift  = 12,
>                 .sllp   = 0,
> -               .penc   = 0,
> +               .penc   = { [0 ... MMU_PAGE_COUNT - 1] = -1 },
>                 .avpnm  = 0,

Yes, which sets them for the entries you initialize, but not for the
others.  For example, the entry for MMU_PAGE_64K will initially be all
zeroes.  Then we find an entry in the ibm,segment-page-sizes property
for 64k pages, so we set mmu_psize_defs[MMU_PAGE_64K].shift to 16,
making that entry valid, but we never set any of the .penc[] entries
to -1, leading your other code to think that it can do (say) 1M pages
in a 64k segment using an encoding of 0.

Also, I noticed that the code in the if (base_idx < 0) statement is
wrong.  It needs to advance prop (and decrease size) by 2 * lpnum,
not just 2.

Paul.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
