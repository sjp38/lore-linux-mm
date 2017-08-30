Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id D0CD66B0292
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 17:53:40 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id u68so8468464ioi.10
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 14:53:40 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d13sor3356078ioe.208.2017.08.30.14.53.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 30 Aug 2017 14:53:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170830165250.GD13559@redhat.com>
References: <20170829235447.10050-1-jglisse@redhat.com> <20170829235447.10050-3-jglisse@redhat.com>
 <20170830165250.GD13559@redhat.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 30 Aug 2017 14:53:38 -0700
Message-ID: <CA+55aFxiyrqasfojwS5rG4aKJfaZpw1H=QAPH+9PRq=HT0W8AQ@mail.gmail.com>
Subject: Re: [PATCH 02/13] mm/rmap: update to new mmu_notifier semantic
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Bernhard Held <berny156@gmx.de>, Adam Borowski <kilobyte@angband.pl>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Wanpeng Li <kernellwp@gmail.com>, Paolo Bonzini <pbonzini@redhat.com>, Takashi Iwai <tiwai@suse.de>, Nadav Amit <nadav.amit@gmail.com>, Mike Galbraith <efault@gmx.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, axie <axie@amd.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed, Aug 30, 2017 at 9:52 AM, Andrea Arcangeli <aarcange@redhat.com> wro=
te:
>
> I pointed out in earlier email ->invalidate_range can only be
> implemented (as mutually exclusive alternative to
> ->invalidate_range_start/end) by secondary MMUs that shares the very
> same pagetables with the core linux VM of the primary MMU, and those
> invalidate_range are already called by
> __mmu_notifier_invalidate_range_end.

I have to admit that I didn't notice that fact - that we are already
in the situation that
invalidate_range is called by by the rand_end() nofifier.

I agree that that should simplify all the code, and means that we
don't have to worry about the few cases that already implemented only
the "invalidate_page()" and "invalidate_range()" cases.

So I think that simplifies J=C3=A9r=C3=B4me's patch further - once you have=
 put
the range_start/end() cases around the inner loop, you can just drop
the invalidate_page() things entirely.

> So this conversion from invalidate_page to invalidate_range looks
> superflous and the final mmu_notifier_invalidate_range_end should be
> enough.

Yes. I missed the fact that we already called range() from range_end().

That said, the double call shouldn't hurt correctness, and it's
"closer" to old behavior for those people who only did the range/page
ones, so I wonder if we can keep J=C3=A9r=C3=B4me's patch in its current st=
ate
for 4.13.

Because I still want to release 4.13 this weekend, despite this
upheaval. Otherwise I'll have timing problems during the next merge
window.

Andrea, do you otherwise agree with the whole series as is?

            Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
