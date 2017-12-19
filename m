Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6FC216B0272
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 08:42:17 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id g33so7459064plb.13
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 05:42:17 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id v62sor344642pgb.41.2017.12.19.05.42.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Dec 2017 05:42:16 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171219132246.GD13680@bombadil.infradead.org>
References: <001a113e9ca8a3affd05609d7ccf@google.com> <6a50d160-56d0-29f9-cfed-6c9202140b43@I-love.SAKURA.ne.jp>
 <CAGXu5jKLBuQ8Ne6BjjPH+1SVw-Fj4ko5H04GHn-dxXYwoMEZtw@mail.gmail.com>
 <CACT4Y+a3h0hmGpfVaePX53QUQwBhN9BUyERp-5HySn74ee_Vxw@mail.gmail.com>
 <20171219083746.GR19604@eros> <20171219132246.GD13680@bombadil.infradead.org>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 19 Dec 2017 14:41:55 +0100
Message-ID: <CACT4Y+YMLL=3SBgbMep-E3FDOn7vwYOgQ_fqG+k8NL78+Fhcjw@mail.gmail.com>
Subject: Re: BUG: bad usercopy in memdup_user
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: "Tobin C. Harding" <me@tobin.cc>, Kees Cook <keescook@chromium.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Linux-MM <linux-mm@kvack.org>, syzbot <bot+719398b443fd30155f92f2a888e749026c62b427@syzkaller.appspotmail.com>, David Windsor <dave@nullcore.net>, keun-o.park@darkmatter.ae, Laura Abbott <labbott@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Mark Rutland <mark.rutland@arm.com>, Ingo Molnar <mingo@kernel.org>, syzkaller-bugs@googlegroups.com, Will Deacon <will.deacon@arm.com>

On Tue, Dec 19, 2017 at 2:22 PM, Matthew Wilcox <willy@infradead.org> wrote:
>> > >> This BUG is reporting
>> > >>
>> > >> [   26.089789] usercopy: kernel memory overwrite attempt detected to 0000000022a5b430 (kmalloc-1024) (1024 bytes)
>> > >>
>> > >> line. But isn't 0000000022a5b430 strange for kmalloc(1024, GFP_KERNEL)ed kernel address?
>> > >
>> > > The address is hashed (see the %p threads for 4.15).
>> >
>> >
>> > +Tobin, is there a way to disable hashing entirely? The only
>> > designation of syzbot is providing crash reports to kernel developers
>> > with as much info as possible. It's fine for it to leak whatever.
>>
>> We have new specifier %px to print addresses in hex if leaking info is
>> not a worry.
>
> Could we have a way to know that the printed address is hashed and not just
> a pointer getting completely scrogged?  Perhaps prefix it with ... a hash!
> So this line would look like:
>
> [   26.089789] usercopy: kernel memory overwrite attempt detected to #0000000022a5b430 (kmalloc-1024) (1024 bytes)
>
> Or does that miss the point of hashing the address, so the attacker
> thinks its a real address?

If we do something with this, I would suggest that we just disable
hashing. Any of the concerns that lead to hashed pointers are not
applicable in this context, moreover they are harmful, cause confusion
and make it harder to debug these bugs. That perfectly can be an
opt-in CONFIG_DEBUG_INSECURE_BLA_BLA_BLA.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
