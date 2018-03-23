Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id AEB696B002E
	for <linux-mm@kvack.org>; Fri, 23 Mar 2018 15:12:55 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id j8so7141351pfh.13
        for <linux-mm@kvack.org>; Fri, 23 Mar 2018 12:12:55 -0700 (PDT)
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (mail-co1nam03on0044.outbound.protection.outlook.com. [104.47.40.44])
        by mx.google.com with ESMTPS id t80si6431300pgb.686.2018.03.23.12.12.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Mar 2018 12:12:54 -0700 (PDT)
From: Nadav Amit <namit@vmware.com>
Subject: Re: [PATCH 09/11] x86/pti: enable global pages for shared areas
Date: Fri, 23 Mar 2018 19:12:50 +0000
Message-ID: <7B08037D-1682-406D-90F1-C2B5B1899F7F@vmware.com>
References: <20180323174447.55F35636@viggo.jf.intel.com>
 <20180323174500.64BD3D36@viggo.jf.intel.com>
In-Reply-To: <20180323174500.64BD3D36@viggo.jf.intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <68D286D9C7305E439D4DBD5FE5AAAEFC@namprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "aarcange@redhat.com" <aarcange@redhat.com>, "luto@kernel.org" <luto@kernel.org>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, "keescook@google.com" <keescook@google.com>, "hughd@google.com" <hughd@google.com>, "jgross@suse.com" <jgross@suse.com>, "x86@kernel.org" <x86@kernel.org>

Dave Hansen <dave.hansen@linux.intel.com> wrote:

>=20
> From: Dave Hansen <dave.hansen@linux.intel.com>
>=20
> The entry/exit text and cpu_entry_area are mapped into userspace and
> the kernel.  But, they are not _PAGE_GLOBAL.  This creates unnecessary
> TLB misses.
>=20
> Add the _PAGE_GLOBAL flag for these areas.
>=20
> static void __init
> diff -puN arch/x86/mm/pti.c~kpti-why-no-global arch/x86/mm/pti.c
> --- a/arch/x86/mm/pti.c~kpti-why-no-global	2018-03-21 16:32:00.799192311 =
-0700
> +++ b/arch/x86/mm/pti.c	2018-03-21 16:32:00.803192311 -0700
> @@ -300,6 +300,13 @@ pti_clone_pmds(unsigned long start, unsi
> 			return;
>=20
> 		/*
> +		 * Setting 'target_pmd' below creates a mapping in both
> +		 * the user and kernel page tables.  It is effectively
> +		 * global, so set it as global in both copies.
> +		 */
> +		*pmd =3D pmd_set_flags(*pmd, _PAGE_GLOBAL);
if (boot_cpu_has(X86_FEATURE_PGE)) ?
