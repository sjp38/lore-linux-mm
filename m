Return-Path: <SRS0=O33Z=PL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DA799C43387
	for <linux-mm@archiver.kernel.org>; Thu,  3 Jan 2019 15:05:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9FE1C2070D
	for <linux-mm@archiver.kernel.org>; Thu,  3 Jan 2019 15:05:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9FE1C2070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 22A7F8E007F; Thu,  3 Jan 2019 10:05:27 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1D73D8E0002; Thu,  3 Jan 2019 10:05:27 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 09FFE8E007F; Thu,  3 Jan 2019 10:05:27 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id C9CC98E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 10:05:26 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id w1so41584049qta.12
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 07:05:26 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=guPIJ+BlU5lY0xGS7zyHrMnMmO+7tolMjRlfMJNvnDk=;
        b=pc9xdAoXZN/Dg988pb8/zWWTlsbMuy7MS+uqUSKdg0I1tQbAdPZ2VK7Mk2NTaWlAIq
         DxjrnHHGfBf1utGPbyk7QPoHQqqbGdUtEdsB5V5CtQ7Cnuq7Jv8L9azMZINGZFFPyUfg
         BpWCb/KXl3VZUTeldhAVYtM4nGOHRtJkgXLHHgGFmk5qYvtRy/Q/Nq/q2C/FUIQfA7eo
         C1GenXIbeANaOw9AcPgFllBdbz4h078LU26LMSrZXFMWCYSz0XCMVmcKDP9dEMQadUMn
         3WzmgTPh4so680yBvWSYwsEDyKanDaVUoFLtu2sLOqXjUJdjWZdTm5Ocga/yPpHh52sv
         6tww==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukfB4ctSQf9yrfmD0lJsm1Yj6qba8EUHrMbxc+vb33zwJghvRxA+
	5+kmNOuNlmRtZXOPnDmWog+46QwQpmPPT+s/SPneYHSVllV/iwWKVy4iBEjpnEtCHkc9h6mHrfF
	JeXjPqaH8aQ+5Km4DldhcsWmnzRsyncvci8GqHB7y91ZkB/5y7grbSQpmN2njtoItCA==
X-Received: by 2002:a0c:f805:: with SMTP id r5mr47589495qvn.130.1546527926548;
        Thu, 03 Jan 2019 07:05:26 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4pkwWDhpExvyIeJt2iRQOfynkOM8Ch+7a1Kqd6nEEmnTWJlVx/DHUjN5jjvS6ut1bCqlfF
X-Received: by 2002:a0c:f805:: with SMTP id r5mr47589438qvn.130.1546527925888;
        Thu, 03 Jan 2019 07:05:25 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546527925; cv=none;
        d=google.com; s=arc-20160816;
        b=t1xdr/VHFs9hq375LPuw0c/rvHibxI7Q3Q7dsnlFEJrJ/oTdV2yZA9ol12tpIaHV6c
         /qBzjkjSEQN/FrjmT1qXwyEO5+G1q1gcnhe6EtkVOVj/MAy2KLr+wQIm9Df+dw/FwtLH
         5F926hgDRdFCkICExr/ad2P+wA5OL6AK8L30PH+kC3qLpyLBV4n3IxDbznH30SCEcCbH
         dzvlMrypLAUxEuhLrGVsj1nEh/C2yUquUJ22QXVH13AiB0BxGBrrI4tLTN08k3HUjDcN
         GPPnewXkQVBcr/4L2Y5x4TmvJa1veJ5+t14hjhxcq9LMCedxtxW9WHw5ssVlvqP+jnuJ
         4o6g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=guPIJ+BlU5lY0xGS7zyHrMnMmO+7tolMjRlfMJNvnDk=;
        b=lSp7jj2aLBVMafnl0Cw5z7ozt2b4b+uLMkPQNvZWUb0IodtidEcdjRHxY6F69vpLVE
         9a446mecGOwxg4/N+uhOMj/6fZGcaX3hrtk86+RfZC7x7eJMr58aTMxamSlH3YOLhXwz
         h2p9RuscHGA/KNlgSm6WSxDaqDajwIIJXRsutYAGurO83nZL456/s91cY+jrIjQ7meR6
         gDoYbbwFg1PcQeyNKbREIrHKkNrCXcxzDDtp2gJlm3Z0TuAvAGJzB6XNAyyX5gTbiw43
         3YWiQFvYNyibF27qKZ+nOEvnJ6/Eujm5CFbFrEHDVch/dvKooU0HK/x49pSuciq/+fh2
         0E1g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x1si3466347qkc.167.2019.01.03.07.05.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jan 2019 07:05:25 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9730085363;
	Thu,  3 Jan 2019 15:05:24 +0000 (UTC)
Received: from redhat.com (ovpn-123-124.rdu2.redhat.com [10.10.123.124])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 7A3AA5D6A6;
	Thu,  3 Jan 2019 15:05:23 +0000 (UTC)
Date: Thu, 3 Jan 2019 10:05:21 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-xfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] Initialise mmu_notifier_range correctly
Message-ID: <20190103150521.GF3395@redhat.com>
References: <20190103002126.GM6310@bombadil.infradead.org>
 <20190103143116.GB3395@redhat.com>
 <20190103144313.GR6310@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190103144313.GR6310@bombadil.infradead.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Thu, 03 Jan 2019 15:05:25 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190103150521.1sSRdffh0jElZ95WurOnueikU0zgcxN11NTA4LMMmSg@z>

On Thu, Jan 03, 2019 at 06:43:13AM -0800, Matthew Wilcox wrote:
> On Thu, Jan 03, 2019 at 09:31:16AM -0500, Jerome Glisse wrote:
> > On Wed, Jan 02, 2019 at 04:21:26PM -0800, Matthew Wilcox wrote:
> > > 
> > > One of the paths in follow_pte_pmd() initialised the mmu_notifier_range
> > > incorrectly.
> > > 
> > > Signed-off-by: Matthew Wilcox <willy@infradead.org>
> > > Fixes: ac46d4f3c432 ("mm/mmu_notifier: use structure for invalidate_range_start/end calls v2")
> > > Tested-by: Dave Chinner <dchinner@redhat.com>
> > 
> > Actually now that i have read the code again this is not ok to
> > do so. The caller of follow_pte_pmd() will call range_init and
> > follow pmd will only update the range address. So existing code
> > is ok.
> 
> I think you need to re-read your own patch.
> 
> `git show ac46d4f3c43241ffa23d5bf36153a0830c0e02cc`
> 
> @@ -4058,10 +4059,10 @@ static int __follow_pte_pmd(struct mm_struct *mm, unsigned long address,
>                 if (!pmdpp)
>                         goto out;
>  
> -               if (start && end) {
> -                       *start = address & PMD_MASK;
> -                       *end = *start + PMD_SIZE;
> -                       mmu_notifier_invalidate_range_start(mm, *start, *end);
> +               if (range) {
> +                       mmu_notifier_range_init(range, mm, address & PMD_MASK,
> +                                            (address & PMD_MASK) + PMD_SIZE);
> +                       mmu_notifier_invalidate_range_start(range);
> 
> ... so it's fine to call range_init() *here*.
> 
> @@ -4069,17 +4070,17 @@ static int __follow_pte_pmd(struct mm_struct *mm, unsign
> ed long address,
> [...]
>         if (pmd_none(*pmd) || unlikely(pmd_bad(*pmd)))
>                 goto out;
>  
> -       if (start && end) {
> -               *start = address & PAGE_MASK;
> -               *end = *start + PAGE_SIZE;
> -               mmu_notifier_invalidate_range_start(mm, *start, *end);
> +       if (range) {
> +               range->start = address & PAGE_MASK;
> +               range->end = range->start + PAGE_SIZE;
> +               mmu_notifier_invalidate_range_start(range);
> 
> ... but then *not* here later in the same function?  You're not making
> any sense.

Ok i see that the patch that add the reason why mmu notifier is
call have been drop. So yes using range_init in follow_pte_pmd
is fine. With that other patch the reasons is set by the caller
of follow_pte_pmd and using range_init would have overwritten
it.

So this patch is fine for current tree. Sorry i was thinking with
the other patch included in mind.

Cheers,
Jérôme

