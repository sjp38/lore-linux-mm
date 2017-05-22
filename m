Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7F197280850
	for <linux-mm@kvack.org>; Sun, 21 May 2017 21:25:34 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id a66so109301776pfl.6
        for <linux-mm@kvack.org>; Sun, 21 May 2017 18:25:34 -0700 (PDT)
Received: from mail-pf0-x234.google.com (mail-pf0-x234.google.com. [2607:f8b0:400e:c00::234])
        by mx.google.com with ESMTPS id h89si15687560pld.136.2017.05.21.18.25.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 May 2017 18:25:33 -0700 (PDT)
Received: by mail-pf0-x234.google.com with SMTP id 9so66157857pfj.1
        for <linux-mm@kvack.org>; Sun, 21 May 2017 18:25:33 -0700 (PDT)
Date: Sun, 21 May 2017 18:25:31 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] slub/memcg: Cure the brainless abuse of sysfs
 attributes
In-Reply-To: <alpine.DEB.2.20.1705201244540.2255@nanos>
Message-ID: <alpine.DEB.2.10.1705211825210.10047@chino.kir.corp.google.com>
References: <alpine.DEB.2.20.1705201244540.2255@nanos>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <peterz@infradead.org>

On Sat, 20 May 2017, Thomas Gleixner wrote:

> memcg_propagate_slab_attrs() abuses the sysfs attribute file functions to
> propagate settings from the root kmem_cache to a newly created
> kmem_cache. It does that with:
> 
>      attr->show(root, buf);
>      attr->store(new, buf, strlen(bug);
> 
> Aside of being a lazy and absurd hackery this is broken because it does not
> check the return value of the show() function.
> 
> Some of the show() functions return 0 w/o touching the buffer. That means in
> such a case the store function is called with the stale content of the
> previous show(). That causes nonsense like invoking kmem_cache_shrink() on
> a newly created kmem_cache. In the worst case it would cause handing in an
> uninitialized buffer.
> 
> This should be rewritten proper by adding a propagate() callback to those
> slub_attributes which must be propagated and avoid that insane conversion
> to and from ASCII, but that's too large for a hot fix.
> 
> Check at least the return value of the show() function, so calling store()
> with stale content is prevented.
> 
> Reported-by: Steven Rostedt <rostedt@goodmis.org>
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
> Cc: stable@vger.kernel.org

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
