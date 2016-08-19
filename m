Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2BB226B0038
	for <linux-mm@kvack.org>; Fri, 19 Aug 2016 10:37:17 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id i27so46606164qte.3
        for <linux-mm@kvack.org>; Fri, 19 Aug 2016 07:37:17 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y188si1734937ybc.271.2016.08.19.07.37.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Aug 2016 07:37:16 -0700 (PDT)
Date: Fri, 19 Aug 2016 16:37:12 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 0/1] soft_dirty: fix soft_dirty during THP split
Message-ID: <20160819143712.fehugpmnxmxyydi2@redhat.com>
References: <1471610515-30229-1-git-send-email-aarcange@redhat.com>
 <57B70796.4080408@virtuozzo.com>
 <20160819134303.35newk6bku5rjdlj@redhat.com>
 <57B70F33.9090902@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57B70F33.9090902@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Emelyanov <xemul@virtuozzo.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mike Rapoport <mike.rapoport@gmail.com>

On Fri, Aug 19, 2016 at 04:52:51PM +0300, Pavel Emelyanov wrote:
> Hm... Are you talking about some in-kernel test, or just any? We have
> tests in CRIU tree for UFFD (not sure we've wired up the non-cooperative
> part though).

Nice. I wasn't aware you had uffd specific tests in CRIU, I'll check.

I was referring to the tools/testing/selftest/vm/userfault*, but I
suppose it's fine in CIRU as well. A self contained test suitable for
testing/selftest would be nice too as not everyone will run CRIU tests
to test the kernel.

Currently what's tested is anon missing, tmpfs missing and hugetlbfs
missing and they all work (just fixed two tmpfs bugs yesterday thanks
to the tmpfs test that crashed my workstation when I tried it, now it
passes fine :).

> And my main worry about this is COW-sharing. If we have two tasks that
> fork()-ed from each other and we try to lazily restore a page that
> is still COW-ed between them, the uffd API doesn't give us anything to
> do it. So we effectively break COW on lazy restore. Do you have any
> ideas what can be done about it?

Building a shared page is tricky, not even khugepaged was doing that
for anon.

Kirill extended khugepaged to do it, along the THP on tmpfs support,
as it's more important for tmpfs (I haven't yet checked if it landed
upstream with the rest of tmpfs in 4.8-rc though).

The main API problem is the uffd is different between parent and
child, fork with your non cooperative patches gives you a new uffd
that represents the child mm.

To create a shared page among two "mm" the API should be able to
specify the two "mm" and two "addresses" atomically in the same
ioctl. And the uffd _is_ the "mm" with the current API.

So what it takes to do it is to add a UFFDIO_COPY_COW that takes as
parameter an address for the current "uffd" and a list of "int uffd,
unsigned long address" pairs.

Even with the UFFDIO_COPY things should still work solid, it'll just
take more memory and it'll break-COW during restore. The important
thing is "break" is as in "allocate more memory", not as in "crashing" :).

> We have ... readiness to do it :) since once CRIU hits this we'll have to.

Ok great.

I also thought about it a bit and I think it's just a matter of
specifying which uffd should get the notification first. The manager
then will take the notification first and it will call an
UFFDIO_FAULT_PASS to cascade in the second uffd registered in the
region if the page was missing in the source container, without waking
up the task blocked in handle_userfault. To find the page is missing
in the source container you could use pagemap.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
