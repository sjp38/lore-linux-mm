Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CA487C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 22:40:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7D4402173C
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 22:40:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7D4402173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1B5586B0003; Thu, 28 Mar 2019 18:40:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 163356B0006; Thu, 28 Mar 2019 18:40:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 029086B0007; Thu, 28 Mar 2019 18:40:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id D0D6F6B0003
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 18:40:37 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id n1so389270qte.12
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 15:40:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=ph4LFRf/JjPQy6NEZ9xZPlxUMh71frMrDkMmCpZGto4=;
        b=cQ+7SQVgnOONfKgrZH/D3nyBZR6iixu5dt4czSzOSOKAApyL0vlgAL6SWI6FR6vaR+
         cqDFo1/kjuPqyH/M9NdkifgR/UNfCujlcUQTLhR8VC7OyqAIIrF4NH5NlOWFU6UInvUz
         VSm4x+YhRkvahP9pSB7OJ7XaiWCsor2tGMOkWB+aqMKsBq3/xyh7z+YDEh+o2dmyfayx
         UcN2vka3CUfQS9G3x1U03VZCzNZuw+3eFcvwzJbZVS3Rpiik474Dy77vNPbQppSfbU/m
         ScB+SQie080v8yPS3k+fcLb4ceHD2oSnbrDUNJPVretoTX/yMhUcTYN9JMC9rMahCd4b
         rUKQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWRyoXQ35ULm3PqwaAR6wi1j7TO/kSu/P5qN/Zz7AM1gfeyFyU+
	JqZjv5q7X5ogvsFcSdGQQdcp7pwn2kgzmGIZ715HR4bfBi/eVPsrtVt13DmEtkn2qXPt/G/B2uX
	CKlsZ2UecSICjhMGpwqYkqfcI3h5qMpmxjs7mUnQfZEHiZGaUJyEDWUSYlhgQDHJDzQ==
X-Received: by 2002:ac8:392c:: with SMTP id s41mr38059526qtb.250.1553812837593;
        Thu, 28 Mar 2019 15:40:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz2lmNhlGl2XvI45MkzkCZpbSzlKzIpxCR1zFIDXhmG/kRIwqj+9uYyD9WCLURo0GWb1KAZ
X-Received: by 2002:ac8:392c:: with SMTP id s41mr38059478qtb.250.1553812836893;
        Thu, 28 Mar 2019 15:40:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553812836; cv=none;
        d=google.com; s=arc-20160816;
        b=t1zM9ggDv4ebWeMNxjGsR0ZCyinaExxqrroUOXZdcRsNV14A+0mELqfaGe7xd5plIh
         D2hhUE12IClTjYQu5ypHHOl0rRo/l80L6MMBod6pqFKLUg6YC0c171KmnPMJXlx3Fk1o
         6aZE4Zt7A97M2wkspanCdl0JtZFNTen/ixBmWZInlzr1Iv+4+QgaFDO1Z8TBFIGvpxFW
         U/5qjFZl5to5lFSIaiBeyJXbK3g7D0MHFdrTh8aJcT1wV/FDcGXa4BjjT6P0pLGbfChT
         nFvkvaP4a/e68349xNL/VDSHzrWPo4Bb9ib0+HD8Y6awd9wPJz6UNvXx+EvXJ65aa6Wc
         FMgQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=ph4LFRf/JjPQy6NEZ9xZPlxUMh71frMrDkMmCpZGto4=;
        b=k2oufc0QVX3C8b48UZu0CUWOniniYKsYR6ouAVWUtzM/4KkP0vbS3HNcCGvf6cB1YP
         zofxIQ6wnmm4umcJ9Y/QlVGV0W9O6npWeWj+WH7BXjwdmrPff3gg71YBhRcs55/bTUaz
         gOpTVFB76wWbvm7VH0fdYI6RszIXbciL9uUmOKutTT7UdBAbuYOXrYUbdKb4kJNfbTwP
         1Mpxj1uWMobKWlQqHXXxFQshqWSYhofVarQEmpAW40NKE5CLEK5eaTSbAtPfIPtBvOlT
         hyFielWTT454HwCW0dGc59B1ETH8VxhwxmToQE1q38tCMLda5wfGIzal5sK3jiM/JXJY
         x07w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m5si76655qkd.82.2019.03.28.15.40.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 15:40:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id F271D307D85B;
	Thu, 28 Mar 2019 22:40:35 +0000 (UTC)
Received: from redhat.com (ovpn-121-118.rdu2.redhat.com [10.10.121.118])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id BBA655C223;
	Thu, 28 Mar 2019 22:40:34 +0000 (UTC)
Date: Thu, 28 Mar 2019 18:40:32 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: John Hubbard <jhubbard@nvidia.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH v2 10/11] mm/hmm: add helpers for driver to safely take
 the mmap_sem v2
Message-ID: <20190328224032.GH13560@redhat.com>
References: <20190325144011.10560-1-jglisse@redhat.com>
 <20190325144011.10560-11-jglisse@redhat.com>
 <9df742eb-61ca-3629-a5f4-8ad1244ff840@nvidia.com>
 <20190328213047.GB13560@redhat.com>
 <a16efd42-3e2b-1b72-c205-0c2659de2750@nvidia.com>
 <20190328220824.GE13560@redhat.com>
 <068db0a8-fade-8ed1-3b9d-c29c27797301@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <068db0a8-fade-8ed1-3b9d-c29c27797301@nvidia.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Thu, 28 Mar 2019 22:40:36 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 28, 2019 at 03:25:39PM -0700, John Hubbard wrote:
> On 3/28/19 3:08 PM, Jerome Glisse wrote:
> > On Thu, Mar 28, 2019 at 02:41:02PM -0700, John Hubbard wrote:
> >> On 3/28/19 2:30 PM, Jerome Glisse wrote:
> >>> On Thu, Mar 28, 2019 at 01:54:01PM -0700, John Hubbard wrote:
> >>>> On 3/25/19 7:40 AM, jglisse@redhat.com wrote:
> >>>>> From: Jérôme Glisse <jglisse@redhat.com>
> [...]
> >>
> >>>>
> >>>> If you insist on having this wrapper, I think it should have approximately 
> >>>> this form:
> >>>>
> >>>> void hmm_mirror_mm_down_read(...)
> >>>> {
> >>>> 	WARN_ON(...)
> >>>> 	down_read(...)
> >>>> } 
> >>>
> >>> I do insist as it is useful and use by both RDMA and nouveau and the
> >>> above would kill the intent. The intent is do not try to take the lock
> >>> if the process is dying.
> >>
> >> Could you provide me a link to those examples so I can take a peek? I
> >> am still convinced that this whole thing is a race condition at best.
> > 
> > The race is fine and ok see:
> > 
> > https://cgit.freedesktop.org/~glisse/linux/commit/?h=hmm-odp-v2&id=eebd4f3095290a16ebc03182e2d3ab5dfa7b05ec
> > 
> > which has been posted and i think i provided a link in the cover
> > letter to that post. The same patch exist for nouveau i need to
> > cleanup that tree and push it.
> 
> Thanks for that link, and I apologize for not keeping up with that
> other review thread.
> 
> Looking it over, hmm_mirror_mm_down_read() is only used in one place.
> So, what you really want there is not a down_read() wrapper, but rather,
> something like
> 
> 	hmm_sanity_check()
> 
> , that ib_umem_odp_map_dma_pages() calls.

Why ? The device driver pattern is:
    if (hmm_is_it_dying()) {
        // handle when process die and abort the fault ie useless
        // to call within HMM
    }
    down_read(mmap_sem);

This pattern is common within nouveau and RDMA and other device driver in
the work. Hence why i am replacing it with just one helper. Also it has the
added benefit that changes being discussed around the mmap sem will be easier
to do as it avoid having to update each driver but instead it can be done
just once for the HMM helpers.

> 
> 
> > 
> >>>
> >>>
> >>>>
> >>>>> +{
> >>>>> +	struct mm_struct *mm;
> >>>>> +
> >>>>> +	/* Sanity check ... */
> >>>>> +	if (!mirror || !mirror->hmm)
> >>>>> +		return -EINVAL;
> >>>>> +	/*
> >>>>> +	 * Before trying to take the mmap_sem make sure the mm is still
> >>>>> +	 * alive as device driver context might outlive the mm lifetime.
> >>>>
> >>>> Let's find another way, and a better place, to solve this problem.
> >>>> Ref counting?
> >>>
> >>> This has nothing to do with refcount or use after free or anthing
> >>> like that. It is just about checking wether we are about to do
> >>> something pointless. If the process is dying then it is pointless
> >>> to try to take the lock and it is pointless for the device driver
> >>> to trigger handle_mm_fault().
> >>
> >> Well, what happens if you let such pointless code run anyway? 
> >> Does everything still work? If yes, then we don't need this change.
> >> If no, then we need a race-free version of this change.
> > 
> > Yes everything work, nothing bad can happen from a race, it will just
> > do useless work which never hurt anyone.
> > 
> 
> OK, so let's either drop this patch, or if merge windows won't allow that,
> then *eventually* drop this patch. And instead, put in a hmm_sanity_check()
> that does the same checks.

RDMA depends on this, so does the nouveau patchset that convert to new API.
So i do not see reason to drop this. They are user for this they are posted
and i hope i explained properly the benefit.

It is a common pattern. Yes it only save couple lines of code but down the
road i will also help for people working on the mmap_sem patchset.


Cheers,
Jérôme

