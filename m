Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 447F6280256
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 12:49:44 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id wk8so157994854pab.3
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 09:49:44 -0700 (PDT)
Received: from mail-pa0-x243.google.com (mail-pa0-x243.google.com. [2607:f8b0:400e:c03::243])
        by mx.google.com with ESMTPS id u84si2774891pfa.234.2016.09.22.09.49.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Sep 2016 09:49:43 -0700 (PDT)
Received: by mail-pa0-x243.google.com with SMTP id my20so3881361pab.3
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 09:49:43 -0700 (PDT)
Message-ID: <1474562982.23058.140.camel@edumazet-glaptop3.roam.corp.google.com>
Subject: Re: [PATCH v2] fs/select: add vmalloc fallback for select(2)
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 22 Sep 2016 09:49:42 -0700
In-Reply-To: <20160922164359.9035-1-vbabka@suse.cz>
References: <20160922164359.9035-1-vbabka@suse.cz>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, netdev@vger.kernel.org

On Thu, 2016-09-22 at 18:43 +0200, Vlastimil Babka wrote:
> The select(2) syscall performs a kmalloc(size, GFP_KERNEL) where size grows
> with the number of fds passed. We had a customer report page allocation
> failures of order-4 for this allocation. This is a costly order, so it might
> easily fail, as the VM expects such allocation to have a lower-order fallback.
> 
> Such trivial fallback is vmalloc(), as the memory doesn't have to be
> physically contiguous. Also the allocation is temporary for the duration of the
> syscall, so it's unlikely to stress vmalloc too much.

vmalloc() uses a vmap_area_lock spinlock, and TLB flushes.

So I guess allowing vmalloc() being called from an innocent application
doing a select() might be dangerous, especially if this select() happens
thousands of time per second.





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
