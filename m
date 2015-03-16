Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id C3CB46B0038
	for <linux-mm@kvack.org>; Mon, 16 Mar 2015 17:25:26 -0400 (EDT)
Received: by obfv9 with SMTP id v9so45795187obf.2
        for <linux-mm@kvack.org>; Mon, 16 Mar 2015 14:25:26 -0700 (PDT)
Received: from g9t5008.houston.hp.com (g9t5008.houston.hp.com. [15.240.92.66])
        by mx.google.com with ESMTPS id i3si6275369obh.83.2015.03.16.14.25.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Mar 2015 14:25:26 -0700 (PDT)
From: "Kani, Toshimitsu" <toshi.kani@hp.com>
Subject: Re: [PATCH v3 4/5] mtrr, x86: Clean up mtrr_type_lookup()
Date: Mon, 16 Mar 2015 21:24:12 +0000
Message-ID: <B4C2A151-B238-487F-942B-A550201FBAAD@hp.com>
References: <1426282421-25385-1-git-send-email-toshi.kani@hp.com>
 <1426282421-25385-5-git-send-email-toshi.kani@hp.com>,<20150316075821.GA16062@gmail.com>
In-Reply-To: <20150316075821.GA16062@gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hpa@zytor.com" <hpa@zytor.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "mingo@redhat.com" <mingo@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "dave.hansen@intel.com" <dave.hansen@intel.com>, "Elliott, Robert (Server
 Storage)" <Elliott@hp.com>, "pebolle@tiscali.nl" <pebolle@tiscali.nl>

> On Mar 16, 2015, at 3:58 AM, Ingo Molnar <mingo@kernel.org> wrote:
>=20
>=20
> * Toshi Kani <toshi.kani@hp.com> wrote:
>=20
>> MTRRs contain fixed and variable entries.  mtrr_type_lookup()
>> may repeatedly call __mtrr_type_lookup() to handle a request
>> that overlaps with variable entries.  However,
>> __mtrr_type_lookup() also handles the fixed entries, which
>> do not have to be repeated.  Therefore, this patch creates
>> separate functions, mtrr_type_lookup_fixed() and
>> mtrr_type_lookup_variable(), to handle the fixed and variable
>> ranges respectively.
>>=20
>> The patch also updates the function headers to clarify the
>> return values and output argument.  It updates comments to
>> clarify that the repeating is necessary to handle overlaps
>> with the default type, since overlaps with multiple entries
>> alone can be handled without such repeating.
>>=20
>> There is no functional change in this patch.
>=20
> Nice cleanup!
>=20
> I also suggest adding a small table to the comments before the=20
> function, that lists the fixed purpose MTRRs and their address ranges=20
> - to make it more obvious what the magic hexadecimal constants within=20
> the code are doing.

Yes, I will add a table to describe the fixed entries.

>> +static u8 mtrr_type_lookup_fixed(u64 start, u64 end)
>> +{
>> +    int idx;
>> +
>> +    if (start >=3D 0x100000)
>> +        return 0xFF;
>=20
> Btw., as a separate cleanup patch, we should probably also change=20
> '0xFF' (which is sometimes written as 0xff) to be some sufficiently=20
> named constant, and explain its usage somewhere?

Sounds good.  I will add a separate patch to do so.

>> +    if (!(mtrr_state.have_fixed) ||
>> +        !(mtrr_state.enabled & MTRR_STATE_MTRR_FIXED_ENABLED))
>=20
> Btw., can MTRR_STATE_MTRR_FIXED_ENABLED ever be set in=20
> mtrr_state.enabled, without mtrr_state.have_fixed being set?

Yes, I believe the arch allows the fixed entries disabled
while MTRRs are enabled.  I expect the most of systems=20
implement the fixed entries, though.

> AFAICS get_mtrr_state() will only ever fill in mtrr_state with fixed=20
> MTRRs if mtrr_state.have_fixed !=3D 0 - but I might be mis-reading the=20
> (rather convoluted) flow of code ...

I will check the code next week.

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
