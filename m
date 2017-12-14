Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id DCB746B0038
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 19:33:21 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id p190so1871918wmd.0
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 16:33:21 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r1sor2025987edc.30.2017.12.13.16.33.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Dec 2017 16:33:20 -0800 (PST)
Date: Thu, 14 Dec 2017 03:33:18 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv4 09/12] x86/mm: Provide pmdp_establish() helper
Message-ID: <20171214003318.xli42qgybplln754@node.shutemov.name>
References: <20171213105756.69879-1-kirill.shutemov@linux.intel.com>
 <20171213105756.69879-10-kirill.shutemov@linux.intel.com>
 <20171213160951.249071f2aecdccb38b6bb646@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171213160951.249071f2aecdccb38b6bb646@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>

On Wed, Dec 13, 2017 at 04:09:51PM -0800, Andrew Morton wrote:
> > @@ -181,6 +182,40 @@ static inline pmd_t native_pmdp_get_and_clear(pmd_t *pmdp)
> >  #define native_pmdp_get_and_clear(xp) native_local_pmdp_get_and_clear(xp)
> >  #endif
> >  
> > +#ifndef pmdp_establish
> > +#define pmdp_establish pmdp_establish
> > +static inline pmd_t pmdp_establish(struct vm_area_struct *vma,
> > +		unsigned long address, pmd_t *pmdp, pmd_t pmd)
> > +{
> > +	pmd_t old;
> > +
> > +	/*
> > +	 * If pmd has present bit cleared we can get away without expensive
> > +	 * cmpxchg64: we can update pmdp half-by-half without racing with
> > +	 * anybody.
> > +	 */
> > +	if (!(pmd_val(pmd) & _PAGE_PRESENT)) {
> > +		union split_pmd old, new, *ptr;
> > +
> > +		ptr = (union split_pmd *)pmdp;
> > +
> > +		new.pmd = pmd;
> > +
> > +		/* xchg acts as a barrier before setting of the high bits */
> > +		old.pmd_low = xchg(&ptr->pmd_low, new.pmd_low);
> > +		old.pmd_high = ptr->pmd_high;
> > +		ptr->pmd_high = new.pmd_high;
> > +		return old.pmd;
> > +	}
> > +
> > +	{
> > +		old = *pmdp;
> > +	} while (cmpxchg64(&pmdp->pmd, old.pmd, pmd.pmd) != old.pmd);
> 
> um, what happened here?

Ouch.. Yeah, we need 'do' here. :-/

Apparently, it's a valid C code that would run the body once and it worked for
me because I didn't hit the race condition.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
