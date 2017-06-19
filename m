Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3E8996B0292
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 18:53:23 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id w12so113983029pfk.1
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 15:53:23 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id y22si10152185pli.292.2017.06.19.15.53.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Jun 2017 15:53:22 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id y7so19647377pfd.3
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 15:53:22 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH v2 10/10] x86/mm: Try to preserve old TLB entries using
 PCID
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <CALCETrV=v_4Ss4VSSW0CJFWCnr0Ks9c0K1W55wipOnL8sStOpg@mail.gmail.com>
Date: Mon, 19 Jun 2017 15:53:20 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <29636D5E-53D4-47B1-8F72-8DD0FAE58A60@gmail.com>
References: <cover.1497415951.git.luto@kernel.org>
 <35264bd304c93f6d3cfff2329e3e01b084598ea1.1497415951.git.luto@kernel.org>
 <740B1D51-B801-48C9-A4C9-F31B34A09AEF@gmail.com>
 <CALCETrV=v_4Ss4VSSW0CJFWCnr0Ks9c0K1W55wipOnL8sStOpg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

Andy Lutomirski <luto@kernel.org> wrote:

> On Sat, Jun 17, 2017 at 11:26 PM, Nadav Amit <nadav.amit@gmail.com> =
wrote:
>>> On Jun 13, 2017, at 9:56 PM, Andy Lutomirski <luto@kernel.org> =
wrote:
>>>=20
>>> PCID is a "process context ID" -- it's what other architectures call
>>> an address space ID.  Every non-global TLB entry is tagged with a
>>> PCID, only TLB entries that match the currently selected PCID are
>>> used, and we can switch PGDs without flushing the TLB.  x86's
>>> PCID is 12 bits.
>>>=20
>>> This is an unorthodox approach to using PCID.  x86's PCID is far too
>>> short to uniquely identify a process, and we can't even really
>>> uniquely identify a running process because there are monster
>>> systems with over 4096 CPUs.  To make matters worse, past attempts
>>> to use all 12 PCID bits have resulted in slowdowns instead of
>>> speedups.
>>>=20
>>> This patch uses PCID differently.  We use a PCID to identify a
>>> recently-used mm on a per-cpu basis.  An mm has no fixed PCID
>>> binding at all; instead, we give it a fresh PCID each time it's
>>> loaded except in cases where we want to preserve the TLB, in which
>>> case we reuse a recent value.
>>>=20
>>> In particular, we use PCIDs 1-3 for recently-used mms and we reserve
>>> PCID 0 for swapper_pg_dir and for PCID-unaware CR3 users (e.g. EFI).
>>> Nothing ever switches to PCID 0 without flushing PCID 0 non-global
>>> pages, so PCID 0 conflicts won't cause problems.
>>=20
>> Is this commit message outdated?
>=20
> Yes, it's old.  Will fix.

Just to clarify: I asked since I don=E2=80=99t understand how the =
interaction with
PCID-unaware CR3 users go. Specifically, IIUC, =
arch_efi_call_virt_teardown()
can reload CR3 with an old PCID value. No?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
