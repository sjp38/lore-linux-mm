Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0438F8E0001
	for <linux-mm@kvack.org>; Fri, 28 Sep 2018 15:06:16 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id c67-v6so4111969ywh.13
        for <linux-mm@kvack.org>; Fri, 28 Sep 2018 12:06:15 -0700 (PDT)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id d185-v6si1290424ybc.240.2018.09.28.12.06.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Sep 2018 12:06:14 -0700 (PDT)
Subject: Re: [PATCH 0/4] get_user_pages*() and RDMA: first steps
References: <20180928053949.5381-1-jhubbard@nvidia.com>
 <20180928152958.GA3321@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <4c884529-e2ff-3808-9763-eb0e71f5a616@nvidia.com>
Date: Fri, 28 Sep 2018 12:06:12 -0700
MIME-Version: 1.0
In-Reply-To: <20180928152958.GA3321@redhat.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>, john.hubbard@gmail.com
Cc: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, Christian Benvenuti <benve@cisco.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>

On 9/28/18 8:29 AM, Jerome Glisse wrote:
> On Thu, Sep 27, 2018 at 10:39:45PM -0700, john.hubbard@gmail.com wrote:
>> From: John Hubbard <jhubbard@nvidia.com>
>>
>> Hi,
>>
>> This short series prepares for eventually fixing the problem described
>> in [1], and is following a plan listed in [2].
>>
>> I'd like to get the first two patches into the -mm tree.
>>
>> Patch 1, although not technically critical to do now, is still nice to have,
>> because it's already been reviewed by Jan, and it's just one more thing on the
>> long TODO list here, that is ready to be checked off.
>>
>> Patch 2 is required in order to allow me (and others, if I'm lucky) to start
>> submitting changes to convert all of the callsites of get_user_pages*() and
>> put_page().  I think this will work a lot better than trying to maintain a
>> massive patchset and submitting all at once.
>>
>> Patch 3 converts infiniband drivers: put_page() --> put_user_page(). I picked
>> a fairly small and easy example.
>>
>> Patch 4 converts a small driver from put_page() --> release_user_pages(). This
>> could just as easily have been done as a change from put_page() to
>> put_user_page(). The reason I did it this way is that this provides a small and
>> simple caller of the new release_user_pages() routine. I wanted both of the
>> new routines, even though just placeholders, to have callers.
>>
>> Once these are all in, then the floodgates can open up to convert the large
>> number of get_user_pages*() callsites.
>>
>> [1] https://lwn.net/Articles/753027/ : "The Trouble with get_user_pages()"
>>
>> [2] https://lkml.kernel.org/r/20180709080554.21931-1-jhubbard@nvidia.com
>>     Proposed steps for fixing get_user_pages() + DMA problems.
>>
> 
> So the solution is to wait (possibly for days, months, years) that the
> RDMA or GPU which did GUP and do not have mmu notifier, release the page
> (or put_user_page()) ?
> 
> This sounds bads. Like i said during LSF/MM there is no way to properly
> fix hardware that can not be preempted/invalidated ... most GPU are fine.
> Few RDMA are fine, most can not ...
> 

Hi Jerome,

Personally, I'm think that this particular design is the best one I've seen
so far, but if other, better designs show up, than let's do those instead, sure.

I guess your main concern is that this might take longer than other approaches.

As for time frame, perhaps I made it sound worse than it really is. I have patches
staged already for all of the simpler call sites, and for about half of the more
complicated ones. The core solution in mm is not large, and we've gone through a 
few discussion threads about it back in July or so, so it shouldn't take too long
to perfect it.

So it may be a few months to get it all reviewed and submitted, but I don't
see "years" by any stretch.


> If it is just about fixing the set_page_dirty() bug then just looking at
> refcount versus mapcount should already tell you if you can remove the
> buffer head from the page or not. Which would fix the bug without complex
> changes (i still like the put_user_page just for symetry with GUP).
> 

It's about more than that. The goal is to make it safe and correct to
use a non-CPU device to read and write to "pinned" memory, especially when
that memory is backed by a file system.

I recall there were objections to just narrowly fixing the set_page_dirty()
bug, because the underlying problem is large and serious. So here we are.

thanks,
-- 
John Hubbard
NVIDIA
