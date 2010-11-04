Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id B38616B00BB
	for <linux-mm@kvack.org>; Thu,  4 Nov 2010 10:12:20 -0400 (EDT)
Message-ID: <4CD2BF1C.10608@redhat.com>
Date: Thu, 04 Nov 2010 10:11:40 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Revalidate page->mapping in do_generic_file_read()
References: <20101103220941.C88FA932@kernel.beaverton.ibm.com>
In-Reply-To: <20101103220941.C88FA932@kernel.beaverton.ibm.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, arunabal@in.ibm.com, sbest@us.ibm.com, stable <stable@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Al Viro <viro@zeniv.linux.org.uk>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On 11/03/2010 06:09 PM, Dave Hansen wrote:
> 70 hours into some stress tests of a 2.6.32-based enterprise kernel,
> we ran into a NULL dereference in here:
>
> 	int block_is_partially_uptodate(struct page *page, read_descriptor_t *desc,
> 	                                        unsigned long from)
> 	{
> ---->		struct inode *inode = page->mapping->host;
>
> It looks like page->mapping was the culprit.  (xmon trace is below).
> After closer examination, I realized that do_generic_file_read() does
> a find_get_page(), and eventually locks the page before calling
> block_is_partially_uptodate().  However, it doesn't revalidate the
> page->mapping after the page is locked.  So, there's a small window
> between the find_get_page() and ->is_partially_uptodate() where the
> page could get truncated and page->mapping cleared.
>
> We _have_ a reference, so it can't get reclaimed, but it certainly
> can be truncated.

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
