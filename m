Return-Path: <SRS0=uo52=XM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 77860C4CECD
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 20:07:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 36D592171F
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 20:07:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="IXoQ3vxu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 36D592171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C9E9A6B0007; Tue, 17 Sep 2019 16:07:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C4F546B0008; Tue, 17 Sep 2019 16:07:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B173C6B000A; Tue, 17 Sep 2019 16:07:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0002.hostedemail.com [216.40.44.2])
	by kanga.kvack.org (Postfix) with ESMTP id 8F9D36B0007
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 16:07:39 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 1EF45181AC9AE
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 20:07:39 +0000 (UTC)
X-FDA: 75945497838.07.pest74_7cf30bd806e23
X-HE-Tag: pest74_7cf30bd806e23
X-Filterd-Recvd-Size: 6557
Received: from mail-io1-f66.google.com (mail-io1-f66.google.com [209.85.166.66])
	by imf32.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 20:07:38 +0000 (UTC)
Received: by mail-io1-f66.google.com with SMTP id j4so10586782iog.11
        for <linux-mm@kvack.org>; Tue, 17 Sep 2019 13:07:38 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Ce6TIk2yBsCUQjQPMJ8ki5Nu2SBqoNexDUHdpPLZySE=;
        b=IXoQ3vxuaz+/4yYyVZDcNRx1kyPbDpgLdKm9H8fFva0zYnZbhoFmyYyC8gngZ58zyF
         6NxP+qTT+//nALDqAjKoS3MOCtXEssE+jNU/o5MfABd/0QfY3+RqJjY3fM9a5qI/F/4T
         I6epQYin6F+jNcw6aZJIhbXjbp5bKLq+/DjI7wrNkEHGGgqFaC3H0YN1XY/adk4zydhW
         Xf95qYQNNXA2wAxAS+n54QcFh281JuuxKEOq/L8CTTqsOx4H9/SagURbie47k2iYcAhF
         B0/AzQQkBqYdmNMEweXoFU7lM61o6RZS8L7cktMGGlkEuw/V+Kp2pD+o1/oJYGlsiLZg
         WK1A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=Ce6TIk2yBsCUQjQPMJ8ki5Nu2SBqoNexDUHdpPLZySE=;
        b=P6lwIwoUrLTeqcIeGXChZ/zffxRMclGwZ40C8m5WXAPhQYvsxBFga/dJ0sVPq7vnv/
         /BTnxTcLLV3WgOiR0bIwWTJMTYmLOI4v2ZdbZ8MBiW2PugHqf8uvfdIgZ9HOrzGUT0EE
         W0OmGeq6t2RMZdtdsDBz29wDm1lO7/ySdzDI0BexVvqkFBAeOFWAkBXpj0HLWgdeUg8e
         mHdQO/nbL4vWYqUYi1cwx+gk4rc3ckKcUilvt6kSkSix8qYJwA/wlDVJm6ggKa/LbEsS
         WUP66lt7xADlym87mE+Rc9pYMc+DPdcn3vyU8T810e/xdJK984bjCNrdOAQkmFb6AiFp
         osRQ==
X-Gm-Message-State: APjAAAVpRmWYgZEC/byXPKiL37rnem8QiJgCXV69hyM8he8yhrNUVVFD
	bJZs75Y0aZNYz3VmJ7xPCduiUY2qvaZ3kMLa2oU=
X-Google-Smtp-Source: APXvYqx/bywcsKyBZocnzcRUqWxcRIiNYzZKZ+MK31UwJG5x0ScDRR8hwq1bhsfxSgwub9YjCSWmX4ykNdQvx8Skj7k=
X-Received: by 2002:a5d:8b47:: with SMTP id c7mr733291iot.42.1568750857640;
 Tue, 17 Sep 2019 13:07:37 -0700 (PDT)
MIME-Version: 1.0
References: <20190907172225.10910.34302.stgit@localhost.localdomain>
 <20190907172545.10910.88045.stgit@localhost.localdomain> <20190917174853.5csycb5pb5zalsxd@willie-the-truck>
In-Reply-To: <20190917174853.5csycb5pb5zalsxd@willie-the-truck>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Tue, 17 Sep 2019 13:07:26 -0700
Message-ID: <CAKgT0Ufoq5BsOwW11SYHDBcy8-U91FgFCxK9XFf5twPWXzpO7g@mail.gmail.com>
Subject: Re: [PATCH v9 5/8] arm64: Move hugetlb related definitions out of
 pgtable.h to page-defs.h
To: Will Deacon <will@kernel.org>
Cc: virtio-dev@lists.oasis-open.org, kvm list <kvm@vger.kernel.org>, 
	"Michael S. Tsirkin" <mst@redhat.com>, Catalin Marinas <catalin.marinas@arm.com>, 
	David Hildenbrand <david@redhat.com>, Dave Hansen <dave.hansen@intel.com>, 
	LKML <linux-kernel@vger.kernel.org>, Matthew Wilcox <willy@infradead.org>, 
	Michal Hocko <mhocko@kernel.org>, linux-mm <linux-mm@kvack.org>, 
	Andrew Morton <akpm@linux-foundation.org>, linux-arm-kernel@lists.infradead.org, 
	Oscar Salvador <osalvador@suse.de>, Yang Zhang <yang.zhang.wz@gmail.com>, 
	Pankaj Gupta <pagupta@redhat.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, 
	Nitesh Narayan Lal <nitesh@redhat.com>, Rik van Riel <riel@surriel.com>, lcapitulino@redhat.com, 
	"Wang, Wei W" <wei.w.wang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, ying.huang@intel.com, 
	Paolo Bonzini <pbonzini@redhat.com>, Dan Williams <dan.j.williams@intel.com>, 
	Fengguang Wu <fengguang.wu@intel.com>, 
	Alexander Duyck <alexander.h.duyck@linux.intel.com>, 
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 17, 2019 at 10:49 AM Will Deacon <will@kernel.org> wrote:
>
> On Sat, Sep 07, 2019 at 10:25:45AM -0700, Alexander Duyck wrote:
> > From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> >
> > Move the static definition for things such as HUGETLB_PAGE_ORDER out of
> > asm/pgtable.h and place it in page-defs.h. By doing this the includes
> > become much easier to deal with as currently arm64 is the only architecture
> > that didn't include this definition in the asm/page.h file or a file
> > included by it.
> >
> > It also makes logical sense as PAGE_SHIFT was already defined in
> > page-defs.h so now we also have HPAGE_SHIFT defined there as well.
> >
> > Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > ---
> >  arch/arm64/include/asm/page-def.h |    9 +++++++++
> >  arch/arm64/include/asm/pgtable.h  |    9 ---------
> >  2 files changed, 9 insertions(+), 9 deletions(-)
> >
> > diff --git a/arch/arm64/include/asm/page-def.h b/arch/arm64/include/asm/page-def.h
> > index f99d48ecbeef..1c5b079e2482 100644
> > --- a/arch/arm64/include/asm/page-def.h
> > +++ b/arch/arm64/include/asm/page-def.h
> > @@ -20,4 +20,13 @@
> >  #define CONT_SIZE            (_AC(1, UL) << (CONT_SHIFT + PAGE_SHIFT))
> >  #define CONT_MASK            (~(CONT_SIZE-1))
> >
> > +/*
> > + * Hugetlb definitions.
> > + */
> > +#define HUGE_MAX_HSTATE              4
> > +#define HPAGE_SHIFT          PMD_SHIFT
> > +#define HPAGE_SIZE           (_AC(1, UL) << HPAGE_SHIFT)
> > +#define HPAGE_MASK           (~(HPAGE_SIZE - 1))
> > +#define HUGETLB_PAGE_ORDER   (HPAGE_SHIFT - PAGE_SHIFT)
> > +
> >  #endif /* __ASM_PAGE_DEF_H */
> > diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
> > index 7576df00eb50..06a376de9bd6 100644
> > --- a/arch/arm64/include/asm/pgtable.h
> > +++ b/arch/arm64/include/asm/pgtable.h
> > @@ -305,15 +305,6 @@ static inline int pte_same(pte_t pte_a, pte_t pte_b)
> >   */
> >  #define pte_mkhuge(pte)              (__pte(pte_val(pte) & ~PTE_TABLE_BIT))
> >
> > -/*
> > - * Hugetlb definitions.
> > - */
> > -#define HUGE_MAX_HSTATE              4
> > -#define HPAGE_SHIFT          PMD_SHIFT
> > -#define HPAGE_SIZE           (_AC(1, UL) << HPAGE_SHIFT)
> > -#define HPAGE_MASK           (~(HPAGE_SIZE - 1))
> > -#define HUGETLB_PAGE_ORDER   (HPAGE_SHIFT - PAGE_SHIFT)
> > -
>
> Acked-by: Will Deacon <will@kernel.org>
>
> I'm assuming you're taking this along with the other patches, but please
> shout if you'd rather it went via the arm64 tree.
>
> Will

As it turns out I am close to submitting a v10 that doesn't need this
patch. I basically just needed to move the list manipulators out of
mmzone.h and then moved my header file out of there so I no longer
needed the code.

Thanks.

- Alex

