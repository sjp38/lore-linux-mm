Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id D7A546B0038
	for <linux-mm@kvack.org>; Thu, 13 Aug 2015 12:34:07 -0400 (EDT)
Received: by wicja10 with SMTP id ja10so158055369wic.1
        for <linux-mm@kvack.org>; Thu, 13 Aug 2015 09:34:07 -0700 (PDT)
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com. [209.85.212.173])
        by mx.google.com with ESMTPS id e14si4945573wjq.46.2015.08.13.09.34.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Aug 2015 09:34:06 -0700 (PDT)
Received: by wijp15 with SMTP id p15so265899139wij.0
        for <linux-mm@kvack.org>; Thu, 13 Aug 2015 09:34:05 -0700 (PDT)
Message-ID: <55CCC6FB.1020901@plexistor.com>
Date: Thu, 13 Aug 2015 19:34:03 +0300
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 4/5] dax: fix mapping lifetime handling, convert to
 __pfn_t + kmap_atomic_pfn_t()
References: <20150813025112.36703.21333.stgit@otcpl-skl-sds-2.jf.intel.com>	<20150813030119.36703.48416.stgit@otcpl-skl-sds-2.jf.intel.com>	<55CC38B0.70502@plexistor.com> <CAPcyv4iscepUm6EDe5iRR273Rbe-h5MAmVepix=gEZ0NtzRgJA@mail.gmail.com>
In-Reply-To: <CAPcyv4iscepUm6EDe5iRR273Rbe-h5MAmVepix=gEZ0NtzRgJA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, Boaz Harrosh <boaz@plexistor.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Jens Axboe <axboe@kernel.dk>, Rik van Riel <riel@redhat.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, Christoph Hellwig <hch@lst.de>

On 08/13/2015 06:21 PM, Dan Williams wrote:
> On Wed, Aug 12, 2015 at 11:26 PM, Boaz Harrosh <boaz@plexistor.com> wrote:
<>
> 
> Hmm, that's not the same block layer I've been working with for the
> past several years:
> 
> $ mount /dev/pmem0 /mnt
> $ echo namespace0.0 > ../drivers/nd_pmem/unbind # succeeds
> 
> Unbind always proceeds unconditionally.  See the recent kernel summit
> topic discussion around devm vs unbind [1].  While kmap_atomic_pfn_t()
> does not implement revoke semantics it at least forces re-validation
> and time bounded references.  For the unplug case we'll need to go
> shootdown those DAX mappings in userspace so that they return SIGBUS
> on access, or something along those lines.
> 

Then fix unbind to refuse. What is the point of unbind when it trashes
the hot path so badly and makes the code so fat. Who uses it and what for?

First I ever heard of it and I do use Linux a little bit.

> [1]: http://www.spinics.net/lists/kernel/msg2032864.html
> 
Hm...

OK I hate it. I would just make sure to override and refuse unbinding with an
elevated ref count. Is not a good reason for me to trash the hotpath.

>> And for god sake. I have a bdev I call bdev_direct_access(sector), the bdev calculated the
>> exact address for me (base + sector). Now I get back this __pfn_t and I need to call
>> kmap_atomic_pfn_t() which does a loop to search for my range and again base+offset ?
>>
>> This all model is broken, sorry?
> 
> I think you are confused about the lifetime of the userspace DAX
> mapping vs the kernel's mapping and the frequency of calls to
> kmap_atomic_pfn_t().  I'm sure you can make this loop look bad with a
> micro-benchmark, but the whole point of DAX is to get the kernel out
> of the I/O path, so I'm not sure this overhead shows up in any real
> way in practice.

Sigh! It does. very much. 4k random write for you. Will drop in half
if I do this. We've been testing with memory for a long time every
rcu lock counts. A single atomic will drop things by %20

Thanks
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
