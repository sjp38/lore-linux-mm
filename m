Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 28F586B0038
	for <linux-mm@kvack.org>; Fri, 19 Aug 2016 09:50:15 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id i64so87230567ith.2
        for <linux-mm@kvack.org>; Fri, 19 Aug 2016 06:50:15 -0700 (PDT)
Received: from EUR03-DB5-obe.outbound.protection.outlook.com (mail-eopbgr40104.outbound.protection.outlook.com. [40.107.4.104])
        by mx.google.com with ESMTPS id x5si4081263oix.240.2016.08.19.06.50.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 19 Aug 2016 06:50:14 -0700 (PDT)
Subject: Re: [PATCH 0/1] soft_dirty: fix soft_dirty during THP split
References: <1471610515-30229-1-git-send-email-aarcange@redhat.com>
 <57B70796.4080408@virtuozzo.com> <20160819134303.35newk6bku5rjdlj@redhat.com>
From: Pavel Emelyanov <xemul@virtuozzo.com>
Message-ID: <57B70F33.9090902@virtuozzo.com>
Date: Fri, 19 Aug 2016 16:52:51 +0300
MIME-Version: 1.0
In-Reply-To: <20160819134303.35newk6bku5rjdlj@redhat.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mike Rapoport <mike.rapoport@gmail.com>

On 08/19/2016 04:43 PM, Andrea Arcangeli wrote:
> On Fri, Aug 19, 2016 at 04:20:22PM +0300, Pavel Emelyanov wrote:
>> And (!) after non-cooperative patches are functional too.
> 
> I merged your non-cooperative patches in my tree although there's no
> testcase to exercise them yet.

Hm... Are you talking about some in-kernel test, or just any? We have
tests in CRIU tree for UFFD (not sure we've wired up the non-cooperative
part though).

>> Yes. Another problem of soft-dirty that will be addressed by uffd is
>> simultaneous memory tracking of two ... scanners (?) E.g. when we
>> reset soft-dirty to track the mem and then some other software comes
>> and tries to do the same, the whole soft-dirty state becomes screwed.
>> With uffd we'll at least have the ability for the first tracker to
>> keep the 2nd one off the tracking task.
> 
> Yes, that sounds like nesting will have to work for it though.
> 
> 		/*
> 		 * Check that this vma isn't already owned by a
> 		 * different userfaultfd. We can't allow more than one
> 		 * userfaultfd to own a single vma simultaneously or we
> 		 * wouldn't know which one to deliver the userfaults to.
> 		 */
> 		ret = -EBUSY;
> 		if (cur->vm_userfaultfd_ctx.ctx &&
> 		    cur->vm_userfaultfd_ctx.ctx != ctx)
> 			goto out_unlock;
> 
> This check shall be lifted... and it'll complicate the code quite a
> bit to lift it.

:)

> My main long term worry at the moment for the non-cooperative usage in
> fact is not really the non cooperative code itself, but the nesting of
> uffd if the app is already its own set of uffds for its own
> purposes. The nesting won't be straightforward.

And my main worry about this is COW-sharing. If we have two tasks that
fork()-ed from each other and we try to lazily restore a page that
is still COW-ed between them, the uffd API doesn't give us anything to
do it. So we effectively break COW on lazy restore. Do you have any
ideas what can be done about it?

> Do you have plans to solve the nesting?

We have ... readiness to do it :) since once CRIU hits this we'll have to.

> It's not just for the use case you mentioned above of two WP trackers
> on the same vma which sounds more "cooperative" than when the app
> already uses "uffd" for its own runtime.
> 
> userfaultfd is going to be used by apps like databases for reliability
> purposes on hugetlbfs or tmpfs (both already supported in my
> development tree), and I believe it'll be perfect to optimize the
> redis snapshotting removing any cons of THP-on and further optimizing
> the snapshot with thread instead of processes, potentially it can be
> used by to-native compilers to stop overwriting the write bit at every
> memory modification (and it'd be interesting to check if the JVM could
> use it too to drop the write bit too..). 

Yes, yes :) Apparently we'll hit this quite soon.

> Here a research article about
> the last usage case of the WP tracking:
> 
> https://medium.com/@MartinCracauer/generational-garbage-collection-write-barriers-write-protection-and-userfaultfd-2-8b0e796b8f7f
> 
> The nesting with virtual machines is strightforward because the uffd
> used by qemu becomes invisible to the guest. The complexities with the
> nesting happen when it has to work at the host level in a non
> cooperative way.
> 
> Thanks,
> Andrea
> .
> 

-- Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
