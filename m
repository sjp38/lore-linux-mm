Subject: Re: [v4][PATCH 2/2] fix large pages in pagemap
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <20080611131108.61389481.akpm@linux-foundation.org>
References: <20080611180228.12987026@kernel>
	 <20080611180230.7459973B@kernel>
	 <20080611123724.3a79ea61.akpm@linux-foundation.org>
	 <1213213980.20045.116.camel@calx>
	 <20080611131108.61389481.akpm@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Date: Wed, 11 Jun 2008 15:21:15 -0500
Message-Id: <1213215675.20045.119.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: dave@linux.vnet.ibm.com, hans.rosenfeld@amd.com, linux-mm@kvack.org, hugh@veritas.com, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2008-06-11 at 13:11 -0700, Andrew Morton wrote:
> On Wed, 11 Jun 2008 14:53:00 -0500
> Matt Mackall <mpm@selenic.com> wrote:
> 
> > [adding Hugh to the cc:]
> > 
> > On Wed, 2008-06-11 at 12:37 -0700, Andrew Morton wrote:
> > > On Wed, 11 Jun 2008 11:02:31 -0700
> > > Dave Hansen <dave@linux.vnet.ibm.com> wrote:
> > > 
> > > > 
> > > > We were walking right into huge page areas in the pagemap
> > > > walker, and calling the pmds pmd_bad() and clearing them.
> > > > 
> > > > That leaked huge pages.  Bad.
> > > > 
> > > > This patch at least works around that for now.  It ignores
> > > > huge pages in the pagemap walker for the time being, and
> > > > won't leak those pages.
> > > > 
> > > 
> > > I don't get it.   Why can't we just stick a
> > > 
> > > 	if (pmd_huge(pmd))
> > > 		continue;
> > > 
> > > into pagemap_pte_range()?  Or something like that.
> > 
> > That's certainly what you'd hope to be able to do, yes.
> > 
> > If I recall the earlier discussion, some arches with huge pages can only
> > identify them via a VMA. Obviously, any arch with hardware that walks
> > our pagetables directly must be able to identify huge pages directly
> > from those tables, but I think PPC and a couple others that don't have
> > hardware TLB fill fail to store such a bit in the tables at all.
> 
> Really?  There already a couple of pmd_huge() tests in mm/memory.c and
> Rik's access_process_vm-device-memory-infrastructure.patch adds another
> one.

Quoting Hugh:

i>>?A pmd_huge(*pmd) test is tempting, but it only ever says "yes" on x86:
we've carefully left it undefined what happens to the pgd/pud/pmd/pte
hierarchy in the general arch case, once you're amongst hugepages.

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
