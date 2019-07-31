Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3BE2FC433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 13:03:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 06004206B8
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 13:03:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 06004206B8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 928328E0008; Wed, 31 Jul 2019 09:03:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8FF698E0001; Wed, 31 Jul 2019 09:03:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 83C928E0008; Wed, 31 Jul 2019 09:03:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4F7778E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 09:03:28 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id k22so42382575ede.0
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 06:03:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=bbMPV0VqZm0usM0L5LgGM25pQTzXoKGUY0N22VWeRHA=;
        b=eHdR1YR9oaRmZtgtQLePeOiB2sX+Vv2+NehmxHARaxv6ZSV3LypUKHXccAZoKiFxnn
         0Zy3k38RZqyOhEKk5J1fpWpg51Yqt8lug8BNJJhahakOlAX89ubeV+xk9waFUCB2sagH
         rau2hxbNj0PqBVYHiDfYZX2qZslRmZP+O0+FKozN5Jocx5KhSiJrv3ERVNahx6nVDeS+
         aqxKvTL2FSrCGvbYGCdBe9vOQaR+w1Zd8LGRpMpbghuxyrB5nsHM03vljyCH3sq6l8mF
         njxxubooPeC4GLS48WVZ/aSZbkXrevBJLqTAFzkXweZT0EuvKufycZhpIB6t6jyuDj+p
         Mndg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUlS6PXQHm0LtPcqtLrvA9T41pSUt/gjLIh14CGGa66FFT5KFUV
	jSuLsukU+EAijiXbX0L1lX8BCkJnK3BzH+3Ee7lBZhCANrB/8Cky3QKwWn9QiIPFDzDbDe5YYPA
	Ry6WM19AqBAPuOQgyns5j4fEWLY1Fp4K2UUc+vz95er/HnWRKmv8zXiP2nWI8Ry4=
X-Received: by 2002:a17:906:7681:: with SMTP id o1mr90341180ejm.207.1564578207899;
        Wed, 31 Jul 2019 06:03:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy9bGKxYoyr/E8Jq23e9RncqK7yz0j8KY3NHqc8OAi1PdOHgyYnQDebPmk7uT6hKSRtdW/a
X-Received: by 2002:a17:906:7681:: with SMTP id o1mr90341124ejm.207.1564578207232;
        Wed, 31 Jul 2019 06:03:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564578207; cv=none;
        d=google.com; s=arc-20160816;
        b=TDckCNY/YyOyV5d/9WqsV5IIccg0cRC42pFQXX/2e8zDx6RxbWPxJsKI2xAZgtkR7d
         XLe2XC58MuhqbCv7qgJq1m84lARNWr05t0/79gmFc3VY3j2EedcCMli9wB6rjybAp6az
         FmQIeIp3xAcGGJmTmSwzpVT4qT6+EFR6FK+QpJ3/m22cpc+Y4u2aVc+awChOvgeSw/R/
         8K5YVf9FV18xNzaHUIgfHbMeWMmmJvu0oCVEmAgI4DfQOq4QDahvIdV8Aqj/90Zo853u
         sISl/GugBZe2VwFTxVL2IBibHct8kqyaAvR8CEc9+groMsexFozPmL1SYyI/HCb4u+sG
         07Lw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=bbMPV0VqZm0usM0L5LgGM25pQTzXoKGUY0N22VWeRHA=;
        b=NwjV2HAZlQtwdGX+EXZPErKuwt0fmePpAmh33HxDrXplu70DH9DKFVejfjWfW1su3C
         KQ8RfzZ2X7M0+zA+T7lh8ooE2AIcD423nP6MjycjeQpyUnlhmEw74OBI/kwzMCkRBWcH
         pU4w8S5KsTtv3TTn+UT5+9ClyTD4Rna5knbLGZcxoFOR/0/PDrnhh3YY6LYJGcz5ivQX
         x6uo4bGznG/HgcbqKEe2MtCMU9dCx+I7PSF/lLN7PWUMIZMU3cxpAi/TfEQGoBmyPbCI
         DI6hGU+Etqt10lAb/pPZXbT+lr+hVTk9HDZQXbd8r6apY30Z91+LiDtBAgvTCxB8DQlw
         3/Bg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d30si21270493ede.441.2019.07.31.06.03.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 06:03:27 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id C416DAEF3;
	Wed, 31 Jul 2019 13:03:26 +0000 (UTC)
Date: Wed, 31 Jul 2019 15:03:25 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Cc: cgroups@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	"n.fahldieck@profihost.ag" <n.fahldieck@profihost.ag>,
	Daniel Aberger - Profihost AG <d.aberger@profihost.ag>,
	p.kramme@profihost.ag
Subject: Re: No memory reclaim while reaching MemoryHigh
Message-ID: <20190731130325.GO9330@dhcp22.suse.cz>
References: <496dd106-abdd-3fca-06ad-ff7abaf41475@profihost.ag>
 <20190725140117.GC3582@dhcp22.suse.cz>
 <028ff462-b547-b9a5-bdb0-e0de3a884afd@profihost.ag>
 <20190726074557.GF6142@dhcp22.suse.cz>
 <d205c7a1-30c4-e26c-7e9c-debc431b5ada@profihost.ag>
 <9eb7d70a-40b1-b452-a0cf-24418fa6254c@profihost.ag>
 <57de9aed-2eab-b842-4ca9-a5ec8fbf358a@profihost.ag>
 <8051474f-3a1c-76ee-68fa-46ec684acdb6@profihost.ag>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8051474f-3a1c-76ee-68fa-46ec684acdb6@profihost.ag>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 29-07-19 09:45:00, Stefan Priebe - Profihost AG wrote:
> Sorry for may be spamming - i try to share as much information as i can:
> 
> The difference varnish between my is that:
> * varnish cgroup consumes active_anon type of mem
> * my test consumes inactive_file type of mem
> 
> both get freed by drop_caches but active_anon does not get freed by
> triggering memoryhigh.

Do you have swap available?
-- 
Michal Hocko
SUSE Labs

