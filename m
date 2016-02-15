Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id 6DC78828DF
	for <linux-mm@kvack.org>; Mon, 15 Feb 2016 06:02:15 -0500 (EST)
Received: by mail-qg0-f45.google.com with SMTP id b67so107672283qgb.1
        for <linux-mm@kvack.org>; Mon, 15 Feb 2016 03:02:15 -0800 (PST)
Received: from e17.ny.us.ibm.com (e17.ny.us.ibm.com. [129.33.205.207])
        by mx.google.com with ESMTPS id s2si33756062qki.76.2016.02.15.03.02.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 15 Feb 2016 03:02:14 -0800 (PST)
Received: from localhost
	by e17.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 15 Feb 2016 06:02:14 -0500
Received: from b01cxnp23033.gho.pok.ibm.com (b01cxnp23033.gho.pok.ibm.com [9.57.198.28])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 050C338C8041
	for <linux-mm@kvack.org>; Mon, 15 Feb 2016 06:02:12 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by b01cxnp23033.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u1FB2BcN32571410
	for <linux-mm@kvack.org>; Mon, 15 Feb 2016 11:02:11 GMT
Received: from d01av04.pok.ibm.com (localhost [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u1FB2A8q030500
	for <linux-mm@kvack.org>; Mon, 15 Feb 2016 06:02:11 -0500
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH V3] powerpc/mm: Fix Multi hit ERAT cause by recent THP update
In-Reply-To: <1455512997.16012.24.camel@gmail.com>
References: <1454980831-16631-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1455504278.16012.18.camel@gmail.com> <87lh6mfv2j.fsf@linux.vnet.ibm.com> <1455512997.16012.24.camel@gmail.com>
Date: Mon, 15 Feb 2016 16:31:59 +0530
Message-ID: <87d1ryfd94.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, akpm@linux-foundation.org, Mel Gorman <mgorman@techsingularity.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Balbir Singh <bsingharora@gmail.com> writes:

>> Now we can't depend for mm_cpumask, a parallel find_linux_pte_hugepte
>> can happen outside that. Now i had a variant for kick_all_cpus_sync that
>> ignored idle cpus. But then that needs more verification.
>>=20
>> http://article.gmane.org/gmane.linux.ports.ppc.embedded/81105
> Can be racy as a CPU moves from non-idle to idle
>
> In
>
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0pmd_hugepage_update(vma->vm_mm, address, =
pmdp, ~0UL, 0);
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0/*
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0* This ensures that generic code th=
at rely on IRQ disabling
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0* to prevent a parallel THP split w=
ork as expected.
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0*/
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0kick_all_cpus_sync();
>
> pmdp_invalidate()->pmd_hugepage_update() can still run in parallel with=
=C2=A0
> find_linux_pte_or_hugepte() and race.. Am I missing something?
>

Yes. But then we make sure that the pte_t returned by
find_linux_pte_or_hugepte doesn't change to a regular pmd entry by using
that kick. Now callers of find_lnux_pte_or_hugepte will check for
_PAGE_PRESENT. So if it called before
pmd_hugepage_update(_PAGE_PRESENT), we wait for the caller to finish the
usage (via kick()). Or they bail out after finding _PAGE_PRESENT cleared.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
