Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CBC46C31E5B
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 16:11:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9B5BC20B1F
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 16:11:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9B5BC20B1F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 364548E0007; Tue, 18 Jun 2019 12:11:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 33BEB8E0001; Tue, 18 Jun 2019 12:11:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 202748E0007; Tue, 18 Jun 2019 12:11:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id C4C578E0001
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 12:11:56 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id d27so21896739eda.9
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 09:11:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=oITxGW1LHubvM44T0Ldv0yFOUtOoUW2OSbAxzFTO8fE=;
        b=UhdJIWElVAyIvrGaGWWz5uIau2OL1NQ9dZtGsfEJwfhgN8Rv9fix94tI4TPcMC9DGS
         2AhbdpHptjWf7ChCb06rkAeNcL1ywpuF5lAOKkwo8XG0JSft2kYTK1DlWZ6jZqL8Iyd/
         +qN2z+lsWyr6BbY9wLiD22hPDJQEhvb9yyPNWNqPs9RQap3Wdp4TqL4r57QyZ18ixJRV
         5CQNj24wksnY/hwAgRkCFa1NTj6W/2lS7Hrw15KyiX6ck3HeeE0KGViXiDZLzGFw/cXh
         I7LrmsrjprvW8O9XIKjFoqlXM7SjdYl0Xv5TjczKjfQJ3OWE05f2bOsxR3YJ/iFCFVI/
         QTIQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAVfzFD6+CaNtCdyeHdVkjHHIQwA0ZiPGSkfPUDMJUUtI6irU4NO
	4RS4wzNbHYaJQ0wU4iUN8rM8lgq9E66a5P9o4BZLVMz96oLypZJ35bAmn5dwHLRpOV6Rld22gKO
	t/4m/M5qXoNxyGT/B+WxdVi3rbQDmqDawS21ZzaNd+LUP8ujHQ0GiwsLPMnVojt8fWQ==
X-Received: by 2002:a17:906:5242:: with SMTP id y2mr26639423ejm.163.1560874316357;
        Tue, 18 Jun 2019 09:11:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwTFrcwlHFnQGXxvw0oFpO9w8o1U4wSMKvMYw7qzOHamiN04hIpXhM2vOXKJEUQy6j5Aj6m
X-Received: by 2002:a17:906:5242:: with SMTP id y2mr26639357ejm.163.1560874315540;
        Tue, 18 Jun 2019 09:11:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560874315; cv=none;
        d=google.com; s=arc-20160816;
        b=iv1HypVonWpmzTWx2TQFtz8Zlud5DEp3DbaIImXfWjHuRRyFmDLZowIo0PQyKyp5qg
         k2Fs9V2FV6RPuLBxqohPpqxn7xyYrwgDf9spIn5Ze6rhEhm/skCf9mobyQkzFl8OhbmK
         f1eFFi9JL2CHkR0WA9PFIIKywtlCBJEXFC8h2m7C3csjao2+ePNye8ff+VU9dyJ5qY8W
         +Zo2a2ZkBpUxlJUUMNF33b0WevSROAiFF0Xwo/NTv0WMLKHQuRZWqcdbfynZqXWGAmD5
         DSCaa+T4ZFd6MiF32GM95kW0691WJP08JQOwGjJ1+PJHFRNJ5IwuQvQsvaCUDzWIOJo2
         JVpw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=oITxGW1LHubvM44T0Ldv0yFOUtOoUW2OSbAxzFTO8fE=;
        b=mFOO8IYsLQiycpgNVOiXb9NrBvZZrVViaQdxhUcUEOZA/2QrkuGrKQkmwHnBHDXmwW
         K4MCdPHMzF6i7gCyomvbIWNO5HprewjFFS4oR6px7A22GtNcDt9NXs3/nB/z5d1LKpcb
         ox8YgS89qDY2x4+Mzxz2RKlYe5RI3dNW2eaoNTuOvgR3riMc9O8xGwMND4RQCgmNk/Em
         3nySu50rmWPy1tuLIkeVu3aJmxEU0/Ust9MaBumIwUnLl1Tf/qIbyPoJNR2ZrWs96/Qi
         LFGIZvbIrktv999pBDHEJY+HdcBo48s0TJKXdTKSFKOHLBEk8AGDUWJ9vqM/PgrUB8fd
         IbyQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g56si12159441edb.70.2019.06.18.09.11.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 09:11:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 88853AEE0;
	Tue, 18 Jun 2019 16:11:54 +0000 (UTC)
Date: Tue, 18 Jun 2019 18:11:51 +0200
From: Oscar Salvador <osalvador@suse.de>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@kernel.org>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	xishi.qiuxishi@alibaba-inc.com,
	"Chen, Jerry T" <jerry.t.chen@intel.com>,
	"Zhuo, Qiuxu" <qiuxu.zhuo@intel.com>, linux-kernel@vger.kernel.org,
	Anshuman Khandual <anshuman.khandual@arm.com>
Subject: Re: [PATCH v3 2/2] mm: hugetlb: soft-offline:
 dissolve_free_huge_page() return zero on !PageHuge
Message-ID: <20190618161151.GB14817@linux>
References: <1560761476-4651-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1560761476-4651-3-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1560761476-4651-3-git-send-email-n-horiguchi@ah.jp.nec.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 17, 2019 at 05:51:16PM +0900, Naoya Horiguchi wrote:
> madvise(MADV_SOFT_OFFLINE) often returns -EBUSY when calling soft offline
> for hugepages with overcommitting enabled. That was caused by the suboptimal
> code in current soft-offline code. See the following part:
> 
>     ret = migrate_pages(&pagelist, new_page, NULL, MPOL_MF_MOVE_ALL,
>                             MIGRATE_SYNC, MR_MEMORY_FAILURE);
>     if (ret) {
>             ...
>     } else {
>             /*
>              * We set PG_hwpoison only when the migration source hugepage
>              * was successfully dissolved, because otherwise hwpoisoned
>              * hugepage remains on free hugepage list, then userspace will
>              * find it as SIGBUS by allocation failure. That's not expected
>              * in soft-offlining.
>              */
>             ret = dissolve_free_huge_page(page);
>             if (!ret) {
>                     if (set_hwpoison_free_buddy_page(page))
>                             num_poisoned_pages_inc();
>             }
>     }
>     return ret;

Hi Naoya,

just a nit:

> 
> Here dissolve_free_huge_page() returns -EBUSY if the migration source page
> was freed into buddy in migrate_pages(), but even in that case we actually
> has a chance that set_hwpoison_free_buddy_page() succeeds. So that means
> current code gives up offlining too early now.

Maybe it is me that I am not really familiar with hugetlb code, but having had
a comment pointing out that the releasing of overcommited hugetlb pages into the
buddy allocator happens in migrate_pages()->put_page()->free_huge_page() would
have been great.

> 
> dissolve_free_huge_page() checks that a given hugepage is suitable for
> dissolving, where we should return success for !PageHuge() case because
> the given hugepage is considered as already dissolved.
> 
> This change also affects other callers of dissolve_free_huge_page(),
> which are cleaned up together.
> 
> Reported-by: Chen, Jerry T <jerry.t.chen@intel.com>
> Tested-by: Chen, Jerry T <jerry.t.chen@intel.com>
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Fixes: 6bc9b56433b76 ("mm: fix race on soft-offlining")
> Cc: <stable@vger.kernel.org> # v4.19+

Reviewed-by: Oscar Salvador <osalvador@suse.de>

-- 
Oscar Salvador
SUSE L3

