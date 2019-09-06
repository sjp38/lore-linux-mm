Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 92214C00307
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 15:32:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 620D120854
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 15:32:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 620D120854
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0C8236B000C; Fri,  6 Sep 2019 11:32:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 077436B026C; Fri,  6 Sep 2019 11:32:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EA7DB6B026D; Fri,  6 Sep 2019 11:32:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0099.hostedemail.com [216.40.44.99])
	by kanga.kvack.org (Postfix) with ESMTP id CAAA56B000C
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 11:32:12 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 7F11852C6
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 15:32:12 +0000 (UTC)
X-FDA: 75904886904.07.jam61_879f89af51a22
X-HE-Tag: jam61_879f89af51a22
X-Filterd-Recvd-Size: 2816
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf37.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 15:32:11 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 22975AD69;
	Fri,  6 Sep 2019 15:32:10 +0000 (UTC)
Date: Fri, 6 Sep 2019 17:32:09 +0200
From: Petr Mladek <pmladek@suse.com>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, davem@davemloft.net,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
	Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org,
	Qian Cai <cai@lca.pw>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Subject: Re: [PATCH] net/skbuff: silence warnings under memory pressure
Message-ID: <20190906153209.ugkeuaespn2q5yix@pathway.suse.cz>
References:<20190904064144.GA5487@jagdpanzerIV>
 <20190904065455.GE3838@dhcp22.suse.cz>
 <20190904071911.GB11968@jagdpanzerIV>
 <20190904074312.GA25744@jagdpanzerIV>
 <1567599263.5576.72.camel@lca.pw>
 <20190904144850.GA8296@tigerII.localdomain>
 <1567629737.5576.87.camel@lca.pw>
 <20190905113208.GA521@jagdpanzerIV>
 <20190905132334.52b13d95@oasis.local.home>
 <20190906033900.GB1253@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To:<20190906033900.GB1253@jagdpanzerIV>
User-Agent: NeoMutt/20170912 (1.9.0)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 2019-09-06 12:39:00, Sergey Senozhatsky wrote:
> On (09/05/19 13:23), Steven Rostedt wrote:
> > > I think we can queue significantly much less irq_work-s from printk().
> > > 
> > > Petr, Steven, what do you think?
> 
> [..]
> > I mean, really, do we need to keep calling wake up if it
> > probably never even executed?
> 
> I guess ratelimiting you are talking about ("if it probably never even
> executed") would be to check if we have already called wake up on the
> log_wait ->head. For that we need to, at least, take log_wait spin_lock
> and check that ->head is still in TASK_INTERRUPTIBLE; which is (quite,
> but not exactly) close to what wake_up_interruptible() does - it doesn't
> wake up the same task twice, it bails out on `p->state & state' check.

I have just realized that only sleeping tasks are in the waitqueue.
It is already handled by waitqueue_active() check.

I am afraid that we could not ratelimit the wakeups. The userspace
loggers might then miss the last lines for a long.

We could move wake_up_klogd() back to console_unlock(). But it might
end up with a back-and-forth games according to who is currently
complaining.

Sigh, I still suggest to ratelimit the warning about failed
allocation.

Best Regards,
Petr

