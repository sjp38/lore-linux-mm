Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id A9E829003C7
	for <linux-mm@kvack.org>; Thu, 13 Aug 2015 11:21:03 -0400 (EDT)
Received: by wijp15 with SMTP id p15so263267423wij.0
        for <linux-mm@kvack.org>; Thu, 13 Aug 2015 08:21:03 -0700 (PDT)
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com. [209.85.212.177])
        by mx.google.com with ESMTPS id y19si4592346wiv.10.2015.08.13.08.21.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Aug 2015 08:21:02 -0700 (PDT)
Received: by wijp15 with SMTP id p15so263266498wij.0
        for <linux-mm@kvack.org>; Thu, 13 Aug 2015 08:21:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <55CC38B0.70502@plexistor.com>
References: <20150813025112.36703.21333.stgit@otcpl-skl-sds-2.jf.intel.com>
	<20150813030119.36703.48416.stgit@otcpl-skl-sds-2.jf.intel.com>
	<55CC38B0.70502@plexistor.com>
Date: Thu, 13 Aug 2015 08:21:01 -0700
Message-ID: <CAPcyv4iscepUm6EDe5iRR273Rbe-h5MAmVepix=gEZ0NtzRgJA@mail.gmail.com>
Subject: Re: [PATCH v5 4/5] dax: fix mapping lifetime handling, convert to
 __pfn_t + kmap_atomic_pfn_t()
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boaz@plexistor.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Jens Axboe <axboe@kernel.dk>, Rik van Riel <riel@redhat.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, Christoph Hellwig <hch@lst.de>

On Wed, Aug 12, 2015 at 11:26 PM, Boaz Harrosh <boaz@plexistor.com> wrote:
> Boooo. Here this all set is a joke. The all "pmem disable vs still-in-use" argument is mute
> here below you have inserted a live, used for ever, pfn into a process vm without holding
> a map.

Careful, don't confuse "unbind" with "unplug".  "Unbind" invalidates
the driver's mapping (ioremap) while "unplug" would invalidate the
pfn.  DAX is indeed broken with respect to unplug and we'll need to go
solve that separately.  I expect "unplug" support will be needed for
hot provisioning pmem to/from virtual machines.

> The all "pmem disable vs still-in-use" is a joke. The FS loaded has a reference on the bdev
> and the filehadle has a reference on the FS. So what is exactly this "pmem disable" you are
> talking about?

Hmm, that's not the same block layer I've been working with for the
past several years:

$ mount /dev/pmem0 /mnt
$ echo namespace0.0 > ../drivers/nd_pmem/unbind # succeeds

Unbind always proceeds unconditionally.  See the recent kernel summit
topic discussion around devm vs unbind [1].  While kmap_atomic_pfn_t()
does not implement revoke semantics it at least forces re-validation
and time bounded references.  For the unplug case we'll need to go
shootdown those DAX mappings in userspace so that they return SIGBUS
on access, or something along those lines.

[1]: http://www.spinics.net/lists/kernel/msg2032864.html

> And for god sake. I have a bdev I call bdev_direct_access(sector), the bdev calculated the
> exact address for me (base + sector). Now I get back this __pfn_t and I need to call
> kmap_atomic_pfn_t() which does a loop to search for my range and again base+offset ?
>
> This all model is broken, sorry?

I think you are confused about the lifetime of the userspace DAX
mapping vs the kernel's mapping and the frequency of calls to
kmap_atomic_pfn_t().  I'm sure you can make this loop look bad with a
micro-benchmark, but the whole point of DAX is to get the kernel out
of the I/O path, so I'm not sure this overhead shows up in any real
way in practice.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
