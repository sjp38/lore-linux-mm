Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m48GgQEf023341
	for <linux-mm@kvack.org>; Thu, 8 May 2008 12:42:26 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m48GgQeb099280
	for <linux-mm@kvack.org>; Thu, 8 May 2008 10:42:26 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m48GgPfJ020204
	for <linux-mm@kvack.org>; Thu, 8 May 2008 10:42:26 -0600
Subject: Re: [PATCH] x86: fix PAE pmd_bad bootup warning
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20080508161925.GH12654@escobedo.amd.com>
References: <20080506124946.GA2146@elte.hu>
	 <Pine.LNX.4.64.0805061435510.32567@blonde.site>
	 <alpine.LFD.1.10.0805061138580.32269@woody.linux-foundation.org>
	 <Pine.LNX.4.64.0805062043580.11647@blonde.site>
	 <20080506202201.GB12654@escobedo.amd.com>
	 <1210106579.4747.51.camel@nimitz.home.sr71.net>
	 <20080508143453.GE12654@escobedo.amd.com>
	 <1210258350.7905.45.camel@nimitz.home.sr71.net>
	 <20080508151145.GG12654@escobedo.amd.com>
	 <1210261882.7905.49.camel@nimitz.home.sr71.net>
	 <20080508161925.GH12654@escobedo.amd.com>
Content-Type: text/plain
Date: Thu, 08 May 2008 09:42:21 -0700
Message-Id: <1210264941.7905.54.camel@nimitz.home.sr71.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hans Rosenfeld <hans.rosenfeld@amd.com>
Cc: Hugh Dickins <hugh@veritas.com>, Ingo Molnar <mingo@elte.hu>, Jeff Chua <jeff.chua.linux@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Gabriel C <nix.or.die@googlemail.com>, Arjan van de Ven <arjan@linux.intel.com>, Nishanth Aravamudan <nacc@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2008-05-08 at 18:19 +0200, Hans Rosenfeld wrote:
> On Thu, May 08, 2008 at 08:51:22AM -0700, Dave Hansen wrote:
> > Is there anything in your dmesg?
> 
> mm/memory.c:127: bad pmd ffff810076801040(80000000720000e7).
> 
> > There was a discussion on LKML in the last couple of days about
> > pmd_bad() triggering on huge pages.  Perhaps we're clearing the mapping
> > with the pmd_none_or_clear_bad(), and *THAT* is leaking the page.
> 
> That makes sense. I remember that explicitly munmapping the huge page
> would still work, but it doesn't. I don't quite remember what I did back
> then to test this, but I probably made some mistake there that led me to
> some false conclusions.

I can't see how it would possibly work with the code that we have today,
so I guess it was just a false assumption.

static inline int pmd_none_or_clear_bad(pmd_t *pmd)
{
        if (pmd_none(*pmd))
                return 1;
        if (unlikely(pmd_bad(*pmd))) {
                pmd_clear_bad(pmd);
                return 1;
        }
        return 0;
}

void pmd_clear_bad(pmd_t *pmd)
{
        pmd_ERROR(*pmd);
        pmd_clear(pmd);
}

That pmd_clear() will simply zero out the pmd and leak the page.

Sounds like Linus had the right idea:

> I'd much rather have pdm_bad() etc fixed up instead, so that they do a 
> more proper test (not thinking that a PSE page is bad, since it clearly 
> isn't). And then, make them dependent on DEBUG_VM, because doing the 
> proper test will be more expensive.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
