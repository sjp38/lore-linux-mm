Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 49BFDC3A59F
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 12:45:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0BE8120828
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 12:45:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="PUHRKgmb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0BE8120828
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AC0426B057A; Mon, 26 Aug 2019 08:45:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A71DD6B057B; Mon, 26 Aug 2019 08:45:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 95E926B057C; Mon, 26 Aug 2019 08:45:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0220.hostedemail.com [216.40.44.220])
	by kanga.kvack.org (Postfix) with ESMTP id 6DC946B057A
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 08:45:01 -0400 (EDT)
Received: from smtpin08.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 1D167181AC9AE
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 12:45:01 +0000 (UTC)
X-FDA: 75864548802.08.frogs76_48d8321094f56
X-HE-Tag: frogs76_48d8321094f56
X-Filterd-Recvd-Size: 3114
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf47.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 12:45:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=PVVuBwtldaFBMW44tYXfYObvZ+/PW6iyu+ybLE74lwA=; b=PUHRKgmbosYq7btXa2cuF6PMt
	Df0ENheFKvVqcpG3n3a7iqqHnTnpA0YQ5170Kp+FUjJrpj5vHON50qsFk3v2dOADP1Sufhy8cRh18
	nZYe6xaBNtsU8cz6pDJwgPsx9Bu+dP5kgxIHZFVkgpRKwUwyku8u2yyNR5dTjwG4rcmu7eavFPdq0
	eqwg+qjo16uRq0B6el2PmNkDlMQqNqwYkgK8kfyTk46IYY3uGlKX8Q2hWWaD3B++oE9C5ndjsQljZ
	5aeT3AMsnw7TndkKXXO4XLKJp3F69Syq/6438COKAKrYINPgF3SMvGrzDpRHutobBGG2V3FN312B/
	O9E19r6HQ==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=noisy.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1i2EMi-0005QB-0f; Mon, 26 Aug 2019 12:44:56 +0000
Received: from hirez.programming.kicks-ass.net (hirez.programming.kicks-ass.net [192.168.1.225])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(Client did not present a certificate)
	by noisy.programming.kicks-ass.net (Postfix) with ESMTPS id 7C96830759B;
	Mon, 26 Aug 2019 14:44:19 +0200 (CEST)
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id BDD4420A71EF4; Mon, 26 Aug 2019 14:44:52 +0200 (CEST)
Date: Mon, 26 Aug 2019 14:44:52 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Song Liu <songliubraving@fb.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, kernel-team@fb.com, stable@vger.kernel.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Dave Hansen <dave.hansen@intel.com>,
	Andy Lutomirski <luto@amacapital.net>,
	Nadav Amit <namit@vmware.com>,
	Daniel Bristot de Oliveira <bristot@redhat.com>
Subject: Re: [PATCH] x86/mm: Do not split_large_page() for
 set_kernel_text_rw()
Message-ID: <20190826124452.GS2369@hirez.programming.kicks-ass.net>
References: <20190823052335.572133-1-songliubraving@fb.com>
 <20190823093637.GH2369@hirez.programming.kicks-ass.net>
 <20190826073308.6e82589d@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190826073308.6e82589d@gandalf.local.home>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 26, 2019 at 07:33:08AM -0400, Steven Rostedt wrote:
> Anyway, I believe Nadav has some patches that converts ftrace to use
> the shadow page modification trick somewhere.
> 
> Or we also need the text_poke batch processing (did that get upstream?).

It did. And I just did that patch; I'll send out in a bit.

It seems to work, but this is the very first time I've looked at this
code.

