Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 946FFC282D7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 17:41:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5337120870
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 17:41:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5337120870
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 01E408E0002; Wed, 30 Jan 2019 12:41:24 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F0E808E0001; Wed, 30 Jan 2019 12:41:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DD7CD8E0002; Wed, 30 Jan 2019 12:41:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 888BC8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 12:41:23 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id x15so140931edd.2
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 09:41:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=NYz4ShpcR46mr1LkihLq5JNzRQ9aq3fNKSAZGEzhCmg=;
        b=jJUCztHjVgTBjHDlHI3xeGiRdfrmBvQJIHA0z0c3TsJ2icZYUQOIxdBjp0kfteYG0s
         X2Eja6vTJWCK4T9HAweBw0nl509FI8JE602If/Isc+k5ldMLlvpnnbDEzPJEwQ7jVV3G
         24WnLdOvKGKJJpeiJPI14jgFMF0/iCVJDEX/NkOAp5rqhRbwgMcjxTU23ax4U0sizLJh
         l3q6QRFxH8O4oIfKQ7nEfjWYrsoaxx6llrEO8hvcf6mioL2G3HU9yqD8xO7kn0Lhgg+d
         th6RsNFtvA6pASV/uEb1fog0ccO/PhzW1Qnw2uPJO91YrPS5sa/M8mHZl/mGP+gcyPXj
         Ascw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukfLKRmrfle/ujSIxzVp4h1KCNOdyoLNyJuRF1WMQ8UU7Ao5FppT
	fYtMvOwTN7BI+Owuad9gnCMScRvTRxnxfdOKTfqVKvZA7xI8EilREurcQMpgc4sKtb4k6cIHy1y
	iBhMaiXT8HdO+jHLPjGFiHkqCaQ6e9GQZi3T3MjOei8ioveZ0vOEEBZ0TogHTtqU=
X-Received: by 2002:a17:906:1956:: with SMTP id b22mr26055411eje.216.1548870083021;
        Wed, 30 Jan 2019 09:41:23 -0800 (PST)
X-Google-Smtp-Source: ALg8bN74sq+iPCkkNY3h3yKuUI8izdxE39mCHBQaD0m5qRp9y1BB8ppXsVNpVjOIHljcUZuEZGy5
X-Received: by 2002:a17:906:1956:: with SMTP id b22mr26055361eje.216.1548870082136;
        Wed, 30 Jan 2019 09:41:22 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548870082; cv=none;
        d=google.com; s=arc-20160816;
        b=o0uYtsbeCuupHpgXur3g14/TYQKD9ks6OWgdVEOaFkxts93TVFP567zyIgz7Ce+tS9
         GB3jrK+MUMn04aZISRmGuXBu1XLDYUdMjyv1x0D9yRh+Nkqp4EbRfwP7T975jeRV6v1r
         b2eZ1GY9zI3fXrFdypJYU2XwQ2n51DeCu0yFha7Mbuw/PtCvHoV2+0eznMj4WVlDo7qr
         DKUKxkLUY/Jy+S60Qlj5e4ORC9xDfhDh44MfFTC5dXklnkZ11n61jeW7HQZ7zQuEW/9R
         z2yK+p6abGJaQ6/ltf/uCc1MjdOoipBK+wbN2uURO0tgZHPx6q8KHQHjtZ2dZr4DM2e+
         0n4g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=NYz4ShpcR46mr1LkihLq5JNzRQ9aq3fNKSAZGEzhCmg=;
        b=uW72UlpCz6eawTzEhEGfBvAucIHErSVvdSHB3t6xCmqgZHcNK6R1XxzQTR1QY2Cpoc
         PGe9BfzoGoyyPLinmdPmnR5f2ejcilDhk+xUDUnRpqxlhUcsTJXpOwYMa6YkuPemCAt0
         B9yIamxuAR6NjsjJGOES2+wi0D7FvIsTp9XjWwFrsGnvSWYhsSScOWZnCy3XBVlKBhp0
         GoFmcGxl3AiK0EUucUJ36lGH02AcbiA+CnxuLLfMp1xtGJ/rgaZWdbho+pImxL8XV7qW
         Xtd0bZyH5wsZfy3z+tAO7n3g3iiGoYPYmmqSlHWiyEpt9fk1Y8xr7dotsllqv0qjyXcj
         fyyw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x9si595434edm.375.2019.01.30.09.41.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 09:41:22 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 9BBD1AF51;
	Wed, 30 Jan 2019 17:41:21 +0000 (UTC)
Date: Wed, 30 Jan 2019 18:41:17 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Chris Down <chris@chrisdown.name>,
	Andrew Morton <akpm@linux-foundation.org>,
	Roman Gushchin <guro@fb.com>, Dennis Zhou <dennis@kernel.org>,
	linux-kernel@vger.kernel.org, cgroups@vger.kernel.org,
	linux-mm@kvack.org, kernel-team@fb.com
Subject: Re: [PATCH 2/2] mm: Consider subtrees in memory.events
Message-ID: <20190130174117.GC18811@dhcp22.suse.cz>
References: <20190128145210.GM18811@dhcp22.suse.cz>
 <20190128145407.GP50184@devbig004.ftw2.facebook.com>
 <20190128151859.GO18811@dhcp22.suse.cz>
 <20190128154150.GQ50184@devbig004.ftw2.facebook.com>
 <20190128170526.GQ18811@dhcp22.suse.cz>
 <20190128174905.GU50184@devbig004.ftw2.facebook.com>
 <20190129144306.GO18811@dhcp22.suse.cz>
 <20190129145240.GX50184@devbig004.ftw2.facebook.com>
 <20190130165058.GA18811@dhcp22.suse.cz>
 <20190130170658.GY50184@devbig004.ftw2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190130170658.GY50184@devbig004.ftw2.facebook.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000004, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 30-01-19 09:06:58, Tejun Heo wrote:
> Hello, Michal.
> 
> On Wed, Jan 30, 2019 at 05:50:58PM +0100, Michal Hocko wrote:
> > > Yeah, cgroup.events and .stat files as some of the local stats would
> > > be useful too, so if we don't flip memory.events we'll end up with sth
> > > like cgroup.events.local, memory.events.tree and memory.stats.local,
> > > which is gonna be hilarious.
> > 
> > Why cannot we simply have memory.events_tree and be done with it? Sure
> > the file names are not goin to be consistent which is a minus but that
> > ship has already sailed some time ago.
> 
> Because the overall cost of shitty interface will be way higher in the
> longer term.

But we are discussing the file name effectively. I do not see a long
term maintenance burden. Confusing? Probably yes but that is were the
documentation would be helpful.
-- 
Michal Hocko
SUSE Labs

