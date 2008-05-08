Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m48FpQob021428
	for <linux-mm@kvack.org>; Thu, 8 May 2008 11:51:26 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m48FpQBo074920
	for <linux-mm@kvack.org>; Thu, 8 May 2008 09:51:26 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m48FpPNN000865
	for <linux-mm@kvack.org>; Thu, 8 May 2008 09:51:25 -0600
Subject: Re: [PATCH] x86: fix PAE pmd_bad bootup warning
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20080508151145.GG12654@escobedo.amd.com>
References: <b6a2187b0805051806v25fa1272xb08e0b70b9c3408@mail.gmail.com>
	 <20080506124946.GA2146@elte.hu>
	 <Pine.LNX.4.64.0805061435510.32567@blonde.site>
	 <alpine.LFD.1.10.0805061138580.32269@woody.linux-foundation.org>
	 <Pine.LNX.4.64.0805062043580.11647@blonde.site>
	 <20080506202201.GB12654@escobedo.amd.com>
	 <1210106579.4747.51.camel@nimitz.home.sr71.net>
	 <20080508143453.GE12654@escobedo.amd.com>
	 <1210258350.7905.45.camel@nimitz.home.sr71.net>
	 <20080508151145.GG12654@escobedo.amd.com>
Content-Type: text/plain
Date: Thu, 08 May 2008 08:51:22 -0700
Message-Id: <1210261882.7905.49.camel@nimitz.home.sr71.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hans Rosenfeld <hans.rosenfeld@amd.com>
Cc: Hugh Dickins <hugh@veritas.com>, Ingo Molnar <mingo@elte.hu>, Jeff Chua <jeff.chua.linux@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Gabriel C <nix.or.die@googlemail.com>, Arjan van de Ven <arjan@linux.intel.com>, Nishanth Aravamudan <nacc@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2008-05-08 at 17:11 +0200, Hans Rosenfeld wrote:
> 
> On Thu, May 08, 2008 at 07:52:30AM -0700, Dave Hansen wrote:
> > On Thu, 2008-05-08 at 16:34 +0200, Hans Rosenfeld wrote:
> > > The huge page is leaked only when the
> > > /proc/self/pagemap entry for the huge page is read.
> > 
> > Well, that's an interesting data point! :)
> > 
> > Are you running any of your /proc/<pid>/pagemap patches?
> 
> No additional patches. The problem already existed before we agreed on
> the change to the pagemap code to just include the page size in the
> values returned, and not doing any special huge page handling. I suspect
> the page walking code used by /proc/pid/pagemap is doing something nasty
> when it sees a huge page as it doesn't know how to handle it.

Is there anything in your dmesg?

static int walk_pmd_range(pud_t *pud, unsigned long addr, unsigned long end,
                          const struct mm_walk *walk, void *private)
{
        pmd_t *pmd;
        unsigned long next;
        int err = 0;

        pmd = pmd_offset(pud, addr);
        do {
                next = pmd_addr_end(addr, end);
                if (pmd_none_or_clear_bad(pmd)) {
                        if (walk->pte_hole)
                                err = walk->pte_hole(addr, next, private);
                        if (err)
                                break;
                        continue;


There was a discussion on LKML in the last couple of days about
pmd_bad() triggering on huge pages.  Perhaps we're clearing the mapping
with the pmd_none_or_clear_bad(), and *THAT* is leaking the page.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
