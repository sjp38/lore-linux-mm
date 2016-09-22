Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 69627280256
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 12:56:50 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id l132so57367270wmf.0
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 09:56:50 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q14si36985762wmb.133.2016.09.22.09.56.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Sep 2016 09:56:49 -0700 (PDT)
Subject: Re: [PATCH v2] fs/select: add vmalloc fallback for select(2)
References: <20160922164359.9035-1-vbabka@suse.cz>
 <1474562982.23058.140.camel@edumazet-glaptop3.roam.corp.google.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <12efc491-a0e7-1012-5a8b-6d3533c720db@suse.cz>
Date: Thu, 22 Sep 2016 18:56:48 +0200
MIME-Version: 1.0
In-Reply-To: <1474562982.23058.140.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, netdev@vger.kernel.org

On 09/22/2016 06:49 PM, Eric Dumazet wrote:
> On Thu, 2016-09-22 at 18:43 +0200, Vlastimil Babka wrote:
>> The select(2) syscall performs a kmalloc(size, GFP_KERNEL) where size grows
>> with the number of fds passed. We had a customer report page allocation
>> failures of order-4 for this allocation. This is a costly order, so it might
>> easily fail, as the VM expects such allocation to have a lower-order fallback.
>>
>> Such trivial fallback is vmalloc(), as the memory doesn't have to be
>> physically contiguous. Also the allocation is temporary for the duration of the
>> syscall, so it's unlikely to stress vmalloc too much.
>
> vmalloc() uses a vmap_area_lock spinlock, and TLB flushes.
>
> So I guess allowing vmalloc() being called from an innocent application
> doing a select() might be dangerous, especially if this select() happens
> thousands of time per second.

Isn't seq_buf_alloc() similarly exposed? And ipc_alloc()?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
