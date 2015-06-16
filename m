Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f173.google.com (mail-ie0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id 607D56B0038
	for <linux-mm@kvack.org>; Tue, 16 Jun 2015 02:41:25 -0400 (EDT)
Received: by iecrd14 with SMTP id rd14so6862692iec.3
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 23:41:25 -0700 (PDT)
Received: from mail-ig0-x230.google.com (mail-ig0-x230.google.com. [2607:f8b0:4001:c05::230])
        by mx.google.com with ESMTPS id g14si616341icn.23.2015.06.15.23.41.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jun 2015 23:41:24 -0700 (PDT)
Received: by igblz2 with SMTP id lz2so7531346igb.1
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 23:41:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150615221946.GI18909@redhat.com>
References: <1434388931-24487-1-git-send-email-aarcange@redhat.com>
	<1434388931-24487-6-git-send-email-aarcange@redhat.com>
	<CA+55aFxD8hakE9SjhAD1_vJ9PATK+90k7yHQ2cENqGqK8r3QhQ@mail.gmail.com>
	<20150615221946.GI18909@redhat.com>
Date: Mon, 15 Jun 2015 20:41:24 -1000
Message-ID: <CA+55aFxZ2_Nix6-PrNE+yN87T02CdqG-y+piHXg=5AMGOiJy2A@mail.gmail.com>
Subject: Re: [PATCH 5/7] userfaultfd: switch to exclusive wakeup for blocking reads
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Paolo Bonzini <pbonzini@redhat.com>, qemu-devel@nongnu.org, Pavel Emelyanov <xemul@parallels.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Andy Lutomirski <luto@amacapital.net>, linux-mm <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, zhang.zhanghailiang@huawei.com, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Peter Feiner <pfeiner@google.com>, Mel Gorman <mgorman@suse.de>, KVM list <kvm@vger.kernel.org>

On Mon, Jun 15, 2015 at 12:19 PM, Andrea Arcangeli <aarcange@redhat.com> wrote:
>
> Yes, it would leave the other blocked, how is it different from having
> just 1 reader and it gets killed?

Either is completely wrong. But the read() code can at least see that
"I'm returning early due to a signal, so I'll wake up any other
waiters".

Poll simply *cannot* do that. Because by definition poll always
returns without actually clearing the thing that caused the wakeup.

So for "poll()", using exclusive waits is wrong very much by
definition. For read(), you *can* use exclusive waits correctly, it
just requires you to wake up others if you don't read all the data
(either due to being killed by a signal, or because the read was
incomplete).

> If any qemu thread gets killed the thing is going to be noticeable,
> there's no fault-tolerance-double-thread for anything.

What does qemu have to do with anything?

We don't implement kernel interfaces that are broken, and that can
leave processes blocked when they shouldn't be blocked. We also don't
implement kernel interfaces that only work with one program and then
say "if that program is broken, it's not our problem".

> I'm not saying doing wakeone is easy [...]

Bullshit, Andrea.

That's *exactly* what you said in the commit message for the broken
patch that I complained about. And I quote:

  "Blocking reads can easily use exclusive wakeups. Poll in theory
could too but there's no poll_wait_exclusive in common code yet"

and I pointed out that your commit message was garbage, and that it's
not at all as easy as you claim, and that your patch was broken, and
your description was even more broken.

The whole "poll cannot use exclsive waits" has _nothing_ to do with us
not having "poll_wait_exclusive()". Poll *fundamentally* cannot use
exclusive waits. Your commit message was garbage, and actively
misleading. Don't make excuses.

                 Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
