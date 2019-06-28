Return-Path: <SRS0=7Cer=U3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7DB8EC4321A
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 11:59:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 49BE92086D
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 11:59:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 49BE92086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DAA6B8E0003; Fri, 28 Jun 2019 07:58:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D5AF68E0002; Fri, 28 Jun 2019 07:58:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C23DA8E0003; Fri, 28 Jun 2019 07:58:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8B10A8E0002
	for <linux-mm@kvack.org>; Fri, 28 Jun 2019 07:58:59 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id s7so8908082edb.19
        for <linux-mm@kvack.org>; Fri, 28 Jun 2019 04:58:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=EZRnCaSGSt6siz764nraB0N/ye6y5DkVHQCqubqMZNI=;
        b=Z9w1vlTsrkNXd8GVuVp8y6c/zJiOxpoJ76TrTgBLsWySPz4fjqAjLRSmuZwHLhSnWy
         q2Nf+q7O4UGrblSC4WVnrysv8tcamIZD/iePA0bKr8pDZGxzf9wyOWSHeb3C3QXwLSwa
         IEDTurhoaDmsAh7JIfWib6QGVr36uhnkqy1dKjeyPirc4LxULVLvuLNM5Bpnm6aL1K2q
         yT629oO9Mi7FJmwx2Vomt3xVIkNgqIeRMeeQGt1pxl0tdFo2RQnVzo3xJeKlph36vPhU
         thy51v+ryzPiJA17surzFx4yKk/LqfSU7JlnnKSyyv2uYxjH/ku2YTFjriijrNZdmMl7
         K11g==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVrMtXkXOd3K/5F4V1pGrNPt7PYHitad192BXNu1dNTRv1ZhXdw
	7WNJxvATdDpWfBh2sIbL7aGwKGEJKF+Hk21dzPQmN+8MYTGU8JnqpGKpybEpEY9H7h9/0SwOsuh
	t4Ke5HVUU2DjtYB2nQbnRaDhzLieys98p5e4rNJPPEfzWs68SvaxML0SWJniuigo=
X-Received: by 2002:a05:6402:1658:: with SMTP id s24mr10924819edx.288.1561723139167;
        Fri, 28 Jun 2019 04:58:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw5l/XMWZjRiyr95N7Oib3ntYzRsPFgDvlsgxpk5Js1xV5R7NzAfR1ljCd49fYFlcQQkmEU
X-Received: by 2002:a05:6402:1658:: with SMTP id s24mr10924754edx.288.1561723138327;
        Fri, 28 Jun 2019 04:58:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561723138; cv=none;
        d=google.com; s=arc-20160816;
        b=LwNYuFkmohGbcQUVSu0ryrB34UCCKAeeU3xpJIMAxIDNByqCjVoIfxP+NpFEQF6Wkd
         PW5Fp5Ty35QntFxZ0kMKcmZd6LGFWfgvUBJQEuXiwqR5HjkruJxg4lzT3kF/PWzyUpqd
         +dfNcZS1C5CtUfYYsPxSUMtNCqnEvXuOZ66ar1VZOTZo9uya1vglXJw9mcwnX8QnA+s/
         AmbVRf2QMzlbc6r+vzcEwqsVF4G0RNIZ7bq9DIKVixnIFZeVZfYe+thgxGO2fFgvh4XS
         XTosF380Yzdf4etuLcP3Ex+Xg05AnLoo9Wh+lmJJ7pXab38nQHQ+PUWVCWjUIsQOkuB2
         dqLQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=EZRnCaSGSt6siz764nraB0N/ye6y5DkVHQCqubqMZNI=;
        b=Je1369cXXHPiXrbce9xvdRPTPqltk++ebTb9kLUaVy+/Z1AFoKg5zeNBzWsMDOg5CD
         NkZeoUW1uFCKiqbv83yFWgay/+zvjfXDXITpdMINvAS7Jgx+TZLH3idtvsd6oT+PDJhZ
         nwwgvDDGtGucgvrXUV6S2OdHEeq0VAUMZRFD8gUJrWdROFM1KyWcD7BlLvZ8giSO70gB
         IIZLtlAp+Tx72EfO3rVhS8k7ac4JuBubb7mYfqawMICV2dXub0QO2EHbaUnL++r/InBz
         t3UfekhwpURpHtvoW9dvus+zzYaA0On4zMAes5GsV7oLa+e3mDuEFHoJQF/gm0nfwAD+
         iJRw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v9si1948059edm.56.2019.06.28.04.58.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Jun 2019 04:58:58 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 9AF3AB627;
	Fri, 28 Jun 2019 11:58:57 +0000 (UTC)
Date: Fri, 28 Jun 2019 13:58:51 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Hildenbrand <david@redhat.com>
Cc: Alastair D'Silva <alastair@d-silva.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Pavel Tatashin <pasha.tatashin@oracle.com>,
	Oscar Salvador <osalvador@suse.de>,
	Mike Rapoport <rppt@linux.ibm.com>, Baoquan He <bhe@redhat.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Logan Gunthorpe <logang@deltatee.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH v2 1/3] mm: Trigger bug on if a section is not found in
 __section_nr
Message-ID: <20190628115851.GH2751@dhcp22.suse.cz>
References: <20190626061124.16013-1-alastair@au1.ibm.com>
 <20190626061124.16013-2-alastair@au1.ibm.com>
 <20190626062113.GF17798@dhcp22.suse.cz>
 <d4af66721ea53ce7df2d45a567d17a30575672b2.camel@d-silva.org>
 <20190626065751.GK17798@dhcp22.suse.cz>
 <e66e43b1fdfbff94ab23a23c48aa6cbe210a3131.camel@d-silva.org>
 <20190627080724.GK17798@dhcp22.suse.cz>
 <634a6b8e-3113-f0af-f8d3-9b766f8cd376@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <634a6b8e-3113-f0af-f8d3-9b766f8cd376@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 28-06-19 13:37:07, David Hildenbrand wrote:
> VM_BUG_ON is only really active with CONFIG_DEBUG_VM. On
> !CONFIG_DEBUG_VM it translated to BUILD_BUG_ON_INVALID(), which is a
> compile-time only check.
> 
> Or am I missing something?

You are not missing anything.
-- 
Michal Hocko
SUSE Labs

