Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 273346B7586
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 13:11:22 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id 68so17382446pfr.6
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 10:11:22 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p186sor27157156pgp.79.2018.12.05.10.11.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Dec 2018 10:11:20 -0800 (PST)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: [RFC v2 01/13] x86/mktme: Document the MKTME APIs
From: Andy Lutomirski <luto@amacapital.net>
In-Reply-To: <c2276bbbb19f3a28bd37c3dd6b1021e2d9a10916.1543903910.git.alison.schofield@intel.com>
Date: Wed, 5 Dec 2018 10:11:18 -0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <4ED70A75-9A88-41B4-B595-87FB748772F9@amacapital.net>
References: <cover.1543903910.git.alison.schofield@intel.com> <c2276bbbb19f3a28bd37c3dd6b1021e2d9a10916.1543903910.git.alison.schofield@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alison Schofield <alison.schofield@intel.com>
Cc: dhowells@redhat.com, tglx@linutronix.de, jmorris@namei.org, mingo@redhat.com, hpa@zytor.com, bp@alien8.de, luto@kernel.org, peterz@infradead.org, kirill.shutemov@linux.intel.com, dave.hansen@intel.com, kai.huang@intel.com, jun.nakajima@intel.com, dan.j.williams@intel.com, jarkko.sakkinen@intel.com, keyrings@vger.kernel.org, linux-security-module@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org



> On Dec 3, 2018, at 11:39 PM, Alison Schofield <alison.schofield@intel.com>=
 wrote:

I realize you=E2=80=99re writing code to expose hardware behavior, but I=E2=80=
=99m not sure this
really makes sense in this context.

> .
> +
> +Usage
> +-----
> +    When using the Kernel Key Service to request an *mktme* key,
> +    specify the *payload* as follows:
> +
> +    type=3D
> +        *user*    User will supply the encryption key data. Use this
> +                type to directly program a hardware encryption key.
> +

I think that =E2=80=9Cuser=E2=80=9D probably sense as a =E2=80=9Ckey service=
=E2=80=9D key, but I don=E2=80=99t think it is at all useful for non-persist=
ent memory.  Even if we take for granted that MKTME for anonymous memory is u=
seful at all, =E2=80=9Ccpu=E2=80=9D seems to be better in all respects.


Perhaps support for =E2=80=9Cuser=E2=80=9D should be tabled until there=E2=80=
=99s a design for how to use this for pmem?  I imagine it would look quite a=
 bit like dm-crypt.  Advanced pmem filesystems could plausibly use different=
 keys for different files, I suppose.

If =E2=80=9Cuser=E2=80=9D is dropped, I think a lot of the complexity goes a=
way. Hotplug becomes automatic, right?

> +        *cpu*    User requests a CPU generated encryption key.

Okay, maybe, but it=E2=80=99s still unclear to me exactly what the intended b=
enefit is, though.

> +                The CPU generates and assigns an ephemeral key.
> +
> +        *clear* User requests that a hardware encryption key be
> +                cleared. This will clear the encryption key from
> +                the hardware. On execution this hardware key gets
> +                TME behavior.
> +

Why is this a key type?  Shouldn=E2=80=99t the API to select a key just have=
 an option to ask for no key to be used?

> +        *no-encrypt*
> +                 User requests that hardware does not encrypt
> +                 memory when this key is in use.

Same as above.  If there=E2=80=99s a performance benefit, then there could b=
e a way to ask for cleartext memory.  Similarly, some pmem users may want a w=
ay to keep their pmem unencrypted.

=E2=80=94Andy=
