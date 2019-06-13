Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 57ED1C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 09:33:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 25D252147A
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 09:33:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 25D252147A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C141B6B0003; Thu, 13 Jun 2019 05:33:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BC41C6B0005; Thu, 13 Jun 2019 05:33:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AD9B36B0006; Thu, 13 Jun 2019 05:33:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 786A56B0003
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 05:33:05 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id y24so30090646edb.1
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 02:33:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :content-transfer-encoding:date:from:to:cc:subject:in-reply-to
         :references:message-id:user-agent;
        bh=iSGa/JDsR6P8jOmMpGaKDES7ytkHhiXcbpOriJgu+eo=;
        b=eY/sW0Ow41wSKB/zNFqqIOtSt5EB8RZwB0iaPB0o06Vs8O9wtpXsUrY/ubT7WNeq8E
         GqL8bf1CALSi8n5IttJub6hqamT/Ld9jDT6rOKfeKPn3VlVUiPIbPC0qHIe0wA0W88YT
         IrR3LVGzZGBRwL+r8OOv0rMWWiH+6Q/OVIo3ii99P0XDbiFwFvSWK7sfyPllNW3XGtT/
         o4h6B47bNlEyIDP+IjbTit4LkUVwL2b+DiR9mMDoAAMtRr+WB/KxVTvj9MaBA22QDaHA
         5x+moHRpkNfkG/NBKFcvOcTcieuOaTEcEU8xLiJdn6dxVxjUBPALy+s8ih7dgruoyyYi
         Qgsg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rpenyaev@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=rpenyaev@suse.de
X-Gm-Message-State: APjAAAVr88PQV679AY3tqKgmihK+/qemyKJIORJEd9VTyM/izpM7SZNh
	5Q6ko7qipbvaOOYpdQ2GviTPxAx+JBsdh3oqnmMLV9dJWpDdZ4nDcaKDaSjJhpEmEokZJZ63/qO
	WeSDgmsY++9IcTdWN5MOM9Xjy+IJPxbEyWiil/4Ti63iGA1aRmTraeSydUW83KGyF3w==
X-Received: by 2002:a05:6402:78c:: with SMTP id d12mr32469299edy.160.1560418385069;
        Thu, 13 Jun 2019 02:33:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxvKzm8wFhqlkyqTqI9FoSS4vx6xQ0A3swTkLKrsgtkIE1MKeFHzuP6gSLP4eSFmxIYhLNE
X-Received: by 2002:a05:6402:78c:: with SMTP id d12mr32469225edy.160.1560418384261;
        Thu, 13 Jun 2019 02:33:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560418384; cv=none;
        d=google.com; s=arc-20160816;
        b=DEAyNBbli6yMdV6Zw8IuggG1hcsMdUMj8UTsN87XA74RQGKlKKWZXq+Sp0zg9A2UQZ
         W6sIMKBG8J2Iup8Zn9lItbgopToVF5LpDK5SKS6p033wcTXAWgj1qAhSUN0stvZRzNxJ
         Cu7T3mTlsqHNmZGIyR35bqUgK3w9642PmnbF1USMSq7W44debsArIuziyLgEqAobrZ0+
         4QxohiXvz60EEyn2f/vh5jh+wA+Kh9tF3Y+7svVCk+VP8lRrhKbBcY+EHAbn6oBxzKyS
         otKgt9RcKtg9RgG5KAnRXz9Pl3S1FY1wOXHLmGj7KZLLvcZ7OmsE+qKNw7JJLPJB5IEA
         LzFQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:message-id:references:in-reply-to:subject:cc:to:from
         :date:content-transfer-encoding:mime-version;
        bh=iSGa/JDsR6P8jOmMpGaKDES7ytkHhiXcbpOriJgu+eo=;
        b=xIkAlG4i6mZJVaDGGukTVWcOUNvHEpWwx/i31BgRF05hLWsx3GQIvwIF6bJQY9UXX4
         BFmyjC39xtDeVMwSisU4sSfJm6vynK2w4Tl+CBZwhUKhV9eywtL/usBoK5ZXwWZ++vWc
         X3KNMmON9EuMq1yPUU/AB3SB3xdPj/lMlj73MykFZQUFddApVQaDO77HAb9M7F/37H/j
         nrFWn5obU0EbCcJ8H0WXbcQShNcpOfVJhwuTFAcmawrfUawdPxkLP3A8gWnZKjlNVy8X
         WQQ3HfPVRQimhm+R9HeMk869QPyUQPymzStrMS2sq8keWrjdtl+U9YGVf2mbyQV8UZ+u
         wflw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rpenyaev@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=rpenyaev@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c58si1998020ede.408.2019.06.13.02.33.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 02:33:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of rpenyaev@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rpenyaev@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=rpenyaev@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 3ECB3AF22;
	Thu, 13 Jun 2019 09:33:03 +0000 (UTC)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Thu, 13 Jun 2019 11:33:02 +0200
From: Roman Penyaev <rpenyaev@suse.de>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rick Edgecombe
 <rick.p.edgecombe@intel.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>,
 Mike Rapoport <rppt@linux.ibm.com>, Roman Gushchin <guro@fb.com>, Michal
 Hocko <mhocko@suse.com>, "Uladzislau Rezki (Sony)" <urezki@gmail.com>,
 Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/vmalloc: Check absolute error return from
 vmap_[p4d|pud|pmd|pte]_range()
In-Reply-To: <1560413551-17460-1-git-send-email-anshuman.khandual@arm.com>
References: <1560413551-17460-1-git-send-email-anshuman.khandual@arm.com>
Message-ID: <7cc6a46c50c2008bfb968c5e48af5a49@suse.de>
X-Sender: rpenyaev@suse.de
User-Agent: Roundcube Webmail
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019-06-13 10:12, Anshuman Khandual wrote:
> vmap_pte_range() returns an -EBUSY when it encounters a non-empty PTE. 
> But
> currently vmap_pmd_range() unifies both -EBUSY and -ENOMEM return code 
> as
> -ENOMEM and send it up the call chain which is wrong. Interestingly 
> enough
> vmap_page_range_noflush() tests for the absolute error return value 
> from
> vmap_p4d_range() but it does not help because -EBUSY has been merged 
> with
> -ENOMEM. So all it can return is -ENOMEM. Fix this by testing for 
> absolute
> error return from vmap_pmd_range() all the way up to vmap_p4d_range().

I could not find any real external caller of vmap API who really cares
about the errno, and frankly why they should?  This is allocation path,
allocation failed - game over.  When you step on -EBUSY case something
has gone completely wrong in your kernel, you get a big warning in
your dmesg and it is already does not matter what errno you get.

--
Roman

