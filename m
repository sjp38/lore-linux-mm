Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id A5A416B02F4
	for <linux-mm@kvack.org>; Thu, 17 Aug 2017 18:30:31 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id s143so127374041ywg.3
        for <linux-mm@kvack.org>; Thu, 17 Aug 2017 15:30:31 -0700 (PDT)
Received: from g9t5008.houston.hpe.com (g9t5008.houston.hpe.com. [15.241.48.72])
        by mx.google.com with ESMTPS id y21si39648ywd.702.2017.08.17.15.30.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Aug 2017 15:30:30 -0700 (PDT)
From: "Elliott, Robert (Persistent Memory)" <elliott@hpe.com>
Subject: RE: [PATCH-resend] mm/hwpoison: Clear PRESENT bit for kernel 1:1
 mappings of poison pages
Date: Thu, 17 Aug 2017 22:29:48 +0000
Message-ID: <AT5PR84MB0082647C725926CC932904B0AB830@AT5PR84MB0082.NAMPRD84.PROD.OUTLOOK.COM>
References: <CAPcyv4gC_6TpwVSjuOzxrz3OdVZCVWD0QVWhBzAuOxUNHJHRMQ@mail.gmail.com>
	<20170816171803.28342-1-tony.luck@intel.com>
 <20170817150942.017f87537b6cbb48e9cfc082@linux-foundation.org>
In-Reply-To: <20170817150942.017f87537b6cbb48e9cfc082@linux-foundation.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Luck, Tony" <tony.luck@intel.com>
Cc: Borislav Petkov <bp@suse.de>, Dave Hansen <dave.hansen@intel.com>, Naoya
 Horiguchi <n-horiguchi@ah.jp.nec.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>



> -----Original Message-----
> From: Andrew Morton [mailto:akpm@linux-foundation.org]
> Sent: Thursday, August 17, 2017 5:10 PM
> To: Luck, Tony <tony.luck@intel.com>
> Cc: Borislav Petkov <bp@suse.de>; Dave Hansen <dave.hansen@intel.com>;
> Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>; Elliott, Robert (Persistent
> Memory) <elliott@hpe.com>; x86@kernel.org; linux-mm@kvack.org; linux-
> kernel@vger.kernel.org
> Subject: Re: [PATCH-resend] mm/hwpoison: Clear PRESENT bit for kernel 1:1
> mappings of poison pages
>=20
> On Wed, 16 Aug 2017 10:18:03 -0700 "Luck, Tony" <tony.luck@intel.com>
> wrote:
>=20
> > Speculative processor accesses may reference any memory that has a
> > valid page table entry.  While a speculative access won't generate
> > a machine check, it will log the error in a machine check bank. That
> > could cause escalation of a subsequent error since the overflow bit
> > will be then set in the machine check bank status register.
> >
> > Code has to be double-plus-tricky to avoid mentioning the 1:1 virtual
> > address of the page we want to map out otherwise we may trigger the
> > very problem we are trying to avoid.  We use a non-canonical address
> > that passes through the usual Linux table walking code to get to the
> > same "pte".
> >
> > Thanks to Dave Hansen for reviewing several iterations of this.
>=20
> It's unclear (to lil ole me) what the end-user-visible effects of this
> are.
>=20
> Could we please have a description of that?  So a) people can
> understand your decision to cc:stable and b) people whose kernels are
> misbehaving can use your description to decide whether your patch might
> fix the issue their users are reporting.

In general, the system is subject to halting due to uncorrectable
memory errors at addresses that software is not even accessing. =20

The first error doesn't cause the crash, but if a second error happens
before the machine check handler services the first one, it'll find
the Overflow bit set and won't know what errors or how many errors
happened (e.g., it might have been problems in an instruction fetch,
and the instructions the CPU is slated to run are bogus).  Halting is=20
the only safe thing to do.

For persistent memory, the BIOS reports known-bad addresses in the
ACPI ARS (address range scrub) table.  They are likely to keep
reappearing every boot since it is persistent memory, so you can't
just reboot and hope they go away.  Software is supposed to avoid
reading those addresses until it fixes them (e.g., writes new data
to those locations).  Even if it follows this rule, the system can
still crash due to speculative reads (e.g., prefetches) touching
those addresses.

Tony's patch marks those addresses in the page tables so the CPU
won't speculatively try to read them.

---
Robert Elliott, HPE Persistent Memory






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
