Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f51.google.com (mail-ee0-f51.google.com [74.125.83.51])
	by kanga.kvack.org (Postfix) with ESMTP id 002576B0031
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 13:58:18 -0500 (EST)
Received: by mail-ee0-f51.google.com with SMTP id b57so1722694eek.24
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 10:58:18 -0800 (PST)
Received: from order.stressinduktion.org (order.stressinduktion.org. [87.106.68.36])
        by mx.google.com with ESMTPS id w2si9952242eeg.70.2014.02.07.10.58.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 07 Feb 2014 10:58:17 -0800 (PST)
Date: Fri, 7 Feb 2014 19:58:16 +0100
From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [BUG] at include/linux/page-flags.h:415 (PageTransHuge)
Message-ID: <20140207185816.GA7764@order.stressinduktion.org>
References: <52D03A9E.2030309@iogearbox.net> <20140110222248.4e8419ca.akpm@linux-foundation.org> <52D147F1.3040803@iogearbox.net> <52D3BCE9.4020405@suse.cz> <52D3D060.1010301@iogearbox.net> <52D69AB4.6000309@suse.cz> <52D6B213.4020602@iogearbox.net> <52EBB5E6.8010007@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <52EBB5E6.8010007@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Daniel Borkmann <borkmann@iogearbox.net>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, Michel Lespinasse <walken@google.com>, linux-mm <linux-mm@kvack.org>, Jared Hulbert <jaredeh@gmail.com>, netdev <netdev@vger.kernel.org>, Thomas Hellstrom <thellstrom@vmware.com>, John David Anglin <dave.anglin@bell.net>, HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Carsten Otte <cotte@de.ibm.com>, Peter Zijlstra <peterz@infradead.org>

Hi!

On Fri, Jan 31, 2014 at 03:40:38PM +0100, Vlastimil Babka wrote:
> From: Vlastimil Babka <vbabka@suse.cz>
> Date: Fri, 31 Jan 2014 11:50:21 +0100
> Subject: [PATCH] mm: include VM_MIXEDMAP flag in the VM_SPECIAL list to avoid
>  m(un)locking
> 
> Daniel Borkmann reported a bug with VM_BUG_ON assertions failing where
> munlock_vma_pages_range() thinks it's unexpectedly in the middle of a THP page.
> This can be reproduced in tools/testing/selftests/net/ by running make and
> then ./psock_tpacket.
> 
> The problem is that an order=2 compound page (allocated by
> alloc_one_pg_vec_page() is part of the munlocked VM_MIXEDMAP vma (mapped by
> packet_mmap()) and mistaken for a THP page and assumed to be order=9.
> 
> The checks for THP in munlock came with commit ff6a6da60b89 ("mm: accelerate
> munlock() treatment of THP pages"), i.e. since 3.9, but did not trigger a bug.
> It just makes munlock_vma_pages_range() skip such compound pages until the next
> 512-pages-aligned page, when it encounters a head page. This is however not a
> problem for vma's where mlocking has no effect anyway, but it can distort the
> accounting.
> Since commit 7225522bb ("mm: munlock: batch non-THP page isolation and
> munlock+putback using pagevec") this can trigger a VM_BUG_ON in PageTransHuge()
> check.
> 
> This patch fixes the issue by adding VM_MIXEDMAP flag to VM_SPECIAL - a list of
> flags that make vma's non-mlockable and non-mergeable. The reasoning is that
> VM_MIXEDMAP vma's are similar to VM_PFNMAP, which is already on the VM_SPECIAL
> list, and both are intended for non-LRU pages where mlocking makes no sense
> anyway.

I also ran into this problem and wanted to ask what the status of this
patch is? Does it need further testing? I can surely help with that. ;)

Thanks,

  Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
