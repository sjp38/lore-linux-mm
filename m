Date: Tue, 31 Oct 2006 22:05:40 +1100
From: 'David Gibson' <david@gibson.dropbear.id.au>
Subject: Re: [RFC] reduce hugetlb_instantiation_mutex usage
Message-ID: <20061031110540.GA14172@localhost.localdomain>
References: <20061031031703.GA7220@localhost.localdomain> <000001c6fcab$8fe56320$5181030a@amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <000001c6fcab$8fe56320$5181030a@amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: g@ozlabs.org, Andrew Morton <akpm@osdl.org>, 'Christoph Lameter' <christoph@schroedinger.engr.sgi.com>, Hugh Dickins <hugh@veritas.com>, bill.irwin@oracle.com, Adam Litke <agl@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Oct 30, 2006 at 09:15:20PM -0800, Chen, Kenneth W wrote:
> David Gibson wrote on Monday, October 30, 2006 7:17 PM
> > > I got side tracked on to the radix-tree stuff.  The comments in
> > > hugetlb_no_page() make me wonder whether we have a race issue on
> > > private mapping:
> > > 
> > >         /*
> > >          * Use page lock to guard against racing truncation
> > >          * before we get page_table_lock.
> > >          */
> > > 
> > > Private mapping won't use radix tree during instantiation.  What protects
> > > racy truncate against fault in that scenario?  Don't we have a bug here?
> > 
> > Not at present, because the hugetlb_instantiation_mutex protects both
> > fault paths.  But with Andrew's patch as it stands, yes.  As I said in
> > a previous email.  The libhugetlbfs testsuite now has a testcase for
> > the MAP_PRIVATE as well as the MAP_SHARED version of the race.
> 
> 
> That's not what I'm saying.  I should've said I'm off topic and not talking
> about parallel fault for private mapping.
> 
> Instead, I'm asking how private mapping protect race between file truncation
> and fault? For shared mapping, it is clear to me that we are using lock_page
> to protect file truncate with fault.  But I don't see that protection with
> private mapping in current upstream kernel.

Oh, ok.  I can't see how it matters in the PRIVATE case, given that
truncate() won't, and shouldn't, truncate privately mapped pages.

-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
