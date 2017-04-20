Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 901752806CB
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 23:14:58 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id 7so10776404qtp.8
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 20:14:58 -0700 (PDT)
Received: from mail-qk0-x233.google.com (mail-qk0-x233.google.com. [2607:f8b0:400d:c09::233])
        by mx.google.com with ESMTPS id e1si4491963qtc.337.2017.04.19.20.14.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Apr 2017 20:14:57 -0700 (PDT)
Received: by mail-qk0-x233.google.com with SMTP id f133so36328758qke.2
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 20:14:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20161028183113.GB4611@redhat.com>
References: <1447181081-30056-1-git-send-email-aarcange@redhat.com>
 <1447181081-30056-2-git-send-email-aarcange@redhat.com> <1459974829.28435.6.camel@redhat.com>
 <20160406220202.GA2998@redhat.com> <CA+eFSM0e1XqnPweeLeYJJz=4zS6ixWzFRSeH6UaChey+o+FWPA@mail.gmail.com>
 <20160921153421.GA4716@redhat.com> <CA+eFSM33iAS98t5QU_+iOGH7F2VvMErwRvuuHnQU2JowZ8cMHg@mail.gmail.com>
 <CA+eFSM2WuMYZ8XXo2fJH1SxwTUMRNxAAEgBjrqdhcS4ZMCHMEw@mail.gmail.com> <20161028183113.GB4611@redhat.com>
From: Gavin Guo <gavin.guo@canonical.com>
Date: Thu, 20 Apr 2017 11:14:56 +0800
Message-ID: <CA+eFSM3kA8HfTuu7QwPxjFUYjC1uHOk7UM5e34gT8PWem89Mkw@mail.gmail.com>
Subject: Re: [PATCH 1/1] ksm: introduce ksm_max_page_sharing per page
 deduplication limit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, linux-mm@kvack.org, Petr Holasek <pholasek@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Arjan van de Ven <arjan@linux.intel.com>, Jay Vosburgh <jay.vosburgh@canonical.com>

On Sat, Oct 29, 2016 at 2:31 AM, Andrea Arcangeli <aarcange@redhat.com> wrote:
>
> On Fri, Oct 28, 2016 at 02:26:03PM +0800, Gavin Guo wrote:
> > I have tried verifying these patches. However, the default 256
> > bytes max_page_sharing still suffers the hung task issue. Then, the
> > following sequence has been tried to mitigate the symptom. When the
> > value is decreased, it took more time to reproduce the symptom.
> > Finally, the value 8 has been tried and I didn't continue with lower
> > value.
> >
> > 128 -> 64 -> 32 -> 16 -> 8
> >
> > The crashdump has also been investigated.
>
> You should try to get multiple sysrq+l too during the hang.
>
> > stable_node: 0xffff880d36413040 stable_node->hlist->first = 0xffff880e4c9f4cf0
> > crash> list hlist_node.next 0xffff880e4c9f4cf0  > rmap_item.lst
> >
> > $ wc -l rmap_item.lst
> > $ 8 rmap_item.lst
> >
> > This shows that the list is actually reduced to 8 items. I wondered if the
> > loop is still consuming a lot of time and hold the mmap_sem too long.
>
> Even the default 256 would be enough (certainly with KVM that doesn't
> have a deep anon_vma interval tree).
>
> Perhaps this is an app with a massively large anon_vma interval tree
> and uses MADV_MERGEABLE and not qemu/kvm? However then you'd run in
> similar issues with anon pages rmap walks so KSM wouldn't be to
> blame. The depth of the rmap_items multiplies the cost of the rbtree
> walk 512 times but still it shouldn't freeze for seconds.
>
> The important thing here is that the app is in control of the max
> depth of the anon_vma interval tree while it's not in control of the
> max depth of the rmap_item list, this is why it's fundamental that the
> KSM rmap_item list is bounded to a max value, while the depth of the
> interval tree is secondary issue because userland has a chance to
> optimize for it. If the app deep forks and uses MADV_MERGEABLE that is
> possible to optimize in userland. But I guess the app that is using
> MADV_MERGEABLE is qemu/kvm for you too so it can't be a too long
> interval tree. Furthermore if when the symptom triggers you still get
> a long hang even with rmap_item depth of 8 and it just takes longer
> time to reach the hanging point, it may be something else.
>
> I assume this is not an upstream kernel, can you reproduce on the
> upstream kernel? Sorry but I can't help you any further, if this isn't
> first verified on the upstream kernel.
>
> Also if you test on the upstream kernel you can leave the default
> value of 256 and then use sysrq+l to get multiple dumps of what's
> running in the CPUs. The crash dump is useful as well but it's also
> interesting to see what's running most frequently during the hang
> (which isn't guaranteed to be shown by the exact point in time the
> crash dump is being taken). perf top -g may also help if this is a
> computational complexity issue inside the kernel to see where most CPU
> is being burnt.
>
> Note the problem was reproduced and verified as fixed. It's quite easy
> to reproduce, I used migrate_pages syscall to do that, and after the
> deep KSM merging that takes several seconds in strace -tt, while with
> the fix it stays in the order of milliseconds. The point is that with
> deeper merging the migrate_pages could take minutes in unkillable R
> state (or during swapping), while with the KSMscale fix it gets capped
> to milliseconds no matter what.
>
> Thanks,
> Andrea

Andrea,

After spending some time, the problem was sorted out. Actually, there
are 2 bugs in a tangle. The other one has been identified and solved.

I've applied your patch to the Ubuntu 4.4 kernel and it works as
expected. Without the patch, The bug can be observed by the perf flame
graph[1]. With the patch, the unstable CPU loading cannot be observed
inside the virtual appliances monitor[2].

I have tested this patch at least 3 weeks, and it's stable. This patch
should be merged into the upstream kernel.

Tested-by: Gavin Guo <gavin.guo@canonical.com>

[1]. http://kernel.ubuntu.com/~gavinguo/sf00131845/numa-131845.svg
[2]. http://kernel.ubuntu.com/~gavinguo/sf00131845/virtual_appliances_loading.png

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
