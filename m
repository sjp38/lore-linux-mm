Received: from westrelay01.boulder.ibm.com (westrelay01.boulder.ibm.com [9.17.195.10])
	by e34.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j35Ivt5b119242
	for <linux-mm@kvack.org>; Tue, 5 Apr 2005 14:57:57 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by westrelay01.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j35IvtOq197762
	for <linux-mm@kvack.org>; Tue, 5 Apr 2005 12:57:55 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id j35IvtHe021971
	for <linux-mm@kvack.org>; Tue, 5 Apr 2005 12:57:55 -0600
Subject: Re: [PATCH 1/6] CKRM: Basic changes to the core kernel
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20050405182240.GE32645@chandralinux.beaverton.ibm.com>
References: <20050402031206.GB23284@chandralinux.beaverton.ibm.com>
	 <1112622313.7189.50.camel@localhost>
	 <20050405172519.GC32645@chandralinux.beaverton.ibm.com>
	 <1112723661.19430.71.camel@localhost>
	 <20050405182240.GE32645@chandralinux.beaverton.ibm.com>
Content-Type: text/plain
Date: Tue, 05 Apr 2005 11:57:50 -0700
Message-Id: <1112727471.19430.116.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chandra Seetharaman <sekharan@us.ibm.com>
Cc: ckrm-tech@lists.sourceforge.net, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2005-04-05 at 11:22 -0700, Chandra Seetharaman wrote:
> On Tue, Apr 05, 2005 at 10:54:20AM -0700, Dave Hansen wrote:
> > If you find a way to track things based on files, you could keep your
> > class pointers in the struct address_space, or even in the vma,
> > depending on what behavior you want.  You could keep anonymous stuff in
> > the anon_vma, just like the objrmap code.  
> 
> This is the first version of memory controller... Handling shared pages
> appropriately are in the plans.

Perhaps it's a better idea to wait until you have this more mature
version before submitting it.  It would be a shame to put all of this
per-page stuff in, only to rip it out.  Doing it that way isn't very
incremental, but I don't think they'd share too much code anyway.

> > ... if the class is behaving itself.  Somebody trying to take down a
> > machine, or a single badly-behaved or runaway app might not behave like
> > that.
> 
> There are checks in that code to make sure that a runaway app doesn't
> get the kernel into this code path often and bring down the system...
> instead the runaway app(its class) is penalised.

Penalized how?  Reducing the task's scheduler slices?  Can you point to
the code?

> > > Also, the loop is just to wakeup kswapd once..
> > > may be I can get rid of that and use pgdat_list directly.
> > 
> > I'd try to be a little more selective than a big for loop like that.
> 
> 'big' for loop ? in that code path ?

>  ckrm_class_limit_ok(struct ckrm_mem_res *cls)
>  {
...
> +       for (i = 0; i < MAX_NR_ZONES; i++)
> +               pg_total += cls->pg_total[i];

Sorry, I was confusing this with something equivalent to
for_each_node().

That brings another question, though.  How does this interact with NUMA?
The classes don't appear to track any per-node information.

> +       if (cls->pg_limit == CKRM_SHARE_DONTCARE) {
> +               struct ckrm_mem_res *parcls = ckrm_get_res_class(cls->parent,
> +                                       mem_rcbs.resid, struct ckrm_mem_res);
> +               ret = (parcls ? ckrm_class_limit_ok(parcls) : 0);
> +       } else
> +               ret = (pg_total <= cls->pg_limit);
> +
> +       return ret;

That looks suspiciously like recursion.  How is the recursion limited?

> > > > SGI's machines?  What about an 8-node x44[05]?  Why can't you call it
> > > > from interrupts?
> > > 
> > > I just wanted to avoid limit related failures in interrupt context, as it
> > > might lead to wierd problems.
> > 
> > You mean you didn't want to make your code robust enough to handle it?
> > Is there something fundamental keeping you from checking limits when in
> > an interrupt?
> 
> It is not the 'checking limit' part that I meant in my reply. It is the
> failure due to over limit(that the class is over its limit).
>
> This is my thinking: if a class is not configured properly, and is over
> its limit in interrupt context, we are going to fail the memory alloc,
> which 'could' lead to unwanted results in the system depending on how the
> interrupt handler treats the alloc failure ;)... 

No.

Interrupt handlers must use GFP_ATOMIC when allocating.  This
allocations are likely to fail, and the writers of the handlers know it.
Interrupts handlers must be equipped to deal with these, or it's a bug
in the interrupt handler.

Is there any other reason to have the !in_interrupt() part?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
