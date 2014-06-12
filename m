Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 8E83A6B0075
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 16:00:19 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id fp1so1296144pdb.31
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 13:00:19 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id sm10si2169551pab.134.2014.06.12.13.00.18
        for <linux-mm@kvack.org>;
        Thu, 12 Jun 2014 13:00:18 -0700 (PDT)
Date: Thu, 12 Jun 2014 13:00:17 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/vmscan.c: wrap five parameters into arg_container in
 shrink_page_list()
Message-Id: <20140612130017.865034e4e606d53499508226@linux-foundation.org>
In-Reply-To: <1402565795-706-1-git-send-email-slaoub@gmail.com>
References: <1402565795-706-1-git-send-email-slaoub@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Yucong <slaoub@gmail.com>
Cc: mgorman@suse.de, hannes@cmpxchg.org, mhocko@suse.cz, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 12 Jun 2014 17:36:35 +0800 Chen Yucong <slaoub@gmail.com> wrote:

> shrink_page_list() has too many arguments that have already reached ten.
> Some of those arguments and temporary variables introduces extra 80 bytes
> on the stack.
> 
> This patch wraps five parameters into arg_container and removes some temporary
> variables, thus making shrink_page_list() to consume fewer stack space.
> 
> Before mm/vmscan.c is modified:
>    text	   data	    bss	    dec	    hex	filename
> 6876698	 957224	 966656	8800578	 864942	vmlinux-3.15
> 
> After mm/vmscan.c is changed:
>    text	   data	    bss	    dec	    hex	filename
> 6876506	 957224	 966656	8800386	 864882	vmlinux-3.15

Code size reduction is a good sign.

>  1 file changed, 29 insertions(+), 35 deletions(-)

We can look at the frame pointer alterations.  Requires
CONFIG_FRAME_POINTER.  There's also scripts/checkstack.pl.

Without:

shrink_page_list:
	pushq	%rbp	#
	movq	%rsp, %rbp	#,
	pushq	%r15	#
	pushq	%r14	#
	pushq	%r13	#
	pushq	%r12	#
	pushq	%rbx	#
	subq	$184, %rsp	#,

With:

shrink_page_list:
	pushq	%rbp	#
	movq	%rsp, %rbp	#,
	pushq	%r15	#
	pushq	%r14	#
	pushq	%r13	#
	pushq	%r12	#
	pushq	%rbx	#
	subq	$136, %rsp	#,

So we've saved approx 184-136=48 bytes of stack in shrink_page_list(). 
shrink_inactive_list() stack space is unchanged.

Please do this sort of analysis yourself and include it in the changelogs.

> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -790,6 +790,14 @@ static void page_check_dirty_writeback(struct page *page,
>  		mapping->a_ops->is_dirty_writeback(page, dirty, writeback);
>  }
>  
> +struct arg_container {
> +	unsigned long nr_dirty;
> +	unsigned long nr_unqueued_dirty;
> +	unsigned long nr_congested;
> +	unsigned long nr_writeback;
> +	unsigned long nr_immediate;
> +};

This name is dreadful.  Let's give it a nice, meaningful name and
document it appropriately.  So it all looks like a part of the vmscan
code and not some hack which was bolted onto the side to save a bit of
stack.

Something like

/*
 * Callers pass a prezeroed shrink_result into the shrink functions to gather
 * statistics about how many pages of particular states were processed
 */
struct shrink_result {
	...


>  /*
>   * shrink_page_list() returns the number of reclaimed pages
>   */
>
> ...
>
> @@ -1148,7 +1142,8 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
>  		.priority = DEF_PRIORITY,
>  		.may_unmap = 1,
>  	};
> -	unsigned long ret, dummy1, dummy2, dummy3, dummy4, dummy5;
> +	unsigned long ret;
> +	struct arg_container dummy;

If we're not going to use this then we can make it static and save more
stack.  That will have some runtime cost as different CPUs fight over
ownership of cachelines but I doubt if it will be significant.

If we leave it on the stack then this code will send kmemcheck berzerk
with all the used-uninitialized errors.  Presumably that it already the
case.  Perhaps `dummy' should be initialized if kmemcheck is in
operation, dunno.


>  	struct page *page, *next;
>  	LIST_HEAD(clean_pages);
>  
>
> ...
>
> @@ -1469,11 +1463,13 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>  	unsigned long nr_scanned;
>  	unsigned long nr_reclaimed = 0;
>  	unsigned long nr_taken;
> -	unsigned long nr_dirty = 0;
> -	unsigned long nr_congested = 0;
> -	unsigned long nr_unqueued_dirty = 0;
> -	unsigned long nr_writeback = 0;
> -	unsigned long nr_immediate = 0;
> +	struct arg_container ac = {
> +		.nr_dirty = 0,
> +		.nr_congested = 0,
> +		.nr_unqueued_dirty = 0,
> +		.nr_writeback = 0,
> +		.nr_immediate = 0,
> +	};

This:

	struct arg_container ac = { };

>  	isolate_mode_t isolate_mode = 0;
>  	int file = is_file_lru(lru);
>  	struct zone *zone = lruvec_zone(lruvec);
>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
