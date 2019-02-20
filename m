Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4898BC10F01
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 13:27:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DFBF820C01
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 13:27:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DFBF820C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 494288E0015; Wed, 20 Feb 2019 08:27:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4501A8E0002; Wed, 20 Feb 2019 08:27:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 333E08E0015; Wed, 20 Feb 2019 08:27:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id E2CD08E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 08:27:38 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id d16so3672406edv.22
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 05:27:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=c/wB29NlHCvEw+lV5GZl1mOg3Zd+Lh0sWLkBTG4z+HQ=;
        b=VwvAzKNcf5ZbEEfjN6VK5hKVixM6gsqL2Ky6odOIbR6twvEE1ONpFM/9ah1W+Ucer6
         t+PlK6z8dBH1zGizMQXZtGn7WvjK5wmbGm2GC7CHhZirjaODC5Nd0HYmFcxmVpfGQ9Ld
         8lFl5fpvSb8/NxSrT5wMBp+gtjK//tLU76Bp8KgjgikNpOiA3rl/Jr77l6BwLd9guWM8
         zhs/xDFrD/MxdtQ/+7NC+rl35bMRPtLlUmbMHztEcHuDFmsjh3zizTHBGg6uwCNtlUal
         rdisad3cHtCwa/F6JiDDEdHXnp1+Mr3Zokdfdb8awgLje254D6NiCStm37epHMHswkIK
         jISQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuZS4bL5eiSNOPTsWXaMr2QlMF+HFiKwbnoyAU5d05SjuMzBxdC6
	y9bMbE0fQZN7RGveyYWFio7D+/fOz2LLrq1X9Hd/HC22fJzbzWdl7qQNReOpRLob/v0qTCAvh3G
	GBaoZW+lc/g0fvfucvPai8iB4GOsvQV2SK0k8q/uTuxYn82i2IIvLNNom/61TYOQ=
X-Received: by 2002:a17:906:d18f:: with SMTP id c15-v6mr23589243ejz.140.1550669258398;
        Wed, 20 Feb 2019 05:27:38 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaEN6nUr8sP7EELL7kp3On8P2VqpjxLTPG7LAhFfI0UGSMma6M6aed3jC6yNllVvUnJKpSj
X-Received: by 2002:a17:906:d18f:: with SMTP id c15-v6mr23589204ejz.140.1550669257415;
        Wed, 20 Feb 2019 05:27:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550669257; cv=none;
        d=google.com; s=arc-20160816;
        b=lbDIf2T0lzl0I1tISOry1HobgymSJ3uF5TrUW6OG4Qv/UDizdeqtpXG/Z9Es1m/Qu6
         7NRuHQGir6jSjbYDzzuJ+4DpDecqTEFGUAiR4yT+dnZnP2Ic7HzCSlRkpPMVXW8o+37R
         x9gNPWzTirFiVxVIrIrYsKmH5XCNnbzzhdc3juQ0HcTSO0FWK4YyOjxQViZl91bCf4I1
         McyrxRLWvVJBJUZ8pTvheLzR+j1I7bJg/dtvwAA5KZnGrDjskQ9BuzS10144jiAg5RY7
         X3eDJL6soCKK4rFBA97kX/LMILWeQ/q2HQ9NFF79HuW+OymJxcY3cxNLjJAmR78LMzKW
         bUHg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=c/wB29NlHCvEw+lV5GZl1mOg3Zd+Lh0sWLkBTG4z+HQ=;
        b=kuh0Uz/4cflcEiMnIVD/yLR9r6JDoeWVZpe0ikrJPJCbF9zUxUrRENwgnRu+3arkwL
         vcIzaO7aNqeR0TyhSMP4jCY7BbSCYtJ3OWlXi8To/cm0WjNNhvJbRFV2zH2Oqs37D9s1
         0wH1XU1QOv+k5b6+PPmh2r92Ryd8ljAzm1Mce/uAeBk/0sF61/LsBcIDN3/pUJD/bzNm
         p4dsbbBeYzPlcyueuIL0rJ9LuxW/miNsJA1puRsv3EkQwYEP3NLBOBeshWxi7/XH2Aw+
         Z0cvhPkyCE0F8RAi5tpZeZ1tBQoZTqTsIZB+h2THKG1RxxoSU/DguXTUDfsG9jnlwGXz
         WnOw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y8si1901402edp.247.2019.02.20.05.27.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Feb 2019 05:27:37 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id E36B9B648;
	Wed, 20 Feb 2019 13:27:36 +0000 (UTC)
Date: Wed, 20 Feb 2019 14:27:34 +0100
From: Michal Hocko <mhocko@kernel.org>
To: William Kucharski <william.kucharski@oracle.com>
Cc: lsf-pc@lists.linux-foundation.org, Linux-MM <linux-mm@kvack.org>,
	linux-fsdevel@vger.kernel.org
Subject: Re: [LSF/MM TOPIC ][LSF/MM ATTEND] Read-only Mapping of Program Text
 using Large THP Pages
Message-ID: <20190220132734.GC4525@dhcp22.suse.cz>
References: <379F21DD-006F-4E33-9BD5-F81F9BA75C10@oracle.com>
 <20190220121016.GZ4525@dhcp22.suse.cz>
 <E419EE42-B9DC-4612-8B40-5AEBB9CCDD93@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E419EE42-B9DC-4612-8B40-5AEBB9CCDD93@oracle.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 20-02-19 06:18:47, William Kucharski wrote:
> 
> 
> > On Feb 20, 2019, at 5:10 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > 
> > On Wed 20-02-19 04:17:13, William Kucharski wrote:
> >> For the past year or so I have been working on further developing my original
> >> prototype support of mapping read-only program text using large THP pages.
> > 
> > Song Liu has already proposed THP on FS topic already [1]
> > 
> > [1] http://lkml.kernel.org/r/77A00946-D70D-469D-963D-4C4EA20AE4FA@fb.com
> > and I assume this is essentially leading to the same discussion, right?
> > So we can merge this requests.
> 
> Different approaches but the same basic issue, yes.

OK, I will mark it as a separate topic then.

-- 
Michal Hocko
SUSE Labs

