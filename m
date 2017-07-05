Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7D6F86B03A1
	for <linux-mm@kvack.org>; Wed,  5 Jul 2017 14:41:30 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id n42so17700051qtn.10
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 11:41:30 -0700 (PDT)
Received: from mail-qt0-x22a.google.com (mail-qt0-x22a.google.com. [2607:f8b0:400d:c0d::22a])
        by mx.google.com with ESMTPS id v14si21382615qta.33.2017.07.05.11.41.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jul 2017 11:41:29 -0700 (PDT)
Received: by mail-qt0-x22a.google.com with SMTP id i2so193843702qta.3
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 11:41:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170630094718.GE22917@dhcp22.suse.cz>
References: <9363561f-a9cd-7ab6-9c11-ab9a99dc89f1@oracle.com>
 <20170627070643.GA28078@dhcp22.suse.cz> <20170627153557.GB10091@rapoport-lnx>
 <51508e99-d2dd-894f-8d8a-678e3747c1ee@oracle.com> <20170628131806.GD10091@rapoport-lnx>
 <3a8e0042-4c49-3ec8-c59f-9036f8e54621@oracle.com> <20170629080910.GC31603@dhcp22.suse.cz>
 <936bde7b-1913-5589-22f4-9bbfdb6a8dd5@oracle.com> <20170630094718.GE22917@dhcp22.suse.cz>
From: John Stultz <john.stultz@linaro.org>
Date: Wed, 5 Jul 2017 11:41:28 -0700
Message-ID: <CALAqxLVO-7XwLFbKhm+WQh=LNzTr8W-+oeeqGAFuKRpEH99zDw@mail.gmail.com>
Subject: Re: [RFC PATCH] userfaultfd: Add feature to request for a signal delivery
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "prakash.sangappa" <prakash.sangappa@oracle.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Dave Hansen <dave.hansen@intel.com>, Christoph Hellwig <hch@infradead.org>, Linux API <linux-api@vger.kernel.org>

On Fri, Jun 30, 2017 at 2:47 AM, Michal Hocko <mhocko@kernel.org> wrote:
> [CC John, the thread started
> http://lkml.kernel.org/r/9363561f-a9cd-7ab6-9c11-ab9a99dc89f1@oracle.com]
>
> On Thu 29-06-17 14:41:22, prakash.sangappa wrote:
>>
>>
>> On 06/29/2017 01:09 AM, Michal Hocko wrote:
>> >On Wed 28-06-17 11:23:32, Prakash Sangappa wrote:
>> >>
>> >>On 6/28/17 6:18 AM, Mike Rapoport wrote:
>> >[...]
>> >>>I've just been thinking that maybe it would be possible to use
>> >>>UFFD_EVENT_REMOVE for this case. We anyway need to implement the generation
>> >>>of UFFD_EVENT_REMOVE for the case of hole punching in hugetlbfs for
>> >>>non-cooperative userfaultfd. It could be that it will solve your issue as
>> >>>well.
>> >>>
>> >>Will this result in a signal delivery?
>> >>
>> >>In the use case described, the database application does not need any event
>> >>for  hole punching. Basically, just a signal for any invalid access to
>> >>mapped area over holes in the file.
>> >OK, but it would be better to think that through for other potential
>> >usecases so that this doesn't end up as a single hugetlb feature. E.g.
>> >what should happen if a regular anonymous memory gets swapped out?
>> >Should we deliver signal as well? How does userspace tell whether this
>> >was a no backing page from unavailable backing page?
>>
>> This may not be useful in all cases. Potential, it could be used
>> with use of mlock() on anonymous memory to ensure any access
>> to memory that is not locked is caught, again for robustness
>> purpose.
>
> The thing I wanted to point out is that not only this should be a single
> usecase thing (I believe others will pop out as well - see below) but it
> should also be well defined as this is a user visible API. Please try to
> write a patch to the userfaultfd man page to clarify the exact semantic.
> This should help the further discussion.
>
> As an aside, I rememeber that prior to MADV_FREE there was long
> discussion about lazy freeing of memory from userspace. Some users
> wanted to be signalled when their memory was freed by the system so that
> they could rebuild the original content (e.g. uncompressed images in
> memory). It seems like MADV_FREE + this signalling could be used for
> that usecase. John would surely know more about those usecases.

Sorry for being slow to reply here. The main usecase for Android is
explicit marking and unmarking of volatile pages, where the userspace
is notified if any pages were purged when it sets a page range
non-volatile, and no access of volatile pages are made before they are
marked non-volatile.

As part of my generalization for the API, there were other users
interested in the marking pages volatile, and then optimistically
using the pages w/o marking them non-volatile. Then only when the user
touched a purged volatile page they would then get a signal they could
handle to mark the pages non-volatile and re-generate the data.

This second use case seems like it would be potentially doable with
the userfaultfd interface, but I'm not sure I see how we could fit the
first use case (which Android's ashmem provides) with it (at least in
an efficient way).

thanks
-john

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
