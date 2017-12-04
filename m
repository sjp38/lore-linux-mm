Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 179C66B0033
	for <linux-mm@kvack.org>; Mon,  4 Dec 2017 09:57:59 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id f4so10438524wre.9
        for <linux-mm@kvack.org>; Mon, 04 Dec 2017 06:57:59 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a9sor7055843edn.5.2017.12.04.06.57.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 04 Dec 2017 06:57:57 -0800 (PST)
Date: Mon, 4 Dec 2017 17:57:55 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] x86/mm: Rewrite sme_populate_pgd() in a more sensible way
Message-ID: <20171204145755.6xu2w6a6og56rq5v@node.shutemov.name>
References: <20171204112323.47019-1-kirill.shutemov@linux.intel.com>
 <d177df77-cdc7-1507-08f8-fcdb3b443709@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d177df77-cdc7-1507-08f8-fcdb3b443709@amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Borislav Petkov <bp@suse.de>, Brijesh Singh <brijesh.singh@amd.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Dec 04, 2017 at 08:19:11AM -0600, Tom Lendacky wrote:
> On 12/4/2017 5:23 AM, Kirill A. Shutemov wrote:
> > sme_populate_pgd() open-codes a lot of things that are not needed to be
> > open-coded.
> > 
> > Let's rewrite it in a more stream-lined way.
> > 
> > This would also buy us boot-time switching between support between
> > paging modes, when rest of the pieces will be upstream.
> 
> Hi Kirill,
> 
> Unfortunately, some of these can't be changed.  The use of p4d_offset(),
> pud_offset(), etc., use non-identity mapped virtual addresses which cause
> failures at this point of the boot process.

Wat? Virtual address is virtual address. p?d_offset() doesn't care about
what mapping you're using.

> Also, calls such as __p4d(), __pud(), etc., are part of the paravirt
> support and can't be used yet, either. 

Yeah, I missed this. native_make_p?d() has to be used instead.

> I can take a closer look at some of the others (p*d_none() and
> p*d_large()) which make use of the native_ macros, but my worry would be
> that these get changed in the future to the non-native calls and then
> boot failures occur.

If you want to avoid paravirt altogher for whole compilation unit, one
more option would be to put #undef CONFIG_PARAVIRT before all includes.
That's hack, but it works. We already use this in arch/x86/boot/compressed
code.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
