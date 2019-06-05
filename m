Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E2F8AC28CC6
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 14:22:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B616020684
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 14:22:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B616020684
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 303576B0006; Wed,  5 Jun 2019 10:22:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2D9CA6B0007; Wed,  5 Jun 2019 10:22:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 217A36B000A; Wed,  5 Jun 2019 10:22:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id CBAF66B0006
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 10:22:49 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id g20so5931621edm.22
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 07:22:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=m0CXrBO5lAniM9Fm8sKB+KtZsWCDEb/L6Wki2GLjN/8=;
        b=kBeaA1AxAN2qOdVk+0I2Cg+twXEGjJWcbfTzp0bSLvYUBV38r9EwLkfFgc3BfPaKsP
         xSJLSRIPPDDCI2mbTQt8USNJ93PUvQjqmS1jhmAW8r/5PdhRh6Wl1eXTVJoRZOe+r6J7
         2QxipbK4bZfsCJ2GzLYs6zEBaXYJkg/1TFlneIMWaHQfKYJCWy4BdBZqCvUHOQoWjP9s
         do2JLdCyYR/WbpHYRA+GLvnnRBVoBo1Y/G1wntSF+QqO/plZS/+TPcBcWgDLt2ZvZDop
         hvzYa+KJYnWAg2Y7Tr6gBI0jkx1aDrDoj9uICLJpMwGsEy9ySRanU5kIa5VrdPCerEnO
         hQXA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXD7vwknb9/CVhG4sRFcp0pt7durc2DqbRDVTg9qC711ijh5Tgy
	BT73IkfB4UBCp+xzkjFRfcNccrlEpZtosohFJw4eOcGvkhh74e2gNtyEnO5tTT7ynfMEzk5nGWP
	mPVbmqGAtCs8R2NeUnu9huNcXCfw6YSoEilJsWObW1pT7hJ/vXAEkxCcimUPApgg=
X-Received: by 2002:aa7:da97:: with SMTP id q23mr17436794eds.194.1559744569329;
        Wed, 05 Jun 2019 07:22:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwJw3R2/rZaXhy8aALlSp5NBL5aevmxmB0IXnP+7OtpDPPNXub1zvlUvciSgicZMTxCB6qV
X-Received: by 2002:aa7:da97:: with SMTP id q23mr17436700eds.194.1559744568377;
        Wed, 05 Jun 2019 07:22:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559744568; cv=none;
        d=google.com; s=arc-20160816;
        b=unP6mVkTereqwEeeYL5wmm5LOfiqguEdCilaDzMBAMU5eAiN2tXGE8HbBpcKi1SWc5
         b4J8Fd8MZ1GxVIhtC9NLsVlAHaNjDCb+GgVI8KlZwak1o+zFkkeo3+PTNMZD/2g1F8zv
         B2smX46HWmb+vUZfl8CaWa7PDjYY22cjcUERDvyTLU45xIWmqc3pEWr4fHttLDPylNp1
         9azAcF67p+JoG2vRMxO9BNhCXNzY8XkOuu7PdbPeWS3xt96UvVwWICvawNP9DtxdIqb6
         BRWVH4q7z8oq7ENKN4kUiM5klab97hBLqQR9jlCuxsCkvFzmtAM6pP7RvxSfXtpALfWi
         KFCA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=m0CXrBO5lAniM9Fm8sKB+KtZsWCDEb/L6Wki2GLjN/8=;
        b=uR53reMfAn1Viqvgnc+9M41EfbfZ8ZX5547nzPltBRt0YSN0EMoguZv1itIhzFu1Dx
         UcuUjm8yOec7d5yZEJb2VaE8mysrFJGISvCBXQCo3t3Iz5hQjqhtaKkRAwgUAFls0NQk
         M+yMYn1qcEs7nDwLTI9J3RpPpvPQlFwlk1Qg3v/+aCJJcGuUFU3ghClIZfHP2L6D9RMG
         DP+kbh1w1FkvPstcQEtLcX2TpwvXqEQKApPlmrX98KcDBp72BDvLd5kRvgrDaLzCB1FO
         Z5VojVS2zorhz+PxnyD9DmK9zTv6TT0ybL5FejVpGLBpk32EZqHa46WZd1SKsdkjOxxV
         PRAw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h12si1167247ede.48.2019.06.05.07.22.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jun 2019 07:22:48 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id B6684AFC7;
	Wed,  5 Jun 2019 14:22:47 +0000 (UTC)
Date: Wed, 5 Jun 2019 16:22:46 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Bharath Vedartham <linux.bhar@gmail.com>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, rientjes@google.com,
	khalid.aziz@oracle.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm: Remove VM_BUG_ON in __alloc_pages_node
Message-ID: <20190605142246.GH15685@dhcp22.suse.cz>
References: <20190605060229.GA9468@bharath12345-Inspiron-5559>
 <20190605070312.GB15685@dhcp22.suse.cz>
 <20190605130727.GA25529@bharath12345-Inspiron-5559>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190605130727.GA25529@bharath12345-Inspiron-5559>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 05-06-19 18:37:28, Bharath Vedartham wrote:
> [Not replying inline as my mail is bouncing back]
> 
> This patch is based on reading the code rather than a kernel crash. My
> thought process was that if an invalid node id was passed to
> __alloc_pages_node, it would be better to add a VM_WARN_ON and fail the
> allocation rather than crashing the kernel. 

This makes some sense to me because BUG_ONs are usually a wrong way to
handle wrong usage of the API. On the other hand VM_BUG_ON is special in
the way that production although some distributions enable it by default
IIRC.

> I feel it would be better to fail the allocation early in the hot path
> if an invalid node id is passed. This is irrespective of whether the
> VM_[BUG|WARN]_*s are enabled or not. I do not see any checks in the hot
> path for the node id, which in turn may cause NODE_DATA(nid) to fail to
> get the pglist_data pointer for the node id. 
> We can optimise the branch by wrapping it around in unlikely(), if
> performance is the issue?

unlikely will just move the return NULL ouside of the main code flow.
The check will still be done.

> What are your thoughts on this? 

I don't know. I would leave the code as it is now or remove the
VM_BUG_ON. I do not remember this would be catching any real issues in
the past.
-- 
Michal Hocko
SUSE Labs

