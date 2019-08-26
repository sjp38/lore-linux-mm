Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F07E4C3A59F
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 15:57:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B10AD21848
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 15:57:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="r1kTwVUB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B10AD21848
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4DA376B05A9; Mon, 26 Aug 2019 11:57:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4B1CD6B05AB; Mon, 26 Aug 2019 11:57:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3C77D6B05AC; Mon, 26 Aug 2019 11:57:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0073.hostedemail.com [216.40.44.73])
	by kanga.kvack.org (Postfix) with ESMTP id 19C116B05A9
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 11:57:11 -0400 (EDT)
Received: from smtpin02.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id BC0E0181AC9B6
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 15:57:10 +0000 (UTC)
X-FDA: 75865033020.02.trick10_46b9a491ed08
X-HE-Tag: trick10_46b9a491ed08
X-Filterd-Recvd-Size: 2984
Received: from merlin.infradead.org (merlin.infradead.org [205.233.59.134])
	by imf18.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 15:57:10 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=4NfHu2NwcaIl5KJfjUKcoltjlmMkEeidEpjbwYEixgE=; b=r1kTwVUB5QH1N5CenHdiuQMyL
	epdJF8JRIsTjreqYtZ3jHgWB2dqS/ApoJxZUQSemx+9ZhkJXMCD4Sz8+GsJJrltATyTmlo/RNqwmI
	cQORD6x35RxPARdeCAeJPXh5GimEVflKFll5aJMahzRfAvXyXucGhYDrb1XtVf+r8NtSzL2ksDmCN
	ua6RsFBwDercls43+V2Ereka5jvkE7rsIGoB2diqEOvlvx/+Ndwi6wvJ4hiNzcL3im3zrFmm0PD/y
	pQ/8pgOiW+8WYzFHE4DnG2mYOJsH6B7pHgseuEglCV6ut2GMwiB3uzM/MtgPMPKGTdYxV8n7dOV56
	XCfs9tmrA==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=noisy.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1i2HMV-0004Cw-6v; Mon, 26 Aug 2019 15:56:55 +0000
Received: from hirez.programming.kicks-ass.net (hirez.programming.kicks-ass.net [192.168.1.225])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(Client did not present a certificate)
	by noisy.programming.kicks-ass.net (Postfix) with ESMTPS id 5D42D301FF9;
	Mon, 26 Aug 2019 17:56:18 +0200 (CEST)
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id DB56320C9570B; Mon, 26 Aug 2019 17:56:51 +0200 (CEST)
Date: Mon, 26 Aug 2019 17:56:51 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Nadav Amit <namit@vmware.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Song Liu <songliubraving@fb.com>,
	LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
	"kernel-team@fb.com" <kernel-team@fb.com>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Dave Hansen <dave.hansen@intel.com>,
	Andy Lutomirski <luto@amacapital.net>,
	Daniel Bristot de Oliveira <bristot@redhat.com>
Subject: Re: [PATCH] x86/mm: Do not split_large_page() for
 set_kernel_text_rw()
Message-ID: <20190826155651.GX2369@hirez.programming.kicks-ass.net>
References: <20190823052335.572133-1-songliubraving@fb.com>
 <20190823093637.GH2369@hirez.programming.kicks-ass.net>
 <20190826073308.6e82589d@gandalf.local.home>
 <31AB5512-F083-4DC3-BA73-D5D65CBC410A@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <31AB5512-F083-4DC3-BA73-D5D65CBC410A@vmware.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 26, 2019 at 03:41:24PM +0000, Nadav Amit wrote:

> For the record - here is my previous patch:
> https://lkml.org/lkml/2018/12/5/211

Thanks!

