Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 52F5C6B0389
	for <linux-mm@kvack.org>; Sun, 19 Mar 2017 10:04:55 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id u48so22104901wrc.0
        for <linux-mm@kvack.org>; Sun, 19 Mar 2017 07:04:55 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n69si11136194wmd.101.2017.03.19.07.04.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 19 Mar 2017 07:04:53 -0700 (PDT)
Date: Sun, 19 Mar 2017 10:04:47 -0400
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: kernel BUG at mm/swap_slots.c:270
Message-ID: <20170319140447.GA12414@dhcp22.suse.cz>
References: <CA+55aFyq++yzU6bthhy1eDebkaAiXnH6YXHCTNzsC2-KZqN=Pw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFyq++yzU6bthhy1eDebkaAiXnH6YXHCTNzsC2-KZqN=Pw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Sat 18-03-17 09:57:18, Linus Torvalds wrote:
> Tim at al,
>  I got this on my desktop at shutdown:
> 
>   ------------[ cut here ]------------
>   kernel BUG at mm/swap_slots.c:270!
>   invalid opcode: 0000 [#1] SMP
>   CPU: 5 PID: 1745 Comm: (sd-pam) Not tainted 4.11.0-rc1-00243-g24c534bb161b #1
>   Hardware name: System manufacturer System Product Name/Z170-K, BIOS
> 1803 05/06/2016
>   RIP: 0010:free_swap_slot+0xba/0xd0
>   Call Trace:
>    swap_free+0x36/0x40
>    do_swap_page+0x360/0x6d0
>    __handle_mm_fault+0x880/0x1080
>    handle_mm_fault+0xd0/0x240
>    __do_page_fault+0x232/0x4d0
>    do_page_fault+0x20/0x70
>    page_fault+0x22/0x30
>   ---[ end trace aefc9ede53e0ab21 ]---
> 
> so there seems to be something screwy in the new swap_slots code.

I am travelling (LSFMM) so I didn't get to look at this more thoroughly
but it seems like a race because enable_swap_slots_cache is called at
the very end of the swapon and we could have already created a swap
entry for a page by that time I guess.

> Any ideas? I'm not finding other reports of this, but I'm also not
> seeing why it should BUG_ON(). The "use_swap_slot_cache" thing very
> much checks whether swap_slot_cache_initialized has been set, so the
> BUG_ON() just seems like garbage. But please take a look.

I guess you are right. I cannot speak of the original intention but it
seems Tim wanted to be careful to not see unexpected swap entry when
the swap wasn't initialized yet. I would just drop the BUG_ON and bail
out when the slot cache hasn't been initialized yet.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
