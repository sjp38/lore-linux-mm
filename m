Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 36474C04AAF
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 08:16:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EDEF120656
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 08:16:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EDEF120656
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 955466B0005; Mon, 20 May 2019 04:16:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 92D626B0006; Mon, 20 May 2019 04:16:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7F5CA6B0007; Mon, 20 May 2019 04:16:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2F38E6B0005
	for <linux-mm@kvack.org>; Mon, 20 May 2019 04:16:24 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id b22so24083863edw.0
        for <linux-mm@kvack.org>; Mon, 20 May 2019 01:16:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=yZQy+pwf/7mWMuxbBQp8tA3M3Puxb3BpKTcmRjOk0sg=;
        b=eqUsE7aFTDaPIYuMrCyxVF7pKUqiiWnaP9YYtoZz1rKOXpokyainp5X+BefQN0TVW1
         RhC5wFjcVFyyWW9xrMaXPWcYGIhvXM6NIMdZrGXFIxZu6wkBJ856JLEFDuw+FFo4RJgg
         2g3hLao+7a2bP1EoJq1P6UsS+bhOOXVYO4cCeD9a00wyb4eM9Cryb2/fHnmOmOyH9rsO
         dgEZToFc8c9GZyXOicqPnDWn5gcRPgMqbLIlt61NiV63MWforFuLVK5mOluI3H/Zgoac
         EHDVJFXZo9kfNT1ypPhv/ydnTsHo082E7lsTGfay+LxNhCVJ+vAVhWg7tCQ3p8ZSYRub
         yfEA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWkeOIvQxT8mgt50v6bwXo8fQGl7rj5nQLwT0c5NC3Mi0k35t68
	1uxnoYDE+tah2IIeGe50wtIJB9hfqbOIc2txwTjB8iS8cOzuSvfl1b0kskaLkp0Wdf0WslHlCes
	0EZU7DFa6NB6AcVIgMi8dBPYeAmKO6s8bMOIZ9harke5p+46HpXi7JhaaJrZhVWE=
X-Received: by 2002:a50:b69c:: with SMTP id d28mr73950154ede.129.1558340183749;
        Mon, 20 May 2019 01:16:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzN/emQSktRLXy/yaBYQRhYqmXJe7aEYRs6bBOmpWRqr6F62S/o494bS/9iRVFBScTdSry2
X-Received: by 2002:a50:b69c:: with SMTP id d28mr73950097ede.129.1558340183003;
        Mon, 20 May 2019 01:16:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558340183; cv=none;
        d=google.com; s=arc-20160816;
        b=nU2fqTGqlrjrEng/eT2ojD+Ftl09HaSBspnGkrrOpwlXa0XgmISeQyHaiURWZE8NSz
         zUYjbkrerPV3JLYgG5Ayt2P59VAjXoVJy2GqZGF0W1LF5vHDhqpk2HRykzwLlBF4YWUl
         pi7Yaz/JMbBEzRQ2hkaA6WffCN5K6WiSUIHR0d/Ns3c/AuW1ooTVLUChvvzKcKKxxYYA
         dQUMPidb63V0uTpuX+HDNF0Dmp6CvxFxGIXrRo4BgiBswKzNlp3RILH2Vy5UaoKdhioi
         JKt+Um0c2p8cEw5mjEQfhE3iwjjUgwuEfnJHXzUA2VbiRXgRUUDNzqP6p1LMrOXrLzow
         D3cQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=yZQy+pwf/7mWMuxbBQp8tA3M3Puxb3BpKTcmRjOk0sg=;
        b=joryCkKTXWGl5LWYwNF9PmbGPoUfZRmhMuRp0qoqktj7FWWOkeCJIhTZl3NWer5ysQ
         EZII5lqMsxyYmJ4aJWt3cq1FO9Eue1pcHodjJ0GaNKVyiQHGEw3wsM2yAutF06hphBhT
         Xsp6ZC9yvS803x99CIFuzjwnhnVz3GnXbin6j3/4/DVSWVpyfkn6flZmA60aSZHHVUPg
         n1yk2hHM/e3k9+ZfGa1YRXi8eUTNNBvbprVDl31ST0mw86tQ4i6Fr2Bringj5gGX+bWp
         89Kb7p0waOa/hQQKENrSdS83M0NCx0m7R5MEebT/S+w2NoncwEwdlCyADP7UBk4OMN1J
         GBtw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g18si2789621ejw.9.2019.05.20.01.16.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 01:16:22 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 6CBF8ADEA;
	Mon, 20 May 2019 08:16:22 +0000 (UTC)
Date: Mon, 20 May 2019 10:16:21 +0200
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
Message-ID: <20190520081621.GV6836@dhcp22.suse.cz>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190520035254.57579-2-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190520035254.57579-2-minchan@kernel.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[CC linux-api]

On Mon 20-05-19 12:52:48, Minchan Kim wrote:
> When a process expects no accesses to a certain memory range
> it could hint kernel that the pages can be reclaimed
> when memory pressure happens but data should be preserved
> for future use.  This could reduce workingset eviction so it
> ends up increasing performance.
> 
> This patch introduces the new MADV_COOL hint to madvise(2)
> syscall. MADV_COOL can be used by a process to mark a memory range
> as not expected to be used in the near future. The hint can help
> kernel in deciding which pages to evict early during memory
> pressure.

I do not want to start naming fight but MADV_COOL sounds a bit
misleading. Everybody thinks his pages are cool ;). Probably MADV_COLD
or MADV_DONTNEED_PRESERVE.

> Internally, it works via deactivating memory from active list to
> inactive's head so when the memory pressure happens, they will be
> reclaimed earlier than other active pages unless there is no
> access until the time.

Could you elaborate about the decision to move to the head rather than
tail? What should happen to inactive pages? Should we move them to the
tail? Your implementation seems to ignore those completely. Why?

What should happen for shared pages? In other words do we want to allow
less privileged process to control evicting of shared pages with a more
privileged one? E.g. think of all sorts of side channel attacks. Maybe
we want to do the same thing as for mincore where write access is
required.
-- 
Michal Hocko
SUSE Labs

