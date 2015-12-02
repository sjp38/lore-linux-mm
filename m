Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f48.google.com (mail-oi0-f48.google.com [209.85.218.48])
	by kanga.kvack.org (Postfix) with ESMTP id D7DC86B0038
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 14:07:00 -0500 (EST)
Received: by oiww189 with SMTP id w189so30868098oiw.3
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 11:07:00 -0800 (PST)
Received: from g4t3426.houston.hp.com (g4t3426.houston.hp.com. [15.201.208.54])
        by mx.google.com with ESMTPS id x140si4524246oif.123.2015.12.02.11.07.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Dec 2015 11:07:00 -0800 (PST)
Message-ID: <1449086521.31589.39.camel@hpe.com>
Subject: Re: [PATCH] mm: Fix mmap MAP_POPULATE for DAX pmd mapping
From: Toshi Kani <toshi.kani@hpe.com>
Date: Wed, 02 Dec 2015 13:02:01 -0700
In-Reply-To: <CAPcyv4jt7JmWCgcsd=p32M322sCyaar4Pj-k+F446XGZvzrO8A@mail.gmail.com>
References: <1448309082-20851-1-git-send-email-toshi.kani@hpe.com>
	 <CAPcyv4gY2SZZwiv9DtjRk4js3gS=vf4YLJvmsMJ196aps4ZHcQ@mail.gmail.com>
	 <1449022764.31589.24.camel@hpe.com>
	 <CAPcyv4hzjMkwx3AA+f5Y9zfp-egjO-b5+_EU7cGO5BGMQaiN_g@mail.gmail.com>
	 <1449078237.31589.30.camel@hpe.com>
	 <CAPcyv4ikJ73nzQTCOfnBRThkv=rZGPM76S7=6O3LSB4kQBeEpw@mail.gmail.com>
	 <CAPcyv4j1vA6eAtjsE=kGKeF1EqWWfR+NC7nUcRpfH_8MRqpM8Q@mail.gmail.com>
	 <1449084362.31589.37.camel@hpe.com>
	 <CAPcyv4jt7JmWCgcsd=p32M322sCyaar4Pj-k+F446XGZvzrO8A@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, mauricio.porto@hpe.com, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, 2015-12-02 at 11:00 -0800, Dan Williams wrote:
> On Wed, Dec 2, 2015 at 11:26 AM, Toshi Kani <toshi.kani@hpe.com> wrote:
> > On Wed, 2015-12-02 at 10:06 -0800, Dan Williams wrote:
> > > On Wed, Dec 2, 2015 at 9:01 AM, Dan Williams <dan.j.williams@intel.com>
> > > wrote:
> > > > On Wed, Dec 2, 2015 at 9:43 AM, Toshi Kani <toshi.kani@hpe.com> wrote:
> > > > > Oh, I see.  I will setup the memmap array and run the tests again.
> > > > > 
> > > > > But, why does the PMD mapping depend on the memmap array?  We have
> > > > > observed major performance improvement with PMD.  This feature should
> > > > > always be enabled with DAX regardless of the option to allocate the
> > > > > memmap
> > > > > array.
> > > > > 
> > > > 
> > > > Several factors drove this decision, I'm open to considering
> > > > alternatives but here's the reasoning:
> > > > 
> > > > 1/ DAX pmd mappings caused crashes in the get_user_pages path leading
> > > > to commit e82c9ed41e8 "dax: disable pmd mappings".  The reason pte
> > > > mappings don't crash and instead trigger -EFAULT is due to the
> > > > _PAGE_SPECIAL pte bit.
> > > > 
> > > > 2/ To enable get_user_pages for DAX, in both the page and huge-page
> > > > case, we need a new pte bit _PAGE_DEVMAP.
> > > > 
> > > > 3/ Given the pte bits are hard to come I'm assuming we won't get two,
> > > > i.e. both _PAGE_DEVMAP and a new _PAGE_SPECIAL for pmds.  Even if we
> > > > could get a _PAGE_SPECIAL for pmds I'm not in favor of pursuing it.
> > > 
> > > Actually, Dave says they aren't that hard to come by for pmds, so we
> > > could go add _PMD_SPECIAL if we really wanted to support the limited
> > > page-less DAX-pmd case.
> > > 
> > > But I'm still of the opinion that we run away from the page-less case
> > > until it can be made a full class citizen with O_DIRECT for pfn
> > > support.
> > 
> > I may be missing something, but per vm_normal_page(), I think _PAGE_SPECIAL
> > can
> > be substituted by the following check when we do not have the memmap.
> > 
> >         if ((vma->vm_flags & VM_PFNMAP) ||
> >             ((vma->vm_flags & VM_MIXEDMAP) && (!pfn_valid(pfn)))) {
> > 
> > This is what I did in this patch for follow_trans_huge_pmd(), although I
> > missed
> > the pfn_valid() check.
> 
> That works for __get_user_pages but not __get_user_pages_fast where we
> don't have access to the vma.

__get_user_page_fast already refers current->mm, so we should be able to get the
vma, and pass it down to gup_pud_range().

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
