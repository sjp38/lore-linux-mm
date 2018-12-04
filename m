Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id E7C246B6BE6
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 19:38:16 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id 74so12575656pfk.12
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 16:38:16 -0800 (PST)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id k2si14000288pgh.63.2018.12.03.16.38.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 16:38:15 -0800 (PST)
Subject: Re: [PATCH v2] iomap: get/put the page in iomap_page_create/release()
References: <20181115184140.1388751-1-pjaroszynski@nvidia.com>
 <20181203152243.095e6b846fd9f623a339e4ab@linux-foundation.org>
From: Piotr Jaroszynski <pjaroszynski@nvidia.com>
Message-ID: <5d92664b-1e37-a7ba-8c72-576af887009a@nvidia.com>
Date: Mon, 3 Dec 2018 16:38:14 -0800
MIME-Version: 1.0
In-Reply-To: <20181203152243.095e6b846fd9f623a339e4ab@linux-foundation.org>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, p.jaroszynski@gmail.com
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Christoph Hellwig <hch@lst.de>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>

On 12/3/18 3:22 PM, Andrew Morton wrote:
> On Thu, 15 Nov 2018 10:41:40 -0800 p.jaroszynski@gmail.com wrote:
> 
>> migrate_page_move_mapping() expects pages with private data set to have
>> a page_count elevated by 1. This is what used to happen for xfs through
>> the buffer_heads code before the switch to iomap in commit 82cb14175e7d
>> ("xfs: add support for sub-pagesize writeback without buffer_heads").
>> Not having the count elevated causes move_pages() to fail on memory
>> mapped files coming from xfs.
>>
>> Make iomap compatible with the migrate_page_move_mapping() assumption
>> by elevating the page count as part of iomap_page_create() and lowering
>> it in iomap_page_release().
> 
> What are the real-world end-user effects of this bug?

It causes the move_pages() syscall to misbehave on memory mapped files
from xfs. It does not not move any pages, which I suppose is "just" a
perf issue, but it also ends up returning a positive number which is out
of spec for the syscall. Talking to Michal Hocko, it sounds like
returning positive numbers might be a necessary update to move_pages()
anyway though, see [1].

I only hit this in tests that verify that move_pages() actually moved
the pages. The test also got confused by the positive return from
move_pages() (it got treated as a success as positive numbers were not
expected and not handled) making it a bit harder to track down what's
going on.

> 
> Is a -stable backport warranted?
> 

I would say yes, but this is my first kernel contribution so others
would be probably better judges of that.

[1] - https://lkml.kernel.org/r/20181116114955.GJ14706@dhcp22.suse.cz

Thanks,
Piotr
