Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 441F86B0253
	for <linux-mm@kvack.org>; Thu,  9 Jun 2016 15:46:00 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id fg1so67030443pad.1
        for <linux-mm@kvack.org>; Thu, 09 Jun 2016 12:46:00 -0700 (PDT)
Received: from mail-pf0-x234.google.com (mail-pf0-x234.google.com. [2607:f8b0:400e:c00::234])
        by mx.google.com with ESMTPS id g195si9012685pfb.182.2016.06.09.12.45.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Jun 2016 12:45:59 -0700 (PDT)
Received: by mail-pf0-x234.google.com with SMTP id 62so15841269pfd.1
        for <linux-mm@kvack.org>; Thu, 09 Jun 2016 12:45:58 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [RFC 05/13] x86/mm: Add barriers and document switch_mm-vs-flush synchronization
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <CALCETrX1TJ0BBJ40Gu_TNrrdntLdeR42Erg4QMbt5HoN9DqngA@mail.gmail.com>
Date: Thu, 9 Jun 2016 12:45:55 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <AC05E45B-CC10-4362-9513-5704DE620A1D@gmail.com>
References: <cover.1452294700.git.luto@kernel.org> <95a853538da28c64dfc877c60549ec79ed7a5d69.1452294700.git.luto@kernel.org> <8D80C93B-3DD6-469B-90D6-FBC71B917EAD@gmail.com> <CALCETrX1TJ0BBJ40Gu_TNrrdntLdeR42Erg4QMbt5HoN9DqngA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Andy Lutomirski <luto@amacapital.net> wrote:

> On Fri, Jun 3, 2016 at 10:42 AM, Nadav Amit <nadav.amit@gmail.com> =
wrote:
>> Following this patch, if (current->active_mm !=3D mm), =
flush_tlb_page() still
>> doesn=E2=80=99t call smp_mb() before checking mm_cpumask(mm).
>>=20
>> In contrast, flush_tlb_mm_range() does call smp_mb().
>>=20
>> Is there a reason for this discrepancy?
>=20
> Not that I can remember.  Is the remote flush case likely to be racy?

You replied separately on another email that included a patch to fix
this case. It turns out smp_mb is not needed on flush_tlb_page, since
the PTE is always updated using an atomic operation. Yet, a compiler=20
barrier is still needed, so I added smp_mb__after_atomic instead.

Nadav=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
