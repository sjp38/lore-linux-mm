Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4C7326B0005
	for <linux-mm@kvack.org>; Thu,  8 Mar 2018 16:08:35 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id l49so5265348qtf.4
        for <linux-mm@kvack.org>; Thu, 08 Mar 2018 13:08:35 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id h187si1991686qka.13.2018.03.08.13.08.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Mar 2018 13:08:34 -0800 (PST)
Subject: Re: [PATCH] hugetlbfs: check for pgoff value overflow
From: Mike Kravetz <mike.kravetz@oracle.com>
References: <20180306133135.4dc344e478d98f0e29f47698@linux-foundation.org>
 <20180307235923.12469-1-mike.kravetz@oracle.com>
 <8a0863a2-1890-11e0-1fc2-c96e1794e809@huawei.com>
 <c41368dd-1566-c69f-ee98-8e89fdc16eeb@oracle.com>
Message-ID: <91e7b7af-a9b5-3a13-74d4-34868e7befd9@oracle.com>
Date: Thu, 8 Mar 2018 13:03:21 -0800
MIME-Version: 1.0
In-Reply-To: <c41368dd-1566-c69f-ee98-8e89fdc16eeb@oracle.com>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yisheng Xie <xieyisheng1@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org
Cc: Michal Hocko <mhocko@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Nic Losby <blurbdust@gmail.com>, Andrew Morton <akpm@linux-foundation.org>

On 03/07/2018 08:25 PM, Mike Kravetz wrote:
> On 03/07/2018 05:35 PM, Yisheng Xie wrote:
>> However, region_chg makes me a litter puzzle that when its return value < 0, sometime
>> adds_in_progress is added like this case, while sometime it is not. so why not just
>> change at the beginning of region_chg ?
>> 	if (f > t)
>> 		return -EINVAL;
> 
> If region_chg returns a value < 0, this indicates an error and adds_in_progress
> should not be incremented.  In the case of this bug, region_chg was passed
> values where f > t.  Of course, this should never happen.  But, because it
> assumed f <= t, it returned a negative count needed huge page reservations.
> The calling code interpreted the negative value as an error and a subsequent
> region_add or region_abort.
> 
> I am not opposed to adding the suggested "if (f > t)".  However, the
> region tracking routines are simple helpers only used by the hugetlbfs
> code and the assumption is that they are being called correctly.  As
> such, I would prefer to leave off the check.  But, this is the second
> time they have been called incorrectly due to insufficient argument
> checking.  If we do add this to region_chg, I would also add the check
> to all region_* routines for consistency.

I really did not want to add the (f > t) check to the region_* routines.
As mentioned we should never encounter this condition.  Adding the check
here says that we missed discovering an error at higher levels.  Therefore,
I went back and examined the callers of region_chg.  There are only 2:
hugetlb_reserve_pages and __vma_reservation_common.  hugetlb_reserve_pages
is called to set up a reservation for a mapping.  __vma_reservation_common
is called to check on an existing reservation, and only operates on a
single huge page.  With this in mind, a check in hugetlb_reserve_pages
would be sufficient.  Therefore, I added an explicit check to that routine
and printed a warning if ever encountered.

> I will send out a V2 of this patch tomorrow with the corrected overflow
> checking and possibly checks added to the region_* routines.

v2 will be sent shortly.  In v2 I Cc stable as this is an issue for
stable branches as well.

-- 
Mike Kravetz
