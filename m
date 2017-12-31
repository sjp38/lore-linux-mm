Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id D12446B0038
	for <linux-mm@kvack.org>; Sun, 31 Dec 2017 03:11:27 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id s12so27464281plp.11
        for <linux-mm@kvack.org>; Sun, 31 Dec 2017 00:11:27 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id r18sor1783960pgv.163.2017.12.31.00.11.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 31 Dec 2017 00:11:26 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <d6c8c26ba44847299c4db9136d60957d@AcuMS.aculab.com>
References: <001a113e9ca8a3affd05609d7ccf@google.com> <6a50d160-56d0-29f9-cfed-6c9202140b43@I-love.SAKURA.ne.jp>
 <CAGXu5jKLBuQ8Ne6BjjPH+1SVw-Fj4ko5H04GHn-dxXYwoMEZtw@mail.gmail.com>
 <CACT4Y+a3h0hmGpfVaePX53QUQwBhN9BUyERp-5HySn74ee_Vxw@mail.gmail.com>
 <20171219083746.GR19604@eros> <20171219132246.GD13680@bombadil.infradead.org>
 <CA+55aFwvMMg0Kt8z+tkgPREbX--Of0R5nr_wS4B64kFxiVVKmw@mail.gmail.com>
 <20171219214849.GU21978@ZenIV.linux.org.uk> <d6c8c26ba44847299c4db9136d60957d@AcuMS.aculab.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Sun, 31 Dec 2017 09:11:05 +0100
Message-ID: <CACT4Y+YBn2kJe3UE5T+zVgKCp-0hCgugTNE-EMw8B+Cy7ZQqKQ@mail.gmail.com>
Subject: Re: BUG: bad usercopy in memdup_user
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Laight <David.Laight@aculab.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, "Tobin C. Harding" <me@tobin.cc>, Kees Cook <keescook@chromium.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Linux-MM <linux-mm@kvack.org>, syzbot <bot+719398b443fd30155f92f2a888e749026c62b427@syzkaller.appspotmail.com>, David Windsor <dave@nullcore.net>, "keun-o.park@darkmatter.ae" <keun-o.park@darkmatter.ae>, Laura Abbott <labbott@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Mark Rutland <mark.rutland@arm.com>, Ingo Molnar <mingo@kernel.org>, "syzkaller-bugs@googlegroups.com" <syzkaller-bugs@googlegroups.com>, Will Deacon <will.deacon@arm.com>

On Wed, Dec 20, 2017 at 10:44 AM, David Laight <David.Laight@aculab.com> wrote:
> From: Al Viro
>> Sent: 19 December 2017 21:49
>> > I suspect that an "offset and size within the kernel object" value
>> > might make sense.  But what does the _pointer_ tell you?
>>
>> Well, for example seeing a 0xfffffffffffffff4 where a pointer to object
>> must have been is a pretty strong hint to start looking for a way for
>> that ERR_PTR(-ENOMEM) having ended up there...  Something like
>> 0x6e69622f7273752f is almost certainly a misplaced "/usr/bin", i.e. a
>> pathname overwriting whatever it ends up in, etc.  And yes, I have run
>> into both of those in real life.
>>
>> Debugging the situation when crap value has ended up in place of a
>> pointer is certainly a case where you do want to see what exactly has
>> ended up in there...
>
> I've certainly seen a lot of ascii in pointers (usually because the
> previous item has overrun).
> Although I suspect they'd appear in the fault frame - which hopefully
> carries real addresses.
>
> A compromise would be to hash the 'page' part of the address.
> On 64bit systems this is probably about 32 bits.
> It would still show whether pointers are user, kernel, vmalloc (etc)
> but without giving away the actual value.
> The page offset (12 bits) would show the alignment (etc).
>
> Including a per-boot random number would make it harder to generate
> 'rainbow tables' to reverse the hash.


Bad things on kmalloc-1024 are most likely caused by an invalid free
in pcrypt, it freed a pointer into a middle of a 1024 byte heap object
which was undetected by KASAN (now there is a patch for this in mm
tree) and later caused all kinds of bad things:
https://groups.google.com/forum/#!topic/syzkaller-bugs/NKn_ivoPOpk
https://patchwork.kernel.org/patch/10126761/

#syz dup: KASAN: use-after-free Read in __list_del_entry_valid (2)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
