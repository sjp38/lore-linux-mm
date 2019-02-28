Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7B950C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 14:34:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 41D56214D8
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 14:34:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 41D56214D8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CE5BA8E0003; Thu, 28 Feb 2019 09:34:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C95738E0001; Thu, 28 Feb 2019 09:34:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B5CEC8E0003; Thu, 28 Feb 2019 09:34:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 622A18E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 09:34:09 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id m25so4768146edd.6
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 06:34:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Najr8rGJO3GqSucevKSP0rOhUhKjzQqEHySynwyedTc=;
        b=LL2E6xHk/UxzWPdBeM4RGK15Z0ivBaZTrNqpY9m3Ih+ah7tKape5wmUIlVUcEO41N+
         OfQ8NPtvrYMPL8qZe3MOXbpcIrtdBI15FFIIiqtGZURpEV5kdWx1uBcWZHqmDucc6l79
         nZOp0Ma/xLpnYdHyuxSHxzSJoGdSg+wAPrdIjO59vPIJJ/FTuGcFPtMmRyM4aqhKXawQ
         UZZjW6RGHUSjpvh/CrHq1t/z3j6Hp5oZrNNB/I+tRPRJ7vRsTHZg8cbX4ZLAQ6Zf+XEb
         6uZgBerb1UfL01EgaiM/sC96SKpqzvWwlH8AQUpoM/GRSmCDwm+qa/PYw9ddHxQckhXO
         E77w==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuZcgmUalE3+zF9bLT0C/pn8k79RZHkwGwYb6H1eg4jvmpoO+I3k
	EFFG0aNz6vPaolpqPBcEoKLxtV5rD7PQOmIbMU2Dr7+K5kzo9uX34T3NKIuJEZ6xYoHtFB3LPh9
	IWqAFj7y8EkmnIMxAjH6JJi3l7ZY+bC7uD4ig5YlM4G868VBsaRY484Z2hEh1JIk=
X-Received: by 2002:a05:6402:1817:: with SMTP id g23mr5657800edy.295.1551364448965;
        Thu, 28 Feb 2019 06:34:08 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ibv2nPzgcqDQv8xUMpi37NP8EeBnov/AYrh+e6NxuonR8Ev1WU0YP6n9bv0g+4guVV1TcQR
X-Received: by 2002:a05:6402:1817:: with SMTP id g23mr5657727edy.295.1551364447857;
        Thu, 28 Feb 2019 06:34:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551364447; cv=none;
        d=google.com; s=arc-20160816;
        b=E1UNfX1uXgnVxiE/bFl8WeOV8LeNYO+8d9v/iu04mnYOZS//C/TfugGQPdqO9ee6/m
         PWlUK9F8i9VSIlV16eU3lCTssAh4FtHzuOCeRuOGWHAlYp9tC1IrECB/HtLrkGQVLtOj
         V8QzfGzNRKWMbVlzEZ5a+Wc8xsrLKLlRUfm78Ec7PJ6JcOU4VTqXPwOVw1e2vCzfCVhx
         1/jozQRFtmLxTDvDG+J2zEVnlwNRz/NI759lSF/a0H9qsRul4dGMl1VhUAXFCz5pLaFc
         xTzYmmlE6RavlUS8AFmTyEeK7kaZyAHlXfigzDdxaarN7Td3l+MKkg13dK49xoF5RJIr
         nhWw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Najr8rGJO3GqSucevKSP0rOhUhKjzQqEHySynwyedTc=;
        b=GbM5j67E4+xHKCU5kjY0h4IjJU20rhNQvRDm9t+zM+0ImZQoOPQN15rFoDBxmmBkkD
         Jcm9xipPTgjy/6DhGsaUDLnZ5QeQE8fszRQo89aW+6Y09e6XzBAJeN7duPAchWhccLss
         Kx2yM2//nz3QJ3qTXcZ0L94oQ/YjSKbe1MPE0/BLgds/ZcsQVxV28U5nR3Rhx96QNqYh
         JtMlY2yS3Tz2tZah5FNVkts1RFMOdxbEyiznw9US1Ua/uj8UWsYrQMfU0T+3zI/5Zu2J
         cdBXjfSYJ3QBScF6X8s5YfBd0IWVkV9k4P9KUUigqmhKT9LBndkw/nMwvGIbBmkLK5z+
         4kYA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y20si1764325edd.385.2019.02.28.06.34.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Feb 2019 06:34:07 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id DCD5EAFF6;
	Thu, 28 Feb 2019 14:34:06 +0000 (UTC)
Date: Thu, 28 Feb 2019 15:34:05 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	akpm@linux-foundation.org, Alexey Kardashevskiy <aik@ozlabs.ru>,
	David Gibson <david@gibson.dropbear.id.au>,
	Andrea Arcangeli <aarcange@redhat.com>, mpe@ellerman.id.au,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v8 1/4] mm/cma: Add PF flag to force non cma alloc
Message-ID: <20190228143405.GF10588@dhcp22.suse.cz>
References: <20190227144736.5872-1-aneesh.kumar@linux.ibm.com>
 <20190227144736.5872-2-aneesh.kumar@linux.ibm.com>
 <1d083bf9-0beb-0c49-9aab-c6bc14da46ea@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1d083bf9-0beb-0c49-9aab-c6bc14da46ea@suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 28-02-19 13:20:03, Vlastimil Babka wrote:
> On 2/27/19 3:47 PM, Aneesh Kumar K.V wrote:
> > This patch adds PF_MEMALLOC_NOCMA which make sure any allocation in that context
> > is marked non-movable and hence cannot be satisfied by CMA region.
> > 
> > This is useful with get_user_pages_longterm where we want to take a page pin by
> > migrating pages from CMA region. Marking the section PF_MEMALLOC_NOCMA ensures
> > that we avoid unnecessary page migration later.
> > 
> > Suggested-by: Andrea Arcangeli <aarcange@redhat.com>
> > Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>
> > Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
> 
> +CC scheduler guys
> 
> Do we really take the last available PF flag just so that "we avoid
> unnecessary page migration later"?
> If yes, that's a third PF_MEMALLOC flag, should we get separate variable
> for gfp context at this point?

Yes, that sounds like a reasonable thing to do. Just note that xfs still
uses current_{set,restore}* api to handle PF_MEMALLOC_NOFS so that would
have to be moved over to the memalloc_nofs_{save,restore} API.

-- 
Michal Hocko

