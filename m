Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 553C7C3A5A8
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 08:25:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 23AF322DBF
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 08:25:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 23AF322DBF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A790B6B0003; Wed,  4 Sep 2019 04:25:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A29CC6B0006; Wed,  4 Sep 2019 04:25:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 93F826B0007; Wed,  4 Sep 2019 04:25:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0104.hostedemail.com [216.40.44.104])
	by kanga.kvack.org (Postfix) with ESMTP id 725A06B0003
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 04:25:44 -0400 (EDT)
Received: from smtpin25.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 157639085
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 08:25:44 +0000 (UTC)
X-FDA: 75896554608.25.spade00_4f1fe4030b446
X-HE-Tag: spade00_4f1fe4030b446
X-Filterd-Recvd-Size: 3045
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf18.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 08:25:43 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 6FFC6AE89;
	Wed,  4 Sep 2019 08:25:41 +0000 (UTC)
Date: Wed, 4 Sep 2019 10:25:40 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Qian Cai <cai@lca.pw>, Eric Dumazet <eric.dumazet@gmail.com>,
	davem@davemloft.net, netdev@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>,
	Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
	Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] net/skbuff: silence warnings under memory pressure
Message-ID: <20190904082540.GI3838@dhcp22.suse.cz>
References: <6109dab4-4061-8fee-96ac-320adf94e130@gmail.com>
 <1567178728.5576.32.camel@lca.pw>
 <229ebc3b-1c7e-474f-36f9-0fa603b889fb@gmail.com>
 <20190903132231.GC18939@dhcp22.suse.cz>
 <1567525342.5576.60.camel@lca.pw>
 <20190903185305.GA14028@dhcp22.suse.cz>
 <1567546948.5576.68.camel@lca.pw>
 <20190904061501.GB3838@dhcp22.suse.cz>
 <20190904064144.GA5487@jagdpanzerIV>
 <20190904070042.GA11968@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190904070042.GA11968@jagdpanzerIV>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 04-09-19 16:00:42, Sergey Senozhatsky wrote:
> On (09/04/19 15:41), Sergey Senozhatsky wrote:
> > But the thing is different in case of dump_stack() + show_mem() +
> > some other output. Because now we ratelimit not a single printk() line,
> > but hundreds of them. The ratelimit becomes - 10 * $$$ lines in 5 seconds
> > (IOW, now we talk about thousands of lines).
> 
> And on devices with slow serial consoles this can be somewhat close to
> "no ratelimit". *Suppose* that warn_alloc() adds 700 lines each time.
> Within 5 seconds we can call warn_alloc() 10 times, which will add 7000
> lines to the logbuf. If printk() can evict only 6000 lines in 5 seconds
> then we have a growing number of pending logbuf messages.

Yes, ratelimit is problematic when the ratelimited operation is slow. I
guess that is a well known problem and we would need to rework both the
api and the implementation to make it work in those cases as well.
Essentially we need to make the ratelimit act as a gatekeeper to an
operation section - something like a critical section except you can
tolerate more code executions but not too many. So effectively

	start_throttle(rate, number);
	/* here goes your operation */
	end_throttle();

one operation is not considered done until the whole section ends.
Or something along those lines.

In this particular case we can increase the rate limit parameters of
course but I think that longterm we need a better api.
-- 
Michal Hocko
SUSE Labs

