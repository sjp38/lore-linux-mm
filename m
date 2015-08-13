Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 9935A6B0038
	for <linux-mm@kvack.org>; Thu, 13 Aug 2015 14:51:53 -0400 (EDT)
Received: by wibhh20 with SMTP id hh20so86306542wib.0
        for <linux-mm@kvack.org>; Thu, 13 Aug 2015 11:51:53 -0700 (PDT)
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com. [209.85.212.182])
        by mx.google.com with ESMTPS id lk14si5534319wic.120.2015.08.13.11.51.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Aug 2015 11:51:52 -0700 (PDT)
Received: by wicja10 with SMTP id ja10so80264464wic.1
        for <linux-mm@kvack.org>; Thu, 13 Aug 2015 11:51:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <55CCC6FB.1020901@plexistor.com>
References: <20150813025112.36703.21333.stgit@otcpl-skl-sds-2.jf.intel.com>
	<20150813030119.36703.48416.stgit@otcpl-skl-sds-2.jf.intel.com>
	<55CC38B0.70502@plexistor.com>
	<CAPcyv4iscepUm6EDe5iRR273Rbe-h5MAmVepix=gEZ0NtzRgJA@mail.gmail.com>
	<55CCC6FB.1020901@plexistor.com>
Date: Thu, 13 Aug 2015 11:51:51 -0700
Message-ID: <CAPcyv4i+gufdFJ7hP4QUyQ_Z3MsjAMsFCC+-2bXtUEWVUZyrAA@mail.gmail.com>
Subject: Re: [PATCH v5 4/5] dax: fix mapping lifetime handling, convert to
 __pfn_t + kmap_atomic_pfn_t()
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boaz@plexistor.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Jens Axboe <axboe@kernel.dk>, Rik van Riel <riel@redhat.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, Christoph Hellwig <hch@lst.de>

On Thu, Aug 13, 2015 at 9:34 AM, Boaz Harrosh <boaz@plexistor.com> wrote:
> On 08/13/2015 06:21 PM, Dan Williams wrote:
>> On Wed, Aug 12, 2015 at 11:26 PM, Boaz Harrosh <boaz@plexistor.com> wrote:
> <>
>>
>> Hmm, that's not the same block layer I've been working with for the
>> past several years:
>>
>> $ mount /dev/pmem0 /mnt
>> $ echo namespace0.0 > ../drivers/nd_pmem/unbind # succeeds
>>
>> Unbind always proceeds unconditionally.  See the recent kernel summit
>> topic discussion around devm vs unbind [1].  While kmap_atomic_pfn_t()
>> does not implement revoke semantics it at least forces re-validation
>> and time bounded references.  For the unplug case we'll need to go
>> shootdown those DAX mappings in userspace so that they return SIGBUS
>> on access, or something along those lines.
>>
>
> Then fix unbind to refuse. What is the point of unbind when it trashes
> the hot path so badly and makes the code so fat.

What? The DAX hot path avoids the kernel entirely.

> Who uses it and what for?

The device driver core.  We simply can't hold off remove indefinitely.
If the administrator wants the device disabled we need to tear down
and revoke active mappings, or at very least guarantee time bounded
removal.

> First I ever heard of it and I do use Linux a little bit.
>
>> [1]: http://www.spinics.net/lists/kernel/msg2032864.html
>>
> Hm...
>
> OK I hate it. I would just make sure to override and refuse unbinding with an
> elevated ref count. Is not a good reason for me to trash the hotpath.

Again, the current usages are not in hot paths.  If it becomes part of
a hot path *and* shows up in a profile we can look to implement
something with less overhead.  Until then we should plan to honor the
lifetime as defined by ->probe() and ->remove().

In fact I proposed the same as you, but then changed my mind based on
Tejun's response [1].  So please reconsider this idea to solve the
problem by blocking ->remove().  PMEM is new and special, but not
*that* special as to justify breaking basic guarantees.

[1]: https://lkml.org/lkml/2015/7/15/731

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
