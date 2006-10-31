Date: Tue, 31 Oct 2006 14:17:04 +1100
From: 'David Gibson' <david@gibson.dropbear.id.au>
Subject: Re: [RFC] reduce hugetlb_instantiation_mutex usage
Message-ID: <20061031031703.GA7220@localhost.localdomain>
References: <20061027040626.GI11733@localhost.localdomain> <000001c6fc97$ecd8cbd0$ff0da8c0@amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <000001c6fc97$ecd8cbd0$ff0da8c0@amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>, g@ozlabs.org
Cc: Andrew Morton <akpm@osdl.org>, 'Christoph Lameter' <christoph@schroedinger.engr.sgi.com>, Hugh Dickins <hugh@veritas.com>, bill.irwin@oracle.com, Adam Litke <agl@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Oct 30, 2006 at 06:54:46PM -0800, Chen, Kenneth W wrote:
> David Gibson wrote on Thursday, October 26, 2006 9:06 PM
> > > Alternatively, we could put the page into pagecache whether or not the
> > > mapping is MAP_SHARED.  Then pull it out again prior to unlocking it if
> > > it's MAP_PRIVATE.  So we're using pagecache just as a way for the
> > > concurrent faulter to locate the page.
> > 
> > Hrm.. interesting if we can make it work.  I'd be worried about cases
> > with concurrent PRIVATE and SHARED pages on the same file offset.
> 
> I got side tracked on to the radix-tree stuff.  The comments in
> hugetlb_no_page() make me wonder whether we have a race issue on
> private mapping:
> 
>         /*
>          * Use page lock to guard against racing truncation
>          * before we get page_table_lock.
>          */
> 
> Private mapping won't use radix tree during instantiation.  What protects
> racy truncate against fault in that scenario?  Don't we have a bug here?

Not at present, because the hugetlb_instantiation_mutex protects both
fault paths.  But with Andrew's patch as it stands, yes.  As I said in
a previous email.  The libhugetlbfs testsuite now has a testcase for
the MAP_PRIVATE as well as the MAP_SHARED version of the race.

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
