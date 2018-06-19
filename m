Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8B3636B0005
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 14:12:13 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id 84-v6so503510qkz.3
        for <linux-mm@kvack.org>; Tue, 19 Jun 2018 11:12:13 -0700 (PDT)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id o9-v6si348619qtk.71.2018.06.19.11.12.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jun 2018 11:12:11 -0700 (PDT)
Subject: Re: [PATCH 2/2] mm: set PG_dma_pinned on get_user_pages*()
References: <CAPcyv4gayKk_zHDYAvntware12qMXWjnnL_FDJNUQsJS_zNfDw@mail.gmail.com>
 <311eba48-60f1-b6cc-d001-5cc3ed4d76a9@nvidia.com>
 <20180618081258.GB16991@lst.de>
 <d4817192-6db0-2f3f-7c67-6078b69686d3@nvidia.com>
 <CAPcyv4iacHYxGmyWokFrVsmxvLj7=phqp2i0tv8z6AT-mYuEEA@mail.gmail.com>
 <3898ef6b-2fa0-e852-a9ac-d904b47320d5@nvidia.com>
 <CAPcyv4iRBzmwWn_9zDvqdfVmTZL_Gn7uA_26A1T-kJib=84tvA@mail.gmail.com>
 <0e6053b3-b78c-c8be-4fab-e8555810c732@nvidia.com>
 <20180619082949.wzoe42wpxsahuitu@quack2.suse.cz>
 <20180619090255.GA25522@bombadil.infradead.org>
 <20180619104142.lpilc6esz7w3a54i@quack2.suse.cz>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <70001987-3938-d33e-11e0-de5b19ca3bdf@nvidia.com>
Date: Tue, 19 Jun 2018 11:11:48 -0700
MIME-Version: 1.0
In-Reply-To: <20180619104142.lpilc6esz7w3a54i@quack2.suse.cz>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>
Cc: Dan Williams <dan.j.williams@intel.com>, Christoph Hellwig <hch@lst.de>, Jason Gunthorpe <jgg@ziepe.ca>, John Hubbard <john.hubbard@gmail.com>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>

On 06/19/2018 03:41 AM, Jan Kara wrote:
> On Tue 19-06-18 02:02:55, Matthew Wilcox wrote:
>> On Tue, Jun 19, 2018 at 10:29:49AM +0200, Jan Kara wrote:
>>> And for record, the problem with page cache pages is not only that
>>> try_to_unmap() may unmap them. It is also that page_mkclean() can
>>> write-protect them. And once PTEs are write-protected filesystems may end
>>> up doing bad things if DMA then modifies the page contents (DIF/DIX
>>> failures, data corruption, oopses). As such I don't think that solutions
>>> based on page reference count have a big chance of dealing with the
>>> problem.
>>>
>>> And your page flag approach would also need to take page_mkclean() into
>>> account. And there the issue is that until the flag is cleared (i.e., we
>>> are sure there are no writers using references from GUP) you cannot
>>> writeback the page safely which does not work well with your idea of
>>> clearing the flag only once the page is evicted from page cache (hint, page
>>> cache page cannot get evicted until it is written back).
>>>
>>> So as sad as it is, I don't see an easy solution here.
>>
>> Pages which are "got" don't need to be on the LRU list.  They'll be
>> marked dirty when they're put, so we can use page->lru for fun things
>> like a "got" refcount.  If we use bit 1 of page->lru for PageGot, we've
>> got 30/62 bits in the first word and a full 64 bits in the second word.
> 
> Interesting idea! It would destroy the aging information for the page but
> for pages accessed through GUP references that is very much vague concept
> anyway. It might be a bit tricky as pulling a page out of LRU requires page
> lock but I don't think that's a huge problem. And page cache pages not on
> LRU exist even currently when they are under reclaim so hopefully there
> won't be too many places in MM that would need fixing up for such pages.

This sound promising, I'll try it out!

> 
> I'm also still pondering the idea of inserting a "virtual" VMA into vma
> interval tree in the inode - as the GUP references are IMHO closest to an
> mlocked mapping - and that would achieve all the functionality we need as
> well. I just didn't have time to experiment with it.

How would this work? Would it have the same virtual address range? And how
does it avoid the problems we've been discussing? Sorry to be a bit slow
here. :)

> 
> And then there's the aspect that both these approaches are a bit too
> heavyweight for some get_user_pages_fast() users (e.g. direct IO) - Al Viro
> had an idea to use page lock for that path but e.g. fs/direct-io.c would have
> problems due to lock ordering constraints (filesystem ->get_block would
> suddently get called with the page lock held). But we can probably leave
> performance optimizations for phase two.

 
So I assume that phase one would be to apply this approach only to
get_user_pages_longterm. (Please let me know if that's wrong.)


thanks,
-- 
John Hubbard
NVIDIA
