Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f174.google.com (mail-qk0-f174.google.com [209.85.220.174])
	by kanga.kvack.org (Postfix) with ESMTP id C95796B006E
	for <linux-mm@kvack.org>; Mon, 15 Jun 2015 17:43:45 -0400 (EDT)
Received: by qkhq76 with SMTP id q76so61189374qkh.2
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 14:43:44 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l4si14199650qcn.47.2015.06.15.14.43.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jun 2015 14:43:43 -0700 (PDT)
Date: Mon, 15 Jun 2015 23:43:38 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/7] userfaultfd: require UFFDIO_API before other ioctls
Message-ID: <20150615214338.GH18909@redhat.com>
References: <1434388931-24487-1-git-send-email-aarcange@redhat.com>
 <1434388931-24487-2-git-send-email-aarcange@redhat.com>
 <CA+55aFzdZJw7Ot7=PYyyskNhkv=H+NPzoF6rKtb6oMyzkuQ-=Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFzdZJw7Ot7=PYyyskNhkv=H+NPzoF6rKtb6oMyzkuQ-=Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Paolo Bonzini <pbonzini@redhat.com>, qemu-devel@nongnu.org, Pavel Emelyanov <xemul@parallels.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Andy Lutomirski <luto@amacapital.net>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, zhang.zhanghailiang@huawei.com, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Peter Feiner <pfeiner@google.com>, Mel Gorman <mgorman@suse.de>, kvm@vger.kernel.org

On Mon, Jun 15, 2015 at 08:11:50AM -1000, Linus Torvalds wrote:
> On Jun 15, 2015 7:22 AM, "Andrea Arcangeli" <aarcange@redhat.com> wrote:
> >
> > +       if (cmd != UFFDIO_API) {
> > +               if (ctx->state == UFFD_STATE_WAIT_API)
> > +                       return -EINVAL;
> > +               BUG_ON(ctx->state != UFFD_STATE_RUNNING);
> > +       }
> 
> NAK.
> 
> Once again: we don't add BUG_ON() as some kind of assert. If your
> non-critical code has s bug in it, you do WARN_ONCE() and you return. You
> don't kill the machine just because of some "this can't happen" situation.
> 
> It turns out "this can't happen" happens way too often, just because code
> changes, or programmers didn't think all the cases through. And killing the
> machine is just NOT ACCEPTABLE.
> 
> People need to stop adding machine-killing checks to code that just doesn't
> merit killing the machine.
> 
> And if you are so damn sure that it really cannot happen ever, then you
> damn well had better remove the test too!
> 
> BUG_ON is not a debugging tool, or a "I think this would be bad" helper.

Several times I got very hardly reproducible bugs noticed purely
because of BUG_ON (not VM_BUG_ON) inserted out of pure paranoia, so I
know as a matter of fact that they're worth the little cost. It's hard
to tell if things didn't get worse, if the workload continued, or even
if I ended up getting a bugreport in the first place with only a
WARN_ON variant, precisely because a WARN_ON isn't necessarily a bug.

Example: when a WARN_ON in the network code showup (and they do once
in a while as there are so many), nobody panics because we assume it
may not actually be a bug so we can cross finger it goes away at the
next git fetch... not even sure if they all get reported in the first
place.

BUG_ONs are terribly annoying when they trigger, and even worse if
they're false positives, but they're worth the pain in my view.

Of course what's unacceptable is that BUG_ON can be triggered at will
by userland, that would be a security issue. Just in case I verified
to run two UFFDIO_API in a row and a UFFDIO_REGISTER without an
UFFDIO_API before it, and no BUG_ON triggers with this code inserted.

Said that it's your choice, so I'm not going to argue further about
this and I'm sure fine with WARN_ONCE too, there were a few more to
convert in the state machine invariant checks. While at it I can also
use VM_WARN_ONCE to cover my performance concern.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
