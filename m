Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D9B165F0001
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 07:38:29 -0400 (EDT)
Received: by wf-out-1314.google.com with SMTP id 25so2722960wfa.11
        for <linux-mm@kvack.org>; Wed, 15 Apr 2009 04:39:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090415104615.GG9809@random.random>
References: <20090414143252.GE28265@random.random>
	 <200904150042.15653.nickpiggin@yahoo.com.au>
	 <20090415165431.AC4C.A69D9226@jp.fujitsu.com>
	 <20090415104615.GG9809@random.random>
Date: Wed, 15 Apr 2009 20:39:04 +0900
Message-ID: <2f11576a0904150439k6e828307ja97b6729650bcb94@mail.gmail.com>
Subject: Re: [RFC][PATCH v3 1/6] mm: Don't unmap gup()ed page
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Jeff Moyer <jmoyer@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

>> + =A0 =A0 if (!migration) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 /* re-check */
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (PageSwapCache(page) &&
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 page_count(page) !=3D page_mapcount(pa=
ge) + 2) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* We lose race against get_us=
er_pages_fast() */
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_pte_at(mm, address, pte, p=
teval);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D SWAP_FAIL;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_unmap;
>> + =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 }
>> + =A0 =A0 mmu_notifier_invalidate_page(vma->vm_mm, address);
>
> With regard to mmu notifier, this is the opposite of the right
> ordering. One mmu_notifier_invalidate_page must run _before_ the first
> check. The ptep_clear_flush_notify will then stay and there's no need
> of a further mmu_notifier_invalidate_page after the second check.

OK. but I have one question.

Can we assume mmu_notifier is only used by kvm now?
if not, we need to make new notifier.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
