Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EB0DAC43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 19:13:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AD8AF21738
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 19:13:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AD8AF21738
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 46D6F8E0004; Tue, 19 Feb 2019 14:13:31 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 41D168E0002; Tue, 19 Feb 2019 14:13:31 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 30BEE8E0004; Tue, 19 Feb 2019 14:13:31 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id E25C28E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 14:13:30 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id d16so2610435edv.22
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 11:13:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=mr46pMwpCOQh86d5trZKD/LdvZrpNnuKsPHptt2rxuc=;
        b=IfH3biWkF4MH6Rq6FtmQkRGkCvJkJR47SwixqFlhWLCznPyA2YF0eNwf9zHVjY/07k
         jorPtKQr+2oDLe4EgQo70UK5CqSGXZkjO3dO3QbdS/SfIWh1lk5CvIHixE4KIXbbptT1
         1pVPRQbDFKfyAr7lZtSIX53t+DWg6VKqPRmOZv0Ew9E8LEeyOju1OVgz8bvHoHRdT/LG
         NY0K8Gdc+aLgFPNBHnYi583dQKdsCce2hjWks1ruxtd4CECBa4PTltcFFu1Kn4rdLv8Q
         uoXMzy5r/kIaJpfLTMUvHDzsc1kaGPlOhxVBncK0WJ8eS4ZR1VkrgiCsVQE5TtlrlSDx
         2ONA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuYpIPQ6dLdmYVxJxxNNwnh9WchijwqQ4+U7JnvVsyh33KOifVOA
	stJYV6vH0Bqn5bjOqNhEBoaNfD2ZKbhaRnXllQW/qrAX9qyQ1nnJkmGg0fBP/BXJb//PLr/16Jg
	0Qm2bmBRkJqwynR7mpUSECJ1tN+l/24G0f/sJj8gRjQ/FOhCW+agXkTiB2d6GJ7k=
X-Received: by 2002:aa7:d987:: with SMTP id u7mr1522074eds.194.1550603610490;
        Tue, 19 Feb 2019 11:13:30 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZb6yGWACRdmhwodM1nQZWQpTz1zpAR2CYGhwdFAMM8EzLS+tR+Elnfiu4M3DP5ah2+Gyd+
X-Received: by 2002:aa7:d987:: with SMTP id u7mr1522032eds.194.1550603609565;
        Tue, 19 Feb 2019 11:13:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550603609; cv=none;
        d=google.com; s=arc-20160816;
        b=fR65QmW/ICoJ9mpWi2iHELtKFZsJuYwlj75XBh0+CCOHvTvuSQsB8bYA4QC6bPilym
         FBhJi5SkIOQ4p9D4V9EwMOKV961qytbCmibN1orFuGNRpOUApvKRTyR9fAXC2CSM68gw
         Y90UPILRFEwuvwYAu7p0MAgKaazvZEgmwqPNJLBNAfCXyx5Qoiv0RMn/fHZh1CwACWLl
         JD5IBpN9jBnsAzuqKKt15yjUXlJW3FaionDug6lxA2tiUHA+TOcPJk03Z1J8RHYSJPWU
         OGcIgRvsD8sRZ/J747GsFiuO4YbMGgpc1hXGQF6Ph0+EaSblSswuHmtuo0GNpy5a8DNP
         1acw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=mr46pMwpCOQh86d5trZKD/LdvZrpNnuKsPHptt2rxuc=;
        b=irMpyL9uN+HgVyvfXKR+9z48V7V6bGq4KdoA33zN1FdrDG9fj6f7QEkwKF2Zh98VkH
         GsRg7C2uZhvK/kejLBTjbwOP8g6DED7BKNwjLc41U4noJYiubxcfpvCb6/oaAhAhv1qd
         CiJc8TnyLW+4y3fe2f3uBQQZs9162/xo0gJinAnbeL0Cnb7A+65wYfcFCTlW95+oEIeq
         oQ/uwdve9TfCfAbVC1NJlSL6ktShkNvqCbzwgsIlO53CR/PBgyCBJEjDP4oWHr+Z4kfy
         sOUDDQHSlcjnVDnAwu0JXwBvLxyWHL7DkDJyDNYZqth47ZhhQ9g03f1FdsX9F07IYUXa
         roXw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y9si1322834edm.251.2019.02.19.11.13.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Feb 2019 11:13:29 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id B0EDBAF56;
	Tue, 19 Feb 2019 19:13:28 +0000 (UTC)
Date: Tue, 19 Feb 2019 20:13:25 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Christopher Lameter <cl@linux.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org
Subject: Re: Memory management facing a 400Gpbs network link
Message-ID: <20190219191325.GS4525@dhcp22.suse.cz>
References: <01000168e2f54113-485312aa-7e08-4963-af92-803f8c7d21e6-000000@email.amazonses.com>
 <20190219122609.GN4525@dhcp22.suse.cz>
 <01000169062262ea-777bfd38-e0f9-4e9c-806f-1c64e507ea2c-000000@email.amazonses.com>
 <20190219173622.GQ4525@dhcp22.suse.cz>
 <0100016906fdc80b-4471de43-3f22-45ec-8f77-f2ff1b76d9fe-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0100016906fdc80b-4471de43-3f22-45ec-8f77-f2ff1b76d9fe-000000@email.amazonses.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000008, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 19-02-19 18:21:29, Cristopher Lameter wrote:
[...]
> I can make this more concrete by listing some of the approaches that I am
> seeing?

Yes, please. We should have a more specific topic otherwise I am not
sure a very vague discussion would be any useful.
-- 
Michal Hocko
SUSE Labs

