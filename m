Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id E6BFC6B0035
	for <linux-mm@kvack.org>; Mon,  4 Aug 2014 20:18:45 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id g10so236195pdj.40
        for <linux-mm@kvack.org>; Mon, 04 Aug 2014 17:18:45 -0700 (PDT)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id bq15si33061pdb.128.2014.08.04.17.18.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 04 Aug 2014 17:18:44 -0700 (PDT)
Received: by mail-pa0-f51.google.com with SMTP id ey11so256549pad.10
        for <linux-mm@kvack.org>; Mon, 04 Aug 2014 17:18:44 -0700 (PDT)
Date: Mon, 4 Aug 2014 17:18:42 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 2/3] mm, oom: remove unnecessary check for NULL
 zonelist
In-Reply-To: <20140802181327.GL9952@cmpxchg.org>
Message-ID: <alpine.DEB.2.02.1408041710070.23228@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1407231814110.22326@chino.kir.corp.google.com> <alpine.DEB.2.02.1407231815090.22326@chino.kir.corp.google.com> <20140731152659.GB9952@cmpxchg.org> <alpine.DEB.2.02.1408010159500.4061@chino.kir.corp.google.com>
 <20140801133444.GH9952@cmpxchg.org> <alpine.DEB.2.02.1408011434330.11532@chino.kir.corp.google.com> <20140802181327.GL9952@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, 2 Aug 2014, Johannes Weiner wrote:

> > I see one concern: that panic_on_oom == 1 will not trigger on pagefault 
> > when constrained by cpusets.  To address that, I'll state that, since 
> > cpuset-constrained allocations are the allocation context for pagefaults,
> > panic_on_oom == 1 should not trigger on pagefault when constrained by 
> > cpusets.
> 
> I expressed my concern pretty clearly above: out_of_memory() wants the
> zonelist that was used during the failed allocation, you are passing a
> non-sensical value in there that only happens to have the same type.
> 

It's certainly meaningful, the particular zonelist chosen isn't important 
because we don't care about the ordering and pagefaults are not going to 
be using __GFP_THISNODE.  In this context, we only need to pass a zonelist 
that includes all zones because constrained_alloc() tests if the 
allocation is cpuset-constrained based on the gfp flags.  We'll get 
CONSTRAINT_CPUSET in that case.

This is important because the behavior of panic_on_oom differs, as you 
pointed out, depending on the constraint.  pagefault_out_of_memory(), with 
my patch, will always get CONSTRAINT_CPUSET when needed and 
check_panic_on_oom() will behave correctly now for cpusets.

> We simply don't have the right information at the end of the page
> fault handler to respect constrained allocations.  Case in point:
> nodemask is unset from pagefault_out_of_memory(), so we still kill
> based on mempolicy even though check_panic_on_oom() says it wouldn't.
> 

That is, in fact, the only last bit of information we need in the 
pagefault handler to make correct decisions.  It's important, too, since 
if the vma of the faulting address is constrained by a mempolicy, we want 
to avoid needless killing a process that has a mempolicy with a disjoint 
set of nodes.

> The code change is not an adequate solution for the problem we have
> here and the changelog is an insult to everybody who wants to make
> sense of this from the git history later on.
> 

We can also address mempolicies by modifying the page fault handler and 
passing the vma and faulting address to make the correct panic_on_oom 
decisions but also filter processes that have mempolicies that consist 
solely of a disjoint set of nodes.  I'll post that patch series as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
