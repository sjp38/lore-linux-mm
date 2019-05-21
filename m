Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AA87FC04AAF
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 06:34:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 76D9D21773
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 06:34:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 76D9D21773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3E1966B0005; Tue, 21 May 2019 02:34:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 390E26B0006; Tue, 21 May 2019 02:34:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 259696B0007; Tue, 21 May 2019 02:34:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id CDF496B0005
	for <linux-mm@kvack.org>; Tue, 21 May 2019 02:34:24 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id z5so29140450edz.3
        for <linux-mm@kvack.org>; Mon, 20 May 2019 23:34:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ZIAQHBaoU6N1pkMi5TydFSWJFjFaqpnqfAuBkt7sNiA=;
        b=lNz/B2ttYQ51uDWh+k24rmbBqQdcnYMztJLXrU7AohpsdUBWCSzxTJKJlCYYfvLOqt
         hSzu5tHK+In3Q4YpZ7JpRG7ZAAjLVo70QSOeGtM9Bf1KiNr9eJYqAHhgwcOC4O1F8Q05
         yc+GLF4CgANp33bVshf7DRcdScAolG5ri4BD1Y34Z8jlxDsIN15MGVSQ5B9e85pao4FY
         IpASkFIZmGAamkdgjIc6TZaNOn797aXI+Qo0GTAVXcqq7MeFypDmIiVNqOUWGCza9FQR
         Wy8iQzqzLPzQ+ICQaYWickGLPWzfSVrUkTEvOtBxnl40/eslWoF9veF5lIJw4/cDFk/W
         dGMg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVhHShcNGd8ugbO+vU1xZJ0lUIPBEUtt2AtsCK2K1XSzQyDM8oN
	VrmWjzsHiD7QcjrysenqeIC/XXMp7xsERdFKL4uJfvtZRv6odc8/Mc6bJ4ToCN0/YSC9zpuzJy6
	qfj1sGpK2P2r494az6QsOhL7jq0jiGXEMPT5hb3hd53PaXo80IOtfr9ZovYpTO68=
X-Received: by 2002:a17:906:e282:: with SMTP id gg2mr7943567ejb.38.1558420464415;
        Mon, 20 May 2019 23:34:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyeDgoOTjyrTBkbrTL5liXOO4YV7CEop9CsYZ5AccORcvkPiU3u7RAL9faF7/G6zQMqAmbq
X-Received: by 2002:a17:906:e282:: with SMTP id gg2mr7943523ejb.38.1558420463678;
        Mon, 20 May 2019 23:34:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558420463; cv=none;
        d=google.com; s=arc-20160816;
        b=KjjJnnrfryW1/egVrtWi1khE1exjuzxcf1vXeKLay9Z8n/w8YuJW1IQ2Is2JRj3qKO
         3OrnNfnSCT3xEKn6879kYPYaC5AlGlaVu39+OSNcrWyahNlQ0tdhKW+Gpj+FOKjQb+te
         Pan+Yb8i8RtwKE05JNQ3bK6AAPEAxZ+IrmjHcqc3VMhlS+GrFFLYRbYUP3AUJ/pzHv29
         eIJTWB2PlJPL09CrlyyMza8VWKCCi/9Vgqpa75KdBB5pr+dtB1hmEZ73TAu2JHMt8C6Z
         DkUqS546YqEZYlV8zgviWR68OW4tZdHRxHn4AgMFVeRfwBqHN+Xshs1L8RtxhsXcnkuG
         ZDxg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ZIAQHBaoU6N1pkMi5TydFSWJFjFaqpnqfAuBkt7sNiA=;
        b=vIPk0WGf5RUsxH8zikWerZOE9goK8AdM+zjneUVzl1y7lpek2XPjme0wxO04BX47Tv
         6O4mHt353quNXuhZv2AlJXbufJAsl7+bbd/fjGlWBeI1kuxGZuqGvDNwdjHidVpoMLUJ
         MVd6KFDlp4exipLAyjWHy4MkBJlGE4xBzyHlDymd7sYnasdawNVXX3/IRDdcQN6q5Y1A
         I1Xn7ycxt9FJCPVHhnSqeGTBsO2l9FNsCuIbmAeuKZ5IwvspoaHGHrbNKa0O5xGiL3pK
         9zToxbjPSjHIMMifJ8aWBeu3a5Ysi4KoxqvsA7KSzdTU7IvwYcSfxvLKBk0HD+1wxGDF
         6jfw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z54si9395216edb.367.2019.05.20.23.34.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 23:34:23 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 3D7E5AEC6;
	Tue, 21 May 2019 06:34:23 +0000 (UTC)
Date: Tue, 21 May 2019 08:34:21 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Minchan Kim <minchan@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>, linux-api@vger.kernel.org
Subject: Re: [RFC 0/7] introduce memory hinting API for external process
Message-ID: <20190521063421.GG32329@dhcp22.suse.cz>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190521014452.GA6738@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190521014452.GA6738@bombadil.infradead.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[linux-api]

On Mon 20-05-19 18:44:52, Matthew Wilcox wrote:
> On Mon, May 20, 2019 at 12:52:47PM +0900, Minchan Kim wrote:
> > IMHO we should spell it out that this patchset complements MADV_WONTNEED
> > and MADV_FREE by adding non-destructive ways to gain some free memory
> > space. MADV_COLD is similar to MADV_WONTNEED in a way that it hints the
> > kernel that memory region is not currently needed and should be reclaimed
> > immediately; MADV_COOL is similar to MADV_FREE in a way that it hints the
> > kernel that memory region is not currently needed and should be reclaimed
> > when memory pressure rises.
> 
> Do we tear down page tables for these ranges?  That seems like a good
> way of reclaiming potentially a substantial amount of memory.

I do not think we can in general because this is a non-destructive
operation. So at least we cannot tear down anonymous ptes (they will
turn into swap entries).

-- 
Michal Hocko
SUSE Labs

