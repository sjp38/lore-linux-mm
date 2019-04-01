Return-Path: <SRS0=sWz3=SD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 99735C10F05
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 11:53:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4554D2082C
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 11:53:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4554D2082C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 835E06B000A; Mon,  1 Apr 2019 07:53:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7BDDA6B000C; Mon,  1 Apr 2019 07:53:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 687596B000D; Mon,  1 Apr 2019 07:53:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 14BD66B000A
	for <linux-mm@kvack.org>; Mon,  1 Apr 2019 07:53:10 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id s27so4229501eda.16
        for <linux-mm@kvack.org>; Mon, 01 Apr 2019 04:53:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=jOmZTUo7++HdeYgJ1YgLKZzRlvlJbZ3RA09Hu3oO6iI=;
        b=tlWUpbTCWlVRBUe5drxa7Aj+bv9a5iT1c1a6h2K+FaY79pdrhyOqyRY1purH9rXcAH
         NbovLh38KwTxy5UZb44EfSTG5f7QM9dbWZEOIWn5wluuhbzVYV3sbfOpJZu5sEqIfWyZ
         d+L3oAGJxbJ9UfqC2OKzva44/O0K8rZVCWlKQBKhqhXYBvdPOQI5200nDP03l4P/87Wt
         4b1eWWDknnP/R1toBSwFrUWrou9aNrfgFLK+fpaJ3FCm/mK8E8GdOjL5qUKBjpRNs/Nu
         3sPZq2pHETKxe5kvPAxFqEs0BGDxRMwwSbmILEz+k3OAxY4bmZh6158N/jgGEY5KBSAz
         hbTA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWQqwEsy2edGV0sUviAUMEGvhH8HiZb1ZCn1ZW7GD05ri7Hp/6K
	fdpSQlbvkGmnE/8yJ87p/Bk5K8UFnW1ZY4RxK7qzyRLBgacoZuYTUz0QWqewYHm4qL27nZ3oEcm
	pGIYsDZL+lfiLljNxmnDgcn6xSh6oVXGYLLija3+3MXUn1GXeGVfEm47ZdsDsEbc=
X-Received: by 2002:a17:906:3941:: with SMTP id g1mr21172035eje.168.1554119589594;
        Mon, 01 Apr 2019 04:53:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzCpSHVWrU4tdpqQKTrPLUd8eahCzJ40ZIqCpuL6ocRSZK6cT7lfGqajrmTvdAkc9hBSjG1
X-Received: by 2002:a17:906:3941:: with SMTP id g1mr21171992eje.168.1554119588608;
        Mon, 01 Apr 2019 04:53:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554119588; cv=none;
        d=google.com; s=arc-20160816;
        b=DXKwv2sdX5/jgFkkeH+1lbrkiu/1UkbhJw64BtOSMc+1Oy5u33AJ22MU8IsaNejh1K
         0ILESyPtHq6DNEfMYzBLuUgMxdRnSXPrt9djL58+x7l/bTz/wrC4wJXwHeMh+Swew8s5
         VGVGPKpGJyG+F8CNZDTit5hMklUn1m9+im/ZjSqAlNmudSIttFTr5Oxs1SF3Pg9djZaN
         yv3YNX2q1iN3AkRlNCAj59Ge4jBvmG9Mo1cRXLEtuKF4/tnI8yIMKSgLNEwUEP110hrs
         xbRPR4twDT13eVP9v14T5sjOxQ1As253OszYxif5M5+oiFQk/h1SVs3f+fNZdtD1n+PV
         +0tA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=jOmZTUo7++HdeYgJ1YgLKZzRlvlJbZ3RA09Hu3oO6iI=;
        b=siEM2E6KeTHRJ3dGKsxaGheqkLr4JMhmqFq/E54VcEB5B35NJ8DpR7YfhqLBk5dT5J
         KrcaMxdMtXlY/I4mocivocELuZL/qRO9M2fi9fj7W+GWkmkCg1+VL5MTvEeF/KhjmClh
         eKvYAoo9RN9nC7v9+zyFKJy1MI71+j3EbqV6KDpfpiCaB0l+n5vQUIegxWjknhAWHuVv
         mIpJFC6k2Y6pbOSr1Z41UNtVwy1AMULa04LdeHPFqzyc/my6lmn8TYeHTCP0lbH+asNF
         k3kzLxMz0I+mRR220LXH6phDb5BG7EoJMMBBY17bhk3SFTnr4Pdnk1SfoMPf9NATEYdy
         7GLg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v7si1073783ede.424.2019.04.01.04.53.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Apr 2019 04:53:08 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id D24CDAEC8;
	Mon,  1 Apr 2019 11:53:07 +0000 (UTC)
Date: Mon, 1 Apr 2019 13:53:06 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Oscar Salvador <osalvador@suse.de>
Cc: David Hildenbrand <david@redhat.com>, akpm@linux-foundation.org,
	dan.j.williams@intel.com, Jonathan.Cameron@huawei.com,
	anshuman.khandual@arm.com, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH 0/4] mm,memory_hotplug: allocate memmap from hotadded
 memory
Message-ID: <20190401115306.GF28293@dhcp22.suse.cz>
References: <20190328134320.13232-1-osalvador@suse.de>
 <cc68ec6d-3ad2-a998-73dc-cb90f3563899@redhat.com>
 <efb08377-ca5d-4110-d7ae-04a0d61ac294@redhat.com>
 <20190329084547.5k37xjwvkgffwajo@d104.suse.de>
 <20190329134243.GA30026@dhcp22.suse.cz>
 <20190401075936.bjt2qsrhw77rib77@d104.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190401075936.bjt2qsrhw77rib77@d104.suse.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 01-04-19 09:59:36, Oscar Salvador wrote:
> On Fri, Mar 29, 2019 at 02:42:43PM +0100, Michal Hocko wrote:
> > Having a larger contiguous area is definitely nice to have but you also
> > have to consider the other side of the thing. If we have a movable
> > memblock with unmovable memory then we are breaking the movable
> > property. So there should be some flexibility for caller to tell whether
> > to allocate on per device or per memblock. Or we need something to move
> > memmaps during the hotremove.
> 
> By movable memblock you mean a memblock whose pages can be migrated over when
> this memblock is offlined, right?

I am mostly thinking about movable_node kernel parameter which makes
newly hotpluged memory go into ZONE_MOVABLE and people do use that to
make sure such a memory can be later hotremoved.

-- 
Michal Hocko
SUSE Labs

