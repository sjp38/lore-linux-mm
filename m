Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8CF556B0008
	for <linux-mm@kvack.org>; Tue, 16 Oct 2018 09:59:57 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id b13-v6so14165895edb.1
        for <linux-mm@kvack.org>; Tue, 16 Oct 2018 06:59:57 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cd14-v6si8660528ejb.135.2018.10.16.06.59.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Oct 2018 06:59:55 -0700 (PDT)
Subject: Re: [PATCH v2] mm: don't warn about large allocations for slab
References: <20180927171502.226522-1-dvyukov@gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <12881182-2459-910a-8f3a-04b3e85f08b6@suse.cz>
Date: Tue, 16 Oct 2018 15:59:52 +0200
MIME-Version: 1.0
In-Reply-To: <20180927171502.226522-1-dvyukov@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@gmail.com>, cl@linux.com, penberg@kernel.org, akpm@linux-foundation.org, rientjes@google.com, iamjoonsoo.kim@lge.com
Cc: Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 9/27/18 7:15 PM, Dmitry Vyukov wrote:
> From: Dmitry Vyukov <dvyukov@google.com>
> 
> Slub does not call kmalloc_slab() for sizes > KMALLOC_MAX_CACHE_SIZE,
> instead it falls back to kmalloc_large().
> For slab KMALLOC_MAX_CACHE_SIZE == KMALLOC_MAX_SIZE and it calls
> kmalloc_slab() for all allocations relying on NULL return value
> for over-sized allocations.
> This inconsistency leads to unwanted warnings from kmalloc_slab()
> for over-sized allocations for slab. Returning NULL for failed
> allocations is the expected behavior.
> 
> Make slub and slab code consistent by checking size >
> KMALLOC_MAX_CACHE_SIZE in slab before calling kmalloc_slab().
> 
> While we are here also fix the check in kmalloc_slab().
> We should check against KMALLOC_MAX_CACHE_SIZE rather than
> KMALLOC_MAX_SIZE. It all kinda worked because for slab the
> constants are the same, and slub always checks the size against
> KMALLOC_MAX_CACHE_SIZE before kmalloc_slab().
> But if we get there with size > KMALLOC_MAX_CACHE_SIZE anyhow
> bad things will happen. For example, in case of a newly introduced
> bug in slub code.
> 
> Also move the check in kmalloc_slab() from function entry
> to the size > 192 case. This partially compensates for the additional
> check in slab code and makes slub code a bit faster
> (at least theoretically).
> 
> Also drop __GFP_NOWARN in the warning check.
> This warning means a bug in slab code itself,
> user-passed flags have nothing to do with it.
> 
> Nothing of this affects slob.
> 
> Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org
> Reported-by: syzbot+87829a10073277282ad1@syzkaller.appspotmail.com
> Reported-by: syzbot+ef4e8fc3a06e9019bb40@syzkaller.appspotmail.com
> Reported-by: syzbot+6e438f4036df52cbb863@syzkaller.appspotmail.com
> Reported-by: syzbot+8574471d8734457d98aa@syzkaller.appspotmail.com
> Reported-by: syzbot+af1504df0807a083dbd9@syzkaller.appspotmail.com

Acked-by: Vlastimil Babka <vbabka@suse.cz>
