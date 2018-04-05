Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id CBC7C6B0003
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 14:43:29 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id 140-v6so3782441itg.4
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 11:43:29 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 80sor3973659ion.311.2018.04.05.11.43.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 05 Apr 2018 11:43:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180405211945-mutt-send-email-mst@kernel.org>
References: <1522431382-4232-1-git-send-email-mst@redhat.com>
 <20180405045231-mutt-send-email-mst@kernel.org> <CA+55aFwpe92MzEX2qRHO-MQsa1CP-iz6AmanFqXCV6_EaNKyMg@mail.gmail.com>
 <20180405171009-mutt-send-email-mst@kernel.org> <CA+55aFz_mCZQPV6ownt+pYnLFf9O+LUK_J6y4t1GUyWL1NJ2Lg@mail.gmail.com>
 <20180405211945-mutt-send-email-mst@kernel.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 5 Apr 2018 11:43:27 -0700
Message-ID: <CA+55aFwEqnY_Z5T-5UUwbxNJfV5MmfV=-8r73xvBnA1tnU_d_w@mail.gmail.com>
Subject: Re: [PATCH] gup: return -EFAULT on access_ok failure
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, stable <stable@vger.kernel.org>, syzbot+6304bf97ef436580fede@syzkaller.appspotmail.com, linux-mm <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Jonathan Corbet <corbet@lwn.net>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Thorsten Leemhuis <regressions@leemhuis.info>

On Thu, Apr 5, 2018 at 11:28 AM, Michael S. Tsirkin <mst@redhat.com> wrote:
>
> to repeat what you are saying IIUC __get_user_pages_fast returns 0 if it can't
> pin any pages and that is by design.  Returning 0 on error isn't usual I think
> so I guess this behaviour should we well documented.

Arguably it happens elsewhere too, and not just in the kernel.
"read()" at past the end of a file is not an error, you'll just get 0
for EOF.

So it's not really "returning 0 on error".

It really is simply returning the number of pages it got. End of
story. That number of pages can be smaller than the requested number
of pages, and _that_ is due to some error, but note how it can return
"5" on error too - you asked for 10 pages, but the error happened in
the middle!

So the right way to check for error is to bverify that you get the
number of pages that you asked for. If you don't, something bad
happened.

Of course, many users don't actually care about "I didn't get
everything". They only care about "did I get _something_". Then that 0
ends up being the error case, but note how it depends on the caller.

> What about get_user_pages_fast though?

We do seem to special-case the first page there. I'm not sure it's a
good idea. But like the __get_user_pages_fast(), we seem to have users
that know about the particular semantics and depend on it.

It's all ugly, I agree.

End result: we can't just change semantics of either of them.

At least not without going through every single user and checking that
they are ok with it.

Which I guess I could be ok with. Maybe changing the semantics of
__get_user_pages_fast() is acceptable, if you just change it
*everywhere* (which includes not just he users, but also the couple of
architecture-specific versions of that same function that we have.

                    Linus
