Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f170.google.com (mail-yk0-f170.google.com [209.85.160.170])
	by kanga.kvack.org (Postfix) with ESMTP id DE0176B0038
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 14:57:56 -0500 (EST)
Received: by ykfs79 with SMTP id s79so60576925ykf.1
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 11:57:56 -0800 (PST)
Received: from mail-yk0-x22f.google.com (mail-yk0-x22f.google.com. [2607:f8b0:4002:c07::22f])
        by mx.google.com with ESMTPS id i129si2909628ywb.311.2015.12.02.11.57.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Dec 2015 11:57:56 -0800 (PST)
Received: by ykfs79 with SMTP id s79so60576631ykf.1
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 11:57:56 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1449087125.31589.45.camel@hpe.com>
References: <1448309082-20851-1-git-send-email-toshi.kani@hpe.com>
	<CAPcyv4gY2SZZwiv9DtjRk4js3gS=vf4YLJvmsMJ196aps4ZHcQ@mail.gmail.com>
	<1449022764.31589.24.camel@hpe.com>
	<CAPcyv4hzjMkwx3AA+f5Y9zfp-egjO-b5+_EU7cGO5BGMQaiN_g@mail.gmail.com>
	<1449078237.31589.30.camel@hpe.com>
	<CAPcyv4ikJ73nzQTCOfnBRThkv=rZGPM76S7=6O3LSB4kQBeEpw@mail.gmail.com>
	<CAPcyv4j1vA6eAtjsE=kGKeF1EqWWfR+NC7nUcRpfH_8MRqpM8Q@mail.gmail.com>
	<1449084362.31589.37.camel@hpe.com>
	<CAPcyv4jt7JmWCgcsd=p32M322sCyaar4Pj-k+F446XGZvzrO8A@mail.gmail.com>
	<1449086521.31589.39.camel@hpe.com>
	<1449087125.31589.45.camel@hpe.com>
Date: Wed, 2 Dec 2015 11:57:55 -0800
Message-ID: <CAPcyv4hvX_s3xN9UZ69v7npOhWVFehfGDPZG1MsDmKWBk4Gq1A@mail.gmail.com>
Subject: Re: [PATCH] mm: Fix mmap MAP_POPULATE for DAX pmd mapping
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hpe.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, mauricio.porto@hpe.com, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, Dec 2, 2015 at 12:12 PM, Toshi Kani <toshi.kani@hpe.com> wrote:
> On Wed, 2015-12-02 at 13:02 -0700, Toshi Kani wrote:
>> On Wed, 2015-12-02 at 11:00 -0800, Dan Williams wrote:
>> > On Wed, Dec 2, 2015 at 11:26 AM, Toshi Kani <toshi.kani@hpe.com> wrote:
>> > > On Wed, 2015-12-02 at 10:06 -0800, Dan Williams wrote:
>> > > > On Wed, Dec 2, 2015 at 9:01 AM, Dan Williams <dan.j.williams@intel.com>
>> > > > wrote:
>> > > > > On Wed, Dec 2, 2015 at 9:43 AM, Toshi Kani <toshi.kani@hpe.com> wrote:
>> > > > > > Oh, I see.  I will setup the memmap array and run the tests again.
>> > > > > >
>> > > > > > But, why does the PMD mapping depend on the memmap array?  We have
>> > > > > > observed major performance improvement with PMD.  This feature
>> > > > > > should always be enabled with DAX regardless of the option to
>> > > > > > allocate the memmap array.
>> > > > > >
>> > > > >
>> > > > > Several factors drove this decision, I'm open to considering
>> > > > > alternatives but here's the reasoning:
>> > > > >
>> > > > > 1/ DAX pmd mappings caused crashes in the get_user_pages path leading
>> > > > > to commit e82c9ed41e8 "dax: disable pmd mappings".  The reason pte
>> > > > > mappings don't crash and instead trigger -EFAULT is due to the
>> > > > > _PAGE_SPECIAL pte bit.
>> > > > >
>> > > > > 2/ To enable get_user_pages for DAX, in both the page and huge-page
>> > > > > case, we need a new pte bit _PAGE_DEVMAP.
>> > > > >
>> > > > > 3/ Given the pte bits are hard to come I'm assuming we won't get two,
>> > > > > i.e. both _PAGE_DEVMAP and a new _PAGE_SPECIAL for pmds.  Even if we
>> > > > > could get a _PAGE_SPECIAL for pmds I'm not in favor of pursuing it.
>> > > >
>> > > > Actually, Dave says they aren't that hard to come by for pmds, so we
>> > > > could go add _PMD_SPECIAL if we really wanted to support the limited
>> > > > page-less DAX-pmd case.
>> > > >
>> > > > But I'm still of the opinion that we run away from the page-less case
>> > > > until it can be made a full class citizen with O_DIRECT for pfn
>> > > > support.
>> > >
>> > > I may be missing something, but per vm_normal_page(), I think
>> > > _PAGE_SPECIAL can be substituted by the following check when we do not
>> > > have the memmap.
>> > >
>> > >         if ((vma->vm_flags & VM_PFNMAP) ||
>> > >             ((vma->vm_flags & VM_MIXEDMAP) && (!pfn_valid(pfn)))) {
>> > >
>> > > This is what I did in this patch for follow_trans_huge_pmd(), although I
>> > > missed the pfn_valid() check.
>> >
>> > That works for __get_user_pages but not __get_user_pages_fast where we
>> > don't have access to the vma.
>>
>> __get_user_page_fast already refers current->mm, so we should be able to get
>> the vma, and pass it down to gup_pud_range().
>
> Alternatively, we can obtain the vma from current->mm in gup_huge_pmd() when the
> !pfn_valid() condition is met, so that we do not add the code to the main path
> of __get_user_pages_fast.

The whole point of __get_user_page_fast() is to avoid the overhead of
taking the mm semaphore to access the vma.  _PAGE_SPECIAL simply tells
__get_user_pages_fast that it needs to fallback to the
__get_user_pages slow path.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
