Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 186236B0007
	for <linux-mm@kvack.org>; Fri,  2 Feb 2018 12:00:09 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id c22so20680437pfj.2
        for <linux-mm@kvack.org>; Fri, 02 Feb 2018 09:00:09 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id x23si137099pgx.774.2018.02.02.09.00.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 02 Feb 2018 09:00:05 -0800 (PST)
Date: Fri, 2 Feb 2018 09:00:03 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [LSF/MM TOPIC] lru_lock scalability
Message-ID: <20180202170003.GA16840@bombadil.infradead.org>
References: <2a16be43-0757-d342-abfb-d4d043922da9@oracle.com>
 <20180201094431.GA20742@bombadil.infradead.org>
 <af831ebd-6acf-1f83-c531-39895ab2eddb@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <af831ebd-6acf-1f83-c531-39895ab2eddb@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, steven.sistare@oracle.com, pasha.tatashin@oracle.com, yossi.lev@oracle.com, Dave.Dice@oracle.com, akpm@linux-foundation.org, mhocko@kernel.org, ldufour@linux.vnet.ibm.com, dave@stgolabs.net, khandual@linux.vnet.ibm.com, ak@linux.intel.com, mgorman@suse.de

On Thu, Feb 01, 2018 at 11:07:56PM -0500, Daniel Jordan wrote:
> On 02/01/2018 04:44 AM, Matthew Wilcox wrote:
> > Something I've been thinking about is changing the LRU from an embedded
> > list_head to an external data structure that I call the XQueue.
> > It's based on the XArray, but is used like a queue; pushing items onto
> > the end of the queue and popping them off the beginning.  You can also
> > remove items from the middle of the queue.
> > 
> > Removing items from the list usually involves dirtying three cachelines.
> > With the XQueue, you'd only dirty one.  That's going to reduce lock
> > hold time.  There may also be opportunities to reduce lock hold time;
> > removal and addition can be done in parallel as long as there's more
> > than 64 entries between head and tail of the list.
> > 
> > The downside is that adding to the queue would require memory allocation.
> > And I don't have time to work on it at the moment.
> 
> I like the idea of touching fewer cachelines.
> 
> I looked through your latest XArray series (v6).  Am I understanding it correctly that a removal (xa_erase) is an exclusive operation within one XArray, i.e. that only one thread can do this at once?  Not sure how XQueue would implement removal though, so the answer might be different for it.

That's currently the case for the XArray, yes.  Peter Zijlstra wrote a
paper over ten years ago for allowing multiple simultaneous page-cache
writers.  https://www.kernel.org/doc/ols/2007/ols2007v2-pages-311-318.pdf

I'm not sure it's applicable to the current XArray which has grown other
features, but it should be implementable for the XQueue.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
