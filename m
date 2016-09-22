Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id CFC3C280256
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 13:07:50 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id n24so174486746pfb.0
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 10:07:50 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id g79si2887588pfg.60.2016.09.22.10.07.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Sep 2016 10:07:50 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id q2so4045655pfj.0
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 10:07:50 -0700 (PDT)
Message-ID: <1474564068.23058.144.camel@edumazet-glaptop3.roam.corp.google.com>
Subject: Re: [PATCH v2] fs/select: add vmalloc fallback for select(2)
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 22 Sep 2016 10:07:48 -0700
In-Reply-To: <12efc491-a0e7-1012-5a8b-6d3533c720db@suse.cz>
References: <20160922164359.9035-1-vbabka@suse.cz>
	 <1474562982.23058.140.camel@edumazet-glaptop3.roam.corp.google.com>
	 <12efc491-a0e7-1012-5a8b-6d3533c720db@suse.cz>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, netdev@vger.kernel.org

On Thu, 2016-09-22 at 18:56 +0200, Vlastimil Babka wrote:
> On 09/22/2016 06:49 PM, Eric Dumazet wrote:
> > On Thu, 2016-09-22 at 18:43 +0200, Vlastimil Babka wrote:
> >> The select(2) syscall performs a kmalloc(size, GFP_KERNEL) where size grows
> >> with the number of fds passed. We had a customer report page allocation
> >> failures of order-4 for this allocation. This is a costly order, so it might
> >> easily fail, as the VM expects such allocation to have a lower-order fallback.
> >>
> >> Such trivial fallback is vmalloc(), as the memory doesn't have to be
> >> physically contiguous. Also the allocation is temporary for the duration of the
> >> syscall, so it's unlikely to stress vmalloc too much.
> >
> > vmalloc() uses a vmap_area_lock spinlock, and TLB flushes.
> >
> > So I guess allowing vmalloc() being called from an innocent application
> > doing a select() might be dangerous, especially if this select() happens
> > thousands of time per second.
> 
> Isn't seq_buf_alloc() similarly exposed? And ipc_alloc()?

Possibly.

We don't have a library function (attempting kmalloc(), fallback to
vmalloc() presumably to avoid abuses, but I guess some patches were
accepted without thinking about this.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
