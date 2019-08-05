Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1A8D2C0650F
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 08:57:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A3EC420B1F
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 08:57:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A3EC420B1F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DCE3C6B0003; Mon,  5 Aug 2019 04:57:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D7DF16B0005; Mon,  5 Aug 2019 04:57:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C47B46B0006; Mon,  5 Aug 2019 04:57:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7573A6B0003
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 04:57:45 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id b12so51121532eds.14
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 01:57:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=mgwKES9TW6wOqRkJaFCixEX6avBI5HnJDplNKfgJbiw=;
        b=eQTjYuEBOFabMwrTsva8Yta1X69LT5Wny8vx/CdVu4Hj/MBazax4huDho9ZoSYCugk
         wJu+II3EVJTXd6PObwYIjW19JOmxmJ/s42eT/MBNFxviaNOo1zeFPQuACvBPtva3sxbP
         SqtTELokYD3zNj447VCzvIpkDuAKjjYkdELqOKy8kTXmFoFO5CB0zcjW+tEopvFZ+q9p
         cirdlhDZ6ofks+4JQ1rUS3hhLuL0gvqa0XgzQPehMIUkN/G2GHia5aiXM2KYP6FFpEE+
         Fnb4OvkSteA5nI/gfCRqtWbrQ4m+XyeJkWnl/GadXLploa5OwhuwPkaH6V/TDeZUglRJ
         q3Aw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Gm-Message-State: APjAAAUv7owZPQS07tsFYl1YxRYJCRlCfmrGgLDFFxjVZuzSLx/WvxjD
	jvpVG4d/OZKtnnIGqsa3cAV57bq5g8GGKri2mGQTtnd8qfAsNi6U+Gi9x0C0lYCvr6Sh3RO5M1R
	tJQ+1vvLfHYOCLipMMkK72mb9jM2xB3iQEC3ekuwbk+ZYMQx/QJ7Eu4b4GQZQcyXqqQ==
X-Received: by 2002:a50:b362:: with SMTP id r31mr135139810edd.14.1564995465039;
        Mon, 05 Aug 2019 01:57:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxkKFq75MIPnUaMqzutoYlIB+HqDbrr25s+1Rphvb5dOql8jkE0xCNh2mSVF4Ib7AL19L+S
X-Received: by 2002:a50:b362:: with SMTP id r31mr135139774edd.14.1564995464204;
        Mon, 05 Aug 2019 01:57:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564995464; cv=none;
        d=google.com; s=arc-20160816;
        b=utuB6xZM+K9KFHNLpZlb8nk+/D4ejiC9vRlfK4YfQViWXzPYgmJD32U9eZxDiOCATI
         QblaILyUxeshwGZ1SGHoDTBimvhOZBM8QSB9JXEYafjPyCf5eITSWuxwk1ggTT/sCuYq
         pJk1Y8lhcgfq2603EFtHrAyS1n9LT7xNEiywpXfSLAkg5v0yvoMHxGCCA7asEWUvp6Oc
         o5dkHacVpMDa73MKuCe8EqP9+ze/19zxFb8mNkGIIWeCu1GBEwsPwsAgzW0uVGMQEU+L
         JIivDXOqQRJTY1aegSB+Zf6vfRtCQ0lfpF6T0tX0e7t4rnXR6iFQXB/Y6FGypyR2efiS
         emww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=mgwKES9TW6wOqRkJaFCixEX6avBI5HnJDplNKfgJbiw=;
        b=bO7sKIjFAjVK6yQvSyJpeN2tr1NEF125NUSHtgBR+1CZxqp/JCuxOFeDsfI/QeWPVr
         /z0L+EFoUS32sAaWl94KdVysmQr954Jv/XTUnm7tpeyI63GOM68kxPhAZA4bGbZoRyez
         Oc1BWKhJq46nYPulMs2Ypul9Iw+YIKh9cnCOxn4iuGoZWQn5OLB9v1fd8oD3tdu3H5s5
         lj8RTlZedMa/c9mKC3SgCwTKvRb8UydsRshvihrObTDExhGVEIVa394/XVPRprTyIMvs
         H6UKy1mihs7IOgcHrrbeATryVTpJzAWR4brBNN+SSlGvMJdUf4bxoqbRL99bPbcJyinT
         vX4w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p55si30128762edc.414.2019.08.05.01.57.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Aug 2019 01:57:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 761DDAD22;
	Mon,  5 Aug 2019 08:57:43 +0000 (UTC)
Date: Mon, 5 Aug 2019 10:57:40 +0200
From: Michal Hocko <mhocko@suse.com>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
	Li Wang <liwang@redhat.com>, Linux-MM <linux-mm@kvack.org>,
	LTP List <ltp@lists.linux.it>,
	"xishi.qiuxishi@alibaba-inc.com" <xishi.qiuxishi@alibaba-inc.com>,
	Cyril Hrubis <chrubis@suse.cz>
Subject: Re: [MM Bug?] mmap() triggers =?utf-8?Q?SI?=
 =?utf-8?B?R0JVUyB3aGlsZSBkb2luZyB0aGXigIsg4oCLbnVtYV9tb3ZlX3BhZ2VzKA==?=
 =?utf-8?Q?=29?= for offlined hugepage in background
Message-ID: <20190805085740.GC7597@dhcp22.suse.cz>
References: <CAEemH2dMW6oh6Bbm=yqUADF+mDhuQgFTTGYftB+xAhqqdYV3Ng@mail.gmail.com>
 <47999e20-ccbe-deda-c960-473db5b56ea0@oracle.com>
 <CAEemH2d=vEfppCbCgVoGdHed2kuY3GWnZGhymYT1rnxjoWNdcQ@mail.gmail.com>
 <a65e748b-7297-8547-c18d-9fb07202d5a0@oracle.com>
 <27a48931-aff6-d001-de78-4f7bef584c32@oracle.com>
 <20190802041557.GA16274@hori.linux.bs1.fc.nec.co.jp>
 <54a5c9f5-eade-0d8f-24f9-bff6f19d4905@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54a5c9f5-eade-0d8f-24f9-bff6f19d4905@oracle.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 02-08-19 10:42:33, Mike Kravetz wrote:
> On 8/1/19 9:15 PM, Naoya Horiguchi wrote:
> > On Thu, Aug 01, 2019 at 05:19:41PM -0700, Mike Kravetz wrote:
> >> There appears to be a race with hugetlb_fault and try_to_unmap_one of
> >> the migration path.
> >>
> >> Can you try this patch in your environment?  I am not sure if it will
> >> be the final fix, but just wanted to see if it addresses issue for you.
> >>
> >> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> >> index ede7e7f5d1ab..f3156c5432e3 100644
> >> --- a/mm/hugetlb.c
> >> +++ b/mm/hugetlb.c
> >> @@ -3856,6 +3856,20 @@ static vm_fault_t hugetlb_no_page(struct mm_struct *mm,
> >>  
> >>  		page = alloc_huge_page(vma, haddr, 0);
> >>  		if (IS_ERR(page)) {
> >> +			/*
> >> +			 * We could race with page migration (try_to_unmap_one)
> >> +			 * which is modifying page table with lock.  However,
> >> +			 * we are not holding lock here.  Before returning
> >> +			 * error that will SIGBUS caller, get ptl and make
> >> +			 * sure there really is no entry.
> >> +			 */
> >> +			ptl = huge_pte_lock(h, mm, ptep);
> >> +			if (!huge_pte_none(huge_ptep_get(ptep))) {
> >> +				ret = 0;
> >> +				spin_unlock(ptl);
> >> +				goto out;
> >> +			}
> >> +			spin_unlock(ptl);
> > 
> > Thanks you for investigation, Mike.
> > I tried this change and found no SIGBUS, so it works well.
> > 
> > I'm still not clear about how !huge_pte_none() becomes true here,
> > because we enter hugetlb_no_page() only when huge_pte_none() is non-null
> > and (racy) try_to_unmap_one() from page migration should convert the
> > huge_pte into a migration entry, not null.
> 
> Thanks for taking a look Naoya.
> 
> In try_to_unmap_one(), there is this code block:
> 
> 		/* Nuke the page table entry. */
> 		flush_cache_page(vma, address, pte_pfn(*pvmw.pte));
> 		if (should_defer_flush(mm, flags)) {
> 			/*
> 			 * We clear the PTE but do not flush so potentially
> 			 * a remote CPU could still be writing to the page.
> 			 * If the entry was previously clean then the
> 			 * architecture must guarantee that a clear->dirty
> 			 * transition on a cached TLB entry is written through
> 			 * and traps if the PTE is unmapped.
> 			 */
> 			pteval = ptep_get_and_clear(mm, address, pvmw.pte);
> 
> 			set_tlb_ubc_flush_pending(mm, pte_dirty(pteval));
> 		} else {
> 			pteval = ptep_clear_flush(vma, address, pvmw.pte);
> 		}
> 
> That happens before setting the migration entry.  Therefore, for a period
> of time the pte is NULL (huge_pte_none() returns true).
> 
> try_to_unmap_one holds the page table lock, but hugetlb_fault does not take
> the lock to 'optimistically' check huge_pte_none().  When huge_pte_none
> returns true, it calls hugetlb_no_page which is where we try to allocate
> a page and fails.
> 
> Does that make sense, or am I missing something?
> 
> The patch checks for this specific condition: someone changing the pte
> from NULL to non-NULL while holding the lock.  I am not sure if this is
> the best way to fix.  But, it may be the easiest.

Please add a comment to explain this because this is quite subtle and
tricky. Unlike the regular page fault hugetlb_no_page is protected by a
large lock so a retry check seems unexpected.

Thanks!
-- 
Michal Hocko
SUSE Labs

