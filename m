Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3B8B66B000A
	for <linux-mm@kvack.org>; Tue, 26 Jun 2018 02:32:10 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id n10-v6so14886701qtp.11
        for <linux-mm@kvack.org>; Mon, 25 Jun 2018 23:32:10 -0700 (PDT)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id r35-v6si889819qta.183.2018.06.25.23.32.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jun 2018 23:32:08 -0700 (PDT)
Subject: Re: [PATCH 2/2] mm: set PG_dma_pinned on get_user_pages*()
References: <3898ef6b-2fa0-e852-a9ac-d904b47320d5@nvidia.com>
 <CAPcyv4iRBzmwWn_9zDvqdfVmTZL_Gn7uA_26A1T-kJib=84tvA@mail.gmail.com>
 <0e6053b3-b78c-c8be-4fab-e8555810c732@nvidia.com>
 <20180619082949.wzoe42wpxsahuitu@quack2.suse.cz>
 <20180619090255.GA25522@bombadil.infradead.org>
 <20180619104142.lpilc6esz7w3a54i@quack2.suse.cz>
 <70001987-3938-d33e-11e0-de5b19ca3bdf@nvidia.com>
 <20180620120824.bghoklv7qu2z5wgy@quack2.suse.cz>
 <151edbf3-66ff-df0c-c1cc-5998de50111e@nvidia.com>
 <20180621163036.jvdbsv3t2lu34pdl@quack2.suse.cz>
 <20180625152150.jnf5suiubecfppcl@quack2.suse.cz>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <550aacd3-cfea-c99a-3b60-563dd1621d5c@nvidia.com>
Date: Mon, 25 Jun 2018 23:31:06 -0700
MIME-Version: 1.0
In-Reply-To: <20180625152150.jnf5suiubecfppcl@quack2.suse.cz>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Matthew Wilcox <willy@infradead.org>, Dan Williams <dan.j.williams@intel.com>, Christoph Hellwig <hch@lst.de>, Jason Gunthorpe <jgg@ziepe.ca>, John Hubbard <john.hubbard@gmail.com>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>

On 06/25/2018 08:21 AM, Jan Kara wrote:
> On Thu 21-06-18 18:30:36, Jan Kara wrote:
>> On Wed 20-06-18 15:55:41, John Hubbard wrote:
>>> On 06/20/2018 05:08 AM, Jan Kara wrote:
>>>> On Tue 19-06-18 11:11:48, John Hubbard wrote:
>>>>> On 06/19/2018 03:41 AM, Jan Kara wrote:
>>>>>> On Tue 19-06-18 02:02:55, Matthew Wilcox wrote:
>>>>>>> On Tue, Jun 19, 2018 at 10:29:49AM +0200, Jan Kara wrote:
>>> [...]
> I've spent some time on this. There are two obstacles with my approach of
> putting special entry into inode's VMA tree:
> 
> 1) If I want to place this special entry in inode's VMA tree, I either need
> to allocate full VMA, somehow initiate it so that it's clear it's a special
> "pinned" range, not a VMA => uses unnecessarily too much memory, it is
> ugly. Another solution I was hoping for was that I would factor out some
> common bits of vm_area_struct (pgoff, rb_node, ..) into a structure common
> for VMA and the locked range => doable but causes a lot of churn as VMAs
> are accessed (and modified!) at hundreds of places in the kernel. Some
> accessor functions would help to reduce the churn a bit but then stuff like
> vma_set_pgoff(vma, pgoff) isn't exactly beautiful either.
> 
> 2) Some users of GUP (e.g. direct IO) get a block of pages and then put
> references to these pages at different times and in random order -
> basically when IO for given page is completed, reference is dropped and one
> GUP call can acquire page references for pages which end up in multiple
> different bios (we don't know in advance). This makes is difficult to
> implement counterpart to GUP to 'unpin' a range of pages - we'd either have
> to support partial unpins (and splitting of pinned ranges and all such fun)
> or just have to track internally in how many pages are still pinned in the
> originally pinned range and release the pin once all individual pages are
> unpinned but then it's difficult to e.g. get to this internal structure
> from IO completion callback where we only have the bio.
> 
> So I think the Matthew's idea of removing pinned pages from LRU is
> definitely worth trying to see how complex that would end up being. Did you
> get to looking into it? If not, I can probably find some time to try that
> out.
> 
 
OK, so I looked into this some more.

As you implied in an earlier response, removing a page from LRU is probably the
easy part. It's *keeping* it off the LRU that worries me. I looked at SetPageLRU()
uses, there were only 5 call sites, and of those, I think only one might be difficult:

    __pagevec_lru_add()

It seems like the way to avoid __pagevec_lru_add() calls on these pages is to
first call lru_add_drain_all, then remove the pages from LRU (presumably via
isolate_page_lru). I think that should do it. But I'm a little concerned that 
maybe I'm overlooking something.

Here are the 5 search hits and my analysis. This may have mistakes in it, as
I'm pretty new to this area, which is why I'm spelling it out:

1. mm/memcontrol.c:2082: SetPageLRU(page); 

    This is in unlock_page_lru(). Caller: commit_charge(), and it's conditional on 
    lrucare, so we can just skip it if the new page flag is set.

2. mm/swap.c:831: SetPageLRU(page_tail);
    This is in lru_add_page_tail(), which is only called by __split_huge_page_tail, and
    there, we can also just skip the call for these pages.

3. mm/swap.c:866:  SetPageLRU(page);
    This is in __pagevec_lru_add_fn (sole caller: __pagevec_lru_add), and is
    discussed above.

4. mm/vmscan.c:1680: SetPageLRU(page);	
    This is in putback_inactive_pages(), which I think won't get called unless
    the page is already on an LRU.

5. mm/vmscan.c:1873: SetPageLRU(page);	//  (N/A)
    This is in move_active_pages_to_lru(), which I also think won't get called unless 
    the page is already on an LRU.


thanks,
-- 
John Hubbard
NVIDIA
