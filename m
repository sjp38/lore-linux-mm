Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id D29716B0038
	for <linux-mm@kvack.org>; Fri, 30 Dec 2016 02:11:18 -0500 (EST)
Received: by mail-lf0-f70.google.com with SMTP id y21so144226870lfa.0
        for <linux-mm@kvack.org>; Thu, 29 Dec 2016 23:11:18 -0800 (PST)
Received: from mail-lf0-x234.google.com (mail-lf0-x234.google.com. [2a00:1450:4010:c07::234])
        by mx.google.com with ESMTPS id p11si32477852lfd.170.2016.12.29.23.11.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Dec 2016 23:11:17 -0800 (PST)
Received: by mail-lf0-x234.google.com with SMTP id b14so232707218lfg.2
        for <linux-mm@kvack.org>; Thu, 29 Dec 2016 23:11:16 -0800 (PST)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH] mm: Drop "PFNs busy" printk in an expected path.
In-Reply-To: <8737h65nr5.fsf@eliezer.anholt.net>
References: <20161229023131.506-1-eric@anholt.net> <20161229091256.GF29208@dhcp22.suse.cz> <87wpeitzld.fsf@eliezer.anholt.net> <xa1td1ga74v7.fsf@mina86.com> <8737h65nr5.fsf@eliezer.anholt.net>
Date: Fri, 30 Dec 2016 08:11:12 +0100
Message-ID: <xa1ta8bd7uy7.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Anholt <eric@anholt.net>, Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-stable <stable@vger.kernel.org>, "Robin H. Johnson" <robbat2@orbis-terrarum.net>, Vlastimil Babka <vbabka@suse.cz>, Marek Szyprowski <m.szyprowski@samsung.com>

On Thu, Dec 29 2016, Eric Anholt wrote:
> Michal Nazarewicz <mina86@mina86.com> writes:
>
>> On Thu, Dec 29 2016, Eric Anholt wrote:
>>> Michal Hocko <mhocko@kernel.org> writes:
>>>
>>>> This has been already brought up
>>>> http://lkml.kernel.org/r/20161130092239.GD18437@dhcp22.suse.cz and the=
re
>>>> was a proposed patch for that which ratelimited the output
>>>> http://lkml.kernel.org/r/20161130132848.GG18432@dhcp22.suse.cz resp.
>>>> http://lkml.kernel.org/r/robbat2-20161130T195244-998539995Z@orbis-terr=
arum.net
>>>>
>>>> then the email thread just died out because the issue turned out to be=
 a
>>>> configuration issue. Michal indicated that the message might be useful
>>>> so dropping it completely seems like a bad idea. I do agree that
>>>> something has to be done about that though. Can we reconsider the
>>>> ratelimit thing?
>>>
>>> I agree that the rate of the message has gone up during 4.9 -- it used
>>> to be a few per second.
>>
>> Sounds like a regression which should be fixed.
>>
>> This is why I don=E2=80=99t think removing the message is a good idea.  =
If you
>> suddenly see a lot of those messages, something changed for the worse.
>> If you remove this message, you will never know.
>>
>>> However, if this is an expected path during normal operation,
>>
>> This depends on your definition of =E2=80=98expected=E2=80=99 and =E2=80=
=98normal=E2=80=99.
>>
>> In general, I would argue that the fact those ever happen is a bug
>> somewhere in the kernel =E2=80=93 if memory is allocated as movable, it =
should
>> be movable damn it!
>
> I was taking "expected" from dae803e165a11bc88ca8dbc07a11077caf97bbcb --
> if this is a actually a bug, how do we go about debugging it?

That=E2=80=99s why I=E2=80=99ve pointed out that this depends on the defini=
tion.  In my
opinion it=E2=80=99s a design bug which is now nearly impossible to fix in
efficient way.

The most likely issues is that some subsystem is allocating movable
memory but then either does not provide a way to actually move it
(that=E2=80=99s an obvious bug in the code IMO) or pins the memory while so=
me
transaction is performed and at the same time CMA tries to move it.

The latter case is really unavoidable at this point which is why this
message is =E2=80=98expected=E2=80=99.

But if suddenly, the rate of the messages increases dramatically, you
have yourself a performance regression.

> I've had Raspbian carrying a patch downstream to remove the error
> message for 2 years now, and I either need to get this fixed or get this
> patch merged to Fedora and Debian as well, now that they're shipping
> some support for Raspberry Pi.

--=20
Best regards
=E3=83=9F=E3=83=8F=E3=82=A6 =E2=80=9C=F0=9D=93=B6=F0=9D=93=B2=F0=9D=93=B7=
=F0=9D=93=AA86=E2=80=9D =E3=83=8A=E3=82=B6=E3=83=AC=E3=83=B4=E3=82=A4=E3=83=
=84
=C2=ABIf at first you don=E2=80=99t succeed, give up skydiving=C2=BB

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
