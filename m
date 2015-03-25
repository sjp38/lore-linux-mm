Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 308716B0038
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 02:07:27 -0400 (EDT)
Received: by wibgn9 with SMTP id gn9so23068187wib.1
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 23:07:26 -0700 (PDT)
Received: from mail-wg0-x22b.google.com (mail-wg0-x22b.google.com. [2a00:1450:400c:c00::22b])
        by mx.google.com with ESMTPS id x1si3205682wif.79.2015.03.24.23.07.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Mar 2015 23:07:25 -0700 (PDT)
Received: by wgs2 with SMTP id 2so15034424wgs.1
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 23:07:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150324150054.a9050b7814860790e1d9b0d0@linux-foundation.org>
References: <1426773881-5757-1-git-send-email-r.peniaev@gmail.com>
	<1426773881-5757-2-git-send-email-r.peniaev@gmail.com>
	<20150324150054.a9050b7814860790e1d9b0d0@linux-foundation.org>
Date: Wed, 25 Mar 2015 15:07:24 +0900
Message-ID: <CACZ9PQUHctju1GkMz_DDYj2YM7hO1FF-=7mFes2_HHqx53jCEw@mail.gmail.com>
Subject: Re: [RFC v2 1/3] mm/vmalloc: fix possible exhaustion of vmalloc space
 caused by vm_map_ram allocator
From: Roman Peniaev <r.peniaev@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Eric Dumazet <edumazet@google.com>, David Rientjes <rientjes@google.com>, WANG Chao <chaowang@redhat.com>, Fabian Frederick <fabf@skynet.be>, Christoph Lameter <cl@linux.com>, Gioh Kim <gioh.kim@lge.com>, Rob Jones <rob.jones@codethink.co.uk>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "stable@vger.kernel.org" <stable@vger.kernel.org>

On Wed, Mar 25, 2015 at 7:00 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Thu, 19 Mar 2015 23:04:39 +0900 Roman Pen <r.peniaev@gmail.com> wrote:
>
>> If suitable block can't be found, new block is allocated and put into a head
>> of a free list, so on next iteration this new block will be found first.
>>
>> ...
>>
>> Cc: stable@vger.kernel.org
>>
>> ...
>>
>> --- a/mm/vmalloc.c
>> +++ b/mm/vmalloc.c
>> @@ -837,7 +837,7 @@ static struct vmap_block *new_vmap_block(gfp_t gfp_mask)
>>
>>       vbq = &get_cpu_var(vmap_block_queue);
>>       spin_lock(&vbq->lock);
>> -     list_add_rcu(&vb->free_list, &vbq->free);
>> +     list_add_tail_rcu(&vb->free_list, &vbq->free);
>>       spin_unlock(&vbq->lock);
>>       put_cpu_var(vmap_block_queue);
>>
>
> I'm not sure about the cc:stable here.  There is potential for
> unexpected side-effects

Only one potential side-effect I see is that allocator has to iterate
up to 6 (7 on 64-bit systems) blocks in a free list two times.
The second patch fixes this by occupying the block right away after
allocation.  But even the second patch is not applied - iterating 6 (7)
blocks (and this is the worst and rare case) is not a big deal comparing
to the size of a free list, which increases over time, if this patch was
not applied.

I can compare the behaviour of the allocator, which puts new blocks to the
head of a free list, with the tetris game: sooner or later coming blocks
will reach the top, and you will lose, even if you are the champion.

> and I don't *think* people are hurting from
> this issue in real life.  Or maybe I'm wrong about that?

Yes, probably they are not.  I showed one special synthetic scenario, which
works pretty well and exhausts the virtual space very fast, another scenario
is a random one, which also works, but very slow.

I think drivers tend only to preallocate (not frequent usage) or to pass
sequential sizes to vm_map_ram.  In these cases everything will be fine.
Also free list is a CPU variable.  Good and fast reproduction happens only
if you bind a vm_map_ram call to the CPU or use uniprocessor system.

Probably the conjunction of all of these reasons hid the problem for a
long time.  But I tend to think that this is a bug, long-standing bug.

--
Roman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
