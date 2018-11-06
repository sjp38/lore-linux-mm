Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2EA3A6B03B4
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 16:05:37 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id 190-v6so5000017pfd.7
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 13:05:37 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id z21-v6si11498951plo.89.2018.11.06.13.05.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Nov 2018 13:05:35 -0800 (PST)
Date: Tue, 6 Nov 2018 13:05:32 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v8 2/4] x86/modules: Increase randomization for modules
Message-Id: <20181106130532.1ef8e080baeedfa0960eebd4@linux-foundation.org>
In-Reply-To: <20181102192520.4522-3-rick.p.edgecombe@intel.com>
References: <20181102192520.4522-1-rick.p.edgecombe@intel.com>
	<20181102192520.4522-3-rick.p.edgecombe@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rick Edgecombe <rick.p.edgecombe@intel.com>
Cc: jeyu@kernel.org, willy@infradead.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, daniel@iogearbox.net, jannh@google.com, keescook@chromium.org, kristen@linux.intel.com, dave.hansen@intel.com, arjan@linux.intel.com

On Fri,  2 Nov 2018 12:25:18 -0700 Rick Edgecombe <rick.p.edgecombe@intel.com> wrote:

> This changes the behavior of the KASLR logic for allocating memory for the text
> sections of loadable modules. It randomizes the location of each module text
> section with about 17 bits of entropy in typical use. This is enabled on X86_64
> only. For 32 bit, the behavior is unchanged.
> 
> It refactors existing code around module randomization somewhat. There are now
> three different behaviors for x86 module_alloc depending on config.
> RANDOMIZE_BASE=n, and RANDOMIZE_BASE=y ARCH=x86_64, and RANDOMIZE_BASE=y
> ARCH=i386.
>
> The refactor of the existing code is to try to clearly show what
> those behaviors are without having three separate versions or threading the
> behaviors in a bunch of little spots. The reason it is not enabled on 32 bit
> yet is because the module space is much smaller and simulations haven't been
> run to see how it performs.
> 
> The new algorithm breaks the module space in two, a random area and a backup
> area. It first tries to allocate at a number of randomly located starting pages
> inside the random section without purging any lazy free vmap areas and
> triggering the associated TLB flush.

Surprised.  Is one TLB flush per module loading sufficiently expensive
to justify any effort to avoid it?  IOW, please provide some
justification and explanation in the changelog.

> If this fails, then it will allocate in
> the backup area. The backup area base will be offset in the same way as the
> current algorithm does for the base area, 1024 possible locations.

So presumably the allocation effort in the randomized section is
somewhat likely to fail.  That's unfortunate.  Some discussion about
why these failures occur would be helpful.

Because it would be nice to do away with the backup area altogether. 
But this reader doesn't really understand why the backup area is
needed.

> Due to boot_params being defined with different types in different places,
> placing the config helpers modules.h or kaslr.h caused conflicts elsewhere, and
> so they are placed in a new file, kaslr_modules.h, instead.
> 
