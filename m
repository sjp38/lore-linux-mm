Date: Wed, 23 Jan 2002 11:28:37 -0800 (PST)
Message-Id: <20020123.112837.112624842.davem@redhat.com>
Subject: Re: [PATCH *] rmap VM, version 12
From: "David S. Miller" <davem@redhat.com>
In-Reply-To: <Pine.LNX.4.33L.0201231720460.32617-100000@imladris.surriel.com>
References: <20020123.110624.93021436.davem@redhat.com>
	<Pine.LNX.4.33L.0201231720460.32617-100000@imladris.surriel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@conectiva.com.br
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

   On Wed, 23 Jan 2002, David S. Miller wrote:
   
   >    Actually, this is just using the pte_free_fast() and
   >    {get,free}_pgd_fast() functions on non-pae machines.
   >
   > Rofl, you can't just do that.  The page tables cache caches the kernel
   > mappings and if you don't update them properly on SMP you die.
   
   Umm, this list just contains _freed_ page tables without
   any mappings, right ?
   
No.

   If there is some specific magic I'm missing, could you
   please point me to the code I'm overlooking ? ;)
   
Look at what get_pgd_slow() in pgalloc.h does, this is the
case where it isn't going to the cache and it is really allocating the
memory.

When the pgd comes fresh off the cache chain, it doesn't do any
of this stuff, it just gives you the cached PGD with all the PMD's
filled in already, including the kernel PMDs.

Hmmm... maybe the "we can fault on kernel mappings" thing takes
care of this because kernel PMDs can only appear, not go away.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
