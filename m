Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id AD5CA6B002C
	for <linux-mm@kvack.org>; Fri,  7 Oct 2011 23:08:27 -0400 (EDT)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id p9838Nq7011055
	for <linux-mm@kvack.org>; Fri, 7 Oct 2011 20:08:24 -0700
Received: from pzd13 (pzd13.prod.google.com [10.243.17.205])
	by wpaz29.hot.corp.google.com with ESMTP id p983836V006357
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 7 Oct 2011 20:08:22 -0700
Received: by pzd13 with SMTP id 13so18987709pzd.3
        for <linux-mm@kvack.org>; Fri, 07 Oct 2011 20:08:22 -0700 (PDT)
Date: Fri, 7 Oct 2011 20:08:19 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH -v2 -mm] add extra free kbytes tunable
In-Reply-To: <20110901152650.7a63cb8b@annuminas.surriel.com>
Message-ID: <alpine.DEB.2.00.1110072001070.13992@chino.kir.corp.google.com>
References: <20110901105208.3849a8ff@annuminas.surriel.com> <20110901100650.6d884589.rdunlap@xenotime.net> <20110901152650.7a63cb8b@annuminas.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Randy Dunlap <rdunlap@xenotime.net>, Satoru Moriya <smoriya@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, lwoodman@redhat.com, Seiji Aguchi <saguchi@redhat.com>, akpm@linux-foundation.org, hughd@google.com, hannes@cmpxchg.org

On Thu, 1 Sep 2011, Rik van Riel wrote:

> Add a userspace visible knob to tell the VM to keep an extra amount
> of memory free, by increasing the gap between each zone's min and
> low watermarks.
> 
> This is useful for realtime applications that call system
> calls and have a bound on the number of allocations that happen
> in any short time period.  In this application, extra_free_kbytes
> would be left at an amount equal to or larger than than the
> maximum number of allocations that happen in any burst.
> 
> It may also be useful to reduce the memory use of virtual
> machines (temporarily?), in a way that does not cause memory
> fragmentation like ballooning does.
> 

I know this was merged into -mm, but I still have to disagree with it 
because I think it adds yet another userspace knob that will never be 
obsoleted, will be misinterepted, and is tied very closely to the 
implementation of page reclaim, both synchronous and asynchronous.  I also 
think that it will cause regressions on other cpu intensive workloads 
that don't require this extra freed memory because it works as a global 
heuristic and is not tied to any specific application.

I think it would be far better to reclaim beyond above the high watermark 
if the types of workloads that need this tunable can be somehow detected 
(the worst case scenario is being a prctl() that does synchronous reclaim 
above the watermark so admins can identify these workloads), or be able to 
mark allocations within the kernel as potentially coming in large bursts 
where allocation is problematic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
