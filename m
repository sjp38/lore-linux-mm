Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2E9A76B0069
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 02:36:57 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id x23so345059413pgx.6
        for <linux-mm@kvack.org>; Sun, 27 Nov 2016 23:36:57 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id v23si53926686pgc.42.2016.11.27.23.36.55
        for <linux-mm@kvack.org>;
        Sun, 27 Nov 2016 23:36:56 -0800 (PST)
Date: Mon, 28 Nov 2016 16:40:02 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [patch] mm, slab: faster active and free stats
Message-ID: <20161128074001.GA32105@js1304-P5Q-DELUXE>
References: <alpine.DEB.2.10.1611081505240.13403@chino.kir.corp.google.com>
 <20161108151727.b64035da825c69bced88b46d@linux-foundation.org>
 <alpine.DEB.2.10.1611091637460.125130@chino.kir.corp.google.com>
 <20161111055326.GA16336@js1304-P5Q-DELUXE>
 <alpine.DEB.2.10.1611110222440.16406@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1611110222440.16406@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Aruna Ramakrishna <aruna.ramakrishna@oracle.com>, Christoph Lameter <cl@linux.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Nov 11, 2016 at 02:30:39AM -0800, David Rientjes wrote:
> On Fri, 11 Nov 2016, Joonsoo Kim wrote:
> 
> > Hello, David.
> > 
> > Maintaining acitve/free_slab counters looks so complex. And, I think
> > that we don't need to maintain these counters for faster slabinfo.
> > Key point is to remove iterating n->slabs_partial list.
> > 
> > We can calculate active slab/object by following equation as you did in
> > this patch.
> > 
> > active_slab(n) = n->num_slab - the number of free_slab
> > active_object(n) = n->num_slab * cachep->num - n->free_objects
> > 
> > To get the number of free_slab, we need to iterate n->slabs_free list
> > but I guess it would be small enough.
> > 
> > If you don't like to iterate n->slabs_free list in slabinfo, just
> > maintaining the number of slabs_free would be enough.
> > 
> 
> Hi Joonsoo,
> 
> It's a good point, although I don't think the patch has overly complex 
> logic to keep track of slab state.
> 
> We don't prefer to do any iteration in get_slabinfo() since users can 
> read /proc/slabinfo constantly; it's better to just settle the stats when 
> slab state changes instead of repeating an expensive operation over and 
> over if someone is running slabtop(1) or /proc/slabinfo is scraped 
> regularly for stats.
> 
> That said, I imagine there are more clever ways to arrive at the same 
> answer, and you bring up a good point about maintaining a n->num_slabs and 
> n->free_slabs rather than n->active_slabs and n->free_slabs.
> 
> I don't feel strongly about either approach, but I think some improvement, 
> such as what this patch provides, is needed to prevent how expensive 
> simply reading /proc/slabinfo can be.

Hello,

Sorry for long delay.
I agree that this improvement is needed. Could you try the approach
that maintains n->num_slabs and n->free_slabs? I guess that it would be
simpler than this patch so more maintainable.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
