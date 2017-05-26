Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4B6B36B0279
	for <linux-mm@kvack.org>; Fri, 26 May 2017 16:10:07 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e7so25489522pfk.9
        for <linux-mm@kvack.org>; Fri, 26 May 2017 13:10:07 -0700 (PDT)
Received: from mail.zytor.com (terminus.zytor.com. [65.50.211.136])
        by mx.google.com with ESMTPS id s62si1879887pfj.14.2017.05.26.13.10.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 May 2017 13:10:06 -0700 (PDT)
Date: Fri, 26 May 2017 12:40:17 -0700
In-Reply-To: <20170526130057.t7zsynihkdtsepkf@node.shutemov.name>
References: <20170525203334.867-1-kirill.shutemov@linux.intel.com> <CA+55aFznnXPDxYy5CN6qVU7QJ3Y9hbSf-s2-w0QkaNJuTspGcQ@mail.gmail.com> <20170526130057.t7zsynihkdtsepkf@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Subject: Re: [PATCHv1, RFC 0/8] Boot-time switching between 4- and 5-level paging
From: hpa@zytor.com
Message-ID: <91E86DF1-9814-444B-AD43-706246D768EC@zytor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, the arch/x86 maintainers <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On May 26, 2017 6:00:57 AM PDT, "Kirill A=2E Shutemov" <kirill@shutemov=2En=
ame> wrote:
>On Thu, May 25, 2017 at 04:24:24PM -0700, Linus Torvalds wrote:
>> On Thu, May 25, 2017 at 1:33 PM, Kirill A=2E Shutemov
>> <kirill=2Eshutemov@linux=2Eintel=2Ecom> wrote:
>> > Here' my first attempt to bring boot-time between 4- and 5-level
>paging=2E
>> > It looks not too terrible to me=2E I've expected it to be worse=2E
>>=20
>> If I read this right, you just made it a global on/off thing=2E
>>=20
>> May I suggest possibly a different model entirely? Can you make it a
>> per-mm flag instead?
>>=20
>> And then we
>>=20
>>  (a) make all kthreads use the 4-level page tables
>>=20
>>  (b) which means that all the init code uses the 4-level page tables
>>=20
>>  (c) which means that all those checks for "start_secondary" etc can
>> just go away, because those all run with 4-level page tables=2E
>>=20
>> Or is it just much too expensive to switch between 4-level and
>5-level
>> paging at run-time?
>
>Hm=2E=2E
>
>I don't see how kernel threads can use 4-level paging=2E It doesn't work
>from virtual memory layout POV=2E Kernel claims half of full virtual
>address
>space for itself -- 256 PGD entries, not one as we would effectively
>have
>in case of switching to 4-level paging=2E For instance, addresses, where
>vmalloc and vmemmap are mapped, are not canonical with 4-level paging=2E
>
>And you cannot see whole direct mapping of physical memory=2E Back to
>highmem? (Please, no, please)=2E
>
>We could possible reduce number of PGD required by kernel=2E Currently,
>layout for 5-level paging allows up-to 55-bit physical memory=2E It's
>redundant as SDM claim that we never will get more than 52=2E So we could
>reduce size of kernel part of layout by few bits, but not definitely to
>1=2E
>
>I don't see how it can possibly work=2E
>
>Besides difficulties of getting switching between paging modes correct,
>that Andy mentioned, it will also hurt performance=2E You cannot switch
>between paging modes directly=2E It would require disabling paging
>completely=2E It means we loose benefit from global page table entries on
>such switching=2E More page-walks=2E
>
>Even ignoring all of above, I don't see much benefit of having per-mm
>switching=2E It adds complexity without much benefit -- saving few lines
>of
>logic during early boot doesn't look as huge win to me=2E

It also makes no sense =E2=80=93 the kernel threads only need one common p=
age table anyway=2E
--=20
Sent from my Android device with K-9 Mail=2E Please excuse my brevity=2E

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
