Date: Mon, 25 Sep 2000 03:45:51 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] vmfixes-2.4.0-test9-B2
Message-ID: <20000925034551.C10381@athlon.random>
References: <Pine.LNX.4.10.10009241646560.974-100000@penguin.transmeta.com> <Pine.LNX.4.21.0009242143040.2029-100000@freak.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0009242143040.2029-100000@freak.distro.conectiva>; from marcelo@conectiva.com.br on Sun, Sep 24, 2000 at 09:53:33PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: Linus Torvalds <torvalds@transmeta.com>, Ingo Molnar <mingo@elte.hu>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, Sep 24, 2000 at 09:53:33PM -0300, Marcelo Tosatti wrote:
> Btw, why we need kmem_cache_shrink() inside shrink_{i,d}cache_memory ?  

Because kmem_cache_free doesn't free anything. It only queues slab
objects into the partial and free part of the cachep slab queue (so that
they're ready to be freed later, and that's what we do in shrink_slab_cache).

> calls shrink_{i,d}cache_memory) already shrink the SLAB cache (with
> kmem_cache_reap), I dont think its needed.

kmem_cache_reap shrinks the slabs at _very_ low frequency. It's worthless to
keep lots of dentries and icache into the slab internal queues until
kmem_cache_reap kicks in again, if we free them such memory immediatly instead
we'll run kmem_cache_reap later and for something more appropraite for what's
been designed. The [id]cache shrink could release lots of memory.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
