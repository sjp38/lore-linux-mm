Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f176.google.com (mail-qk0-f176.google.com [209.85.220.176])
	by kanga.kvack.org (Postfix) with ESMTP id 405546B0038
	for <linux-mm@kvack.org>; Mon, 15 Jun 2015 18:19:52 -0400 (EDT)
Received: by qkdm188 with SMTP id m188so40424968qkd.1
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 15:19:52 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o24si2984448qko.1.2015.06.15.15.19.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jun 2015 15:19:51 -0700 (PDT)
Date: Tue, 16 Jun 2015 00:19:46 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 5/7] userfaultfd: switch to exclusive wakeup for blocking
 reads
Message-ID: <20150615221946.GI18909@redhat.com>
References: <1434388931-24487-1-git-send-email-aarcange@redhat.com>
 <1434388931-24487-6-git-send-email-aarcange@redhat.com>
 <CA+55aFxD8hakE9SjhAD1_vJ9PATK+90k7yHQ2cENqGqK8r3QhQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFxD8hakE9SjhAD1_vJ9PATK+90k7yHQ2cENqGqK8r3QhQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Paolo Bonzini <pbonzini@redhat.com>, qemu-devel@nongnu.org, Pavel Emelyanov <xemul@parallels.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Andy Lutomirski <luto@amacapital.net>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, zhang.zhanghailiang@huawei.com, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Peter Feiner <pfeiner@google.com>, Mel Gorman <mgorman@suse.de>, kvm@vger.kernel.org

On Mon, Jun 15, 2015 at 08:19:07AM -1000, Linus Torvalds wrote:
> What if the process doing the polling never doors anything with the end
> result? Maybe it meant to, but it got killed before it could? Are you going
> to leave everybody else blocked, even though there are pending events?

Yes, it would leave the other blocked, how is it different from having
just 1 reader and it gets killed?

If any qemu thread gets killed the thing is going to be noticeable,
there's no fault-tolerance-double-thread for anything. If one wants to
use more threads for fault tolerance of this scenario with
userfaultfd, one just needs to add a feature flag to the
uffdio_api.features to request it and change the behavior to wakeall
but by default if we can do wakeone I think we should.

> The same us try of read() too. What if the reader only reads party of the
> message? The wake didn't wake anybody else, so now people are (again)
> blocked despite there being data.

I totally agree that for a normal read that would be a concern, but
the wakeone only applies to the uffd. I'm not even trying to change
other read methods.

The uffd can't short-read. Lengths not multiple of sizeof(struct
uffd_msg) immediately return -EINVAL. read will return one or more
events, sizeof(struct uffd_msg). Signal interruptions only are
reported if it's about to block and it found nothing.

> So no, exclusive waiting is never "simple". You have to 100% guarantee that
> you will consume all the data that caused the wake event (or perhaps wake
> the next person up if you don't).

I don't see where it goes wrong.

Now if __wake_up_common didn't check the retval of
default_wake_function->try_to_wake_up before decrements and checking
nr_exclusive I would where the problem about the next guy is, but it
does this:

		if (curr->func(curr, mode, wake_flags, key) &&
				(flags & WQ_FLAG_EXCLUSIVE) && !--nr_exclusive)
			break;

Every new userfault blocking (and at max 1 event to read is generated
for each new blocking userfaults) wakes one more reader, and each
reader is guaranteed to be blocked only if the pending (pending as not
read yet) waitqueue is truly empty. Where does it misbehave?

Yes each reader is required then to handle whatever userfault event it
got from read (or to pass it to another thread before quitting), but
this is a must anyway. This is because after the userfault is read it
is moved from pending fault queue to normal fault queue, so it won't
ever be read again, if it wasn't the case read would infinite loop and
it couldn't block (the same applies to poll, poll blocks after the
pending event has been read).

The testsuite can reproduce the bug fixed in 4/7 in like 3 seconds,
and it's 100% reproducible. And the window for such a bug is really
small: exactly in between list_del(); list_add the two
waitqueue_active must run in the other CPU. So it's hard to imagine if
this had some major issue, the testsuite wouldn't show it. In fact the
load seems to scale more evenly across all uffd threads too without no
apparent downside.

qemu uses just one reader, and it's even using poll, so this is not
needed for the short term production code, and it's totally fine to
defer this patch.

I'm not saying doing wakeone is easy and it's enough to flip a switch
everywhere to get it everywhere, and perhaps there's something wrong
still, I just I don't see where the actual bug is and how it should
work better without this patch but it's certainly fine to drop the
patch anyway (at least for now).

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
