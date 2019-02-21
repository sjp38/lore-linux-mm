Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E1B6BC00319
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 07:25:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8DA0C2086A
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 07:25:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8DA0C2086A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0F8638E005F; Thu, 21 Feb 2019 02:25:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0A8568E0002; Thu, 21 Feb 2019 02:25:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ED8688E005F; Thu, 21 Feb 2019 02:25:57 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id AC6478E0002
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 02:25:57 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id u12so2937114edo.5
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 23:25:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=d7u9APklCCV9MJNXcCigQ4MeFA/P/06o1MMbIdihD20=;
        b=ktGn/NxznotWJlkel+sF781uLmLGsNVkxN/wG/VbXVqm56H0dhhcztqrb0gSExyqSK
         eIPeL8Y/ScOizo1eUib5rFkU9yOpTmnxlvJFsHqAtUkb2Be6Wfh2zYnVMWPee/6mSnyR
         N66QK9dP25b++p4PXecoDXmuvy/XooiEglHujgry0jJdB15tFfr06+AEDVCvirmvTEjA
         73Rr1LZoNF6TialgPRokCNBwNZYQEryYdZkEGGALMwvzC9XrED+XMfuCGv8cwimKBROZ
         70PsfsAuqMkt8uT4ljBFKll9JxcaLNkTanTFPUVTP7HNvHGBnI5qWZ2jGYnOkWBGJM0u
         qS9w==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuZt84aN1m39DdgIiuB08o+gxsBptjLcAXCPdJv3PrQyYTCmDaA8
	22P1YQqCpTi1/ir+oEFf6WqxEerP1uW8ApZh0LyCIfxHPcaIJePXUXisChQ5ZGQ3cWrU+kc5loF
	m/Vkbc5Fd0vdiwqhLLaW/9n6kmvy7L4mqTriiYqw39Fh+LP28VH1wX6XgXVJfTH0=
X-Received: by 2002:a17:906:f114:: with SMTP id gv20mr1178161ejb.124.1550733957108;
        Wed, 20 Feb 2019 23:25:57 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib+9bXBHEcSWyziG7wyjq905/Y7zYDcgHoL5dt7Fr8OTY6hRv4GYZNM2AEBi6+z21xg+HbM
X-Received: by 2002:a17:906:f114:: with SMTP id gv20mr1178124ejb.124.1550733956254;
        Wed, 20 Feb 2019 23:25:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550733956; cv=none;
        d=google.com; s=arc-20160816;
        b=c8R5V07V6rlV4/wcwaUs3wgrAuKgrtbBII6RcsceBW1uuOZh2UqGwMytipb8ELGGoC
         rFhJsBPZcUOlfQ7Qj2qqTejYzqEtMc8nGNYhktNoOcQHAOIaGH5hll06WMh1z9/67vey
         9Z6QngZWedfzZf6vYrHzU/olbMsbBuyCQ727suX5VAVYP5QaowkcVLAG7dSDURsjTWAj
         qwKcuGVF+SM9MCxmkyDRM1Yauu6D0BBb9GF8rMRfi4e0QdkPkz/gQxgJf+m2qbNBuSBp
         29GRmwp6zfa1R5b6P9LoYh1yJiNyG0zEYi3FcwreMfH5NriW0WQr7XFSFboDA9aauDVa
         vmZw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=d7u9APklCCV9MJNXcCigQ4MeFA/P/06o1MMbIdihD20=;
        b=OJCIRG7p5utHoRmZRki1ETAiiYySKXwjREX5ZxGrry9EcNEMymF5cpIOKxbjm5ZpYK
         P9XO2DaKS4mT4Zt8h1WrAKNCAC7BByDdBqs/G71YxLN6Hco+2izBn3gYYFLb8arWiwxg
         jzhtTsbEYqiAyt77I1GtGcTDSsQ12iAH3Hk3lPm57e/Tn8mbUNnqQI4CUKpq0BhK7dwc
         WTWFFxZZ1F+9aryGrzY0iZOWRG8FPPMEGtocTQm0YRko8BqN7lQ2/IMzgWJfbmgUzN1Z
         yjuElDZVK8ZDLR1LtimFGZZwY3iRaZq/9xmIeVWcvpdPQKptal5+z9PXbPv7VcIYDYBR
         J3/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l52si331354edb.0.2019.02.20.23.25.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Feb 2019 23:25:56 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id B2164AF15;
	Thu, 21 Feb 2019 07:25:55 +0000 (UTC)
Date: Thu, 21 Feb 2019 08:25:50 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Rong Chen <rong.a.chen@intel.com>
Cc: Oscar Salvador <OSalvador@suse.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Matthew Wilcox <willy@infradead.org>,
	Mike Rapoport <rppt@linux.ibm.com>, linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>, lkp@01.org
Subject: Re: [LKP] [RFC PATCH] mm, memory_hotplug: fix off-by-one in
 is_pageblock_removable
Message-ID: <20190221072550.GF4525@dhcp22.suse.cz>
References: <20190218052823.GH29177@shao2-debian>
 <20190218181544.14616-1-mhocko@kernel.org>
 <20190220125732.GB4525@dhcp22.suse.cz>
 <e3fc1372-f3bb-d734-9e3f-d715b85d781d@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e3fc1372-f3bb-d734-9e3f-d715b85d781d@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 21-02-19 11:18:07, Rong Chen wrote:
> Hi,
> 
> The patch can fix the issue for me.

Thanks for the confirmation!
-- 
Michal Hocko
SUSE Labs

