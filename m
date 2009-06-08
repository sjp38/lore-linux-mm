Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 7D8596B004F
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 02:46:54 -0400 (EDT)
Date: Mon, 8 Jun 2009 15:52:46 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [rfc][patch] swap: virtual swap readahead
Message-ID: <20090608075246.GA12644@localhost>
References: <1243436746-2698-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="vtzGhvizbBRQ85DL"
Content-Disposition: inline
In-Reply-To: <1243436746-2698-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>


--vtzGhvizbBRQ85DL
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, May 27, 2009 at 05:05:46PM +0200, Johannes Weiner wrote:
> The current swap readahead implementation reads a physically
> contiguous group of swap slots around the faulting page to take
> advantage of the disk head's position and in the hope that the
> surrounding pages will be needed soon as well.
> 
> This works as long as the physical swap slot order approximates the
> LRU order decently, otherwise it wastes memory and IO bandwidth to
> read in pages that are unlikely to be needed soon.
> 
> However, the physical swap slot layout diverges from the LRU order
> with increasing swap activity, i.e. high memory pressure situations,
> and this is exactly the situation where swapin should not waste any
> memory or IO bandwidth as both are the most contended resources at
> this point.
> 
> This patch makes swap-in base its readaround window on the virtual
> proximity of pages in the faulting VMA, as an indicator for pages
> needed in the near future, while still taking physical locality of
> swap slots into account.
> 
> This has the advantage of reading in big batches when the LRU order
> matches the swap slot order while automatically throttling readahead
> when the system is thrashing and swap slots are no longer nicely
> grouped by LRU order.

Hi Johannes,

You may want to test the patch against a real desktop :)
The attached scripts can do that. I also have the setup to
test it out conveniently, so if you send me the latest patch..

Thanks,
Fengguang

> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> Cc: Rik van Riel <riel@redhat.com>
> ---
>  mm/swap_state.c |   80 +++++++++++++++++++++++++++++++++++++++----------------
>  1 files changed, 57 insertions(+), 23 deletions(-)
> 
> qsbench, 20 runs each, 1.7GB RAM, 2GB swap, 4 cores:
> 
>          "mean (standard deviation) median"
> 
> All values are given in seconds.  I used a t-test to make sure there
> is a statistical difference of at least 95% probability in the
> compared runs for the given number of samples, arithmetic mean and
> standard deviation.
> 
> 1 x 2048M
> vanilla: 391.25 ( 71.76) 384.56
> vswapra: 445.55 ( 83.19) 415.41
> 
> 	This is an actual regression.  I am not yet quite sure why
> 	this happens and I am undecided whether one humonguous active
> 	vma in the system is a common workload.
> 
> 	It's also the only regression I found, with qsbench anyway.  I
> 	started out with powers of two and tweaked the parameters
> 	until the results between the two kernel versions differed.
> 
> 2 x 1024M
> vanilla: 384.25 ( 75.00) 423.08
> vswapra: 290.26 ( 31.38) 299.51
> 
> 4 x 540M
> vanilla: 553.91 (100.02) 554.57
> vswapra: 336.58 ( 52.49) 331.52
> 
> 8 x 280M
> vanilla: 561.08 ( 82.36) 583.12
> vswapra: 319.13 ( 43.17) 307.69
> 
> 16 x 128M
> vanilla: 285.51 (113.20) 236.62
> vswapra: 214.24 ( 62.37) 214.15
> 
> 	All these show a nice improvement in performance and runtime
> 	stability.
> 
> The missing shmem support is a big TODO, I will try to find time to
> tackle this when the overall idea is not refused in the first place.
> 
> diff --git a/mm/swap_state.c b/mm/swap_state.c
> index 3ecea98..8f8daaa 100644
> --- a/mm/swap_state.c
> +++ b/mm/swap_state.c
> @@ -336,11 +336,6 @@ struct page *read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
>   *
>   * Returns the struct page for entry and addr, after queueing swapin.
>   *
> - * Primitive swap readahead code. We simply read an aligned block of
> - * (1 << page_cluster) entries in the swap area. This method is chosen
> - * because it doesn't cost us any seek time.  We also make sure to queue
> - * the 'original' request together with the readahead ones...
> - *
>   * This has been extended to use the NUMA policies from the mm triggering
>   * the readahead.
>   *
> @@ -349,27 +344,66 @@ struct page *read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
>  struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
>  			struct vm_area_struct *vma, unsigned long addr)
>  {
> -	int nr_pages;
> -	struct page *page;
> -	unsigned long offset;
> -	unsigned long end_offset;
> -
> -	/*
> -	 * Get starting offset for readaround, and number of pages to read.
> -	 * Adjust starting address by readbehind (for NUMA interleave case)?
> -	 * No, it's very unlikely that swap layout would follow vma layout,
> -	 * more likely that neighbouring swap pages came from the same node:
> -	 * so use the same "addr" to choose the same node for each swap read.
> -	 */
> -	nr_pages = valid_swaphandles(entry, &offset);
> -	for (end_offset = offset + nr_pages; offset < end_offset; offset++) {
> -		/* Ok, do the async read-ahead now */
> -		page = read_swap_cache_async(swp_entry(swp_type(entry), offset),
> -						gfp_mask, vma, addr);
> +	int cluster = 1 << page_cluster;
> +	int window = cluster << PAGE_SHIFT;
> +	unsigned long start, pos, end;
> +	unsigned long pmin, pmax;
> +
> +	/* XXX: fix this for shmem */
> +	if (!vma || !vma->vm_mm)
> +		goto nora;
> +
> +	/* Physical range to read from */
> +	pmin = swp_offset(entry) & ~(cluster - 1);
> +	pmax = pmin + cluster;
> +
> +	/* Virtual range to read from */
> +	start = addr & ~(window - 1);
> +	end = start + window;
> +
> +	for (pos = start; pos < end; pos += PAGE_SIZE) {
> +		struct page *page;
> +		swp_entry_t swp;
> +		spinlock_t *ptl;
> +		pgd_t *pgd;
> +		pud_t *pud;
> +		pmd_t *pmd;
> +		pte_t *pte;
> +
> +		pgd = pgd_offset(vma->vm_mm, pos);
> +		if (!pgd_present(*pgd))
> +			continue;
> +		pud = pud_offset(pgd, pos);
> +		if (!pud_present(*pud))
> +			continue;
> +		pmd = pmd_offset(pud, pos);
> +		if (!pmd_present(*pmd))
> +			continue;
> +		pte = pte_offset_map_lock(vma->vm_mm, pmd, pos, &ptl);
> +		if (!is_swap_pte(*pte)) {
> +			pte_unmap_unlock(pte, ptl);
> +			continue;
> +		}
> +		swp = pte_to_swp_entry(*pte);
> +		pte_unmap_unlock(pte, ptl);
> +
> +		if (swp_type(swp) != swp_type(entry))
> +			continue;
> +		/*
> +		 * Dont move the disk head too far away.  This also
> +		 * throttles readahead while thrashing, where virtual
> +		 * order diverges more and more from physical order.
> +		 */
> +		if (swp_offset(swp) > pmax)
> +			continue;
> +		if (swp_offset(swp) < pmin)
> +			continue;
> +		page = read_swap_cache_async(swp, gfp_mask, vma, pos);
>  		if (!page)
> -			break;
> +			continue;
>  		page_cache_release(page);
>  	}
>  	lru_add_drain();	/* Push any new pages onto the LRU now */
> +nora:
>  	return read_swap_cache_async(entry, gfp_mask, vma, addr);
>  }
> -- 
> 1.6.3
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--vtzGhvizbBRQ85DL
Content-Type: application/x-sh
Content-Disposition: attachment; filename="run-many-x-apps.sh"
Content-Transfer-Encoding: quoted-printable

#!/bin/zsh=0A# why zsh? bash does not support floating numbers=0A=0A# aptit=
ude install iceweasel gnome-games=0A# aptitude install openoffice.org # and=
 uncomment the oo* lines=0A=0A=0Aread T0 T1 < /proc/uptime=0A=0Afunction pr=
ogress()=0A{=0A	read t0 t1 < /proc/uptime=0A	t=3D$((t0 - T0))=0A	printf "%8=
=2E2f    " $t=0A	echo "$@"=0A}=0A=0Afunction switch_windows()=0A{=0A	wmctrl=
 -l | while read a b c win=0A	do=0A		progress A "$win"=0A		wmctrl -a "$win"=
=0A	done=0A	firefox /usr/share/doc/debian/FAQ/index.html=0A}=0A=0Awhile rea=
d app args=0Ado=0A	progress N $app $args=0A	$app $args &=0A	switch_windows=
=0Adone << EOF=0Axeyes=0Afirefox=0Anautilus=0Anautilus --browser=0Agthumb=
=0Agedit=0Axpdf /usr/share/doc/shared-mime-info/shared-mime-info-spec.pdf=
=0A=0Axterm=0Amlterm=0Agnome-terminal=0Aurxvt=0A=0Agnome-system-monitor=0Ag=
nome-help=0Agnome-dictionary=0A=0A/usr/games/sol=0A/usr/games/gnometris=0A/=
usr/games/gnect=0A/usr/games/gtali=0A/usr/games/iagno=0A/usr/games/gnotrave=
x=0A/usr/games/mahjongg=0A/usr/games/gnome-sudoku=0A/usr/games/glines=0A/us=
r/games/glchess=0A/usr/games/gnomine=0A/usr/games/gnotski=0A/usr/games/gnib=
bles=0A/usr/games/gnobots2=0A/usr/games/blackjack=0A/usr/games/same-gnome=
=0A=0A/usr/bin/gnome-window-properties=0A/usr/bin/gnome-default-application=
s-properties=0A/usr/bin/gnome-at-properties=0A/usr/bin/gnome-typing-monitor=
=0A/usr/bin/gnome-at-visual=0A/usr/bin/gnome-sound-properties=0A/usr/bin/gn=
ome-at-mobility=0A/usr/bin/gnome-keybinding-properties=0A/usr/bin/gnome-abo=
ut-me=0A/usr/bin/gnome-display-properties=0A/usr/bin/gnome-network-preferen=
ces=0A/usr/bin/gnome-mouse-properties=0A/usr/bin/gnome-appearance-propertie=
s=0A/usr/bin/gnome-control-center=0A/usr/bin/gnome-keyboard-properties=0A=
=0A: oocalc=0A: oodraw=0A: ooimpress=0A: oomath=0A: ooweb=0A: oowriter    =
=0A=0AEOF=0A
--vtzGhvizbBRQ85DL
Content-Type: application/x-sh
Content-Disposition: attachment; filename="test-mmap-exec-prot.sh"
Content-Transfer-Encoding: quoted-printable

#!/bin/sh=0A=0Aprot=3D$(</proc/sys/fs/suid_dumpable)=0Aecho $prot=0A=0ADISP=
LAY=3D:0.0 ./run-many-x-apps.sh | tee progress.$prot=0A=0Acp /proc/vmstat v=
mstat.$prot=0Acp /proc/meminfo meminfo.$prot=0Afree > free.$prot=0A
--vtzGhvizbBRQ85DL--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
