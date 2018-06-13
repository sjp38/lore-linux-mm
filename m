Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8E12E6B0003
	for <linux-mm@kvack.org>; Wed, 13 Jun 2018 16:14:01 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id d20-v6so1794974pfn.16
        for <linux-mm@kvack.org>; Wed, 13 Jun 2018 13:14:01 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id u13-v6si3361751pfh.282.2018.06.13.13.14.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jun 2018 13:14:00 -0700 (PDT)
Date: Wed, 13 Jun 2018 23:13:56 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCHv3 01/17] mm: Do no merge VMAs with different encryption
 KeyIDs
Message-ID: <20180613201356.cupmlkfllo4ql7hq@black.fi.intel.com>
References: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
 <20180612143915.68065-2-kirill.shutemov@linux.intel.com>
 <090170d5-44a7-9bd6-2287-c1f9f87f536f@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <090170d5-44a7-9bd6-2287-c1f9f87f536f@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Jun 13, 2018 at 05:45:24PM +0000, Dave Hansen wrote:
> On 06/12/2018 07:38 AM, Kirill A. Shutemov wrote:
> > VMAs with different KeyID do not mix together. Only VMAs with the same
> > KeyID are compatible.
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > ---
> >  include/linux/mm.h | 7 +++++++
> >  mm/mmap.c          | 3 ++-
> >  2 files changed, 9 insertions(+), 1 deletion(-)
> > 
> > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > index 02a616e2f17d..1c3c15f37ed6 100644
> > --- a/include/linux/mm.h
> > +++ b/include/linux/mm.h
> > @@ -1492,6 +1492,13 @@ static inline bool vma_is_anonymous(struct vm_area_struct *vma)
> >  	return !vma->vm_ops;
> >  }
> >  
> > +#ifndef vma_keyid
> > +static inline int vma_keyid(struct vm_area_struct *vma)
> > +{
> > +	return 0;
> > +}
> > +#endif
> 
> I'm generally not a fan of this #ifdef'ing method.  It makes it hard to
> figure out who is supposed to define it, and it's also substantially
> more fragile in the face of #include ordering.
> 
> I'd much rather see some Kconfig involvement, like
> CONFIG_ARCH_HAS_MEM_ENCRYPTION or something.

Well, it's matter of taste, I guess. I do prefer per-function #ifdef'ing.
It seems more flexible to me.

I can rework it if maintainers prefer to see config option instead.

-- 
 Kirill A. Shutemov
