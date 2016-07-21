Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8CC6482963
	for <linux-mm@kvack.org>; Thu, 21 Jul 2016 07:33:28 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id l89so50290391lfi.3
        for <linux-mm@kvack.org>; Thu, 21 Jul 2016 04:33:28 -0700 (PDT)
Received: from mail-lf0-x230.google.com (mail-lf0-x230.google.com. [2a00:1450:4010:c07::230])
        by mx.google.com with ESMTPS id 79si3887021ljj.1.2016.07.21.04.33.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Jul 2016 04:33:27 -0700 (PDT)
Received: by mail-lf0-x230.google.com with SMTP id f93so59227706lfi.2
        for <linux-mm@kvack.org>; Thu, 21 Jul 2016 04:33:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160720223427.GA22911@node.shutemov.name>
References: <20160720114417.GA19146@node.shutemov.name> <20160720115323.GI11249@dhcp22.suse.cz>
 <9c2c9249-af41-56c2-7169-1465e0c07edc@suse.cz> <20160720151905.GB19146@node.shutemov.name>
 <e9ffdc50-b085-c96c-5da7-7358967f421c@suse.cz> <CAG_fn=UP0169b+cTxVBhqPUfOurQNxAKne0pYSPy3a1uFvTp-g@mail.gmail.com>
 <20160720223427.GA22911@node.shutemov.name>
From: Alexander Potapenko <glider@google.com>
Date: Thu, 21 Jul 2016 13:33:26 +0200
Message-ID: <CAG_fn=UppxF7NY7HAtq6DvK-wqizCKmEw=vQ0+rjYErGbHjsvg@mail.gmail.com>
Subject: Re: [mmotm-2016-07-18-16-40] page allocation failure: order:2, mode:0x2000000(GFP_NOWAIT)
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.cz>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, riel@redhat.com, David Rientjes <rientjes@google.com>, mgorman@techsingularity.net

On Thu, Jul 21, 2016 at 12:34 AM, Kirill A. Shutemov
<kirill@shutemov.name> wrote:
> On Wed, Jul 20, 2016 at 08:12:13PM +0200, Alexander Potapenko wrote:
>> >>>>> It's easy to reproduce in my setup: virtual machine with some amou=
nt of
>> >>>>> swap space and try allocate about the size of RAM in userspace (I =
used
>> >>>>> usemem[1] for that).
>>
>> Am I understanding right that you're seeing allocation failures from
>> the stack depot? How often do they happen? Are they reported under
>> heavy load, or just when you boot the kernel?
>
> As I described, it happens under memory pressure.
>
>> Allocating with __GFP_NOWARN will help here, but I think we'd better
>> figure out what's gone wrong.
>> I've sent https://lkml.org/lkml/2016/7/14/566, which should reduce the
>> stack depot's memory consumption, for review - can you see if the bug
>> is still reproducible with that?
>
> I was not able to trigger the failure with the same test case.
> Tested with v2 of the patch.
When the allocation happens in IRQ handler, we try to be clever and
cut everything below EOI, because the lower frames don't really
matter, but prevent stack deduplication.
But since the stack pointers aren't preserved in the stack trace, the
only way to do so is to check whether each frame is an IRQ entry
point.
That patch adds several entry points to the .irqentry.text section,
thus allowing the stack depot to filter them out as well.
If that works for you, we'd better not add the __GFP_NOWARN flag -
that way we'll be able to detect similar problems in the future.

> (Links to http://lkml.kernel.org/ or other archive with message-id in url
> is prefered. lkml.org is garbage)
Does gmane.org work (e.g. http://article.gmane.org/gmane.linux.kernel/22669=
71)
It is surprisingly tricky to figure out a message id from the subject.
> --
>  Kirill A. Shutemov



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Matthew Scott Sucherman, Paul Terence Manicle
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
