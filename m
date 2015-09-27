Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id DFC506B0038
	for <linux-mm@kvack.org>; Sat, 26 Sep 2015 21:36:39 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so143169731pac.2
        for <linux-mm@kvack.org>; Sat, 26 Sep 2015 18:36:39 -0700 (PDT)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id kg8si16515246pab.100.2015.09.26.18.36.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 26 Sep 2015 18:36:39 -0700 (PDT)
Received: by padhy16 with SMTP id hy16so140407010pad.1
        for <linux-mm@kvack.org>; Sat, 26 Sep 2015 18:36:39 -0700 (PDT)
Date: Sat, 26 Sep 2015 18:36:29 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: fix cpu hangs on truncating last page of a 16t sparse
 file
In-Reply-To: <560723F8.3010909@gmail.com>
Message-ID: <alpine.LSU.2.11.1509261835360.9917@eggly.anvils>
References: <560723F8.3010909@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: angelo <angelo70@gmail.com>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Let's Cc linux-fsdevel, who will be more knowledgable.

On Sun, 27 Sep 2015, angelo wrote:

> Hi all,
> 
> running xfstests, generic 308 on whatever 32bit arch is possible
> to observe cpu to hang near 100% on unlink.
> The test removes a sparse file of length 16tera where only the last
> 4096 bytes block is mapped.
> At line 265 of truncate.c there is a
> if (index >= end)
>     break;
> But if index is, as in this case, a 4294967295, it match -1 used as
> eof. Hence the cpu loops 100% just after.

That's odd.  I've not checked your patch, because I think the problem
would go beyond truncate, and the root cause lie elsewhere.

My understanding is that the 32-bit
#define MAX_LFS_FILESIZE (((loff_t)PAGE_CACHE_SIZE << (BITS_PER_LONG-1))-1) 
makes a page->index of -1 (or any "negative") impossible to reach.

I don't know offhand the rules for mounting a filesystem populated with
a 64-bit kernel on a 32-bit kernel, what's to happen when a too-large
file is encountered; but assume that's not the case here - you're
just running xfstests/tests/generic/308.

Is pwrite missing a check for offset beyond s_maxbytes?

Or is this filesystem-dependent?  Which filesystem?

Hugh

> 
> -------------------
> 
> On 32bit archs, with CONFIG_LBDAF=y, if truncating last page
> of a 16tera file, "index" variable is set to 4294967295, and hence
> matches with -1 used as EOF value. This result in an inifite loop
> when unlink is executed on this file.
> 
> Signed-off-by: Angelo Dureghello <angelo@sysam.it>
> ---
>  mm/truncate.c | 11 ++++++-----
>  1 file changed, 6 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/truncate.c b/mm/truncate.c
> index 76e35ad..3751034 100644
> --- a/mm/truncate.c
> +++ b/mm/truncate.c
> @@ -283,14 +283,15 @@ void truncate_inode_pages_range(struct address_space
> *mapping,
>                 pagevec_remove_exceptionals(&pvec);
>                 pagevec_release(&pvec);
>                 cond_resched();
> -               index++;
> +               if (index < end)
> +                       index++;
>         }
> 
>         if (partial_start) {
>                 struct page *page = find_lock_page(mapping, start - 1);
>                 if (page) {
>                         unsigned int top = PAGE_CACHE_SIZE;
> -                       if (start > end) {
> +                       if (start > end && end != -1) {
>                                 /* Truncation within a single page */
>                                 top = partial_end;
>                                 partial_end = 0;
> @@ -322,7 +323,7 @@ void truncate_inode_pages_range(struct address_space
> *mapping,
>          * If the truncation happened within a single page no pages
>          * will be released, just zeroed, so we can bail out now.
>          */
> -       if (start >= end)
> +       if (start >= end && end != -1)
>                 return;
> 
>         index = start;
> @@ -337,7 +338,7 @@ void truncate_inode_pages_range(struct address_space
> *mapping,
>                         index = start;
>                         continue;
>                 }
> -               if (index == start && indices[0] >= end) {
> +               if (index == start && (indices[0] >= end && end != -1)) {
>                         /* All gone out of hole to be punched, we're done */
>                         pagevec_remove_exceptionals(&pvec);
>                         pagevec_release(&pvec);
> @@ -348,7 +349,7 @@ void truncate_inode_pages_range(struct address_space
> *mapping,
> 
>                         /* We rely upon deletion not changing page->index */
>                         index = indices[i];
> -                       if (index >= end) {
> +                       if (index >= end && (end != -1)) {
>                                 /* Restart punch to make sure all gone */
>                                 index = start - 1;
>                                 break;
> -- 
> 2.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
