Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1A21F6B000C
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 21:31:47 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id t78-v6so636525pfa.8
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 18:31:47 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id o12-v6si4963671pgi.112.2018.07.24.18.31.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jul 2018 18:31:46 -0700 (PDT)
Date: Tue, 24 Jul 2018 18:31:42 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/3] mm: calculate deferred pages after skipping
 mirrored memory
Message-Id: <20180724183142.d20798b43fd1215f6165649c@linux-foundation.org>
In-Reply-To: <20180724235520.10200-3-pasha.tatashin@oracle.com>
References: <20180724235520.10200-1-pasha.tatashin@oracle.com>
	<20180724235520.10200-3-pasha.tatashin@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, linux-kernel@vger.kernel.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, linux-mm@kvack.org, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, jrdr.linux@gmail.com, bhe@redhat.com, gregkh@linuxfoundation.org, vbabka@suse.cz, richard.weiyang@gmail.com, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org, osalvador@techadventures.net, abdhalee@linux.vnet.ibm.com, mpe@ellerman.id.au

On Tue, 24 Jul 2018 19:55:19 -0400 Pavel Tatashin <pasha.tatashin@oracle.com> wrote:

> update_defer_init() should be called only when struct page is about to be
> initialized. Because it counts number of initialized struct pages, but
> there we may skip struct pages if there is some mirrored memory.
> 
> So move, update_defer_init() after checking for mirrored memory.
> 
> Also, rename update_defer_init() to defer_init() and reverse the return
> boolean to emphasize that this is a boolean function, that tells that the
> reset of memmap initialization should be deferred.
> 
> Make this function self-contained: do not pass number of already
> initialized pages in this zone by using static counters.
> 
> ...
>
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -306,24 +306,28 @@ static inline bool __meminit early_page_uninitialised(unsigned long pfn)
>  }
>  
>  /*
> - * Returns false when the remaining initialisation should be deferred until
> + * Returns true when the remaining initialisation should be deferred until
>   * later in the boot cycle when it can be parallelised.
>   */
> -static inline bool update_defer_init(pg_data_t *pgdat,
> -				unsigned long pfn, unsigned long zone_end,
> -				unsigned long *nr_initialised)
> +static inline bool defer_init(int nid, unsigned long pfn, unsigned long end_pfn)
>  {
> +	static unsigned long prev_end_pfn, nr_initialised;

So answer me quick, what happens with a static variable in an inlined
function?  Is there one copy kernel-wide?  One copy per invocation
site?  One copy per compilation unit?

Well I didn't know so I wrote a little test.  One copy per compilation
unit (.o file), it appears.

It's OK in this case because the function is in .c (and has only one
call site).  But if someone moves it into a header and uses it from a
different .c file, they have problems.

So it's dangerous, and poor practice.  I'll make this non-static
__meminit.

--- a/mm/page_alloc.c~mm-calculate-deferred-pages-after-skipping-mirrored-memory-fix
+++ a/mm/page_alloc.c
@@ -309,7 +309,8 @@ static inline bool __meminit early_page_
  * Returns true when the remaining initialisation should be deferred until
  * later in the boot cycle when it can be parallelised.
  */
-static inline bool defer_init(int nid, unsigned long pfn, unsigned long end_pfn)
+static bool __meminit
+defer_init(int nid, unsigned long pfn, unsigned long end_pfn)
 {
 	static unsigned long prev_end_pfn, nr_initialised;
 

Also, what locking protects these statics?  Our knowledge that this
code is single-threaded, presumably?
