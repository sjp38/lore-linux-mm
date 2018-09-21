Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0C48E8E0001
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 04:42:16 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id s11-v6so5453489pgv.9
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 01:42:16 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id x3-v6si23088754plr.138.2018.09.21.01.42.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Sep 2018 01:42:14 -0700 (PDT)
Message-ID: <1537519325.19048.0.camel@intel.com>
Subject: Re: [PATCH 3/3] mm: optimise pte dirty/accessed bit setting by
 demand based pte insertion
From: Ley Foon Tan <ley.foon.tan@intel.com>
Date: Fri, 21 Sep 2018 16:42:05 +0800
In-Reply-To: <20180918035337.0727dad0@roar.ozlabs.ibm.com>
References: <20180828112034.30875-1-npiggin@gmail.com>
	 <20180828112034.30875-4-npiggin@gmail.com>
	 <20180905142951.GA15680@roeck-us.net>
	 <20180918035337.0727dad0@roar.ozlabs.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>, Guenter Roeck <linux@roeck-us.net>
Cc: linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ley Foon Tan <lftan@altera.com>, nios2-dev@lists.rocketboards.org

On Tue, 2018-09-18 at 03:53 +1000, Nicholas Piggin wrote:
> On Wed, 5 Sep 2018 07:29:51 -0700
> Guenter Roeck <linux@roeck-us.net> wrote:
>=20
> >=20
> > Hi,
> >=20
> > On Tue, Aug 28, 2018 at 09:20:34PM +1000, Nicholas Piggin wrote:
> > >=20
> > > Similarly to the previous patch, this tries to optimise
> > > dirty/accessed
> > > bits in ptes to avoid access costs of hardware setting them.
> > >=20
> > This patch results in silent nios2 boot failures, silent meaning
> > that
> > the boot stalls.
> Okay I just got back to looking at this. The reason for the hang is
> I think a bug in the nios2 TLB code, but maybe other archs have
> similar
> issues.
>=20
> In case of a missing / !present Linux pte, nios2 installs a TLB entry
> with no permissions via its fast TLB exception handler (software TLB
> fill). Then it relies on that causing a TLB permission exception in a
> slower handler that calls handle_mm_fault to set the Linux pte and
> flushes the old TLB. Then the fast exception handler will find the
> new
> Linux pte.
>=20
> With this patch, nios2 has a case where handle_mm_fault does not
> flush
> the old TLB, which results in the TLB permission exception
> continually
> being retried.
>=20
> What happens now is that fault paths like do_read_fault will install
> a
> Linux pte with the young bit clear and return. That will cause nios2
> to
> fault again but this time go down the bottom of handle_pte_fault and
> to
> the access flags update with the young bit set. The young bit is seen
> to
> be different, so that causes ptep_set_access_flags to do a TLB flush
> and
> that finally allows the fast TLB handler to fire and pick up the new
> Linux pte.
>=20
> With this patch, the young bit is set in the first handle_mm_fault,
> so
> the second handle_mm_fault no longer sees the ptes are different and
> does not flush the TLB. The spurious fault handler also does not
> flush
> them unless FAULT_FLAG_WRITE is set.
>=20
> What nios2 should do is invalidate the TLB in update_mmu_cache. What
> it
> *really* should do is install the new TLB entry, I have some patches
> to
> make that work in qemu I can submit. But I would like to try getting
> these dirty/accessed bit optimisation in 4.20, so I will send a
> simple
> path to just do the TLB invalidate that could go in Andrew's git
> tree.
>=20
> Is that agreeable with the nios2 maintainers?
>=20
> Thanks,
> Nick
>=20
Hi

Do you have patches to test?

Regards
Ley Foon
