Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 7374B6B0002
	for <linux-mm@kvack.org>; Thu, 24 Jan 2013 03:30:04 -0500 (EST)
Received: by mail-ie0-f175.google.com with SMTP id qd14so15229955ieb.34
        for <linux-mm@kvack.org>; Thu, 24 Jan 2013 00:30:03 -0800 (PST)
Message-ID: <1359016192.2866.1.camel@kernel>
Subject: Re: [LSF/MM TOPIC]swap improvements for fast SSD
From: Simon Jeons <simon.jeons@gmail.com>
Date: Thu, 24 Jan 2013 02:29:52 -0600
In-Reply-To: <20130124014059.GA22654@blaptop>
References: <20130122065341.GA1850@kernel.org>
	 <20130123075808.GH2723@blaptop> <51003439.2070505@linux.vnet.ibm.com>
	 <20130124014059.GA22654@blaptop>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Shaohua Li <shli@kernel.org>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>

On Thu, 2013-01-24 at 10:40 +0900, Minchan Kim wrote:
> Hi Seth,
> 
> On Wed, Jan 23, 2013 at 01:04:25PM -0600, Seth Jennings wrote:
> > On 01/23/2013 01:58 AM, Minchan Kim wrote:
> > > Currently, the page table entries that have swapped out pages
> > > associated with them contain a swap entry, pointing directly
> > > at the swap device and swap slot containing the data. Meanwhile,
> > > the swap count lives in a separate array.
> > > 
> > > The redesign we are considering moving the swap entry to the
> > > page cache radix tree for the swapper_space and having the pte
> > > contain only the offset into the swapper_space.  The swap count
> > > info can also fit inside the swapper_space page cache radix
> > > tree (at least on 64 bits - on 32 bits we may need to get
> > > creative or accept a smaller max amount of swap space).
> > 
> > Correct me if I'm wrong, but this recent patchset creating a
> > swapper_space per type would mess this up right?  The offset alone
> > would no longer be sufficient to access the proper swapper_space.
> 
> If I understand Rik's idea correctly, it doesn't mess up. Because we already
> have used (swp_type, swp_offset) as offset of swapper_space so although
> he mentioned "pte contains only the offset into the swapper_space",
> it doesn't mean we will store only swp_offset in pte but store offset of
> swapper_space in pte.
> 
> old :
>         do_swap_page
>         swp_entry_t entry = pte_to_swp_entry(pte);
>         if (!lookup_swap_cache(entry))
>                 swapin_readahead(entry)
> 
> New :
>         do_swap_page
>         pgoff_t offset = pte_to_swp_offset(pte)
>         if (!lookup_swap_cache(offset)) {
>                 swp_entry_t entry = offset_to_swp_entry(offset);
>                 swapin_readahead(entry);
>         }
> 

Since Shaohua change the logic to each swap partition have one
address_space, the idea mentioned above can't work any more, correct?   

> IOW, entry of old and offset of new would be same vaule.
> 
> > 
> > Why not just continue to store the entire swap entry (type and offset)
> > in the pte?  Where you planning to use the type space in the pte for
> > something else?
> 
> No plan if I didn't miss something. :)
> 
> > 
> > Seth
> > 
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
