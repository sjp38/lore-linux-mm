Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 57AF26B0047
	for <linux-mm@kvack.org>; Sun, 31 Jan 2010 10:57:23 -0500 (EST)
Date: Sun, 31 Jan 2010 15:57:19 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH] mm: Fix nr_good_pages calculation
In-Reply-To: <20100120151912.GA27747@angel.research.nokia.com>
Message-ID: <alpine.LSU.2.00.1001311538410.3817@sister.anvils>
References: <20100120151912.GA27747@angel.research.nokia.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Jarkko Lavinen <jarkko.lavinen@nokia.com>
Cc: Andrew Morton <akpm@osdl.org>, Nitin Gupta <ngupta@vflare.org>, Jakub Jelinek <jakub@redhat.com>, Karel Zak <kzak@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 20 Jan 2010, Jarkko Lavinen wrote:

> Swapon wastes one page of swap space to no effect.
> 
> Mkswap stores the value 'pages - 1' into last_page field, where pages is the
> partition size in pages.  When nr_good_pages is calculated, last_page + 1
> should be used for the number of all the pages header included.
> 
> Signed-off-by: Jarkko Lavinen <jarkko.lavinen@nokia.com>
> ---
>  mm/swapfile.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 6c0585b..50d90ca 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -1961,7 +1961,7 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
>  	if (error)
>  		goto bad_swap;
>  
> -	nr_good_pages = swap_header->info.last_page -
> +	nr_good_pages = swap_header->info.last_page + 1 -
>  			swap_header->info.nr_badpages -
>  			1 /* header page */;
>  
> -- 

Sorry to be so slow to respond: I needed to do a little research, and
find time to cool myself down near absolute zero to consider offs-by-one.

You're right that there's an off-by-one there: Nitin and I also noticed
it last year; but I'm afraid I have to Nack your patch, just as I did
Nitin's similar patch last August.

Fixing up nr_good_pages like that makes the numbers displayed look right;
but you're then inconsistent with p->max, counting a page which can never
get to be used.

Here's what I believe is the right patch: is this something you and Nitin
can give your Acks to, or do you see further issues with it?

Thanks,
Hugh


[PATCH] mm: fix swapon size off-by-one

There's an off-by-one disagreement between mkswap and swapon about the
meaning of swap_header last_page: mkswap (in all versions I've looked
at: util-linux-ng and BusyBox and old util-linux; probably as far back
as 1999) consistently means the offset (in page units) of the last page
of the swap area, whereas kernel sys_swapon (as far back as 2.2 and 2.3)
strangely takes it to mean the size (in page units) of the swap area.

This disagreement is the safe way round; but it's worrying people,
and loses us one page of swap.

The fix is not just to add one to nr_good_pages: we need to get maxpages
(the size of the swap_map array) right before that; and though that is an
unsigned long, be careful not to overflow the unsigned int p->max which
later holds it (probably why header uses __u32 last_page instead of size).

Why did we subtract one from the maximum swp_offset to calculate maxpages?
Though it was probably me who made that change in 2.4.10, I don't get it:
and now we should be adding one (without risk of overflow in this case).

Fix the handling of swap_header badpages: it could have overrun the
swap_map when very large swap area used on a more limited architecture.

Remove pre-initializations of swap_header, nr_good_pages and maxpages:
those date from when sys_swapon was supporting other versions of header.

Reported-by: Nitin Gupta <ngupta@vflare.org>
Reported-by: Jarkko Lavinen <jarkko.lavinen@nokia.com>
Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
---

 mm/swapfile.c |   31 ++++++++++++++++++-------------
 1 file changed, 18 insertions(+), 13 deletions(-)

--- 2.6.33-rc6/mm/swapfile.c	2009-12-18 11:42:55.000000000 +0000
+++ linux/mm/swapfile.c	2010-01-31 13:15:58.000000000 +0000
@@ -1759,11 +1759,11 @@ SYSCALL_DEFINE2(swapon, const char __use
 	unsigned int type;
 	int i, prev;
 	int error;
-	union swap_header *swap_header = NULL;
-	unsigned int nr_good_pages = 0;
+	union swap_header *swap_header;
+	unsigned int nr_good_pages;
 	int nr_extents = 0;
 	sector_t span;
-	unsigned long maxpages = 1;
+	unsigned long maxpages;
 	unsigned long swapfilepages;
 	unsigned char *swap_map = NULL;
 	struct page *page = NULL;
@@ -1922,9 +1922,13 @@ SYSCALL_DEFINE2(swapon, const char __use
 	 * swap pte.
 	 */
 	maxpages = swp_offset(pte_to_swp_entry(
-			swp_entry_to_pte(swp_entry(0, ~0UL)))) - 1;
-	if (maxpages > swap_header->info.last_page)
-		maxpages = swap_header->info.last_page;
+			swp_entry_to_pte(swp_entry(0, ~0UL)))) + 1;
+	if (maxpages > swap_header->info.last_page) {
+		maxpages = swap_header->info.last_page + 1;
+		/* p->max is an unsigned int: don't overflow it */
+		if ((unsigned int)maxpages == 0)
+			maxpages = UINT_MAX;
+	}
 	p->highest_bit = maxpages - 1;
 
 	error = -EINVAL;
@@ -1948,23 +1952,24 @@ SYSCALL_DEFINE2(swapon, const char __use
 	}
 
 	memset(swap_map, 0, maxpages);
+	nr_good_pages = maxpages - 1;	/* omit header page */
+
 	for (i = 0; i < swap_header->info.nr_badpages; i++) {
-		int page_nr = swap_header->info.badpages[i];
-		if (page_nr <= 0 || page_nr >= swap_header->info.last_page) {
+		unsigned int page_nr = swap_header->info.badpages[i];
+		if (page_nr == 0 || page_nr > swap_header->info.last_page) {
 			error = -EINVAL;
 			goto bad_swap;
 		}
-		swap_map[page_nr] = SWAP_MAP_BAD;
+		if (page_nr < maxpages) {
+			swap_map[page_nr] = SWAP_MAP_BAD;
+			nr_good_pages--;
+		}
 	}
 
 	error = swap_cgroup_swapon(type, maxpages);
 	if (error)
 		goto bad_swap;
 
-	nr_good_pages = swap_header->info.last_page -
-			swap_header->info.nr_badpages -
-			1 /* header page */;
-
 	if (nr_good_pages) {
 		swap_map[0] = SWAP_MAP_BAD;
 		p->max = maxpages;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
