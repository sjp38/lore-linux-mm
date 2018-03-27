Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id C93476B0033
	for <linux-mm@kvack.org>; Tue, 27 Mar 2018 05:24:13 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id e130so6660886wme.0
        for <linux-mm@kvack.org>; Tue, 27 Mar 2018 02:24:13 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id k44si618062wre.107.2018.03.27.02.24.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 27 Mar 2018 02:24:12 -0700 (PDT)
Date: Tue, 27 Mar 2018 11:23:50 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 2/2] x86/mm: Do not lose cpuinfo_x86:x86_phys_bits
 adjustment
In-Reply-To: <20180315134907.9311-3-kirill.shutemov@linux.intel.com>
Message-ID: <alpine.DEB.2.21.1803271115040.1964@nanos.tec.linutronix.de>
References: <20180315134907.9311-1-kirill.shutemov@linux.intel.com> <20180315134907.9311-3-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>

On Thu, 15 Mar 2018, Kirill A. Shutemov wrote:

> Some features (Intel MKTME, AMD SME) may reduce number of effectively

May? They fricking reduce the number of bits.

> available physical address bits. We adjust x86_phys_bits accordingly.
> 
> But if get_cpu_cap() got called more than one time we may lose this
> information.

We may? Dammit, I asked you more than once to stop writing fairy
tales. Changelogs are about facts and not about may/could or whatever. And
not WE lose the information, the information gets overwritten by the
subsequent invocation of get_cpu_cap().

> That's exactly what happens in setup_pku(): it gets called after
> detect_tme() and x86_phys_bits gets overwritten.
> 
> Add x86_phys_bits_adj which stores by how many bits we should reduce
> x86_phys_bits comparing to what CPUID returns.

That's just sloppy, really.

The real question is: Why on earth is get_cpu_cap() updating the 0x80000008
leaf information again after the first initialization?

If there is no reason to do so, then this needs to be taken out of
get_cpu_caps().

If there is a reason, then this wants to be explained proper.

This 'add some duct tape' mode has to stop. The cpu feature detection is
messy enough already, there is no need to add more to it unless there is a
real compelling reason.

Thanks,

	tglx
