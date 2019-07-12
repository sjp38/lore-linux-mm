Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 42A0CC742A8
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 07:14:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1510E21537
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 07:14:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1510E21537
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 94E578E011E; Fri, 12 Jul 2019 03:14:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8FE918E00DB; Fri, 12 Jul 2019 03:14:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8153E8E011E; Fri, 12 Jul 2019 03:14:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 31FBE8E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 03:14:02 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id c31so6984201ede.5
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 00:14:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=toxXyfFcENzhlGtfCwLXjsG4XsCPKy2Hcjp1RDAf030=;
        b=cOJsA0J3ICYAmDQW5MvrWIlg7HJfY04cT21xhGpqkqs98+mD4ppAkreP/+WTwCqzHv
         +7+Ilk8DGp+3G+jPP+wL3l0qsqdWsQHsOXinRMerr9R1WGHcKWsSPqitzBypZeX0/ID4
         1extU7xQjNxbdSDxJc+hKsZ7OKzgTeYKNEDqyCdX3jTZkRNyaDqASsD1GBpDB9jPnnma
         pwkiwGAIj/ULPr9pxXEILBzbFAQ6VIR9amRC7URiiF06ekQVxl6HdlZ7JMhbxIaD0gOX
         TGy0Zaa0zsBkKBO8EPqprIwVyBwoPTqm1f37ykCiDg4icE6YteN/p03Wf0jWZPxD6Z3z
         +yoA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVcls/JbHHUJ9djtbkY1yKQu5MADBmThyLIimxJyyr6qydHgZ2/
	PxqsNhB1/vAFaaSr6IU/NH2EaxtRlBLpm1Ejm6LafMrvv8yeb4d+jOfPBYXIbX1wJLg7H9G0aTA
	XeUOZpi90zMROIztfMEVSn4JkMquhZ8VtxGjrnSdfRJymfNodBeZc2pryrUA/rFY=
X-Received: by 2002:aa7:c486:: with SMTP id m6mr7747187edq.298.1562915641777;
        Fri, 12 Jul 2019 00:14:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzA4yf+m/sarjtxkD3Z+tWum2Nc4hpua2j/bK2O4OYAgL2fzwEGsgKY7YzKV/O5lkbE/M8v
X-Received: by 2002:aa7:c486:: with SMTP id m6mr7747146edq.298.1562915641079;
        Fri, 12 Jul 2019 00:14:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562915641; cv=none;
        d=google.com; s=arc-20160816;
        b=xd5+eKm9nvslu+lQeIHrvY4vmoalQBbEjqvBhfHPqmVygsQxUIkfMpfkNkDv8Zm6Os
         kLc0Ep/FK55NXATF12zEXBmz/U6uxLIvAcuiUZEAqQCNkIaLmtzjy0VLgKRs8voq6IVk
         poQxs241lnFkGuW5Hh0c7Oe8Yh+6Fub1yqD9EcaHCCy1Qw/uOGVFoLqtCYlmaIPijRII
         LyQDUvs66eKneo+nFWhwIfcZODc1VpFPg7Ppcwmqs52FXBtOCgP1cVL0ugfhdLm+cCJD
         Hh0wcFjupjyPwC8ohXPNdgQW9GJJFbZ4bJOsH9QPJHVML7ybT+6QyPqZlZmRgRlmtvHU
         tKkw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=toxXyfFcENzhlGtfCwLXjsG4XsCPKy2Hcjp1RDAf030=;
        b=riYbl6qGrovo0680AaOghcpYS5c7Hm1H/zMYitB+8oV7/pHQ37x4ZNm8pmaNo/gnXX
         +cgn5ZANv9ZqBfvWbQSz3IteKeA4QYuKv2lmg08LAxt05HZGydplBFNnt0Xhs31IwYLw
         CBwi/WwI+/XARvYnyR6ro9LISJ00wePmd/cXEkPZy0iXSiClMEpWX7mXL/qT5saanOzM
         fT2qP12mYNmHkVFDRvBEzxNdVq4N7PQ8W4907C5iAABLIJ1u0/0U6cX+RIZ4Mmymor0V
         hmkh2wlaIRgKSPghITJMwfFmnkIZJe1HsxPRJClZ666Gcc3eVwu1VI8t0GyRPHpluUAx
         LO5A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k28si5823566ede.131.2019.07.12.00.14.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jul 2019 00:14:01 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 38EF9AC2D;
	Fri, 12 Jul 2019 07:14:00 +0000 (UTC)
Date: Fri, 12 Jul 2019 09:13:59 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Kuo-Hsin Yang <vovoy@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Minchan Kim <minchan@kernel.org>, Sonny Rao <sonnyrao@chromium.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	stable@vger.kernel.org
Subject: Re: [PATCH] mm: vmscan: scan anonymous pages on file refaults
Message-ID: <20190712071359.GN29483@dhcp22.suse.cz>
References: <20190628111627.GA107040@google.com>
 <20190701081038.GA83398@google.com>
 <20190703143057.GQ978@dhcp22.suse.cz>
 <20190704094716.GA245276@google.com>
 <20190704110425.GD5620@dhcp22.suse.cz>
 <20190705124505.GA173726@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190705124505.GA173726@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 05-07-19 20:45:05, Kuo-Hsin Yang wrote:
> With 4 processes accessing non-overlapping parts of a large file, 30316
> pages swapped out with this patch, 5152 pages swapped out without this
> patch. The swapout number is small comparing to pgpgin.

which is 5 times more swapout. This may be seen to be a lot for
workloads that prefer no swapping (e.g. large in memory databases) with
an occasional heavy IO (e.g. backup). And I am worried those would
regress. I do agree that the current behavior is far from optimal
because the trashing is real. I believe that we really need a different
approach. Johannes has brought this up few years back (sorry I do not
have a link handy) but it was essentially about implementing refault
logic to anonymous memory and swap out based on the refault price. If
there is effectively no swapin then it simply makes more sense to swap
out rather than refault a page cache.

That being said, I am not nacking the patch. Let's see whether something
regresses as there is a no clear cut for the proper behavior. But I am
bringing that up because we really need a better and more robust plan
for the future.

-- 
Michal Hocko
SUSE Labs

