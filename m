Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2037EC28CC3
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 06:28:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E5A1726455
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 06:28:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E5A1726455
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8193C6B0269; Fri, 31 May 2019 02:28:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7CA5D6B026F; Fri, 31 May 2019 02:28:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6B8E16B0278; Fri, 31 May 2019 02:28:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1A3C26B0269
	for <linux-mm@kvack.org>; Fri, 31 May 2019 02:28:58 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id d15so12409392edm.7
        for <linux-mm@kvack.org>; Thu, 30 May 2019 23:28:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=v6dimRf+yHDe7xz8eg6wzBp0xwGCHBPie8WH9UV+01o=;
        b=MYPOdRi7Av3AzNsuLL4XGQ5tvCDPXJnHZfbEqPqevGuFTDGMx5E11zA0PM81I2bt5g
         i5vjT9jJQf6cwM7XMbIxN0VbcdrXek2vLzjdRety4kA7vhh4mePmm/nQjGbwbv+Sr4ri
         E+iLMnhLnQak3pyifyMWp0JBEEdmN+YiKv+YC+gjT30o7HCOXp91L5Q8L6kmzHaqwwpx
         ermzQ5sqJPYNZBA1gSmpBHHXuiOLQHHSuMgxuEuSBkUZoAK16uYgp2WjbBwhTlw7cTkC
         F81oErYkBzc0E6T/AkSMhff8UoGbwc7e/o7M5s9mNH/Pk3TxTZf+TZkKULkKCeRs5dB7
         V34w==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUTk8JuuLtiWyLe6n0tYAdCCuVt8ibxzv49W8Np8lYtWwIoGTCx
	XuPsfvmC5J4gA4ZofVLWbDDG+wuiisZf/TcMsPLI6OjnKxpB7JlrU6cFrCjydCUlHCI9gGBU3+K
	cXLh85TzuBrVMw1pT7kn+9eqcVZGQ5K25/LBpMZ58ZusoLuVeqVerj4ECPEVCDX4=
X-Received: by 2002:a50:9581:: with SMTP id w1mr9281549eda.6.1559284137682;
        Thu, 30 May 2019 23:28:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx+U91YXJrwQE839LTTS/mbKDUrIDnC1m0Pe06YAO3Szy6Z+ILhcBHd3EG2n+bdHIP17269
X-Received: by 2002:a50:9581:: with SMTP id w1mr9281474eda.6.1559284136618;
        Thu, 30 May 2019 23:28:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559284136; cv=none;
        d=google.com; s=arc-20160816;
        b=Aq80ywuDB5DKBcZ269HCuOSwYIJmNxxhrrf2rIOIiMARFzjiBWY8Abp+Zvney5fZQR
         7ooZXY0f9AkPqEV1ODjkveoGVwZa+zZv+1dLs3jaIr9oG/U62ElW3CcJyQhTmCb4eeGk
         KdWsBwQBKkWq4aLIF1tSaIA1dZ5EfywBtBPVYn2n35ZjuzFb/wc4OM5rcgK68KGM4nWK
         igut4vkHFCrHAHhMF3ZB1aq/2mBo8/R+dAX3YtRbgLnNC9/vuWs9S3BkZ7tT7hP6hni1
         HOv0lyTLWPWjPE6LXkEf6FH/MSgx73bEHw1FkI1+SG3InbOGCG9+VFEldVGImAeLz2cW
         feIQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=v6dimRf+yHDe7xz8eg6wzBp0xwGCHBPie8WH9UV+01o=;
        b=GpVtcNRYQ8x5Bwu2ukap5DPjnou6hduaxZlsUPOjMJryvYPj5WYUEDIQArq9xujw4K
         +ILRAONs4uCg97XcGrS7tVc+r8d+2vq/VdEzNwyEtQ1O7PJjYGwKXsjK/D/tLkzabSjN
         bjZnuB0wSbiH+LB2AcQPZV2TYg5FkK1cPlAGageZqrdlHootyP8gry8ELLdi8w5OzBSN
         h9Rlbw5XP3CrxpbgPA9JTxuOhGDPbSuvW2MjYtAMTVATA4+tnH/iVQkXg6+nGEuC3KBv
         xMgIwM/McMf4dcUxYMsdAoN6JcYEOkf1GzMgG9gXPoPJQI3niWWK7ncpVP4HJBJIcUvd
         MFUQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d16si3656751ede.160.2019.05.30.23.28.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 23:28:56 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id CFF82AF8A;
	Fri, 31 May 2019 06:28:55 +0000 (UTC)
Date: Fri, 31 May 2019 08:28:54 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Chris Down <chris@chrisdown.name>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>,
	Roman Gushchin <guro@fb.com>, Dennis Zhou <dennis@kernel.org>,
	linux-kernel@vger.kernel.org, cgroups@vger.kernel.org,
	linux-mm@kvack.org, kernel-team@fb.com
Subject: Re: [PATCH REBASED] mm, memcg: Make scan aggression always exclude
 protection
Message-ID: <20190531062854.GG6896@dhcp22.suse.cz>
References: <20190228213050.GA28211@chrisdown.name>
 <20190322160307.GA3316@chrisdown.name>
 <20190530061221.GA6703@dhcp22.suse.cz>
 <20190530064453.GA110128@chrisdown.name>
 <20190530065111.GC6703@dhcp22.suse.cz>
 <20190530205210.GA165912@chrisdown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190530205210.GA165912@chrisdown.name>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 30-05-19 13:52:10, Chris Down wrote:
> Michal Hocko writes:
> > On Wed 29-05-19 23:44:53, Chris Down wrote:
> > > Michal Hocko writes:
> > > > Maybe I am missing something so correct me if I am wrong but the new
> > > > calculation actually means that we always allow to scan even min
> > > > protected memcgs right?
> > > 
> > > We check if the memcg is min protected as a precondition for coming into
> > > this function at all, so this generally isn't possible. See the
> > > mem_cgroup_protected MEMCG_PROT_MIN check in shrink_node.
> > 
> > OK, that is the part I was missing, I got confused by checking the min
> > limit as well here. Thanks for the clarification. A comment would be
> > handy or do we really need to consider min at all?
> 
> You mean as part of the reclaim pressure calculation? Yeah, we still need
> it, because we might only set memory.min, but not set memory.low.

But then the memcg will get excluded as well right?
-- 
Michal Hocko
SUSE Labs

