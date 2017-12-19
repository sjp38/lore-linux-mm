Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3787D6B0038
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 15:45:13 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id t92so11986349wrc.13
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 12:45:13 -0800 (PST)
Received: from out3-smtp.messagingengine.com (out3-smtp.messagingengine.com. [66.111.4.27])
        by mx.google.com with ESMTPS id b18si12589518edh.513.2017.12.19.12.45.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Dec 2017 12:45:12 -0800 (PST)
Date: Wed, 20 Dec 2017 07:45:07 +1100
From: "Tobin C. Harding" <me@tobin.cc>
Subject: Re: BUG: bad usercopy in memdup_user
Message-ID: <20171219204507.GU19604@eros>
References: <CAGXu5jKLBuQ8Ne6BjjPH+1SVw-Fj4ko5H04GHn-dxXYwoMEZtw@mail.gmail.com>
 <CACT4Y+a3h0hmGpfVaePX53QUQwBhN9BUyERp-5HySn74ee_Vxw@mail.gmail.com>
 <20171219083746.GR19604@eros>
 <20171219132246.GD13680@bombadil.infradead.org>
 <CACT4Y+YMLL=3SBgbMep-E3FDOn7vwYOgQ_fqG+k8NL78+Fhcjw@mail.gmail.com>
 <201712192308.HJJ05711.SHQFVFLOMFOOJt@I-love.SAKURA.ne.jp>
 <CACT4Y+YC51waTR6DQE1QQMrSrdYoYnPOGvmbhGZcOieC=ccvXg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+YC51waTR6DQE1QQMrSrdYoYnPOGvmbhGZcOieC=ccvXg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Matthew Wilcox <willy@infradead.org>, Kees Cook <keescook@chromium.org>, Linux-MM <linux-mm@kvack.org>, syzbot <bot+719398b443fd30155f92f2a888e749026c62b427@syzkaller.appspotmail.com>, David Windsor <dave@nullcore.net>, keun-o.park@darkmatter.ae, Laura Abbott <labbott@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Mark Rutland <mark.rutland@arm.com>, Ingo Molnar <mingo@kernel.org>, syzkaller-bugs@googlegroups.com, Will Deacon <will.deacon@arm.com>, Linus Torvalds <torvalds@linux-foundation.org>

Adding Linus

On Tue, Dec 19, 2017 at 03:12:05PM +0100, Dmitry Vyukov wrote:
> On Tue, Dec 19, 2017 at 3:08 PM, Tetsuo Handa
> <penguin-kernel@i-love.sakura.ne.jp> wrote:
> > Dmitry Vyukov wrote:
> >> On Tue, Dec 19, 2017 at 2:22 PM, Matthew Wilcox <willy@infradead.org> wrote:
> >> >> > >> This BUG is reporting
> >> >> > >>
> >> >> > >> [   26.089789] usercopy: kernel memory overwrite attempt detected to 0000000022a5b430 (kmalloc-1024) (1024 bytes)
> >> >> > >>
> >> >> > >> line. But isn't 0000000022a5b430 strange for kmalloc(1024, GFP_KERNEL)ed kernel address?
> >> >> > >
> >> >> > > The address is hashed (see the %p threads for 4.15).
> >> >> >
> >> >> >
> >> >> > +Tobin, is there a way to disable hashing entirely? The only
> >> >> > designation of syzbot is providing crash reports to kernel developers
> >> >> > with as much info as possible. It's fine for it to leak whatever.
> >> >>
> >> >> We have new specifier %px to print addresses in hex if leaking info is
> >> >> not a worry.
> >> >
> >> > Could we have a way to know that the printed address is hashed and not just
> >> > a pointer getting completely scrogged?  Perhaps prefix it with ... a hash!
> >> > So this line would look like:
> >> >
> >> > [   26.089789] usercopy: kernel memory overwrite attempt detected to #0000000022a5b430 (kmalloc-1024) (1024 bytes)
> >> >
> >> > Or does that miss the point of hashing the address, so the attacker
> >> > thinks its a real address?
> >>
> >> If we do something with this, I would suggest that we just disable
> >> hashing. Any of the concerns that lead to hashed pointers are not
> >> applicable in this context, moreover they are harmful, cause confusion
> >> and make it harder to debug these bugs. That perfectly can be an
> >> opt-in CONFIG_DEBUG_INSECURE_BLA_BLA_BLA.
> >>
> > Why not a kernel command line option? Hashing by default.
> 
> 
> Would work for continuous testing systems too.
> I just thought that since it has security implications, a config would
> be more reliable. Say if a particular distribution builds kernel
> without this config, then there is no way to enable it on the fly,
> intentionally or not.

I wasn't the architect behind the hashing, I've cc'd Linus in the event
he wants to correct me. I believe that some of the benefit of hashing
was to shake things up and force people to think about this issue. If we
implement a method of disabling hashing (command-line parameter or
CONFIG_) at this stage then we risk loosing this benefit since one has
to assume that people will just take the easy option and disable
it. Though perhaps after things settle a bit we could implement this
without the risk?

thanks,
Tobin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
