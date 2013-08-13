Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 9EF096B0032
	for <linux-mm@kvack.org>; Tue, 13 Aug 2013 06:58:51 -0400 (EDT)
Received: by mail-ee0-f44.google.com with SMTP id b47so4086376eek.17
        for <linux-mm@kvack.org>; Tue, 13 Aug 2013 03:58:50 -0700 (PDT)
Date: Tue, 13 Aug 2013 12:58:47 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [RFC v3 0/5] Transparent on-demand struct page initialization
 embedded in the buddy allocator
Message-ID: <20130813105847.GC2170@gmail.com>
References: <1375465467-40488-1-git-send-email-nzimmer@sgi.com>
 <1376344480-156708-1-git-send-email-nzimmer@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1376344480-156708-1-git-send-email-nzimmer@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nathan Zimmer <nzimmer@sgi.com>
Cc: hpa@zytor.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, holt@sgi.com, rob@landley.net, travis@sgi.com, daniel@numascale-asia.com, akpm@linux-foundation.org, gregkh@linuxfoundation.org, yinghai@kernel.org, mgorman@suse.de, Linus Torvalds <torvalds@linux-foundation.org>


* Nathan Zimmer <nzimmer@sgi.com> wrote:

> We are still restricting ourselves ourselves to 2MiB initialization. 
> This was initially to keep the patch set a little smaller and more 
> clear. However given how well it is currently performing I don't see a 
> how much better it could be with to 2GiB chunks.
> 
> As far as extra overhead. We incur an extra function call to 
> ensure_page_is_initialized but that is only really expensive when we 
> find uninitialized pages, otherwise it is a flag check once every 
> PTRS_PER_PMD. [...]

Mind expanding on this in more detail?

The main fastpath overhead we are really interested in is the 'memory is 
already fully ininialized and we reallocate a second time' case - i.e. the 
*second* (and subsequent), post-initialization allocation of any page 
range.

Those allocations are the ones that matter most: they will occur again and 
again, for the lifetime of the booted up system.

What extra overhead is there in that case? Only a flag check that is 
merged into an existing flag check (in free_pages_check()) and thus is 
essentially zero overhead? Or is it more involved - if yes, why?

One would naively think that nothing but the flags check is needed in this 
case: if all 512 pages in an aligned 2MB block is fully initialized, and 
marked as initialized in all the 512 page heads, then no other runtime 
check will be needed in the future.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
