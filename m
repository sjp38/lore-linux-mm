Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B5E77C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 12:26:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7AF89217D7
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 12:26:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7AF89217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0E4E88E0003; Tue, 19 Feb 2019 07:26:13 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 06CA58E0002; Tue, 19 Feb 2019 07:26:13 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E76D18E0003; Tue, 19 Feb 2019 07:26:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9CDF58E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 07:26:12 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id u25so3301808edd.15
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 04:26:12 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=sUlM88ZKkaVzZg4CngY/sTO15uTwKdycPIdYqTs7XRc=;
        b=ssNL90K/LRKuKkRxz4JK9f/NbCfKV2AttEhK1pHUQvD2wSNdwxY2QLPEKt08xnJ1Vm
         myreLBEByd51lFKO+iqei89ofhO671KF4Uc7nmUFRunFfLYdLp3blNSUK/MfEMEish2o
         rXoCDT3ae7EVH/YpbWWErRTLBxY1TL4eSqwGiVxTaVIFZQmkc8ipGGEJfVexCZXMEyvU
         o6hbLM2Pa/KLzXCGex58pfA3/fZRCnmuShkY8YJHcucYZflrXFKxfQA5cd5mATa1fEd2
         VeNASbTAoXy1UnqoByf16Um60Jv+3D4kuHaB4/s5sC5qTrOtKLcKTL6vw80Xl9bUqSjL
         tLfA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuZrlBPasnUcJqUi64deEoU8QtO6MYtru3NStq4uk6RC1DRzyaLO
	4qt6YFAfWW67pbZOzgnX126+bQlVrX+49uEusW4uVCPtdPRIq50IktYEjBVg69sKUZ3xkaOpHI6
	2aFKGY5+tXOvnq0eJh8wUafLcxr1YQsZXZmYwX++ghuI3/YPRFgefYJo2fRVuI9I=
X-Received: by 2002:a17:906:2643:: with SMTP id i3mr20249281ejc.157.1550579172115;
        Tue, 19 Feb 2019 04:26:12 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY/e7Bmb+dZthNLBOl4D+eo2pIyg7fjdArgvy6XQ9lQ7QyTpLThlnCBken/s+ljmywrN+ee
X-Received: by 2002:a17:906:2643:: with SMTP id i3mr20249232ejc.157.1550579171204;
        Tue, 19 Feb 2019 04:26:11 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550579171; cv=none;
        d=google.com; s=arc-20160816;
        b=KGl0yfANO/PkAhK59BDklVbxbHr+Bk0R+rp/hbso0zAmFLhPZ29U5AvLm71AnmjdQO
         EjaWJ5Mp9SliZRlFpMPvrT/5Xb8O4w3zK+kOUih4E8RtilK/Jo6Ouq45SKTPSDsMDNcc
         f7eFpRb9B+1jQihMnOJwkby5jmn2xsHi7Rd8OCwN3KKptuz/mia7rhnyK53MiKO73Gc/
         LzrzE7Soy/iWqkXSt/ar8i24jxblM+eKQgwQqEArjcxRt3TVGgyYMHxG2oBqCSHCORw2
         C2DeKdx/282bhSUdwWdohFJmQi7tx6g3XC5zGUy08Io3TH30PexQbI8qXqsSVC1BYYCs
         7bZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=sUlM88ZKkaVzZg4CngY/sTO15uTwKdycPIdYqTs7XRc=;
        b=y6zxlQ7YHrsHBTEknuVQyjYHQukVaduAWDXE9ikjoDqseNqDhBwKIz76+kxbdiia/s
         lf406zhAAvORhjmWs3YGoVoa3udqyrTzHgGQHXzL1eF+gT5jwI0O1yyz4RdDNh4bKPJ4
         0ACrPe4xhy21xiq52CMxBEKl1Fx4GMw7HUpv0kA9FnE37HXqZgROuZOPpivQ3peCfRP7
         KDB0ZLcKChOWzbskNdZUtg43GmyYLLAZv52hVwApXw3b/qAtq0/fmaqWf2WVN61GpDZL
         py1bt3bdtSOB35FkGBJGeJ4/+zq2lUg9Ej6YdmYlfCroNFYazZQIWcErnvIBFusiy9Sd
         NXvw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c1si1565012edw.352.2019.02.19.04.26.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Feb 2019 04:26:11 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 28457AE62;
	Tue, 19 Feb 2019 12:26:10 +0000 (UTC)
Date: Tue, 19 Feb 2019 13:26:09 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Christopher Lameter <cl@linux.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org
Subject: Re: Memory management facing a 400Gpbs network link
Message-ID: <20190219122609.GN4525@dhcp22.suse.cz>
References: <01000168e2f54113-485312aa-7e08-4963-af92-803f8c7d21e6-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <01000168e2f54113-485312aa-7e08-4963-af92-803f8c7d21e6-000000@email.amazonses.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 12-02-19 18:25:50, Cristopher Lameter wrote:
> 400G Infiniband will become available this year. This means that the data
> ingest speeds can be higher than the bandwidth of the processor
> interacting with its own memory.
> 
> For example a single hardware thread is limited to 20Gbyte/sec whereas the
> network interface provides 50Gbytes/sec. These rates can only be obtained
> currently with pinned memory.
> 
> How can we evolve the memory management subsystem to operate at higher
> speeds with more the comforts of paging and system calls that we are used
> to?

Realistically, is there anything we _can_ do when the HW is the
bottleneck?
-- 
Michal Hocko
SUSE Labs

