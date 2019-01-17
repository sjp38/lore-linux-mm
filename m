Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1BE4B8E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 00:42:29 -0500 (EST)
Received: by mail-yw1-f69.google.com with SMTP id x14so4603524ywg.18
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 21:42:29 -0800 (PST)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id y1si696855ywe.310.2019.01.16.21.42.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 21:42:27 -0800 (PST)
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
References: <20190111165141.GB3190@redhat.com>
 <1b37061c-5598-1b02-2983-80003f1c71f2@nvidia.com>
 <20190112020228.GA5059@redhat.com>
 <294bdcfa-5bf9-9c09-9d43-875e8375e264@nvidia.com>
 <20190112024625.GB5059@redhat.com>
 <b6f4ed36-fc8d-1f9b-8c74-b12f61d496ae@nvidia.com>
 <20190114145447.GJ13316@quack2.suse.cz> <20190114172124.GA3702@redhat.com>
 <20190115080759.GC29524@quack2.suse.cz>
 <20190116113819.GD26069@quack2.suse.cz> <20190116130813.GA3617@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <5c6dc6ed-4c8d-bce7-df02-ee8b7785b265@nvidia.com>
Date: Wed, 16 Jan 2019 21:42:25 -0800
MIME-Version: 1.0
In-Reply-To: <20190116130813.GA3617@redhat.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>, Jan Kara <jack@suse.cz>
Cc: Matthew Wilcox <willy@infradead.org>, Dave Chinner <david@fromorbit.com>, Dan Williams <dan.j.williams@intel.com>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, mike.marciniszyn@intel.com, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On 1/16/19 5:08 AM, Jerome Glisse wrote:
> On Wed, Jan 16, 2019 at 12:38:19PM +0100, Jan Kara wrote:
>> On Tue 15-01-19 09:07:59, Jan Kara wrote:
>>> Agreed. So with page lock it would actually look like:
>>>
>>> get_page_pin()
>>> 	lock_page(page);
>>> 	wait_for_stable_page();
>>> 	atomic_add(&page->_refcount, PAGE_PIN_BIAS);
>>> 	unlock_page(page);
>>>
>>> And if we perform page_pinned() check under page lock, then if
>>> page_pinned() returned false, we are sure page is not and will not be
>>> pinned until we drop the page lock (and also until page writeback is
>>> completed if needed).
>>
>> After some more though, why do we even need wait_for_stable_page() and
>> lock_page() in get_page_pin()?
>>
>> During writepage page_mkclean() will write protect all page tables. So
>> there can be no new writeable GUP pins until we unlock the page as all such
>> GUPs will have to first go through fault and ->page_mkwrite() handler. And
>> that will wait on page lock and do wait_for_stable_page() for us anyway.
>> Am I just confused?
> 
> Yeah with page lock it should synchronize on the pte but you still
> need to check for writeback iirc the page is unlocked after file
> system has queue up the write and thus the page can be unlock with
> write back pending (and PageWriteback() == trye) and i am not sure
> that in that states we can safely let anyone write to that page. I
> am assuming that in some case the block device also expect stable
> page content (RAID stuff).
> 
> So the PageWriteback() test is not only for racing page_mkclean()/
> test_set_page_writeback() and GUP but also for pending write back.


That was how I thought it worked too: page_mkclean and a few other things
like page migration take the page lock, but writeback takes the lock, 
queues it up, then drops the lock, and writeback actually happens outside
that lock. 

So on the GUP end, some combination of taking the page lock, and 
wait_on_page_writeback(), is required in order to flush out the writebacks.
I think I just rephrased what Jerome said, actually. :)


> 
> 
>> That actually touches on another question I wanted to get opinions on. GUP
>> can be for read and GUP can be for write (that is one of GUP flags).
>> Filesystems with page cache generally have issues only with GUP for write
>> as it can currently corrupt data, unexpectedly dirty page etc.. DAX & memory
>> hotplug have issues with both (DAX cannot truncate page pinned in any way,
>> memory hotplug will just loop in kernel until the page gets unpinned). So
>> we probably want to track both types of GUP pins and page-cache based
>> filesystems will take the hit even if they don't have to for read-pins?
> 
> Yes the distinction between read and write would be nice. With the map
> count solution you can only increment the mapcount for GUP(write=true).
> With pin bias the issue is that a big number of read pin can trigger
> false positive ie you would do:
>     GUP(vaddr, write)
>         ...
>         if (write)
>             atomic_add(page->refcount, PAGE_PIN_BIAS)
>         else
>             atomic_inc(page->refcount)
> 
>     PUP(page, write)
>         if (write)
>             atomic_add(page->refcount, -PAGE_PIN_BIAS)
>         else
>             atomic_dec(page->refcount)
> 
> I am guessing false positive because of too many read GUP is ok as
> it should be unlikely and when it happens then we take the hit.
> 

I'm also intrigued by the point that read-only GUP is harmless, and we 
could just focus on the writeable case.

However, I'm rather worried about actually attempting it, because remember
that so far, each call site does no special tracking of each struct page. 
It just remembers that it needs to do a put_page(), not whether or
not that particular page was set up with writeable or read-only GUP. I mean,
sure, they often call set_page_dirty before put_page, indicating that it might
have been a writeable GUP call, but it seems sketchy to rely on that.

So actually doing this could go from merely lots of work, to K*(lots_of_work)...


thanks,
-- 
John Hubbard
NVIDIA
