Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id A3CD08E00E5
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 11:30:01 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id k125so12481087pga.5
        for <linux-mm@kvack.org>; Wed, 12 Dec 2018 08:30:01 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 37si14780515pgw.590.2018.12.12.08.30.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Dec 2018 08:30:00 -0800 (PST)
Received: from mail-wm1-f54.google.com (mail-wm1-f54.google.com [209.85.128.54])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id A5D6820879
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 16:29:59 +0000 (UTC)
Received: by mail-wm1-f54.google.com with SMTP id y1so6371318wmi.3
        for <linux-mm@kvack.org>; Wed, 12 Dec 2018 08:29:59 -0800 (PST)
MIME-Version: 1.0
References: <cover.1543903910.git.alison.schofield@intel.com>
 <CALCETrUqqQiHR_LJoKB2JE6hCZ-e7LiFprEhmo-qoegDZJ9uYQ@mail.gmail.com>
 <0a21eadd05b245f762f7d536d8fdf579c113a9bc.camel@intel.com>
 <20181207115713.ia5jbrx5e3osaqxi@kshutemo-mobl1> <fd94ec722edc45008097a39d0c84a5d7134641c7.camel@intel.com>
 <19c539f8c6c9b34974e4cb4f268eb64fe7ba4297.camel@intel.com> <655394650664715c39ef242689fbc8af726f09c3.camel@intel.com>
In-Reply-To: <655394650664715c39ef242689fbc8af726f09c3.camel@intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Wed, 12 Dec 2018 08:29:45 -0800
Message-ID: <CALCETrVztbuRUnp9MUz-Pp85NhY2htNZHGszS+mU_oWoXK3u6A@mail.gmail.com>
Subject: Re: [RFC v2 00/13] Multi-Key Total Memory Encryption API (MKTME)
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Sakkinen, Jarkko" <jarkko.sakkinen@intel.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, James Morris <jmorris@namei.org>, kai.huang@intel.com, keyrings@vger.kernel.org, Matthew Wilcox <willy@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Linux-MM <linux-mm@kvack.org>, David Howells <dhowells@redhat.com>, LSM List <linux-security-module@vger.kernel.org>, Dan Williams <dan.j.williams@intel.com>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, Andrew Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@intel.com>, Alison Schofield <alison.schofield@intel.com>, Jun Nakajima <jun.nakajima@intel.com>

On Wed, Dec 12, 2018 at 7:31 AM Sakkinen, Jarkko
<jarkko.sakkinen@intel.com> wrote:
>
> On Fri, 2018-12-07 at 15:45 -0800, Jarkko Sakkinen wrote:
> > The brutal fact is that a physical address is an astronomical stretch
> > from a random value or increasing counter. Thus, it is fair to say that
> > MKTME provides only naive measures against replay attacks...
>
> I'll try to summarize how I understand the high level security
> model of MKTME because (would be good idea to document it).
>
> Assumptions:
>
> 1. The hypervisor has not been infiltrated.
> 2. The hypervisor does not leak secrets.
>
> When (1) and (2) hold [1], we harden VMs in two different ways:
>
> A. VMs cannot leak data to each other or can they with L1TF when HT
>    is enabled?

I strongly suspect that, on L1TF-vulnerable CPUs, MKTME provides no
protection whatsoever.  It sounds like MKTME is implemented in the
memory controller -- as far as the rest of the CPU and the cache
hierarchy are concerned, the MKTME key selction bits are just part of
the physical address.  So an attack like L1TF that leaks a cacheline
that's selected by physical address will leak the cleartext if the key
selection bits are set correctly.

(I suppose that, if the attacker needs to brute-force the physical
address, then MKTME makes it a bit harder because the effective
physical address space is larger.)

> B. Protects against cold boot attacks.

TME does this, AFAIK.  MKTME does, too, unless the "user" mode is
used, in which case the protection is weaker.

>
> Isn't this what this about in the nutshell roughly?
>
> [1] XPFO could potentially be an opt-in feature that reduces the
>     damage when either of these assumptions has been broken.
>
> /Jarkko
