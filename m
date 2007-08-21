Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l7LMc9Aj024991
	for <linux-mm@kvack.org>; Tue, 21 Aug 2007 18:38:09 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7LMc8nT261698
	for <linux-mm@kvack.org>; Tue, 21 Aug 2007 16:38:08 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7LMc8v5009779
	for <linux-mm@kvack.org>; Tue, 21 Aug 2007 16:38:08 -0600
Subject: Re: [RFC][PATCH 8/9] pagemap: use page walker pte_hole() helper
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20070821220103.GM30556@waste.org>
References: <20070821204248.0F506A29@kernel>
	 <20070821204257.BB3A4C17@kernel>  <20070821220103.GM30556@waste.org>
Content-Type: text/plain
Date: Tue, 21 Aug 2007 15:38:07 -0700
Message-Id: <1187735887.16177.133.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2007-08-21 at 17:01 -0500, Matt Mackall wrote:
> > +	copy_to_user(pm->out, &pfn, out_len);
> 
> And I think we want to keep the put_user in the fast path.

OK, updated:

static int add_to_pagemap(unsigned long addr, unsigned long pfn,
                          struct pagemapread *pm)
{
        /*
         * Make sure there's room in the buffer for an
         * entire entry.  Otherwise, only copy part of
         * the pfn.
         */
        if (pm->count >= PM_ENTRY_BYTES)
                __put_user(pfn pm->out);
        else
                copy_to_user(pm->out, &pfn, pm->count);

        pm->pos += PM_ENTRY_BYTES;
        pm->count -= PM_ENTRY_BYTES;
        if (pm->count <= 0)
                return PAGEMAP_END_OF_BUFFER;
        return 0;
}

I'll patch-bomb you with the (small) updates I just made.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
