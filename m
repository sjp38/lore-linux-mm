Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 549606B005A
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 18:50:34 -0400 (EDT)
Received: by dakp5 with SMTP id p5so6084081dak.14
        for <linux-mm@kvack.org>; Fri, 29 Jun 2012 15:50:33 -0700 (PDT)
Date: Fri, 29 Jun 2012 15:50:31 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] KSM: numa awareness sysfs knob
In-Reply-To: <20120629141759.3312b49e.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1206291543360.17044@chino.kir.corp.google.com>
References: <1340970592-25001-1-git-send-email-pholasek@redhat.com> <20120629141759.3312b49e.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Petr Holasek <pholasek@redhat.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Chris Wright <chrisw@sous-sol.org>, Izik Eidus <izik.eidus@ravellosystems.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Anton Arapov <anton@redhat.com>

On Fri, 29 Jun 2012, Andrew Morton wrote:

> > I've tested this patch on numa machines with 2, 4 and 8 nodes and
> > measured speed of memory access inside of KVM guests with memory pinned
> > to one of nodes with this benchmark:
> > 
> > http://pholasek.fedorapeople.org/alloc_pg.c
> > 
> > Population standard deviations of access times in percentage of average
> > were following:
> > 
> > merge_nodes=1
> > 2 nodes 1.4%
> > 4 nodes 1.6%
> > 8 nodes	1.7%
> > 
> > merge_nodes=0
> > 2 nodes	1%
> > 4 nodes	0.32%
> > 8 nodes	0.018%
> 
> ooh, numbers!  Thanks.
> 

Ok, the standard deviation increases when merging pages from nodes with 
remote distance, that makes sense.  But if that's true, then you would 
restrict either the entire application to local memory with mempolicies or 
cpusets, or you would use mbind() to restrict this memory to that set of 
nodes already so that accesses, even with ksm merging, would have 
affinity.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
