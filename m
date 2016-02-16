Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 31D8F6B0005
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 13:38:00 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id a4so113680656wme.1
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 10:38:00 -0800 (PST)
Received: from mail-wm0-x22c.google.com (mail-wm0-x22c.google.com. [2a00:1450:400c:c09::22c])
        by mx.google.com with ESMTPS id z2si35141418wmz.40.2016.02.16.10.37.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Feb 2016 10:37:59 -0800 (PST)
Received: by mail-wm0-x22c.google.com with SMTP id g62so122655277wme.1
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 10:37:59 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160201025530.GD32125@js1304-P5Q-DELUXE>
References: <cover.1453918525.git.glider@google.com>
	<a6491b8dfc46299797e67436cc1541370e9439c9.1453918525.git.glider@google.com>
	<20160128074051.GA15426@js1304-P5Q-DELUXE>
	<CAG_fn=Uxk-Y2gVfrdLxPRFf2SQ+1VnoWNUorcDw4E18D0+NBWQ@mail.gmail.com>
	<CAG_fn=VetOrSwqseiRwCFVr-nTTemczMixbbafgEJdqDRB4p7Q@mail.gmail.com>
	<20160201025530.GD32125@js1304-P5Q-DELUXE>
Date: Tue, 16 Feb 2016 19:37:58 +0100
Message-ID: <CAG_fn=UwMgXJkgKhSa6Qsr_2jqQi8exZj7b8eoe+WK-_7aD5cA@mail.gmail.com>
Subject: Re: [PATCH v1 5/8] mm, kasan: Stackdepot implementation. Enable
 stackdepot for SLAB
From: Alexander Potapenko <glider@google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: kasan-dev@googlegroups.com, Christoph Lameter <cl@linux.com>, linux-kernel@vger.kernel.org, Dmitriy Vyukov <dvyukov@google.com>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, linux-mm@kvack.org, Andrey Konovalov <adech.fo@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>

On Mon, Feb 1, 2016 at 3:55 AM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> On Thu, Jan 28, 2016 at 02:27:44PM +0100, Alexander Potapenko wrote:
>> On Thu, Jan 28, 2016 at 1:51 PM, Alexander Potapenko <glider@google.com>=
 wrote:
>> >
>> > On Jan 28, 2016 8:40 AM, "Joonsoo Kim" <iamjoonsoo.kim@lge.com> wrote:
>> >>
>> >> Hello,
>> >>
>> >> On Wed, Jan 27, 2016 at 07:25:10PM +0100, Alexander Potapenko wrote:
>> >> > Stack depot will allow KASAN store allocation/deallocation stack tr=
aces
>> >> > for memory chunks. The stack traces are stored in a hash table and
>> >> > referenced by handles which reside in the kasan_alloc_meta and
>> >> > kasan_free_meta structures in the allocated memory chunks.
>> >>
>> >> Looks really nice!
>> >>
>> >> Could it be more generalized to be used by other feature that need to
>> >> store stack trace such as tracepoint or page owner?
>> > Certainly yes, but see below.
>> >
>> >> If it could be, there is one more requirement.
>> >> I understand the fact that entry is never removed from depot makes th=
ings
>> >> very simpler, but, for general usecases, it's better to use reference
>> >> count
>> >> and allow to remove. Is it possible?
>> > For our use case reference counting is not really necessary, and it wo=
uld
>> > introduce unwanted contention.
>
> Okay.
>
>> > There are two possible options, each having its advantages and drawbac=
ks: we
>> > can let the clients store the refcounters directly in their stacks (mo=
re
>> > universal, but harder to use for the clients), or keep the counters in=
 the
>> > depot but add an API that does not change them (easier for the clients=
, but
>> > potentially error-prone).
>> > I'd say it's better to actually find at least one more user for the st=
ack
>> > depot in order to understand the requirements, and refactor the code a=
fter
>> > that.
>
> I re-think the page owner case and it also may not need refcount.
> For now, just moving this stuff to /lib would be helpful for other future=
 user.
I agree this code may need to be moved to /lib someday, but I wouldn't
hurry with that.
Right now it is quite KASAN-specific, and it's unclear yet whether
anyone else is going to use it.
I suggest we keep it in mm/kasan for now, and factor the common parts
into /lib when the need arises.

> BTW, is there any performance number? I guess that it could affect
> the performance.
I've compared the performance of KASAN with SLAB allocator on a small
synthetic benchmark in two modes: with stack depot enabled and with
kasan_save_stack() unconditionally returning 0.
In the former case 8% more time was spent in the kernel than in the latter =
case.

If I am not mistaking, for SLUB allocator the bookkeeping (enabled
with the slub_debug=3DUZ boot options) take only 1.5 time, so the
difference is worth looking into (at least before we switch SLUB to
stack depot).


> Thanks.



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Matthew Scott Sucherman, Paul Terence Manicle
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg
Diese E-Mail ist vertraulich. Wenn Sie nicht der richtige Adressat sind,
leiten Sie diese bitte nicht weiter, informieren Sie den
Absender und l=C3=B6schen Sie die E-Mail und alle Anh=C3=A4nge. Vielen Dank=
.
This e-mail is confidential. If you are not the right addressee please
do not forward it, please inform the sender, and please erase this
e-mail including any attachments. Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
