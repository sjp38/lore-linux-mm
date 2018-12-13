Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 726018E0161
	for <linux-mm@kvack.org>; Thu, 13 Dec 2018 08:40:54 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id c128so2543203itc.0
        for <linux-mm@kvack.org>; Thu, 13 Dec 2018 05:40:54 -0800 (PST)
Received: from p3plsmtpa11-09.prod.phx3.secureserver.net (p3plsmtpa11-09.prod.phx3.secureserver.net. [68.178.252.110])
        by mx.google.com with ESMTPS id u76si947529jau.27.2018.12.13.05.40.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Dec 2018 05:40:53 -0800 (PST)
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
References: <20181208022445.GA7024@redhat.com>
 <20181210102846.GC29289@quack2.suse.cz> <20181212150319.GA3432@redhat.com>
 <CAPcyv4go0Xzhz8rXdfscWuXDu83BO9v8WD4upDUJWb7gKzX5OQ@mail.gmail.com>
 <20181212213005.GE5037@redhat.com>
 <CAPcyv4gJHeFjEgna1S-2uE4KxkSUgkc=e=2E5oqfoirec84C-w@mail.gmail.com>
 <20181212215348.GF5037@redhat.com> <20181212233703.GB2947@ziepe.ca>
 <20181213000109.GK5037@redhat.com> <20181213032043.GA3204@ziepe.ca>
 <20181213124325.GA3186@redhat.com>
From: Tom Talpey <tom@talpey.com>
Message-ID: <81a731bb-6a8a-a554-cf99-5d0588b0a21f@talpey.com>
Date: Thu, 13 Dec 2018 08:40:49 -0500
MIME-Version: 1.0
In-Reply-To: <20181213124325.GA3186@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>
Cc: Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, John Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Michal Hocko <mhocko@kernel.org>, Mike Marciniszyn <mike.marciniszyn@intel.com>, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "Weiny, Ira" <ira.weiny@intel.com>

On 12/13/2018 7:43 AM, Jerome Glisse wrote:
> On Wed, Dec 12, 2018 at 08:20:43PM -0700, Jason Gunthorpe wrote:
>> On Wed, Dec 12, 2018 at 07:01:09PM -0500, Jerome Glisse wrote:
>>> On Wed, Dec 12, 2018 at 04:37:03PM -0700, Jason Gunthorpe wrote:
>>>> On Wed, Dec 12, 2018 at 04:53:49PM -0500, Jerome Glisse wrote:
>>>>>> Almost, we need some safety around assuming that DMA is complete the
>>>>>> page, so the notification would need to go all to way to userspace
>>>>>> with something like a file lease notification. It would also need to
>>>>>> be backstopped by an IOMMU in the case where the hardware does not /
>>>>>> can not stop in-flight DMA.
>>>>>
>>>>> You can always reprogram the hardware right away it will redirect
>>>>> any dma to the crappy page.
>>>>
>>>> That causes silent data corruption for RDMA users - we can't do that.
>>>>
>>>> The only way out for current hardware is to forcibly terminate the
>>>> RDMA activity somehow (and I'm not even sure this is possible, at
>>>> least it would be driver specific)
>>>>
>>>> Even the IOMMU idea probably doesn't work, I doubt all current
>>>> hardware can handle a PCI-E error TLP properly.
>>>
>>> What i saying is reprogram hardware to crappy page ie valid page
>>> dma map but that just has random content as a last resort to allow
>>> filesystem to reuse block. So their should be no PCIE error unless
>>> hardware freak out to see its page table reprogram randomly.
>>
>> No, that isn't an option. You can't silently provide corrupted data
>> for RDMA to transfer out onto the network, or silently discard data
>> coming in!!
>>
>> Think of the consequences of that - I have a fileserver process and
>> someone does ftruncate and now my clients receive corrupted data??
> 
> This is what happens _today_ ie today someone do GUP on page file
> and then someone else do truncate the first GUP is effectively
> streaming _random_ data to network as the page does not correspond
> to anything anymore and once the RDMA MR goes aways and release
> the page the page content will be lost. So i am not changing anything
> here, what i proposed was to make it explicit to device driver at
> least that they were streaming random data. Right now this is all
> silent but this is what is happening wether you like it or not :)
> 
> Note that  i am saying do that only for truncate to allow to be
> nice to fs. But again i am fine with whatever solution but you can
> not please everyone here. Either block truncate and fs folks will
> hate you or make it clear to device driver that you are streaming
> random things and RDMA people hates you.
> 
> 
>> The only option is to prevent the RDMA transfer from ever happening,
>> and we just don't have hardware support (beyond destroy everything) to
>> do that.
>>
>>> The question is who do you want to punish ? RDMA user that pin stuff
>>> and expect thing to work forever without worrying for other fs
>>> activities ? Or filesystem to pin block forever :)
>>
>> I don't want to punish everyone, I want both sides to have complete
>> data integrity as the USER has deliberately decided to combine DAX and
>> RDMA. So either stop it at the front end (ie get_user_pages_longterm)
>> or make it work in a way that guarantees integrity for both.
>>
>>>      S2: notify userspace program through device/sub-system
>>>          specific API and delay ftruncate. After a while if there
>>>          is no answer just be mean and force hardware to use
>>>          crappy page as anyway this is what happens today
>>
>> I don't think this happens today (outside of DAX).. Does it?
> 
> It does it is just silent, i don't remember anything in the code
> that would stop a truncate to happen because of elevated refcount.
> This does not happen with ODP mlx5 as it does abide by _all_ mmu
> notifier. This is for anything that does ODP without support for
> mmu notifier.

Wait - is it expected that the MMU notifier upcall is handled
synchronously? That is, the page DMA mapping must be torn down
immediately, and before returning?

That's simply not possible, since the hardware needs to get control
to do this. Even if there were an IOMMU that could intercept the
DMA, reprogramming it will require a flush, which cannot be guaranteed
to occur "inline".

>> .. and the remedy here is to kill the process, not provide corrupt
>> data. Kill the process is likely to not go over well with any real
>> users that want this combination.
>>
>> Think Samba serving files over RDMA - you can't have random unpriv
>> users calling ftruncate and causing smbd to be killed or serve corrupt
>> data.
> 
> So what i am saying is there is a choice and it would be better to
> decide something than let the existing status quo where we just keep
> streaming random data after truncate to a GUPed page.

Let's also remember that any torn-down DMA mapping can't be recycled
until all uses of the old DMA addresses are destroyed. The whole
thing screams for reference counting all the way down, to me.

Tom.
