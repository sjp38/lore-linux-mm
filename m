Return-Path: <linux-kernel-owner@vger.kernel.org>
MIME-Version: 1.0
References: <20190123110349.35882-1-keescook@chromium.org> <20190123110349.35882-2-keescook@chromium.org>
 <20190123115829.GA31385@kroah.com> <874l9z31c5.fsf@intel.com> <20190123191802.GB15311@bombadil.infradead.org>
In-Reply-To: <20190123191802.GB15311@bombadil.infradead.org>
From: Kees Cook <keescook@chromium.org>
Date: Thu, 24 Jan 2019 09:36:11 +1300
Message-ID: <CAGXu5jLNvHVhbyr5Cbyoe8o0ARv52sU-NEpD+u2UYfESM3ofCw@mail.gmail.com>
Subject: Re: [Intel-gfx] [PATCH 1/3] treewide: Lift switch variables out of switches
Content-Type: text/plain; charset="UTF-8"
Sender: linux-kernel-owner@vger.kernel.org
To: Matthew Wilcox <willy@infradead.org>
Cc: Jani Nikula <jani.nikula@linux.intel.com>, Greg KH <gregkh@linuxfoundation.org>, dev@openvswitch.org, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Network Development <netdev@vger.kernel.org>, intel-gfx@lists.freedesktop.org, linux-usb@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Maling list - DRI developers <dri-devel@lists.freedesktop.org>, Linux-MM <linux-mm@kvack.org>, linux-security-module <linux-security-module@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>, intel-wired-lan@lists.osuosl.org, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, xen-devel <xen-devel@lists.xenproject.org>, Laura Abbott <labbott@redhat.com>, linux-kbuild <linux-kbuild@vger.kernel.org>, Alexander Popov <alex.popov@linux.com>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 24, 2019 at 8:18 AM Matthew Wilcox <willy@infradead.org> wrote:
>
> On Wed, Jan 23, 2019 at 04:17:30PM +0200, Jani Nikula wrote:
> > Can't have:
> >
> >       switch (i) {
> >               int j;
> >       case 0:
> >               /* ... */
> >       }
> >
> > because it can't be turned into:
> >
> >       switch (i) {
> >               int j = 0; /* not valid C */
> >       case 0:
> >               /* ... */
> >       }
> >
> > but can have e.g.:
> >
> >       switch (i) {
> >       case 0:
> >               {
> >                       int j = 0;
> >                       /* ... */
> >               }
> >       }
> >
> > I think Kees' approach of moving such variable declarations to the
> > enclosing block scope is better than adding another nesting block.
>
> Another nesting level would be bad, but I think this is OK:
>
>         switch (i) {
>         case 0: {
>                 int j = 0;
>                 /* ... */
>         }
>         case 1: {
>                 void *p = q;
>                 /* ... */
>         }
>         }
>
> I can imagine Kees' patch might have a bad effect on stack consumption,
> unless GCC can be relied on to be smart enough to notice the
> non-overlapping liveness of the vriables and use the same stack slots
> for both.

GCC is reasonable at this. The main issue, though, was most of these
places were using the variables in multiple case statements, so they
couldn't be limited to a single block (or they'd need to be manually
repeated in each block, which is even more ugly, IMO).

Whatever the consensus, I'm happy to tweak the patch.

Thanks!

-- 
Kees Cook
