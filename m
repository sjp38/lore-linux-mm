Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 499BEC43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 08:10:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1776A208C3
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 08:10:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1776A208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A2BA28E0005; Mon, 24 Jun 2019 04:10:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9DBA68E0002; Mon, 24 Jun 2019 04:10:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8F0328E0005; Mon, 24 Jun 2019 04:10:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 43E338E0002
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 04:10:22 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id n49so19293632edd.15
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 01:10:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=RZKAfdNkkZhfv4uWe9xB11wjrlRnV2dauStMSJOvwuA=;
        b=H2Bu/2XmF1/gnSDW7TIaXVBxZqZNGHBPtYq4GSi6bOk7TP2eUInawNyFKqPluTC+ZJ
         ari7WwkgrISiJC5CowGTErLSqPkEbZKf9F8xKkPka/Qlnsxt0LWs/flpDJq3zk9qCe/i
         ejwQMKH10XJIgaYErHqLoedcOtFqFugJ+VzeyN1J8aa0m+yA3OyVEZr/Ix2vrRCh7LUJ
         OjLxX8fQoV06TJDGQ16e+4v0K6vuIbX4XUfgQTktU4SmRQrqmviCtdV5Vxar40dWsqNw
         HwA5VKOuk0Z3SmLFbu9KCD1DTB9MKrPsIgiTCw/FdONGd+qTwSHgnx0NMhLlrcSSqryJ
         Dh4w==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUyaDYyhqnM6jNBq5BDwrMrKzjpwknFpxLnJciqZP2DqtKOMfaW
	BabYn6hYXXRWFQLpIwnxjLZEapuH9akG1JdnBnPkm14MMjikpfbG+ev3rtFxLoDLGtHiW/hJC9Q
	vf0FwMQxZmf/XWEXUco4KypwbX5rHrtP/dbt6/Et27mqIugo/JRAc/lUJHi4Cto4=
X-Received: by 2002:a17:906:ca9:: with SMTP id k9mr121338756ejh.4.1561363821840;
        Mon, 24 Jun 2019 01:10:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzG7E83W7Q9stUQxgKC+ZJW/memYPIzPTUW6J+kRBSGo85RFqeVV34yFZAUWR3W5nYhJkWm
X-Received: by 2002:a17:906:ca9:: with SMTP id k9mr121338711ejh.4.1561363821056;
        Mon, 24 Jun 2019 01:10:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561363821; cv=none;
        d=google.com; s=arc-20160816;
        b=IoVCCHsiwk4z9irU1/oKGfLdWtcYaxachwB1eB5xBjt6AB/HPtbxZNSVAeyfSFcqpG
         w0KsQL+ZPNp/w9k2a4diRmzYeWI/d62ajCy+0QcuNyGWVJg84HqUlrmQf5RZ7K2qEYQv
         ufSZUwmYWJ4yrDGeCpQ1T70qVO886F5dl9GTOtWglIMC101+UKZxb2/12vRmZjcofIjO
         FrhEo1yhXvnJcP2uWmNq2pS/3poz98bIMgO9lpEbTXmmQlJm7IyU1WVfpU/CgHYQGHpj
         thp1xO9JKxnMtwEq7G+WxMQKnK5qHB3Q+omxGqV79jj62MXOQ9Avuoi9yQKdjSBXIUNp
         c8rQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=RZKAfdNkkZhfv4uWe9xB11wjrlRnV2dauStMSJOvwuA=;
        b=BaeOawDmBztsY93p+UAxR5nSyoa3yPgRspGAbckdsBvbpwZbBR/p2aTECkmQS6T3jq
         KNHMIfKXuZw/i/ld9jQ9QZKpeJ+g8oOVqR0gU5Vft0imNIwHNgJqurK0QtXOXtQFsMKb
         /DcGgIqYbCHxeKKhDPcV5nU6WXYSKmX2quXjP6633QZJ3IoUfymBaumG7pc1GEtAJsHb
         IvykCUrhxq182weGn/r2mBomMVCLFQCVG6P5mSd/OWJBZ8GbtJhiaDZDMhoHufdYCeuG
         uchHzGU3zlqDF9gepFqfhgdunzTmXHtUf6UOxMpJERlgMxIQcu1s3LltXVAwEHfMAjUr
         WPhQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z9si8682285edz.403.2019.06.24.01.10.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jun 2019 01:10:21 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id D0121AF99;
	Mon, 24 Jun 2019 08:10:12 +0000 (UTC)
Date: Mon, 24 Jun 2019 10:10:11 +0200
From: Michal Hocko <mhocko@kernel.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>,
	Minchan Kim <minchan@kernel.org>, Vlastimil Babka <vbabka@suse.cz>,
	Linux Memory Management List <linux-mm@kvack.org>,
	"Wangkefeng (Kevin)" <wangkefeng.wang@huawei.com>
Subject: Re: Frequent oom introduced in mainline when migrate_highatomic
 replace migrate_reserve
Message-ID: <20190624081011.GA11400@dhcp22.suse.cz>
References: <5D1054EE.20402@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5D1054EE.20402@huawei.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 24-06-19 12:43:26, zhong jiang wrote:
> Recently,  I  hit an frequent oom issue in linux-4.4 stable with less than 4M free memory after
> the machine boots up.

Is this is a regression? Could you share the oom report?

> As the process is created,  kernel stack will use the higher order to allocate continuous memory.
> Due to the fragmentabtion,  we fails to allocate the memory.   And the low memory will result
> in hardly memory compction.  hence,  it will easily to reproduce the oom.

How get your get such a large fragmentation that you cannot allocate
order-1 pages and compaction is not making any progress?

> But if we use migrate_reserve to reserve at least a pageblock at  the boot stage.   we can use
> the reserve memory to allocate continuous memory for process when the system is under
> severerly fragmentation.

Well, any reservation is a finite resource so I am not sure how that can
help universally. But your description is quite vague. Could you be more
specific about that workload? Also do you see the same with the current
upstream kernel as well?
-- 
Michal Hocko
SUSE Labs

