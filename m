Return-Path: <SRS0=tO+N=VH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 067F5C74A36
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 19:47:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C5CE820645
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 19:47:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C5CE820645
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 59E388E008D; Wed, 10 Jul 2019 15:47:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 54E018E0032; Wed, 10 Jul 2019 15:47:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 464F18E008D; Wed, 10 Jul 2019 15:47:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id EBE918E0032
	for <linux-mm@kvack.org>; Wed, 10 Jul 2019 15:47:22 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id d27so2306304eda.9
        for <linux-mm@kvack.org>; Wed, 10 Jul 2019 12:47:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=n+3148dvhMrZk2Jakl4I2423z9NjrhfvTQWBWBqyIuE=;
        b=CyUIO88RJTTQI1p/2yN+CWKniJ4BVDL9WpNNHQZBhpKfIsMPxqCm4p+GcMmVm0z5Fh
         ALd2kVdqFbZrBqOYnQj87+vvn/tNdtfjeiU09sqiF4XHKIX0iIlnm9511XhsU5V1aWEI
         EaP9c/xMUuWYSQVcxqzg44yKzP0krsbzvrO+uszijQ/e29rDB1sdQYGqQzsj8KzXUFx/
         zV/ux7uogoEbxI08u3Cax4CRgQpNdoUM/XYW6zJS+i8zB+GAj4q05NLuhS9C0w3krD0V
         R9oghYE0SJEAaHKQd93DEzDnMCgUBepYutuqn6BJWHTby6kqp8PEW/xlTjcXesWb7RPW
         JRng==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWxCPWfR5MQAebuIxp8XCkqzR8emaHVuhCuBLo89DPtKf6QfRd7
	WOOjjXXI/DplkxiYcF+ghHs/uFW4NUW8C12KiXA0Ivs9NaGX0NkJrloXQiehXbABQQX7JsZt9YF
	N7I6q5idMbxqfRJ8SodmUA9YeRzhP+V3ILg2kuAbBeZDAcSHrTHB2XBBbQDDSnnE=
X-Received: by 2002:a50:ad01:: with SMTP id y1mr32765271edc.180.1562788042518;
        Wed, 10 Jul 2019 12:47:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxSykl7LKYusXSw35LWeLQM4TVIptDpaqUyo4DC7NSrx95oRFWBkUb1mTJ8+Vh2da490icl
X-Received: by 2002:a50:ad01:: with SMTP id y1mr32765221edc.180.1562788041696;
        Wed, 10 Jul 2019 12:47:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562788041; cv=none;
        d=google.com; s=arc-20160816;
        b=xolAdkr1UaBtrzL5GQC+13HD57mGjLH9B8foOYmVwk2h2vB7fr0RS48lWQyp9YWQHM
         rcWAWyuvPYijXPR6SSPCeiJh30l3tCpDbMv24yxIEj8YBSRqoGXJjwjjIa2kDyUP+bD5
         cPeAHG2r0WMuY6u0LPm0QD3ootH2U9zchgJl4Ht5Rzdwb34evvq4NffvXmlqg20wje6k
         DsgXaACRMgoDbIuA4M1xbkQLI+x77f//gngZSYrcPI5jR1p0FoQaFRrmfPEf0j12h7EO
         BuXecngGIw1QtAFn42LkxvFA9b9QwD+vvgyVz5mgLWPRRkxnXxLaPfOWYL6me/YzY7p3
         TmDw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=n+3148dvhMrZk2Jakl4I2423z9NjrhfvTQWBWBqyIuE=;
        b=g6+io6AzGMvB4yIe9gdiMI/ebunPfvs2lfOBXXeWuEvnuCxSDuA0z/WvIvYmBucvw+
         7Q7XWn25OR8j0mGr5LntYtpnqciPXT1BcoAajEfv3V7swsY70v39mt1LqH74zupsrYHp
         ChOTJTxEDpd3PqdH7bcF4o5NI1TC63yWF0Zt8QEx49dqS+Y7zpHFlMHkxqXHl6VwHI/i
         gCjeNIZdV02tbyxxFWX2TzEI9u4Gd74W7XKuH8YtK+nNOTKu1Pmc3k0SC/dT1OEiADL4
         O4H+CXuYh/1U9hzDySDMxu4k4ImU4pT1L94q6CvcnsCADaiHCN3yfD3uW+FrR0Q7DCKL
         k7oQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k24si1796956ejz.188.2019.07.10.12.47.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Jul 2019 12:47:21 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 0E607ACA0;
	Wed, 10 Jul 2019 19:47:21 +0000 (UTC)
Date: Wed, 10 Jul 2019 21:47:19 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	oleksandr@redhat.com, hdanton@sina.com, lizeb@google.com,
	Dave Hansen <dave.hansen@intel.com>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH v3 4/5] mm: introduce MADV_PAGEOUT
Message-ID: <20190710194719.GS29695@dhcp22.suse.cz>
References: <20190627115405.255259-1-minchan@kernel.org>
 <20190627115405.255259-5-minchan@kernel.org>
 <20190709095518.GF26380@dhcp22.suse.cz>
 <20190710104809.GA186559@google.com>
 <20190710111622.GI29695@dhcp22.suse.cz>
 <20190710115356.GC186559@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190710115356.GC186559@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 10-07-19 20:53:56, Minchan Kim wrote:
> On Wed, Jul 10, 2019 at 01:16:22PM +0200, Michal Hocko wrote:
> > On Wed 10-07-19 19:48:09, Minchan Kim wrote:
> > > On Tue, Jul 09, 2019 at 11:55:19AM +0200, Michal Hocko wrote:
> > [...]
> > > > I am still not convinced about the SWAP_CLUSTER_MAX batching and the
> > > > udnerlying OOM argument. Is one pmd worth of pages really an OOM risk?
> > > > Sure you can have many invocations in parallel and that would add on
> > > > but the same might happen with SWAP_CLUSTER_MAX. So I would just remove
> > > > the batching for now and think of it only if we really see this being a
> > > > problem for real. Unless you feel really strong about this, of course.
> > > 
> > > I don't have the number to support SWAP_CLUSTER_MAX batching for hinting
> > > operations. However, I wanted to be consistent with other LRU batching
> > > logic so that it could affect altogether if someone try to increase
> > > SWAP_CLUSTER_MAX which is more efficienty for batching operation, later.
> > > (AFAIK, someone tried it a few years ago but rollback soon, I couldn't
> > > rebemeber what was the reason at that time, anyway).
> > 
> > Then please drop this part. It makes the code more complex while any
> > benefit is not demonstrated.
> 
> The history says the benefit.
> https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/patch/?id=d37dd5dcb955dd8c2cdd4eaef1f15d1b7ecbc379

Limiting the number of isolated pages is fine. All I am saying is that
SWAP_CLUSTER_MAX is an arbitrary number same as 512 pages for one PMD as
a unit of work. Both can lead to the same effect if there are too many
parallel tasks doing the same thing.

I do not want you to change that in the reclaim path. All I am asking
for is to add a bathing without any actual data to back that because
that makes the code more complex without any gains.
-- 
Michal Hocko
SUSE Labs

