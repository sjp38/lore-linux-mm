Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 88BECC433FF
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 07:39:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 36EC8217F4
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 07:39:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 36EC8217F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 794AD6B0003; Wed,  7 Aug 2019 03:39:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 71D2A6B0008; Wed,  7 Aug 2019 03:39:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6332C6B000A; Wed,  7 Aug 2019 03:39:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 190766B0003
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 03:39:15 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id r21so55595906edc.6
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 00:39:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=V76C7zDNIqrtLbbInwIByQ4lHslqfE4oQ+VegGsya7Q=;
        b=q2yA/Is9SOlNZ1FcSKWJ1lhvji0GY2VZ2oxO2cDuFG3fwUn2neXeaSmYec+tUFrkQc
         RZYG60yK0bCtdOFPSMufU7A6FNH9PwlTJ8b563gWBQLE5U5zZO9G6XkmYoUjpSfSJE5q
         +IsEPV8JudL64tM9noExU+aUzCCBO8dwEtVsjRJoxMbliZvdF0LMIgh8QiREbwMlB921
         Bf0BL+Ww5ncx6IjqYJOHzkqYy1Y1RNfTYZkfzAJQszjO5QKST3VgTwCZCk5P/NxPmGn4
         QhT33kO5SlF95+bwQxpHF6Qf1MnFS8pN43lIOFDAO4T4ae2JaxUsdqn1YwfbgvUaMEUh
         fV7A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Gm-Message-State: APjAAAVaU31V+b1rzkhzDgyVAe/+dp3zmAVUTjxjFxpS+Rs7PGsmZulP
	A7mH+g8BrwlSBmlX201Vremp8OckjHCWcXIc1KAVZO6kDe6B0IJJGgrZM3vc/qt7TYnQ4UwKEUu
	H7tZ352U+baDvb9jF21WRch+sT1A1Ct4Mc2WUpm6PH4mB/cxrqwPznPV1SqxULS3VIw==
X-Received: by 2002:a50:a4ef:: with SMTP id x44mr8313397edb.304.1565163554633;
        Wed, 07 Aug 2019 00:39:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxtemf02WOMwcHNLIHY5VrRrGIaeqYLY0P6dN9lV7qEGAGUzWLzvxNgp+phmV7xq9o/x1dI
X-Received: by 2002:a50:a4ef:: with SMTP id x44mr8313365edb.304.1565163553924;
        Wed, 07 Aug 2019 00:39:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565163553; cv=none;
        d=google.com; s=arc-20160816;
        b=WpZspzI+XKmNOw4jf6mNjZXbI4IMNyc2bBYmrExBLOpq5Mq0pVvhVv/WS6aHt6p3Bm
         X0zbbbJHl1OgYYHrJcg+kBAp1rQ33AhsAfzDem1F/ZIU1SfEadsKtcXJM9bUk8aFoG/A
         dcFlj2TyM5gMv6df1fCq9q5OtkGdnNncfBHoueC1N8sQDFy6PjFSP6lFCe/R91+2k3UU
         h1lsPgMR4lGgf7oU/m97iOifqTscwoin73iiFhrZEQlpVptdsyZW2sU4CjabJ1CsE0uG
         5o2hCzqyAD8LDyQmKo4BpaMUHVWGEIwoDKiZhUCgGPLYPJff68qyteZdqFvuDVNnpd4f
         /T8A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=V76C7zDNIqrtLbbInwIByQ4lHslqfE4oQ+VegGsya7Q=;
        b=01yEcoL8N5CT0MYTKlSTGcO8mmHO/yY6UakR08e3GDE0Z5Znp22AlkOV8bXJUfoEmu
         3Dktpeiruz0oQCn4LDhuWi7Jd37WSS3aO6CuMr3rumIagq1CEOQeLxjYTiqLx5kRVNAj
         f7ec8PVavCsYqNHmuXwvL7nty++PJAMoZhhhv4WwzpxrTp+l4CZ8PIUKRN/XOSQciU6z
         wN7hkjGRNGG33gFiRoDH106/IYrQH1EiXaQv0sceMuSt4vGr1sPmWotR9p2tn1sT3K0s
         gRSi+Poesm7kKIJlSjdnv1HVWgvS3xqSiYuT6zG+rulrxvkalbN/QyjTCuRAErm7VeMe
         Hhkg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f35si32819954edd.350.2019.08.07.00.39.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 00:39:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 0ABDCAEFC;
	Wed,  7 Aug 2019 07:39:12 +0000 (UTC)
Date: Wed, 7 Aug 2019 09:39:09 +0200
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
Message-ID: <20190807073909.GL11812@dhcp22.suse.cz>
References: <CAEemH2dMW6oh6Bbm=yqUADF+mDhuQgFTTGYftB+xAhqqdYV3Ng@mail.gmail.com>
 <47999e20-ccbe-deda-c960-473db5b56ea0@oracle.com>
 <CAEemH2d=vEfppCbCgVoGdHed2kuY3GWnZGhymYT1rnxjoWNdcQ@mail.gmail.com>
 <a65e748b-7297-8547-c18d-9fb07202d5a0@oracle.com>
 <27a48931-aff6-d001-de78-4f7bef584c32@oracle.com>
 <20190802041557.GA16274@hori.linux.bs1.fc.nec.co.jp>
 <54a5c9f5-eade-0d8f-24f9-bff6f19d4905@oracle.com>
 <20190805085740.GC7597@dhcp22.suse.cz>
 <7d78f6b9-afb8-79d1-003e-56de58fded00@oracle.com>
 <3c104b29-ffe2-07cb-440e-cb88d8e11acb@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3c104b29-ffe2-07cb-440e-cb88d8e11acb@oracle.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 06-08-19 17:07:25, Mike Kravetz wrote:
> On 8/5/19 10:36 AM, Mike Kravetz wrote:
> >>>>> Can you try this patch in your environment?  I am not sure if it will
> >>>>> be the final fix, but just wanted to see if it addresses issue for you.
> >>>>>
> >>>>> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> >>>>> index ede7e7f5d1ab..f3156c5432e3 100644
> >>>>> --- a/mm/hugetlb.c
> >>>>> +++ b/mm/hugetlb.c
> >>>>> @@ -3856,6 +3856,20 @@ static vm_fault_t hugetlb_no_page(struct mm_struct *mm,
> >>>>>  
> >>>>>  		page = alloc_huge_page(vma, haddr, 0);
> >>>>>  		if (IS_ERR(page)) {
> >>>>> +			/*
> >>>>> +			 * We could race with page migration (try_to_unmap_one)
> >>>>> +			 * which is modifying page table with lock.  However,
> >>>>> +			 * we are not holding lock here.  Before returning
> >>>>> +			 * error that will SIGBUS caller, get ptl and make
> >>>>> +			 * sure there really is no entry.
> >>>>> +			 */
> >>>>> +			ptl = huge_pte_lock(h, mm, ptep);
> >>>>> +			if (!huge_pte_none(huge_ptep_get(ptep))) {
> >>>>> +				ret = 0;
> >>>>> +				spin_unlock(ptl);
> >>>>> +				goto out;
> >>>>> +			}
> >>>>> +			spin_unlock(ptl);
> >>>>
> >>>> Thanks you for investigation, Mike.
> >>>> I tried this change and found no SIGBUS, so it works well.
> 
> Here is another way to address the issue.  Take the hugetlb fault mutex in
> the migration code when modifying the page tables.  IIUC, the fault mutex
> was introduced to prevent this same issue when there were two page faults
> on the same page (and we were unable to allocate an 'extra' page).  The
> downside to such an approach is that we add more hugetlbfs specific code
> to try_to_unmap_one.

I would rather go with the hugetlb_no_page which is better isolated.
-- 
Michal Hocko
SUSE Labs

