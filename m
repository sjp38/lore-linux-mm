Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f173.google.com (mail-vc0-f173.google.com [209.85.220.173])
	by kanga.kvack.org (Postfix) with ESMTP id EB4096B00C2
	for <linux-mm@kvack.org>; Mon,  9 Jun 2014 19:30:22 -0400 (EDT)
Received: by mail-vc0-f173.google.com with SMTP id lf12so1034771vcb.18
        for <linux-mm@kvack.org>; Mon, 09 Jun 2014 16:30:22 -0700 (PDT)
Received: from mail-vc0-x235.google.com (mail-vc0-x235.google.com [2607:f8b0:400c:c03::235])
        by mx.google.com with ESMTPS id o6si11144208vcr.56.2014.06.09.16.30.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 09 Jun 2014 16:30:22 -0700 (PDT)
Received: by mail-vc0-f181.google.com with SMTP id hq11so6985905vcb.40
        for <linux-mm@kvack.org>; Mon, 09 Jun 2014 16:30:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140609223028.GA13109@redhat.com>
References: <20140609223028.GA13109@redhat.com>
Date: Mon, 9 Jun 2014 16:30:21 -0700
Message-ID: <CA+55aFw8MzKeNFPO+CgxyBcH-VZP4Q0Te+-Ue+r3-NNBjZ=mFA@mail.gmail.com>
Subject: Re: rb_erase oops.
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Mon, Jun 9, 2014 at 3:30 PM, Dave Jones <davej@redhat.com> wrote:
>
> Oops: 0000 [#1] PREEMPT SMP

Dave, for some reason your oops is missing the first line. There
should have been something like

 "Unable to handle kernel NULL pointer access at 00000001"

or something.

Anyway, the code decodes to

  22: 48 8b 7a 08           mov    0x8(%rdx),%rdi
  26: 48 85 ff             test   %rdi,%rdi
  29: 74 09                 je     0x34
  2b:* f6 07 01             testb  $0x1,(%rdi) <-- trapping instruction

and %rdi has the value "1". Which isn't  NULL (so the test against
zero doesn't trigger), but obviously traps.

That *looks* like the test for

                        if (!tmp1 || rb_is_black(tmp1)) {

(the "testb $0x1,(%rdi)" is actually testing the low bit of the
"entry->__rb_tree_parent" pointer, and there's a subsequent "testb"
too, so it looks like one of the two cases where we look at the two
siblings and see if they are both NULL or black)

> Workqueue: events free_work

That's the "vfree was done in irq context, so we delay it into a
workqueue" worker.

> RIP: rb_erase+0xb9/0x380
> RAX: ffff8802396b0018 RBX: ffff88024176b008 RCX: 0000000000000000
> RDX: ffffc90010fe1bf0 RSI: ffffffff8afb3178 RDI: 0000000000000001
> RBP: ffff88009ed9fcc0 R08: ffff88023b122e58 R09: ffff88024176ae58
> R10: 0000000000000000 R11: ffff880245801dc0 R12: ffff88024176b020
> R13: ffff88009ed9fd80 R14: ffff88009ed9fd88 R15: ffff88024e397100
> FS:  0000000000000000(0000) GS:ffff88024e380000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 0000000000000001

.. and obviously the faulting address in CR2 is that invalid pointer "1".

The rbtree pointers have the two low bits reserved for color (only one
bit used - the low bit says whether it's red or black), so I'm
wondering if this is a "black NULL" pointer that hit some code
sequence that didn't properly mask off the color. But that really
shouldn't exist, afaik.

Perhaps just memory corruption (ie a NULL having been randomly
incremented to "1").

          Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
