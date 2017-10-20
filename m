Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4C1AE6B0069
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 14:02:04 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id q4so11730085oic.12
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 11:02:04 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j7si464067oiy.118.2017.10.20.11.02.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Oct 2017 11:02:02 -0700 (PDT)
Date: Fri, 20 Oct 2017 20:02:00 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: RFC: spurious UFFD_EVENT_FORK with pending signals
Message-ID: <20171020180200.GG3394@redhat.com>
References: <20171007151609.GH16918@redhat.com>
 <20171009061949.GA20101@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171009061949.GA20101@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Mike Kravetz <mike.kravetz@oracle.com>, mhocko@suse.com, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Prakash Sangappa <prakash.sangappa@oracle.com>, Pavel Emelyanov <xemul@virtuozzo.com>

On Mon, Oct 09, 2017 at 09:19:50AM +0300, Mike Rapoport wrote:
> Indeed in CRIU we don't close the parent uffd and a couple of spurious
> UFFD_EVENT_FORK won't cause a real problem. Yet, if we'll run out of file
> descriptors because of signal flood during migration, even with graceful
> failure we'd loose the migrated process entirely.

That's precisely the problem. The only risk is file descriptor exhaustion.

> Currently userfault related code in fork.c neatly fits into dup_mmap() and
> moving the uffd structures up into the callers would be ugly :(

Which is why for now I'm going to patch the selftest with a #define
that can be undefined if the fork stops generating false
positives.

And this is needed only because the selftests cannot handle non
cooperative workload, and for it, the spurious fork event is otherwise
unexpected.

You couldn't notice this with CRIU (unless the manager run out fds).

> I'm going to experiment with the list of userfaultfd_ctx in mm_struct, it
> seems to me that it may have additional value, e.g. to simplify
> userfaultfd_event_wait_completion(). I'll need a bit of time to see if I'm
> not talking complete nonsense :)

Up to you, it's only a (minor) issue for non cooperative usage.

> > diff --git a/tools/testing/selftests/vm/userfaultfd.c b/tools/testing/selftests/vm/userfaultfd.c

I'll submit the selftest fix after I split this up and submit it, but
in the meantime if you work on this, to test any kernel change to the
event fork, you can apply the patch I already sent and define those
two:

#define REPRODUCE_SPURIOUS_UFFD_EVENT_FORK_IN_SIG_TEST
#define REPRODUCE_SPURIOUS_UFFD_EVENT_FORK_IN_EVENTS_TEST

You'll reproduce the spurious fork events immediately with it. Perhaps
the background signal flood can be slowed down a bit over time but it
doesn't seem to slow down the workload too much, it starts and stops
the signal flood (needed for immediate reproduction) every other second.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
