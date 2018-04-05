Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3E6056B0003
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 15:40:18 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id l12so1887061wmh.4
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 12:40:18 -0700 (PDT)
Received: from fireflyinternet.com (mail.fireflyinternet.com. [109.228.58.192])
        by mx.google.com with ESMTPS id f58si6309577wra.479.2018.04.05.12.40.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Apr 2018 12:40:17 -0700 (PDT)
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
From: Chris Wilson <chris@chris-wilson.co.uk>
In-Reply-To: <20180405215744-mutt-send-email-mst@kernel.org>
References: <1522431382-4232-1-git-send-email-mst@redhat.com>
 <20180405045231-mutt-send-email-mst@kernel.org>
 <CA+55aFwpe92MzEX2qRHO-MQsa1CP-iz6AmanFqXCV6_EaNKyMg@mail.gmail.com>
 <20180405171009-mutt-send-email-mst@kernel.org>
 <CA+55aFz_mCZQPV6ownt+pYnLFf9O+LUK_J6y4t1GUyWL1NJ2Lg@mail.gmail.com>
 <20180405211945-mutt-send-email-mst@kernel.org>
 <CA+55aFwEqnY_Z5T-5UUwbxNJfV5MmfV=-8r73xvBnA1tnU_d_w@mail.gmail.com>
 <20180405215744-mutt-send-email-mst@kernel.org>
Message-ID: <152295717252.23264.15314297102427001125@mail.alporthouse.com>
Subject: Re: [PATCH] gup: return -EFAULT on access_ok failure
Date: Thu, 05 Apr 2018 20:39:32 +0100
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, stable <stable@vger.kernel.org>, syzbot+6304bf97ef436580fede@syzkaller.appspotmail.com, linux-mm <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Jonathan Corbet <corbet@lwn.net>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Thorsten Leemhuis <regressions@leemhuis.info>, Tvrtko Ursulin <tvrtko.ursulin@linux.intel.com>, "Gong,
 Zhipeng" <zhipeng.gong@intel.com>, Akash Goel <akash.goel@intel.com>, "Volkin, Bradley D" <bradley.d.volkin@intel.com>, Daniel Vetter <daniel.vetter@ffwll.ch>

Quoting Michael S. Tsirkin (2018-04-05 20:34:08)
> On Thu, Apr 05, 2018 at 11:43:27AM -0700, Linus Torvalds wrote:
> > On Thu, Apr 5, 2018 at 11:28 AM, Michael S. Tsirkin <mst@redhat.com> wr=
ote:
> > >
> > > to repeat what you are saying IIUC __get_user_pages_fast returns 0 if=
 it can't
> > > pin any pages and that is by design.  Returning 0 on error isn't usua=
l I think
> > > so I guess this behaviour should we well documented.
> > =

> > Arguably it happens elsewhere too, and not just in the kernel.
> > "read()" at past the end of a file is not an error, you'll just get 0
> > for EOF.
> > =

> > So it's not really "returning 0 on error".
> > =

> > It really is simply returning the number of pages it got. End of
> > story. That number of pages can be smaller than the requested number
> > of pages, and _that_ is due to some error, but note how it can return
> > "5" on error too - you asked for 10 pages, but the error happened in
> > the middle!
> > =

> > So the right way to check for error is to bverify that you get the
> > number of pages that you asked for. If you don't, something bad
> > happened.
> > =

> > Of course, many users don't actually care about "I didn't get
> > everything". They only care about "did I get _something_". Then that 0
> > ends up being the error case, but note how it depends on the caller.
> > =

> > > What about get_user_pages_fast though?
> > =

> > We do seem to special-case the first page there. I'm not sure it's a
> > good idea. But like the __get_user_pages_fast(), we seem to have users
> > that know about the particular semantics and depend on it.
> > =

> > It's all ugly, I agree.
> > =

> > End result: we can't just change semantics of either of them.
> > =

> > At least not without going through every single user and checking that
> > they are ok with it.
> > =

> > Which I guess I could be ok with. Maybe changing the semantics of
> > __get_user_pages_fast() is acceptable, if you just change it
> > *everywhere* (which includes not just he users, but also the couple of
> > architecture-specific versions of that same function that we have.
> > =

> >                     Linus
> =

> OK I hope I understood what you are saying here.
> =

> At least drivers/gpu/drm/i915/i915_gem_userptr.c seems to
> get it wrong:
> =

>         pinned =3D __get_user_pages_fast(obj->userptr.ptr,
> =

>         if (pinned < 0) {
>                 pages =3D ERR_PTR(pinned);
>                 pinned =3D 0;
>         } else if (pinned < num_pages) {
>                 pages =3D __i915_gem_userptr_get_pages_schedule(obj);
>                 active =3D pages =3D=3D ERR_PTR(-EAGAIN);
>         } else {
>                 pages =3D __i915_gem_userptr_alloc_pages(obj, pvec, num_p=
ages);
>                 active =3D !IS_ERR(pages);
>         }
> =

> The <0 path is never taken.

Please note that it only recently lost other paths that set an error
beforehand. Not exactly wrong since the short return is expected and
handled.

> Cc maintainers - should that driver be changed to use
> get_user_pages_fast?

It's not allowed to fault. __gup_fast has that comment, gup_fast does
not.
-Chris
