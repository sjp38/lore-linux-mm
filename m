Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E9845C10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 18:49:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 97F3B20663
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 18:49:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 97F3B20663
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 081DF6B000A; Thu, 11 Apr 2019 14:49:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 00B316B0269; Thu, 11 Apr 2019 14:49:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E3C5C6B026B; Thu, 11 Apr 2019 14:49:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id A89C06B000A
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 14:49:24 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id r6so3502100edp.18
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 11:49:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=hHSskMoFD/XTerIrAossYBBWCQkAGnlN+dOY3SDaBVY=;
        b=FwOp5Fx9WtoKirF0FWwVZSDmEkLxNLLAju1J7t2WiWJaAzLQI6z7IBsk1CKpHXjW3V
         3+Qbw5j1gbfjt98aQTKisXo0c2iUILLF/h9osQ8n6JHq0IdodzVDeP3uFkmakAASVHHw
         gjgw+46QXl4J0wqrgmRhq7cVuR29OixsHb1LVBTzWLeWFuYldbEKj32qVYwwbi3vxO2c
         QNW3lJiV0yFWtnEhMfc2TRysF8ddhZJA2uf/PHglXnyZQsNWQf0rDeXCEMgBBDw4ksNm
         nV8FokANu6xyAn8xztroFLlECg9SLupc2ditQrUcJsU1jkvKk0RNlqP9JePuBEZauhlz
         Of3A==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAU0hGwK0k5nZVSkfDL1MrNHSfSuKhqMSk+azR2SBozvCue26zIs
	Wo7Zi1bI8RCnpgR95TggsfiEHxFaPA+LvM49Ify5iL0n/gxjoA/GaPNRaNznq5LqpqhfaLBYU8g
	CUT1XJwLLpiRvXywIwZJ0wIYGST7sVIpXU4daz15b8WRWHmK3eOnqSQ/gJTAGn60=
X-Received: by 2002:a17:906:4b10:: with SMTP id y16mr29257953eju.19.1555008564265;
        Thu, 11 Apr 2019 11:49:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxeZt74dbZVlCJ+lLfMnI7On3hOmN3ObU32xKoh4Ue4lHsMgbQ+fvgD0tgr7oDDdcYEeX9a
X-Received: by 2002:a17:906:4b10:: with SMTP id y16mr29257922eju.19.1555008563480;
        Thu, 11 Apr 2019 11:49:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555008563; cv=none;
        d=google.com; s=arc-20160816;
        b=IS/hI/22EU3/SjU2y1P/b+DLCrXGr1SbtRjhUnRLgQSsy6FOt65YfjSFmC5d6g9hVP
         n4G4JdkMn5JNagaaPixMnQt/efJQ0cJUIjRoZkjj319bTe4Y9t+GbJU1vnXkfKGwNW/J
         JTr6uxf9YaTsXSS6IWhJ5Jeoz3aLcGYBYXZ1wYpHr2N2Ze1tgd+JDJssu9zRSSBth3UQ
         B3XYMDLtHtfXFp0QMq9w9rVJKQZPlQQbp8KGnbqkuSycvNYDYhjX8U3yP+H96d46zLUa
         IK8l/GGBo8IO55iBd3Y4vT2N0EqR+W+K2xOPkS0ZwKwAfVhXgJug6h2bUwvyfaUacnY+
         32SQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=hHSskMoFD/XTerIrAossYBBWCQkAGnlN+dOY3SDaBVY=;
        b=gDLPecTr7Bgutx5kYGZrljHN+KThaNbJh+0+lUTeb4vyyRfEHHOxJls2gp03o3XlIJ
         WhIqqKgT00iuk3mL8+hhl/CBlXCqVdv/fsrhaLp0tY1W6j4tvSNFonBgddIf8+pMkuiZ
         3IAL3qmxhnEhcHm5qSckJl6NM233iUbDeToox60MMWqmNEzibLDtIgqx2Ao1k5j0mXVM
         LhfD1+d3Ux7y/vBzgvMARu40jnAQd8dA0QF3BoRohECqTW3QNPBxCX2zwlOAe8rWLe+V
         DBBW7XJzJwpeEjyzS+eBBC4QsukyW93JIDGfE/ZCQfSyAUavl0nGmcusTG+PzsCwfz79
         4wAA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q1si27692ejr.44.2019.04.11.11.49.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 11:49:23 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id ED84FADE5;
	Thu, 11 Apr 2019 18:49:22 +0000 (UTC)
Date: Thu, 11 Apr 2019 20:49:20 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Yufen Yu <yuyufen@huawei.com>, linux-mm@kvack.org,
	kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com
Subject: Re: [PATCH v2] hugetlbfs: fix protential null pointer dereference
Message-ID: <20190411184920.GF10383@dhcp22.suse.cz>
References: <20190411035318.32976-1-yuyufen@huawei.com>
 <20190411081900.GP10383@dhcp22.suse.cz>
 <b3287006-2d80-8ead-ea63-2047fc5ef602@oracle.com>
 <20190411182220.GD10383@dhcp22.suse.cz>
 <ce422d2b-dd9d-e878-750d-499b9a21c847@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ce422d2b-dd9d-e878-750d-499b9a21c847@oracle.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 11-04-19 11:40:02, Mike Kravetz wrote:
> On 4/11/19 11:22 AM, Michal Hocko wrote:
> > On Thu 11-04-19 09:52:45, Mike Kravetz wrote:
> >> Or, do you think that is too much?
> >> Ideally, that comment should have been added as part of 58b6e5e8f1ad
> >> ("hugetlbfs: fix memory leak for resv_map") as it could cause one to wonder
> >> if resv_map could be NULL.
> > 
> > I would much rather explain a comment explaining _when_ inode_resv_map
> > might return NULL than add checks just to be sure.
> 
> You are right.  That would make more sense.  It has been a while since I
> looked into that code and unfortunately I did not save notes.  I'll do some
> research to come up with an appropriate explanation/comment.

Thanks a lot! This is highly appreciated.
-- 
Michal Hocko
SUSE Labs

