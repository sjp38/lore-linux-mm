Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 31C6D6B0006
	for <linux-mm@kvack.org>; Tue,  5 Jun 2018 15:54:02 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id d64-v6so1764577pfd.13
        for <linux-mm@kvack.org>; Tue, 05 Jun 2018 12:54:02 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g36-v6sor17694845plb.4.2018.06.05.12.54.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 05 Jun 2018 12:54:01 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH] mremap: Avoid TLB flushing anonymous pages that are not
 in swap cache
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <20180605171319.uc5jxdkxopio6kg3@techsingularity.net>
Date: Tue, 5 Jun 2018 12:53:57 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <EAD124C4-FFA4-4894-AE8B-33949CD6731B@gmail.com>
References: <20180605171319.uc5jxdkxopio6kg3@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Aaron Lu <aaron.lu@intel.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

Mel Gorman <mgorman@techsingularity.net> wrote:

> Commit 5d1904204c99 ("mremap: fix race between mremap() and page =
cleanning")
> fixed races between mremap and other operations for both file-backed =
and
> anonymous mappings. The file-backed was the most critical as it =
allowed the
> possibility that data could be changed on a physical page after =
page_mkclean
> returned which could trigger data loss or data integrity issues. A =
customer
> reported that the cost of the TLBs for anonymous regressions was =
excessive
> and resulting in a 30-50% drop in performance overall since this =
commit
> on a microbenchmark. Unfortunately I neither have access to the =
test-case
> nor can I describe what it does other than saying that mremap =
operations
> dominate heavily.
>=20
> The anonymous page race fix is overkill for two reasons. Pages that =
are not
> in the swap cache are not going to be issued for IO and if a stale TLB =
entry
> is used, the write still occurs on the same physical page. Any race =
with
> mmap replacing the address space is handled by mmap_sem. As anonymous =
pages
> are often dirty, it can mean that mremap always has to flush even when =
it is
> not necessary.
>=20
> This patch special cases anonymous pages to only flush if the page is =
in
> swap cache and can be potentially queued for IO. It uses the page lock =
to
> serialise against any potential reclaim. If the page is added to the =
swap
> cache on the reclaim side after the page lock is dropped on the mremap
> side then reclaim will call try_to_unmap_flush_dirty() before issuing
> any IO so there is no data integrity issue. This means that in the =
common
> case where a workload avoids swap entirely that mremap is a much =
cheaper
> operation due to the lack of TLB flushes.
>=20
> Using another testcase that simply calls mremap heavily with varying =
number
> of threads, it was found that very broadly speaking that TLB =
shootdowns
> were reduced by 31% on average throughout the entire test case but =
your
> milage will vary.
>=20
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> ---
> mm/mremap.c | 42 +++++++++++++++++++++++++++++++++++++-----
> 1 file changed, 37 insertions(+), 5 deletions(-)
>=20
> diff --git a/mm/mremap.c b/mm/mremap.c
> index 049470aa1e3e..d26c5a00fd9d 100644
> --- a/mm/mremap.c
> +++ b/mm/mremap.c
> @@ -24,6 +24,7 @@
> #include <linux/uaccess.h>
> #include <linux/mm-arch-hooks.h>
> #include <linux/userfaultfd_k.h>
> +#include <linux/mm_inline.h>
>=20
> #include <asm/cacheflush.h>
> #include <asm/tlbflush.h>
> @@ -112,6 +113,41 @@ static pte_t move_soft_dirty_pte(pte_t pte)
> 	return pte;
> }
>=20
> +/* Returns true if a TLB must be flushed before PTL is dropped */
> +static bool should_force_flush(pte_t *pte)
> +{
> +	bool is_swapcache;
> +	struct page *page;
> +
> +	if (!pte_present(*pte) || !pte_dirty(*pte))
> +		return false;
> +
> +	/*
> +	 * If we are remapping a dirty file PTE, make sure to flush TLB
> +	 * before we drop the PTL for the old PTE or we may race with
> +	 * page_mkclean().
> +	 */
> +	page =3D pte_page(*pte);
> +	if (page_is_file_cache(page))
> +		return true;
> +
> +	/*
> +	 * For anonymous pages, only flush swap cache pages that could
> +	 * be unmapped and queued for swap since =
flush_tlb_batched_pending was
> +	 * last called. Reclaim itself takes care that the TLB is =
flushed
> +	 * before IO is queued. If a page is not in swap cache and a =
stale TLB
> +	 * is used before mremap is complete then the write hits the =
same
> +	 * physical page and there is no lost data loss. Check under the
> +	 * page lock to avoid any potential race with reclaim.
> +	 */
> +	if (!trylock_page(page))
> +		return true;
> +	is_swapcache =3D PageSwapCache(page);
> +	unlock_page(page);
> +
> +	return is_swapcache;
> +}

While I do not have a specific reservation regarding the logic, I find =
the
current TLB invalidation scheme hard to follow and inconsistent. I guess
should_force_flush() can be extended and used more commonly to make =
things
clearer.

To be more specific and to give an example: Can should_force_flush() be =
used
in zap_pte_range() to set the force_flush instead of the current code?

  if (!PageAnon(page)) {
	if (pte_dirty(ptent)) {
		force_flush =3D 1;
		...
  	}
