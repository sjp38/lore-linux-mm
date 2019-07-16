Return-Path: <SRS0=rp0W=VN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 770A4C76188
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 10:03:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1275620665
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 10:03:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1275620665
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A1A856B0006; Tue, 16 Jul 2019 06:03:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9A2EA6B0008; Tue, 16 Jul 2019 06:03:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 86CC78E0001; Tue, 16 Jul 2019 06:03:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4A6926B0006
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 06:03:51 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id l24so10299159wrb.0
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 03:03:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=lb6duNy/7wLoG9h57KuNjB0tAnNqD9o6T1YVSIMFY70=;
        b=YrHM7+xDfSqJAb2HqCdINFRDQNBHOUPH0rLkPzRkMBo8j35dmwNgZvJg15PrbEd+jC
         2n0mu9K1o14CFMCmYcsJ8VJTH6jU43p0rzD9J662PNu2SH///PgYLbRaBoOTiJwx4eUh
         UAZanvjqUdxzSScSpjLFLy+VnOqeVketwHp9EnbV+I6HiTjBpd9J0QmLVhT4MM6wjJFB
         fDRFifFJiQSs+FNvcBRE12nWBWZUvSVyV0Z+tqIwI7zRXReAQotFI4+yk8TQGkcPVmH8
         cEYTCHGteLGSDt99khJp82jJtWks1IUgmGScSD555vzuWPdZ7PPubA4fFhje1RQyF+hS
         Zyxg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.41 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAWIpclJVwqRFJOfVwZwlAGLaFLy97XGVB4qz6vtZQuP79muVHy4
	ip1KIPYBf44vVluzmmKLPYEats2VoxdkVmukO76cDbu3tUCiOy4j7b5BVls2MGoS3Ct24nCL4uu
	ZG1K+ySk0GteqtWbue1orWm0ePnLP00HguyMpiO7/DyqfOr3W0amVXAHXIOtH9lNYhw==
X-Received: by 2002:adf:ec0d:: with SMTP id x13mr36232256wrn.240.1563271430866;
        Tue, 16 Jul 2019 03:03:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyNVdRsxsLyEuDBIUWbV/0OgN3qtVR5syT1XLT/ozZ5JHKQFSMbig7GcuzXqsEKKmVRKA5C
X-Received: by 2002:adf:ec0d:: with SMTP id x13mr36232133wrn.240.1563271429995;
        Tue, 16 Jul 2019 03:03:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563271429; cv=none;
        d=google.com; s=arc-20160816;
        b=mOW6dLtSRbc8LSUnsPMCU7wcv/zydsnqbATbfEfle1VVauhx6ACbQsmf7KZ7PhrfjR
         KL6H7FZX4vfvXF+Rdx+cz+z1bW5mKzYKliDPH9u+SMm9JHpN29wJAGnLryhi/QqbKk7Y
         ysQp0VmVNnc7NxBixm6w0f8eZugKGcm8YfPgUiATR5ch+mVPUi4AXUgUl7xf6nsv00w/
         DXteHkPJ9sEfwkqWy0/tfkNMkvTNJKnkwDIEpyzn2UQJDdppU7UbUFmOwMeuOkM2VIix
         CLLhI0Ske641xHljFnQZqJfsHMDl6HRTnx3tXWnN0o3JG0e8eHJZLHN4ocbZl1j3YdZR
         nmqw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=lb6duNy/7wLoG9h57KuNjB0tAnNqD9o6T1YVSIMFY70=;
        b=zsnnQWYO+ByWUoyORJZKVIog1TF03f3SnoNnDhiybO8iJB9cp2R81DKiaiMKJJ30IQ
         kpGRbkCpLAI/i1BMnIhocVmT5QlzRpscXPGa54E/47Cb04sYOiKHRTXeKO0T77BrbLaR
         wB8qv6NDr4JPd92JV+KX/nwO2p0oJ79MEyZ4pWDpAG20G5ZX/xt8CJHA5PKiUXO9Rj/T
         Ycr9I5iZA9jsWcZJbtwoq83EZL6Cw77dFbsXYUJWFxMyTjeHf7mhcSAkL/GgUIony0FH
         SL/Ynkmy+pSN95ZkC5LX82xNXbdQZTKZuCKLb9YUffBqR+b5RpZgB03wQSat/8yYR9Ge
         SWeA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.41 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp21.blacknight.com (outbound-smtp21.blacknight.com. [81.17.249.41])
        by mx.google.com with ESMTPS id g3si22611288wrb.272.2019.07.16.03.03.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jul 2019 03:03:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.41 as permitted sender) client-ip=81.17.249.41;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.41 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp21.blacknight.com (Postfix) with ESMTPS id D2F5AB8900
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 11:03:48 +0100 (IST)
Received: (qmail 15829 invoked from network); 16 Jul 2019 10:03:48 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[84.203.21.36])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 16 Jul 2019 10:03:48 -0000
Date: Tue, 16 Jul 2019 11:03:47 +0100
From: Mel Gorman <mgorman@techsingularity.net>
To: howaboutsynergy@protonmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Re: [Bug 204165] New: 100% CPU usage in compact_zone_order
Message-ID: <20190716100347.GB24383@techsingularity.net>
References: <bug-204165-27@https.bugzilla.kernel.org/>
 <20190715142524.e0df173a9d7f81a384abf28f@linux-foundation.org>
 <pLm2kTLklcV9AmHLFjB1oi04nZf9UTLlvnvQZoq44_ouTn3LhqcDD8Vi7xjr9qaTbrHfY5rKdwD6yVr43YCycpzm7MDLcbTcrYmGA4O0weU=@protonmail.com>
 <GX2mE2MIJ0H5o4mejfgRsT-Ng_bb19MXio4XzPWFjRzVb4cNpvDC1JXNqtX3k44MpbKg4IEg3amOh5V2Qt0AfMev1FZJoAWNh_CdfYIqxJ0=@protonmail.com>
 <WGYVD8PH-EVhj8iJluAiR5TqOinKtx6BbqdNr2RjFO6kOM_FP2UaLy4-1mXhlpt50wEWAfLFyYTa4p6Ie1xBOuCdguPmrLOW1wJEzxDhcuU=@protonmail.com>
 <EDGpMqBME0-wqL8JuVQeCbXEy1lZkvqS0XMvMj6Z_OFhzyK5J6qXWAgNUCxrcgVLmZVlqMH-eRJrqOCxb1pct39mDyFMcWhIw1ZUTAVXr2o=@protonmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <EDGpMqBME0-wqL8JuVQeCbXEy1lZkvqS0XMvMj6Z_OFhzyK5J6qXWAgNUCxrcgVLmZVlqMH-eRJrqOCxb1pct39mDyFMcWhIw1ZUTAVXr2o=@protonmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

I tried reproducing this but after 300 attempts with various parameters
and adding other workloads in the background, I was unable to reproduce
the problem.

-- 
Mel Gorman
SUSE Labs

