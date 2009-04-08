Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 3F24E5F0001
	for <linux-mm@kvack.org>; Wed,  8 Apr 2009 06:05:27 -0400 (EDT)
Received: by wf-out-1314.google.com with SMTP id 25so31280wfa.11
        for <linux-mm@kvack.org>; Wed, 08 Apr 2009 03:05:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090408094159.GK17934@one.firstfloor.org>
References: <20090407509.382219156@firstfloor.org>
	 <20090407150959.C099D1D046E@basil.firstfloor.org>
	 <28c262360904071621j5bdd8e33u1fbd8534d177a941@mail.gmail.com>
	 <20090408065121.GI17934@one.firstfloor.org>
	 <28c262360904080039l65c381edn106484c88f1c5819@mail.gmail.com>
	 <20090408094159.GK17934@one.firstfloor.org>
Date: Wed, 8 Apr 2009 19:05:30 +0900
Message-ID: <28c262360904080305y381628e3y466038f7c6232b2f@mail.gmail.com>
Subject: Re: [PATCH] [3/16] POISON: Handle poisoned pages in page free
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 8, 2009 at 6:41 PM, Andi Kleen <andi@firstfloor.org> wrote:
> On Wed, Apr 08, 2009 at 04:39:17PM +0900, Minchan Kim wrote:
>> On Wed, Apr 8, 2009 at 3:51 PM, Andi Kleen <andi@firstfloor.org> wrote:
>> >> >
>> >> > =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
>> >> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0* Page may have been marked bad before=
 process is freeing it.
>> >> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0* Make sure it is not put back into th=
e free page lists.
>> >> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>> >> > + =C2=A0 =C2=A0 =C2=A0 if (PagePoison(page)) {
>> >> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* check more fl=
ags here... */
>> >>
>> >> How about adding WARNING with some information(ex, pfn, flags..).
>> >
>> > The memory_failure() code is already quite chatty. Don't think more
>> > noise is needed currently.
>>
>> Sure.
>>
>> > Or are you worrying about the case where a page gets corrupted
>> > by software and suddenly has Poison bits set? (e.g. 0xff everywhere).
>> > That would deserve a printk, but I'm not sure how to reliably test for
>> > that. After all a lot of flag combinations are valid.
>>
>> I misunderstood your code.
>> That's because you add the code in bad_page.
>>
>> As you commented, your intention was to prevent bad page from returning =
buddy.
>> Is right ?
>
> Yes. Well actually it should not happen anymore. Perhaps I should
> make it a BUG()
>
>> If it is right, how about adding prevention code to free_pages_check ?
>> Now, bad_page is for showing the information that why it is bad page
>> I don't like emergency exit in bad_page.
>
> There's already one in there, so i just reused that one. It was a conveni=
ent
> way to keep things out of the fast path


Sorry for my vague previous comment.
I mean bad_page function's role is just to print why it is bad now.
Whoever can use bad_page to show information.
If someone begin to add side branch in bad_page, anonther people might
add his exception case in one.

So, I think it would be better to check PagePoison in free_pages_check
not bad_page. :)

> -Andi
>
> ak@linux.intel.com -- Speaking for myself only.
>



--=20
Kinds regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
