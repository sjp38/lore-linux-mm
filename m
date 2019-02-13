Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8FC71C282CA
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 09:18:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 49AD4222C9
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 09:18:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="aJBR3p8U"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 49AD4222C9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linuxfoundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CE2FE8E0002; Wed, 13 Feb 2019 04:18:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C91898E0001; Wed, 13 Feb 2019 04:18:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BA7128E0002; Wed, 13 Feb 2019 04:18:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7A5918E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 04:18:07 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id b8so1435077pfe.10
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 01:18:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=ezC/cSIEOi9TZhW/zhe4OwXuUzMJ8JGy1VtqvyP7VJI=;
        b=cC25Ah+L0wyARPzEUwP3h3SBzCYEqCD3UYO7jdZPJLWmSZUTsim/TCSFtsNmRsxN3R
         Z/WoXxzfjuSxBoTjdz7aKvFcDpSsG8I7wDj60VR1/NBkAtZPoQdqDMtOKlBYee7yzkj9
         0e2dIG5zXAf0u05KlhB5KDVDK5CckuzXW2W5tvCvWUlcpaq9ZQiSvJI1vYqp3u74PrWL
         YbHIZ59E6o9OFlCAxW/i4L7l8TyfR1z1xdnzLJFiywI6gfy9yAHlzMCrzNzoo7CvqQYt
         WTQToFujMwkJc+cLeU3RahEgHPjRQKDigDdXKP2SNqtoRzXq4Fwia0rgfuZF6fvlub20
         pEcA==
X-Gm-Message-State: AHQUAuatGcPbERmBL9Ih9QMTO6ggNJOOwPT2OQLb6DIUGMGc+yi6K/3W
	PqRD1Th7iVq/IK9lVFEcyGHiEY97zL07hUXub7PG7tUwWFbs/T1BE16k6Be3TemFbUkGjlzvcfg
	ja/Pr75WFDjdJOyH4wH6sT/3eBbPsNRZ67mdgPbix5WA0MXapHPV8zkMJYrE8ftU=
X-Received: by 2002:a62:35c7:: with SMTP id c190mr8886196pfa.76.1550049487086;
        Wed, 13 Feb 2019 01:18:07 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbLRxCGHcJb4S/TnZOwhcmOaGLDmUWjp1xEL0rTHJ18AYkjRXbmf86adn4e9ra7CctrQSql
X-Received: by 2002:a62:35c7:: with SMTP id c190mr8886132pfa.76.1550049486104;
        Wed, 13 Feb 2019 01:18:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550049486; cv=none;
        d=google.com; s=arc-20160816;
        b=Zdfp8vm+aQZjnrvHbiBI+mS0uyuYDBy7gCnUD/AzEJIPgwZNW0f7n3ChDQJidHdKT3
         Js1Sqz19ORgGSrYlHuhCO6SVbyb9ZROvWkV27IYCT+eqT4Jb9jTbMs73BiKHzarYpA8Y
         6UiuUGz/dlYlHJawgFEs3oLjYqukrj5c4j6hvFD60oIpKpqMOBzR+gU60y8c2XGg8JR2
         iDCE4fX9S87+zvM5rAQsqVX+P344frOLGgoZHI2GjU8XmphJgsMrQXct2DwXO7pKNy77
         rz+LqZRQQHwOAqdjrFIItOtlDIBVlwIqlkrGX0YTTE6DKHWeTdb5Af0wHNLyj88m69zF
         VIqg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=ezC/cSIEOi9TZhW/zhe4OwXuUzMJ8JGy1VtqvyP7VJI=;
        b=CQe0U2e7jd7514QJtf/1xSECTf9M3hWtCyWcDiib3AeBjgs0siucblUFjimm6+IKLh
         1STXRv8WnnAZv8BbcWbmhhw/LjXzNm4m3y5QbBm1YBrfNBLDGevi847DtXbdlMqmChs2
         2izvNqdFU1jss7hmHxhoXN2r7gnjRZ4AaC+2iWyhYzIW/yq45Qb1QC4fSuBekVRVOCbj
         ZXdPg10Z+n40/jnb+7lDMDRvCGhT6d2YoDkxZE2FYFrARY6uRsNM/JnOmtTnSCPjMn+T
         Rv8kFx1rushWI6NuqzEQPbzYvJU4lcJHgUoHMtuglsT9w9P1aTAJHBCQ6+9ybwui99dB
         Osmw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=aJBR3p8U;
       spf=pass (google.com: domain of srs0=8kuc=qu=linuxfoundation.org=gregkh@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=8KUc=QU=linuxfoundation.org=gregkh@kernel.org"
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id b1si8312376plr.379.2019.02.13.01.18.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 01:18:06 -0800 (PST)
Received-SPF: pass (google.com: domain of srs0=8kuc=qu=linuxfoundation.org=gregkh@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=aJBR3p8U;
       spf=pass (google.com: domain of srs0=8kuc=qu=linuxfoundation.org=gregkh@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=8KUc=QU=linuxfoundation.org=gregkh@kernel.org"
Received: from localhost (5356596B.cm-6-7b.dynamic.ziggo.nl [83.86.89.107])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 286E8222BE;
	Wed, 13 Feb 2019 09:18:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1550049485;
	bh=OBwtMif6U+gAaRqAxV3AgL7zafK6ORpn+3ToEs1jewg=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=aJBR3p8UeaFYq4Y9hKmUYhWwNBpI/rhmNsqsWY5DyLtM70GEH2zsy934/UJrWt0UQ
	 YlRgwty3vJMnXJEYcGPMOCe90hxSs6XnD2eriPsByXASy9gNMWSFhdXkTRVXQc8CVi
	 P6OKqoUYaAOb5ywdBMwvzWG5uev3p2PZSm37lpAE=
Date: Wed, 13 Feb 2019 10:18:03 +0100
From: Greg KH <gregkh@linuxfoundation.org>
To: Amir Goldstein <amir73il@gmail.com>
Cc: Steve French <smfrench@gmail.com>, Sasha Levin <sashal@kernel.org>,
	lsf-pc@lists.linux-foundation.org,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	"Luis R. Rodriguez" <mcgrof@kernel.org>
Subject: Re: [LSF/MM TOPIC] FS, MM, and stable trees
Message-ID: <20190213091803.GA2308@kroah.com>
References: <20190212170012.GF69686@sasha-vm>
 <CAH2r5mviqHxaXg5mtVe30s2OTiPW2ZYa9+wPajjzz3VOarAUfw@mail.gmail.com>
 <CAOQ4uxjMYWJPF8wFF_7J7yy7KCdGd8mZChfQc5GzNDcfqA7UAA@mail.gmail.com>
 <20190213073707.GA2875@kroah.com>
 <CAOQ4uxgQGCSbhppBfhHQmDDXS3TGmgB4m=Vp3nyyWTFiyv6z6g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOQ4uxgQGCSbhppBfhHQmDDXS3TGmgB4m=Vp3nyyWTFiyv6z6g@mail.gmail.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 13, 2019 at 11:01:25AM +0200, Amir Goldstein wrote:
> I think the main difference between these review announcements
> and true CI is what kind of guaranty you get for a release candidate
> from NOT getting a test failure response, which is one of the main
> reasons that where holding back xfs stable fixes for so long.

That's not true, I know to wait for some responses before doing a
release of these kernels.

> Best effort testing in timely manner is good, but a good way to
> improve confidence in stable kernel releases is a publicly
> available list of tests that the release went through.

We have that, you aren't noticing them...

> Do you have any such list of tests that you *know* are being run,
> that you (or Sasha) run yourself or that you actively wait on an
> ACK from a group before a release?

Yes, look at the responses to those messages from Guenter, Shuah, Jon,
kernel.ci, Red Hat testing, the Linaro testing teams, and a few other
testers that come and go over time.  Those list out all of the tests
that are being run, and the results of those tests.

I also get a number of private responses from different build systems
from companies that don't want to post in public, which is fine, I
understand the issues involved with that.

I would argue that the stable releases are better tested than Linus's
releases for that reason alone :)

thanks,

greg k-h

