Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4C009C28CC7
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 13:58:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1B3E22085A
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 13:58:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1B3E22085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8FF7E6B0266; Mon, 10 Jun 2019 09:58:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 888AF6B0269; Mon, 10 Jun 2019 09:58:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 750D76B026A; Mon, 10 Jun 2019 09:58:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2469C6B0266
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 09:58:26 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id l53so15530287edc.7
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 06:58:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=XrAhha77OFPTFlF7KSQShELx6jUVmZeLDMg/Tr5gqzY=;
        b=Y2ne7uPjRnYs36rZoouvCppssDURcxK7uuu7O34PXwFql//2RbTYPG2kZvkZlDfd0e
         EWKCX9u4qv9Uzwak3Ze6RePyFgWPpR28rrxwpod9BDdokU+Lf2YO9tZgIc1aEHZMOs3w
         m5sQoE1YORnTh1s6+H+c0R9PlW3ztv+0RkgSL+9Bgu+eC+k7VNSu1E0Soa2TOUOkYU9x
         vlf2tjZxTzniq3XjQGVefPrI1RSp9VC/OH1ZRzotXbICSt1ANzVeZwgIkkhzBDDAmsmZ
         pZk2pQ+vdhBlaIdxIECGB7pXqrQT562ZBjbBEX79NPGtpJsgS1LYrMMfmQ86uPLVIKh5
         vHBA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVrd0GEYXl/YuoFKbKOBY5uFX8hhxJz2QfHTGn7ZDmWPXr+980+
	MZFig0gQQ7IG0iXYsB7GokgmN9WiD8auQB3AEpEOqgXRxeJYnH0ODxb5wzfnyxmdOlPxzg+NZGL
	2oHMW7ERDMHPpcfPhw+KcQkCzUEeyWM6H5BqAWGWYR2Y246tAE9UhvadDr2G4H88=
X-Received: by 2002:a17:906:1942:: with SMTP id b2mr59012389eje.272.1560175105667;
        Mon, 10 Jun 2019 06:58:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzxxHm/13WhXnWaC1rlZfkUiMeSFSgMRI8kAYV2vFH2ngwMHwxAapD9RNHcWXSTjdnOsDJc
X-Received: by 2002:a17:906:1942:: with SMTP id b2mr59012336eje.272.1560175104839;
        Mon, 10 Jun 2019 06:58:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560175104; cv=none;
        d=google.com; s=arc-20160816;
        b=V9X5hPhv1dBWy+imbqvpk5w+OabdjLMP9IV1YxZ/MSOISOeAUbb2jVbf/JbW0FtXMy
         /rJQwrtUxvCb++LWVFHPTviQ39ozhbrnnU9z/emJjKKTMIUDjMz24BVRsekqJiw1fd2P
         oS6RpTdmkSRwpcIDYzYpgxKbzKJQ2siOa3LfB1aHtjOI8ZIeY11osXpaItRCqNnit75O
         PrDuM4Oyt3hVoCXQMiH/J+RZfUvYBZKjp2LwA6ZfELRZTyDYZPA4RZn+TwkCsVS01Z7Q
         0ar9+ja3BlFIsVvakENcudBOaxMGaiGDXQin4ljDqhkB76m2kbf+rcs0U0/H4HAu5Yo8
         XLkQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=XrAhha77OFPTFlF7KSQShELx6jUVmZeLDMg/Tr5gqzY=;
        b=qUDJXjxhz/zI+v6uj8iZEANyJMri7gDh3GZSNnrt2ei1lhOPTJyiuqZ5+a/x9cHT07
         pMf2nAtGu2L4rWi8/9w6rt63vgA+KhAfvkfiV8RECD/yt0iL6TUl+55efG1u94tMqe7h
         46+MyKmwW2mrpyGKyJmRTe4VCgADI32/bZ3abfQonPCImMxqerkcxD0E7IprEGCrOg0T
         8mBBLMnHoJU8VVpzwbDNK5E4M46uR0YO+1HtayloFqn2stCRNHeQ2FrQ6eTs4okOUfDX
         lvSha689tIOmRxywKy5o7wf08UM2n5GoLlH2YzFxVDQGik7AK9XIPMlehybwCXbjMhJm
         XVqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t24si2122173edd.357.2019.06.10.06.58.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jun 2019 06:58:24 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 2EFEDABD2;
	Mon, 10 Jun 2019 13:58:24 +0000 (UTC)
Date: Mon, 10 Jun 2019 15:58:23 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Stable tree <stable@vger.kernel.org>
Cc: Greg KH <gregkh@linuxfoundation.org>, linux-mm@kvack.org,
	LKML <linux-kernel@vger.kernel.org>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Jann Horn <jannh@google.com>, Oleg Nesterov <oleg@redhat.com>,
	Peter Xu <peterx@redhat.com>, Mike Rapoport <rppt@linux.ibm.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Joel Fernandes <joel@joelfernandes.org>
Subject: Re: [PATCH stable 4.4 v2] coredump: fix race condition between
 mmget_not_zero()/get_task_mm() and core dumping
Message-ID: <20190610135823.GI30967@dhcp22.suse.cz>
References: <20190604094953.26688-1-mhocko@kernel.org>
 <20190610074635.2319-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190610074635.2319-1-mhocko@kernel.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Just a heads up. Ajay Kaher has noticed that mlx4 driver is missing the
check in 4.14 [1] and 4.4 seems to have the same problem. I will wait
for more review before reposting v3. The incremental diff is:

diff --git a/drivers/infiniband/hw/mlx4/main.c b/drivers/infiniband/hw/mlx4/main.c
index 67c4c73343d4..6968154a073e 100644
--- a/drivers/infiniband/hw/mlx4/main.c
+++ b/drivers/infiniband/hw/mlx4/main.c
@@ -1042,6 +1042,8 @@ static void mlx4_ib_disassociate_ucontext(struct ib_ucontext *ibcontext)
 	 * mlx4_ib_vma_close().
 	 */
 	down_write(&owning_mm->mmap_sem);
+	if (!mmget_still_valid(owning_mm))
+		goto skip_mm;
 	for (i = 0; i < HW_BAR_COUNT; i++) {
 		vma = context->hw_bar_info[i].vma;
 		if (!vma)
@@ -1061,6 +1063,7 @@ static void mlx4_ib_disassociate_ucontext(struct ib_ucontext *ibcontext)
 		context->hw_bar_info[i].vma->vm_ops = NULL;
 	}
 
+skip_mm:
 	up_write(&owning_mm->mmap_sem);
 	mmput(owning_mm);
 	put_task_struct(owning_process);
-- 
Michal Hocko
SUSE Labs

