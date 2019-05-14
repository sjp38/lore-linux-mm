Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AC95DC04AB7
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 06:20:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 77168208CA
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 06:20:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 77168208CA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 058A86B0007; Tue, 14 May 2019 02:20:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F23986B0008; Tue, 14 May 2019 02:20:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DEB5B6B000A; Tue, 14 May 2019 02:20:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8D5816B0007
	for <linux-mm@kvack.org>; Tue, 14 May 2019 02:20:42 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id l3so7359855edl.10
        for <linux-mm@kvack.org>; Mon, 13 May 2019 23:20:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=/EMQzAezXnn0oYijD9ANQWZeVbNXHm+aZD+2Ibjc4yM=;
        b=KgoAryjQ1uX97Npp1yoFKxkcEKSscBq8hJDiaiXBhRBHFr4R9D3tw6joLFuZBQwa/X
         B3zU+UzkkJUi07ifETJswep3xMUbUHOhIOMETsHvTTdbEnsqKS5u9BrvB6qNdzLv2fOf
         71fDnLiei2aYNhqmR18KzCdwFUDYg5vnR3RSpKV8eAA2hGcVFGuzAkG7SBC4A3tmYCCC
         C1BEBEPNjfdhdIyRNdrqsPBud/PBYSD8K9Yfu26GGmuaucnG4/QGVy1B6zqoj/PPkymW
         uvZPii1soxBS55/7y8xHRMzlBCPX/9gYgBXyPzZJRq2vJnFrcTBEJqfgeZcOzNBPu5S/
         58/Q==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVbmkVzxIZ1RvcCXojXvbHhGGrV3pgZx0ak74TAgneX3Hyujyx6
	JZWG2kHztnNpCcW6bAbbrDJVD/rsLzKEPiqtPI6FzzyytANCdr0vc/Qk1cPsTFBMbO9f6QphhWp
	HkUAXIlVQLi221BdMtDkdewPnM9zk1r7x9cytNRAjzwQxPPlieWtLpKXWcOgw8lY=
X-Received: by 2002:aa7:db05:: with SMTP id t5mr33091032eds.217.1557814842167;
        Mon, 13 May 2019 23:20:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyvAEgaTwClx2T1M6h3xAMKnGcSLsZWlVIwtAjEJ2w/H9i7H1a+bc4S733q5U7TE28musZP
X-Received: by 2002:aa7:db05:: with SMTP id t5mr33090969eds.217.1557814841307;
        Mon, 13 May 2019 23:20:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557814841; cv=none;
        d=google.com; s=arc-20160816;
        b=W8K556exMRviFuagvJlpYsUyckXvqDxw+9Yo/XqGS93ndnCuUhF95l+YuXQlyzMjSY
         SrHUcSMJllQEZxX4zSihB513KQv7Kw04Pd5HJ8T/AzsSG4eQ58mfnVvZhs6SVRkckoGK
         zYPPChkpZkfTLjoWpJx0seZkfX1D2PfG3rBVML6dfR1LJDYydyCM9y70C0qNZwBoaWmg
         xKgQquxgx0/BTaUkTWzCKIMB3rloE1reAf9jY1AgAK0mR4LWxg2lYKzruFm7/l59hp2o
         AMTCzPO+keYbk88A/Uq9CKLqu9bbwWVfzYpCjnCHAueNHHWnkCIp/byy61jJ46rPIWGN
         1djQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=/EMQzAezXnn0oYijD9ANQWZeVbNXHm+aZD+2Ibjc4yM=;
        b=cu5f4sADFa2T1itMZtzX5tgiih8wA80T6HVdCx4b4TP2HGcNI648RtD9l9QANDugAN
         Sm/HKrzskjrYzXrbqfZFi6PHwNWRq2ThC5/s7++uoSv2Mn6+L2AxmK9+nW0YjsXOza+h
         ikTg6qPg+tizgO3UrxH1UzGUc+aNlnbqBrPDwGOZTR8LhZayjn81WHITDCCFzBxGnjMg
         t9utrpQCrtACDKwctCUJpUfdaT9N2kZugwQ7eel3iAh1QwmPnRKaLJbZy1gSlcKM1Oi5
         jLwRWzvUla8X2lcEgWVm1ZXFopC3Egkj0uacySFqd/XBdfZY73gVyjaosTrfdafm2R65
         borg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f3si2433311edv.9.2019.05.13.23.20.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 23:20:41 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 8FD3DAD94;
	Tue, 14 May 2019 06:20:40 +0000 (UTC)
Date: Tue, 14 May 2019 08:20:39 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Yang Shi <shy828301@gmail.com>
Cc: Yang Shi <yang.shi@linux.alibaba.com>,
	Huang Ying <ying.huang@intel.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Mel Gorman <mgorman@techsingularity.net>,
	kirill.shutemov@linux.intel.com, Hugh Dickins <hughd@google.com>,
	Shakeel Butt <shakeelb@google.com>, william.kucharski@oracle.com,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: Re: [v2 PATCH] mm: vmscan: correct nr_reclaimed for THP
Message-ID: <20190514062039.GB20868@dhcp22.suse.cz>
References: <1557505420-21809-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190513080929.GC24036@dhcp22.suse.cz>
 <c3c26c7a-748c-6090-67f4-3014bedea2e6@linux.alibaba.com>
 <20190513214503.GB25356@dhcp22.suse.cz>
 <CAHbLzkpUE2wBp8UjH72ugXjWSfFY5YjV1Ps9t5EM2VSRTUKxRw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHbLzkpUE2wBp8UjH72ugXjWSfFY5YjV1Ps9t5EM2VSRTUKxRw@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 13-05-19 21:36:59, Yang Shi wrote:
> On Mon, May 13, 2019 at 2:45 PM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Mon 13-05-19 14:09:59, Yang Shi wrote:
> > [...]
> > > I think we can just account 512 base pages for nr_scanned for
> > > isolate_lru_pages() to make the counters sane since PGSCAN_KSWAPD/DIRECT
> > > just use it.
> > >
> > > And, sc->nr_scanned should be accounted as 512 base pages too otherwise we
> > > may have nr_scanned < nr_to_reclaim all the time to result in false-negative
> > > for priority raise and something else wrong (e.g. wrong vmpressure).
> >
> > Be careful. nr_scanned is used as a pressure indicator to slab shrinking
> > AFAIR. Maybe this is ok but it really begs for much more explaining
> 
> I don't know why my company mailbox didn't receive this email, so I
> replied with my personal email.
> 
> It is not used to double slab pressure any more since commit
> 9092c71bb724 ("mm: use sc->priority for slab shrink targets"). It uses
> sc->priority to determine the pressure for slab shrinking now.
> 
> So, I think we can just remove that "double slab pressure" code. It is
> not used actually and looks confusing now. Actually, the "double slab
> pressure" does something opposite. The extra inc to sc->nr_scanned
> just prevents from raising sc->priority.

I have to get in sync with the recent changes. I am aware there were
some patches floating around but I didn't get to review them. I was
trying to point out that nr_scanned used to have a side effect to be
careful about. If it doesn't have anymore then this is getting much more
easier of course. Please document everything in the changelog.
-- 
Michal Hocko
SUSE Labs

