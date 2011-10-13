Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 49F3C6B002C
	for <linux-mm@kvack.org>; Wed, 12 Oct 2011 20:07:13 -0400 (EDT)
Subject: Re: [PATCH] Reduce vm_stat cacheline contention in
 __vm_enough_memory
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <CADE8fzrdMOBF1RyyEpMVi8aKcgOVKRQSKi0=c1Qvh3p6hHcXRA@mail.gmail.com>
References: <20111012160202.GA18666@sgi.com>
	 <20111012120118.e948f40a.akpm@linux-foundation.org>
	 <CADE8fzrdMOBF1RyyEpMVi8aKcgOVKRQSKi0=c1Qvh3p6hHcXRA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 12 Oct 2011 17:07:17 -0700
Message-ID: <1318464437.6469.16.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dimitri Sivanich <sivanich@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, ak@linux.intel.com

Andrew Morton wrote:

> Yes, the global vm_stat[] array is a problem - I'm surprised it's hung
> around for this long.  Altering the sysctl_overcommit_memory mode will
> hide the problem, but that's no good.
> 
> I think we've discussed switching vm_stat[] to a contention-avoiding
> counter scheme.  Simply using <percpu_counter.h> would be the simplest
> approach.  They'll introduce inaccuracies but hopefully any problems
> from that will be minor for the global page counters.
> 
> otoh, I think we've been round this loop before and I don't recall why
> nothing happened.

Yeah, we have had this discussion on vm_enough_memory before.  

https://lkml.org/lkml/2011/1/26/473

The current version of per cpu counter was not really suitable because
the batch size is not appropriate.  I've tried to use per cpu counter
with batch size adjusted in my attempt.  Andrew has suggested having an
elastic batch size that's proportional to the size of the central
counter but I haven't gotten around to try that out.

Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
