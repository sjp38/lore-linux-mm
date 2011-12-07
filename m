Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id A1F166B0096
	for <linux-mm@kvack.org>; Tue,  6 Dec 2011 23:59:27 -0500 (EST)
Subject: Re: [PATCH 1/3] slub: set a criteria for slub node partial adding
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <alpine.DEB.2.00.1112061259210.28251@chino.kir.corp.google.com>
References: <1322814189-17318-1-git-send-email-alex.shi@intel.com>
	 <alpine.DEB.2.00.1112020842280.10975@router.home>
	 <1323076965.16790.670.camel@debian>
	 <alpine.DEB.2.00.1112061259210.28251@chino.kir.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 07 Dec 2011 13:11:13 +0800
Message-ID: <1323234673.22361.372.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: "Shi, Alex" <alex.shi@intel.com>, Christoph Lameter <cl@linux.com>, "penberg@kernel.org" <penberg@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andi Kleen <ak@linux.intel.com>

On Wed, 2011-12-07 at 05:06 +0800, David Rientjes wrote:
> On Mon, 5 Dec 2011, Alex,Shi wrote:
> 
> > Previous testing depends on 3.2-rc1, that show hackbench performance has
> > no clear change, and netperf get some benefit. But seems after
> > irqsafe_cpu_cmpxchg patch, the result has some change. I am collecting
> > these results. 
> > 
> 
> netperf will also degrade with this change on some machines, there's no 
> clear heuristic that can be used to benefit all workloads when deciding 
> where to add a partial slab into the list.  Cache hotness is great but 
> your patch doesn't address situations where frees happen to a partial slab 
> such that they may be entirely free (or at least below your 1:4 inuse to 
> nr_objs threshold) at the time you want to deactivate the cpu slab.
> 
> I had a patchset that iterated the partial list and found the "most free" 
> partial slab (and terminated prematurely if a threshold had been reached, 
> much like yours) and selected that one, and it helped netperf 2-3% in my 
> testing.  So I disagree with determining where to add a partial slab to 
> the list at the time of free because it doesn't infer its state at the 
> time of cpu slab deactivation.
interesting. I did similar experiment before (try to sort the page
according to free number), but it appears quite hard. The free number of
a page is dynamic, eg more slabs can be freed when the page is in
partial list. And in netperf test, the partial list could be very very
long. Can you post your patch, I definitely what to look at it.
What I have about the partial list is it wastes a lot of memory. My test
shows about 50% memory is wasted. I'm thinking not always fetching the
oldest page from the partial list, because chances that objects of
oldest page can all be freed is high. I haven't done any test yet,
wondering if it could be helpful.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
