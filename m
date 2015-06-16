Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f169.google.com (mail-qk0-f169.google.com [209.85.220.169])
	by kanga.kvack.org (Postfix) with ESMTP id C15286B006C
	for <linux-mm@kvack.org>; Tue, 16 Jun 2015 08:17:52 -0400 (EDT)
Received: by qkhu186 with SMTP id u186so7548334qkh.0
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 05:17:52 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 76si716874qkz.88.2015.06.16.05.17.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jun 2015 05:17:52 -0700 (PDT)
Date: Tue, 16 Jun 2015 14:17:47 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 5/7] userfaultfd: switch to exclusive wakeup for blocking
 reads
Message-ID: <20150616121747.GJ18909@redhat.com>
References: <1434388931-24487-1-git-send-email-aarcange@redhat.com>
 <1434388931-24487-6-git-send-email-aarcange@redhat.com>
 <CA+55aFxD8hakE9SjhAD1_vJ9PATK+90k7yHQ2cENqGqK8r3QhQ@mail.gmail.com>
 <20150615221946.GI18909@redhat.com>
 <CA+55aFxZ2_Nix6-PrNE+yN87T02CdqG-y+piHXg=5AMGOiJy2A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFxZ2_Nix6-PrNE+yN87T02CdqG-y+piHXg=5AMGOiJy2A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Paolo Bonzini <pbonzini@redhat.com>, qemu-devel@nongnu.org, Pavel Emelyanov <xemul@parallels.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Andy Lutomirski <luto@amacapital.net>, linux-mm <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, zhang.zhanghailiang@huawei.com, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Peter Feiner <pfeiner@google.com>, Mel Gorman <mgorman@suse.de>, KVM list <kvm@vger.kernel.org>

On Mon, Jun 15, 2015 at 08:41:24PM -1000, Linus Torvalds wrote:
> On Mon, Jun 15, 2015 at 12:19 PM, Andrea Arcangeli <aarcange@redhat.com> wrote:
> >
> > Yes, it would leave the other blocked, how is it different from having
> > just 1 reader and it gets killed?
> 
> Either is completely wrong. But the read() code can at least see that
> "I'm returning early due to a signal, so I'll wake up any other
> waiters".
> 
> Poll simply *cannot* do that. Because by definition poll always
> returns without actually clearing the thing that caused the wakeup.
> 
> So for "poll()", using exclusive waits is wrong very much by
> definition. For read(), you *can* use exclusive waits correctly, it
> just requires you to wake up others if you don't read all the data
> (either due to being killed by a signal, or because the read was
> incomplete).

There's no interface to do wakeone with poll so I haven't thought much
about it frankly but intuitively it didn't look radically different as
long as poll checks every fd revent it gets. If I was to patch it to
introduce wakeone in poll I'd think more about it of course. Perhaps
I've been overoptimistic here.

> What does qemu have to do with anything?
> 
> We don't implement kernel interfaces that are broken, and that can
> leave processes blocked when they shouldn't be blocked. We also don't
> implement kernel interfaces that only work with one program and then
> say "if that program is broken, it's not our problem".

I'm testing with the stresstest application not with qemu, qemu cannot
take advantage of this anyway because it uses a single thread so far
and it uses poll not blocking reads. The stresstest suite listens to
events with one thread per CPU and it interleaves poll usage with
blocking reads at every bounce, and it's working correctly so far.

> > I'm not saying doing wakeone is easy [...]
> 
> Bullshit, Andrea.
> 
> That's *exactly* what you said in the commit message for the broken
> patch that I complained about. And I quote:

Please don't quote me out of context, and quote me in full if you
quote me:

"I'm not saying doing wakeone is easy and it's enough to flip a switch
everywhere to get it everywhere"

In the above paragraph (that you quoted in a truncated version of it)
I was talking in general, not specific to userfaultfd. I meant in
general wakeone is not easy.

> patch that I complained about. And I quote:
> 
>   "Blocking reads can easily use exclusive wakeups. Poll in theory
> could too but there's no poll_wait_exclusive in common code yet"

With "I'm not saying doing wakeone is easy and it's enough to flip a
switch everywhere to get it everywhere" I intended exactly to clarify
that "Blocking reads can easily use exclusive wakeups" was in the
context of userfaultfd only.

With regard to the patch you still haven't told what exactly what
runtime breakage I shall expect from my simple change. The case you
mentioned about a thread that gets killed is irrelevant because an
userfault would get missed anyway, if a task listening to userfaultfd
get killed after it received any uffd_msg structure. Wakeone or
wakeall won't move the needle for that case. There's no broadcast of
userfaults to all readers, even with wakeall, only the first reader
that wakes up, gets the messages, the others returns to sleep
immediately.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
