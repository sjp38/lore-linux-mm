Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id WAA18022
	for <linux-mm@kvack.org>; Fri, 27 Sep 2002 22:54:54 -0700 (PDT)
Message-ID: <3D95442E.C0959F4A@digeo.com>
Date: Fri, 27 Sep 2002 22:54:54 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: mremap() pte allocation atomicity error
References: <20020928052813.GY22942@holomorphy.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
> 
> I'm working on something else atm.
> 
>  [<c01187b3>]__might_sleep+0x43/0x47
>  [<c013b6d4>]__alloc_pages+0x24/0x20c
>  [<c0133650>]file_read_actor+0x0/0x1b0
>  [<c01131ed>]pte_alloc_one+0x41/0x104
>  [<c012d05d>]pte_alloc_map+0x4d/0x210
>  [<c013bc73>]get_page_cache_size+0xf/0x18
>  [<c0135f38>]move_one_page+0xe8/0x328
>  [<c0136061>]move_one_page+0x211/0x328
>  [<c0130644>]vm_enough_memory+0x34/0xc0
>  [<c01361a9>]move_page_tables+0x31/0x7c
>  [<c0136860>]do_mremap+0x66c/0x7ec
>  [<c0136a30>]sys_mremap+0x50/0x73
>  [<c010748f>]syscall_call+0x7/0xb
> 

ooh, oww, ouch.   Look at move_one_page():

        src = get_one_pte_map_nested(mm, old_addr);
        if (src) {
                dst = alloc_one_pte_map(mm, new_addr);
                error = copy_one_pte(mm, src, dst);


get_one_pte_map_nested() does a kmap_atomic(), and then we go and
call alloc_one_pte_map->pte_alloc_map->pte_alloc_one->alloc_pages()
inside that kmap_atomic().

I guess that has been there since day one.

A simple fix would be to drop the atomic kmap of the source pte
and take it again after the alloc_one_pte_map() call.

Can you think of a more efficient way?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
