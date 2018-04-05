Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id C36AB6B0003
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 22:40:38 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id 140-v6so1191212itg.4
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 19:40:38 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id v2-v6sor2399716itd.117.2018.04.04.19.40.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 04 Apr 2018 19:40:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180405045231-mutt-send-email-mst@kernel.org>
References: <1522431382-4232-1-git-send-email-mst@redhat.com> <20180405045231-mutt-send-email-mst@kernel.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 4 Apr 2018 19:40:36 -0700
Message-ID: <CA+55aFwpe92MzEX2qRHO-MQsa1CP-iz6AmanFqXCV6_EaNKyMg@mail.gmail.com>
Subject: Re: [PATCH] gup: return -EFAULT on access_ok failure
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, stable <stable@vger.kernel.org>, syzbot+6304bf97ef436580fede@syzkaller.appspotmail.com, linux-mm <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Jonathan Corbet <corbet@lwn.net>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Thorsten Leemhuis <regressions@leemhuis.info>

On Wed, Apr 4, 2018 at 6:53 PM, Michael S. Tsirkin <mst@redhat.com> wrote:
>
> Any feedback on this? As this fixes a bug in vhost, I'll merge
> through the vhost tree unless someone objects.

NAK.

__get_user_pages_fast() returns the number of pages it gets.

It has never returned an error code, and all the other versions of it
(architecture-specific) don't either.

If you ask for one page, and get zero pages, then that's an -EFAULT.
Note that that's an EFAULT regardless of whether that zero page
happened due to kernel addresses or just lack of mapping in user
space.

The documentation is simply wrong if it says anything else. Fix the
docs, and fix the users.

The correct use has always been to check the number of pages returned.

Just looking around, returning an error number looks like it could
seriously confuse some things. You have things like the kvm code that
does the *right* thing:

        unsigned long ... npinned ...

        npinned = get_user_pages_fast(uaddr, npages, write ?
FOLL_WRITE : 0, pages);
        if (npinned != npages) {
     ...

err:
        if (npinned > 0)
                release_pages(pages, npinned);

and the above code clearly depends on the actual behavior, not on the
documentation.

Any changes in this area would need some *extreme* care, exactly
because of code like the above that clearly depends on the existing
semantics.

In fact, the documentation really seems to be just buggy. The actual
get_user_pages() function itself is expressly being careful *not* to
return an error code, it even has a comment to the effect ("Have to be
a bit careful with return values").

So the "If no pages were pinned, returns -errno" comment is just bogus.

                  Linus
