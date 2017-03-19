Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8039A6B039A
	for <linux-mm@kvack.org>; Sun, 19 Mar 2017 16:10:04 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id n11so12911796wma.5
        for <linux-mm@kvack.org>; Sun, 19 Mar 2017 13:10:04 -0700 (PDT)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id m30si20063450wrb.72.2017.03.19.13.10.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 19 Mar 2017 13:10:03 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id E545C98D09
	for <linux-mm@kvack.org>; Sun, 19 Mar 2017 20:10:02 +0000 (UTC)
Date: Sun, 19 Mar 2017 20:09:56 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [HMM 00/16] HMM (Heterogeneous Memory Management) v18
Message-ID: <20170319200956.GJ2774@techsingularity.net>
References: <1489680335-6594-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1489680335-6594-1-git-send-email-jglisse@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: J?r?me Glisse <jglisse@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>

On Thu, Mar 16, 2017 at 12:05:19PM -0400, J?r?me Glisse wrote:
> Cliff note: HMM offers 2 things (each standing on its own). First
> it allows to use device memory transparently inside any process
> without any modifications to process program code. Second it allows
> to mirror process address space on a device.
> 
> Changes since v17:
>   - typos
>   - ZONE_DEVICE page refcount move put_zone_device_page()
> 
> Work is still underway to use this feature inside the upstream
> nouveau driver. It has been tested with closed source driver
> and test are still underway on top of new kernel. So far we have
> found no issues. I expect to get a tested-by soon. Also this
> feature is not only useful for NVidia GPU, i expect AMD GPU will
> need it too if they want to support some of the new industry API.
> I also expect some FPGA company to use it and probably other
> hardware.
> 
> That being said I don't expect i will ever get a review-by anyone
> for reasons beyond my control.

I spent the length of time a battery lasts reading the patches during my
flight to LSF/MM showing that you can get people to review anything if
you lock them in a metal box for a few hours.

I only got as far as patch 13 before running low on time but decided to send
what I have anyway so you have the feedback before the LSF/MM topic. The
remaining patches are HMM specific and the intent was review how much the
core mm is affected and how hard this would be to maintain. I was less
concerned with the HMM internals itself but I assume that the authors
writing driver support can supply tested-by's.

Overall HMM is fairly well isolated.  The drivers can cause new and
interesting damage through the MMU notifiers and fault handling but that is
a driver, not a core, issue. There is new core code but most of it is active
only if a driver is so most people won't notice. Fast paths generally remain
unaffected except for one major case covered in the review. I also didn't
like the migrate_page API update and suggested an alternative. Most of the
other overhead is very minor. My expection is that most core code does not
have to care about HMM and while there is a risk that a driver can cause
damage through the notifiers, that is completely the responsibility of the
driver. Maybe some buglets exist in the new core migration code but again,
most people won't notice unless a suitable driver is loaded.

On that basis, if you address the major aspects of this review, I don't
have an objection at the moment to HMM being merged unlike the
objections I had to the CDM preparation patches that modified zonelist
handling, nodes and the page allocator fast paths.

It still leaves the problem of no in-kernel user of the API. The catch-22 has
now existed for years that driver support won't exist until it's merged and
it won't get merged without drivers. I won't object strongly on that basis
any more but others might. Maybe if this passes Andrew's review it could
be staged in mmotm until a driver or something like CDM is ready? That
would at least give a tree for driver authors to work against with the
resonable expectation that both HMM + driver would go in at the same time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
