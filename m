Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5C83D6B000A
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 03:39:08 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id p13so5765890wmc.6
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 00:39:08 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p54sor234604edc.22.2018.03.06.00.39.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Mar 2018 00:39:07 -0800 (PST)
Date: Tue, 6 Mar 2018 11:38:51 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC, PATCH 19/22] x86/mm: Implement free_encrypt_page()
Message-ID: <20180306083851.g5yh6f66srvrtc5n@node.shutemov.name>
References: <20180305162610.37510-1-kirill.shutemov@linux.intel.com>
 <20180305162610.37510-20-kirill.shutemov@linux.intel.com>
 <f9129b50-9231-abfd-9eb2-5eecad7e220d@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f9129b50-9231-abfd-9eb2-5eecad7e220d@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Mar 05, 2018 at 11:00:00AM -0800, Dave Hansen wrote:
> On 03/05/2018 08:26 AM, Kirill A. Shutemov wrote:
> > +void free_encrypt_page(struct page *page, int keyid, unsigned int order)
> > +{
> > +	int i;
> > +	void *v;
> > +
> > +	for (i = 0; i < (1 << order); i++) {
> > +		v = kmap_atomic_keyid(page, keyid + i);
> > +		/* See comment in prep_encrypt_page() */
> > +		clflush_cache_range(v, PAGE_SIZE);
> > +		kunmap_atomic(v);
> > +	}
> > +}
> 
> Did you miss adding the call sites for this?

No. It is in "mm, rmap: Free encrypted pages once mapcount drops to zero".
But the call is optimized out since anon_vma_encrypted() is always false
so far.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
