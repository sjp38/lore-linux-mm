Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 75F056B0032
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 05:45:18 -0400 (EDT)
Received: by mail-ee0-f42.google.com with SMTP id c4so4319155eek.15
        for <linux-mm@kvack.org>; Tue, 23 Jul 2013 02:45:16 -0700 (PDT)
Date: Tue, 23 Jul 2013 11:45:13 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: Performance regression from switching lock to rw-sem for
 anon-vma tree
Message-ID: <20130723094513.GA24522@gmail.com>
References: <1372292701.22432.152.camel@schen9-DESK>
 <20130627083651.GA3730@gmail.com>
 <1372366385.22432.185.camel@schen9-DESK>
 <1372375873.22432.200.camel@schen9-DESK>
 <20130628093809.GB29205@gmail.com>
 <1372453461.22432.216.camel@schen9-DESK>
 <20130629071245.GA5084@gmail.com>
 <1372710497.22432.224.camel@schen9-DESK>
 <20130702064538.GB3143@gmail.com>
 <1373997195.22432.297.camel@schen9-DESK>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1373997195.22432.297.camel@schen9-DESK>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, "Shi, Alex" <alex.shi@intel.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>


* Tim Chen <tim.c.chen@linux.intel.com> wrote:

> Ingo,
> 
> I tried MCS locking to order the writers but it didn't make much 
> difference on my particular workload. After thinking about this some 
> more, a likely explanation of the performance difference between mutex 
> and rwsem performance is:
> 
> 1) Jobs acquiring mutex put itself on the wait list only after 
> optimistic spinning.  That's only 2% of the time on my test workload so 
> they access the wait list rarely.
> 
> 2) Jobs acquiring rw-sem for write *always* put itself on the wait list 
> first before trying lock stealing and optimistic spinning.  This creates 
> a bottleneck at the wait list, and also more cache bouncing.

Indeed ...

> One possible optimization is to delay putting the writer on the wait 
> list till after optimistic spinning, but we may need to keep track of 
> the number of writers waiting.  We could add a WAIT_BIAS to count for 
> each write waiter and remove the WAIT_BIAS each time a writer job 
> completes.  This is tricky as I'm changing the semantics of the count 
> field and likely will require a number of changes to rwsem code.  Your 
> thoughts on a better way to do this?

Why not just try the delayed addition approach first? The spinning is time 
limited AFAICS, so we don't _have to_ recognize those as writers per se, 
only if the spinning fails and it wants to go on the waitlist. Am I 
missing something?

It will change patterns, it might even change the fairness balance - but 
is a legit change otherwise, especially if it helps performance.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
