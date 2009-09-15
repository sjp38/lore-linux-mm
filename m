Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 7F3856B004F
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 12:02:07 -0400 (EDT)
Message-ID: <4AAFBA76.109@redhat.com>
Date: Tue, 15 Sep 2009 12:01:58 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch] mm: use-once mapped file pages
References: <1252971975-15218-1-git-send-email-hannes@cmpxchg.org> <28c262360909150826s2a0f5f0dpd111640f92d0f5ff@mail.gmail.com>
In-Reply-To: <28c262360909150826s2a0f5f0dpd111640f92d0f5ff@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Minchan Kim wrote:

> http://git.kernel.org/?p=linux/kernel/git/torvalds/old-2.6-bkcvs.git;a=commitdiff;h=fe23e022c442bb917815e206c4765cd9150faef5
> 
> At that time, Rik added following as.
> ( I hate wordwrap, but my google webmail will do ;( )
> 
> +       /* File is mmap'd by somebody. */
> +       if (!list_empty(&mapping->i_mmap) ||
> !list_empty(&mapping->i_mmap_shared))
> +               return 1;
> 
> It made your case worse as you noticed.

Other things changed since that code was added.

At the time, we set the page referenced bit at page fault
time, while today we propagate the referenced bit from the
page table to the struct page at MUNMAP time.

The code above was put in place to make sure the kernel
would cache often used (but very briefly mmaped) pages,
like the ones containing exec(3) in glibc.

However, propagating the referenced bit at munmap time
should have the same effect, allowing us to get rid of
my old page_mapping_inuse() code.

Frankly, I'm happy to see that code go :)

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
