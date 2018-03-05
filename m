Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id D1D356B0003
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 11:05:13 -0500 (EST)
Received: by mail-lf0-f72.google.com with SMTP id h191so5236080lfg.18
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 08:05:13 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y7sor2948196lfd.106.2018.03.05.08.05.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Mar 2018 08:05:11 -0800 (PST)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: [RFC PATCH] Randomization of address chosen by mmap.
From: Ilya Smith <blackzert@gmail.com>
In-Reply-To: <CA+DvKQKHqVzk9u2GwSC+F2vF938DY4Heb+JexwOSZhfcFkuqcw@mail.gmail.com>
Date: Mon, 5 Mar 2018 19:05:08 +0300
Content-Transfer-Encoding: quoted-printable
Message-Id: <896E6047-A49F-4E2E-A831-34CC2AD48550@gmail.com>
References: <20180227131338.3699-1-blackzert@gmail.com>
 <CAGXu5jKF7ysJqj57ZktrcVL4G2NWOFHCud8dtXFHLs=tvVLXnQ@mail.gmail.com>
 <55C92196-5398-4C19-B7A7-6C122CD78F32@gmail.com>
 <20180228183349.GA16336@bombadil.infradead.org>
 <CA+DvKQKoo1U7T_iOOLhfEf9c+K1pzD068au+kGtx0RokFFNKHw@mail.gmail.com>
 <2CF957C6-53F2-4B00-920F-245BEF3CA1F6@gmail.com>
 <CA+DvKQ+mrnm4WX+3cBPuoSLFHmx2Zwz8=FsEx51fH-7yQMAd9w@mail.gmail.com>
 <20180304034704.GB20725@bombadil.infradead.org>
 <20180304205614.GC23816@bombadil.infradead.org>
 <7FA6631B-951F-42F4-A7BF-8E5BB734D709@gmail.com>
 <CA+DvKQKHqVzk9u2GwSC+F2vF938DY4Heb+JexwOSZhfcFkuqcw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Micay <danielmicay@gmail.com>
Cc: Matthew Wilcox <willy@infradead.org>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Jerome Glisse <jglisse@redhat.com>, Hugh Dickins <hughd@google.com>, Helge Deller <deller@gmx.de>, Andrea Arcangeli <aarcange@redhat.com>, Oleg Nesterov <oleg@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

> On 5 Mar 2018, at 17:23, Daniel Micay <danielmicay@gmail.com> wrote:
> I didn't suggest this as the way of implementing fine-grained
> randomization but rather a small starting point for hardening address
> space layout further. I don't think it should be tied to a mmap flag
> but rather something like a personality flag or a global sysctl. It
> doesn't need to be random at all to be valuable, and it's just a first
> step. It doesn't mean there can't be switches between random pivots
> like OpenBSD mmap, etc. I'm not so sure that randomly switching around
> is going to result in isolating things very well though.
>=20

Here I like the idea of Kees Cook:
> I think this will need a larger knob -- doing this by default is
> likely to break stuff, I'd imagine? Bikeshedding: I'm not sure if this
> should be setting "3" for /proc/sys/kernel/randomize_va_space, or a
> separate one like /proc/sys/mm/randomize_mmap_allocation.
I mean it should be a way to turn randomization off since some =
applications are=20
really need huge memory.
If you have suggestion here, would be really helpful to discuss.
I think one switch might be done globally for system administrate like=20=

/proc/sys/mm/randomize_mmap_allocation and another one would be good to =
have=20
some ioctl to switch it of in case if application knows what to do.

I would like to implement it in v2 of the patch.

>> I can=E2=80=99t understand what direction this conversation is going =
to. I was talking
>> about weak implementation in Linux kernel but got many comments about =
ASLR
>> should be implemented in user mode what is really weird to me.
>=20
> That's not what I said. I was saying that splitting things into
> regions based on the type of allocation works really well and allows
> for high entropy bases, but that the kernel can't really do that right
> now. It could split up code that starts as PROT_EXEC into a region but
> that's generally not how libraries are mapped in so it won't know
> until mprotect which is obviously too late. Unless it had some kind of
> type key passed from userspace, it can't really do that.

Yes, thats really true. I wrote about earlier. This is the issue - =
kernel can=E2=80=99t=20
provide such interface thats why I try to get maximum from current mmap =
design.=20
May be later we could split mmap on different actions by different types =
of=20
memory it handles. But it will be a very long road I think.=20

>> I think it is possible  to add GUARD pages into my implementations, =
but initially
>> problem was about entropy of address choosing. I would like to =
resolve it step by
>> step.
>=20
> Starting with fairly aggressive fragmentation of the address space is
> going to be a really hard sell. The costs of a very spread out address
> space in terms of TLB misses, etc. are unclear. Starting with enforced
> gaps (1 page) and randomization for those wouldn't rule out having
> finer-grained randomization, like randomly switching between different
> regions. This needs to be cheap enough that people want to enable it,
> and the goals need to be clearly spelled out. The goal needs to be
> clearer than "more randomization =3D=3D good" and then accepting a =
high
> performance cost for that.
>=20

I want to clarify. As I know TLB caches doesn=E2=80=99t care about =
distance between=20
pages, since it works with pages. So in theory TLB miss is not an issue =
here. I=20
agree, I need to show the performance costs here. I will. Just give some =
time=20
please.

The enforced gaps, in my case:
+	addr =3D get_random_long() % ((high - low) >> PAGE_SHIFT);
+	addr =3D low + (addr << PAGE_SHIFT);
but what you saying, entropy here should be decreased.

How about something like this:
+	addr =3D get_random_long() % min(((high - low) >> PAGE_SHIFT),=20=

MAX_SECURE_GAP );
+	addr =3D high - (addr << PAGE_SHIFT);
where MAX_SECURE_GAP is configurable. Probably with sysctl.

How do you like it?

> I'm not dictating how things should be done, I don't have any say
> about that. I'm just trying to discuss it.

Sorry, thanks for your involvement. I=E2=80=99m really appreciate it.=20

Thanks,
Ilya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
