Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 94E7D6B0038
	for <linux-mm@kvack.org>; Mon, 15 Jan 2018 22:09:37 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id p190so1502657wmd.0
        for <linux-mm@kvack.org>; Mon, 15 Jan 2018 19:09:37 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id w102sor470468wrb.45.2018.01.15.19.09.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 15 Jan 2018 19:09:36 -0800 (PST)
Date: Tue, 16 Jan 2018 04:09:32 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCHv2-resend] x86/mm, mm/hwpoison: Don't unconditionally
 unmap kernel 1:1 pages.
Message-ID: <20180116030932.itshfy2i4326bvoo@gmail.com>
References: <20171129192446.21090-1-tony.luck@intel.com>
 <20180110201947.32727-1-tony.luck@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180110201947.32727-1-tony.luck@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@intel.com>
Cc: Borislav Petkov <bp@suse.de>, Denys Vlasenko <dvlasenk@redhat.com>, linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>, Brian Gerst <brgerst@gmail.com>, "Hansen, Dave" <dave.hansen@intel.com>, Andy Lutomirski <luto@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Robert (Persistent Memory)" <elliott@hpe.com>, Thomas Gleixner <tglx@linutronix.de>


* Tony Luck <tony.luck@intel.com> wrote:

> v1->v2 0-day reported a build warning on 32-bit. Don't do 32-bit (see comment
> at end of commit message). This fixed the build error, but then discussion on
> the list went quiet. Repost to wake things up.

It seems dubious to me to introduce a difference in behavior on 32-bit:

> +static void mce_unmap_kpfn(unsigned long pfn)
> +{
> +#ifdef CONFIG_X86_64
> +	unsigned long decoy_addr;

> +	if (set_memory_np(decoy_addr, 1))
> +		pr_warn("Could not invalidate pfn=0x%lx from 1:1 map\n", pfn);
> +#endif

... to fix a build warning?

32-bit kernels might be under-tested, but if it's supposed to work I don't think 
we should bifurcate the behavior and uglify the code here.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
