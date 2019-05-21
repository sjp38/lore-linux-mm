Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0A125C04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 06:04:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B29F320863
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 06:04:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B29F320863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 296D16B0007; Tue, 21 May 2019 02:04:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 247F56B0008; Tue, 21 May 2019 02:04:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 10FF16B000C; Tue, 21 May 2019 02:04:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id B31B56B0007
	for <linux-mm@kvack.org>; Tue, 21 May 2019 02:04:47 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id 18so28964722eds.5
        for <linux-mm@kvack.org>; Mon, 20 May 2019 23:04:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=iGiuVyrWdErPenA47+xqHTFQvXjJMlkLCNfVHl8tsmQ=;
        b=VBs9yzAPjesZEM9qmR9aMrf+h4r8vsWu4HP7usk724sOqZeAUH1zFOKzobdOoWbSUx
         YrcV4h+ycpaK4AUrHnqd6CFs8eKlsFhtPqom/KEBfI2sjmaC6fH2IZCsa9NKp7Vfjblv
         H2odQVW/lGAzNpW1pap1iXS6B4hCEOQls+dhltTwqkpZjokLU9mO7cLtGq34K5dqQg7u
         fRWWCGJMbjOvUbFLoyWy6YztNFHkC0YiImladbMdFk80LAWxx86U8Q7hRm0guK4n+reA
         0LTw+FI/CT5wfcI70N7OLXdbA2HB7TXneqEs4JNLwEy9W4/d9XB0jOFv0WwKzk2xqoH3
         LsNQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVvnKjYoNlIYx92KAG/3ctkbxg6pwnshCClDM3JD9wYin9J6HMk
	4BAdHeIa8e5UgW4efnRSa/d7mzbGdCoJ0QZQkjwS/2VuXW5ZyFma5/gP9l3AUGq2uVti/sspsxq
	HmdjhYhFeiiDnKBcYIMkzeaghw5Q9UCtlEQhLL/p0bNLATYa/QZ1vrrfYe3qa/BU=
X-Received: by 2002:a17:906:9145:: with SMTP id y5mr18970212ejw.206.1558418687192;
        Mon, 20 May 2019 23:04:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxmyM851lRnHt1aQ291WD4YZgbmyjLYqdKDzATXXhvaTZQi7vze4dAoWyxz8xpAhgWudNwi
X-Received: by 2002:a17:906:9145:: with SMTP id y5mr18970154ejw.206.1558418686301;
        Mon, 20 May 2019 23:04:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558418686; cv=none;
        d=google.com; s=arc-20160816;
        b=B4nyNokAL0u1Z4Lx+5lELUf5xLEwr74kuuxbNh0kNqW/ldkzks17FEM8T2QE7DvwlN
         xovZfBpWCeqP5dA89OTNX1SeJ1IbSRMwRQBJq6ZPYHO6VHeK6RSLnBlQyi45ALvHfA6l
         CtSJMo1OWJQmmJWP6kt+nuwmH2J9/rHK93QHIz61uGnX3gDfKyO/N0lF7kgRbNBCpPLl
         TXJg73YF973SVf66Npz2ymX/dKCi4rcfa73pfZT/wO9GOArt6ebL1coBKgvW9AWheghR
         zq8g2/glj2Bm84NZt39OL/NMYB9L+bQj4FVDZVENv97ywqs0vjmuEnUHWVLacd+eTxrx
         8yWQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=iGiuVyrWdErPenA47+xqHTFQvXjJMlkLCNfVHl8tsmQ=;
        b=oiz8hpG6hkdsT3hAtroNBczgJYa8Ka2V95ZKV0XzQJunoQpitYIVE8870fH4mBVgSJ
         B47VWtong5PQxvJI/D/6Er9OhsmbsS4SX5NZPemOZ3DHwy5EbW6poiNZAk8sWsM7hsXh
         4BhSTo/0rEIy+SvaEuZNCLSSbcB96ynm3iq5xXU2Q2tBZLLd5Tbuq1R7SnuhHsXg2awG
         xmQ5UV2ilwX6hOU2DH8KBxuyng7TUaVJv/fM8FAlh6oCSQXlCFCt660SiqQFUn4MXojZ
         Vj7M/wWUnC349Vs6/+okolxORVTCzk62wNyjJFK0xPP+Er4OYHW2CcJ6tLKr5CsGEWkr
         lnXQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f58si1123128edf.183.2019.05.20.23.04.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 23:04:46 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 8B8CEAC20;
	Tue, 21 May 2019 06:04:45 +0000 (UTC)
Date: Tue, 21 May 2019 08:04:43 +0200
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
Subject: Re: [RFC 1/7] mm: introduce MADV_COOL
Message-ID: <20190521060443.GA32329@dhcp22.suse.cz>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190520035254.57579-2-minchan@kernel.org>
 <20190520081621.GV6836@dhcp22.suse.cz>
 <20190520225419.GA10039@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190520225419.GA10039@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 21-05-19 07:54:19, Minchan Kim wrote:
> On Mon, May 20, 2019 at 10:16:21AM +0200, Michal Hocko wrote:
[...]
> > > Internally, it works via deactivating memory from active list to
> > > inactive's head so when the memory pressure happens, they will be
> > > reclaimed earlier than other active pages unless there is no
> > > access until the time.
> > 
> > Could you elaborate about the decision to move to the head rather than
> > tail? What should happen to inactive pages? Should we move them to the
> > tail? Your implementation seems to ignore those completely. Why?
> 
> Normally, inactive LRU could have used-once pages without any mapping
> to user's address space. Such pages would be better candicate to
> reclaim when the memory pressure happens. With deactivating only
> active LRU pages of the process to the head of inactive LRU, we will
> keep them in RAM longer than used-once pages and could have more chance
> to be activated once the process is resumed.

You are making some assumptions here. You have an explicit call what is
cold now you are assuming something is even colder. Is this assumption a
general enough to make people depend on it? Not that we wouldn't be able
to change to logic later but that will always be risky - especially in
the area when somebody want to make a user space driven memory
management.
 
> > What should happen for shared pages? In other words do we want to allow
> > less privileged process to control evicting of shared pages with a more
> > privileged one? E.g. think of all sorts of side channel attacks. Maybe
> > we want to do the same thing as for mincore where write access is
> > required.
> 
> It doesn't work with shared pages(ie, page_mapcount > 1). I will add it
> in the description.

OK, this is good for the starter. It makes the implementation simpler
and we can add shared mappings coverage later.

Although I would argue that touching only writeable mappings should be
reasonably safe.

-- 
Michal Hocko
SUSE Labs

