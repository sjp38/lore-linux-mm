Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1DDDA6B039F
	for <linux-mm@kvack.org>; Thu, 30 Mar 2017 19:21:45 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id 8so2027937itb.22
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 16:21:45 -0700 (PDT)
Received: from mail-pg0-x22d.google.com (mail-pg0-x22d.google.com. [2607:f8b0:400e:c05::22d])
        by mx.google.com with ESMTPS id x6si643770itf.53.2017.03.30.16.21.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Mar 2017 16:21:44 -0700 (PDT)
Received: by mail-pg0-x22d.google.com with SMTP id x125so52923996pgb.0
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 16:21:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170306103327.2766-3-mhocko@kernel.org>
References: <20170306103032.2540-1-mhocko@kernel.org> <20170306103327.2766-1-mhocko@kernel.org>
 <20170306103327.2766-3-mhocko@kernel.org>
From: Shakeel Butt <shakeelb@google.com>
Date: Thu, 30 Mar 2017 16:21:43 -0700
Message-ID: <CALvZod73-ddnbMAWXF9QpXMcpjZMLreLXheUo-CgcB7s_5iBnQ@mail.gmail.com>
Subject: Re: [PATCH 7/9] net: use kvmalloc with __GFP_REPEAT rather than open
 coded variant
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Eric Dumazet <edumazet@google.com>, Vlastimil Babka <vbabka@suse.cz>

On Mon, Mar 6, 2017 at 2:33 AM, Michal Hocko <mhocko@kernel.org> wrote:
> From: Michal Hocko <mhocko@suse.com>
>
> fq_alloc_node, alloc_netdev_mqs and netif_alloc* open code kmalloc
> with vmalloc fallback. Use the kvmalloc variant instead. Keep the
> __GFP_REPEAT flag based on explanation from Eric:
> "
> At the time, tests on the hardware I had in my labs showed that
> vmalloc() could deliver pages spread all over the memory and that was a
> small penalty (once memory is fragmented enough, not at boot time)
> "
>
> The way how the code is constructed means, however, that we prefer to go
> and hit the OOM killer before we fall back to the vmalloc for requests
> <=32kB (with 4kB pages) in the current code. This is rather disruptive for
> something that can be achived with the fallback. On the other hand
> __GFP_REPEAT doesn't have any useful semantic for these requests. So the
> effect of this patch is that requests smaller than 64kB will fallback to

I am a bit confused about this 64kB, shouldn't it be <=32kB (with 4kB
pages & PAGE_ALLOC_COSTLY_ORDER = 3)?

> vmalloc easier now.
>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: netdev@vger.kernel.org
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
