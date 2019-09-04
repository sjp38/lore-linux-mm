Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D5E0CC3A5A9
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 06:54:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A42DE2343A
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 06:54:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A42DE2343A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3DD5C6B0003; Wed,  4 Sep 2019 02:54:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 38D646B0006; Wed,  4 Sep 2019 02:54:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2C9E26B0007; Wed,  4 Sep 2019 02:54:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0060.hostedemail.com [216.40.44.60])
	by kanga.kvack.org (Postfix) with ESMTP id 09E2E6B0003
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 02:54:59 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 9476082437CF
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 06:54:58 +0000 (UTC)
X-FDA: 75896325876.15.pig22_e4b93172b060
X-HE-Tag: pig22_e4b93172b060
X-Filterd-Recvd-Size: 3080
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf21.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 06:54:58 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id ABD1DACFA;
	Wed,  4 Sep 2019 06:54:56 +0000 (UTC)
Date: Wed, 4 Sep 2019 08:54:55 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Qian Cai <cai@lca.pw>, Eric Dumazet <eric.dumazet@gmail.com>,
	davem@davemloft.net, netdev@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>,
	Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
	Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] net/skbuff: silence warnings under memory pressure
Message-ID: <20190904065455.GE3838@dhcp22.suse.cz>
References: <1567177025-11016-1-git-send-email-cai@lca.pw>
 <6109dab4-4061-8fee-96ac-320adf94e130@gmail.com>
 <1567178728.5576.32.camel@lca.pw>
 <229ebc3b-1c7e-474f-36f9-0fa603b889fb@gmail.com>
 <20190903132231.GC18939@dhcp22.suse.cz>
 <1567525342.5576.60.camel@lca.pw>
 <20190903185305.GA14028@dhcp22.suse.cz>
 <1567546948.5576.68.camel@lca.pw>
 <20190904061501.GB3838@dhcp22.suse.cz>
 <20190904064144.GA5487@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20190904064144.GA5487@jagdpanzerIV>
User-Agent: Mutt/1.10.1 (2018-07-13)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 04-09-19 15:41:44, Sergey Senozhatsky wrote:
> On (09/04/19 08:15), Michal Hocko wrote:
> > > If you look at the original report, the failed allocation dump_stac=
k() is,
> > >=20
> > > =A0<IRQ>
> > > =A0warn_alloc.cold.43+0x8a/0x148
> > > =A0__alloc_pages_nodemask+0x1a5c/0x1bb0
> > > =A0alloc_pages_current+0x9c/0x110
> > > =A0allocate_slab+0x34a/0x11f0
> > > =A0new_slab+0x46/0x70
> > > =A0___slab_alloc+0x604/0x950
> > > =A0__slab_alloc+0x12/0x20
> > > =A0kmem_cache_alloc+0x32a/0x400
> > > =A0__build_skb+0x23/0x60
> > > =A0build_skb+0x1a/0xb0
> > > =A0igb_clean_rx_irq+0xafc/0x1010 [igb]
> > > =A0igb_poll+0x4bb/0xe30 [igb]
> > > =A0net_rx_action+0x244/0x7a0
> > > =A0__do_softirq+0x1a0/0x60a
> > > =A0irq_exit+0xb5/0xd0
> > > =A0do_IRQ+0x81/0x170
> > > =A0common_interrupt+0xf/0xf
> > > =A0</IRQ>
> > >=20
> > > Since it has no __GFP_NOWARN to begin with, it will call,
>=20
> I think that DEFAULT_RATELIMIT_INTERVAL and DEFAULT_RATELIMIT_BURST
> are good when we ratelimit just a single printk() call, so the ratelimi=
t
> is "max 10 kernel log lines in 5 seconds".

I am sorry, I could have been more explicit when CCing you. Sure the
ratelimit is part of the problem. But I was more interested in the
potential livelock (infinite loop) mentioned by Qian Cai. It is not
important whether we generate one or more lines of output from the
softirq context as long as the printk generates more irq processing
which might end up doing the same. Is this really possible?
--=20
Michal Hocko
SUSE Labs

