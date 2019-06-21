Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E5170C43613
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 12:48:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A4A5B208C3
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 12:48:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="ZlBt1ZI3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A4A5B208C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3881A8E0003; Fri, 21 Jun 2019 08:48:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 339138E0002; Fri, 21 Jun 2019 08:48:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1DA3E8E0003; Fri, 21 Jun 2019 08:48:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id C2CC08E0002
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 08:48:23 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id r21so9061377edp.11
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 05:48:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=4adQYbcIqRIUCBEdkxswp1975OueOQrS15/MY1hDOBk=;
        b=JFBwBZl5GeNhocL9Ih6WVoIDvm26PAXnBs3RvDQO4ujQ4KQzyczEQ0BFXTxLIDB7WJ
         tkE3OoVz6rYRZZLVwnUg371iOwDJX87ItiXorKyioktjw3Ja+8n9qh0L8tgGrYgsOS38
         EdX5mncaa6iuUR7ZUqoXCHVuh5laBOt97tqANkhnAo7vsOmBrqLM3sOLLg8e2kyrzSOz
         uDkvY/bSVvXycEhJAt4oJuVXuO4fZ2bvCdwy0fb4X7M7ZiDftdpn3lvnjKWp+DoqpEBl
         zxDptxKoUAKjAyYpb/8sBS1TgFnNtOlyTwZGSWemvM9LiGkykILobm2j28ivhEYxs+HN
         Cg1g==
X-Gm-Message-State: APjAAAXLnP2d17kgQTPG5kVgFAKMa3zNR5L9RdFpSeH3T/FYDIZQBj48
	RUH+9YfIh376Sk5xJTkvQVSZnxIzUOanj4TdBr5oAxbVDwPviWP6Ox+LleP/664nfYEwZz5h1fk
	73QLTPXsMToBZ07PqbRhTNRsVtP9CpZsA7KtY6eLM7ZeVidQb+aKu8LUi5Vyl2IK88A==
X-Received: by 2002:a17:906:27d5:: with SMTP id k21mr56309331ejc.101.1561121303280;
        Fri, 21 Jun 2019 05:48:23 -0700 (PDT)
X-Received: by 2002:a17:906:27d5:: with SMTP id k21mr56309295ejc.101.1561121302592;
        Fri, 21 Jun 2019 05:48:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561121302; cv=none;
        d=google.com; s=arc-20160816;
        b=NeiuZVNRz3hqin+zdBRfb3lnsLEpTQIUg+g/Fhs887n3Z9fCbpbB/kooonyaqhoB4K
         H3mI90t1pZbz2ZJMVJAQMePaYfHDtinqdy+rWwte1ccJJvPW5SzAav4U7Nv6ln03ZkVG
         f9Cu5/gghVbPTBdUUiwV1jqATqbxPlUDhMsObJC6dxfw33gTyZYTaBD2BDk19jabUA+i
         Peil5Id8oi0nlRe+nnpJnxCeDOSp4DerDHIuhvmCpp/UXB3AKNQjm/jpq6zwRArn6GGw
         h0SSjqdEGNCB2tvp/zQdflgtjNQFTdVsRVa5TLIcRxk2K5dSsMgAZ3Ha+TJK9Zfxg8sE
         6xYw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=4adQYbcIqRIUCBEdkxswp1975OueOQrS15/MY1hDOBk=;
        b=OEGLoUo1CjWF7Uy6KKQjnypkahSS5M/9Qo3hIr8GUVxvDnAJZkBcxyQ4ww/vbf67Sw
         +fPocZVokyR0PJitr0NJslnrTQlCGPo2H1ixdCLP7k5PItEBHF4HF4ugHdiXmTrAMa4Z
         aUQ38PiCu6SuKVK7uZVz5YuUw+dqJbHapvQMB2L/pth1gLOoN6F/YV8yBaC9oZod+nij
         xwo3O7KiElZ0kN+OCuKk9Q/rfh8k6yRmJWbDzWLh46Q9eBJ/zk2CLOjuANe1Iuj9H7Fp
         4bKpZZ2JSMOXNrdLIDtuiAG/FWhk5g07FV1E+7Fg7z242ynOnXJAR2lko/+HotJfd3cA
         9xzg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=ZlBt1ZI3;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o2sor1010784ejc.8.2019.06.21.05.48.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Jun 2019 05:48:22 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=ZlBt1ZI3;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=4adQYbcIqRIUCBEdkxswp1975OueOQrS15/MY1hDOBk=;
        b=ZlBt1ZI3O0VPVoumZdjZDlOVbahkwHP0Gd/+Uf04iRyZBVzhCcdM1UWqVkdNgGSC7Q
         W47OGL+joFZokL2MgAo+Lxue5OKzFPJFpiTtEaxHsFRYXdkKMRPASxSDA3p/7+VJffIY
         RlKGQZrzIjbvABcchC03LHxG/puhUJX22aWzunxAgqOmlI2HyazUe2ttZrKUhzdxFZlH
         TpDrEw/NPuHN8GaqgvbLUX5rtASqhoRIzQbIwRoau4hhDtIh1N899gWgGjiZZAGQwWXW
         8ZgyVt0/oKwyAID4t7fEPrDGzq6BchbGJuLgpQufAy7H9bzUPPvmKPtumb/uuwHNo5hj
         akrA==
X-Google-Smtp-Source: APXvYqx/TwHAJD6kk+b8dyJleYW2CHXvFxSsfvy2LLGu8vJEZP6ld5sJ0RhKrIWoNBlPsRROYLAv+Q==
X-Received: by 2002:a17:906:32d2:: with SMTP id k18mr23391835ejk.232.1561121302258;
        Fri, 21 Jun 2019 05:48:22 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id j17sm849175ede.60.2019.06.21.05.48.21
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jun 2019 05:48:21 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 7170C10289C; Fri, 21 Jun 2019 15:48:23 +0300 (+03)
Date: Fri, 21 Jun 2019 15:48:23 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Song Liu <songliubraving@fb.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, oleg@redhat.com,
	rostedt@goodmis.org, mhiramat@kernel.org, matthew.wilcox@oracle.com,
	kirill.shutemov@linux.intel.com, kernel-team@fb.com
Subject: Re: [PATCH v4 5/5] uprobe: collapse THP pmd after removing all
 uprobes
Message-ID: <20190621124823.ziyyx3aagnkobs2n@box>
References: <20190613175747.1964753-1-songliubraving@fb.com>
 <20190613175747.1964753-6-songliubraving@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190613175747.1964753-6-songliubraving@fb.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 10:57:47AM -0700, Song Liu wrote:
> After all uprobes are removed from the huge page (with PTE pgtable), it
> is possible to collapse the pmd and benefit from THP again. This patch
> does the collapse.
> 
> An issue on earlier version was discovered by kbuild test robot.
> 
> Reported-by: kbuild test robot <lkp@intel.com>
> Signed-off-by: Song Liu <songliubraving@fb.com>
> ---
>  include/linux/huge_mm.h |  7 +++++
>  kernel/events/uprobes.c |  5 ++-
>  mm/huge_memory.c        | 69 +++++++++++++++++++++++++++++++++++++++++

I still sync it's duplication of khugepaged functinallity. We need to fix
khugepaged to handle SCAN_PAGE_COMPOUND and probably refactor the code to
be able to call for collapse of particular range if we have all locks
taken (as we do in uprobe case).

-- 
 Kirill A. Shutemov

