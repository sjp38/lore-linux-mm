Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id BB4E16B0005
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 05:05:06 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id l68so11266998wml.0
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 02:05:06 -0800 (PST)
Received: from mail-wm0-x22a.google.com (mail-wm0-x22a.google.com. [2a00:1450:400c:c09::22a])
        by mx.google.com with ESMTPS id u62si1798935wme.91.2016.03.11.02.05.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Mar 2016 02:05:05 -0800 (PST)
Received: by mail-wm0-x22a.google.com with SMTP id l68so10710690wml.1
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 02:05:05 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160310121426.b667420195a19ee17503ae2d@linux-foundation.org>
References: <cover.1457519440.git.glider@google.com>
	<bdd59cc00ee49b7849ad60a11c6a4704c3e4856b.1457519440.git.glider@google.com>
	<20160309122148.1250854b862349399591dabf@linux-foundation.org>
	<CAG_fn=UkgkHw5Ed72hPkYYzhXcH5gy5ubTeS8SvggvzZDxFdJw@mail.gmail.com>
	<20160310121426.b667420195a19ee17503ae2d@linux-foundation.org>
Date: Fri, 11 Mar 2016 11:05:05 +0100
Message-ID: <CAG_fn=Uh6gn=g7xeb1yaeDrv9NYPcWGwaHnfcuL9YRzDiP5HDQ@mail.gmail.com>
Subject: Re: [PATCH v5 7/7] mm: kasan: Initial memory quarantine implementation
From: Alexander Potapenko <glider@google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Konovalov <adech.fo@gmail.com>, Christoph Lameter <cl@linux.com>, Dmitriy Vyukov <dvyukov@google.com>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, JoonSoo Kim <js1304@gmail.com>, Kostya Serebryany <kcc@google.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Thu, Mar 10, 2016 at 9:14 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Thu, 10 Mar 2016 14:50:56 +0100 Alexander Potapenko <glider@google.com=
> wrote:
>
>> On Wed, Mar 9, 2016 at 9:21 PM, Andrew Morton <akpm@linux-foundation.org=
> wrote:
>> > On Wed,  9 Mar 2016 12:05:48 +0100 Alexander Potapenko <glider@google.=
com> wrote:
>> >
>> >> Quarantine isolates freed objects in a separate queue. The objects ar=
e
>> >> returned to the allocator later, which helps to detect use-after-free
>> >> errors.
>> >
>> > I'd like to see some more details on precisely *how* the parking of
>> > objects in the qlists helps "detect use-after-free"?
>> When the object is freed, its state changes from KASAN_STATE_ALLOC to
>> KASAN_STATE_QUARANTINE. The object is poisoned and put into quarantine
>> instead of being returned to the allocator, therefore every subsequent
>> access to that object triggers a KASAN error, and the error handler is
>> able to say where the object has been allocated and deallocated.
>> When it's time for the object to leave quarantine, its state becomes
>> KASAN_STATE_FREE and it's returned to the allocator. From now on the
>> allocator may reuse it for another allocation.
>> Before that happens, it's still possible to detect a use-after free on
>> that object (it retains the allocation/deallocation stacks).
>> When the allocator reuses this object, the shadow is unpoisoned and
>> old allocation/deallocation stacks are wiped. Therefore a use of this
>> object, even an incorrect one, won't trigger ASan warning.
>> Without the quarantine, it's not guaranteed that the objects aren't
>> reused immediately, that's why the probability of catching a
>> use-after-free is lower than with quarantine in place.
>
> I see, thanks.  I'll slurp that into the changelog for posterity.

I've also added a paragraph about that to the patch description.

>> >> +}
>> >
>> > We could avoid th4ese ifdefs in the usual way: an empty version of
>> > quarantine_remove_cache() if CONFIG_SLAB=3Dn.
>> Yes, agreed.
>> I am sorry, I don't fully understand the review process now, when
>> you've pulled the patches into mm-tree.
>> Shall I send the new patch series version, as before, or is anything
>> else needs to be done?
>> Do I need to rebase against mm- or linux-next? Thanks in advance.
>
> I like to queue a delta patch so I and others can see what changed and
> also to keep track of who fixed what and why.  It's a bit harsh on the
> reviewers to send them a slightly altered version of a 500 line patch
> which they've already read through.
I'm listing the differences between patch versions after the patch
description (between the triple dashes), hope that helps the
reviewers.

> Before sending the patch up to Linus I'll clump everything into a
> single patch and a lot of that history is somewhat lost.
>
> Sending a replacement patch is often more convenient for the originator
> so that's fine - I'll turn the replacement into a delta locally and
> will review then queue that delta.  Also a new revision of a patch has
> an altered changelog so I'll manually move that into the older original
> patch's changelog immediately.
>
> IOW: either a new patch or a delta is fine.
Ok, got it.
> Your patch is in linux-next now so a diff against -next will work OK.
>
> Probably the easiest thing for you to do is to just alter the patch you
> have in-place and send out the new one.  A "[v2" in the Subject: helps
> people keep track of things.
Ok, will do.



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
