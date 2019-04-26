Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9EC0DC4321A
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 05:48:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4B56E206BA
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 05:48:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4B56E206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9DBB36B026D; Fri, 26 Apr 2019 01:48:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 98A7A6B026E; Fri, 26 Apr 2019 01:48:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 87B1F6B026F; Fri, 26 Apr 2019 01:48:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3A18A6B026D
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 01:48:06 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id o3so940954edr.6
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 22:48:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=I+rfU/9FO2xyRwSEjUrDDCSFV49nsTTpaH3YoH9ujj8=;
        b=k4Sb473JNeICfXJauqSk8+OHrD7xFKou0JU7mPQjCtAFwKiLwF8ZVh6dCzVHowYC2I
         MkoFny/0UDdqeYj4ls/h4dBj1bj4p0McUwAZw75Hmg5kwJNQsVp0h5RwA0QeGZS4A0fR
         XHkBwoW5LrfDVM/gXVBg+CCdoCSOq7naVDiZxtq/l2LU65sjP3Iw8J4yK9RwUJ86utye
         /RgD9MB7wvOvcR8tXzITwCe7xo+qZguUsrgv96Lc6L4+t8xImRatdktG+uFCWdmByG3k
         EYShG7VJ/+/L8e4hDQN2t0WeZaZSlvzI0P5UGYBgP9+ywf0MgycPqlaOE2LiC3grOTa+
         ByfA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXpeCmd44NBMC80Px9THGObFybAXDVC4NI57Whz2v5m7FrszfPf
	cGWmCdbCIZm56+WjYfcnJ9VZS/5wr9BnAFoNHUmG92/ZaY1P6VFNZ0buiQPGxYDHY2BhRXO2uIe
	Dvoxd4VX/gfOphIBaJ+B2Gs+hkXM5uv59p9Q3DAT8iEbLRGaRAkft7o7ffhp1Cow=
X-Received: by 2002:a50:b69c:: with SMTP id d28mr26822566ede.126.1556257685735;
        Thu, 25 Apr 2019 22:48:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxqUKulDR6mDpbIdwIKV0MvDv7tzrL4gJaoE0ucDiBSr+4t1EmLlSswEjTZB0+ExVDGT9Wl
X-Received: by 2002:a50:b69c:: with SMTP id d28mr26822530ede.126.1556257685083;
        Thu, 25 Apr 2019 22:48:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556257685; cv=none;
        d=google.com; s=arc-20160816;
        b=LwG6XAGRsH5vJCYElvD1lpnDhzMRlWoS5vd9M56gwxxIe0/Bpc1aqzSEaVSg6iNKfE
         xQPTcQhtnV0NR25x+6PPptiaezXUCZoCHryQ6HGtMXe7do+96LSWttVsbLsvyj1VDXmG
         PEbQbhFp/SI7BlvTMIXoYCjAcvBIjgdNk4ayQEHcDC6eFNR6dwdhXSMC3hoDeMIGbngI
         aoLLq5hwtse7whlLtxDAl9kd0jQzwO9ozdxqHdjx2A9m4J+Ed8M+urmplbD5n/9LqXkb
         7zyaWmgxbnKJUdnZFQrZuZvZDx8JV4SVSI5HL1LNcxX+3Lgc/ZxuKArdrYj2QOTbp/xB
         wdwA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=I+rfU/9FO2xyRwSEjUrDDCSFV49nsTTpaH3YoH9ujj8=;
        b=NWUuUwqaB2wPMq/IqZePcGgRgzsq+JCrU8D6S7KBgcACsBsnJiPcBKHOHjofjGjL0Q
         T1hS2Bu/ROxw0lwZ8T9XtKmMNqYi8v5ON51qDpnuYSL20nv/gtmt7BeTIlooiWKN0oN1
         hZHR95IftsNBvK1JWbQq/iwb+ffyWYI5da2SYp09mPabmqjDcB6BCfaoJMtI3Mr9n6q7
         lUCQhrgAaRATgeOCS0iOMAb5n4JkFhzYTgGAB02QIfKJNCr5FNAlNF9A/4sbeLHPTSQU
         C2o1zdbFuEGSJIVfDc6AcHZ9C5jXVdTZ7HmTtAFNBc+ACb52HDug3IFsEazS5Z2UE5dD
         n8Rw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s17si4166008eda.250.2019.04.25.22.48.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 22:48:05 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id F2779AD8C;
	Fri, 26 Apr 2019 05:48:03 +0000 (UTC)
Date: Fri, 26 Apr 2019 07:47:58 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christopher Lameter <cl@linux.com>, mm-commits@vger.kernel.org,
	yong.wu@mediatek.com, yingjoe.chen@mediatek.com, yehs1@lenovo.com,
	willy@infradead.org, will.deacon@arm.com, vbabka@suse.cz,
	tfiga@google.com, stable@vger.kernel.org, rppt@linux.vnet.ibm.com,
	robin.murphy@arm.com, rientjes@google.com, penberg@kernel.org,
	mgorman@techsingularity.net, matthias.bgg@gmail.com,
	joro@8bytes.org, iamjoonsoo.kim@lge.com, hsinyi@chromium.org,
	hch@infradead.org, Alexander.Levin@microsoft.com,
	drinkcat@chromium.org, linux-mm@kvack.org
Subject: Re: + mm-add-sys-kernel-slab-cache-cache_dma32.patch added to -mm
 tree
Message-ID: <20190426054758.GE12337@dhcp22.suse.cz>
References: <20190319183751.rWqkf%akpm@linux-foundation.org>
 <20190319191721.GC30433@dhcp22.suse.cz>
 <01000169988825c0-df946577-83d4-4fc5-a329-52b65bec9735-000000@email.amazonses.com>
 <20190320070516.GD30433@dhcp22.suse.cz>
 <20190425214615.b46db647b6a6a82db92e4143@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190425214615.b46db647b6a6a82db92e4143@linux-foundation.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 25-04-19 21:46:15, Andrew Morton wrote:
> This patch is presently in limbo.   Should we just drop it?

There was no strong justification for it except "we alredy do export dma
cache so why not dma32". Christopher was arguing that slabinfo (in tree
tool) is going to use it but that merely prints it without any
additional considerations. So I would just drop it until there is a real
use case (aka somebody is going to use it for something _useful_).
-- 
Michal Hocko
SUSE Labs

