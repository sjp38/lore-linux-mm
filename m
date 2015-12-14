Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id CFBA16B026D
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 14:46:49 -0500 (EST)
Received: by pacwq6 with SMTP id wq6so108578787pac.1
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 11:46:49 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id qy7si8457386pab.169.2015.12.14.11.46.49
        for <linux-mm@kvack.org>;
        Mon, 14 Dec 2015 11:46:49 -0800 (PST)
Date: Mon, 14 Dec 2015 11:46:48 -0800
From: "Luck, Tony" <tony.luck@intel.com>
Subject: Re: [PATCHV2 3/3] x86, ras: Add mcsafe_memcpy() function to recover
 from machine checks
Message-ID: <20151214194648.GA15222@agluck-desk.sc.intel.com>
References: <3908561D78D1C84285E8C5FCA982C28F39F82D87@ORSMSX114.amr.corp.intel.com>
 <CALCETrVeALAHbiLytBO=2WAwifon=K-wB6mCCWBfuuUu7dbBVA@mail.gmail.com>
 <3908561D78D1C84285E8C5FCA982C28F39F82EEF@ORSMSX114.amr.corp.intel.com>
 <CAPcyv4hR+FNZ7b1duZ9g9e0xWnAwBsMtnzms_ZRvssXNJUaVoA@mail.gmail.com>
 <CALCETrVcj=4sDaEXGNtYuq0kXLm7K9de1catqWPi25ae56g8Jg@mail.gmail.com>
 <3908561D78D1C84285E8C5FCA982C28F39F82F97@ORSMSX114.amr.corp.intel.com>
 <CALCETrUK1raRagO=JxCRpy0_eKfS56gce737fVe9rtJqNwH+_A@mail.gmail.com>
 <3908561D78D1C84285E8C5FCA982C28F39F82FED@ORSMSX114.amr.corp.intel.com>
 <CALCETrUFQXPB9HM8O+4UfMij7nodfrWtjicy0XNhOiWCka+4yw@mail.gmail.com>
 <20151214083625.GA28073@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151214083625.GA28073@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Andy Lutomirski <luto@amacapital.net>, "Williams, Dan J" <dan.j.williams@intel.com>, Borislav Petkov <bp@alien8.de>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>

On Mon, Dec 14, 2015 at 09:36:25AM +0100, Ingo Molnar wrote:
> >     /* deal with it */
> > 
> > That way the magic is isolated to the function that needs the magic.
> 
> Seconded - this is the usual pattern we use in all assembly functions.

Ok - you want me to write some x86 assembly code (you may regret that).

Initial question ... here's the fixup for __copy_user_nocache()

		.section .fixup,"ax"
	30:     shll $6,%ecx
		addl %ecx,%edx
		jmp 60f
	40:     lea (%rdx,%rcx,8),%rdx
		jmp 60f
	50:     movl %ecx,%edx
	60:     sfence
		jmp copy_user_handle_tail
		.previous

Are %ecx and %rcx synonyms for the same register? Is there some
super subtle reason we use the 'r' names in the "40" fixup, but
the 'e' names everywhere else in this code (and the 'e' names in
the body of the original function)?

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
