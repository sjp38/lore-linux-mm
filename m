Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id E0AA76B0036
	for <linux-mm@kvack.org>; Sat,  2 Aug 2014 14:13:39 -0400 (EDT)
Received: by mail-wg0-f49.google.com with SMTP id k14so5716934wgh.20
        for <linux-mm@kvack.org>; Sat, 02 Aug 2014 11:13:39 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id je7si13204727wic.5.2014.08.02.11.13.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 02 Aug 2014 11:13:37 -0700 (PDT)
Date: Sat, 2 Aug 2014 14:13:27 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 2/3] mm, oom: remove unnecessary check for NULL zonelist
Message-ID: <20140802181327.GL9952@cmpxchg.org>
References: <alpine.DEB.2.02.1407231814110.22326@chino.kir.corp.google.com>
 <alpine.DEB.2.02.1407231815090.22326@chino.kir.corp.google.com>
 <20140731152659.GB9952@cmpxchg.org>
 <alpine.DEB.2.02.1408010159500.4061@chino.kir.corp.google.com>
 <20140801133444.GH9952@cmpxchg.org>
 <alpine.DEB.2.02.1408011434330.11532@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1408011434330.11532@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Aug 01, 2014 at 02:42:19PM -0700, David Rientjes wrote:
> On Fri, 1 Aug 2014, Johannes Weiner wrote:
> 
> > > > out_of_memory() wants the zonelist that was used during allocation,
> > > > not just the random first node's zonelist that's simply picked to
> > > > serialize page fault OOM kills system-wide.
> > > > 
> > > > This would even change how panic_on_oom behaves for page fault OOMs
> > > > (in a completely unpredictable way) if we get CONSTRAINED_CPUSET.
> > > > 
> > > > This change makes no sense to me.
> > > > 
> > > 
> > > Allocations during fault will be constrained by the cpuset's mems, if we 
> > > are oom then why would we panic when panic_on_oom == 1?
> > 
> > Can you please address the concerns I raised?
> > 
> 
> I see one concern: that panic_on_oom == 1 will not trigger on pagefault 
> when constrained by cpusets.  To address that, I'll state that, since 
> cpuset-constrained allocations are the allocation context for pagefaults,
> panic_on_oom == 1 should not trigger on pagefault when constrained by 
> cpusets.

I expressed my concern pretty clearly above: out_of_memory() wants the
zonelist that was used during the failed allocation, you are passing a
non-sensical value in there that only happens to have the same type.

We simply don't have the right information at the end of the page
fault handler to respect constrained allocations.  Case in point:
nodemask is unset from pagefault_out_of_memory(), so we still kill
based on mempolicy even though check_panic_on_oom() says it wouldn't.

The code change is not an adequate solution for the problem we have
here and the changelog is an insult to everybody who wants to make
sense of this from the git history later on.

But the much bigger problem is that you continue to fail to address
even basic feedback and instead consistently derail discussions with
unrelated drivel and circular arguments.  As long as you continue to
do that I don't think we should be merging any of your patches.

> > And please describe user-visible changes in the changelog.
> > 
> 
> Ok, Andrew please annotate the changelog for 
> mm-oom-remove-unnecessary-check-for-null-zonelist.patch by including:
> 
> This also causes panic_on_oom == 1 to not panic the machine when the 
> pagefault is constrained by the mems of current's cpuset.  That behavior 
> agrees with the semantics of the sysctl in Documentation/sysctl/vm.txt.

Great, now we have a cleanup patch with the side-effect of changing
user-visible behavior and introducing non-sensical code semantics.

Nacked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
