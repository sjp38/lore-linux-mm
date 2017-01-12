Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4E72C6B0253
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 20:23:27 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id b22so14291152pfd.0
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 17:23:27 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id 31si7454563pli.135.2017.01.11.17.23.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jan 2017 17:23:26 -0800 (PST)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH v5 2/9] mm/swap: Add cluster lock
References: <cover.1484082593.git.tim.c.chen@linux.intel.com>
	<dbb860bbd825b1aaba18988015e8963f263c3f0d.1484082593.git.tim.c.chen@linux.intel.com>
	<20170111150029.29e942aa00af69f9c3c4e9b1@linux-foundation.org>
	<20170111160729.23e06078@lwn.net>
Date: Thu, 12 Jan 2017 09:23:21 +0800
In-Reply-To: <20170111160729.23e06078@lwn.net> (Jonathan Corbet's message of
	"Wed, 11 Jan 2017 16:07:29 -0700")
Message-ID: <87a8ax137a.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tim Chen <tim.c.chen@linux.intel.com>, "Huang, Ying" <ying.huang@intel.com>, dave.hansen@intel.com, ak@linux.intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christian Borntraeger <borntraeger@de.ibm.com>

Hi, Jonathan,

Jonathan Corbet <corbet@lwn.net> writes:

> On Wed, 11 Jan 2017 15:00:29 -0800
> Andrew Morton <akpm@linux-foundation.org> wrote:
>
>> hm, bit_spin_lock() is a nasty thing.  It is slow and it doesn't have
>> all the lockdep support.
>> 
>> Would the world end if we added a spinlock to swap_cluster_info?
>
> FWIW, I asked the same question in December, this is what I got:

Sorry I made a mistake in the following email.  I have sent another
email to correct this before from my another email address,
huang.ying.caritas@gmail.com, have you received it, copied below,

From: huang ying <huang.ying.caritas@gmail.com>
Subject: Re: [PATCH v2 2/8] mm/swap: Add cluster lock
To: "Huang, Ying" <ying.huang@intel.com>
CC: Jonathan Corbet <corbet@lwn.net>, Tim Chen <tim.c.chen@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>, <dave.hansen@intel.com>, "Andi
 Kleen" <ak@linux.intel.com>, Aaron Lu <aaron.lu@intel.com>,
	<linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Hugh Dickins
	<hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim
	<minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli
	<aarcange@redhat.com>, "Kirill A . Shutemov"
	<kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov.dev@gmail.com>,
	Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Hillf
 Danton <hillf.zj@alibaba-inc.com>
Date: Wed, 28 Dec 2016 11:34:01 +0800 (2 weeks, 21 hours, 45 minutes ago)

Hi, Jonathan,

On Tue, Oct 25, 2016 at 10:05 AM, Huang, Ying <ying.huang@intel.com> wrote:
> Hi, Jonathan,
>
> Thanks for review.
>
> Jonathan Corbet <corbet@lwn.net> writes:
>
>> On Thu, 20 Oct 2016 16:31:41 -0700
>> Tim Chen <tim.c.chen@linux.intel.com> wrote:
>>
>>> From: "Huang, Ying" <ying.huang@intel.com>
>>>
>>> This patch is to reduce the lock contention of swap_info_struct->lock
>>> via using a more fine grained lock in swap_cluster_info for some swap
>>> operations.  swap_info_struct->lock is heavily contended if multiple

[...]

>> The cost, of course, is the growth of this structure, but you've already
>> noted that the overhead isn't all that high; seems like it could be worth
>> it.
>
> Yes.  The data structure you proposed is much easier to be used than the
> current one.  The main concern is the RAM usage.  The size of the data
> structure you proposed is about 80 bytes, while that of the current one
> is about 8 bytes.  There will be one struct swap_cluster_info for every
> 1MB swap space, so for 1TB swap space, the total size will be 80M
> compared with 8M of current implementation.

Sorry, I turned on the lockdep when measure the size change, so the
previous size change data is wrong.  The size of the data structure
you proposed is 12 bytes.  While that of the current one is 8 bytes on
64 bit platform and 4 bytes on 32 bit platform.

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
