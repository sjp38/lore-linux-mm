Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3CC116B002D
	for <linux-mm@kvack.org>; Tue, 18 Oct 2011 21:16:29 -0400 (EDT)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id p9J1GPnt008891
	for <linux-mm@kvack.org>; Tue, 18 Oct 2011 18:16:26 -0700
Received: from qabg27 (qabg27.prod.google.com [10.224.20.219])
	by wpaz5.hot.corp.google.com with ESMTP id p9J19PWY019890
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 18 Oct 2011 18:16:24 -0700
Received: by qabg27 with SMTP id g27so2627563qab.11
        for <linux-mm@kvack.org>; Tue, 18 Oct 2011 18:16:24 -0700 (PDT)
Date: Tue, 18 Oct 2011 18:16:21 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] Reduce vm_stat cacheline contention in
 __vm_enough_memory
In-Reply-To: <m2mxcyz4f7.fsf@firstfloor.org>
Message-ID: <alpine.DEB.2.00.1110181806570.12850@chino.kir.corp.google.com>
References: <20111013135032.7c2c54cd.akpm@linux-foundation.org> <alpine.DEB.2.00.1110131602020.26553@router.home> <20111013142434.4d05cbdc.akpm@linux-foundation.org> <20111014122506.GB26737@sgi.com> <20111014135055.GA28592@sgi.com> <alpine.DEB.2.00.1110140856420.6411@router.home>
 <20111014141921.GC28592@sgi.com> <alpine.DEB.2.00.1110140932530.6411@router.home> <alpine.DEB.2.00.1110140958550.6411@router.home> <20111014161603.GA30561@sgi.com> <20111018134835.GA16222@sgi.com> <m2mxcyz4f7.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Dimitri Sivanich <sivanich@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@gentwo.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>

On Tue, 18 Oct 2011, Andi Kleen wrote:

> > Would it make sense to have the ZVC delta be tuneable (via /proc/sys/vm?), keeping the
> > same default behavior as what we currently have?
> 
> Tunable is bad. We don't really want a "hundreds of lines magic shell script to
> make large systems perform". Please find a way to auto tune.
> 

Agreed, and I think even if we had a tunable that it would result in 
potentially erradic VM performance because some areas depend on "fairly 
accurate" ZVCs and it wouldn't be clear that you're trading other unknown 
VM issues that will affect your workload because you've increased the 
deltas.  Let's try to avoid having to ask "what is your ZVC delta tunable 
set at?" when someone reports a bug about reclaim stopping preemptively.

That said, perhaps we need higher deltas by default and then hints in key 
areas in the form of sync_stats_if_delta_above(x) calls that would do 
zone_page_state_add() only when that kind of precision is actually needed.  
For public interfaces, that would be very easy to audit to see what the 
level of precision is when parsing the data.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
