Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id A81A88E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 00:25:08 -0500 (EST)
Received: by mail-yw1-f70.google.com with SMTP id t17so4573188ywc.23
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 21:25:08 -0800 (PST)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id 204si629073ywi.272.2019.01.16.21.25.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 21:25:07 -0800 (PST)
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
References: <20190103144405.GC3395@redhat.com>
 <a79b259b-3982-b271-025a-0656f70506f4@nvidia.com>
 <20190111165141.GB3190@redhat.com>
 <1b37061c-5598-1b02-2983-80003f1c71f2@nvidia.com>
 <20190112020228.GA5059@redhat.com>
 <294bdcfa-5bf9-9c09-9d43-875e8375e264@nvidia.com>
 <20190112024625.GB5059@redhat.com>
 <b6f4ed36-fc8d-1f9b-8c74-b12f61d496ae@nvidia.com>
 <20190114145447.GJ13316@quack2.suse.cz> <20190114172124.GA3702@redhat.com>
 <20190115080759.GC29524@quack2.suse.cz>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <76788484-d5ec-91f2-1f66-141764ba0b1e@nvidia.com>
Date: Wed, 16 Jan 2019 21:25:05 -0800
MIME-Version: 1.0
In-Reply-To: <20190115080759.GC29524@quack2.suse.cz>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>, Jerome Glisse <jglisse@redhat.com>
Cc: Matthew Wilcox <willy@infradead.org>, Dave Chinner <david@fromorbit.com>, Dan Williams <dan.j.williams@intel.com>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, mike.marciniszyn@intel.com, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On 1/15/19 12:07 AM, Jan Kara wrote:
>>>>> [...]
>>> Also there is one more idea I had how to record number of pins in the page:
>>>
>>> #define PAGE_PIN_BIAS	1024
>>>
>>> get_page_pin()
>>> 	atomic_add(&page->_refcount, PAGE_PIN_BIAS);
>>>
>>> put_page_pin();
>>> 	atomic_add(&page->_refcount, -PAGE_PIN_BIAS);
>>>
>>> page_pinned(page)
>>> 	(atomic_read(&page->_refcount) - page_mapcount(page)) > PAGE_PIN_BIAS
>>>
>>> This is pretty trivial scheme. It still gives us 22-bits for page pins
>>> which should be plenty (but we should check for that and bail with error if
>>> it would overflow). Also there will be no false negatives and false
>>> positives only if there are more than 1024 non-page-table references to the
>>> page which I expect to be rare (we might want to also subtract
>>> hpage_nr_pages() for radix tree references to avoid excessive false
>>> positives for huge pages although at this point I don't think they would
>>> matter). Thoughts?

Hi Jan,

Some details, sorry I'm not fully grasping your plan without more explanation:

Do I read it correctly that this uses the lower 10 bits for the original
page->_refcount, and the upper 22 bits for gup-pinned counts? If so, I'm surprised,
because gup-pinned is going to be less than or equal to the normal (get_page-based)
pin count. And 1024 seems like it might be reached in a large system with lots
of processes and IPC.

Are you just allowing the lower 10 bits to overflow, and that's why the 
subtraction of mapcount? Wouldn't it be better to allow more than 10 bits, 
instead?

Another question: do we just allow other kernel code to observe this biased
_refcount, or do we attempt to filter it out?  In other words, do you expect 
problems due to some kernel code checking the _refcount and finding a large 
number there, when it expected, say, 3? I recall some code tries to do 
that...in fact, ZONE_DEVICE is 1-based, instead of zero-based, with respect 
to _refcount, right?

thanks,
-- 
John Hubbard
NVIDIA
