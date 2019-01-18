Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id E2BE38E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 20:15:31 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id t72so8751076pfi.21
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 17:15:31 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y23sor4817492pga.35.2019.01.17.17.15.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 17 Jan 2019 17:15:30 -0800 (PST)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH 17/17] module: Prevent module removal racing with
 text_poke()
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <e865e051-be79-adce-7275-72abf2173bdb@zytor.com>
Date: Thu, 17 Jan 2019 17:15:27 -0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <69EA2C81-826F-46BA-8D80-241C39B0B70B@gmail.com>
References: <20190117003259.23141-1-rick.p.edgecombe@intel.com>
 <20190117003259.23141-18-rick.p.edgecombe@intel.com>
 <20190117165422.d33d1af83db8716e24960a3c@kernel.org>
 <e865e051-be79-adce-7275-72abf2173bdb@zytor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Masami Hiramatsu <mhiramat@kernel.org>, Rick Edgecombe <rick.p.edgecombe@intel.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>, LKML <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Damian Tometzki <linux_dti@icloud.com>, linux-integrity <linux-integrity@vger.kernel.org>, LSM List <linux-security-module@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>, Linux-MM <linux-mm@kvack.org>, Will Deacon <will.deacon@arm.com>, ard.biesheuvel@linaro.org, kristen@linux.intel.com, deneen.t.dock@intel.com

> On Jan 17, 2019, at 3:58 PM, H. Peter Anvin <hpa@zytor.com> wrote:
>=20
> On 1/16/19 11:54 PM, Masami Hiramatsu wrote:
>> On Wed, 16 Jan 2019 16:32:59 -0800
>> Rick Edgecombe <rick.p.edgecombe@intel.com> wrote:
>>=20
>>> From: Nadav Amit <namit@vmware.com>
>>>=20
>>> It seems dangerous to allow code modifications to take place
>>> concurrently with module unloading. So take the text_mutex while the
>>> memory of the module is freed.
>>=20
>> At that point, since the module itself is removed from module list,
>> it seems no actual harm. Or would you have any concern?
>=20
> The issue isn't the module list, but rather when it is safe to free =
the
> contents, so we don't clobber anything. We absolutely need to enforce
> that we can't text_poke() something that might have already been =
freed.
>=20
> That being said, we *also* really would prefer to enforce that we =
can't
> text_poke() memory that doesn't actually contain code; as far as I can
> tell we don't currently do that check.

Yes, that what the mutex was supposed to achieve. It=E2=80=99s not =
supposed just
to check whether it is a code page, but also that it is the same code
page that you wanted to patch.=20

> This, again, is a good use for a separate mm context. We can enforce
> that that context will only ever contain valid page mappings for =
actual
> code pages.

This will not tell you that you have the *right* code-page. The module
notifiers help to do so, since they synchronize the text poking with
the module removal.

> (Note: in my proposed algorithm, with a separate mm, replace INVLPG =
with
> switching CR3 if we have to do a rollback or roll forward in the
> breakpoint handler.)

I really need to read your patches more carefully to see what you mean.

Anyhow, so what do you prefer? I=E2=80=99m ok with either one:
	1. Keep this patch
	2. Remove this patch and change into a comment on text_poke()
	3. Just drop the patch
