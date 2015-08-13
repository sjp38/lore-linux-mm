Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f177.google.com (mail-lb0-f177.google.com [209.85.217.177])
	by kanga.kvack.org (Postfix) with ESMTP id 41B226B0038
	for <linux-mm@kvack.org>; Thu, 13 Aug 2015 09:23:43 -0400 (EDT)
Received: by lbbpu9 with SMTP id pu9so26976322lbb.3
        for <linux-mm@kvack.org>; Thu, 13 Aug 2015 06:23:42 -0700 (PDT)
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com. [209.85.212.169])
        by mx.google.com with ESMTPS id u10si3945525wiv.111.2015.08.13.06.23.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Aug 2015 06:23:41 -0700 (PDT)
Received: by wicja10 with SMTP id ja10so151405585wic.1
        for <linux-mm@kvack.org>; Thu, 13 Aug 2015 06:23:41 -0700 (PDT)
Message-ID: <55CC9A5A.1020209@plexistor.com>
Date: Thu, 13 Aug 2015 16:23:38 +0300
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 2/5] allow mapping page-less memremaped areas into
 KVA
References: <20150813025112.36703.21333.stgit@otcpl-skl-sds-2.jf.intel.com>	<20150813030109.36703.21738.stgit@otcpl-skl-sds-2.jf.intel.com>	<55CC3222.5090503@plexistor.com> <CAPcyv4gwFD5F=k_qQyf68z74Opzf1t4DMqY+A9D2w_Fwsbzvew@mail.gmail.com>
In-Reply-To: <CAPcyv4gwFD5F=k_qQyf68z74Opzf1t4DMqY+A9D2w_Fwsbzvew@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, Boaz Harrosh <boaz@plexistor.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Jens Axboe <axboe@kernel.dk>, Rik van Riel <riel@redhat.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, Christoph Hellwig <hch@lst.de>

On 08/13/2015 03:57 PM, Dan Williams wrote:
<>
> This is explicitly addressed in the changelog, repeated here:
> 
>> The __pfn_t to resource lookup is indeed inefficient walking of a linked list,
>> but there are two mitigating factors:
>>
>> 1/ The number of persistent memory ranges is bounded by the number of
>>    DIMMs which is on the order of 10s of DIMMs, not hundreds.
>>

You do not get where I'm comming from. It used to be a [ptr - ONE_BASE + OTHER_BASE]
(In 64 bit) it is now a call and a loop and a search. how ever you will look at
it is *not* the instantaneous address translation it is now.

I have memory I want memory speeds. You keep thinking HD speeds, where what ever
you do will not matter.

>> 2/ The lookup yields the entire range, if it becomes inefficient to do a
>>    kmap_atomic_pfn_t() a PAGE_SIZE at a time the caller can take
>>    advantage of the fact that the lookup can be amortized for all kmap
>>    operations it needs to perform in a given range.
> 

What "given range" how can a bdev assume that the all sg-list belongs to the
same "range". In fact our code does multple-pmem devices for a long time.
What about say md-of-pmems for example, or btrfs

> DAX as is is races against pmem unbind.   A synchronization cost must
> be paid somewhere to make sure the memremap() mapping is still valid.

Sorry for being so slow, is what I asked. what is exactly "pmem unbind" ?

Currently in my 4.1 Kernel the ioremap is done on modprobe time and
released modprobe --remove time. the --remove can not happen with a mounted
FS dax or not. So what is exactly "pmem unbind". And if there is a new knob
then make it refuse with a raised refcount.

Cheers
Boaz


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
