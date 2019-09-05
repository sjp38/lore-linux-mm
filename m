Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_2
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 90845C43140
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 17:14:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3927420870
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 17:14:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3927420870
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=goodmis.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 21A5E6B0282; Thu,  5 Sep 2019 13:14:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1CBFD6B0283; Thu,  5 Sep 2019 13:14:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0E1606B0285; Thu,  5 Sep 2019 13:14:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0229.hostedemail.com [216.40.44.229])
	by kanga.kvack.org (Postfix) with ESMTP id DC5F86B0282
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 13:14:22 -0400 (EDT)
Received: from smtpin29.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 84DE2180AD7C3
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 17:14:22 +0000 (UTC)
X-FDA: 75901515564.29.tail40_605c838d1715f
X-HE-Tag: tail40_605c838d1715f
X-Filterd-Recvd-Size: 2623
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf39.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 17:14:22 +0000 (UTC)
Received: from oasis.local.home (bl11-233-114.dsl.telepac.pt [85.244.233.114])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 8DB8820828;
	Thu,  5 Sep 2019 17:14:19 +0000 (UTC)
Date: Thu, 5 Sep 2019 13:14:13 -0400
From: Steven Rostedt <rostedt@goodmis.org>
To: Qian Cai <cai@lca.pw>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Petr Mladek
 <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
 Michal Hocko <mhocko@kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>,
 davem@davemloft.net, netdev@vger.kernel.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
Subject: Re: [PATCH] net/skbuff: silence warnings under memory pressure
Message-ID: <20190905131413.0aa4e4f1@oasis.local.home>
In-Reply-To: <1567699393.5576.96.camel@lca.pw>
References: <20190903185305.GA14028@dhcp22.suse.cz>
	<1567546948.5576.68.camel@lca.pw>
	<20190904061501.GB3838@dhcp22.suse.cz>
	<20190904064144.GA5487@jagdpanzerIV>
	<20190904065455.GE3838@dhcp22.suse.cz>
	<20190904071911.GB11968@jagdpanzerIV>
	<20190904074312.GA25744@jagdpanzerIV>
	<1567599263.5576.72.camel@lca.pw>
	<20190904144850.GA8296@tigerII.localdomain>
	<1567629737.5576.87.camel@lca.pw>
	<20190905113208.GA521@jagdpanzerIV>
	<1567699393.5576.96.camel@lca.pw>
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000016, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 05 Sep 2019 12:03:13 -0400
Qian Cai <cai@lca.pw> wrote:

> > > and could deal with console hardware that involve irq_exit() anyway.  
> > 
> > printk->console_driver->write() does not involve irq.  
> 
> Hmm, from the article,
> 
> https://en.wikipedia.org/wiki/Universal_asynchronous_receiver-transmitter
> 
> "Since transmission of a single or multiple characters may take a long time
> relative to CPU speeds, a UART maintains a flag showing busy status so that the
> host system knows if there is at least one character in the transmit buffer or
> shift register; "ready for next character(s)" may also be signaled with an
> interrupt."

I'm pretty sure all serial consoles do a busy loop on the UART and not
use interrupts to notify when it's available. That would require an
asynchronous implementation of printk() which would be quite complex to
implement.

-- Steve

