Date: Tue, 2 Dec 2008 16:56:54 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 7/8] badpage: ratelimit print_bad_pte and bad_page
Message-Id: <20081202165654.b84ffdad.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0812010045520.11401@blonde.site>
References: <Pine.LNX.4.64.0812010032210.10131@blonde.site>
	<Pine.LNX.4.64.0812010045520.11401@blonde.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: nickpiggin@yahoo.com.au, davej@redhat.com, arjan@infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 1 Dec 2008 00:46:53 +0000 (GMT)
Hugh Dickins <hugh@veritas.com> wrote:

> print_bad_pte() and bad_page() might each need ratelimiting - especially
> for their dump_stacks, almost never of interest, yet not quite dispensible.
> Correlating corruption across neighbouring entries can be very helpful,
> so allow a burst of 60 reports before keeping quiet for the remainder
> of that minute (or allow a steady drip of one report per second).
> 
> Signed-off-by: Hugh Dickins <hugh@veritas.com>
> ---
> 
>  mm/memory.c     |   23 +++++++++++++++++++++++
>  mm/page_alloc.c |   26 +++++++++++++++++++++++++-
>  2 files changed, 48 insertions(+), 1 deletion(-)
> 
> --- badpage6/mm/memory.c	2008-11-28 20:40:48.000000000 +0000
> +++ badpage7/mm/memory.c	2008-11-28 20:40:50.000000000 +0000
> @@ -383,6 +383,29 @@ static void print_bad_pte(struct vm_area
>  	pmd_t *pmd = pmd_offset(pud, addr);
>  	struct address_space *mapping;
>  	pgoff_t index;
> +	static unsigned long resume;
> +	static unsigned long nr_shown;
> +	static unsigned long nr_unshown;
> +
> +	/*
> +	 * Allow a burst of 60 reports, then keep quiet for that minute;
> +	 * or allow a steady drip of one report per second.
> +	 */
> +	if (nr_shown == 60) {
> +		if (time_before(jiffies, resume)) {
> +			nr_unshown++;
> +			return;
> +		}
> +		if (nr_unshown) {
> +			printk(KERN_EMERG
> +				"Bad page map: %lu messages suppressed\n",
> +				nr_unshown);
> +			nr_unshown = 0;
> +		}
> +		nr_shown = 0;
> +	}
> +	if (nr_shown++ == 0)
> +		resume = jiffies + 60 * HZ;
>  
>  	mapping = vma->vm_file ? vma->vm_file->f_mapping : NULL;
>  	index = linear_page_index(vma, addr);
> --- badpage6/mm/page_alloc.c	2008-11-28 20:40:42.000000000 +0000
> +++ badpage7/mm/page_alloc.c	2008-11-28 20:40:50.000000000 +0000
> @@ -223,6 +223,30 @@ static inline int bad_range(struct zone 
>  
>  static void bad_page(struct page *page)
>  {
> +	static unsigned long resume;
> +	static unsigned long nr_shown;
> +	static unsigned long nr_unshown;
> +
> +	/*
> +	 * Allow a burst of 60 reports, then keep quiet for that minute;
> +	 * or allow a steady drip of one report per second.
> +	 */
> +	if (nr_shown == 60) {
> +		if (time_before(jiffies, resume)) {
> +			nr_unshown++;
> +			goto out;
> +		}
> +		if (nr_unshown) {
> +			printk(KERN_EMERG
> +				"Bad page state: %lu messages suppressed\n",
> +				nr_unshown);
> +			nr_unshown = 0;
> +		}
> +		nr_shown = 0;
> +	}
> +	if (nr_shown++ == 0)
> +		resume = jiffies + 60 * HZ;
> +

gee, that's pretty elaborate.  There's no way of using the
possibly-enhanced ratelimit.h?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
