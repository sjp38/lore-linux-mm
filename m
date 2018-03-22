Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7D04C6B0023
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 13:34:56 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id s6so4515670pgn.3
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 10:34:56 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 38-v6si6607544pln.397.2018.03.22.10.34.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 22 Mar 2018 10:34:55 -0700 (PDT)
Date: Thu, 22 Mar 2018 10:34:50 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2 6/8] page_frag_cache: Use a mask instead of offset
Message-ID: <20180322173450.GI28468@bombadil.infradead.org>
References: <20180322153157.10447-1-willy@infradead.org>
 <20180322153157.10447-7-willy@infradead.org>
 <CAKgT0UfcYLm3UZcq536cNOczVhR60qoFDHh_gcXqqyqdViuLzw@mail.gmail.com>
 <20180322164157.GE28468@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180322164157.GE28468@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Netdev <netdev@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Eric Dumazet <eric.dumazet@gmail.com>

On Thu, Mar 22, 2018 at 09:41:57AM -0700, Matthew Wilcox wrote:
> On Thu, Mar 22, 2018 at 09:22:31AM -0700, Alexander Duyck wrote:
> > You could just use the pfc->mask here instead of size - 1 just to
> > avoid having to do the subtraction more than once assuming the
> > compiler doesn't optimize it.
> 
> Either way I'm assuming a compiler optimisation -- that it won't reload
> from memory, or that it'll remember the subtraction.  I don't much care
> which, and I'll happily use the page_frag_cache_mask() if that reads better
> for you.

Looks like it does reload from memory if I make that change.  Before:

    37e7:       c7 43 08 ff 7f 00 00    movl   $0x7fff,0x8(%rbx)
    37ee:       b9 00 80 00 00          mov    $0x8000,%ecx
    37f3:       be ff 7f 00 00          mov    $0x7fff,%esi
    37f8:       ba 00 80 00 00          mov    $0x8000,%edx
...
    380b:       01 70 1c                add    %esi,0x1c(%rax)

After:

    37e7:       c7 43 08 ff 7f 00 00    movl   $0x7fff,0x8(%rbx)
    37ee:       b9 00 80 00 00          mov    $0x8000,%ecx
    37f3:       ba 00 80 00 00          mov    $0x8000,%edx
...
    3806:       8b 73 08                mov    0x8(%rbx),%esi
    3809:       01 70 1c                add    %esi,0x1c(%rax)

Of course, it's shorter because it's fewer bytes to reload from memory
than it is to put a 32-bit immediate in the instruction stream, but
it's one additional memory reference (cache-hot, of course).  I don't
really care because it's the cold path.
