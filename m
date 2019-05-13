Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5AC6BC04AA7
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 19:49:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1AB0321019
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 19:49:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1AB0321019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ABDEB6B000A; Mon, 13 May 2019 15:49:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A6EB96B000C; Mon, 13 May 2019 15:49:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 95E696B000D; Mon, 13 May 2019 15:49:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 774B56B000A
	for <linux-mm@kvack.org>; Mon, 13 May 2019 15:49:33 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id g19so15415105qtb.18
        for <linux-mm@kvack.org>; Mon, 13 May 2019 12:49:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=6YlU5R2+RUhMosTwwDn27gdGgw6dH1xAClt6LM1dhJY=;
        b=NCmE1vHAA5LG+UuhopTqQ5Ue+55EFbx7hHLu4rFNEFImeT3eiIHLlJZ1fLpQcfUta2
         lncLcGaFsm1n4nwCFlg3UBhMx9ytAO0Cg2Xru7K++uoqnnD3ukYrf/g+Sx14f+M0xaw9
         HRO64ZPkJeROweGOnCU++uYgDChrmwd3Ru862cVhskDydtakaKPYY1oBoqsRWohoUopX
         6xxsJUW8M/11MF35flCqatD8BN/kKESV4P46sw4Tv3aGl25D75Q13NEqi4aKse5V/PJE
         fdwr8bVgOcnEzzbUsKqyXueAhjKPcb4102fK5QuYXtUV220sd0tQ+lwtl74A2NH3Ja5k
         S2HQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVaUgR5vO4ryEUBdWCRcpEEYWiwKAFzIW9HzZWtibtXftDZVmYn
	hUVXxZMGD9CjowGUmTdiJ2OMT4RNXgQ7KUC9ugsetTbC77cUlZ19oIKxUoUdQxFqAZzejAzaeCK
	QFgPd+z0gV328gzD+Gzu//ov57sg4kIEReoSasmCkLrF8fQgvj58xrVSngLPs1I4QcA==
X-Received: by 2002:a37:8843:: with SMTP id k64mr24074053qkd.8.1557776973263;
        Mon, 13 May 2019 12:49:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwClWPCo6vCFUvZmehGpXSdPYADjOw66VG3bqwdA9y1XjQ3jqlI7V/Xe3dMcep1I1gRjloy
X-Received: by 2002:a37:8843:: with SMTP id k64mr24073999qkd.8.1557776972512;
        Mon, 13 May 2019 12:49:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557776972; cv=none;
        d=google.com; s=arc-20160816;
        b=NA2rGpd6RTMWJGojUxrs9MXcyEPWTY7uIa1aL+a2VXEYYrrIeIQpuZLTr3NkWqq7Ey
         InAyM1ZPK90D32PzzzcokIr1cjChzz9YDJt0Ei7wUsPZqlvfnTckJ5O5bPyxGfehrike
         N/dfHgPgMxXK66E8WLiswYH+RonLMzOyeVnhm+9SeTZzMJQ3nX0BzQgmVwvZkU5lCr/m
         Dm1sXdHFZnqDm64DW/eLSBa41D7KANlouVaa26s5BzQWh6NOz4dihbBA4z4LpSWPDEJ5
         2d3C+KTj5IMpM0gE4JwhwLXUIHP+ytHCKdosjul4nJ03VYKGoYo2TCMFuE60cb6cmBby
         C0hg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=6YlU5R2+RUhMosTwwDn27gdGgw6dH1xAClt6LM1dhJY=;
        b=m11+nx7MJj8grsoSs0T7V5s44BKyCvC3WNSpjGlPlBGKO+i+PUfBNsQmJZ1NqPgS/L
         AttwgmvrAg5ZVzYbfPskj01TCDHEptE+nAM9UxKQnVvo9We5gn2hBan+t9GM6VT6hPge
         hfcpO1nKNRW3L4vyfrJstqdigjN4dT5s25tdusJBvEX20Np+0nwsn0IFv8nuSMXU6VhG
         cUBHwKF3vUdG77y39SLsvhylEJABgtQxij1mMhF0g3vhZcHT/+fbhH7X5WZUltyJQPOm
         K1zk3FWvck80MSNbpxT1ti+guZnZTmDK80Z9IdVwCIHRW5Qj0y9clMcil5Tssjz/riWx
         FEeA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j20si3448426qtj.18.2019.05.13.12.49.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 12:49:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id AF36B4623E;
	Mon, 13 May 2019 19:49:31 +0000 (UTC)
Received: from redhat.com (ovpn-112-22.rdu2.redhat.com [10.10.112.22])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 2E81C183A2;
	Mon, 13 May 2019 19:49:29 +0000 (UTC)
Date: Mon, 13 May 2019 15:49:26 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: "Kuehling, Felix" <Felix.Kuehling@amd.com>,
	Andrew Morton <akpm@linux-foundation.org>
Cc: "alex.deucher@amd.com" <alex.deucher@amd.com>,
	"airlied@gmail.com" <airlied@gmail.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>
Subject: Re: [PATCH 2/2] mm/hmm: Only set FAULT_FLAG_ALLOW_RETRY for
 non-blocking
Message-ID: <20190513194925.GA31365@redhat.com>
References: <20190510195258.9930-1-Felix.Kuehling@amd.com>
 <20190510195258.9930-3-Felix.Kuehling@amd.com>
 <20190510201403.GG4507@redhat.com>
 <65328381-aa0d-353d-68dc-81060e7cebdf@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <65328381-aa0d-353d-68dc-81060e7cebdf@amd.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Mon, 13 May 2019 19:49:31 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew can we get this 2 fixes line up for 5.2 ?

On Mon, May 13, 2019 at 07:36:44PM +0000, Kuehling, Felix wrote:
> Hi Jerome,
> 
> Do you want me to push the patches to your branch? Or are you going to 
> apply them yourself?
> 
> Is your hmm-5.2-v3 branch going to make it into Linux 5.2? If so, do you 
> know when? I'd like to coordinate with Dave Airlie so that we can also 
> get that update into a drm-next branch soon.
> 
> I see that Linus merged Dave's pull request for Linux 5.2, which 
> includes the first changes in amdgpu using HMM. They're currently broken 
> without these two patches.

HMM patch do not go through any git branch they go through the mmotm
collection. So it is not something you can easily coordinate with drm
branch.

By broken i expect you mean that if numabalance happens it breaks ?
Or it might sleep when you are not expecting it too ?

Cheers,
Jérôme

> 
> Thanks,
>    Felix
> 
> On 2019-05-10 4:14 p.m., Jerome Glisse wrote:
> > [CAUTION: External Email]
> >
> > On Fri, May 10, 2019 at 07:53:24PM +0000, Kuehling, Felix wrote:
> >> Don't set this flag by default in hmm_vma_do_fault. It is set
> >> conditionally just a few lines below. Setting it unconditionally
> >> can lead to handle_mm_fault doing a non-blocking fault, returning
> >> -EBUSY and unlocking mmap_sem unexpectedly.
> >>
> >> Signed-off-by: Felix Kuehling <Felix.Kuehling@amd.com>
> > Reviewed-by: Jérôme Glisse <jglisse@redhat.com>
> >
> >> ---
> >>   mm/hmm.c | 2 +-
> >>   1 file changed, 1 insertion(+), 1 deletion(-)
> >>
> >> diff --git a/mm/hmm.c b/mm/hmm.c
> >> index b65c27d5c119..3c4f1d62202f 100644
> >> --- a/mm/hmm.c
> >> +++ b/mm/hmm.c
> >> @@ -339,7 +339,7 @@ struct hmm_vma_walk {
> >>   static int hmm_vma_do_fault(struct mm_walk *walk, unsigned long addr,
> >>                            bool write_fault, uint64_t *pfn)
> >>   {
> >> -     unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_REMOTE;
> >> +     unsigned int flags = FAULT_FLAG_REMOTE;
> >>        struct hmm_vma_walk *hmm_vma_walk = walk->private;
> >>        struct hmm_range *range = hmm_vma_walk->range;
> >>        struct vm_area_struct *vma = walk->vma;
> >> --
> >> 2.17.1
> >>

