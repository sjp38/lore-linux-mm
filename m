Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id C73E66B0038
	for <linux-mm@kvack.org>; Mon, 15 Jun 2015 16:35:38 -0400 (EDT)
Received: by wibdq8 with SMTP id dq8so90743755wib.1
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 13:35:38 -0700 (PDT)
Received: from mail-wg0-x233.google.com (mail-wg0-x233.google.com. [2a00:1450:400c:c00::233])
        by mx.google.com with ESMTPS id q5si23931003wjw.143.2015.06.15.13.35.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jun 2015 13:35:37 -0700 (PDT)
Received: by wgv5 with SMTP id 5so77925644wgv.1
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 13:35:36 -0700 (PDT)
Date: Mon, 15 Jun 2015 22:35:32 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 07/12] x86/virt/guest/xen: Remove use of pgd_list from
 the Xen guest code
Message-ID: <20150615203532.GC13273@gmail.com>
References: <1434188955-31397-1-git-send-email-mingo@kernel.org>
 <1434188955-31397-8-git-send-email-mingo@kernel.org>
 <1434359109.13744.14.camel@hellion.org.uk>
 <557EA944.9020504@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <557EA944.9020504@citrix.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Vrabel <david.vrabel@citrix.com>
Cc: Ian Campbell <ijc@hellion.org.uk>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, xen-devel@lists.xenproject.org, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Denys Vlasenko <dvlasenk@redhat.com>, Brian Gerst <brgerst@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Waiman Long <Waiman.Long@hp.com>


* David Vrabel <david.vrabel@citrix.com> wrote:

> On 15/06/15 10:05, Ian Campbell wrote:
> > On Sat, 2015-06-13 at 11:49 +0200, Ingo Molnar wrote:

> >> xen_mm_pin_all()/unpin_all() are used to implement full guest instance 
> >> suspend/restore. It's a stop-all method that needs to iterate through all 
> >> allocated pgds in the system to fix them up for Xen's use.
> >>
> >> This code uses pgd_list, probably because it was an easy interface.
> >>
> >> But we want to remove the pgd_list, so convert the code over to walk all 
> >> tasks in the system. This is an equivalent method.
> 
> It is not equivalent because pgd_alloc() now populates entries in pgds that are 
> not visible to xen_mm_pin_all() (note how the original code adds the pgd to the 
> pgd_list in pgd_ctor() before calling pgd_prepopulate_pmd()).  These newly 
> allocated page tables won't be correctly converted on suspend/resume and the new 
> process will die after resume.

So how should the Xen logic be fixed for the new scheme? I can't say I can see 
through the paravirt complexity here.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
