Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8CCC0C04E87
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 06:50:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5B98421743
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 06:50:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5B98421743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E83CB6B0003; Tue, 21 May 2019 02:50:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E338B6B0005; Tue, 21 May 2019 02:50:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D221E6B0006; Tue, 21 May 2019 02:50:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 83A106B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 02:50:03 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id r5so29047020edd.21
        for <linux-mm@kvack.org>; Mon, 20 May 2019 23:50:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=2ZkDKgj8qrHt/EXBvP4noZlO8/k3KVLxkmXI+R6GJV0=;
        b=IC0GR5Ls59QJxALy21FD8Q6r6BsoOwKyuaWS5bZ5qrycIxeHiSqY0Z8UwRi4UPA1cm
         ktgPlMdYOKTCB98Oh1IvzykRqRlKmh4UeSDcbv7Gd0LJUJjknYjTLluBWHBauo4avU1c
         fML0MbODusAp2Ikb6segvroAIxPyUfzlYyHRZQDmj1NWjpbgqKuE7LEsa7U2FFC1aWKy
         1j4p+0f2yymg6W3M4CxI4LeQS6bA2UQNtt7+HX0ZtlzJ99p6W+cQXgYY0cK7VB5+jK1y
         qfzolzPWisX6BxexF078nSIivpcgr3rvihqPXtbEc6iskN1CGOlLjiuL37s5KSfCybB5
         74bA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXjYRAEmQwGFmeIX1TnSM6arsRfSIK7vmUKtCWNEhe50QL5HNvg
	dGaX+Mi14L3vECNkvkZJQgqVsmwrV1lvkQOs1ICtMKxXa37Lapz0K5j1EkrKeg24Q1H2vGsqbNp
	f689t+LSMLIs+4miZm7k24oPBGHbsjO9+OdFS+LYgwWgVPLYej6WLfOWTOR/AMv0=
X-Received: by 2002:a50:e101:: with SMTP id h1mr585042edl.180.1558421403127;
        Mon, 20 May 2019 23:50:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwXtGtIWlhUYzZ4wCH7SWK3lMjS242hI4O6DNg5CFxD02MlKk7Qb54NpDzMM+gmQUcoK21J
X-Received: by 2002:a50:e101:: with SMTP id h1mr584973edl.180.1558421402243;
        Mon, 20 May 2019 23:50:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558421402; cv=none;
        d=google.com; s=arc-20160816;
        b=OQJEvLDxuBwxRV/3r4R8pWhmXgiallngLIUethHZeUU2A3O3mInJpee5oTIpDjWMx/
         mu4s6AUKYQJBl4PxeUE9rS1V7QmnLJH/HlvYW5fm4gnL9XsDKK4SADEGqL25ns4We9vW
         PzPplmIwFcTQUlxXmbo3NcRxjKxd0X+isePq4nwsc5XiQM/d+LPVipVJ/4zfqYBCwiMq
         7vTWaadzBEOtgRzpSSksKKfPzV+O68KAVqvG2+ko4iWv5uOncA0zm268Wn9QmqJ8jhx3
         ESMsfbnQ0wIIZYfKeCOfIByqQ9zay0jhT9EfhbDFNzbnHycZwNlN81048N4HHTzYfYg1
         siZQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=2ZkDKgj8qrHt/EXBvP4noZlO8/k3KVLxkmXI+R6GJV0=;
        b=s7Qtin4htN5bzCxRncOhuWLc9kRxlosqrGMuA4Ul1FF/PVR7/rlj2dUg3I7V4j7Xd5
         YDIfLZDseRVz5e82Gttiy5BiJ9+4c2srvy+k4Rgs5PDiedCCFgaMoP3I94le12Vdivt0
         wNThyVtegtHP/yr2ZHvs++qeXRduwzdiTRK6ZGL2m4e88U0eoG57u/KvxMBxcC0BecdC
         nUWdkkWPVc0ZUxbYTA3sWatqFxRMr36i/wFLmAOaSJ1NMIGFiWXxqy+jvARIdqeHlNUF
         StvPb+GfbrcHp4BAfyI7IXr5vWnUstBgQWzGWNxmwSuGVpK0tqOavzIjyqMloGVo8Saj
         9pOw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h28si17229743edh.128.2019.05.20.23.50.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 23:50:02 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 5C37FAF70;
	Tue, 21 May 2019 06:50:01 +0000 (UTC)
Date: Tue, 21 May 2019 08:50:00 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Oleksandr Natalenko <oleksandr@redhat.com>
Cc: Minchan Kim <minchan@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>
Subject: Re: [RFC 4/7] mm: factor out madvise's core functionality
Message-ID: <20190521065000.GH32329@dhcp22.suse.cz>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190520035254.57579-5-minchan@kernel.org>
 <20190520142633.x5d27gk454qruc4o@butterfly.localdomain>
 <20190521012649.GE10039@google.com>
 <20190521063628.x2npirvs75jxjilx@butterfly.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190521063628.x2npirvs75jxjilx@butterfly.localdomain>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 21-05-19 08:36:28, Oleksandr Natalenko wrote:
[...]
> Regarding restricting the hints, I'm definitely interested in having
> remote MADV_MERGEABLE/MADV_UNMERGEABLE. But, OTOH, doing it via remote
> madvise() introduces another issue with traversing remote VMAs reliably.
> IIUC, one can do this via userspace by parsing [s]maps file only, which
> is not very consistent, and once some range is parsed, and then it is
> immediately gone, a wrong hint will be sent.
> 
> Isn't this a problem we should worry about?

See http://lkml.kernel.org/r/20190520091829.GY6836@dhcp22.suse.cz

-- 
Michal Hocko
SUSE Labs

