Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 5FD926B0038
	for <linux-mm@kvack.org>; Thu, 13 Aug 2015 11:01:37 -0400 (EDT)
Received: by wicne3 with SMTP id ne3so143585927wic.0
        for <linux-mm@kvack.org>; Thu, 13 Aug 2015 08:01:36 -0700 (PDT)
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com. [209.85.212.169])
        by mx.google.com with ESMTPS id c4si4476552wiy.27.2015.08.13.08.01.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Aug 2015 08:01:35 -0700 (PDT)
Received: by wibhh20 with SMTP id hh20so78879358wib.0
        for <linux-mm@kvack.org>; Thu, 13 Aug 2015 08:01:35 -0700 (PDT)
Message-ID: <55CCB14B.4030303@plexistor.com>
Date: Thu, 13 Aug 2015 18:01:31 +0300
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 2/5] allow mapping page-less memremaped areas into
 KVA
References: <20150813025112.36703.21333.stgit@otcpl-skl-sds-2.jf.intel.com> <20150813030109.36703.21738.stgit@otcpl-skl-sds-2.jf.intel.com> <55CC3222.5090503@plexistor.com> <CAPcyv4gwFD5F=k_qQyf68z74Opzf1t4DMqY+A9D2w_Fwsbzvew@mail.gmail.com> <55CC9A5A.1020209@plexistor.com> <20150813144132.GC17375@lst.de>
In-Reply-To: <20150813144132.GC17375@lst.de>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Dan Williams <dan.j.williams@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Jens Axboe <axboe@kernel.dk>, Rik van Riel <riel@redhat.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>

On 08/13/2015 05:41 PM, Christoph Hellwig wrote:
> On Thu, Aug 13, 2015 at 04:23:38PM +0300, Boaz Harrosh wrote:
>>> DAX as is is races against pmem unbind.   A synchronization cost must
>>> be paid somewhere to make sure the memremap() mapping is still valid.
>>
>> Sorry for being so slow, is what I asked. what is exactly "pmem unbind" ?
>>
>> Currently in my 4.1 Kernel the ioremap is done on modprobe time and
>> released modprobe --remove time. the --remove can not happen with a mounted
>> FS dax or not. So what is exactly "pmem unbind". And if there is a new knob
>> then make it refuse with a raised refcount.
> 
> Surprise removal of a PCIe card which is mapped to provide non-volatile
> memory for example.  Or memory hot swap.
> 

Then the mapping is just there and you get garbage. Just the same as
"memory hot swap" the kernel will not let you HOT-REMOVE a referenced
memory. It will just refuse. If you forcefully remove a swapeble memory
chip without HOT-REMOVE first what will happen? so the same here.

SW wise you refuse to HOT-REMOVE. HW wise BTW the Kernel will not die
only farther reads will return all 111111 and writes will go to the
either.

The all kmap thing was for highmem. Is not the case here.

Again see my other comment at dax mmap:

- you go pfn_map take a pfn
- kpfn_unmap
- put pfn on user mmap vma
- then what happens to user access after that. Nothing not even a page_fault
  It will have a vm-mapping to a now none existing physical address that's
  it.

Thanks
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
