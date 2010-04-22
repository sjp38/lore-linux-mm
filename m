Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id D8F1D6B01F5
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 11:17:44 -0400 (EDT)
Message-ID: <4BD0688A.7050806@redhat.com>
Date: Thu, 22 Apr 2010 11:17:30 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [BUG] rmap: fix page_address_in_vma() to walk through anon_vma_chain
References: <20100422054241.GB10957@spritzerA.linux.bs1.fc.nec.co.jp>
In-Reply-To: <20100422054241.GB10957@spritzerA.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

On 04/22/2010 01:42 AM, Naoya Horiguchi wrote:
> I found a bug on page_address_in_vma() related to anon_vma_chain.
>
> I wrote a patch, but according to a comment in include/linux/rmap.h,
> I suspect this doesn't meet lock requirement of anon_vma_chain
> (mmap_sem and page_table_lock, see below).
>
>                             mmap_sem      page_table_lock
>    mm/ksm.c:
>      write_protect_page()   hold          not hold
>      replace_page()         hold          not hold
>    mm/memory-failure.c:
>      add_to_kill()          not hold      hold
>    mm/mempolicy.c:
>      new_vma_page()         hold          not hold
>    mm/swapfile.c:
>      unuse_vma()            hold          not hold
>
> Any comments?

Good catch.

However, for anonymous pages, page_address_in_vma only
ever determined whether the page _could_ be part of the
VMA, never whether it actually was.

The function page_address_in_vma has always given
false positives, which means all of the callers already
check that the page is actually part of the process.

This means we may be able to get away with not verifying
the anon_vma at all.  After all, verifying that the VMA
has the anon_vma mapped does not mean the VMA has this
page...

Doing away with that check gets rid of your locking
conundrum :)

Opinions?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
