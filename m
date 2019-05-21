Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 22506C04AAF
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 06:17:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E485620863
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 06:17:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E485620863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6D26F6B0003; Tue, 21 May 2019 02:17:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 682946B0005; Tue, 21 May 2019 02:17:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 54B086B0006; Tue, 21 May 2019 02:17:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 07C4A6B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 02:17:47 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id x16so29036169edm.16
        for <linux-mm@kvack.org>; Mon, 20 May 2019 23:17:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=FoPcLY0miRY5PxPQu0TUNW0KKRAuAX21tJsbyXN90R8=;
        b=uON4Sr6F50vAhmMd3sa+LOoENpc0FyQqIX4vF8xbYWzh5ZeiRRtP7RP1iit6i+Mpvw
         iRW1qJJCmJh/ClmQUfGG9LtuzMhg+kB7UDyNWMymgv9wlgcUWcy7POePr16gYLyeSv3B
         t7dsoWpXSihdu4kWKYfMHW9x5iZC3I7eJ0tMxig8m3LvOMNFhFGNprdpWY38K9ttfVMr
         ABHF+zUNoQOBUrxhxy/ikD+SGPAfYPJQAb2nkrY0uSodgqt4h0DRqi/jWArdsYST1/h9
         UcwNrRmliYKSzNbSgfj+1P0W4i9pCrc70NRIGuoUorZS6AOjYG7ZTJW9uJBcE5PV6SKw
         1GBQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXsvcLvx4AcjRNL/vH/hMUYsIL2MLCDlHJJssMFpwJpf+MdEqne
	hLa2y2bqvBuYXAaL30bYhLpyOJXB2HS/hqv2ymRfyCKV/Arwl157Ocs7/Epw2fQxeE2+qnQ6nm4
	hm39g5kLrEVGL7EzdGTwdrGXZTKFzPcHY81JtPZ5worXpXQob8Ct1OVLMaffRXsE=
X-Received: by 2002:a17:906:4581:: with SMTP id t1mr43879087ejq.187.1558419466580;
        Mon, 20 May 2019 23:17:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwWFesCkeLQj3YDuC9iS6wDYMhPKygwffSOfCN+LIs1CbfQGvJyH5AQpVpViIcIBbvlG/cU
X-Received: by 2002:a17:906:4581:: with SMTP id t1mr43879029ejq.187.1558419465642;
        Mon, 20 May 2019 23:17:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558419465; cv=none;
        d=google.com; s=arc-20160816;
        b=qPL/iF3z9jTsjZEQ9XXtWw2nhHBgKfdkPG9EqyuQZ57ctisUjxjIW+uIdyuPtTsfCO
         OmT3qU/OF7lCU8SF+EmhDJHz+Swq1o6x1vU9eZeSEpLYveWQApA6nwqReef35XtLe1dw
         Ur+zXYyQmsnrY3agr2Zd9+tDb/nhYLxwm6MCh1e3fVx+JkObbnD+ywE3pGmkzOLoDMYR
         XDJqdhcZ4p/rwdo1TU91XVFRtU4RgoBhI+XmiR3m7fp7FmVAq+4cTDg7NhiD1u5gVDwi
         X+ruWhsro7pT1UR/D1dwypz24JWQ4YW/NwKRBkY/s4f8c4WMFm3i12ggz9x4jxtOuefS
         CMCw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=FoPcLY0miRY5PxPQu0TUNW0KKRAuAX21tJsbyXN90R8=;
        b=SNerzawXC8erit1YBSTpxF6Xe/6Uv3Gv6usvJbc/4HqUhLyRu6RZRydM05K9l9AzBL
         iv4IanHZ8L5xeBv5xCgiDrZGJYnpvNd2T3V2/q9toAQRvuBXcDGUTI93wowYnP49sSkp
         Lp7UQXh57KoACogqWGTb0RXs0k/l9AttvhRz/jGdjQTEb9J24paw44KWeUaobuyeDuED
         mB/T9vXwqEtJ3FcFpmZkNVG9upnyBGckyJjHiabBUZZHz1ox8bxS4voH1AZQA+M8x9gw
         vGnx4hswg6WrGqy/jLO9LQLdX49ncBJg6RsAuwzeml2tvOR6PhJ4Mq5vDusHaF3BH+2i
         Wwhw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h15si7359346eda.399.2019.05.20.23.17.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 23:17:45 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id B91BCAD47;
	Tue, 21 May 2019 06:17:44 +0000 (UTC)
Date: Tue, 21 May 2019 08:17:43 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>, linux-api@vger.kernel.org
Subject: Re: [RFC 5/7] mm: introduce external memory hinting API
Message-ID: <20190521061743.GC32329@dhcp22.suse.cz>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190520035254.57579-6-minchan@kernel.org>
 <20190520091829.GY6836@dhcp22.suse.cz>
 <20190521024107.GF10039@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190521024107.GF10039@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 21-05-19 11:41:07, Minchan Kim wrote:
> On Mon, May 20, 2019 at 11:18:29AM +0200, Michal Hocko wrote:
> > [Cc linux-api]
> > 
> > On Mon 20-05-19 12:52:52, Minchan Kim wrote:
> > > There is some usecase that centralized userspace daemon want to give
> > > a memory hint like MADV_[COOL|COLD] to other process. Android's
> > > ActivityManagerService is one of them.
> > > 
> > > It's similar in spirit to madvise(MADV_WONTNEED), but the information
> > > required to make the reclaim decision is not known to the app. Instead,
> > > it is known to the centralized userspace daemon(ActivityManagerService),
> > > and that daemon must be able to initiate reclaim on its own without
> > > any app involvement.
> > 
> > Could you expand some more about how this all works? How does the
> > centralized daemon track respective ranges? How does it synchronize
> > against parallel modification of the address space etc.
> 
> Currently, we don't track each address ranges because we have two
> policies at this moment:
> 
> 	deactive file pages and reclaim anonymous pages of the app.
> 
> Since the daemon has a ability to let background apps resume(IOW, process
> will be run by the daemon) and both hints are non-disruptive stabilty point
> of view, we are okay for the race.

Fair enough but the API should consider future usecases where this might
be a problem. So we should really think about those potential scenarios
now. If we are ok with that, fine, but then we should be explicit and
document it that way. Essentially say that any sort of synchronization
is supposed to be done by monitor. This will make the API less usable
but maybe that is enough.
 
> > > To solve the issue, this patch introduces new syscall process_madvise(2)
> > > which works based on pidfd so it could give a hint to the exeternal
> > > process.
> > > 
> > > int process_madvise(int pidfd, void *addr, size_t length, int advise);
> > 
> > OK, this makes some sense from the API point of view. When we have
> > discussed that at LSFMM I was contemplating about something like that
> > except the fd would be a VMA fd rather than the process. We could extend
> > and reuse /proc/<pid>/map_files interface which doesn't support the
> > anonymous memory right now. 
> > 
> > I am not saying this would be a better interface but I wanted to mention
> > it here for a further discussion. One slight advantage would be that
> > you know the exact object that you are operating on because you have a
> > fd for the VMA and we would have a more straightforward way to reject
> > operation if the underlying object has changed (e.g. unmapped and reused
> > for a different mapping).
> 
> I agree your point. If I didn't miss something, such kinds of vma level
> modify notification doesn't work even file mapped vma at this moment.
> For anonymous vma, I think we could use userfaultfd, pontentially.
> It would be great if someone want to do with disruptive hints like
> MADV_DONTNEED.
> 
> I'd like to see it further enhancement after landing address range based
> operation via limiting hints process_madvise supports to non-disruptive
> only(e.g., MADV_[COOL|COLD]) so that we could catch up the usercase/workload
> when someone want to extend the API.

So do you think we want both interfaces (process_madvise and madvisefd)?
-- 
Michal Hocko
SUSE Labs

