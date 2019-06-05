Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65D4FC28CC5
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 07:03:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1CF34206BA
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 07:03:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1CF34206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7813C6B000C; Wed,  5 Jun 2019 03:03:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 732F76B000D; Wed,  5 Jun 2019 03:03:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6208C6B000E; Wed,  5 Jun 2019 03:03:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1409E6B000C
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 03:03:16 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id d27so4286453eda.9
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 00:03:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=lOKRg+b53UEoqXjg6WzbI+0KlkzCni9JGDcVfpiMNCM=;
        b=ZKm9/67ZrptpBBnFmefeOaMY3QeSYjBxeIYfMMegakxoAmBtbUoTCb8I3MHe+UJCRm
         KZWbcHnNsb+pDDpjO62gKfdv74YdKbMelzBPQ0OXxaPBKCbVwX7rf4qOFRmbHFpMHZbY
         +c+PTNbBtX3hkvioPmNx4l7BYzulrkHIxDTEUiC0zOWGD2LpzA1uLm/uEuSVmUTjefQG
         lLNJeQ6zXfb5/nlUAJj1JkqWQHJBKIug+mZFO+Lyu9PsRCCGOVba8GjuJk/+DBRAodpW
         tcRVBe2L3gKk+FW5COcgN6THxyTTVW4/NGmnL6EuzO8tRwtTScZTHdereNbLb45OPE5h
         zEow==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAX/9CstGlCivmK7CuS1zAILVyUN8EALY3nEo/hN66eFaMX/lZJh
	REC9XZPFMPuJDByD8Ik/yKJt6wp3Gns7f9eqEgOAeY01X9cDio5U7UnUDMB1AZbAhPaXYM/4fxI
	Hu8jbSaw6gi7cAnU9zLZCWukSP3fLlqhpOJ9Zi/Y3vV8A+u32S87pTsCivBMMgBE=
X-Received: by 2002:a50:ba83:: with SMTP id x3mr41089763ede.266.1559718195592;
        Wed, 05 Jun 2019 00:03:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqybW3mvi6rLu6S/i/srN354h3gzsqfHUgfZcckVrX1UEWCx2niKYv/sdWcTx0KtHyWxLtI0
X-Received: by 2002:a50:ba83:: with SMTP id x3mr41089679ede.266.1559718194661;
        Wed, 05 Jun 2019 00:03:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559718194; cv=none;
        d=google.com; s=arc-20160816;
        b=BEVJ9n88dH5nP86VqCnC5aKWs5nTfqJv0t9m0y0yFneozXOPXmLbHdLErOttcySbwM
         UlffZ9NBlz/d/WwDcBzBh7i/w1V0TncqgeGwSUIjD5EYdA7QGoatAgaATu5nkiwKp/Zu
         nbijCS1KeIhODwnCF3y5QbwlueySwiAOazuL/LNJ2Pi8D6qm5F2wzh43/m5vK1uVPU1I
         63ThYJPLbODOhKE8wNGOyCaWFNjL7cx1z9+sGTouGCgerytSulBV+854tLHwGnAUtXOd
         nyJSqm4jqH2gfonV3ckvsVnamkXKfG2E3AGm7+tYf6IOP8QtlYF0ekiiz7j6+ZN3By1y
         9H6w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=lOKRg+b53UEoqXjg6WzbI+0KlkzCni9JGDcVfpiMNCM=;
        b=xQbrCNhcqu5AotJ9tPO2hh2qPM6TFlJUnoa7w63p0NfKVATCyVGfgRhTmD0RU/PgGP
         Z2SLeNSizdt8SyEJdLfLwyibLSzr2urW7xowLiWO0vtohZbfnAFmVPLP10uM8tiFH9/J
         d1iHBGjttpP3rwsG2o9oiafztQhQJgerdeI+EQeSmsdaxMCO4zAzJnlxrbjChuIW4qTE
         mhM8rNZMVK6aIw1iYyjgcxQ7u9OlMweN64j60BjgpdwpISk48dnZk1Tym1ltHseSFdEy
         nMU4rL7q3jVTzjgSx8q2HsZ697vO8TOG19I7rW2I9tvArHc6mOKmgGsxMG5r+AxRANDn
         4npA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q36si6240672edd.119.2019.06.05.00.03.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jun 2019 00:03:14 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 0D4C8ADE0;
	Wed,  5 Jun 2019 07:03:14 +0000 (UTC)
Date: Wed, 5 Jun 2019 09:03:12 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Bharath Vedartham <linux.bhar@gmail.com>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, rientjes@google.com,
	khalid.aziz@oracle.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm: Remove VM_BUG_ON in __alloc_pages_node
Message-ID: <20190605070312.GB15685@dhcp22.suse.cz>
References: <20190605060229.GA9468@bharath12345-Inspiron-5559>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190605060229.GA9468@bharath12345-Inspiron-5559>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 05-06-19 11:32:29, Bharath Vedartham wrote:
> In __alloc_pages_node, there is a VM_BUG_ON on the condition (nid < 0 ||
> nid >= MAX_NUMNODES). Remove this VM_BUG_ON and add a VM_WARN_ON, if the
> condition fails and fail the allocation if an invalid NUMA node id is
> passed to __alloc_pages_node.

What is the motivation of the patch? VM_BUG_ON is not enabled by default
and your patch adds a branch to a really hot path. Why is this an
improvement for something that shouldn't happen in the first place?

> 
> The check (nid < 0 || nid >= MAX_NUMNODES) also considers NUMA_NO_NODE
> as an invalid nid, but the caller of __alloc_pages_node is assumed to
> have checked for the case where nid == NUMA_NO_NODE.
> 
> Signed-off-by: Bharath Vedartham <linux.bhar@gmail.com>
> ---
>  include/linux/gfp.h | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 5f5e25f..075bdaf 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -480,7 +480,11 @@ __alloc_pages(gfp_t gfp_mask, unsigned int order, int preferred_nid)
>  static inline struct page *
>  __alloc_pages_node(int nid, gfp_t gfp_mask, unsigned int order)
>  {
> -	VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES);
> +	if (nid < 0 || nid >= MAX_NUMNODES) {
> +		VM_WARN_ON(nid < 0 || nid >= MAX_NUMNODES);
> +		return NULL; 
> +	}
> +
>  	VM_WARN_ON((gfp_mask & __GFP_THISNODE) && !node_online(nid));
>  
>  	return __alloc_pages(gfp_mask, order, nid);
> -- 
> 2.7.4
> 

-- 
Michal Hocko
SUSE Labs

