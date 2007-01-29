Date: Mon, 29 Jan 2007 12:02:23 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: swap: which is the maximum size allowed?
In-Reply-To: <epliuf$an7$1@sea.gmane.org>
Message-ID: <Pine.LNX.4.64.0701291157490.32345@schroedinger.engr.sgi.com>
References: <epliuf$an7$1@sea.gmane.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eriberto <eriberto@eriberto.pro.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 29 Jan 2007, Eriberto wrote:

> I am trying understand the swap. I would like to know which is the
> maximum swap size on i386. Is 64 GB? If yes, how to know the origin of
> this "magic" number? How to calculate it? I don't found it (Internet).

If you look at include/asm-i386/pgtable-2level.h


/*
 * Bits 0, 6 and 7 are taken, split up the 29 bits of offset
 * into this range:
 */
#define PTE_FILE_MAX_BITS       29

#define pte_to_pgoff(pte) \
        ((((pte).pte_low >> 1) & 0x1f ) + (((pte).pte_low >> 8) << 5 ))

#define pgoff_to_pte(off) \
        ((pte_t) { (((off) & 0x1f) << 1) + (((off) >> 5) << 8) + 
_PAGE_FILE })

/* Encode and de-code a swap entry */
#define __swp_type(x)                   (((x).val >> 1) & 0x1f)
#define __swp_offset(x)                 ((x).val >> 8)
#define __swp_entry(type, offset)       ((swp_entry_t) { ((type) << 1) | 
((offset) << 8) })
#define __pte_to_swp_entry(pte)         ((swp_entry_t) { (pte).pte_low })
#define __swp_entry_to_pte(x)           ((pte_t) { (x).val })

5 bits are used for the swap file number (__swp_type). This gives you 32 
swap fileswith 2^(29-5)*PAGE_SIZE = 64 GB each.

The swap size is bigger if you use 3 page table levels.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
