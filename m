Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id BD5A36B0003
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 14:54:09 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id r15so2170626wrr.16
        for <linux-mm@kvack.org>; Fri, 16 Feb 2018 11:54:09 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i10sor3793535edk.51.2018.02.16.11.54.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 16 Feb 2018 11:54:08 -0800 (PST)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH 2/3] x86/mm: introduce __PAGE_KERNEL_GLOBAL
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <0f8abc68-1092-1bae-d244-1adbbee455f9@linux.intel.com>
Date: Fri, 16 Feb 2018 11:54:03 -0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <4542D3AE-6A4F-45AD-AD70-8DFA9503071A@gmail.com>
References: <20180215132053.6C9B48C8@viggo.jf.intel.com>
 <20180215132055.F341C31E@viggo.jf.intel.com>
 <E0AB2852-C4E0-43D3-ABA7-34117A5516C1@gmail.com>
 <a3dd1676-a2dc-aa02-77ad-51cd3b7a78d5@linux.intel.com>
 <DF43D1DD-42EE-4545-9F54-4BC2395D66EA@gmail.com>
 <0f8abc68-1092-1bae-d244-1adbbee455f9@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, keescook@google.com, Hugh Dickins <hughd@google.com>, Juergen Gross <jgross@suse.com>, x86@kernel.org

Dave Hansen <dave.hansen@linux.intel.com> wrote:

> On 02/16/2018 10:25 AM, Nadav Amit wrote:
>>> +#ifdef CONFIG_PAGE_TABLE_ISOLATION
>>> +#define __PAGE_KERNEL_GLOBAL		0
>>> +#else
>>> +#define __PAGE_KERNEL_GLOBAL		_PAGE_GLOBAL
>>> +#endif
>> ...
>>> --- a/arch/x86/mm/pageattr.c~kpti-no-global-for-kernel-mappings	=
2018-02-13 15:17:56.148210060 -0800
>>> +++ b/arch/x86/mm/pageattr.c	2018-02-13 15:17:56.153210060 =
-0800
>>> @@ -593,7 +593,8 @@ try_preserve_large_page(pte_t *kpte, uns
>>> 	 * different bit positions in the two formats.
>>> 	 */
>>> 	req_prot =3D pgprot_4k_2_large(req_prot);
>>> -	req_prot =3D pgprot_set_on_present(req_prot, _PAGE_GLOBAL | =
_PAGE_PSE);
>>> +	req_prot =3D pgprot_set_on_present(req_prot,
>>> +			__PAGE_KERNEL_GLOBAL | _PAGE_PSE);
>>> 	req_prot =3D canon_pgprot(req_prot);
>> =46rom these chunks, it seems to me as req_prot will not have the =
global bit
>> on when =E2=80=9Cnopti=E2=80=9D parameter is provided. What am I =
missing?
>=20
> That's a good point.  The current patch does not allow the use of
> _PAGE_GLOBAL via _PAGE_KERNEL_GLOBAL when =
CONFIG_PAGE_TABLE_ISOLATION=3Dy,
> but booted with nopti.  It's a simple enough fix.  Logically:
>=20
> #ifdef CONFIG_PAGE_TABLE_ISOLATION
> #define __PAGE_KERNEL_GLOBAL	static_cpu_has(X86_FEATURE_PTI) ?
> 					0 : _PAGE_GLOBAL
> #else
> #define __PAGE_KERNEL_GLOBAL	_PAGE_GLOBAL
> #endif
>=20
> But I don't really want to hide that gunk in a macro like that.  It
> might make more sense as a static inline.  I'll give that a shot and =
resent.

Since determining whether PTI is on is done in several places in the =
kernel,
maybe there should a single function to determine whether PTI is on,
something like:

static inline bool is_pti_on(void)
{
	return IS_ENABLED(CONFIG_PAGE_TABLE_ISOLATION) &&=20
		static_cpu_has(X86_FEATURE_PTI);
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
