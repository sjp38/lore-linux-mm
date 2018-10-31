Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id A02536B02C2
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 05:35:45 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id w126-v6so11608562oib.18
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 02:35:45 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id t32si7172046otc.126.2018.10.31.02.35.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Oct 2018 02:35:44 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w9V9YrUG145800
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 05:35:44 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2nf9he8yv6-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 05:35:43 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Wed, 31 Oct 2018 09:35:42 -0000
Date: Wed, 31 Oct 2018 10:35:36 +0100
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH 1/3] mm: introduce mm_[p4d|pud|pmd]_folded
In-Reply-To: <20181031090255.bvmp3jnsdaunhzn7@kshutemo-mobl1>
References: <1539621759-5967-1-git-send-email-schwidefsky@de.ibm.com>
	<1539621759-5967-2-git-send-email-schwidefsky@de.ibm.com>
	<20181031090255.bvmp3jnsdaunhzn7@kshutemo-mobl1>
MIME-Version: 1.0
Message-Id: <20181031103536.0cab673d@mschwideX1>
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Li Wang <liwang@redhat.com>, Guenter Roeck <linux@roeck-us.net>, Janosch Frank <frankja@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Wed, 31 Oct 2018 12:02:55 +0300
"Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> On Mon, Oct 15, 2018 at 06:42:37PM +0200, Martin Schwidefsky wrote:
> > Add three architecture overrideable function to test if the
> > p4d, pud, or pmd layer of a page table is folded or not.
> > 
> > Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
> > ---
> >  include/linux/mm.h | 40 ++++++++++++++++++++++++++++++++++++++++
> >  1 file changed, 40 insertions(+)
> > 
> > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > index 0416a7204be3..d1029972541c 100644
> > --- a/include/linux/mm.h
> > +++ b/include/linux/mm.h  
> 
> Shouldn't it be somewhere in asm-generic/pgtable*?

If you prefer the definitions in asm-generic that is fine with me.
I'll give it a try to see if it still compiles.

> > @@ -105,6 +105,46 @@ extern int mmap_rnd_compat_bits __read_mostly;
> >  #define mm_zero_struct_page(pp)  ((void)memset((pp), 0, sizeof(struct page)))
> >  #endif
> >  
> > +/*
> > + * On some architectures it depends on the mm if the p4d/pud or pmd
> > + * layer of the page table hierarchy is folded or not.
> > + */
> > +#ifndef mm_p4d_folded
> > +#define mm_p4d_folded(mm) mm_p4d_folded(mm)  
> 
> Do we need to define it in generic header?

That is true, it should work without the #define in the generic header.

> > +static inline bool mm_p4d_folded(struct mm_struct *mm)
> > +{
> > +#ifdef __PAGETABLE_P4D_FOLDED
> > +	return 1;
> > +#else
> > +	return 0;
> > +#endif  
> 
> Maybe
> 	return __is_defined(__PAGETABLE_P4D_FOLDED);
> 
> ?
 
I have tried that, doesn't work. The reason is that the
__PAGETABLE_xxx_FOLDED defines to not have a value.

#define __PAGETABLE_P4D_FOLDED
#define __PAGETABLE_PMD_FOLDED
#define __PAGETABLE_PUD_FOLDED

While the definition of CONFIG_xxx symbols looks like this

#define CONFIG_xxx 1

The __is_defined needs the value for the __take_second_arg trick.

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.
