Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 0FB6D6B0255
	for <linux-mm@kvack.org>; Mon,  9 Nov 2015 15:10:58 -0500 (EST)
Received: by wmec201 with SMTP id c201so99577033wme.0
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 12:10:57 -0800 (PST)
Received: from mail-wm0-x234.google.com (mail-wm0-x234.google.com. [2a00:1450:400c:c09::234])
        by mx.google.com with ESMTPS id p131si18830794wmd.100.2015.11.09.12.10.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Nov 2015 12:10:56 -0800 (PST)
Received: by wmec201 with SMTP id c201so99576307wme.0
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 12:10:56 -0800 (PST)
Date: Mon, 9 Nov 2015 22:10:55 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v4 RESEND 4/11] x86/asm: Fix pud/pmd interfaces to handle
 large PAT bit
Message-ID: <20151109201054.GA5443@node.shutemov.name>
References: <1442514264-12475-1-git-send-email-toshi.kani@hpe.com>
 <1442514264-12475-5-git-send-email-toshi.kani@hpe.com>
 <5640E08F.5020206@oracle.com>
 <1447096601.21443.15.camel@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1447096601.21443.15.camel@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hpe.com>
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, bp@alien8.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, jgross@suse.com, konrad.wilk@oracle.com, elliott@hpe.com

On Mon, Nov 09, 2015 at 12:16:41PM -0700, Toshi Kani wrote:
> On Mon, 2015-11-09 at 13:06 -0500, Boris Ostrovsky wrote:
> > On 09/17/2015 02:24 PM, Toshi Kani wrote:
> > > Now that we have pud/pmd mask interfaces, which handle pfn & flags
> > > mask properly for the large PAT bit.
> > > 
> > > Fix pud/pmd pfn & flags interfaces by replacing PTE_PFN_MASK and
> > > PTE_FLAGS_MASK with the pud/pmd mask interfaces.
> > > 
> > > Suggested-by: Juergen Gross <jgross@suse.com>
> > > Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
> > > Cc: Juergen Gross <jgross@suse.com>
> > > Cc: Konrad Wilk <konrad.wilk@oracle.com>
> > > Cc: Thomas Gleixner <tglx@linutronix.de>
> > > Cc: H. Peter Anvin <hpa@zytor.com>
> > > Cc: Ingo Molnar <mingo@redhat.com>
> > > Cc: Borislav Petkov <bp@alien8.de>
> > > ---
> > >   arch/x86/include/asm/pgtable.h       |   14 ++++++++------
> > >   arch/x86/include/asm/pgtable_types.h |    4 ++--
> > >   2 files changed, 10 insertions(+), 8 deletions(-)
> > > 
> > 
> > 
> > Looks like this commit is causing this splat for 32-bit kernels. I am 
> > attaching my config file, just in case.
> 
> Thanks for the report!  I'd like to reproduce the issue since I am not sure how
> this change caused it...
> 
> I tried to build a kernel with the attached config file, and got the following
> error.  Not sure what I am missing.  

The problem is that PMD_PAGE_MASK as well as PUD_PAGE_MASK are 'unsigned
long', not 'unsigned long long'. So on 32-bit with PAE enabled your
pmd_pfn_mask()/pud_pfn_mask() will truncate bits 32..43 of pmd/pudval and
you'll never get proper page frame for pages above 4G.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
