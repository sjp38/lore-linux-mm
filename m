Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 68BEC800D8
	for <linux-mm@kvack.org>; Sun, 21 Jan 2018 21:35:55 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id v25so7673045pfg.14
        for <linux-mm@kvack.org>; Sun, 21 Jan 2018 18:35:55 -0800 (PST)
Received: from mail.zytor.com (terminus.zytor.com. [65.50.211.136])
        by mx.google.com with ESMTPS id a13si9891292pgt.663.2018.01.21.18.35.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Jan 2018 18:35:54 -0800 (PST)
Date: Sun, 21 Jan 2018 18:20:11 -0800
In-Reply-To: <CA+55aFz4cUhqhmWg-F8NXGjowVGXkMA126H-mQ4n1A0ywtQ_tg@mail.gmail.com>
References: <1516120619-1159-1-git-send-email-joro@8bytes.org> <5D89F55C-902A-4464-A64E-7157FF55FAD0@gmail.com> <886C924D-668F-4007-98CA-555DB6279E4F@gmail.com> <9CF1DD34-7C66-4F11-856D-B5E896988E16@gmail.com> <CA+55aFz4cUhqhmWg-F8NXGjowVGXkMA126H-mQ4n1A0ywtQ_tg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Subject: Re: [RFC PATCH 00/16] PTI support for x86-32
From: hpa@zytor.com
Message-ID: <143DE376-A8A4-4A91-B4FF-E258D578242D@zytor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Nadav Amit <nadav.amit@gmail.com>
Cc: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, the arch/x86 maintainers <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Joerg Roedel <jroedel@suse.de>

On January 21, 2018 6:11:07 PM PST, Linus Torvalds <torvalds@linux-foundati=
on=2Eorg> wrote:
>On Sun, Jan 21, 2018 at 3:46 PM, Nadav Amit <nadav=2Eamit@gmail=2Ecom>
>wrote:
>> I wanted to see whether segments protection can be a replacement for
>PTI
>> (yes, excluding SMEP emulation), or whether speculative execution
>=E2=80=9Cignores=E2=80=9D
>> limit checks, similarly to the way paging protection is skipped=2E
>>
>> It does seem that segmentation provides sufficient protection from
>Meltdown=2E
>> The =E2=80=9Creliability=E2=80=9D test of Gratz PoC fails if the segmen=
t limit is set
>to
>> prevent access to the kernel memory=2E [ It passes if the limit is not
>set,
>> even if the DS is reloaded=2E ] My test is enclosed below=2E
>
>Interesting=2E It might not be entirely reliable for all
>microarchitectures, though=2E
>
>> So my question: wouldn=E2=80=99t it be much more efficient to use
>segmentation
>> protection for x86-32, and allow users to choose whether they want
>SMEP-like
>> protection if needed (and then enable PTI)?
>
>That's what we did long long ago, with user space segments actually
>using the limit (in fact, if you go back far enough, the kernel even
>used the base)=2E
>
>You'd have to make sure that the LDT loading etc do not allow CPL3
>segments with base+limit past TASK_SIZE, so that people can't generate
>their own=2E  And the TLS segments also need to be limited (and
>remember, the limit has to be TASK_SIZE-base, not just TASK_SIZE)=2E
>
>And we should check with Intel that segment limit checking really is
>guaranteed to be done before any access=2E
>
>Too bad x86-64 got rid of the segments ;)
>
>               Linus

No idea about Intel, but at least on Transmeta CPUs the limit check was as=
ynchronous with the access=2E
--=20
Sent from my Android device with K-9 Mail=2E Please excuse my brevity=2E

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
