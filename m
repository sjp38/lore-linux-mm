Return-Path: <SRS0=c8nW=TE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 23B61C43219
	for <linux-mm@archiver.kernel.org>; Sat,  4 May 2019 19:40:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 97D4820652
	for <linux-mm@archiver.kernel.org>; Sat,  4 May 2019 19:40:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="BLXpH5+g"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 97D4820652
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 16E636B0003; Sat,  4 May 2019 15:40:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 122596B0006; Sat,  4 May 2019 15:40:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F293F6B0007; Sat,  4 May 2019 15:40:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8AFE96B0003
	for <linux-mm@kvack.org>; Sat,  4 May 2019 15:40:22 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id h12so7490644edl.23
        for <linux-mm@kvack.org>; Sat, 04 May 2019 12:40:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Ce5vpv+5ZXGpxa3lgMdpi8rpCOiWb2UyQ6xRgbfBrHw=;
        b=ZVI2djrwbvZyKtKXdPRXTquJYPgemArNRf8o1jveuqGE4v1ZctZHDXKSYPKjvkm8c0
         RcrRmKEebt8vCq/YTYVK7WfSXQw8Az9IygpXF/lCIoN72/2lr22LWqGD1nBXgTBFgau2
         bH9O/l7dbZrSCDamXU5VBzsMyOjLPq0oPmAhBETFUM9XA1LPFRku+/6nZOEo2EzOjiZ7
         rgMSLS3r+bnRmWSJLSwE1hMrY6kqG8/vxkpphoqm71FxTj0S6D1tzKoYVmAqLwS3/RFG
         McQrEUr1xKaX6aEYmzT0SvhceDUI8qDKrDicFkB5VOQDtX3U6yvBgYtFxK8pQ27f9/G0
         OcRQ==
X-Gm-Message-State: APjAAAUwrsfsqbsEMTccNERf2Kv3vip9HD+Eivcds66Cztd1m6tRRAk7
	HLQFCXN0WJFCh/6X67DjLgPnwDzw+d2fOZMd4uunawV/Nj58B874K2VQ2s87UyKUSv5+i/6nggY
	G2bo2/aYEqlWfZ+8mzrj57ZqmjFawvdf1LFpxWKNkS5CcASv+6rozB8joILbrQd9jlg==
X-Received: by 2002:a17:906:7d08:: with SMTP id u8mr11864355ejo.1.1556998822089;
        Sat, 04 May 2019 12:40:22 -0700 (PDT)
X-Received: by 2002:a17:906:7d08:: with SMTP id u8mr11864307ejo.1.1556998820848;
        Sat, 04 May 2019 12:40:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556998820; cv=none;
        d=google.com; s=arc-20160816;
        b=PXYX6vdOFl8JmfZQOpWeTTr2bqG1cjUDJZ6bkZvqPStz3O3x6lDSClq0v1elJKs7n3
         X9reRXU7QxpPvYZY5esDY93jXBwzMKbBhdCgwEqo0ptOBHqAvQ5kyGVkJcYmLFbOHJ/z
         WVONbbHe7mHDO0o7N1AE1UJ0ZK4ErqiB0vswDvPbpxEyeue0PlzpvTqH7pZB3sHrvYVY
         Xw7LdWTB2ewINv6Dbb4oKt4RvvDBdxaqYo81K9KJWdpOU7GtZnO1DG2+j5m55P5rWo1w
         dZzRvv/aAXwwDDlJZQtpPhtq8x+aZ62UKMFdmvsdZPKoBxggxSr0h9uEaN6jqZnfIeh/
         ae2g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Ce5vpv+5ZXGpxa3lgMdpi8rpCOiWb2UyQ6xRgbfBrHw=;
        b=m1I1erS76hKyjQaLCUkD88mZVcOigzfjBLHb/lITC579kpam4wvo79qvHyCcJmrvRg
         cGrie9vE4w/cIE4Wk2Vux2NNxtJelOu3cPLUbucY86hoCCSQ8Ww0fNKhr92+z0xP5Ua1
         RvwP6tvWR3FL0IQvrVG0GuDlX/KPJ6uyRpA+QhPLkEp7J95ZqQhMdtVejPCBwHa/ZOOr
         8HyNKglSf4YzRZ8iVEN5FLAFnnWlJsKL5E8Q4PH+KYmHsqLHg7y5H3tXHnyRGTMpJw3T
         iMI1uhNSBXhTnHumGRAosIRZHdgc2vKHeA0DXy97Aa/qWTjCEADmMb8k+nFTyiJ5/2bF
         WrIw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=BLXpH5+g;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i7sor590566ede.8.2019.05.04.12.40.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 04 May 2019 12:40:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=BLXpH5+g;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Ce5vpv+5ZXGpxa3lgMdpi8rpCOiWb2UyQ6xRgbfBrHw=;
        b=BLXpH5+gTls+UjjGmDTy2FR/p68KitDeI320srTaxdL2w3OBd9QKKJP2YLuNMkY2+9
         yJWZHOg9nSv7TkbaJEd6meeP7fRBb0nYjFKeeqlqsc9k+UoMS1MQfrdsHgyy4UQxq7Ge
         wX7DzOMBZfkrqZEKJTbnETLo25QpaPNzSIIyCywMyLlXoq0uwuA8Ini/EGpWc8SbLJhD
         b8JUTY/DZjiZNrxI34yek6wYvqi1BMjx9XuNWRa8C/yrX+Yj2Mkpllf1WLze53HSlQur
         1yg4RCZLUYbE5pCCyVdDbuS1DnbCEszfJrAOYUAVDJb3xZ85IdD/t+tkGFzJOv9cLTfb
         xjog==
X-Google-Smtp-Source: APXvYqwOFF9HU+jMy+hBb2/lgsHqjnT3bBcNAAUTBNAKvnayHQXnRxCcMUzavHhLNXrDnEsmIYiRNcMVsEG0ILPTuPk=
X-Received: by 2002:a50:f5ad:: with SMTP id u42mr16693281edm.17.1556998820421;
 Sat, 04 May 2019 12:40:20 -0700 (PDT)
MIME-Version: 1.0
References: <155552633539.2015392.2477781120122237934.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155552635098.2015392.5460028594173939000.stgit@dwillia2-desk3.amr.corp.intel.com>
 <CA+CK2bAfnCVYz956jPTNQ+AqHJs7uY1ZqWfL8fSUFWQOdKxHcg@mail.gmail.com> <CAPcyv4hH2733FEs4bAroa4zscM_PkshEWEmRw7LwXwVJb9pDWg@mail.gmail.com>
In-Reply-To: <CAPcyv4hH2733FEs4bAroa4zscM_PkshEWEmRw7LwXwVJb9pDWg@mail.gmail.com>
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Date: Sat, 4 May 2019 15:40:08 -0400
Message-ID: <CA+CK2bCghkGDsHAW=wqw89NRXXp574kCcBjMtR8n-U0UYpofMQ@mail.gmail.com>
Subject: Re: [PATCH v6 03/12] mm/sparsemem: Add helpers track active portions
 of a section at boot
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, 
	Vlastimil Babka <vbabka@suse.cz>, Logan Gunthorpe <logang@deltatee.com>, linux-mm <linux-mm@kvack.org>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>, LKML <linux-kernel@vger.kernel.org>, 
	David Hildenbrand <david@redhat.com>
Content-Type: multipart/alternative; boundary="0000000000009b73a205881509d8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--0000000000009b73a205881509d8
Content-Type: text/plain; charset="UTF-8"

On Sat, May 4, 2019, 3:26 PM Dan Williams <dan.j.williams@intel.com> wrote:

> On Thu, May 2, 2019 at 9:12 AM Pavel Tatashin <pasha.tatashin@soleen.com>
> wrote:
> >
> > On Wed, Apr 17, 2019 at 2:53 PM Dan Williams <dan.j.williams@intel.com>
> wrote:
> > >
> > > Prepare for hot{plug,remove} of sub-ranges of a section by tracking a
> > > section active bitmask, each bit representing 2MB (SECTION_SIZE (128M)
> /
> > > map_active bitmask length (64)). If it turns out that 2MB is too large
> > > of an active tracking granularity it is trivial to increase the size of
> > > the map_active bitmap.
> >
> > Please mention that 2M on Intel, and 16M on Arm64.
> >
> > >
> > > The implications of a partially populated section is that pfn_valid()
> > > needs to go beyond a valid_section() check and read the sub-section
> > > active ranges from the bitmask.
> > >
> > > Cc: Michal Hocko <mhocko@suse.com>
> > > Cc: Vlastimil Babka <vbabka@suse.cz>
> > > Cc: Logan Gunthorpe <logang@deltatee.com>
> > > Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> > > ---
> > >  include/linux/mmzone.h |   29 ++++++++++++++++++++++++++++-
> > >  mm/page_alloc.c        |    4 +++-
> > >  mm/sparse.c            |   48
> ++++++++++++++++++++++++++++++++++++++++++++++++
> > >  3 files changed, 79 insertions(+), 2 deletions(-)
> > >
> > > diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> > > index 6726fc175b51..cffde898e345 100644
> > > --- a/include/linux/mmzone.h
> > > +++ b/include/linux/mmzone.h
> > > @@ -1175,6 +1175,8 @@ struct mem_section_usage {
> > >         unsigned long pageblock_flags[0];
> > >  };
> > >
> > > +void section_active_init(unsigned long pfn, unsigned long nr_pages);
> > > +
> > >  struct page;
> > >  struct page_ext;
> > >  struct mem_section {
> > > @@ -1312,12 +1314,36 @@ static inline struct mem_section
> *__pfn_to_section(unsigned long pfn)
> > >
> > >  extern int __highest_present_section_nr;
> > >
> > > +static inline int section_active_index(phys_addr_t phys)
> > > +{
> > > +       return (phys & ~(PA_SECTION_MASK)) / SECTION_ACTIVE_SIZE;
> >
> > How about also defining SECTION_ACTIVE_SHIFT like this:
> >
> > /* BITS_PER_LONG = 2^6 */
> > #define BITS_PER_LONG_SHIFT 6
> > #define SECTION_ACTIVE_SHIFT (SECTION_SIZE_BITS - BITS_PER_LONG_SHIFT)
> > #define SECTION_ACTIVE_SIZE (1 << SECTION_ACTIVE_SHIFT)
> >
> > The return above would become:
> > return (phys & ~(PA_SECTION_MASK)) >> SECTION_ACTIVE_SHIFT;
> >
> > > +}
> > > +
> > > +#ifdef CONFIG_SPARSEMEM_VMEMMAP
> > > +static inline int pfn_section_valid(struct mem_section *ms, unsigned
> long pfn)
> > > +{
> > > +       int idx = section_active_index(PFN_PHYS(pfn));
> > > +
> > > +       return !!(ms->usage->map_active & (1UL << idx));
> > > +}
> > > +#else
> > > +static inline int pfn_section_valid(struct mem_section *ms, unsigned
> long pfn)
> > > +{
> > > +       return 1;
> > > +}
> > > +#endif
> > > +
> > >  #ifndef CONFIG_HAVE_ARCH_PFN_VALID
> > >  static inline int pfn_valid(unsigned long pfn)
> > >  {
> > > +       struct mem_section *ms;
> > > +
> > >         if (pfn_to_section_nr(pfn) >= NR_MEM_SECTIONS)
> > >                 return 0;
> > > -       return valid_section(__nr_to_section(pfn_to_section_nr(pfn)));
> > > +       ms = __nr_to_section(pfn_to_section_nr(pfn));
> > > +       if (!valid_section(ms))
> > > +               return 0;
> > > +       return pfn_section_valid(ms, pfn);
> > >  }
> > >  #endif
> > >
> > > @@ -1349,6 +1375,7 @@ void sparse_init(void);
> > >  #define sparse_init()  do {} while (0)
> > >  #define sparse_index_init(_sec, _nid)  do {} while (0)
> > >  #define pfn_present pfn_valid
> > > +#define section_active_init(_pfn, _nr_pages) do {} while (0)
> > >  #endif /* CONFIG_SPARSEMEM */
> > >
> > >  /*
> > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > index f671401a7c0b..c9ad28a78018 100644
> > > --- a/mm/page_alloc.c
> > > +++ b/mm/page_alloc.c
> > > @@ -7273,10 +7273,12 @@ void __init free_area_init_nodes(unsigned long
> *max_zone_pfn)
> > >
> > >         /* Print out the early node map */
> > >         pr_info("Early memory node ranges\n");
> > > -       for_each_mem_pfn_range(i, MAX_NUMNODES, &start_pfn, &end_pfn,
> &nid)
> > > +       for_each_mem_pfn_range(i, MAX_NUMNODES, &start_pfn, &end_pfn,
> &nid) {
> > >                 pr_info("  node %3d: [mem %#018Lx-%#018Lx]\n", nid,
> > >                         (u64)start_pfn << PAGE_SHIFT,
> > >                         ((u64)end_pfn << PAGE_SHIFT) - 1);
> > > +               section_active_init(start_pfn, end_pfn - start_pfn);
> > > +       }
> > >
> > >         /* Initialise every node */
> > >         mminit_verify_pageflags_layout();
> > > diff --git a/mm/sparse.c b/mm/sparse.c
> > > index f87de7ad32c8..5ef2f884c4e1 100644
> > > --- a/mm/sparse.c
> > > +++ b/mm/sparse.c
> > > @@ -210,6 +210,54 @@ static inline unsigned long
> first_present_section_nr(void)
> > >         return next_present_section_nr(-1);
> > >  }
> > >
> > > +static unsigned long section_active_mask(unsigned long pfn,
> > > +               unsigned long nr_pages)
> > > +{
> > > +       int idx_start, idx_size;
> > > +       phys_addr_t start, size;
> > > +
> > > +       if (!nr_pages)
> > > +               return 0;
> > > +
> > > +       start = PFN_PHYS(pfn);
> > > +       size = PFN_PHYS(min(nr_pages, PAGES_PER_SECTION
> > > +                               - (pfn & ~PAGE_SECTION_MASK)));
> > > +       size = ALIGN(size, SECTION_ACTIVE_SIZE);
> > > +
> > > +       idx_start = section_active_index(start);
> > > +       idx_size = section_active_index(size);
> > > +
> > > +       if (idx_size == 0)
> > > +               return -1;
> > > +       return ((1UL << idx_size) - 1) << idx_start;
> > > +}
> > > +
> > > +void section_active_init(unsigned long pfn, unsigned long nr_pages)
> > > +{
> > > +       int end_sec = pfn_to_section_nr(pfn + nr_pages - 1);
> > > +       int i, start_sec = pfn_to_section_nr(pfn);
> > > +
> > > +       if (!nr_pages)
> > > +               return;
> > > +
> > > +       for (i = start_sec; i <= end_sec; i++) {
> > > +               struct mem_section *ms;
> > > +               unsigned long mask;
> > > +               unsigned long pfns;
> > > +
> > > +               pfns = min(nr_pages, PAGES_PER_SECTION
> > > +                               - (pfn & ~PAGE_SECTION_MASK));
> > > +               mask = section_active_mask(pfn, pfns);
> > > +
> > > +               ms = __nr_to_section(i);
> > > +               pr_debug("%s: sec: %d mask: %#018lx\n", __func__, i,
> mask);
> > > +               ms->usage->map_active = mask;
> > > +
> > > +               pfn += pfns;
> > > +               nr_pages -= pfns;
> > > +       }
> > > +}
> >
> > For some reasons the above code is confusing to me. It seems all the
> > code supposed to do is set all map_active to -1, and trim the first
> > and last sections (can be the same section of course). So, I would
> > replace the above two functions with one function like this:
> >
> > void section_active_init(unsigned long pfn, unsigned long nr_pages)
> > {
> >         int end_sec = pfn_to_section_nr(pfn + nr_pages - 1);
> >         int i, idx, start_sec = pfn_to_section_nr(pfn);
> >         struct mem_section *ms;
> >
> >         if (!nr_pages)
> >                 return;
> >
> >         for (i = start_sec; i <= end_sec; i++) {
> >                 ms = __nr_to_section(i);
> >                 ms->usage->map_active = ~0ul;
> >         }
> >
> >         /* Might need to trim active pfns from the beginning and end */
> >         idx = section_active_index(PFN_PHYS(pfn));
> >         ms = __nr_to_section(start_sec);
> >         ms->usage->map_active &= (~0ul << idx);
> >
> >         idx = section_active_index(PFN_PHYS(pfn + nr_pages -1));
> >         ms = __nr_to_section(end_sec);
> >         ms->usage->map_active &= (~0ul >> (BITS_PER_LONG - idx - 1));
> > }
>
> I like the cleanup, but one of the fixes in v7 resulted in the
> realization that a given section may be populated twice at init time.
> For example, enabling that pr_debug() yields:
>
>     section_active_init: sec: 12 mask: 0x00000003ffffffff
>     section_active_init: sec: 12 mask: 0xe000000000000000
>
> So, the implementation can't blindly clear bits based on the current
> parameters. However, I'm switching this code over to use bitmap_*()
> helpers which should help with the readability.
>

Yes, bitmap_* will help, and I assume you will also make active_map size
scalable?

I will take another look at version 8.


Thank you,
Pasha

--0000000000009b73a205881509d8
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"auto"><div><br><br><div class=3D"gmail_quote"><div dir=3D"ltr" =
class=3D"gmail_attr">On Sat, May 4, 2019, 3:26 PM Dan Williams &lt;<a href=
=3D"mailto:dan.j.williams@intel.com">dan.j.williams@intel.com</a>&gt; wrote=
:<br></div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;bor=
der-left:1px #ccc solid;padding-left:1ex">On Thu, May 2, 2019 at 9:12 AM Pa=
vel Tatashin &lt;<a href=3D"mailto:pasha.tatashin@soleen.com" target=3D"_bl=
ank" rel=3D"noreferrer">pasha.tatashin@soleen.com</a>&gt; wrote:<br>
&gt;<br>
&gt; On Wed, Apr 17, 2019 at 2:53 PM Dan Williams &lt;<a href=3D"mailto:dan=
.j.williams@intel.com" target=3D"_blank" rel=3D"noreferrer">dan.j.williams@=
intel.com</a>&gt; wrote:<br>
&gt; &gt;<br>
&gt; &gt; Prepare for hot{plug,remove} of sub-ranges of a section by tracki=
ng a<br>
&gt; &gt; section active bitmask, each bit representing 2MB (SECTION_SIZE (=
128M) /<br>
&gt; &gt; map_active bitmask length (64)). If it turns out that 2MB is too =
large<br>
&gt; &gt; of an active tracking granularity it is trivial to increase the s=
ize of<br>
&gt; &gt; the map_active bitmap.<br>
&gt;<br>
&gt; Please mention that 2M on Intel, and 16M on Arm64.<br>
&gt;<br>
&gt; &gt;<br>
&gt; &gt; The implications of a partially populated section is that pfn_val=
id()<br>
&gt; &gt; needs to go beyond a valid_section() check and read the sub-secti=
on<br>
&gt; &gt; active ranges from the bitmask.<br>
&gt; &gt;<br>
&gt; &gt; Cc: Michal Hocko &lt;<a href=3D"mailto:mhocko@suse.com" target=3D=
"_blank" rel=3D"noreferrer">mhocko@suse.com</a>&gt;<br>
&gt; &gt; Cc: Vlastimil Babka &lt;<a href=3D"mailto:vbabka@suse.cz" target=
=3D"_blank" rel=3D"noreferrer">vbabka@suse.cz</a>&gt;<br>
&gt; &gt; Cc: Logan Gunthorpe &lt;<a href=3D"mailto:logang@deltatee.com" ta=
rget=3D"_blank" rel=3D"noreferrer">logang@deltatee.com</a>&gt;<br>
&gt; &gt; Signed-off-by: Dan Williams &lt;<a href=3D"mailto:dan.j.williams@=
intel.com" target=3D"_blank" rel=3D"noreferrer">dan.j.williams@intel.com</a=
>&gt;<br>
&gt; &gt; ---<br>
&gt; &gt;=C2=A0 include/linux/mmzone.h |=C2=A0 =C2=A029 +++++++++++++++++++=
+++++++++-<br>
&gt; &gt;=C2=A0 mm/page_alloc.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A0 4=
 +++-<br>
&gt; &gt;=C2=A0 mm/sparse.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=
=A0 =C2=A048 ++++++++++++++++++++++++++++++++++++++++++++++++<br>
&gt; &gt;=C2=A0 3 files changed, 79 insertions(+), 2 deletions(-)<br>
&gt; &gt;<br>
&gt; &gt; diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h<br>
&gt; &gt; index 6726fc175b51..cffde898e345 100644<br>
&gt; &gt; --- a/include/linux/mmzone.h<br>
&gt; &gt; +++ b/include/linux/mmzone.h<br>
&gt; &gt; @@ -1175,6 +1175,8 @@ struct mem_section_usage {<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long pageblock_flags[0]=
;<br>
&gt; &gt;=C2=A0 };<br>
&gt; &gt;<br>
&gt; &gt; +void section_active_init(unsigned long pfn, unsigned long nr_pag=
es);<br>
&gt; &gt; +<br>
&gt; &gt;=C2=A0 struct page;<br>
&gt; &gt;=C2=A0 struct page_ext;<br>
&gt; &gt;=C2=A0 struct mem_section {<br>
&gt; &gt; @@ -1312,12 +1314,36 @@ static inline struct mem_section *__pfn_t=
o_section(unsigned long pfn)<br>
&gt; &gt;<br>
&gt; &gt;=C2=A0 extern int __highest_present_section_nr;<br>
&gt; &gt;<br>
&gt; &gt; +static inline int section_active_index(phys_addr_t phys)<br>
&gt; &gt; +{<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0return (phys &amp; ~(PA_SECTION_MASK)=
) / SECTION_ACTIVE_SIZE;<br>
&gt;<br>
&gt; How about also defining SECTION_ACTIVE_SHIFT like this:<br>
&gt;<br>
&gt; /* BITS_PER_LONG =3D 2^6 */<br>
&gt; #define BITS_PER_LONG_SHIFT 6<br>
&gt; #define SECTION_ACTIVE_SHIFT (SECTION_SIZE_BITS - BITS_PER_LONG_SHIFT)=
<br>
&gt; #define SECTION_ACTIVE_SIZE (1 &lt;&lt; SECTION_ACTIVE_SHIFT)<br>
&gt;<br>
&gt; The return above would become:<br>
&gt; return (phys &amp; ~(PA_SECTION_MASK)) &gt;&gt; SECTION_ACTIVE_SHIFT;<=
br>
&gt;<br>
&gt; &gt; +}<br>
&gt; &gt; +<br>
&gt; &gt; +#ifdef CONFIG_SPARSEMEM_VMEMMAP<br>
&gt; &gt; +static inline int pfn_section_valid(struct mem_section *ms, unsi=
gned long pfn)<br>
&gt; &gt; +{<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0int idx =3D section_active_index(PFN_=
PHYS(pfn));<br>
&gt; &gt; +<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0return !!(ms-&gt;usage-&gt;map_active=
 &amp; (1UL &lt;&lt; idx));<br>
&gt; &gt; +}<br>
&gt; &gt; +#else<br>
&gt; &gt; +static inline int pfn_section_valid(struct mem_section *ms, unsi=
gned long pfn)<br>
&gt; &gt; +{<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0return 1;<br>
&gt; &gt; +}<br>
&gt; &gt; +#endif<br>
&gt; &gt; +<br>
&gt; &gt;=C2=A0 #ifndef CONFIG_HAVE_ARCH_PFN_VALID<br>
&gt; &gt;=C2=A0 static inline int pfn_valid(unsigned long pfn)<br>
&gt; &gt;=C2=A0 {<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0struct mem_section *ms;<br>
&gt; &gt; +<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (pfn_to_section_nr(pfn) &gt;=
=3D NR_MEM_SECTIONS)<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0retu=
rn 0;<br>
&gt; &gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0return valid_section(__nr_to_section(=
pfn_to_section_nr(pfn)));<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0ms =3D __nr_to_section(pfn_to_section=
_nr(pfn));<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0if (!valid_section(ms))<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;=
<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0return pfn_section_valid(ms, pfn);<br=
>
&gt; &gt;=C2=A0 }<br>
&gt; &gt;=C2=A0 #endif<br>
&gt; &gt;<br>
&gt; &gt; @@ -1349,6 +1375,7 @@ void sparse_init(void);<br>
&gt; &gt;=C2=A0 #define sparse_init()=C2=A0 do {} while (0)<br>
&gt; &gt;=C2=A0 #define sparse_index_init(_sec, _nid)=C2=A0 do {} while (0)=
<br>
&gt; &gt;=C2=A0 #define pfn_present pfn_valid<br>
&gt; &gt; +#define section_active_init(_pfn, _nr_pages) do {} while (0)<br>
&gt; &gt;=C2=A0 #endif /* CONFIG_SPARSEMEM */<br>
&gt; &gt;<br>
&gt; &gt;=C2=A0 /*<br>
&gt; &gt; diff --git a/mm/page_alloc.c b/mm/page_alloc.c<br>
&gt; &gt; index f671401a7c0b..c9ad28a78018 100644<br>
&gt; &gt; --- a/mm/page_alloc.c<br>
&gt; &gt; +++ b/mm/page_alloc.c<br>
&gt; &gt; @@ -7273,10 +7273,12 @@ void __init free_area_init_nodes(unsigned=
 long *max_zone_pfn)<br>
&gt; &gt;<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Print out the early node map =
*/<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pr_info(&quot;Early memory node =
ranges\n&quot;);<br>
&gt; &gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0for_each_mem_pfn_range(i, MAX_NUMNODE=
S, &amp;start_pfn, &amp;end_pfn, &amp;nid)<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0for_each_mem_pfn_range(i, MAX_NUMNODE=
S, &amp;start_pfn, &amp;end_pfn, &amp;nid) {<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pr_i=
nfo(&quot;=C2=A0 node %3d: [mem %#018Lx-%#018Lx]\n&quot;, nid,<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0(u64)start_pfn &lt;&lt; PAGE_SHIFT,<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0((u64)end_pfn &lt;&lt; PAGE_SHIFT) - 1);<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0section_a=
ctive_init(start_pfn, end_pfn - start_pfn);<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
&gt; &gt;<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Initialise every node */<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0mminit_verify_pageflags_layout()=
;<br>
&gt; &gt; diff --git a/mm/sparse.c b/mm/sparse.c<br>
&gt; &gt; index f87de7ad32c8..5ef2f884c4e1 100644<br>
&gt; &gt; --- a/mm/sparse.c<br>
&gt; &gt; +++ b/mm/sparse.c<br>
&gt; &gt; @@ -210,6 +210,54 @@ static inline unsigned long first_present_se=
ction_nr(void)<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return next_present_section_nr(-=
1);<br>
&gt; &gt;=C2=A0 }<br>
&gt; &gt;<br>
&gt; &gt; +static unsigned long section_active_mask(unsigned long pfn,<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned =
long nr_pages)<br>
&gt; &gt; +{<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0int idx_start, idx_size;<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0phys_addr_t start, size;<br>
&gt; &gt; +<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0if (!nr_pages)<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;=
<br>
&gt; &gt; +<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0start =3D PFN_PHYS(pfn);<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0size =3D PFN_PHYS(min(nr_pages, PAGES=
_PER_SECTION<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0- (pfn &amp; ~PAGE_SECTION_=
MASK)));<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0size =3D ALIGN(size, SECTION_ACTIVE_S=
IZE);<br>
&gt; &gt; +<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0idx_start =3D section_active_index(st=
art);<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0idx_size =3D section_active_index(siz=
e);<br>
&gt; &gt; +<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0if (idx_size =3D=3D 0)<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return -1=
;<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0return ((1UL &lt;&lt; idx_size) - 1) =
&lt;&lt; idx_start;<br>
&gt; &gt; +}<br>
&gt; &gt; +<br>
&gt; &gt; +void section_active_init(unsigned long pfn, unsigned long nr_pag=
es)<br>
&gt; &gt; +{<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0int end_sec =3D pfn_to_section_nr(pfn=
 + nr_pages - 1);<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0int i, start_sec =3D pfn_to_section_n=
r(pfn);<br>
&gt; &gt; +<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0if (!nr_pages)<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return;<b=
r>
&gt; &gt; +<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0for (i =3D start_sec; i &lt;=3D end_s=
ec; i++) {<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct me=
m_section *ms;<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned =
long mask;<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned =
long pfns;<br>
&gt; &gt; +<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pfns =3D =
min(nr_pages, PAGES_PER_SECTION<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0- (pfn &amp; ~PAGE_SECTION_=
MASK));<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0mask =3D =
section_active_mask(pfn, pfns);<br>
&gt; &gt; +<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ms =3D __=
nr_to_section(i);<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pr_debug(=
&quot;%s: sec: %d mask: %#018lx\n&quot;, __func__, i, mask);<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ms-&gt;us=
age-&gt;map_active =3D mask;<br>
&gt; &gt; +<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pfn +=3D =
pfns;<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0nr_pages =
-=3D pfns;<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
&gt; &gt; +}<br>
&gt;<br>
&gt; For some reasons the above code is confusing to me. It seems all the<b=
r>
&gt; code supposed to do is set all map_active to -1, and trim the first<br=
>
&gt; and last sections (can be the same section of course). So, I would<br>
&gt; replace the above two functions with one function like this:<br>
&gt;<br>
&gt; void section_active_init(unsigned long pfn, unsigned long nr_pages)<br=
>
&gt; {<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0int end_sec =3D pfn_to_section_nr(pfn=
 + nr_pages - 1);<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0int i, idx, start_sec =3D pfn_to_sect=
ion_nr(pfn);<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct mem_section *ms;<br>
&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!nr_pages)<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return;<b=
r>
&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0for (i =3D start_sec; i &lt;=3D end_s=
ec; i++) {<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ms =3D __=
nr_to_section(i);<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ms-&gt;us=
age-&gt;map_active =3D ~0ul;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Might need to trim active pfns fro=
m the beginning and end */<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0idx =3D section_active_index(PFN_PHYS=
(pfn));<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ms =3D __nr_to_section(start_sec);<br=
>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ms-&gt;usage-&gt;map_active &amp;=3D =
(~0ul &lt;&lt; idx);<br>
&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0idx =3D section_active_index(PFN_PHYS=
(pfn + nr_pages -1));<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ms =3D __nr_to_section(end_sec);<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ms-&gt;usage-&gt;map_active &amp;=3D =
(~0ul &gt;&gt; (BITS_PER_LONG - idx - 1));<br>
&gt; }<br>
<br>
I like the cleanup, but one of the fixes in v7 resulted in the<br>
realization that a given section may be populated twice at init time.<br>
For example, enabling that pr_debug() yields:<br>
<br>
=C2=A0 =C2=A0 section_active_init: sec: 12 mask: 0x00000003ffffffff<br>
=C2=A0 =C2=A0 section_active_init: sec: 12 mask: 0xe000000000000000<br>
<br>
So, the implementation can&#39;t blindly clear bits based on the current<br=
>
parameters. However, I&#39;m switching this code over to use bitmap_*()<br>
helpers which should help with the readability.<br></blockquote></div></div=
><div dir=3D"auto"><br></div><div dir=3D"auto">Yes, bitmap_* will help, and=
 I assume you will also make active_map size scalable?</div><div dir=3D"aut=
o"><br></div><div dir=3D"auto">I will take another look at version 8.</div>=
<div dir=3D"auto"><br></div><div dir=3D"auto"><br></div><div dir=3D"auto">T=
hank you,</div><div dir=3D"auto">Pasha</div><div dir=3D"auto"><br></div><di=
v dir=3D"auto"><div class=3D"gmail_quote"><blockquote class=3D"gmail_quote"=
 style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
</blockquote></div></div></div>

--0000000000009b73a205881509d8--

