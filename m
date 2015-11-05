Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 95ADC82F64
	for <linux-mm@kvack.org>; Thu,  5 Nov 2015 03:23:52 -0500 (EST)
Received: by padhx2 with SMTP id hx2so72812343pad.1
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 00:23:52 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTPS id iv8si8505459pbc.11.2015.11.05.00.23.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 05 Nov 2015 00:23:51 -0800 (PST)
Date: Thu, 5 Nov 2015 17:23:59 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 3/5] mm, page_owner: copy page owner info during migration
Message-ID: <20151105082359.GB26034@js1304-P5Q-DELUXE>
References: <1446649261-27122-1-git-send-email-vbabka@suse.cz>
 <1446649261-27122-4-git-send-email-vbabka@suse.cz>
 <20151105081005.GB25938@js1304-P5Q-DELUXE>
 <563B109D.6030001@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <563B109D.6030001@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>

On Thu, Nov 05, 2015 at 09:17:33AM +0100, Vlastimil Babka wrote:
> On 11/05/2015 09:10 AM, Joonsoo Kim wrote:
> > On Wed, Nov 04, 2015 at 04:00:59PM +0100, Vlastimil Babka wrote:
> >> +void __copy_page_owner(struct page *oldpage, struct page *newpage)
> >> +{
> >> +	struct page_ext *old_ext = lookup_page_ext(oldpage);
> >> +	struct page_ext *new_ext = lookup_page_ext(newpage);
> >> +	int i;
> >> +
> >> +	new_ext->order = old_ext->order;
> >> +	new_ext->gfp_mask = old_ext->gfp_mask;
> >> +	new_ext->nr_entries = old_ext->nr_entries;
> >> +
> >> +	for (i = 0; i < ARRAY_SIZE(new_ext->trace_entries); i++)
> >> +		new_ext->trace_entries[i] = old_ext->trace_entries[i];
> >> +
> >> +	__set_bit(PAGE_EXT_OWNER, &new_ext->flags);
> >> +}
> >> +
> > 
> > Need to clear PAGE_EXT_OWNER bit in oldppage.
> 
> Hm, I thought that the freeing of the oldpage, which follows the migration,
> would take care of that. And if it hit some bug and dump_page before being
> freed, we would still have some info to print?

Okay. I missed that.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
