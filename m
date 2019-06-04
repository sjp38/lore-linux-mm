Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DCFE5C282CE
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 11:43:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 87CD7245BB
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 11:43:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 87CD7245BB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=units.it
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1E6816B026C; Tue,  4 Jun 2019 07:43:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 196476B026E; Tue,  4 Jun 2019 07:43:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 085856B0270; Tue,  4 Jun 2019 07:43:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id B839C6B026C
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 07:43:50 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id q12so2112061ljc.4
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 04:43:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:to:from:cc
         :subject:in-reply-to:mime-version:content-id:date:message-id;
        bh=f24ekZm2ys8hucc4CJN6hVJobWFYc9ZPOl9iZ9PZmpE=;
        b=GOiYBWCJkTQkIs99u+YJXiD5EBeCpqIGqT/AE3MBNtlvFcZNEzHTrQkz3zxHpwJAXS
         +Y5ul2yB/sGSqs++Z2lO5Yuq/0qoDfxz3IHCTr6B6dEhjAkWFadm6FvPNINsxH0CtLPH
         AsETgxQ280C1xV7b3d0NY2yhq1dsEwuCr0vyNs0/mx3U2YdqNDtT9xgnWemkSgXUzTHA
         n+mhc7A0C3PggMzXsLhOr/jVBfgnsPPQqmqTFoCL/y9MWBPWDvek8aEf7kyP3PdkwK80
         ZMfYqks9EmtWfNy9ORJW2nFkcFUJNHM+Hm7XMmaFJ9uH80pGdWfx6oKnCrhNRAYSDogf
         kEFw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of balducci@units.it designates 140.105.55.81 as permitted sender) smtp.mailfrom=balducci@units.it
X-Gm-Message-State: APjAAAWrbqfS+hc/kdkZNaPrG89cjmR27beaSK3n3mP6nJagTPGGJtTc
	6z39OybhCYfAloipT2kDeRCX3CEg8oV0oPDCpfEuQbzXB40JYKvRPNuV1piK+52/kS+ObNtNpdK
	OKfXzuu7Qee0DRKHxl0OXaoPqt/4pYq/hOPI0Z0UZ/Mvc0CJvQ6zO2ztaKnHWay11kw==
X-Received: by 2002:ac2:44d3:: with SMTP id d19mr13100998lfm.30.1559648630081;
        Tue, 04 Jun 2019 04:43:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyFsxuQl4OVuTHAeAAXS+ELy75KjNXYCJ8zW5vuIIHrht2eqW1gkZ2Tf+5pcgXnNAIG+RZR
X-Received: by 2002:ac2:44d3:: with SMTP id d19mr13100969lfm.30.1559648629249;
        Tue, 04 Jun 2019 04:43:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559648629; cv=none;
        d=google.com; s=arc-20160816;
        b=rqR10+9CoqFZc9G9s9+Rj39IQ3vpgELrqwr2WtpdYpQQkIYm85/TOUt+T+lpCf4Po5
         5VYD4qpXLjYHK1KfiS16N8owaJPd3+lpVuAlZO2CJPK/Qe1Pf3nnIgi+VPv2AB2XpOG0
         o/iATj2J7t1zLaIThqW5hJv831tLb+X9JBE0QfobSfgQJkqxMZpHaS6G8mlOLesVJwuq
         FJjix+kbDKvHyI/duAzi0GzM0LLDxrh7IaHOBPhC69h6w0LiTjGIZVr3Fm4EX6xUlzyB
         CDD9PpPkaKY6Ol0A6xfzWQUibn6eVlKnN5IRW2GKtI2YX1SlV+h9LP6i7CU4A4iXsT2m
         bZow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:content-id:mime-version:in-reply-to:subject:cc:from
         :to;
        bh=f24ekZm2ys8hucc4CJN6hVJobWFYc9ZPOl9iZ9PZmpE=;
        b=RPTCftfBGi2nAYpztwd5zyN+n/9NrhE/6Xg/UAVbbkiitLpVDwfVLFCzcj2TpHGSi7
         HpvCnasa1cnFWXmN5U/Ft+0GBWzdl7YzRBupnZKiHFMpeazF1DsYceRooVh04bXPMnVx
         ad0xHY5YKhwAm3aHYMVlDiVb/f3uDpEWuIGuBOCGscYSfJ5q0YjejaJtEHyHefY8VjlB
         K6ngZRgcTGqtunmGFI0OUn0Fp/3kinfvnvmnam27AJ+9l3iglxuVyWB6vGfo4HrMyz43
         76/NXEFj3/k8mLWD8fOYqS5RNyqJH72CbcBmO7W/6SvlRehrznK3+YiQizAANvn05h7x
         IvFQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of balducci@units.it designates 140.105.55.81 as permitted sender) smtp.mailfrom=balducci@units.it
Received: from dschgrazlin2.units.it (dschgrazlin2.univ.trieste.it. [140.105.55.81])
        by mx.google.com with ESMTP id j6si15351020ljc.31.2019.06.04.04.43.48
        for <linux-mm@kvack.org>;
        Tue, 04 Jun 2019 04:43:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of balducci@units.it designates 140.105.55.81 as permitted sender) client-ip=140.105.55.81;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of balducci@units.it designates 140.105.55.81 as permitted sender) smtp.mailfrom=balducci@units.it
Received: from dschgrazlin2.units.it (loopback [127.0.0.1])
	by dschgrazlin2.units.it (8.15.2/8.15.2) with ESMTP id x54BhLoa005093;
	Tue, 4 Jun 2019 13:43:21 +0200
To: Mel Gorman <mgorman@techsingularity.net>
From: balducci@units.it
Cc: bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org,
        akpm@linux-foundation.org
Subject: Re: [Bug 203715] New: BUG: unable to handle kernel NULL pointer dereference under stress (possibly related to https://lkml.org/lkml/2019/5/24/292 ?)
In-reply-to: Your message of "Tue, 04 Jun 2019 12:05:10 +0100."
             <20190604110510.GA4626@techsingularity.net>
X-Mailer: MH-E 8.6+git; nmh 1.7.1; GNU Emacs 26.2
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <5091.1559648625.1@dschgrazlin2.units.it>
Date: Tue, 04 Jun 2019 13:43:21 +0200
Message-ID: <5092.1559648625@dschgrazlin2.units.it>
X-Greylist: inspected by milter-greylist-4.6.2 (dschgrazlin2.units.it [0.0.0.0]); Tue, 04 Jun 2019 13:43:22 +0200 (CEST) for IP:'127.0.0.1' DOMAIN:'loopback' HELO:'dschgrazlin2.units.it' FROM:'balducci@units.it' RCPT:''
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.6.2 (dschgrazlin2.units.it [0.0.0.0]); Tue, 04 Jun 2019 13:43:22 +0200 (CEST)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000004, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> Sorry, I was on holidays and only playing catchup now. Does this happen
> to trigger with 5.2-rc3? I ask because there were other fixes in there
> with stable cc'd that have not been picked up yet. They are a poor match
> for this particular bug but it would be nice to confirm.

I'll test 5.2-rc3 as soon as possible and report the results

thanks
ciao
-g

