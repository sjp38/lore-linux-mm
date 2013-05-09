Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id D45226B0039
	for <linux-mm@kvack.org>; Thu,  9 May 2013 10:40:48 -0400 (EDT)
Message-ID: <518BB4F2.2040704@redhat.com>
Date: Thu, 09 May 2013 10:38:42 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] COMPACTION: bugfix of improper cache flush in MIGRATION
 code.
References: <20130509001821.15951.98705.stgit@linux-yegoshin>
In-Reply-To: <20130509001821.15951.98705.stgit@linux-yegoshin>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>
Cc: mhocko@suse.cz, akpm@linux-foundation.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 05/08/2013 08:18 PM, Leonid Yegoshin wrote:
> Page 'new' during MIGRATION can't be flushed by flush_cache_page().
> Using flush_cache_page(vma, addr, pfn) is justified only if
> page is already placed in process page table, and that is done right
> after flush_cache_page(). But without it the arch function has
> no knowledge of process PTE and does nothing.
>
> Besides that, flush_cache_page() flushes an application cache,
> kernel has a different page virtual address and dirtied it.
>
> Replace it with flush_dcache_page(new) which is a proper usage.
>
> Old page is flushed in try_to_unmap_one() before MIGRATION.
>
> This bug takes place in Sead3 board with M14Kc MIPS CPU without
> cache aliasing (but Harvard arch - separate I and D cache)
> in tight memory environment (128MB) each 1-3days on SOAK test.
> It fails in cc1 during kernel build (SIGILL, SIGBUS, SIGSEG) if
> CONFIG_COMPACTION is switched ON.

Good catch!

> Author: Leonid Yegoshin <yegoshin@mips.com>
> Signed-off-by: Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
