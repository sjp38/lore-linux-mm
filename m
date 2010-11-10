Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id ABEC16B0085
	for <linux-mm@kvack.org>; Wed, 10 Nov 2010 16:01:26 -0500 (EST)
Date: Wed, 10 Nov 2010 13:01:19 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] fix __set_page_dirty_no_writeback() return value
Message-Id: <20101110130119.ca352698.akpm@linux-foundation.org>
In-Reply-To: <1289379628-14044-1-git-send-email-lliubbo@gmail.com>
References: <1289379628-14044-1-git-send-email-lliubbo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Bob Liu <lliubbo@gmail.com>
Cc: fengguang.wu@intel.com, linux-mm@kvack.org, kenchen@google.com
List-ID: <linux-mm.kvack.org>

On Wed, 10 Nov 2010 17:00:27 +0800
Bob Liu <lliubbo@gmail.com> wrote:

> __set_page_dirty_no_writeback() should return true if it actually transitioned
> the page from a clean to dirty state although it seems nobody used its return
> value now.
> 
> Signed-off-by: Bob Liu <lliubbo@gmail.com>
> ---
>  mm/page-writeback.c |    4 +---
>  1 files changed, 1 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index bf85062..e8f5f06 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -1157,9 +1157,7 @@ EXPORT_SYMBOL(write_one_page);
>   */
>  int __set_page_dirty_no_writeback(struct page *page)
>  {
> -	if (!PageDirty(page))
> -		SetPageDirty(page);
> -	return 0;
> +	return !TestSetPageDirty(page);
>  }

The idea here is to avoid modifying the cacheline which contains the
pageframe if that page was already dirty.  So that a set_page_dirty()
against an already-dirty page doesn't result in the CPU having to
perform writeback of the cacheline.

The code as it stands assumes that a test_and_set_bit() will
unconditionally modify the target.  This might not be true of certain
CPUs - perhaps they optimise away the write in that case, I don't know.

Yes, you're right, __set_page_dirty_no_writeback() should return the
correct value.  But the way to do that while preserving this
optimisation is

	if (!PageDirty(page))
		return !TestSetPageDirty(page);
	return 0;


This optimisation is used in quite a few places and is done in
differeing ways depending upon what is being modified.  I've never
really seen any quantification of its effectiveness.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
