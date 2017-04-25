Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4F93B6B0038
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 14:53:39 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id m73so7446421wmi.22
        for <linux-mm@kvack.org>; Tue, 25 Apr 2017 11:53:39 -0700 (PDT)
Received: from mail-wr0-x242.google.com (mail-wr0-x242.google.com. [2a00:1450:400c:c0c::242])
        by mx.google.com with ESMTPS id w22si31086060wra.281.2017.04.25.11.53.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Apr 2017 11:53:37 -0700 (PDT)
Received: by mail-wr0-x242.google.com with SMTP id 6so12243977wrb.1
        for <linux-mm@kvack.org>; Tue, 25 Apr 2017 11:53:37 -0700 (PDT)
Date: Tue, 25 Apr 2017 20:53:34 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH] x86/mm/64: Fix crash in remove_pagetable()
Message-ID: <20170425185333.3ecz46gn5ufy4bwi@gmail.com>
References: <20170425092557.21852-1-kirill.shutemov@linux.intel.com>
 <CAPcyv4j6woeE7QfTVXEohh-kCbcFFJQmciMmgf5RDDWntM+P5w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4j6woeE7QfTVXEohh-kCbcFFJQmciMmgf5RDDWntM+P5w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, X86 ML <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>


* Dan Williams <dan.j.williams@intel.com> wrote:

> On Tue, Apr 25, 2017 at 2:25 AM, Kirill A. Shutemov
> <kirill.shutemov@linux.intel.com> wrote:
> > remove_pagetable() does page walk using p*d_page_vaddr() plus cast.
> > It's not canonical approach -- we usually use p*d_offset() for that.
> >
> > It works fine as long as all page table levels are present. We broke the
> > invariant by introducing folded p4d page table level.
> >
> > As result, remove_pagetable() interprets PMD as PUD and it leads to
> > crash:
> >
> >         BUG: unable to handle kernel paging request at ffff880300000000
> >         IP: memchr_inv+0x60/0x110
> >         PGD 317d067
> >         P4D 317d067
> >         PUD 3180067
> >         PMD 33f102067
> >         PTE 8000000300000060
> >
> > Let's fix this by using p*d_offset() instead of p*d_page_vaddr() for
> > page walk.
> >
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > Reported-by: Dan Williams <dan.j.williams@intel.com>
> > Fixes: f2a6a7050109 ("x86: Convert the rest of the code to support p4d_t")
> 
> Thanks! This patch on top of tip/master passes a full run of the
> nvdimm regression suite.
> 
> Tested-by: Dan Williams <dan.j.williams@intel.com>

Does a re-application of:

  "x86/mm/gup: Switch GUP to the generic get_user_page_fast() implementation"

still work (which you can achive via 'git revert 6dd29b3df975'), or is that 
another breakage?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
