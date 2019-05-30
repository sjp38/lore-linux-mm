Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5362BC28CC0
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 12:14:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0F8C32568D
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 12:14:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="WwpXvpKM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0F8C32568D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 88FCB6B0010; Thu, 30 May 2019 08:14:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 83F126B026B; Thu, 30 May 2019 08:14:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 72D906B026C; Thu, 30 May 2019 08:14:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 265C86B0010
	for <linux-mm@kvack.org>; Thu, 30 May 2019 08:14:05 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id l3so8380136edl.10
        for <linux-mm@kvack.org>; Thu, 30 May 2019 05:14:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=p1918MnxARtKvEc6ceYsEUd3Epplrq3Dno0QWUAOQIc=;
        b=pNauE3nQVPugIOQk9vWG/8seVlhCnj/rlj+2Z9wzVE5vi7GY2Mkr699Fck5IuYD0RV
         Ed71PqgCtnlLNP9KKuOPQGKL92kJXdDGIeM6g1ennVX6vdNVxnfDit0ylFoTBR1PuAD7
         kSHY0P/OLe6NdK8nxNEHMiPH50GMxR1wxKQxTG4fMZ5wIZJE73xHrksLkrL7kTASU2xr
         N/UjnDZQyZxVQcS+ve2zQYEsjxYfnQm9+fAz9itDA7QwrFnSR1NqxgsPSlSb65gqfVHb
         QYHDNBrCPuOS7ixAkLuq+U7hyD9QEtGjFf6yiVR22gnuG9XlhfuSPb/pheLys5ZOfzcf
         tbLA==
X-Gm-Message-State: APjAAAXd6EgeDrFldbD8TMokB675vynK91yFAN0YZJVTPzMMLF5H8yuv
	pWrKqnHYtSbnJ1TVPll9rWc1LbjgGlB4kiSZWQfof/FMf5t4P50FbmzOgGY4f19i/9l1UCnhAvu
	9zhQ6VnWP7lufb3TRBRk1B8cT5JnBIhKoru/Fipy6XD4dA+WryiTggO3g+eXh3XvI2Q==
X-Received: by 2002:a05:6402:1610:: with SMTP id f16mr4112402edv.171.1559218444644;
        Thu, 30 May 2019 05:14:04 -0700 (PDT)
X-Received: by 2002:a05:6402:1610:: with SMTP id f16mr4112307edv.171.1559218443773;
        Thu, 30 May 2019 05:14:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559218443; cv=none;
        d=google.com; s=arc-20160816;
        b=Kr9zbMpHCJ8ySYVyD1iIg6YTTyo1U7Xz0vQV1mNvYSHimztcU52iGnebiPSeEj+Dsj
         VMqdXolY53efhSdUaeDB6OZO3B2/Lc5GbF+xZzShg2fpn8F73GRMILLE33DlnLx8WQcy
         OfOK1c+GRVmLVS2zlEjOO17x3s2bO5ttLaYitRDNtwg3uhNmWIjJIo730FwOJPTwVW/p
         N6g69WuMx0bBXTjKPNbRhgtdD/KAUlxhcb7U2OlLf81XyhHO+1wkvRd6nQ0mqCeajVd8
         d4TcLyJkFpQXf39GyrNmJDawpEvgGuhdLONTuaNV+RyldmdU6Ys0I6LSlRoTLecmQhjO
         7Wcg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=p1918MnxARtKvEc6ceYsEUd3Epplrq3Dno0QWUAOQIc=;
        b=M1vlwYSkfg9pcCgmfagouPBDzzwMV5zT7U165Ys1GbVxzZ2BTZkBF6trM8FuzSsEq6
         gIvff381A0xaH81Nv2AgiFqsEHU6C5S+VQLFlQKVsh1kDV8iR+NxmDwIltCPs+6DPxgP
         lVBv6DzA5NTTLd4U/zTx99CFApnRR4kXsVqC0cSqG9qASSQYMWnVeDfyxHKsWtdAGnM5
         yID9ZK4d2bnosbflhK0J400L2q7Oy139t5hPZCAW3eO+zhih80m2G8S5xtZOtzf+1kYc
         d2sBYuEMF7EgIPTvp4cSOPDfMMfdkOb/Gp7aiU+bco8B/yREWBx5BBKFsWs5A6Mad43W
         U5FA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=WwpXvpKM;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d6sor805905ejp.4.2019.05.30.05.14.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 30 May 2019 05:14:03 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=WwpXvpKM;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=p1918MnxARtKvEc6ceYsEUd3Epplrq3Dno0QWUAOQIc=;
        b=WwpXvpKM9wyVqaBDvR0ygQVcZ42ff9V7UdQHrCrSBwcUIEVEmjuTKBZ/IcXWH9eb5r
         LM2dQI9+J0VXq6CKq0RCQVNNfFNFV7wXEVX6NmISCJthmIw0bOFXuveRJjd3kAcqEdmH
         2kXefMuUqNOvxd8cf4G/K8smJTb967IvuR2zQJyzvKmuTmEJjeY909hYgmoeDTt9dJqw
         tIy9hLMgZ4lmN0z3tHsNhdeexSGkNFDu0lIElK/3gavacIosueW6YA0nyyn5+T38ggfF
         TqQMY95IlMlKA9y5AfiRxQGvPAHj/giAOKuetihepllUU1tcrz57Yur9DY5wjCsZV4WJ
         Zr9A==
X-Google-Smtp-Source: APXvYqyeQ7RjD8auQNHx3XF4JeRe83d9ggJZiR6/yHiQKW8mGxbq1bQy7fyk84Y985CtTEYnjKtW9g==
X-Received: by 2002:a17:906:a302:: with SMTP id j2mr3149843ejz.155.1559218443491;
        Thu, 30 May 2019 05:14:03 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id g18sm684004edh.13.2019.05.30.05.14.02
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 05:14:02 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id C43031041ED; Thu, 30 May 2019 15:14:00 +0300 (+03)
Date: Thu, 30 May 2019 15:14:00 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Song Liu <songliubraving@fb.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, namit@vmware.com,
	peterz@infradead.org, oleg@redhat.com, rostedt@goodmis.org,
	mhiramat@kernel.org, matthew.wilcox@oracle.com,
	kirill.shutemov@linux.intel.com, kernel-team@fb.com,
	william.kucharski@oracle.com, chad.mynhier@oracle.com,
	mike.kravetz@oracle.com
Subject: Re: [PATCH uprobe, thp 3/4] uprobe: support huge page by only
 splitting the pmd
Message-ID: <20190530121400.amti2s5ilrba2wvb@box>
References: <20190529212049.2413886-1-songliubraving@fb.com>
 <20190529212049.2413886-4-songliubraving@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190529212049.2413886-4-songliubraving@fb.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 29, 2019 at 02:20:48PM -0700, Song Liu wrote:
> Instead of splitting the compound page with FOLL_SPLIT, this patch allows
> uprobe to only split pmd for huge pages.
> 
> A helper function mm_address_trans_huge(mm, address) was introduced to
> test whether the address in mm is pointing to THP.

Maybe it would be cleaner to have FOLL_SPLIT_PMD which would strip
trans_huge PMD if any and then set pte using get_locked_pte()?

This way you'll not need any changes in split_huge_pmd() path. Clearing
PMD will be fine.

-- 
 Kirill A. Shutemov

