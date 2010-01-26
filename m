Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 1A8366B009E
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 11:12:58 -0500 (EST)
Message-ID: <4B5F1460.7030106@redhat.com>
Date: Tue, 26 Jan 2010 11:12:16 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 04 of 31] update futex compound knowledge
References: <patchbomb.1264513915@v2.random> <948638099c17d3da3d6f.1264513919@v2.random>
In-Reply-To: <948638099c17d3da3d6f.1264513919@v2.random>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, Christoph Hellwig <chellwig@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On 01/26/2010 08:51 AM, Andrea Arcangeli wrote:
> From: Andrea Arcangeli<aarcange@redhat.com>
>
> Futex code is smarter than most other gup_fast O_DIRECT code and knows about
> the compound internals. However now doing a put_page(head_page) will not
> release the pin on the tail page taken by gup-fast, leading to all sort of
> refcounting bugchecks. Getting a stable head_page is a little tricky.
>
> Signed-off-by: Andrea Arcangeli<aarcange@redhat.com>
> ---
>
> diff --git a/kernel/futex.c b/kernel/futex.c
> --- a/kernel/futex.c
> +++ b/kernel/futex.c
> @@ -218,7 +218,7 @@ get_futex_key(u32 __user *uaddr, int fsh
>   {
>   	unsigned long address = (unsigned long)uaddr;
>   	struct mm_struct *mm = current->mm;
> -	struct page *page;
> +	struct page *page, *page_head;
>   	int err;
>
>   	/*
> @@ -250,10 +250,32 @@ again:
>   	if (err<  0)
>   		return err;
>
> -	page = compound_head(page);
> -	lock_page(page);
> -	if (!page->mapping) {
> -		unlock_page(page);
> +	page_head = page;

...

> +	if (unlikely(page_head != page)) {

Should the line above be "page_head = compound_head(page);" or
am I missing something?

If I am missing something, the changelog message could be a
little more verbose :)

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
