Date: Tue, 25 Mar 2008 21:23:50 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [Bugme-new] [Bug 10318] New: WARNING: at
	arch/x86/mm/highmem_32.c:43 kmap_atomic_prot+0x87/0x184()
Message-ID: <20080325202350.GH15330@elte.hu>
References: <bug-10318-10286@http.bugzilla.kernel.org/> <20080325105750.ff913a83.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080325105750.ff913a83.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org, pstaszewski@artcom.pl, linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

* Andrew Morton <akpm@linux-foundation.org> wrote:

> afacit what's happened is that someone is running __alloc_pages(..., 
> __GFP_ZERO) from softirq context.  But the __GFP_ZERO implementation 
> uses KM_USER0 which cannot be used from softirq context because 
> non-interrupt code on this CPU might be using the same kmap slot.
> 
> Can anyone thing of anything which recently changed in either 
> networking core or e1000e which would have triggered this?
> 
> I think the core MM code is being doubly dumb here.
> 
> a) We should be able to use __GFP_ZERO from all copntexts.
> 
> b) it's not a highmem page anyway, so we won't be using that kmap 
> slot.

i think this came up before (with kzalloc()) and the MM code should have 
been fixed to not even attempt a kmap_atomic(), instead of working it 
around in the callsite or in the kmap_atomic() code.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
