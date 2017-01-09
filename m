Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4671F6B0038
	for <linux-mm@kvack.org>; Mon,  9 Jan 2017 12:45:15 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id n3so81076899wjy.6
        for <linux-mm@kvack.org>; Mon, 09 Jan 2017 09:45:15 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t10si10708053wmb.123.2017.01.09.09.45.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 09 Jan 2017 09:45:14 -0800 (PST)
Date: Mon, 9 Jan 2017 18:45:11 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: __GFP_REPEAT usage in fq_alloc_node
Message-ID: <20170109174511.GA8306@dhcp22.suse.cz>
References: <20170106152052.GS5556@dhcp22.suse.cz>
 <CANn89i+QZs0cSPK21qMe6LXw+AeAMZ_tKEDUEnCsJ_cd+q0t-g@mail.gmail.com>
 <20170106160743.GU5556@dhcp22.suse.cz>
 <20170106161944.GW5556@dhcp22.suse.cz>
 <20170109102219.GF7495@dhcp22.suse.cz>
 <CANn89iKcHqyr=af2R7WyZRPawXt_bZkFAsbk0W_tkVt9VOGYFQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CANn89iKcHqyr=af2R7WyZRPawXt_bZkFAsbk0W_tkVt9VOGYFQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <edumazet@google.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon 09-01-17 08:00:16, Eric Dumazet wrote:
> On Mon, Jan 9, 2017 at 2:22 AM, Michal Hocko <mhocko@kernel.org> wrote:
> >
> > the changelog doesn't mention it but this, unlike other kvmalloc
> > conversions is not without functional changes. The kmalloc part
> > will be weaker than it is with the original code for !costly (<64kB)
> > requests, because we are enforcing __GFP_NORETRY to break out from the
> > page allocator which doesn't really fail such a small requests.
> >
> > Now the question is what those code paths really prefer. Do they really
> > want to potentially loop in the page allocator and invoke the OOM killer
> > when the memory is short/fragmeted? I mean we can get into a situation
> > when no order-3 pages can be compacted and shooting the system down just
> > for that reason sounds quite dangerous to me.
> >
> > So the main question is how hard should we try before falling back to
> > vmalloc here?
> 
> This patch is fine :
> 
> 1) Default hash size is 1024 slots, 8192 bytes on 64bit arches.

What about those non-default configurations. Do they really want to
invoke the OOM killer rather than fallback to the vmalloc?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
