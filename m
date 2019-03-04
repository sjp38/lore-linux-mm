Return-Path: <SRS0=F7ZL=RH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3E468C43381
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 14:53:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EDFE220815
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 14:53:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EDFE220815
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 853308E0003; Mon,  4 Mar 2019 09:53:16 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7DA018E0001; Mon,  4 Mar 2019 09:53:16 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 655578E0003; Mon,  4 Mar 2019 09:53:16 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 369598E0001
	for <linux-mm@kvack.org>; Mon,  4 Mar 2019 09:53:16 -0500 (EST)
Received: by mail-yw1-f71.google.com with SMTP id a199so8366322ywe.23
        for <linux-mm@kvack.org>; Mon, 04 Mar 2019 06:53:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=sE4U0X4iNAAJIIxzoRR00DNC0BWsDIZMWguVaPSfGbM=;
        b=oluTLpA6adEPA3tWwl2GijNr7yl5Aph/0JfKKNfLUfkUwwO6UZ76qQ1YdIql1m6qwM
         Yi5JaDA3tjyHWpytAGvh07/FZiRipKNllXKyuJJhVNiq/LuJ6h1wCZJHOoKhT7CHVqh0
         CPAXECOEEr9D1BH5dUcXhuiEgw5TJPoMYMYRc2SrQHP4HMHMNYnxUmiGLK8U94xA4fvN
         GvJ0qid5yPONDqECPsBKPxpO1d3a7gyA+oFxVZoeJlhOPIff0qxGHEj8+mwlBbelOJje
         8ST4rMZrlbf6gvFS75C4TGn6iG1YxM9+3rp1cR9/31tlm4lfUwvu9k6eGscWCIHuqukU
         FDoQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAU703MtzXfPZV2vfdoICf7YxaLXyh9oi1nlpBaT2Skpv0uPUVIR
	gG1MVGo03OpN7+4C1ibxMBxYyVEpiJXwkh56LCMyYRM3K2V71ih6WqOd/wZmroW8ZE07HEcWv88
	Th1EJ1Rh7lQVUGAk3rdoz5EOGQRY9G9FhMoEMCW498VD9IAgqR3O+C3RbAFXYTMZVCA==
X-Received: by 2002:a25:18c2:: with SMTP id 185mr15030041yby.224.1551711195882;
        Mon, 04 Mar 2019 06:53:15 -0800 (PST)
X-Google-Smtp-Source: APXvYqzKsspHDCPBELSGxepon8+RvL9DP4+MXGWDIeE0ZaaIUK7yrRZCG2zRRXbc57mBjGWVVPH1
X-Received: by 2002:a25:18c2:: with SMTP id 185mr15029998yby.224.1551711194985;
        Mon, 04 Mar 2019 06:53:14 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551711194; cv=none;
        d=google.com; s=arc-20160816;
        b=hE6pAUKsK093Lln3tXsu7aE+h081mcpCHHUcgehXynhDGb+9psaupAA+y6QQd+1beH
         yAIcGGey3R4O9n9ijp2J/ZLqyvcFjWRECoGpkPHMWSNnYBBu2QU+ODm5/SOCJy8n28uS
         L4lyPlBgr/t49nWyDGHAJI/Iz1t2bFsBSvTWrNMMp7x2t19UsHmpJ9blcaVEC0pSBWhW
         tU+jZqKaz7oihOQ8bOal5rxGkJzirHH48iNWB1SMjFlT6GWUngsCqMOVLKbvm3TKyOqI
         gOj86BN8niJ7NbqYGQBohtobP1IinrNh75qvUDzGyeafpuZjup5NmlCo9qj3aJxsgP4e
         BrZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=sE4U0X4iNAAJIIxzoRR00DNC0BWsDIZMWguVaPSfGbM=;
        b=zp6HY4gDCQWVH66R5D9sThEmrJkvN3XpCdTdCU2o3KhgmzENYkW/fSXuEmTN+Ouf8U
         sRmC3xm22ZUSw3jl7LVi5cP+44oOWcb9EHor8PToElggy/ovw5SQHaJ92iByQa5aryo3
         jepxbvNk9MlDxaEPiYSKvQJz8bG9fO5QUfVayKwiBrIdaM+ynCH+JzUJTjglyqXGJ+35
         LuJrsQJureHGatdZM0uupBXTkgPPqmpR3Izr5kazNrmW1YHhOGVeeHTd3aDm+JMznzrf
         yxHxbKteg8tkG5wR8140Fu2xTVG0kInYEwWummi+TXpZPCVkNjKXl0rnG3ra9DL3brei
         sc5g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id f126si3205365ybc.216.2019.03.04.06.53.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Mar 2019 06:53:14 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x24Eog0b126528
	for <linux-mm@kvack.org>; Mon, 4 Mar 2019 09:53:14 -0500
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2r15f8j5f1-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 04 Mar 2019 09:53:14 -0500
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Mon, 4 Mar 2019 14:53:12 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp03.uk.ibm.com (192.168.101.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 4 Mar 2019 14:53:05 -0000
Received: from d06av21.portsmouth.uk.ibm.com (d06av21.portsmouth.uk.ibm.com [9.149.105.232])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x24Er4qT59768974
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 4 Mar 2019 14:53:05 GMT
Received: from d06av21.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id D00EC5204F;
	Mon,  4 Mar 2019 14:53:04 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.206.89])
	by d06av21.portsmouth.uk.ibm.com (Postfix) with ESMTPS id 0AABA52063;
	Mon,  4 Mar 2019 14:53:02 +0000 (GMT)
Date: Mon, 4 Mar 2019 16:53:01 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Steven Price <steven.price@arm.com>
Cc: Mark Rutland <Mark.Rutland@arm.com>,
        Dave Hansen <dave.hansen@linux.intel.com>,
        James Morse <james.morse@arm.com>, Arnd Bergmann <arnd@arndb.de>,
        Ard Biesheuvel <ard.biesheuvel@linaro.org>,
        Peter Zijlstra <peterz@infradead.org>,
        Catalin Marinas <catalin.marinas@arm.com>, x86@kernel.org,
        Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org,
        =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
        Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
        Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>,
        "Kirill A. Shutemov" <kirill@shutemov.name>,
        Thomas Gleixner <tglx@linutronix.de>,
        linux-arm-kernel@lists.infradead.org,
        "Liang, Kan" <kan.liang@linux.intel.com>
Subject: Re: [PATCH v2 03/13] mm: Add generic p?d_large() macros
References: <20190221142812.oa53lfnnfmsuh6ys@kshutemo-mobl1>
 <a3076d01-41b3-d59b-e98c-a0fd9ba5d3f5@arm.com>
 <20190221145706.zqwfdoyiirn3lc7y@kshutemo-mobl1>
 <e0c7fc0c-7924-1106-a7a3-fc12136b7b82@arm.com>
 <20190221210618.voyfs5cnafpvgedh@kshutemo-mobl1>
 <20190301115300.GE5156@rapoport-lnx>
 <20190301123031.rw3dswcoaa2x7haq@kshutemo-mobl1>
 <b8bd0f99-1c5e-7cf5-32dd-ab52d921e86c@arm.com>
 <20190303071253.GA7585@rapoport-lnx>
 <2adbc516-3ffd-8e34-887a-843ccab72d51@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2adbc516-3ffd-8e34-887a-843ccab72d51@arm.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19030414-0012-0000-0000-000002FE5B31
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19030414-0013-0000-0000-000021355E08
Message-Id: <20190304145300.GC22843@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-04_06:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1903040109
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 04, 2019 at 02:35:56PM +0000, Steven Price wrote:
> On 03/03/2019 07:12, Mike Rapoport wrote:
> > On Fri, Mar 01, 2019 at 01:39:30PM +0000, Steven Price wrote:
> >> On 01/03/2019 12:30, Kirill A. Shutemov wrote:
> >>> On Fri, Mar 01, 2019 at 01:53:01PM +0200, Mike Rapoport wrote:
> >>>> Him Kirill,
> >>>>
> >>>> On Fri, Feb 22, 2019 at 12:06:18AM +0300, Kirill A. Shutemov wrote:
> >>>>> On Thu, Feb 21, 2019 at 05:16:46PM +0000, Steven Price wrote:
> >>>>>>>> Note that in terms of the new page walking code, these new defines are
> >>>>>>>> only used when walking a page table without a VMA (which isn't currently
> >>>>>>>> done), so architectures which don't use p?d_large currently will work
> >>>>>>>> fine with the generic versions. They only need to provide meaningful
> >>>>>>>> definitions when switching to use the walk-without-a-VMA functionality.
> >>>>>>>
> >>>>>>> How other architectures would know that they need to provide the helpers
> >>>>>>> to get walk-without-a-VMA functionality? This looks very fragile to me.
> >>>>>>
> >>>>>> Yes, you've got a good point there. This would apply to the p?d_large
> >>>>>> macros as well - any arch which (inadvertently) uses the generic version
> >>>>>> is likely to be fragile/broken.
> >>>>>>
> >>>>>> I think probably the best option here is to scrap the generic versions
> >>>>>> altogether and simply introduce a ARCH_HAS_PXD_LARGE config option which
> >>>>>> would enable the new functionality to those arches that opt-in. Do you
> >>>>>> think this would be less fragile?
> >>>>>
> >>>>> These helpers are useful beyond pagewalker.
> >>>>>
> >>>>> Can we actually do some grinding and make *all* archs to provide correct
> >>>>> helpers? Yes, it's tedious, but not that bad.
> >>>>
> >>>> Many architectures simply cannot support non-leaf entries at the higher
> >>>> levels. I think letting the use a generic helper actually does make sense.
> >>>
> >>> I disagree.
> >>>
> >>> It's makes sense if the level doesn't exists on the arch.
> >>
> >> This is what patch 24 [1] of the series does - if the level doesn't
> >> exist then appropriate stubs are provided.
> >>
> >>> But if the level exists, it will be less frugile to ask the arch to
> >>> provide the helper. Even if it is dummy always-false.
> >>
> >> The problem (as I see it), is we need a reliable set of p?d_large()
> >> implementations to be able to walk arbitrary page tables. Either the
> >> entire functionality of walking page tables without a VMA has to be an
> >> opt-in per architecture, or we need to mandate that every architecture
> >> provide these implementations.
> > 
> > I agree that we need a reliable set of p?d_large(), but I'm still not
> > convinced that every architecture should provide these.
> > 
> > Why having generic versions if p?d_large() is more fragile, than e.g.
> > p??__access_permitted() or atomic ops?
> 
> Personally I feel having p?d_large implemented for each arch has the
> following benefits:
> 
>  * Matches p?d_present/p?d_none/p?d_bad which all similarly have to be
> implemented for all arches except for folded levels (when folded using
> the generic code).
> 
>  * Gives the architecture maintainers a heads-up and an opportunity to
> ensure that the implementations I've written are correct rather than
> silently picking up the generic version.
> 
>  * When adding a new architecture it will be obvious that p?d_large
> implementations are needed.
> 
> The benefits of having a generic version seem to be:
> 
>  * No boiler plate for the architectures that don't support large pages
> (saves a handful of lines).
> 
>  * Easier to merge (fewer patches).
> 
> While the last one is certainly appealing (to me at least), I'm not
> convinced the benefits of the generic version outweigh those of
> providing implementations per-arch.
> 
> Am I missing something?
> 
> > IMHO, adding those functions/macros for architectures that support large
> > pages and providing defines to avoid override of 'static inline' implementations
> > would be robust enough and will avoid unnecessary stubs in architectures
> > that don't have large pages.
> 
> Clearly at run time there's no difference in the "robustness" - the code
> generation should be the same. So it's purely down to development processes.
> 
> However, if you prefer I can resurrect the generic versions and drop the
> patches that simply add dummy implementations.

My concern was the code duplication, which didn't seem necessary. It's not
only about saving a handful of lines, but rather having as many of the code
shared by different architectures actually shared and not copied.

I'd really appreciate having the dummy versions in include/asm-generic
rather than all over arch/*/include/asm.
 
> Steve
> 

-- 
Sincerely yours,
Mike.

