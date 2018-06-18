Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0F86F6B0005
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 13:44:52 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id j11-v6so14570529qtf.15
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 10:44:52 -0700 (PDT)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id 9-v6si4592485qtn.162.2018.06.18.10.44.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jun 2018 10:44:51 -0700 (PDT)
Subject: Re: [PATCH 2/2] mm: set PG_dma_pinned on get_user_pages*()
References: <20180617012510.20139-1-jhubbard@nvidia.com>
 <20180617012510.20139-3-jhubbard@nvidia.com>
 <20180618075650.GA7300@infradead.org>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <7295d9c3-ecc3-ae60-1818-72b0565741ff@nvidia.com>
Date: Mon, 18 Jun 2018 10:44:28 -0700
MIME-Version: 1.0
In-Reply-To: <20180618075650.GA7300@infradead.org>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>, john.hubbard@gmail.com
Cc: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>

Hi Christoph,

Thanks for looking at this...

On 06/18/2018 12:56 AM, Christoph Hellwig wrote:
> On Sat, Jun 16, 2018 at 06:25:10PM -0700, john.hubbard@gmail.com wrote:
>> From: John Hubbard <jhubbard@nvidia.com>
>>
>> This fixes a few problems that come up when using devices (NICs, GPUs,
>> for example) that want to have direct access to a chunk of system (CPU)
>> memory, so that they can DMA to/from that memory. Problems [1] come up
>> if that memory is backed by persistence storage; for example, an ext4
>> file system. I've been working on several customer bugs that are hitting
>> this, and this patchset fixes those bugs.
> 
> What happens if we do get_user_page from two different threads or even
> processes on the same page?  As far as I can tell from your patch
> the first one finishing the page will clear the bit and then we are
> back to no protection.

The patch does not do that. The flag is only ever cleared when the page is 
freed. That can't happen until each of the two threads above is done and 
calls put_page(). So while there may be other design issues here, the above 
case is not one of them. :)


thanks,
-- 
John Hubbard
NVIDIA
