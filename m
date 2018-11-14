Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id E31D76B0006
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 06:46:27 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id b4-v6so9018299plb.3
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 03:46:27 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id g20-v6si23658980plq.192.2018.11.14.03.46.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Nov 2018 03:46:26 -0800 (PST)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH] mm/usercopy: Use memory range to be accessed for
 wraparound check
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <5dcd06a0f84a4824bb9bab2b437e190d@AcuMS.aculab.com>
Date: Wed, 14 Nov 2018 04:46:18 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <7C54170F-DE66-47E0-9C0D-7D1A97DCD339@oracle.com>
References: <1542156686-12253-1-git-send-email-isaacm@codeaurora.org>
 <FFE931C2-DE41-4AD8-866B-FD37C1493590@oracle.com>
 <5dcd06a0f84a4824bb9bab2b437e190d@AcuMS.aculab.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Laight <David.Laight@ACULAB.COM>
Cc: "Isaac J. Manjarres" <isaacm@codeaurora.org>, Kees Cook <keescook@chromium.org>, "crecklin@redhat.com" <crecklin@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "psodagud@codeaurora.org" <psodagud@codeaurora.org>, "tsoni@codeaurora.org" <tsoni@codeaurora.org>, "stable@vger.kernel.org" <stable@vger.kernel.org>



> On Nov 14, 2018, at 4:09 AM, David Laight <David.Laight@ACULAB.COM> =
wrote:
>=20
> From: William Kucharski
>> Sent: 14 November 2018 10:35
>>=20
>>> On Nov 13, 2018, at 5:51 PM, Isaac J. Manjarres =
<isaacm@codeaurora.org> wrote:
>>>=20
>>> diff --git a/mm/usercopy.c b/mm/usercopy.c
>>> index 852eb4e..0293645 100644
>>> --- a/mm/usercopy.c
>>> +++ b/mm/usercopy.c
>>> @@ -151,7 +151,7 @@ static inline void check_bogus_address(const =
unsigned long ptr, unsigned long n,
>>> 				       bool to_user)
>>> {
>>> 	/* Reject if object wraps past end of memory. */
>>> -	if (ptr + n < ptr)
>>> +	if (ptr + (n - 1) < ptr)
>>> 		usercopy_abort("wrapped address", NULL, to_user, 0, ptr =
+ n);
>>=20
>> I'm being paranoid, but is it possible this routine could ever be =
passed "n" set to zero?
>>=20
>> If so, it will erroneously abort indicating a wrapped address as (n - =
1) wraps to ULONG_MAX.
>>=20
>> Easily fixed via:
>>=20
>> 	if ((n !=3D 0) && (ptr + (n - 1) < ptr))
>=20
> Ugg... you don't want a double test.
>=20
> I'd guess that a length of zero is likely, but a usercopy that =
includes
> the highest address is going to be invalid because it is a kernel =
address
> (on most archs, and probably illegal on others).
> What you really want to do is add 'ptr + len' and check the carry =
flag.

The extra test is only a few extra instructions, but I understand the =
concern. (Though I don't
know how you'd access the carry flag from C in a machine-independent =
way. Also, for the
calculation to be correct you still need to check 'ptr + (len - 1)' for =
the wrap.)

You could also theoretically call gcc's __builtin_uadd_overflow() if you =
want to get carried away.

As I mentioned, I was just being paranoid, but the passed zero length =
issue stood out to me.

    William Kucharski=
