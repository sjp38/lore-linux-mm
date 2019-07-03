Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5CDF4C06513
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 09:17:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 300942189E
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 09:17:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 300942189E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B92966B0003; Wed,  3 Jul 2019 05:17:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B420F8E0003; Wed,  3 Jul 2019 05:17:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A33438E0001; Wed,  3 Jul 2019 05:17:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 539146B0003
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 05:17:51 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id c27so1233477edn.8
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 02:17:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=zFn0R1BIJkVs6C6l25PMXXvjISDd7tz6HAFht8/fEZo=;
        b=DUHmPHj9IYwO+MxkbEbZ6CbZR+/IxeRjS2iV5AmW+bgCiH+eR5ZEkQJW2rJtgKx2lO
         inYY5R3RvPub3yoLeUTcDJEvlkb0GoliXunTEm3oH0TS4vJYQJgxMzuSXplPpUkbDgVA
         YQZhk3mgRxiA1xikqCKP0l4QG0AbeMKedfGUu99mFvds5lA99nh8c+DzVDqPqYKiLNpD
         6QZsfA//eBVsx/dvzPJmuuR5sD0IULO/y4kcrUyIUK1ntd7b3a9IzkMJMUQTsjsQvGGh
         Cu4o0gLZE06n2m64bNN6lt5vU5i/DJWOWLeq8RJjdt/O+mXLCZ3A7nM0VKJklVY/MmE4
         mKLA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
X-Gm-Message-State: APjAAAVJD7B3hh+UEswq02fPBzMMeoDnBz7hIczXn1ryN4MnaUZ+Frlz
	o7LmkfSB/W4mvXGpvMyI8eaBIXwvbIc3o4LXOu58/Vh/JGGoC2ai870dNEvptLb4cfxc1VUUecc
	QyV8OlKptRj1pLGiOJKxbiSovuCac9vYDYktgXhZ5sf94f2S0Td9BiYwJdEmAVghklA==
X-Received: by 2002:a17:906:158c:: with SMTP id k12mr3816346ejd.83.1562145470902;
        Wed, 03 Jul 2019 02:17:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxJsAyt57z6dtC0zXakYGauixboAPG5Ly2Rdu1kLCsRKX2XF4dPq/9dBucoWE7/C4D2jDvD
X-Received: by 2002:a17:906:158c:: with SMTP id k12mr3816283ejd.83.1562145469890;
        Wed, 03 Jul 2019 02:17:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562145469; cv=none;
        d=google.com; s=arc-20160816;
        b=ltLg1sdPLQu/FdQA8V48D47hrRHxNMM26cM9WqiSaTWSFD746CQKm+6Va0Y/kGdXwM
         jx1tcCAh5nSDbmxGEHfZCTC9WsqRg51wBk7hv0M9EV49wIBZQVVA0xfTJ76Z2oaBTEqD
         GW8xgS6E3uE/jGhrt0NhdZ+iRcMCAwaEnS2UMXjU8uRo4C75fUAbxcf8KVs43IduR4AW
         4lr+2yAk61896QIyg2DgGY8N3WleIGfT856XJqqnR4Z8C8H0O15y917wzfnOUAnNf25x
         YTRXokaO9Yge+9aWh+R4xJcO4+HXHWgT1EV0B1RbRtWnBDnteVI7aKSX9HCiYQPbr+rM
         dUOg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=zFn0R1BIJkVs6C6l25PMXXvjISDd7tz6HAFht8/fEZo=;
        b=b7aIAyVmeI4MaaFXg+dSvuEch9qDWQ9m+Rcl3MgEIDOaQIv7t2a5ICuK3+CKpXydqb
         udD+HawiwK2G+VlCSdfa9M5RL7NPcrD6i5w9aNQs1YnvvlIvjPbOnVk7GEed0grCUFez
         bU/ePr+izo3cjNBwQbow0XPRqGllM9GLCuLIeHbfwIYq2T7MEipOdFxLuRzzvtR+7rGx
         7bh13no+NFcDW2qHL5YJNRzvaZYUgKe4xCrjpM+Rz/3K59Q2a821yIEFGB+gC2pK2uMN
         gMbSXud9KDfU/ECH2iu2rG1MeoLeLtUhU3Xdl+tc3PGyt0uzKJ4ep17P7+B7Xw9mq/0S
         HQsQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z23si1631694edc.256.2019.07.03.02.17.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jul 2019 02:17:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 465AAAF70;
	Wed,  3 Jul 2019 09:17:49 +0000 (UTC)
Date: Wed, 3 Jul 2019 10:17:47 +0100
From: Mel Gorman <mgorman@suse.de>
To: huang ying <huang.ying.caritas@gmail.com>
Cc: Huang Ying <ying.huang@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>, jhladky@redhat.com,
	lvenanci@redhat.com, Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH -mm] autonuma: Fix scan period updating
Message-ID: <20190703091747.GA13484@suse.de>
References: <20190624025604.30896-1-ying.huang@intel.com>
 <20190624140950.GF2947@suse.de>
 <CAC=cRTNYUxGUcSUvXa-g9hia49TgrjkzE-b06JbBtwSn2zWYsw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CAC=cRTNYUxGUcSUvXa-g9hia49TgrjkzE-b06JbBtwSn2zWYsw@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 25, 2019 at 09:23:22PM +0800, huang ying wrote:
> On Mon, Jun 24, 2019 at 10:25 PM Mel Gorman <mgorman@suse.de> wrote:
> >
> > On Mon, Jun 24, 2019 at 10:56:04AM +0800, Huang Ying wrote:
> > > The autonuma scan period should be increased (scanning is slowed down)
> > > if the majority of the page accesses are shared with other processes.
> > > But in current code, the scan period will be decreased (scanning is
> > > speeded up) in that situation.
> > >
> > > This patch fixes the code.  And this has been tested via tracing the
> > > scan period changing and /proc/vmstat numa_pte_updates counter when
> > > running a multi-threaded memory accessing program (most memory
> > > areas are accessed by multiple threads).
> > >
> >
> > The patch somewhat flips the logic on whether shared or private is
> > considered and it's not immediately obvious why that was required. That
> > aside, other than the impact on numa_pte_updates, what actual
> > performance difference was measured and on on what workloads?
> 
> The original scanning period updating logic doesn't match the original
> patch description and comments.  I think the original patch
> description and comments make more sense.  So I fix the code logic to
> make it match the original patch description and comments.
> 
> If my understanding to the original code logic and the original patch
> description and comments were correct, do you think the original patch
> description and comments are wrong so we need to fix the comments
> instead?  Or you think we should prove whether the original patch
> description and comments are correct?
> 

I'm about to get knocked offline so cannot answer properly. The code may
indeed be wrong and I have observed higher than expected NUMA scanning
behaviour than expected although not enough to cause problems. A comment
fix is fine but if you're changing the scanning behaviour, it should be
backed up with data justifying that the change both reduces the observed
scanning and that it has no adverse performance implications.

-- 
Mel Gorman
SUSE Labs

