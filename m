Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 87B7D6B0038
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 15:34:03 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id l33so11984929wrl.5
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 12:34:03 -0800 (PST)
Received: from out3-smtp.messagingengine.com (out3-smtp.messagingengine.com. [66.111.4.27])
        by mx.google.com with ESMTPS id b8si5343947edf.174.2017.12.19.12.34.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Dec 2017 12:34:02 -0800 (PST)
Date: Wed, 20 Dec 2017 07:33:57 +1100
From: "Tobin C. Harding" <me@tobin.cc>
Subject: Re: BUG: bad usercopy in memdup_user
Message-ID: <20171219203357.GT19604@eros>
References: <001a113e9ca8a3affd05609d7ccf@google.com>
 <6a50d160-56d0-29f9-cfed-6c9202140b43@I-love.SAKURA.ne.jp>
 <CAGXu5jKLBuQ8Ne6BjjPH+1SVw-Fj4ko5H04GHn-dxXYwoMEZtw@mail.gmail.com>
 <CACT4Y+a3h0hmGpfVaePX53QUQwBhN9BUyERp-5HySn74ee_Vxw@mail.gmail.com>
 <20171219083746.GR19604@eros>
 <20171219132246.GD13680@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171219132246.GD13680@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Dmitry Vyukov <dvyukov@google.com>, Kees Cook <keescook@chromium.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Linux-MM <linux-mm@kvack.org>, syzbot <bot+719398b443fd30155f92f2a888e749026c62b427@syzkaller.appspotmail.com>, David Windsor <dave@nullcore.net>, keun-o.park@darkmatter.ae, Laura Abbott <labbott@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Mark Rutland <mark.rutland@arm.com>, Ingo Molnar <mingo@kernel.org>, syzkaller-bugs@googlegroups.com, Will Deacon <will.deacon@arm.com>

On Tue, Dec 19, 2017 at 05:22:46AM -0800, Matthew Wilcox wrote:
> On Tue, Dec 19, 2017 at 07:37:46PM +1100, Tobin C. Harding wrote:
> > On Tue, Dec 19, 2017 at 09:12:58AM +0100, Dmitry Vyukov wrote:
> > > On Tue, Dec 19, 2017 at 1:57 AM, Kees Cook <keescook@chromium.org> wrote:
> > > > On Mon, Dec 18, 2017 at 6:22 AM, Tetsuo Handa
> > > >> This BUG is reporting
> > > >>
> > > >> [   26.089789] usercopy: kernel memory overwrite attempt detected to 0000000022a5b430 (kmalloc-1024) (1024 bytes)
> > > >>
> > > >> line. But isn't 0000000022a5b430 strange for kmalloc(1024, GFP_KERNEL)ed kernel address?
> > > >
> > > > The address is hashed (see the %p threads for 4.15).
> > > 
> > > 
> > > +Tobin, is there a way to disable hashing entirely? The only
> > > designation of syzbot is providing crash reports to kernel developers
> > > with as much info as possible. It's fine for it to leak whatever.
> > 
> > We have new specifier %px to print addresses in hex if leaking info is
> > not a worry.
> 
> Could we have a way to know that the printed address is hashed and not just
> a pointer getting completely scrogged?  Perhaps prefix it with ... a hash!
> So this line would look like:
> 
> [   26.089789] usercopy: kernel memory overwrite attempt detected to #0000000022a5b430 (kmalloc-1024) (1024 bytes)

This poses the risk of breaking userland tools that parse the
address. The zeroing of the first 32 bits was a design compromise to
keep the address format while making _kind of_ explicit that some funny
business was going on.

> Or does that miss the point of hashing the address, so the attacker
> thinks its a real address?

No subterfuge intended.

Bonus points Wily, I had to go to 'The New Hackers Dictionary' to look
up 'scrogged' :)

thanks,
Tobin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
