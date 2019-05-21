Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8C879C04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 06:32:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4B0CF2173C
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 06:32:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4B0CF2173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D808D6B0003; Tue, 21 May 2019 02:32:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D2F7F6B0005; Tue, 21 May 2019 02:32:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BF76F6B0006; Tue, 21 May 2019 02:32:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 72A8E6B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 02:32:24 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id h2so29079108edi.13
        for <linux-mm@kvack.org>; Mon, 20 May 2019 23:32:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=R0J8eFAZPKfMuBgnAh1KTAQtcZQMjPYHQ4JTWjvI/a8=;
        b=uipNPt3hCKuBJ/8vVLu+VK49L6uQrkYA1MUHB8GYHkisrmqR9tLOk7yJG5idtw1KtO
         BEUXn4pqHHC8wXiTSEG5QdvXhvL8DedYCz5eod6WhPpRnpemoKkx7bNSXZ8wNhU8eCmS
         lB4aOwCDVX2ODzC93hMCZ4OQFWvK+uckvGYZPn2udtFwoFL8ysdqF1ERXC3EBxGqEdPF
         T+mQ9Ai1hHSYh6KtaCiZg6qYWGhatbv26Hn+r55pG59bbGxUEQikgAMzrWRv0vToy3iR
         iOJzt8vZHYTD9PSkkVQbXOucci4V54WwPifiywanqF2rL8UOILfM5eWzj0plVDH5zIR2
         L0sA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWptezYKpFE+oEoNtgFE5t2Nz3Qha54V1CH32x6nWXVmrh0Deh+
	JQihJ4FF81uo7ZyPFVUiigF6a2t8+vL6vvZBBVcDYv5XMKp5GvRV5zO1i3pTBN2cTmUTHUglVWT
	MnMJdvvkNdAAwKRYkBbnIfOQRJ/ZjvZ424blPwfR/kIn86j+iHaC2w+zGBrf+Wdo=
X-Received: by 2002:a17:906:2922:: with SMTP id v2mr11429304ejd.115.1558420344005;
        Mon, 20 May 2019 23:32:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxaidn63rwvx527LK9ww1n9GjHVj/N2pF/mW+E79xdoz+HlbzwxzDNKyObBSe3300MyEpvf
X-Received: by 2002:a17:906:2922:: with SMTP id v2mr11429260ejd.115.1558420343250;
        Mon, 20 May 2019 23:32:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558420343; cv=none;
        d=google.com; s=arc-20160816;
        b=hfVQqgqq5K1A1jE/xMD/BgzE7JZyR8A2lbEkUpcLnkpeLNGtnw1/uvl8OY7YwmqtVr
         PM+a2Xpozub8m+FzHxCAnjtDNDILFTvQM1bQdbPXJNxKpPN8hLSj1aJ0mCXRrnFgAzb2
         568Xsz3UBoxMXT2+QhazvzSaolhz/nX3Mv+ZgthMr0+ez7aKV3o46/F4+nSvZLtBuB67
         ngFhlpobc2FvZ8gFotnxAD1bwmO+7eBq98Uzh39QyOD9jOkaY9TYdSDJ8dQ6zg+bw8KN
         OPEQkM04RwnPyjmHb6dn+bUZ35QysQIwc/lnbj4vNOE3YkgrJDPIM2WJOMeu8Xk8NOWb
         gu1Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=R0J8eFAZPKfMuBgnAh1KTAQtcZQMjPYHQ4JTWjvI/a8=;
        b=VD3Ksn6kqJpPSWqxkvn8dxiT+f7BQ9DRjS+y0ntp83MNtCsQ3Zob+HHX52jfkP4YEz
         BsyZ0gZ79vuE5fFP6ScfgZ5UiM5VbkPDym7YFKIXXpo+eRnR5b/gBUl/Y5BBdlhi3A43
         99icr1Bp2v0ib1lQQgSWii7zRqbX7boFyCse/0G7c7lIb9RGA2HqHLvxRwgSteLDij8f
         KU+gXGi5ITUOA5cwX2UfW+u+7qvNmKAQnIBQIKG9uc6P6BiZz0dn15Ny4nAEbmMHe6ui
         Bc335+4KDeZ1NqR/fpFaKzSs0bZj1FG5Ulk4RKD7xJMcm0NTBOo/vNbUkYDB7mI/ZQHh
         nz8Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l34si2547663edb.201.2019.05.20.23.32.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 23:32:23 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 57D8FAE1D;
	Tue, 21 May 2019 06:32:22 +0000 (UTC)
Date: Tue, 21 May 2019 08:32:21 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>, linux-api@vger.kernel.org
Subject: Re: [RFC 0/7] introduce memory hinting API for external process
Message-ID: <20190521063221.GF32329@dhcp22.suse.cz>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190520164605.GA11665@cmpxchg.org>
 <20190521043950.GJ10039@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190521043950.GJ10039@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[Cc linux-api]

On Tue 21-05-19 13:39:50, Minchan Kim wrote:
> On Mon, May 20, 2019 at 12:46:05PM -0400, Johannes Weiner wrote:
> > On Mon, May 20, 2019 at 12:52:47PM +0900, Minchan Kim wrote:
> > > - Approach
> > > 
> > > The approach we chose was to use a new interface to allow userspace to
> > > proactively reclaim entire processes by leveraging platform information.
> > > This allowed us to bypass the inaccuracy of the kernel’s LRUs for pages
> > > that are known to be cold from userspace and to avoid races with lmkd
> > > by reclaiming apps as soon as they entered the cached state. Additionally,
> > > it could provide many chances for platform to use much information to
> > > optimize memory efficiency.
> > > 
> > > IMHO we should spell it out that this patchset complements MADV_WONTNEED
> > > and MADV_FREE by adding non-destructive ways to gain some free memory
> > > space. MADV_COLD is similar to MADV_WONTNEED in a way that it hints the
> > > kernel that memory region is not currently needed and should be reclaimed
> > > immediately; MADV_COOL is similar to MADV_FREE in a way that it hints the
> > > kernel that memory region is not currently needed and should be reclaimed
> > > when memory pressure rises.
> > 
> > I agree with this approach and the semantics. But these names are very
> > vague and extremely easy to confuse since they're so similar.
> > 
> > MADV_COLD could be a good name, but for deactivating pages, not
> > reclaiming them - marking memory "cold" on the LRU for later reclaim.
> > 
> > For the immediate reclaim one, I think there is a better option too:
> > In virtual memory speak, putting a page into secondary storage (or
> > ensuring it's already there), and then freeing its in-memory copy, is
> > called "paging out". And that's what this flag is supposed to do. So
> > how about MADV_PAGEOUT?
> > 
> > With that, we'd have:
> > 
> > MADV_FREE: Mark data invalid, free memory when needed
> > MADV_DONTNEED: Mark data invalid, free memory immediately
> > 
> > MADV_COLD: Data is not used for a while, free memory when needed
> > MADV_PAGEOUT: Data is not used for a while, free memory immediately
> > 
> > What do you think?
> 
> There are several suggestions until now. Thanks, Folks!
> 
> For deactivating:
> 
> - MADV_COOL
> - MADV_RECLAIM_LAZY
> - MADV_DEACTIVATE
> - MADV_COLD
> - MADV_FREE_PRESERVE
> 
> 
> For reclaiming:
> 
> - MADV_COLD
> - MADV_RECLAIM_NOW
> - MADV_RECLAIMING
> - MADV_PAGEOUT
> - MADV_DONTNEED_PRESERVE
> 
> It seems everybody doesn't like MADV_COLD so want to go with other.
> For consisteny of view with other existing hints of madvise, -preserve
> postfix suits well. However, originally, I don't like the naming FREE
> vs DONTNEED from the beginning. They were easily confused.
> I prefer PAGEOUT to RECLAIM since it's more likely to be nuance to
> represent reclaim with memory pressure and is supposed to paged-in
> if someone need it later. So, it imply PRESERVE.
> If there is not strong against it, I want to go with MADV_COLD and
> MADV_PAGEOUT.
> 
> Other opinion?

I do not really care strongly. I am pretty sure we will have a lot of
suggestions because people tend to be good at arguing about that...
Anyway, unlike DONTNEED/FREE we do not have any other OS to implement
these features, right? So we shouldn't be tight to existing names.
On the other hand I kinda like the reference to the existing names but
DEACTIVATE/PAGEOUT seem a good fit to me as well. Unless there is way
much better name suggested I would go with one of those. Up to you.
-- 
Michal Hocko
SUSE Labs

