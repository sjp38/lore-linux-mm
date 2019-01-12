Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 901D08E0002
	for <linux-mm@kvack.org>; Sat, 12 Jan 2019 15:46:23 -0500 (EST)
Received: by mail-yw1-f71.google.com with SMTP id b8so9836581ywb.17
        for <linux-mm@kvack.org>; Sat, 12 Jan 2019 12:46:23 -0800 (PST)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id f65si49185101ywe.66.2019.01.12.12.46.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 12 Jan 2019 12:46:22 -0800 (PST)
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
References: <20190103015533.GA15619@redhat.com>
 <20190103092654.GA31370@quack2.suse.cz> <20190103144405.GC3395@redhat.com>
 <a79b259b-3982-b271-025a-0656f70506f4@nvidia.com>
 <20190111165141.GB3190@redhat.com>
 <1b37061c-5598-1b02-2983-80003f1c71f2@nvidia.com>
 <20190112020228.GA5059@redhat.com>
 <294bdcfa-5bf9-9c09-9d43-875e8375e264@nvidia.com>
 <20190112024625.GB5059@redhat.com>
 <b6f4ed36-fc8d-1f9b-8c74-b12f61d496ae@nvidia.com>
 <20190112032533.GD5059@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <9c80b708-35fa-3264-f114-b4d568939437@nvidia.com>
Date: Sat, 12 Jan 2019 12:46:20 -0800
MIME-Version: 1.0
In-Reply-To: <20190112032533.GD5059@redhat.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>, Dave
 Chinner <david@fromorbit.com>, Dan Williams <dan.j.williams@intel.com>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro,
 Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, mike.marciniszyn@intel.com, rcampbell@nvidia.com, Linux Kernel Mailing
 List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On 1/11/19 7:25 PM, Jerome Glisse wrote:
[...]
>>>> Why is it that page lock cannot be used for gup fast, btw?
>>>
>>> Well it can not happen within the preempt disable section. But after
>>> as a post pass before GUP_fast return and after reenabling preempt then
>>> it is fine like it would be for regular GUP. But locking page for GUP
>>> is also likely to slow down some workload (with direct-IO).
>>>
>>
>> Right, and so to crux of the matter: taking an uncontended page lock involves
>> pretty much the same set of operations that your approach does. (If gup ends up
>> contended with the page lock for other reasons than these paths, that seems
>> surprising.) I'd expect very similar performance.
>>
>> But the page lock approach leads to really dramatically simpler code (and code
>> reviews, let's not forget). Any objection to my going that direction, and keeping
>> this idea as a Plan B? I think the next step will be, once again, to gather some
>> performance metrics, so maybe that will help us decide.
> 
> They are already work load that suffer from the page lock so adding more
> code that need it will only worsen those situations. I guess i will do a
> patchset with my solution as it is definitly lighter weight that having to
> take the page lock.
> 

Hi Jerome,

I expect that you're right, and in any case, having you code up the new 
synchronization parts is probably a smart idea--you understand it best. To avoid
duplicating work, may I propose these steps:

1. I'll post a new RFC, using your mapcount idea, but with a minor variation: 
using the page lock to synchronize gup() and page_mkclean(). 

   a) I'll also include a github path that has enough gup callsite conversions
   done, to allow performance testing. 

   b) And also, you and others have provided a lot of information that I want to
   turn into nice neat comments and documentation.

2. Then your proposed synchronization system would only need to replace probably
one or two of the patches, instead of duplicating the whole patchset. I dread
having two large, overlapping patchsets competing, and hope we can avoid that mess.

3. We can run performance tests on both approaches, hopefully finding some test
cases that will highlight whether page lock is a noticeable problem here.

Or, the other thing that could happen is someone will jump in here and NAK anything
involving the page lock, based on long experience, and we'll just go straight to
your scheme anyway.  I'm sorta expecting that any minute now. :)

thanks,
-- 
John Hubbard
NVIDIA
