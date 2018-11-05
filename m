Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id DCFA66B0286
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 11:57:33 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id u6-v6so5773371eds.10
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 08:57:33 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u9-v6si1058025ejk.320.2018.11.05.08.57.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 08:57:32 -0800 (PST)
Date: Mon, 5 Nov 2018 17:57:30 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2] mm/kvmalloc: do not call kmalloc for size >
 KMALLOC_MAX_SIZE
Message-ID: <20181105165730.GN4361@dhcp22.suse.cz>
References: <154106356066.887821.4649178319705436373.stgit@buzz>
 <154106695670.898059.5301435081426064314.stgit@buzz>
 <80074d2a-2f8d-a9db-892b-105c0ad7cd47@suse.cz>
 <d033db53-129d-c031-db78-ba7f9fed5bf4@yandex-team.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d033db53-129d-c031-db78-ba7f9fed5bf4@yandex-team.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Mon 05-11-18 19:19:28, Konstantin Khlebnikov wrote:
> 
> 
> On 05.11.2018 16:03, Vlastimil Babka wrote:
> > On 11/1/18 11:09 AM, Konstantin Khlebnikov wrote:
> > > Allocations over KMALLOC_MAX_SIZE could be served only by vmalloc.
> > > 
> > > Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> > 
> > Makes sense regardless of warnings stuff.
> > 
> > Acked-by: Vlastimil Babka <vbabka@suse.cz>
> > 
> > But it must be moved below the GFP_KERNEL check!
> 
> But kmalloc cannot handle it regardless of GFP.
> 
> Ok maybe write something like this
> 
> if (size > KMALLOC_MAX_SIZE) {
> 	if (WARN_ON_ONCE((flags & GFP_KERNEL) != GFP_KERNEL)
> 		return NULL;
> 	goto do_vmalloc;
> }

Do we really have to be so defensive? I agree with Vlastimil that the
check should be done after GFP_KERNEL check (I should have noticed that).
kmalloc should already complain on the allocation size request.

> or fix that uncertainty right in vmalloc
> 
> For now comment in vmalloc declares
> 
>  *	Any use of gfp flags outside of GFP_KERNEL should be consulted
>  *	with mm people.

Which is what we want. There are some exceptional cases where using a
subset of GFP_KERNEL works fine (e.g. scope nofs/noio context).

-- 
Michal Hocko
SUSE Labs
