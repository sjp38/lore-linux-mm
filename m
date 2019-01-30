Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7CC06C282D7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 17:07:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 38E8520989
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 17:07:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="rQjmckmz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 38E8520989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C6B298E0004; Wed, 30 Jan 2019 12:07:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C1AD28E0001; Wed, 30 Jan 2019 12:07:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B0BF68E0004; Wed, 30 Jan 2019 12:07:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 830B68E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 12:07:03 -0500 (EST)
Received: by mail-yb1-f200.google.com with SMTP id t3so121225ybo.15
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 09:07:03 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=r4FvnOpw+Kp/xo1E/oIUXzj02pZKaUP0vrX/v1MVF3s=;
        b=R8nS/FQzr/3gmRkzSH183ncXobFEaPyS6CxE7HgnYpnCfCgjbYDv70PAOyO5sGa+Ob
         HlG9jhesL18nXRAb77jAhkWrq+LmAstBXa88RoMubfG6Ze9Q6Xao61Mis4T5FbaiyMAQ
         yzz6qmNdRTxwr1tDFDtCZqTPoqyzYOu2tYtNQE5zXjb5tuC46MV2DKv0nvwno8p6Vv0A
         t57YK6mD16X5wuNLVEOkjzc+aun1X0lNi6M+OPh+HqjJrVy2zBMLZZKZUwRR76GQYbaS
         h2efuQrQcltYntT/ezLZ0Uur/2/RQRapetVWlPlKGlp1AoaDDiCJwgATl5AQ6KVlO/sz
         +dXA==
X-Gm-Message-State: AJcUukefEQ6MnVFnaqJ/gjwQbj6IRZWK11u6z+n/fYTram++LeF2Y652
	zwj4m+j/u+PVuSnv9NwNQZmPlFpf+kv3YtroVmj+lh3SdbUpoSjIhXAmMhbSkOGVup2+Tc+svy5
	QPy4Z2OFqYOTBC1SvBNSp8VYyyNu/8fqfPBeeOqRrxVwt5tJA2gcFeCslhI7PvCxKmc+uKelrI2
	7MHQkAEFpf6InWmwaI6RW13RE5kTWqdrnclFTwLlfm/hRHyP9S+skg/DYKVv34vWx5pJh4yUgjj
	Jr4mQ5HTssYTUWmiPVXfC7Dj9VGuUOpmEjr8wBG1eJaq+BHznTWNx5I4ROxlOXcQq4gUjmudX2o
	R0yOgPj5Qbmr9ke+NSdkKUZ8IFHLdX6QLFvsq56HnVWgQggPpcB9NMZPsd4Xfn1mN7NRxpXsGw=
	=
X-Received: by 2002:a81:9ad5:: with SMTP id r204mr29599386ywg.215.1548868023191;
        Wed, 30 Jan 2019 09:07:03 -0800 (PST)
X-Received: by 2002:a81:9ad5:: with SMTP id r204mr29599322ywg.215.1548868022393;
        Wed, 30 Jan 2019 09:07:02 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548868022; cv=none;
        d=google.com; s=arc-20160816;
        b=txWE4Q3ywsMsiT+0Ed3fwkstl4xSCAMheJAS6Zq/MWUnJvKgxwpGpSSEt9Rx9UUgBs
         Ehi5RsB4+TZPSUbA59cpiu3KCX8UGeMBWmIXhVrYzKFmOdXaAgvQevG+6nneDAUCsBEB
         1NFHhIA3SjrO0O+96kC7b7VRm/ZijP4YBUVasfa3/QlXJLkuTS+15sGd1Zzh4jTQiw/4
         VqH2ruB2XHQDEePswOXxF7ytM+gTwrhza47P2dZ+TykDedBlaVcNvjQy9Sn0DRdzfaUf
         /vsOh5dOx7zJU4PKPpdDB++ijJSRWsRm00pP3rKFPePgr/CzpzgoIA7/6lXy89gRZX0n
         StIA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=r4FvnOpw+Kp/xo1E/oIUXzj02pZKaUP0vrX/v1MVF3s=;
        b=J9NqV40RToBxe6/Wx1bY9ba1NlGFphBJ4Ymp0G9eWDNhG/hyrVR4BNDMx9zC6JIHXf
         lJy9UKX75sRhOFUT4B0TT/+hapuOEoVSEkXGN/7lnKnuunaIpk9C1apnldpIU0KuhoHL
         AjqFZINZDe5LJ2tM2L+hUafmEhRrFK6YXKkfWc7sSD3U/a9gjsuXrhYBnd3uGN1IYeT7
         ri8y4iN3wp465gkTvXU7aC8WnLs/FVU1Lq00DLsaIaMT0V7HRi255egUnBTDr7TzASDz
         SaBeBZK7WABVAcPmWjRvAeiqB/TJ0zXm28OY9x3Swfv4N8UMTYfuUlLZoqUVHu8Zssvk
         0Ctg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=rQjmckmz;
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v191sor354940ywe.185.2019.01.30.09.07.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 30 Jan 2019 09:07:02 -0800 (PST)
Received-SPF: pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=rQjmckmz;
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=r4FvnOpw+Kp/xo1E/oIUXzj02pZKaUP0vrX/v1MVF3s=;
        b=rQjmckmzAv1TtgaDTf+xwGnxDCZf/qt62fsajJvyFlBof5l/0CVKAG0/RQdHbYUU8Z
         YV3pupMl9wakI8GJ2a6Q6X1czRWRbqRIrvDYdBGenYJH/AT+DrU6hAeWiAJeKafhh47f
         jEDi7+H+xXmSLP+84wuhC/kTT1At/AlXUGMc7YbhpX92ShXurAJwHvoI1VXRc8cN2NoO
         uMKjdB5EwWa9+9c0xWSBmyKrQBV0LdzTOgzkmuI9iU0gbxpf1N+yxqips6zJE2ehg/yz
         2hltgR4GXOpilyhCa+c/RA4A40XOj85aph8KTQMtFbCHYe82rL28IeBb2qbM1WjpktGs
         JPnQ==
X-Google-Smtp-Source: ALg8bN46/CyjNniPd/uEyCmyWWAS1mahMjoWkazGoUDEhY78foz8Nqb7qCmY2P58ISnLM36C8mVYug==
X-Received: by 2002:a81:3413:: with SMTP id b19mr29798236ywa.297.1548868021695;
        Wed, 30 Jan 2019 09:07:01 -0800 (PST)
Received: from localhost ([2620:10d:c091:200::7:e55d])
        by smtp.gmail.com with ESMTPSA id g84sm2015945ywg.9.2019.01.30.09.07.00
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 09:07:00 -0800 (PST)
Date: Wed, 30 Jan 2019 09:06:58 -0800
From: Tejun Heo <tj@kernel.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Chris Down <chris@chrisdown.name>,
	Andrew Morton <akpm@linux-foundation.org>,
	Roman Gushchin <guro@fb.com>, Dennis Zhou <dennis@kernel.org>,
	linux-kernel@vger.kernel.org, cgroups@vger.kernel.org,
	linux-mm@kvack.org, kernel-team@fb.com
Subject: Re: [PATCH 2/2] mm: Consider subtrees in memory.events
Message-ID: <20190130170658.GY50184@devbig004.ftw2.facebook.com>
References: <20190128142816.GM50184@devbig004.ftw2.facebook.com>
 <20190128145210.GM18811@dhcp22.suse.cz>
 <20190128145407.GP50184@devbig004.ftw2.facebook.com>
 <20190128151859.GO18811@dhcp22.suse.cz>
 <20190128154150.GQ50184@devbig004.ftw2.facebook.com>
 <20190128170526.GQ18811@dhcp22.suse.cz>
 <20190128174905.GU50184@devbig004.ftw2.facebook.com>
 <20190129144306.GO18811@dhcp22.suse.cz>
 <20190129145240.GX50184@devbig004.ftw2.facebook.com>
 <20190130165058.GA18811@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190130165058.GA18811@dhcp22.suse.cz>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello, Michal.

On Wed, Jan 30, 2019 at 05:50:58PM +0100, Michal Hocko wrote:
> > Yeah, cgroup.events and .stat files as some of the local stats would
> > be useful too, so if we don't flip memory.events we'll end up with sth
> > like cgroup.events.local, memory.events.tree and memory.stats.local,
> > which is gonna be hilarious.
> 
> Why cannot we simply have memory.events_tree and be done with it? Sure
> the file names are not goin to be consistent which is a minus but that
> ship has already sailed some time ago.

Because the overall cost of shitty interface will be way higher in the
longer term.  cgroup2 interface is far from perfect but is way better
than cgroup1 especially for the memory controller.  Why do you think
that is?

> > If you aren't willing to change your mind, the only option seems to be
> > introducing a mount option to gate the flip and additions of local
> > files.  Most likely, userspace will enable the option by default
> > everywhere, so the end result will be exactly the same but I guess
> > it'll better address your concern.
> 
> How does the consumer of the API learns about the mount type?

It's gonna be a mount flag exposed in /sys/kernel/cgroup/features.

Thanks.

-- 
tejun

