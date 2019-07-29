Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ECD3AC433FF
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 08:35:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B476F206E0
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 08:35:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B476F206E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 67A5D8E0002; Mon, 29 Jul 2019 04:35:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 604128E0006; Mon, 29 Jul 2019 04:35:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4FCA98E0002; Mon, 29 Jul 2019 04:35:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id F3A9B8E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 04:35:17 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id i44so37870333eda.3
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 01:35:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=weFZ024Wz245V9Cv8k3Qru57y17L0kKufx1yaF/wZVg=;
        b=HkRRHArn9WSTdNsOZOd/Z+8Kr3xeBYJN5CURt2CvPF9Yqh6pHuTbxXn7O8v1S7JTRh
         WovylmmaCZAW8e1aASAT+itQtUjnZAXu9fJ7q/rcw+M7bP0FFw1RPI4z9uYo2Rbx/NG/
         EAs1QedmXq3e7oufiqjjyTAufFDM4PZaQhZn5XlbON6sMR6jQ0z2vgb7tKVRXru92OqT
         gsxTzFo/VTCT/sjJrmeTXseYd3nc9LkFZqMSyZNWviMYoY5eQdW7LobMYeHZaFxFM09N
         MtmagDu6J+zi+Y45aSTLT/4jZJoe6tiOnGEJImTamk8ysuHpxMZm9FiPg9ictQLzot9i
         hEIw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUgeUW8xrAQusRQLU+BgQxDIGQgjbx26b95ZybwXqQ197BiANZd
	brpt0y1qco9bWY+F2NjcQ1oUAV9+sfMI8jqSmRKoknYvTkHQMbAqEnHBthL4j0AnUh2DMoqBKDw
	+I9Bb8r1LAe9DtDQiWFY7GuCETFeJVV+HjeiQbc9d1AfAt+nZdGJNzdQaG37OyP4=
X-Received: by 2002:a17:906:28c4:: with SMTP id p4mr84140949ejd.181.1564389317577;
        Mon, 29 Jul 2019 01:35:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyLB0ZiqU1fnx2iSLtghlwPJm93EqlP+ugfduw7qrPqJx6Jq1ye9h12q3sfpLmBJCHxIOFG
X-Received: by 2002:a17:906:28c4:: with SMTP id p4mr84140914ejd.181.1564389316934;
        Mon, 29 Jul 2019 01:35:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564389316; cv=none;
        d=google.com; s=arc-20160816;
        b=J/K/OFqbMiy6nDXQsbyawYc8QsBgwpPNHttKVgvgS41NlAMcA7QhIC7sQRdW6+lLmX
         6qj0NXghNeOT5moNeFFiPisnpRevaGneTUpUDIU533cgNRUAVwh3urOpjBJ2DdNvT8cQ
         Mwbb4Jqcjd2qAqjsqbGo/uW3CnFcagwmULd/yITz9eRzPs6xCewiRBVgxM4zf9dldt23
         20U1TijA/unIw9NYVFXDjYLqezvFJLL16KJ7v7UKrEPP3j6YpqpJLv8KKNIgefhaCU6b
         s8iWZSDThEQJUiYyBOuOs2+Ik2TbCrb69Ea5De10ZPWTR0zOT3KXEAdZ5lEGV4Gwsaa4
         spvA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=weFZ024Wz245V9Cv8k3Qru57y17L0kKufx1yaF/wZVg=;
        b=Czxq4WZ6o2BmITvx0k5mtdwfmnBOBvyI0AqOxHh5l1KIXw0ijO2dPSNXjSkfcV1eo9
         qAg7MaqIIknZvOr1rpGH84xIhH48QbQduRdriYIJCGI0VfqDGjpKMF0YLhsmKMIkfdTA
         yRcAMb8yN5xILur0/9KaQlRXYD58qdaU2/9L+35mE2lSmZOVL2/77R/e7duxxvypa71m
         Va6Zcb+5idDCCyj6sS1hforl4pvp9Fwzj6zQ6mYwy51SfEMo+dkKTxx1bVCLjvi/fcxu
         jF+FRfulQuym7OIeMJ4ziQUyCGB5uGJtBManZhESk0cRcSuV95Ta/kpKw417wXDdGcG/
         Pw/A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q55si16866740eda.257.2019.07.29.01.35.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jul 2019 01:35:16 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 739D4B023;
	Mon, 29 Jul 2019 08:35:16 +0000 (UTC)
Date: Mon, 29 Jul 2019 10:35:15 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Miguel de Dios <migueldedios@google.com>, Wei Wang <wvw@google.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm: release the spinlock on zap_pte_range
Message-ID: <20190729083515.GD9330@dhcp22.suse.cz>
References: <20190729071037.241581-1-minchan@kernel.org>
 <20190729074523.GC9330@dhcp22.suse.cz>
 <20190729082052.GA258885@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190729082052.GA258885@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 29-07-19 17:20:52, Minchan Kim wrote:
> On Mon, Jul 29, 2019 at 09:45:23AM +0200, Michal Hocko wrote:
> > On Mon 29-07-19 16:10:37, Minchan Kim wrote:
> > > In our testing(carmera recording), Miguel and Wei found unmap_page_range
> > > takes above 6ms with preemption disabled easily. When I see that, the
> > > reason is it holds page table spinlock during entire 512 page operation
> > > in a PMD. 6.2ms is never trivial for user experince if RT task couldn't
> > > run in the time because it could make frame drop or glitch audio problem.
> > 
> > Where is the time spent during the tear down? 512 pages doesn't sound
> > like a lot to tear down. Is it the TLB flushing?
> 
> Miguel confirmed there is no such big latency without mark_page_accessed
> in zap_pte_range so I guess it's the contention of LRU lock as well as
> heavy activate_page overhead which is not trivial, either.

Please give us more details ideally with some numbers.
-- 
Michal Hocko
SUSE Labs

