Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id B2EB66B0003
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 13:26:04 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id m3so2550372pgd.20
        for <linux-mm@kvack.org>; Fri, 16 Feb 2018 10:26:04 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s13-v6sor601600plp.13.2018.02.16.10.26.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 16 Feb 2018 10:26:03 -0800 (PST)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH 2/3] x86/mm: introduce __PAGE_KERNEL_GLOBAL
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <a3dd1676-a2dc-aa02-77ad-51cd3b7a78d5@linux.intel.com>
Date: Fri, 16 Feb 2018 10:25:59 -0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <DF43D1DD-42EE-4545-9F54-4BC2395D66EA@gmail.com>
References: <20180215132053.6C9B48C8@viggo.jf.intel.com>
 <20180215132055.F341C31E@viggo.jf.intel.com>
 <E0AB2852-C4E0-43D3-ABA7-34117A5516C1@gmail.com>
 <a3dd1676-a2dc-aa02-77ad-51cd3b7a78d5@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, jgross@suse.com, x86@kernel.org

Dave Hansen <dave.hansen@linux.intel.com> wrote:

> On 02/16/2018 09:47 AM, Nadav Amit wrote:
>>> But, this also means that we now get *no* opportunity to use
>>> global pages with PTI, even for data which is shared such as the
>>> cpu_entry_area and entry/exit text.
>>=20
>> Doesn=E2=80=99t this patch change the kernel behavior when the =
=E2=80=9Cnopti=E2=80=9D
>> parameter is used?
>=20
> I don't think so.  It takes the "nopti" behavior and effectively makes
> it apply everywhere.  So it changes the PTI behavior, not the "nopti"
> behavior.
>=20
> Maybe it would help to quote the code that you think does this instead
> of the description. :)

Sorry, I thought it is obvious - so I must be missing something.

> +#ifdef CONFIG_PAGE_TABLE_ISOLATION
> +#define __PAGE_KERNEL_GLOBAL		0
> +#else
> +#define __PAGE_KERNEL_GLOBAL		_PAGE_GLOBAL
> +#endif
...
> --- a/arch/x86/mm/pageattr.c~kpti-no-global-for-kernel-mappings	=
2018-02-13 15:17:56.148210060 -0800
> +++ b/arch/x86/mm/pageattr.c	2018-02-13 15:17:56.153210060 -0800
> @@ -593,7 +593,8 @@ try_preserve_large_page(pte_t *kpte, uns
> 	 * different bit positions in the two formats.
> 	 */
> 	req_prot =3D pgprot_4k_2_large(req_prot);
> -	req_prot =3D pgprot_set_on_present(req_prot, _PAGE_GLOBAL | =
_PAGE_PSE);
> +	req_prot =3D pgprot_set_on_present(req_prot,
> +			__PAGE_KERNEL_GLOBAL | _PAGE_PSE);
> 	req_prot =3D canon_pgprot(req_prot);

=46rom these chunks, it seems to me as req_prot will not have the global =
bit
on when =E2=80=9Cnopti=E2=80=9D parameter is provided. What am I =
missing?
=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
