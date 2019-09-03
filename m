Return-Path: <SRS0=NQQQ=W6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 98512C3A5A2
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 18:53:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 60D1D21897
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 18:53:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 60D1D21897
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F24D96B0005; Tue,  3 Sep 2019 14:53:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ED6006B0006; Tue,  3 Sep 2019 14:53:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DEBC56B0007; Tue,  3 Sep 2019 14:53:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0146.hostedemail.com [216.40.44.146])
	by kanga.kvack.org (Postfix) with ESMTP id BE0F36B0005
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 14:53:14 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 54C97AC09
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 18:53:14 +0000 (UTC)
X-FDA: 75894507108.24.point79_738b70525290a
X-HE-Tag: point79_738b70525290a
X-Filterd-Recvd-Size: 2487
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf48.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 18:53:13 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 95500B117;
	Tue,  3 Sep 2019 18:53:12 +0000 (UTC)
Date: Tue, 3 Sep 2019 20:53:05 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Qian Cai <cai@lca.pw>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] net/skbuff: silence warnings under memory pressure
Message-ID: <20190903185305.GA14028@dhcp22.suse.cz>
References: <1567177025-11016-1-git-send-email-cai@lca.pw>
 <6109dab4-4061-8fee-96ac-320adf94e130@gmail.com>
 <1567178728.5576.32.camel@lca.pw>
 <229ebc3b-1c7e-474f-36f9-0fa603b889fb@gmail.com>
 <20190903132231.GC18939@dhcp22.suse.cz>
 <1567525342.5576.60.camel@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1567525342.5576.60.camel@lca.pw>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 03-09-19 11:42:22, Qian Cai wrote:
> On Tue, 2019-09-03 at 15:22 +0200, Michal Hocko wrote:
> > On Fri 30-08-19 18:15:22, Eric Dumazet wrote:
> > > If there is a risk of flooding the syslog, we should fix this generically
> > > in mm layer, not adding hundred of __GFP_NOWARN all over the places.
> > 
> > We do already ratelimit in warn_alloc. If it isn't sufficient then we
> > can think of a different parameters. Or maybe it is the ratelimiting
> > which doesn't work here. Hard to tell and something to explore.
> 
> The time-based ratelimit won't work for skb_build() as when a system under
> memory pressure, and the CPU is fast and IO is so slow, it could take a long
> time to swap and trigger OOM.

I really do not understand what does OOM and swapping have to do with
the ratelimiting here. The sole purpose of the ratelimit is to reduce
the amount of warnings to be printed. Slow IO might have an effect on
when the OOM killer is invoked but atomic allocations are not directly
dependent on IO.

> I suppose what happens is those skb_build() allocations are from softirq, and
> once one of them failed, it calls printk() which generates more interrupts.
> Hence, the infinite loop.

Please elaborate more.

-- 
Michal Hocko
SUSE Labs

