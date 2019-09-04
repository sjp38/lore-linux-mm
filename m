Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,FSL_HELO_FAKE,HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1,USER_IN_DEF_DKIM_WL autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 32A7EC3A5AB
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 20:54:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E98A721883
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 20:54:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="lL5TlUCt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E98A721883
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7F7676B0003; Wed,  4 Sep 2019 16:54:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7A8976B0006; Wed,  4 Sep 2019 16:54:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6BEBD6B0007; Wed,  4 Sep 2019 16:54:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0112.hostedemail.com [216.40.44.112])
	by kanga.kvack.org (Postfix) with ESMTP id 4C55F6B0003
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 16:54:50 -0400 (EDT)
Received: from smtpin01.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id C6FF4180AD801
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 20:54:49 +0000 (UTC)
X-FDA: 75898442298.01.grade47_4736d83212229
X-HE-Tag: grade47_4736d83212229
X-Filterd-Recvd-Size: 5643
Received: from mail-io1-f66.google.com (mail-io1-f66.google.com [209.85.166.66])
	by imf09.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 20:54:49 +0000 (UTC)
Received: by mail-io1-f66.google.com with SMTP id h144so32131120iof.7
        for <linux-mm@kvack.org>; Wed, 04 Sep 2019 13:54:49 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=vXwoIRD/HomfAGA3enlPIWun5YO8zmnB2AFzW0Iniws=;
        b=lL5TlUCtshbicXBX7o8SDAZtZAKYXC6ca2f5A9ldF6R14qEtWGy99KueQps418Znq9
         nw1RLiYAkb29C6Cfvhf3pDnBrnOMftTxL0cYvm/oCqZOub6VMXqVfVa2aWTgjSr4r4gj
         8MPzqz7MtWfwJUNQo6KkZ7T76dRaxG/HeGS4IoscFtXW3YiOUivL81MJNqyOmTtrXfBt
         FEP+y4hCVNmDxZ1WzytKXQkbjsItc+aiZlQ5r32sAp8B+XE3wc1ogHHQaB3hdPCP7KzD
         fF+6ITHH/T4LiOKChbaM11LaRBRmjfa66V0sB+gCbPI1l5aDRVuBbn6GWlOoZa6zD2tK
         SenA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=vXwoIRD/HomfAGA3enlPIWun5YO8zmnB2AFzW0Iniws=;
        b=RefOG+sy2YJqNvDgYO+mle6oB5BxZikCG7XzsiNF6hMbbpGAulzTdr6lnCFHJ0Opp5
         4w0tNIT4t29wWRoBI1LrelhaKjXOAPNQapyndJqPhFq+uxv0XKxOwe/6Mg+2NVxOFDXi
         3QO4zL5bB6c+1GkBG3B6TloUubhM7XkCc1eRzhYvxTyogsm3TLnPFsL9Rlk4E+JnyA72
         eAIzYvSj+G9yZkRG28efF2I/qKcJFK/5Dd2178UBa50bfUyaGdzdZS3n8F4jw0s5CpBv
         7fqCAL8vzv+GvPcSLN73LwvUntNbgyee18/zB7x2gBu4dk1Haw69R3RZDq+e68R6/us+
         ECag==
X-Gm-Message-State: APjAAAU09qUDZwz4LVO48G5n5GWrZo5ldsNwa2qNXSO0idToyciEsSsH
	Wl5sWGPB/YCwe3XV9JFZpa8kTg==
X-Google-Smtp-Source: APXvYqw87BnjWR9GdN8CRA7xMoVsDrp0wOKoOFPjmTBeJqSfmuF9wzp9tZO06jjNNw9zgpEiqOgfrA==
X-Received: by 2002:a5e:9813:: with SMTP id s19mr2214175ioj.263.1567630488336;
        Wed, 04 Sep 2019 13:54:48 -0700 (PDT)
Received: from google.com ([2620:15c:183:0:9f3b:444a:4649:ca05])
        by smtp.gmail.com with ESMTPSA id j26sm36426ioe.18.2019.09.04.13.54.47
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 04 Sep 2019 13:54:47 -0700 (PDT)
Date: Wed, 4 Sep 2019 14:54:43 -0600
From: Yu Zhao <yuzhao@google.com>
To: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: Matthew Wilcox <willy@infradead.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ralph Campbell <rcampbell@nvidia.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Will Deacon <will@kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	"Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>,
	Dave Airlie <airlied@redhat.com>,
	Thomas Hellstrom <thellstrom@vmware.com>,
	Souptick Joarder <jrdr.linux@gmail.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm: replace is_zero_pfn with is_huge_zero_pmd for thp
Message-ID: <20190904205443.GA70057@google.com>
References: <20190825200621.211494-1-yuzhao@google.com>
 <20190826131858.GB15933@bombadil.infradead.org>
 <20190826170934.7c2f4340@thinkpad>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190826170934.7c2f4340@thinkpad>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 26, 2019 at 05:09:34PM +0200, Gerald Schaefer wrote:
> On Mon, 26 Aug 2019 06:18:58 -0700
> Matthew Wilcox <willy@infradead.org> wrote:
> 
> > Why did you not cc Gerald who wrote the patch?  You can't just
> > run get_maintainers.pl and call it good.
> > 
> > On Sun, Aug 25, 2019 at 02:06:21PM -0600, Yu Zhao wrote:
> > > For hugely mapped thp, we use is_huge_zero_pmd() to check if it's
> > > zero page or not.
> > > 
> > > We do fill ptes with my_zero_pfn() when we split zero thp pmd, but
> > >  this is not what we have in vm_normal_page_pmd().
> > > pmd_trans_huge_lock() makes sure of it.
> > > 
> > > This is a trivial fix for /proc/pid/numa_maps, and AFAIK nobody
> > > complains about it.
> > > 
> > > Signed-off-by: Yu Zhao <yuzhao@google.com>
> > > ---
> > >  mm/memory.c | 2 +-
> > >  1 file changed, 1 insertion(+), 1 deletion(-)
> > > 
> > > diff --git a/mm/memory.c b/mm/memory.c
> > > index e2bb51b6242e..ea3c74855b23 100644
> > > --- a/mm/memory.c
> > > +++ b/mm/memory.c
> > > @@ -654,7 +654,7 @@ struct page *vm_normal_page_pmd(struct vm_area_struct *vma, unsigned long addr,
> > >  
> > >  	if (pmd_devmap(pmd))
> > >  		return NULL;
> > > -	if (is_zero_pfn(pfn))
> > > +	if (is_huge_zero_pmd(pmd))
> > >  		return NULL;
> > >  	if (unlikely(pfn > highest_memmap_pfn))
> > >  		return NULL;
> > > -- 
> > > 2.23.0.187.g17f5b7556c-goog
> > >   
> 
> Looks good to me. The "_pmd" versions for can_gather_numa_stats() and
> vm_normal_page() were introduced to avoid using pte_present/dirty() on
> pmds, which is not affected by this patch.
> 
> In fact, for vm_normal_page_pmd() I basically copied most of the code
> from vm_normal_page(), including the is_zero_pfn(pfn) check, which does
> look wrong to me now. Using is_huge_zero_pmd() should be correct.
> 
> Maybe the description could also mention the symptom of this bug?
> I would assume that it affects anon/dirty accounting in gather_pte_stats(),
> for huge mappings, if zero page mappings are not correctly recognized.

Hi, sorry for not copying you on the original email. I came across
this while I was looking at the code. I'm not aware of any symptom.
Thank you.

