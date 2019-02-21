Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8D37C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 18:07:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7813720836
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 18:07:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7813720836
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 221D48E009D; Thu, 21 Feb 2019 13:07:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1AA278E0094; Thu, 21 Feb 2019 13:07:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 09C1E8E009D; Thu, 21 Feb 2019 13:07:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id D07A68E0094
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 13:07:41 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id d134so5824327qkc.17
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 10:07:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=olMrqHH5uy4fS8Ln6XD+bGmOqhmVEwplgiUErDulkDc=;
        b=Kz6koeNwQ95QZq/HWC5Kev14HlhWi08YUOocg3dmOiETa0EaA+Wu3Ti8z1qsYWIU8z
         lt8ulT88QqbpDV23F74dBzDVO56GqwdlQydrPAMTObgJFEfz9qoavDCML0JKkX48w37v
         mNIV+q+tbR3AmsPx1pq534boI3ZBC0mCLdTSDuDw93XeOknzuQ9TKUBOwK2JmI2efkJ7
         5djXTiFuzhTBj5C0idFN5CmKVqjo6TtAQ4mYtIA+acS8gpyyxb79XhDkz+Xj4eABf82j
         KvbVaZ6OFcJtkgwUuzLuw+NGzcn4VKCrY3srTEclKGAWm24XsBp05n2yPJY+1A3aGC5T
         Mntg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAub6IDiw8lzDw+nvC7uaSNh3OLOENNCZRlDmCzD+/l5p3MHBtTho
	t4AXxoVGyweIKGOkNQjcX8UnStpCYnR4fmfih87YPlPe8U/olf+br1P/GlJxLA4Cxt0fSdSpaBN
	8OyTGlz2agpICwR7YQ7ez3XEBr3vEQZoY9dsg4ApojSFEHmmzkcaUsxD3K33wF0Gnaw==
X-Received: by 2002:a37:59c4:: with SMTP id n187mr30757281qkb.156.1550772461645;
        Thu, 21 Feb 2019 10:07:41 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib84gadtSw3l7TLozMHFCtraShsPsBcWwo7z4y4Fe6bHaLcx7ZHdFOILdA38W+sb7D1Md4r
X-Received: by 2002:a37:59c4:: with SMTP id n187mr30757248qkb.156.1550772461130;
        Thu, 21 Feb 2019 10:07:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550772461; cv=none;
        d=google.com; s=arc-20160816;
        b=rgPDJv+nza/9p0n5MZnqoT6dVAh6sN7rDTA5Ju+KyZe7MhkIRO4Zre1EyZXQVPd3Dr
         qMvvY5oBzT4vW5vRwi5asA+BKdaHgpUY0Pie4bfsoLHbp3hb3GHKiwy6LdHRVerezpsu
         cZiUwUyJO6cfQlv92Mi758/cnOI2gOcEZbvQnedEEKcn9ZnvaMTPcb3TvT0Fl0O+lqF4
         WqIL6jsIbXq1ToyAj8SoRC2Ao0pEU6tnGuAtVuvhAAeMDjiRgPToQhV57DtEo6FgeWZQ
         w+QAEwKjBIYAaes/hjr7SU1pnb5JITL3Ql+vV31UiR7G8v59xWSCgTdiJn5oSUhxYp0G
         DtYw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=olMrqHH5uy4fS8Ln6XD+bGmOqhmVEwplgiUErDulkDc=;
        b=0W74qCROSBrxEpEqMNQ3KWhme5OPdI8jbkjZJRSGeRbHsO6714nZEcPIFRIb23W0y6
         HgZwFMgwtXAezKSsY8r66oUKOPtlOIZ4qkLjjOiDNpI3QYf/Gig/iu7m6rUfySbnRnl+
         Ct41Zogipcxj1nglp8rmWlWdIqlggGlfV3FtH3S8zv6lex3HNTQbmfiRQPThIoP2gR7+
         eih1U+1c9906PNZkhJVoZTazaBWorT5Hwgy0iHsMLjIX2B9lYuOgPNcb/uP1nEQL8CDV
         g/lmmvHk1PE3uyoyLP6rWHK9rAR4hpWR/KQCeZSwMb8OpEaAJ1hdOp5Hk4jaEnwA932I
         AEOQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b22si1733722qvb.187.2019.02.21.10.07.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 10:07:41 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 295C730058A8;
	Thu, 21 Feb 2019 18:07:40 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 7F0C1282C2;
	Thu, 21 Feb 2019 18:07:32 +0000 (UTC)
Date: Thu, 21 Feb 2019 13:07:30 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Peter Xu <peterx@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	David Hildenbrand <david@redhat.com>,
	Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Martin Cracauer <cracauer@cons.org>, Shaohua Li <shli@fb.com>,
	Marty McFadden <mcfadden8@llnl.gov>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [PATCH v2 16/26] userfaultfd: wp: add pmd_swp_*uffd_wp() helpers
Message-ID: <20190221180730.GP2813@redhat.com>
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-17-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190212025632.28946-17-peterx@redhat.com>
User-Agent: Mutt/1.10.0 (2018-05-17)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Thu, 21 Feb 2019 18:07:40 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 10:56:22AM +0800, Peter Xu wrote:
> Adding these missing helpers for uffd-wp operations with pmd
> swap/migration entries.
> 
> Signed-off-by: Peter Xu <peterx@redhat.com>

Reviewed-by: Jérôme Glisse <jglisse@redhat.com>

> ---
>  arch/x86/include/asm/pgtable.h     | 15 +++++++++++++++
>  include/asm-generic/pgtable_uffd.h | 15 +++++++++++++++
>  2 files changed, 30 insertions(+)
> 
> diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
> index 6863236e8484..18a815d6f4ea 100644
> --- a/arch/x86/include/asm/pgtable.h
> +++ b/arch/x86/include/asm/pgtable.h
> @@ -1401,6 +1401,21 @@ static inline pte_t pte_swp_clear_uffd_wp(pte_t pte)
>  {
>  	return pte_clear_flags(pte, _PAGE_SWP_UFFD_WP);
>  }
> +
> +static inline pmd_t pmd_swp_mkuffd_wp(pmd_t pmd)
> +{
> +	return pmd_set_flags(pmd, _PAGE_SWP_UFFD_WP);
> +}
> +
> +static inline int pmd_swp_uffd_wp(pmd_t pmd)
> +{
> +	return pmd_flags(pmd) & _PAGE_SWP_UFFD_WP;
> +}
> +
> +static inline pmd_t pmd_swp_clear_uffd_wp(pmd_t pmd)
> +{
> +	return pmd_clear_flags(pmd, _PAGE_SWP_UFFD_WP);
> +}
>  #endif /* CONFIG_HAVE_ARCH_USERFAULTFD_WP */
>  
>  #define PKRU_AD_BIT 0x1
> diff --git a/include/asm-generic/pgtable_uffd.h b/include/asm-generic/pgtable_uffd.h
> index 643d1bf559c2..828966d4c281 100644
> --- a/include/asm-generic/pgtable_uffd.h
> +++ b/include/asm-generic/pgtable_uffd.h
> @@ -46,6 +46,21 @@ static __always_inline pte_t pte_swp_clear_uffd_wp(pte_t pte)
>  {
>  	return pte;
>  }
> +
> +static inline pmd_t pmd_swp_mkuffd_wp(pmd_t pmd)
> +{
> +	return pmd;
> +}
> +
> +static inline int pmd_swp_uffd_wp(pmd_t pmd)
> +{
> +	return 0;
> +}
> +
> +static inline pmd_t pmd_swp_clear_uffd_wp(pmd_t pmd)
> +{
> +	return pmd;
> +}
>  #endif /* CONFIG_HAVE_ARCH_USERFAULTFD_WP */
>  
>  #endif /* _ASM_GENERIC_PGTABLE_UFFD_H */
> -- 
> 2.17.1
> 

