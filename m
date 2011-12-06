Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id EB62D6B0062
	for <linux-mm@kvack.org>; Tue,  6 Dec 2011 16:06:11 -0500 (EST)
Received: by vbbfn1 with SMTP id fn1so3537843vbb.14
        for <linux-mm@kvack.org>; Tue, 06 Dec 2011 13:06:10 -0800 (PST)
Date: Tue, 6 Dec 2011 13:06:07 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/3] slub: set a criteria for slub node partial adding
In-Reply-To: <1323076965.16790.670.camel@debian>
Message-ID: <alpine.DEB.2.00.1112061259210.28251@chino.kir.corp.google.com>
References: <1322814189-17318-1-git-send-email-alex.shi@intel.com> <alpine.DEB.2.00.1112020842280.10975@router.home> <1323076965.16790.670.camel@debian>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Alex,Shi" <alex.shi@intel.com>
Cc: Christoph Lameter <cl@linux.com>, "penberg@kernel.org" <penberg@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andi Kleen <ak@linux.intel.com>

On Mon, 5 Dec 2011, Alex,Shi wrote:

> Previous testing depends on 3.2-rc1, that show hackbench performance has
> no clear change, and netperf get some benefit. But seems after
> irqsafe_cpu_cmpxchg patch, the result has some change. I am collecting
> these results. 
> 

netperf will also degrade with this change on some machines, there's no 
clear heuristic that can be used to benefit all workloads when deciding 
where to add a partial slab into the list.  Cache hotness is great but 
your patch doesn't address situations where frees happen to a partial slab 
such that they may be entirely free (or at least below your 1:4 inuse to 
nr_objs threshold) at the time you want to deactivate the cpu slab.

I had a patchset that iterated the partial list and found the "most free" 
partial slab (and terminated prematurely if a threshold had been reached, 
much like yours) and selected that one, and it helped netperf 2-3% in my 
testing.  So I disagree with determining where to add a partial slab to 
the list at the time of free because it doesn't infer its state at the 
time of cpu slab deactivation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
