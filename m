Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id B172F6B1EA0
	for <linux-mm@kvack.org>; Tue, 21 Aug 2018 08:17:40 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id i68-v6so9648249pfb.9
        for <linux-mm@kvack.org>; Tue, 21 Aug 2018 05:17:40 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e3-v6si12509684pgh.385.2018.08.21.05.17.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Aug 2018 05:17:39 -0700 (PDT)
Date: Tue, 21 Aug 2018 14:17:34 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: Fix comment for NODEMASK_ALLOC
Message-ID: <20180821121734.GA29735@dhcp22.suse.cz>
References: <20180820085516.9687-1-osalvador@techadventures.net>
 <20180820142440.1f9ccbebefc5d617c881b41e@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180820142440.1f9ccbebefc5d617c881b41e@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Oscar Salvador <osalvador@techadventures.net>, tglx@linutronix.de, joe@perches.com, arnd@arndb.de, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Oscar Salvador <osalvador@suse.de>

On Mon 20-08-18 14:24:40, Andrew Morton wrote:
> On Mon, 20 Aug 2018 10:55:16 +0200 Oscar Salvador <osalvador@techadventures.net> wrote:
> 
> > From: Oscar Salvador <osalvador@suse.de>
> > 
> > Currently, NODEMASK_ALLOC allocates a nodemask_t with kmalloc when
> > NODES_SHIFT is higher than 8, otherwise it declares it within the stack.
> > 
> > The comment says that the reasoning behind this, is that nodemask_t will be
> > 256 bytes when NODES_SHIFT is higher than 8, but this is not true.
> > For example, NODES_SHIFT = 9 will give us a 64 bytes nodemask_t.
> > Let us fix up the comment for that.
> > 
> > Another thing is that it might make sense to let values lower than 128bytes
> > be allocated in the stack.
> > Although this all depends on the depth of the stack
> > (and this changes from function to function), I think that 64 bytes
> > is something we can easily afford.
> > So we could even bump the limit by 1 (from > 8 to > 9).
> > 
> 
> I agree.  Such a change will reduce the amount of testing which the
> kmalloc version receives, but I assume there are enough people out
> there testing with large NODES_SHIFT values.

We do have CONFIG_NODES_SHIFT=10 in our SLES kernels for quite some
time (around SLE11-SP3 AFAICS).

Anyway, isn't NODES_ALLOC over engineered a bit? Does actually even do
larger than 1024 NUMA nodes? This would be 128B and from a quick glance
it seems that none of those functions are called in deep stacks. I
haven't gone through all of them but a patch which checks them all and
removes NODES_ALLOC would be quite nice IMHO.

-- 
Michal Hocko
SUSE Labs
