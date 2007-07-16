Date: Sun, 15 Jul 2007 23:20:31 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 1/5] avoid tlb gather restarts.
Message-Id: <20070715232031.5479614e.akpm@linux-foundation.org>
In-Reply-To: <20070703121228.254110263@de.ibm.com>
References: <20070703111822.418649776@de.ibm.com>
	<20070703121228.254110263@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: hugh@veritas.com, peterz@infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 03 Jul 2007 13:18:23 +0200 Martin Schwidefsky <schwidefsky@de.ibm.com> wrote:

> From: Martin Schwidefsky <schwidefsky@de.ibm.com>
> 
> If need_resched() is false in the inner loop of unmap_vmas it is
> unnecessary to do a full blown tlb_finish_mmu / tlb_gather_mmu for
> each ZAP_BLOCK_SIZE ptes. Do a tlb_flush_mmu() instead. That gives
> architectures with a non-generic tlb flush implementation room for
> optimization. The tlb_flush_mmu primitive is a available with the
> generic tlb flush code, the ia64_tlb_flush_mm needs to be renamed
> and a dummy function is added to arm and arm26.
> 
> Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
> ---
> 
>  include/asm-arm/tlb.h   |    5 +++++
>  include/asm-arm26/tlb.h |    5 +++++
>  include/asm-ia64/tlb.h  |    6 +++---
>  mm/memory.c             |   16 ++++++----------
>  4 files changed, 19 insertions(+), 13 deletions(-)

sparc64 broke:

mm/memory.c: In function `unmap_vmas':
mm/memory.c:862: error: too many arguments to function `tlb_flush_mmu'

grep, please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
