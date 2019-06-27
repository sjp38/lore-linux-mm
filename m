Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 08274C5B576
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 20:59:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CF3CF20B7C
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 20:59:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CF3CF20B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 689F86B0003; Thu, 27 Jun 2019 16:59:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 63A1D8E0003; Thu, 27 Jun 2019 16:59:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 54FD68E0002; Thu, 27 Jun 2019 16:59:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 341336B0003
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 16:59:33 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id c207so3887068qkb.11
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 13:59:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:organization:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=j09t1oNe1xrcwM9PCr/Xf9jFeI/a2JEDFhFgPvgAEcg=;
        b=sbVPIDaXd9YK6OO+weIIAJCIuhz9qwWve7XhPBXwSkAeVHLqx9khRbrigi64cHc1Pg
         J42n8RKg+1DZ1hT6pwZ7YCh7IO9dsyMswiEjuX4MdD3zseWd12NoQHhlpY3e6YZdeQRD
         0SPr6kTeRiPaBOru/kGmdRrF1W9tFw+5VC/EOHUkdSNiz94VPZnP+Q5N0wSI7KUUZ+ED
         c8zjjCEzAsMXBAK3rsGS+mHFqEOSzjYAsXSe49M7+Y/0Itt+BIUILX9WacYrjvpYnSu5
         va6RVejUU1C+l7OACfthIOVJH9ZVHAnYMYlytSze02ClaSF2EmK9xPH9I0zF8ff1itIu
         dTHA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAX+HfiKV5EKX97y+iJ+gcJYneARJKp0APVsOKE6BQW/zS/XIIXK
	QhiS2I/KNh5+bZYw9TeeFOzUFPYWZMdJBvcCon0MIe/9K4F4Ok2eCnd8vfImO7x7sFlYPqGDCH3
	oP5IAFua1zGdUPGM3NIoyh0Xh+rHgOwjsKsTCaeWsPOv7R5ryDiEjtHib2D89FbtQ3w==
X-Received: by 2002:a0c:88a6:: with SMTP id 35mr4414079qvn.63.1561669172975;
        Thu, 27 Jun 2019 13:59:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzkZGSK6Fx5IO9I+z3zOu0lhCCpvpUWexnEw7Sq4FvFn93ACz+iuFuJbuSU2MawQpz0SAHG
X-Received: by 2002:a0c:88a6:: with SMTP id 35mr4414042qvn.63.1561669172410;
        Thu, 27 Jun 2019 13:59:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561669172; cv=none;
        d=google.com; s=arc-20160816;
        b=z8rmF0oNM3Exc/cpbS7Qh2rtHh0j1E8fnpEh2PMZCFexkS/sT1wr6EonvBBBbr06+3
         9CVh2DZV5n2A1Uh/m06XSXe6Gfx66M4KSBr2EZg7VNwtfMiA+GxWPYCsCLF2+MTKVEmm
         L475Y2ndKLyCi8yGMVhZzEQF7foZdECEemRrfXvQk5UPdSZiWt/kB6NqFF98CJF/z1QS
         oHwttE2iNouJ2svKjUhqk0Jt4LDovy86XygTJfrwPEcGck6BM1fBITZ0HpZZLfcD1hHf
         LaXejQ6JMygF/+rVr96AJRf6M96KRefcXmjbJJ0cGrFOgITsxKJfqJjPCNE8yNYjcw+r
         MGAA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject;
        bh=j09t1oNe1xrcwM9PCr/Xf9jFeI/a2JEDFhFgPvgAEcg=;
        b=yOQPquIzTjUZHtJHjiEGDlMJIE/HcLHZVb3cgyn9uMPivsGIJSOqGdU2wbqbM2Ef4h
         XbHJZoj63dC/0nyFo3FKmYZhc0BI5NOTV2nr/eUwT0j58zc4NpuZ4NPBjIypcI7YMBpb
         D2h6fKu7WsketvvBB88XN3RJlRdf+BgZhCwckjCquKq7sFcIExp4M4Uwx4ibR2YeeSWK
         VPMeWve/xibm2VISS0Y2UqDqn8l+kI4MTX6QrKmeTxmcTcGLrzY+THWm/zgUmJfa1ZGR
         EFkb178Wc9DWYtxIl8+IdOUxxH6hpRngYKf9vCp47pC5JvMPGGLbrk7bc5ySQfswCwG7
         gBGQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n2si209526qkd.208.2019.06.27.13.59.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jun 2019 13:59:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A2BD930BB37D;
	Thu, 27 Jun 2019 20:59:26 +0000 (UTC)
Received: from llong.remote.csb (dhcp-17-85.bos.redhat.com [10.18.17.85])
	by smtp.corp.redhat.com (Postfix) with ESMTP id C3273544ED;
	Thu, 27 Jun 2019 20:59:24 +0000 (UTC)
Subject: Re: [PATCH] memcg: Add kmem.slabinfo to v2 for debugging purpose
To: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>,
 Vladimir Davydov <vdavydov.dev@gmail.com>, linux-kernel@vger.kernel.org,
 cgroups@vger.kernel.org, linux-mm@kvack.org,
 Andrew Morton <akpm@linux-foundation.org>, Shakeel Butt <shakeelb@google.com>
References: <20190626165614.18586-1-longman@redhat.com>
 <20190627142024.GW657710@devbig004.ftw2.facebook.com>
From: Waiman Long <longman@redhat.com>
Organization: Red Hat
Message-ID: <afc95bfa-d913-b834-c4b7-39839e7a902d@redhat.com>
Date: Thu, 27 Jun 2019 16:59:24 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190627142024.GW657710@devbig004.ftw2.facebook.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Thu, 27 Jun 2019 20:59:31 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/27/19 10:20 AM, Tejun Heo wrote:
> Hello, Waiman.
>
> On Wed, Jun 26, 2019 at 12:56:14PM -0400, Waiman Long wrote:
>> With memory cgroup v1, there is a kmem.slabinfo file that can be
>> used to view what slabs are allocated to the memory cgroup. There
>> is currently no such equivalent in memory cgroup v2. This file can
>> be useful for debugging purpose.
>>
>> This patch adds an equivalent kmem.slabinfo to v2 with the caveat that
>> this file will only show up as ".__DEBUG__.memory.kmem.slabinfo" when the
>> "cgroup_debug" parameter is specified in the kernel boot command line.
>> This is to avoid cluttering the cgroup v2 interface with files that
>> are seldom used by end users.
> Can you please take a look at drgn?
>
>   https://github.com/osandov/drgn
>
> Baking in debug interface files always is limited and nasty and drgn
> can get you way more flexible debugging / monitoring tool w/o having
> to bake in anything into the kernel.  For an example, please take a
> look at
>
>   https://lore.kernel.org/bpf/20190614015620.1587672-10-tj@kernel.org/
>
> Thanks.
>
Thanks for the information. Will take a serious look at that.

Cheers,
Longman

