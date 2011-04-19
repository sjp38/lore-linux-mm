Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9FAF58D003B
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 17:23:40 -0400 (EDT)
Received: from kpbe13.cbf.corp.google.com (kpbe13.cbf.corp.google.com [172.25.105.77])
	by smtp-out.google.com with ESMTP id p3JLNcaQ031282
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 14:23:38 -0700
Received: from pzk30 (pzk30.prod.google.com [10.243.19.158])
	by kpbe13.cbf.corp.google.com with ESMTP id p3JLMiJV032484
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 14:23:36 -0700
Received: by pzk30 with SMTP id 30so67102pzk.3
        for <linux-mm@kvack.org>; Tue, 19 Apr 2011 14:23:36 -0700 (PDT)
Date: Tue, 19 Apr 2011 14:23:35 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2] break out page allocation warning code
In-Reply-To: <1303160221.9887.301.camel@nimitz>
Message-ID: <alpine.DEB.2.00.1104191422080.510@chino.kir.corp.google.com>
References: <20110415170437.17E1AF36@kernel> <alpine.DEB.2.00.1104161653220.14788@chino.kir.corp.google.com> <1303139455.9615.2533.camel@nimitz> <alpine.DEB.2.00.1104181321480.31186@chino.kir.corp.google.com> <1303160221.9887.301.camel@nimitz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Nazarewicz <mina86@mina86.com>, Andrew Morton <akpm@linux-foundation.org>

On Mon, 18 Apr 2011, Dave Hansen wrote:

> > It shouldn't be a follow-on patch since you're introducing a new feature 
> > here (vmalloc allocation failure warnings) and what I'm identifying is a 
> > race in the access to current->comm.  A bug fix for a race should always 
> > preceed a feature that touches the same code.
> 
> Dude.  Seriously.  Glass house!  a63d83f4
> 

Not sure what you're implying here.  The commit you've identified is the 
oom killer rewrite and the oom killer is very specific about making sure 
to always hold task_lock() whenever dereferencing ->comm, even for 
current, to guard against /proc/pid/comm or prctl().  The oom killer is 
different from your usecase, however, because we can always take 
task_lock(current) in the oom killer because it's in a blockable context, 
whereas page allocation warnings can occur in a superset.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
