Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id 214DF6B0055
	for <linux-mm@kvack.org>; Fri,  1 Aug 2014 17:42:22 -0400 (EDT)
Received: by mail-ig0-f172.google.com with SMTP id h15so2320539igd.5
        for <linux-mm@kvack.org>; Fri, 01 Aug 2014 14:42:21 -0700 (PDT)
Received: from mail-ie0-x22b.google.com (mail-ie0-x22b.google.com [2607:f8b0:4001:c03::22b])
        by mx.google.com with ESMTPS id fu3si25253240icb.49.2014.08.01.14.42.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 01 Aug 2014 14:42:21 -0700 (PDT)
Received: by mail-ie0-f171.google.com with SMTP id at1so6632277iec.2
        for <linux-mm@kvack.org>; Fri, 01 Aug 2014 14:42:21 -0700 (PDT)
Date: Fri, 1 Aug 2014 14:42:19 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 2/3] mm, oom: remove unnecessary check for NULL
 zonelist
In-Reply-To: <20140801133444.GH9952@cmpxchg.org>
Message-ID: <alpine.DEB.2.02.1408011434330.11532@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1407231814110.22326@chino.kir.corp.google.com> <alpine.DEB.2.02.1407231815090.22326@chino.kir.corp.google.com> <20140731152659.GB9952@cmpxchg.org> <alpine.DEB.2.02.1408010159500.4061@chino.kir.corp.google.com>
 <20140801133444.GH9952@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 1 Aug 2014, Johannes Weiner wrote:

> > > out_of_memory() wants the zonelist that was used during allocation,
> > > not just the random first node's zonelist that's simply picked to
> > > serialize page fault OOM kills system-wide.
> > > 
> > > This would even change how panic_on_oom behaves for page fault OOMs
> > > (in a completely unpredictable way) if we get CONSTRAINED_CPUSET.
> > > 
> > > This change makes no sense to me.
> > > 
> > 
> > Allocations during fault will be constrained by the cpuset's mems, if we 
> > are oom then why would we panic when panic_on_oom == 1?
> 
> Can you please address the concerns I raised?
> 

I see one concern: that panic_on_oom == 1 will not trigger on pagefault 
when constrained by cpusets.  To address that, I'll state that, since 
cpuset-constrained allocations are the allocation context for pagefaults,
panic_on_oom == 1 should not trigger on pagefault when constrained by 
cpusets.

> And please describe user-visible changes in the changelog.
> 

Ok, Andrew please annotate the changelog for 
mm-oom-remove-unnecessary-check-for-null-zonelist.patch by including:

This also causes panic_on_oom == 1 to not panic the machine when the 
pagefault is constrained by the mems of current's cpuset.  That behavior 
agrees with the semantics of the sysctl in Documentation/sysctl/vm.txt.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
