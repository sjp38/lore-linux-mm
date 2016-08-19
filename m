Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 315586B025E
	for <linux-mm@kvack.org>; Fri, 19 Aug 2016 09:43:06 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id g62so78197336ith.0
        for <linux-mm@kvack.org>; Fri, 19 Aug 2016 06:43:06 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o189si4833743itg.60.2016.08.19.06.43.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Aug 2016 06:43:05 -0700 (PDT)
Date: Fri, 19 Aug 2016 15:43:03 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 0/1] soft_dirty: fix soft_dirty during THP split
Message-ID: <20160819134303.35newk6bku5rjdlj@redhat.com>
References: <1471610515-30229-1-git-send-email-aarcange@redhat.com>
 <57B70796.4080408@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57B70796.4080408@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Emelyanov <xemul@virtuozzo.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Fri, Aug 19, 2016 at 04:20:22PM +0300, Pavel Emelyanov wrote:
> And (!) after non-cooperative patches are functional too.

I merged your non-cooperative patches in my tree although there's no
testcase to exercise them yet.

> Yes. Another problem of soft-dirty that will be addressed by uffd is
> simultaneous memory tracking of two ... scanners (?) E.g. when we
> reset soft-dirty to track the mem and then some other software comes
> and tries to do the same, the whole soft-dirty state becomes screwed.
> With uffd we'll at least have the ability for the first tracker to
> keep the 2nd one off the tracking task.

Yes, that sounds like nesting will have to work for it though.

		/*
		 * Check that this vma isn't already owned by a
		 * different userfaultfd. We can't allow more than one
		 * userfaultfd to own a single vma simultaneously or we
		 * wouldn't know which one to deliver the userfaults to.
		 */
		ret = -EBUSY;
		if (cur->vm_userfaultfd_ctx.ctx &&
		    cur->vm_userfaultfd_ctx.ctx != ctx)
			goto out_unlock;

This check shall be lifted... and it'll complicate the code quite a
bit to lift it.

My main long term worry at the moment for the non-cooperative usage in
fact is not really the non cooperative code itself, but the nesting of
uffd if the app is already its own set of uffds for its own
purposes. The nesting won't be straightforward.

Do you have plans to solve the nesting?

It's not just for the use case you mentioned above of two WP trackers
on the same vma which sounds more "cooperative" than when the app
already uses "uffd" for its own runtime.

userfaultfd is going to be used by apps like databases for reliability
purposes on hugetlbfs or tmpfs (both already supported in my
development tree), and I believe it'll be perfect to optimize the
redis snapshotting removing any cons of THP-on and further optimizing
the snapshot with thread instead of processes, potentially it can be
used by to-native compilers to stop overwriting the write bit at every
memory modification (and it'd be interesting to check if the JVM could
use it too to drop the write bit too..). Here a research article about
the last usage case of the WP tracking:

https://medium.com/@MartinCracauer/generational-garbage-collection-write-barriers-write-protection-and-userfaultfd-2-8b0e796b8f7f

The nesting with virtual machines is strightforward because the uffd
used by qemu becomes invisible to the guest. The complexities with the
nesting happen when it has to work at the host level in a non
cooperative way.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
