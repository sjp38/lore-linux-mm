Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1E77FC0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 18:53:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E0D2C2184E
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 18:53:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E0D2C2184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7F1DE6B0007; Thu,  8 Aug 2019 14:53:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7A1ED6B0008; Thu,  8 Aug 2019 14:53:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 690906B000A; Thu,  8 Aug 2019 14:53:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1ADD86B0007
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 14:53:19 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id f19so58779538edv.16
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 11:53:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=L6cmpkEWtNhWcNMz5/oZ6Vbn28vJUxk3i067WpBFzys=;
        b=edrBHIt+7Jc79UzyZKqV1ZXmn/HxKulv6Oo09AWV8L14ZGQVxBoVKN0vInDnTaN/AP
         DS4ncaJrL6tqmc96DSS159PXJAlGJPeM+B60FC3gHFHBkN9ClH+QqRlMMp0dkHpGFbEj
         IqOCpShMx1/ocm6PwvFET1MGuYTaFztNF3YD/csrcr2VqPcn/njF5tvqqT48OmQ4V4yO
         bvBL7GlK01ndi5MzpEZ872KZoOhdeb2pS6peyfg77LUPSWYtQgh1pLWsRfI7Ovd2Quj/
         I6b90oiEbMaYIa8KtzRYCTITMsjz1nfY0ZtzSKQhWBSTeX4ZcmKotbC5bY/EMU70dK8m
         CURw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAX91t4C3pfYh2CIg52ZF/lK33IxKopIzr279C3OYAxqRh+F9eTH
	EcqptDBbT5V3GWbP0EAh23tN6KjfKnRTyDNEPk7GKFvLk9Wypllt/LKXZwb8BXBu3Osxk83uu5Z
	ySb9r+C5tWVT9ImtAMrQaKTcx68giNDbTdYMpy2/wh28NTxQPKN4smX1K6eD/IA0=
X-Received: by 2002:a17:906:4882:: with SMTP id v2mr15110473ejq.100.1565290398640;
        Thu, 08 Aug 2019 11:53:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyRAXFoROZAo+E4z8faVAYPvvoSXTj4fMQsQ+mUXpQAody8P9uUJRg+y+5DAP9Se1qMaGgu
X-Received: by 2002:a17:906:4882:: with SMTP id v2mr15110408ejq.100.1565290397630;
        Thu, 08 Aug 2019 11:53:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565290397; cv=none;
        d=google.com; s=arc-20160816;
        b=n8QV2GmntDXAOYMjQEXoS0BuhojOHCj/GqxuhiRKuALra1eYWE8FC4IGIFOk5pXwJf
         8b4c3sYB2+fSAwONMTgsjxonntu+9fb0PWZszVsCdNcy3IMuXTJNGMnbBvTVau6AVlHL
         ZwPbxXyYbhyPpZbSpkyA/MWp7eiiy4h+sy+Ysm3DoVCKgAJhMlaqaOfb72hLLCPhzZ5b
         7lO+RzPh4i4G5I5gt7qK9h8SV8Zmi6YSxpATu5pkA49RIYO00dsZfJ1mI4B/cE317VMG
         goSsiFanrIQP0vZQx/YXitJ78KDojdQvjHj2I/5bgOYLP/qZlaI7XueCcTutxVVX+xgx
         3Y0A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=L6cmpkEWtNhWcNMz5/oZ6Vbn28vJUxk3i067WpBFzys=;
        b=otIEzBDgBk5YIVSTXHg0/NIR6bXLyz3Ln8KOowoKZD/FTZpabpaoC8MlgsjuU8mEsX
         iVZkq9ewhtYdTV2N2cP7LCb/2/9cfqEjQDmmmCi+6Xhw2kl8mh2mUOfOx7JtyIpW2hHm
         7wZr7hUIL96ZHPny+Dw8GoFh5Rit5Dj7kAhIri3rQz9yfKfUrSQM6sTHEtka6wdU7JFg
         rNFb3acVEfHU1FU5w0FF/XUZiCpNulve3jlicODW9FNealIcJzHuzHApAlYjeLhNNly+
         ByIR6V1Lj6DNoy3Bn9qyMvmOd7XfgyTFVlQWvcUtK2sKJ28WHg3EjoEIN36FOa91kamA
         iFRQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k28si39674137ede.131.2019.08.08.11.53.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 11:53:17 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 1B533AFD4;
	Thu,  8 Aug 2019 18:53:15 +0000 (UTC)
Date: Thu, 8 Aug 2019 20:53:13 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, ltp@lists.linux.it,
	Li Wang <liwang@redhat.com>,
	Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
	Cyril Hrubis <chrubis@suse.cz>, xishi.qiuxishi@alibaba-inc.com,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] hugetlbfs: fix hugetlb page migration/fault race causing
 SIGBUS
Message-ID: <20190808185313.GG18351@dhcp22.suse.cz>
References: <20190808000533.7701-1-mike.kravetz@oracle.com>
 <20190808074607.GI11812@dhcp22.suse.cz>
 <20190808074736.GJ11812@dhcp22.suse.cz>
 <416ee59e-9ae8-f72d-1b26-4d3d31501330@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <416ee59e-9ae8-f72d-1b26-4d3d31501330@oracle.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 08-08-19 09:55:45, Mike Kravetz wrote:
> On 8/8/19 12:47 AM, Michal Hocko wrote:
> > On Thu 08-08-19 09:46:07, Michal Hocko wrote:
> >> On Wed 07-08-19 17:05:33, Mike Kravetz wrote:
> >>> Li Wang discovered that LTP/move_page12 V2 sometimes triggers SIGBUS
> >>> in the kernel-v5.2.3 testing.  This is caused by a race between hugetlb
> >>> page migration and page fault.
> <snip>
> >>> Reported-by: Li Wang <liwang@redhat.com>
> >>> Fixes: 290408d4a250 ("hugetlb: hugepage migration core")
> >>> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> >>> Tested-by: Li Wang <liwang@redhat.com>
> >>
> >> Acked-by: Michal Hocko <mhocko@suse.com>
> > 
> > Btw. is this worth marking for stable? I haven't seen it triggering
> > anywhere but artificial tests. On the other hand the patch is quite
> > straightforward so it shouldn't hurt in general.
> 
> I don't think this really is material for stable.  I added the tag as the
> stable AI logic seems to pick up patches whether marked for stable or not.
> For example, here is one I explicitly said did not need to go to stable.
> 
> https://lkml.org/lkml/2019/6/1/165
> 
> Ironic to find that commit message in a stable backport.
> 
> I'm happy to drop the Fixes tag.

No, please do not drop the Fixes tag. That is a very _useful_
information. If the stable tree maintainers want to abuse it so be it.
They are responsible for their tree. If you do not think this is a
stable material then fine with me. I tend to agree but that doesn't mean
that we should obfuscate Fixes.

-- 
Michal Hocko
SUSE Labs

