Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2D45F6B0038
	for <linux-mm@kvack.org>; Sat, 21 Oct 2017 04:32:14 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id v127so5596488wma.3
        for <linux-mm@kvack.org>; Sat, 21 Oct 2017 01:32:14 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c30sor1472545edf.16.2017.10.21.01.32.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 21 Oct 2017 01:32:13 -0700 (PDT)
Date: Sat, 21 Oct 2017 11:32:10 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 1/4] mm/zsmalloc: Prepare to variable MAX_PHYSMEM_BITS
Message-ID: <20171021083210.njqhsc3wlhkh5g34@node.shutemov.name>
References: <20171020195934.32108-1-kirill.shutemov@linux.intel.com>
 <20171020195934.32108-2-kirill.shutemov@linux.intel.com>
 <CAPkvG_cyvK9ds6_L2MWmFBwuzOa0jabiKr6KmVetVWOZOTX=Fg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAPkvG_cyvK9ds6_L2MWmFBwuzOa0jabiKr6KmVetVWOZOTX=Fg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nitin Gupta <ngupta@vflare.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Minchan Kim <minchan@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On Fri, Oct 20, 2017 at 06:43:55PM -0700, Nitin Gupta wrote:
> On Fri, Oct 20, 2017 at 12:59 PM, Kirill A. Shutemov
> <kirill.shutemov@linux.intel.com> wrote:
> > With boot-time switching between paging mode we will have variable
> > MAX_PHYSMEM_BITS.
> >
> > Let's use the maximum variable possible for CONFIG_X86_5LEVEL=y
> > configuration to define zsmalloc data structures.
> >
> > The patch introduces MAX_POSSIBLE_PHYSMEM_BITS to cover such case.
> > It also suits well to handle PAE special case.
> >
> 
> 
> I see that with your upcoming patch, MAX_PHYSMEM_BITS is turned into a
> variable for x86_64 case as: (pgtable_l5_enabled ? 52 : 46).
> 
> Even with this change, I don't see a need for this new
> MAX_POSSIBLE_PHYSMEM_BITS constant.

This is the error, I'm talking about:

mm/zsmalloc.c:249:21: error: variably modified a??size_classa?? at file scope
  struct size_class *size_class[ZS_SIZE_CLASSES];

ZS_SIZE_CLASSES
  ZS_MIN_ALLOC_SIZE
    OBJ_INDEX_BITS
      _PFN_BITS
        MAX_PHYSMEM_BITS
	  (pgtable_l5_enabled ? 52 : 46)

Check without the patch and full patchset applied.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
