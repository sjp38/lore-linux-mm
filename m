Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e32.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id jA2LaoRK020023
	for <linux-mm@kvack.org>; Wed, 2 Nov 2005 16:36:50 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id jA2Laorq450076
	for <linux-mm@kvack.org>; Wed, 2 Nov 2005 14:36:50 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id jA2Lakkh015212
	for <linux-mm@kvack.org>; Wed, 2 Nov 2005 14:36:46 -0700
Subject: Re: New bug in patch and existing Linux code - race with
	install_page() (was: Re: [PATCH] 2.6.14 patch for supporting
	madvise(MADV_REMOVE))
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <200511022054.15119.blaisorblade@yahoo.it>
References: <1130366995.23729.38.camel@localhost.localdomain>
	 <20051102014321.GG24051@opteron.random>
	 <1130947957.24503.70.camel@localhost.localdomain>
	 <200511022054.15119.blaisorblade@yahoo.it>
Content-Type: text/plain
Date: Wed, 02 Nov 2005 13:36:23 -0800
Message-Id: <1130967383.24503.112.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Blaisorblade <blaisorblade@yahoo.it>
Cc: Andrea Arcangeli <andrea@suse.de>, lkml <linux-kernel@vger.kernel.org>, Hugh Dickins <hugh@veritas.com>, akpm@osdl.org, dvhltc@us.ibm.com, linux-mm <linux-mm@kvack.org>, Jeff Dike <jdike@addtoit.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2005-11-02 at 20:54 +0100, Blaisorblade wrote:
> On Wednesday 02 November 2005 17:12, Badari Pulavarty wrote:
> > Hi Andrew & Andrea,
> >
> > Here is the updated patch with name change again :(
> > Hopefully this would be final. (MADV_REMOVE).
> >
> > BTW, I am not sure if we need to hold i_sem and i_allocsem
> > all the way ? I wanted to be safe - but this may be overkill ?
> While looking into this, I probably found another problem, a race with 
> install_page(), which doesn't use the seqlock-style check we use for 
> everything else (aka do_no_page) but simply assumes a page is valid if its 
> index is below the current file size.
> 
> This is clearly "truncate" specific, and is already racy. Suppose I truncate a 
> file and reduce its size, and then re-extend it, the page which I previously 
> fetched from the cache is invalid. The current install_page code generates 
> corruption.
> 
> In fact the page is fetched from the caller of install_page and passed to it.
> 
> This affects anybody using MAP_POPULATE or using remap_file_pages.
> 
> > +       /* XXX - Do we need both i_sem and i_allocsem all the way ? */
> > +       down(&inode->i_sem);
> > +       down_write(&inode->i_alloc_sem);
> > +       unmap_mapping_range(mapping, offset, (end - offset), 1);
> In my opinion, as already said, unmap_mapping_range can be called without 
> these two locks, as it operates only on mappings for the file.
> 
> However currently it's called with these locks held in vmtruncate, but I think 
> the locks are held in that case only because we need to truncate the file, 
> and are hold in excess also across this call.

I agree, I can push down the locking only for ->truncate_range - if
no one has objections. (But again, it so special case - no one really
cares about the performance of this interface ?).

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
