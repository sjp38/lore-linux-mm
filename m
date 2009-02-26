Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 275F36B003D
	for <linux-mm@kvack.org>; Thu, 26 Feb 2009 04:20:24 -0500 (EST)
Subject: Re: [patch][rfc] mm: hold page lock over page_mkwrite
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20090225093629.GD22785@wotan.suse.de>
References: <20090225093629.GD22785@wotan.suse.de>
Content-Type: text/plain
Date: Thu, 26 Feb 2009 10:20:18 +0100
Message-Id: <1235640018.4645.4692.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2009-02-25 at 10:36 +0100, Nick Piggin wrote:
> +               if (!page_mkwrite)
> +                       wait_on_page_locked(dirty_page);
>                 set_page_dirty_balance(dirty_page, page_mkwrite);
>                 put_page(dirty_page);
> +               if (page_mkwrite) {
> +                       unlock_page(old_page);
> +                       page_cache_release(old_page);
> +               }

We're calling into the whole balance_dirty_pages() writeout path with a
page locked.. is that sensible?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
