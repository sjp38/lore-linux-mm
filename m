Message-ID: <3D45E400.8E6DC52C@zip.com.au>
Date: Mon, 29 Jul 2002 17:55:28 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] nru replacement for 2.5.29
References: <Pine.LNX.4.44L.0207292136040.3086-100000@imladris.surriel.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: William Lee Irwin III <wli@holomorphy.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
> ...
> +       read_lock(&mapping->page_lock);
> +       for (page_idx = offset; page_idx > lower_limit; page_idx--) {
> +               page = radix_tree_lookup(&mapping->page_tree, page_idx);
> +
> +               if (!page || (!PageActive(page) && !PageReferenced(page)))
> +                       break;
> +
> +               deactivate_page(page);
> +       }
> +       read_unlock(&mapping->page_lock);

A lock ranking bug here, I think.

But that is OK - I'm bringing the pagevec code uptodate.
When that's up and running I can slot all the pages
into a pagevec here and do a gang deactivate outside the
page_lock.  

I wonder how to test this?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
