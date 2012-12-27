Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id CFDB26B002B
	for <linux-mm@kvack.org>; Thu, 27 Dec 2012 17:31:12 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id bi1so5677854pad.8
        for <linux-mm@kvack.org>; Thu, 27 Dec 2012 14:31:12 -0800 (PST)
Date: Thu, 27 Dec 2012 14:31:10 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/3] mm, bootmem: panic in bootmem alloc functions even
 if slab is available
In-Reply-To: <CAOJsxLH4RzWdxdVXyn+eFc56JfJtije2jK1eWaBYVaoZSHuUBA@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1212271428520.18214@chino.kir.corp.google.com>
References: <1356293711-23864-1-git-send-email-sasha.levin@oracle.com> <1356293711-23864-2-git-send-email-sasha.levin@oracle.com> <alpine.DEB.2.00.1212271423210.18214@chino.kir.corp.google.com>
 <CAOJsxLH4RzWdxdVXyn+eFc56JfJtije2jK1eWaBYVaoZSHuUBA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, "David S. Miller" <davem@davemloft.net>, Tejun Heo <tj@kernel.org>, Joonsoo Kim <js1304@gmail.com>, Yinghai Lu <yinghai@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 28 Dec 2012, Pekka Enberg wrote:

> On Sun, 23 Dec 2012, Sasha Levin wrote:
> >> diff --git a/mm/bootmem.c b/mm/bootmem.c
> >> index 1324cd7..198a92f 100644
> >> --- a/mm/bootmem.c
> >> +++ b/mm/bootmem.c
> >> @@ -763,9 +763,6 @@ void * __init ___alloc_bootmem_node(pg_data_t *pgdat, unsigned long size,
> >>  void * __init __alloc_bootmem_node(pg_data_t *pgdat, unsigned long size,
> >>                                  unsigned long align, unsigned long goal)
> >>  {
> >> -     if (WARN_ON_ONCE(slab_is_available()))
> >> -             return kzalloc_node(size, GFP_NOWAIT, pgdat->node_id);
> >> -
> >>       return  ___alloc_bootmem_node(pgdat, size, align, goal, 0);
> >>  }
> 
> I'm not sure what Sasha's patch is trying to do here but the fall-back
> is there simply to let the caller know it's calling the bootmem
> allocator *too late*. That is, the slab allocator is already up and
> running so you're expected to use that.
> 

The __alloc_bootmem_node() variant is intended to panic rather than return 
NULL so there are callers that do not check the return value.  I'm 
suggesting rather than removing the fallback to the slab allocator to 
check the return value and panic() here if kzalloc_node() returns NULL.  
The __alloc_bootmem_node_nopanic() variant needs not be changed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
