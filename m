Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id E26F96B0253
	for <linux-mm@kvack.org>; Mon,  9 Jan 2017 11:00:17 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id x2so93203543itf.6
        for <linux-mm@kvack.org>; Mon, 09 Jan 2017 08:00:17 -0800 (PST)
Received: from mail-io0-x231.google.com (mail-io0-x231.google.com. [2607:f8b0:4001:c06::231])
        by mx.google.com with ESMTPS id o189si9835893ith.38.2017.01.09.08.00.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jan 2017 08:00:17 -0800 (PST)
Received: by mail-io0-x231.google.com with SMTP id f103so85395590ioi.1
        for <linux-mm@kvack.org>; Mon, 09 Jan 2017 08:00:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170109102219.GF7495@dhcp22.suse.cz>
References: <20170106152052.GS5556@dhcp22.suse.cz> <CANn89i+QZs0cSPK21qMe6LXw+AeAMZ_tKEDUEnCsJ_cd+q0t-g@mail.gmail.com>
 <20170106160743.GU5556@dhcp22.suse.cz> <20170106161944.GW5556@dhcp22.suse.cz> <20170109102219.GF7495@dhcp22.suse.cz>
From: Eric Dumazet <edumazet@google.com>
Date: Mon, 9 Jan 2017 08:00:16 -0800
Message-ID: <CANn89iKcHqyr=af2R7WyZRPawXt_bZkFAsbk0W_tkVt9VOGYFQ@mail.gmail.com>
Subject: Re: __GFP_REPEAT usage in fq_alloc_node
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon, Jan 9, 2017 at 2:22 AM, Michal Hocko <mhocko@kernel.org> wrote:
>
> the changelog doesn't mention it but this, unlike other kvmalloc
> conversions is not without functional changes. The kmalloc part
> will be weaker than it is with the original code for !costly (<64kB)
> requests, because we are enforcing __GFP_NORETRY to break out from the
> page allocator which doesn't really fail such a small requests.
>
> Now the question is what those code paths really prefer. Do they really
> want to potentially loop in the page allocator and invoke the OOM killer
> when the memory is short/fragmeted? I mean we can get into a situation
> when no order-3 pages can be compacted and shooting the system down just
> for that reason sounds quite dangerous to me.
>
> So the main question is how hard should we try before falling back to
> vmalloc here?

This patch is fine :

1) Default hash size is 1024 slots, 8192 bytes on 64bit arches.
2) Most of the times, qdisc are setup at boot time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
