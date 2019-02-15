Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 929D5C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 13:11:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4BE84218AC
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 13:11:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4BE84218AC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DAA218E0002; Fri, 15 Feb 2019 08:11:25 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D5BAC8E0001; Fri, 15 Feb 2019 08:11:25 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C4BC08E0002; Fri, 15 Feb 2019 08:11:25 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 672C48E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 08:11:25 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id u7so3942744edj.10
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 05:11:25 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=eiGYyTMLjvoCfZDYnRCaaCBm4lN8kCVhrT3KK2fZQ5c=;
        b=B61fttaXMSanDHmOiPFFTMht9wHkcrowSEUpllTV4k6PxQOR1tfcxhik8XeKPcyA8f
         q98Cw+X3dYhWSBvAjOmFXASQXnyT0Zr+iFIiCyilRVSDNG8NNAtw5+OMqE86c307ul0n
         g0FEo49CPaDaSanNiltYtTqMn9qpBMxYOYGE2WYyX4E9574i6FDVH9YB6UKMIcrpD6r1
         wKhZBKfUuPLU9lKSuC7EfW5GQYjPxtM9JUbtK0CkEgGaZ+77SK7y9GWmT017rIyjl8Dc
         c95iDY29TpdyCBSsxXNJ+tnnhSa3VywmoU73nR/uLbiNGqhA/70RMKoWEHDNqb2Mo1jw
         wL7A==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuaNzZ7LHlMpET5oI8zKJgTbg2bl05evOVuRCOcxea5ItSyLWPNx
	ttIo2CK1L9+ylmrEpCDWlS2kMZr7ye5byw2lg97hR1lUdy/DyGB3rsvLUWrz3DKreEKU06Kw8Sg
	tWjhAWrAs8YaDUSqzcg/evy2yyAP4pHV7yowq4GzL/ZaIdUurQko5SN/FKPaoBTs=
X-Received: by 2002:a50:b7ad:: with SMTP id h42mr7581178ede.210.1550236284963;
        Fri, 15 Feb 2019 05:11:24 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZzALOmDrnm7sh9Ub2R5uEYbg7vhNHPZHzGWJDd4JD8ZvR/0ZrsxJ0Ffoko7SZVOkJiuRNl
X-Received: by 2002:a50:b7ad:: with SMTP id h42mr7581126ede.210.1550236284013;
        Fri, 15 Feb 2019 05:11:24 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550236284; cv=none;
        d=google.com; s=arc-20160816;
        b=qd97bcCqwL37IbN3Tb1WD16ssax96l+bekCHkTBjj3VbGf6Fj5SkbQnKbCCqFsfKyj
         rcFEqsYV6LTLkw6zK9ThJKf36I10gs0SQHOPAyRt4vooIa/SO77UfgfYOvz7icp0KEV3
         qtw/mZLFHY3/K3jIGXeYOm+PIqTeRiXG36C0Qxtw3YpV1ezUKEDsbtbrb1qbpCrXdAaW
         zu99hVxVxUAS+MdP+KpxvgSaM19uDJoJ+9lXiavY7O9jJBH3zvpMMiiZsT4UtluoRxr0
         nitf+ja2I3lfc90SBaYFm9JYsbrKTpuCPoCnRB7OjRPWT802UIBLODUBDqzpd02sEj0G
         MEwA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=eiGYyTMLjvoCfZDYnRCaaCBm4lN8kCVhrT3KK2fZQ5c=;
        b=BTnjxPg+1D/wusWJIn913P3L04/RVYUBtlE1dDG9AIM0FT/jFFtQ67bLQXSxrg0xor
         UpjuwInejAA4SEL1R1jvE9bZm7DU3BnTfgUOxMgh5c3EX8/q09Xt4lng/WFZR/by8gLS
         eqDELLhtbDJxIeFVRbeMrAxxtAEgzWm3QOAFNeajd5rPQTzU4929AiJa1kwRoiGzgE+w
         +4rR37DQjPEa+I0Ue5hd9TJHF7Xo4dC89bQoPBo4YQu/dy0zatx/LzG7RuimSR0X2RLW
         UzqwO0bZyiHErk3hABaFakUlhSyUt9v57MZso937QWQ2/S8NQinaO0t5HYn/3O/mQnNQ
         x+xA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l19si431100edr.195.2019.02.15.05.11.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 05:11:23 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 4B6ADADCA;
	Fri, 15 Feb 2019 13:11:23 +0000 (UTC)
Date: Fri, 15 Feb 2019 14:11:22 +0100
From: Michal Hocko <mhocko@kernel.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>,
	"Paul E . McKenney" <paulmck@linux.vnet.ibm.com>,
	Minchan Kim <minchan@kernel.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Chen <tim.c.chen@linux.intel.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	=?utf-8?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	David Rientjes <rientjes@google.com>,
	Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>,
	Dave Jiang <dave.jiang@intel.com>,
	Daniel Jordan <daniel.m.jordan@oracle.com>,
	Andrea Parri <andrea.parri@amarulasolutions.com>
Subject: Re: [PATCH -mm -V7] mm, swap: fix race between swapoff and some swap
 operations
Message-ID: <20190215131122.GA4525@dhcp22.suse.cz>
References: <20190211083846.18888-1-ying.huang@intel.com>
 <20190214143318.GJ4525@dhcp22.suse.cz>
 <871s49bkaz.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <871s49bkaz.fsf@yhuang-dev.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 15-02-19 15:08:36, Huang, Ying wrote:
> Michal Hocko <mhocko@kernel.org> writes:
> 
> > On Mon 11-02-19 16:38:46, Huang, Ying wrote:
> >> From: Huang Ying <ying.huang@intel.com>
> >> 
> >> When swapin is performed, after getting the swap entry information from
> >> the page table, system will swap in the swap entry, without any lock held
> >> to prevent the swap device from being swapoff.  This may cause the race
> >> like below,
> >> 
> >> CPU 1				CPU 2
> >> -----				-----
> >> 				do_swap_page
> >> 				  swapin_readahead
> >> 				    __read_swap_cache_async
> >> swapoff				      swapcache_prepare
> >>   p->swap_map = NULL		        __swap_duplicate
> >> 					  p->swap_map[?] /* !!! NULL pointer access */
> >> 
> >> Because swapoff is usually done when system shutdown only, the race may
> >> not hit many people in practice.  But it is still a race need to be fixed.
> >> 
> >> To fix the race, get_swap_device() is added to check whether the specified
> >> swap entry is valid in its swap device.  If so, it will keep the swap
> >> entry valid via preventing the swap device from being swapoff, until
> >> put_swap_device() is called.
> >> 
> >> Because swapoff() is very rare code path, to make the normal path runs as
> >> fast as possible, disabling preemption + stop_machine() instead of
> >> reference count is used to implement get/put_swap_device().  From
> >> get_swap_device() to put_swap_device(), the preemption is disabled, so
> >> stop_machine() in swapoff() will wait until put_swap_device() is called.
> >> 
> >> In addition to swap_map, cluster_info, etc.  data structure in the struct
> >> swap_info_struct, the swap cache radix tree will be freed after swapoff,
> >> so this patch fixes the race between swap cache looking up and swapoff
> >> too.
> >> 
> >> Races between some other swap cache usages protected via disabling
> >> preemption and swapoff are fixed too via calling stop_machine() between
> >> clearing PageSwapCache() and freeing swap cache data structure.
> >> 
> >> Alternative implementation could be replacing disable preemption with
> >> rcu_read_lock_sched and stop_machine() with synchronize_sched().
> >
> > using stop_machine is generally discouraged. It is a gross
> > synchronization.
> >
> > Besides that, since when do we have this problem?
> 
> For problem, you mean the race between swapoff and the page fault
> handler?

yes

> The problem is introduced in v4.11 when we avoid to replace
> swap_info_struct->lock with swap_cluster_info->lock in
> __swap_duplicate() if possible to improve the scalability of swap
> operations.  But because swapoff is a really rare operation, I don't
> think it's necessary to backport the fix.

Well, a lack of any bug reports would support your theory that this is
unlikely to hit in practice. Fixes tag would be nice to have regardless
though.

Thanks!
-- 
Michal Hocko
SUSE Labs

