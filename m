Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id ACE5D28027D
	for <linux-mm@kvack.org>; Fri, 11 Nov 2016 05:30:42 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 17so9613367pfy.2
        for <linux-mm@kvack.org>; Fri, 11 Nov 2016 02:30:42 -0800 (PST)
Received: from mail-pf0-x231.google.com (mail-pf0-x231.google.com. [2607:f8b0:400e:c00::231])
        by mx.google.com with ESMTPS id cs1si7960352pac.117.2016.11.11.02.30.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Nov 2016 02:30:41 -0800 (PST)
Received: by mail-pf0-x231.google.com with SMTP id d2so10225750pfd.0
        for <linux-mm@kvack.org>; Fri, 11 Nov 2016 02:30:41 -0800 (PST)
Date: Fri, 11 Nov 2016 02:30:39 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, slab: faster active and free stats
In-Reply-To: <20161111055326.GA16336@js1304-P5Q-DELUXE>
Message-ID: <alpine.DEB.2.10.1611110222440.16406@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1611081505240.13403@chino.kir.corp.google.com> <20161108151727.b64035da825c69bced88b46d@linux-foundation.org> <alpine.DEB.2.10.1611091637460.125130@chino.kir.corp.google.com> <20161111055326.GA16336@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Aruna Ramakrishna <aruna.ramakrishna@oracle.com>, Christoph Lameter <cl@linux.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 11 Nov 2016, Joonsoo Kim wrote:

> Hello, David.
> 
> Maintaining acitve/free_slab counters looks so complex. And, I think
> that we don't need to maintain these counters for faster slabinfo.
> Key point is to remove iterating n->slabs_partial list.
> 
> We can calculate active slab/object by following equation as you did in
> this patch.
> 
> active_slab(n) = n->num_slab - the number of free_slab
> active_object(n) = n->num_slab * cachep->num - n->free_objects
> 
> To get the number of free_slab, we need to iterate n->slabs_free list
> but I guess it would be small enough.
> 
> If you don't like to iterate n->slabs_free list in slabinfo, just
> maintaining the number of slabs_free would be enough.
> 

Hi Joonsoo,

It's a good point, although I don't think the patch has overly complex 
logic to keep track of slab state.

We don't prefer to do any iteration in get_slabinfo() since users can 
read /proc/slabinfo constantly; it's better to just settle the stats when 
slab state changes instead of repeating an expensive operation over and 
over if someone is running slabtop(1) or /proc/slabinfo is scraped 
regularly for stats.

That said, I imagine there are more clever ways to arrive at the same 
answer, and you bring up a good point about maintaining a n->num_slabs and 
n->free_slabs rather than n->active_slabs and n->free_slabs.

I don't feel strongly about either approach, but I think some improvement, 
such as what this patch provides, is needed to prevent how expensive 
simply reading /proc/slabinfo can be.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
