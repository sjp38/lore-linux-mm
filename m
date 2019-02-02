Return-Path: <SRS0=HJeg=QJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F376AC282DA
	for <linux-mm@archiver.kernel.org>; Sat,  2 Feb 2019 00:14:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A227F20863
	for <linux-mm@archiver.kernel.org>; Sat,  2 Feb 2019 00:14:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A227F20863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E055F8E000E; Fri,  1 Feb 2019 19:14:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DB4488E0001; Fri,  1 Feb 2019 19:14:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C7C738E000E; Fri,  1 Feb 2019 19:14:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9A5B78E0001
	for <linux-mm@kvack.org>; Fri,  1 Feb 2019 19:14:40 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id k66so9248829qkf.1
        for <linux-mm@kvack.org>; Fri, 01 Feb 2019 16:14:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=54T7pBveelr5wNuB4Y0kmlu7knWA/DulFqZRo8RUA88=;
        b=J2Bv5IZXjIrBHiRxMf464FAayCD2YEPKIj0ahHVKifSta2n3c3hy/Ofplg11P9a6Q6
         sJ9Z+JnNXEEYWwyf1W99yk9n0EaCBBNDKL1IdHIdMZ5u3vOHPaoeliSmT0OhKraPAf5V
         L81uR8TiVmvhia/4yCir/HIJtTS7u19kEpfjM431V0G0EvXXZ9KgMiyjkaRaC7ng4Uqz
         BQ2FCZOxQdkY2Xkwd3gJa3BdIzhyU6ZwShsNZdCTJC5A8aVPJ50Q+bsrKy4hxrFijv27
         w1F3v+OUOKQS1odyiMHHWOGsL+uvLOHSGH2FC5IRjYpvE+7Int8jjzb/rxGJdaZ/wgo7
         7twA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAub2bEhEnHcDTNKeDzr8f7XeCCb9Tn/QH/U4ouJgjaZe7phZgn+4
	RcMobdgCrF0QojNVhxN22DqxBF0/7f3K9P/dWrSpvAJYsw2V00Pw+jkaFLhi2Um/VSxHzxKv8VF
	FT3XKK0bqlJugJZfDolYpEyUwbzwUT/aH8MPECUSdIMQF3dnndFHFROp3GPS0UbEBOA==
X-Received: by 2002:ae9:eb13:: with SMTP id b19mr4323595qkg.25.1549066480398;
        Fri, 01 Feb 2019 16:14:40 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYDSZYvMq01PK3ytveJjHPFufCCSg752mJ3WSnvncpf1yd+sQffymbu2E8bOlOWLr+e6nBd
X-Received: by 2002:ae9:eb13:: with SMTP id b19mr4323569qkg.25.1549066479887;
        Fri, 01 Feb 2019 16:14:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549066479; cv=none;
        d=google.com; s=arc-20160816;
        b=pAus+X1XldH4vunGxhgicA0mXxby2Nd5flcwFx0UvgVl27PpBddY82vSZ3T5k/2VaG
         7vmCMW+SGZsCeCL4QtwZNeO7RRFbJHY4jd2fTCRh2o5LTmdSZHNCKl/rt0a4f69aOcWV
         rrKggaEqL99eWkQgz/ExDNFMj2bzJ5j+QJomkjvPGkP2lhySBTYv1BgKui0G5iMYGZtl
         bWyWvsfmBReDDLJB7qNxHRKgs95KvSwnxJwd3cs+JEqXjaHkEhjElwt5zW1kVYFTZzIJ
         1cbCoxYjvt/tb2XVMXvZVVL7UPUBqwpDgLKVCSeZlC2SV1NA13T0zKbCdejmRlAHny6s
         tUbQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=54T7pBveelr5wNuB4Y0kmlu7knWA/DulFqZRo8RUA88=;
        b=eyemFjcUXYtUOb5LjRXQsCGxuPf3rPMpQEiMpm7+LjjY+EtgIPmzuWo/jpz6JlTlKb
         Xy0K9UpmHbQLv0d5k7ZgIDMPQbUe4gVv6A4EBhUh2T6DnpgdN1e0r8O6vKkZMD42Up5T
         g4p6z8pH8E6Tr8714bhfOKhBt3eE/rTNb6fIscMfXzJhgcn11BLbgpGxp+m5w8hq1ow1
         8l4SlAyPY/MTLfV4KRxyemtxnRgBWLhC4kf5VCyvy/lvoVzPmrmSSxQO45OlOOUjAhHV
         TcE/i5ZFAHr/S2Po3IgZell9nJhYeZ2a+0PPRH73R7UBbS1uOuo4y0b5hjsNGg+WmEHR
         gUPA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b42si2799117qvh.197.2019.02.01.16.14.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Feb 2019 16:14:39 -0800 (PST)
Received-SPF: pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id AD52C432C0;
	Sat,  2 Feb 2019 00:14:38 +0000 (UTC)
Received: from sky.random (ovpn-121-14.rdu2.redhat.com [10.10.121.14])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id D6FAB1C929;
	Sat,  2 Feb 2019 00:14:33 +0000 (UTC)
Date: Fri, 1 Feb 2019 19:14:33 -0500
From: Andrea Arcangeli <aarcange@redhat.com>
To: jglisse@redhat.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Peter Xu <peterx@redhat.com>, Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>,
	Arnaldo Carvalho de Melo <acme@kernel.org>,
	Alexander Shishkin <alexander.shishkin@linux.intel.com>,
	Jiri Olsa <jolsa@redhat.com>, Namhyung Kim <namhyung@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Matthew Wilcox <mawilcox@microsoft.com>,
	Paolo Bonzini <pbonzini@redhat.com>,
	Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>,
	Michal Hocko <mhocko@kernel.org>, kvm@vger.kernel.org
Subject: Re: [RFC PATCH 0/4] Restore change_pte optimization to its former
 glory
Message-ID: <20190202001433.GB12463@redhat.com>
References: <20190131183706.20980-1-jglisse@redhat.com>
 <20190201235738.GA12463@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190201235738.GA12463@redhat.com>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Sat, 02 Feb 2019 00:14:38 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 01, 2019 at 06:57:38PM -0500, Andrea Arcangeli wrote:
> If it's cleared with ptep_clear_flush_notify, change_pte still won't
> work. The above text needs updating with
> "ptep_clear_flush". set_pte_at_notify is all about having
> ptep_clear_flush only before it or it's the same as having a range
> invalidate preceding it.
> 
> With regard to the code, wp_page_copy() needs
> s/ptep_clear_flush_notify/ptep_clear_flush/ before set_pte_at_notify.

Oops, the above two statements were incorrect because
ptep_clear_flush_notify doesn't interfere with change_pte and will
only invalidate secondary MMU mappings on those secondary MMUs that
shares the same pagetables with the primary MMU and that in turn won't
ever implement a change_pte method.

