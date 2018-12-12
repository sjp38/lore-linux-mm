Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id D7C118E00E5
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 01:31:03 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id p66so4642979itc.0
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 22:31:03 -0800 (PST)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-eopbgr740043.outbound.protection.outlook.com. [40.107.74.43])
        by mx.google.com with ESMTPS id t185si2355514itt.131.2018.12.11.22.31.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 11 Dec 2018 22:31:02 -0800 (PST)
From: Nadav Amit <namit@vmware.com>
Subject: Re: [PATCH v2 4/4] x86/vmalloc: Add TLB efficient x86 arch_vunmap
Date: Wed, 12 Dec 2018 06:30:56 +0000
Message-ID: <90B10050-0CF1-48B2-B671-508FB092C2FE@vmware.com>
References: <20181212000354.31955-1-rick.p.edgecombe@intel.com>
 <20181212000354.31955-5-rick.p.edgecombe@intel.com>
In-Reply-To: <20181212000354.31955-5-rick.p.edgecombe@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <7D8FBBAF5802454AB9BBEEE3320BC3F6@namprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rick Edgecombe <rick.p.edgecombe@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Will Deacon <will.deacon@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "naveen.n.rao@linux.vnet.ibm.com" <naveen.n.rao@linux.vnet.ibm.com>, "anil.s.keshavamurthy@intel.com" <anil.s.keshavamurthy@intel.com>, "davem@davemloft.net" <davem@davemloft.net>, "mhiramat@kernel.org" <mhiramat@kernel.org>, "rostedt@goodmis.org" <rostedt@goodmis.org>, "mingo@redhat.com" <mingo@redhat.com>, "ast@kernel.org" <ast@kernel.org>, "daniel@iogearbox.net" <daniel@iogearbox.net>, "jeyu@kernel.org" <jeyu@kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "jannh@google.com" <jannh@google.com>, "kristen@linux.intel.com" <kristen@linux.intel.com>, "dave.hansen@intel.com" <dave.hansen@intel.com>, "deneen.t.dock@intel.com" <deneen.t.dock@intel.com>

> On Dec 11, 2018, at 4:03 PM, Rick Edgecombe <rick.p.edgecombe@intel.com> =
wrote:
>=20
> This adds a more efficient x86 architecture specific implementation of
> arch_vunmap, that can free any type of special permission memory with onl=
y 1 TLB
> flush.
>=20
> In order to enable this, _set_pages_p and _set_pages_np are made non-stat=
ic and
> renamed set_pages_p_noflush and set_pages_np_noflush to better communicat=
e
> their different (non-flushing) behavior from the rest of the set_pages_*
> functions.
>=20
> The method for doing this with only 1 TLB flush was suggested by Andy
> Lutomirski.
>=20

[snip]

> +	/*
> +	 * If the vm being freed has security sensitive capabilities such as
> +	 * executable we need to make sure there is no W window on the directma=
p
> +	 * before removing the X in the TLB. So we set not present first so we
> +	 * can flush without any other CPU picking up the mapping. Then we rese=
t
> +	 * RW+P without a flush, since NP prevented it from being cached by
> +	 * other cpus.
> +	 */
> +	set_area_direct_np(area);
> +	vm_unmap_aliases();

Does vm_unmap_aliases() flush in the TLB the direct mapping range as well? =
I
can only find the flush of the vmalloc range.
