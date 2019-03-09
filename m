Return-Path: <SRS0=P3wr=RM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9A88AC43381
	for <linux-mm@archiver.kernel.org>; Sat,  9 Mar 2019 12:49:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 36A3A20836
	for <linux-mm@archiver.kernel.org>; Sat,  9 Mar 2019 12:49:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 36A3A20836
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C51E58E0003; Sat,  9 Mar 2019 07:49:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BD8028E0002; Sat,  9 Mar 2019 07:49:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AC8408E0003; Sat,  9 Mar 2019 07:49:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 507CA8E0002
	for <linux-mm@kvack.org>; Sat,  9 Mar 2019 07:49:28 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id j5so116850edt.17
        for <linux-mm@kvack.org>; Sat, 09 Mar 2019 04:49:28 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=0NpGcYltsgE4WItEEmaOTLOQuPIWs0m8pWYJLOZzsqw=;
        b=FPkHBP8S8bXD2rw081KDJOzLJLInuuFpPUFSvV+7Rn9r6oka+IdSbHz72/WJBed9Z/
         bCSluhkN1YKcFiJT2fhnRTnBCHZMzXXjhGUe6QSET0ToM2BCBMhDo56KXHgs06nuaGxB
         /27JQo1G8QaArdxyNyhHQz9AWyHG3jMqltiSJCwSQqzDzLDfWZDhSAXHDoIRewNVkcF/
         rX1qVkiNs5UjZd+L0fW07cdumvh9TYTRtw0d4iA5T+qpK0+mUSbm0DZC7JqdLEm0Ph47
         noLxOzckxmwLVnewE6nJlD7tWARvCqagc00kwRbwznKyeKJx9GiBelyJ8dLhU684EXwS
         3MTg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.17 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAUS4JyP68C9Ii5vk7iZT3cbJQux/CzoXGJtuTj6QFl04hbvrqW2
	7pGIoBuK5ECf492l5g/+K8tNRSB4CN8jW8RHQk8Q055++3L5od6bVlFri0T/pc0Gnz0KEyuWq4L
	Awd3mlAidCQWGuiDz6oMp5iliLUU0dMLnkMKfR+QGDgiHqM9E+zN8Dmrl9yq8gTg8ng==
X-Received: by 2002:a17:906:678a:: with SMTP id q10mr15050637ejp.156.1552135767813;
        Sat, 09 Mar 2019 04:49:27 -0800 (PST)
X-Google-Smtp-Source: APXvYqzVAQsuEplesvgl9uLyRkp2KhKvR0cGdiaU6HZmFC4jhOu/OdelxEw+KzsUXp7lb094mQbV
X-Received: by 2002:a17:906:678a:: with SMTP id q10mr15050597ejp.156.1552135766894;
        Sat, 09 Mar 2019 04:49:26 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552135766; cv=none;
        d=google.com; s=arc-20160816;
        b=HgucV7dJvA171SGjFQbBEQRF6I7Vc2i2Yj2LSX6D6/U6KaFAwrHGpLBzXAfkVJqkYn
         s+vLdbgHjDvFQLDJPwNzZyDRZ+VmZgL9h3lIuIvSjIG8dhj5IzlaGVTBl6gC9Ng4/NFb
         EU+NeSdI5vNgXG+ROAo9j3S7f46zCf7wvqaXy89Znd9gvHx9jHon3SID7bxUHIW9VO4Q
         3EWNwot3xGx7ZtfsPt0k21+docp6yjhKMqPJXkgQnedbqM+wpO3Xsd7+zSeTNNIDDFoW
         Lc2LjYytTEwiGCcHTyrOJ2PtdHxcuUnesvO2Uk3MnprjrgRX6EJcBXxXZnI2frnwO62R
         bpWw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=0NpGcYltsgE4WItEEmaOTLOQuPIWs0m8pWYJLOZzsqw=;
        b=vl0oKl+oBODHKV2zw/SCzJHDohrOjfkxzufV0uF0EutF0arwHUFDWHj+pExKFQ7Y3x
         LWdO1ZqRE2TczmSlI/ZgbdUec+rUvfLExXcho34MaVazOvbQxaSfmzuCw31utXE4TR5e
         mRdy+AwUTjD23xcKHxEtNfE00KilGxWSPIea/yQFVp6HVQuucPW9wD0sJzdBZ03Sku6n
         srVK/1HNOW3oKqQigWr5/cbY+WogXtKpxL3Sahh5qrrn8i98bCaz1XvjXz2236oICX3h
         lTPZTx0Qyt5pRO/AygYJQfd9YcYCIJ4whE07mS3OybOwQG8dfcjYh9JlUC/njV0tt18Z
         ayuw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.17 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp12.blacknight.com (outbound-smtp12.blacknight.com. [46.22.139.17])
        by mx.google.com with ESMTPS id p18si808906eju.212.2019.03.09.04.49.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Mar 2019 04:49:26 -0800 (PST)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.17 as permitted sender) client-ip=46.22.139.17;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.17 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp12.blacknight.com (Postfix) with ESMTPS id 61E771C2F92
	for <linux-mm@kvack.org>; Sat,  9 Mar 2019 12:49:26 +0000 (GMT)
Received: (qmail 24262 invoked from network); 9 Mar 2019 12:49:26 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[37.228.225.79])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 9 Mar 2019 12:49:26 -0000
Date: Sat, 9 Mar 2019 12:49:24 +0000
From: Mel Gorman <mgorman@techsingularity.net>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Re: [QUESTION] Is MPOL_F_MOF user visible?
Message-ID: <20190309124924.GM9565@techsingularity.net>
References: <3f1f8f38-71fa-7a12-92cd-c3ad552518ff@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <3f1f8f38-71fa-7a12-92cd-c3ad552518ff@linux.alibaba.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 08, 2019 at 10:22:59PM -0800, Yang Shi wrote:
> Hi folks,
> 
> 
> When reading the mempolicy code, I got confused by MPOL_F_MOF flag. It is
> defined in include/uapi/linux/mempolicy.h, so it looks visible to the users.
> But, man page doesn't mention it at all. And, the code in do_set_mempolicy()
> -> mpol_new() doesn't set it. It looks it is just set by two places:
> 
>     - NUMA default policy (preferred_node_policy)
> 
>     - When MPOL_MF_LAZY is passed in. But, it is not configurable from user
> since it is not valid MF
> 

It was never exported to userspace because it was not clear how the
policy would be used sensibly outside the context of the default policy.

> So, actually it can't be set by user with set_mempolicy()/mbind() APIs,
> right? As long as the process' or vmas' policy is changed to non-default one
> (i.e. MPOL_BIND), those processes or vmas are *not* eligible for migrating
> with NUMA balancing anymore?
> 

Correct because if the policy is MPOL_BIND, it's not defined how lazy
migration should behave.

-- 
Mel Gorman
SUSE Labs

