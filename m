Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 5E3156B0085
	for <linux-mm@kvack.org>; Tue, 14 May 2013 12:50:46 -0400 (EDT)
Message-ID: <51926B64.5040005@sr71.net>
Date: Tue, 14 May 2013 09:50:44 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 6/7] use __remove_mapping_batch() in shrink_page_list()
References: <20130507211954.9815F9D1@viggo.jf.intel.com> <20130507212002.219EDB7F@viggo.jf.intel.com> <20130514160541.GX11497@suse.de>
In-Reply-To: <20130514160541.GX11497@suse.de>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, tim.c.chen@linux.intel.com

On 05/14/2013 09:05 AM, Mel Gorman wrote:
> This helper seems overkill. Why not just have batch_mapping in
> shrink_page_list() that is set when the first page is added to the
> batch_for_mapping_removal and defer the decision to drain until after the
> page mapping has been looked up?
> 
> struct address_space *batch_mapping = NULL;
> 
> .....
> 
> mapping = page_mapping(page);
> if (!batch_mapping)
> 	batch_mapping = mapping;
> 
> if (!list_empty(&batch_for_mapping_removal) && mapping != batch_mapping) {
> 	nr_reclaimed += __remove_mapping_batch(....);
> 	batch_mapping = mapping;
> }

I was trying to avoid doing the batch drain while holding lock_page() on
an unrelated page.  But, now that I think about it, that was probably
unsafe anyway.  The page could have been truncated out of the mapping
since it *was* before lock_page().

I think I was also trying to save adding another local variable, but
you're right that it's overkill.  I'll fix it up.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
