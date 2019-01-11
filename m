Return-Path: <SRS0=ysF+=PT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D17D7C43387
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 07:37:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 96A302084C
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 07:37:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 96A302084C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2B21F8E0003; Fri, 11 Jan 2019 02:37:02 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 23AA18E0001; Fri, 11 Jan 2019 02:37:02 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 08C7D8E0003; Fri, 11 Jan 2019 02:37:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id B50B88E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 02:37:01 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id s71so9664095pfi.22
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 23:37:01 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=/t29zHqKzgbLFTMhI4YxQD0+zVsqn9bKT0quiYOeSnQ=;
        b=cJUm6CYGKC8HT9aHBS0+yZ4dB8bpQmlblVgPY3+TyordUq10sj2vtY4KtL40bJC8ki
         PrLqoXDsB4enBhvN9jVc0VfYi95GqH/o8tSx2sfziAMJfNpypWZcT9908dTgreOOTsyI
         1tby/JozVQXBRH5UAA8V+8J7kg6olFM/SOq1bo/rfSApMgwTaFBkeutlf0AW3+bTT/tT
         kqj+Gk7WYbMzcsiR5h/+dT6XVLFaEyPIc6otS2Xn58WdehSeRmxty4jy6ogFgWv0+AvK
         Chw6ni8QK3nPgeSQlKkb7GVeXmQgcxoqzAOXHkQcBlYHlMMQTaGJZ6H0idnG6zbOxX7W
         pfbg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=jikos@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukeWNV5WToYN4G1G672AuQ6gtItn1/6dBApa1mp6w8BIAEr7C5ip
	mwMn96endrzIC8GdJkycUHrXxwv9LYteT9ZGaqelgA/JhKPoPHi/HkHY8Cy8Ev5OfupVTFE1qOM
	FE4FfSWMPJslT7fjSyahk4B9qA1dlERfzmUr6Y+K8MpxHpFw6dvaFH5q7oOQhccY=
X-Received: by 2002:a63:91c1:: with SMTP id l184mr12461808pge.29.1547192221371;
        Thu, 10 Jan 2019 23:37:01 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6tCO36erx9DFngIqTYtVuGojoVKj0X7QzmDWpcMNIIXsUIwQ70ijQ7m1TR7cneM3VBhtXM
X-Received: by 2002:a63:91c1:: with SMTP id l184mr12461779pge.29.1547192220740;
        Thu, 10 Jan 2019 23:37:00 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547192220; cv=none;
        d=google.com; s=arc-20160816;
        b=JBabPWrBUQ+oil9C6eyzrcQ8sTQqP9QeM3LBdpFfByRphQS0v52qiVgpl5EgeCYWmZ
         iewwaklrH3N/0L781OMk8VdcMGT+gcIxnZXVFir6K6XeRmzNlzMwtvbXmHWRVz1Psh+k
         aZATfCPeS37OPHc+lXLpNMiYFjJkCa/5cfewQyulHOu5uQZJnRXDaoI4m4QRupWpxv8N
         ZcpzsUltSWY4az+l9D+GGdzJ+IzZDUEh8pYpYmyoxFFz09D917c9xijCisg+crYfwX4D
         KWtzI+TsUjvNvIWnifjN5mWr+fCwqRqF9Hk2eAe8fLOOuZ9YCLzvsTqwUF+oj6zstc96
         07lA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=/t29zHqKzgbLFTMhI4YxQD0+zVsqn9bKT0quiYOeSnQ=;
        b=1FMT/AMJ7vV9diNYcsU+h8PJhAKLfgPyIKlA9K4TXQXBUuBqt6QtzfS4pLkVi5tECc
         aTqFIYx4Fbp4b/GMq+U/xOQdF8lyBaybXe0CfINQLyC9Jsttc/VkREHEEstr6Nzbs9jL
         IKWbwcsn8+28yBFx5wHNZziXVoDjaUUHaIbeiJBuMiYXmb9MJj5M7gcfBTj/Rw9jOPRS
         jCFgn+sJ//Hd2n85OMUuhqdBXnvL+Y4yAVjSUeVJeGS9BbGT+og8/sKDCLW3lFUuaq2d
         FOEtwip0Vx8ckj6+utMbw0zDEMUXzvKRHHbxG7rfLqcm3STZEBlPKFbTI1sbNHuXIzFC
         Vhxw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=jikos@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m64si10114993pfb.224.2019.01.10.23.37.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 23:37:00 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=jikos@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 51535B07C;
	Fri, 11 Jan 2019 07:36:57 +0000 (UTC)
Date: Fri, 11 Jan 2019 08:36:55 +0100 (CET)
From: Jiri Kosina <jikos@kernel.org>
To: Dave Chinner <david@fromorbit.com>
cc: Linus Torvalds <torvalds@linux-foundation.org>, 
    Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Greg KH <gregkh@linuxfoundation.org>, 
    Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, 
    Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, 
    Linux API <linux-api@vger.kernel.org>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
In-Reply-To: <20190110004424.GH27534@dastard>
Message-ID: <nycvar.YFH.7.76.1901110836110.6626@cbobk.fhfr.pm>
References: <20190106001138.GW6310@bombadil.infradead.org> <CAHk-=wiT=ov+6zYcnw_64ihYf74Amzqs67iVGtJMQq65PxiVYw@mail.gmail.com> <CAHk-=wg1A44Roa8C4dmfdXLRLmNysEW36=3R7f+tzZzbcJ2d2g@mail.gmail.com> <CAHk-=wiqbKEC5jUXr3ax+oUuiRrp=QMv_ZnUfO-SPv=UNJ-OTw@mail.gmail.com>
 <20190108044336.GB27534@dastard> <CAHk-=wjvzEFQcTGJFh9cyV_MPQftNrjOLon8YMMxaX0G1TLqkg@mail.gmail.com> <20190109022430.GE27534@dastard> <nycvar.YFH.7.76.1901090326460.16954@cbobk.fhfr.pm> <20190109043906.GF27534@dastard> <CAHk-=wic28fSkwmPbBHZcJ3BGbiftprNy861M53k+=OAB9n0=w@mail.gmail.com>
 <20190110004424.GH27534@dastard>
User-Agent: Alpine 2.21 (LSU 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190111073655._zmCceKJGVIstWH_7BxLrDlNaVE-yeX23MMjs84SDsU@z>

On Thu, 10 Jan 2019, Dave Chinner wrote:

> Sounds nice from a theoretical POV, but reality has taught us very 
> different lessons.
> 
> FWIW, a quick check of XFS's history so you understand how long this 
> behaviour has been around. It was introduced in the linux port in 2001 
> as direct IO support was being added:
> 
> commit e837eac23662afae603aaaef7c94bc839c1b8f67
> Author: Steve Lord <lord@sgi.com>
> Date:   Mon Mar 5 16:47:52 2001 +0000
> 
>     Add bounds checking for direct I/O, do the cache invalidation for
>     data coherency on direct I/O.

Out of curiosity, which repository is this from please? Even google 
doesn't seem to know about this SHA.

Thanks,

-- 
Jiri Kosina
SUSE Labs

