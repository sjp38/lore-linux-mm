Return-Path: <SRS0=CHX8=XL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_2 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B9B46C4CECD
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 14:42:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8811B214D9
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 14:42:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8811B214D9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=goodmis.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1EB7D6B0005; Mon, 16 Sep 2019 10:42:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 19C0E6B0006; Mon, 16 Sep 2019 10:42:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0B1A66B0007; Mon, 16 Sep 2019 10:42:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0140.hostedemail.com [216.40.44.140])
	by kanga.kvack.org (Postfix) with ESMTP id D60616B0005
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 10:42:43 -0400 (EDT)
Received: from smtpin23.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 75941181AC9AE
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 14:42:43 +0000 (UTC)
X-FDA: 75941050206.23.month39_8c243868dc906
X-HE-Tag: month39_8c243868dc906
X-Filterd-Recvd-Size: 3026
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf32.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 14:42:42 +0000 (UTC)
Received: from gandalf.local.home (cpe-66-24-58-225.stny.res.rr.com [66.24.58.225])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id AC8F520830;
	Mon, 16 Sep 2019 14:42:40 +0000 (UTC)
Date: Mon, 16 Sep 2019 10:42:39 -0400
From: Steven Rostedt <rostedt@goodmis.org>
To: Qian Cai <cai@lca.pw>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Petr Mladek
 <pmladek@suse.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon
 <will@kernel.org>, Dan Williams <dan.j.williams@intel.com>,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, Peter Zijlstra
 <peterz@infradead.org>, Waiman Long <longman@redhat.com>, Thomas Gleixner
 <tglx@linutronix.de>, Theodore Ts'o <tytso@mit.edu>, Arnd Bergmann
 <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: page_alloc.shuffle=1 + CONFIG_PROVE_LOCKING=y = arm64 hang
Message-ID: <20190916104239.124fc2e5@gandalf.local.home>
In-Reply-To: <1568289941.5576.140.camel@lca.pw>
References: <1566509603.5576.10.camel@lca.pw>
	<1567717680.5576.104.camel@lca.pw>
	<1568128954.5576.129.camel@lca.pw>
	<20190911011008.GA4420@jagdpanzerIV>
	<1568289941.5576.140.camel@lca.pw>
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 12 Sep 2019 08:05:41 -0400
Qian Cai <cai@lca.pw> wrote:

> >  drivers/char/random.c | 7 ++++---
> >  1 file changed, 4 insertions(+), 3 deletions(-)
> > 
> > diff --git a/drivers/char/random.c b/drivers/char/random.c
> > index 9b54cdb301d3..975015857200 100644
> > --- a/drivers/char/random.c
> > +++ b/drivers/char/random.c
> > @@ -1687,8 +1687,9 @@ static void _warn_unseeded_randomness(const char *func_name, void *caller,
> >  	print_once = true;
> >  #endif
> >  	if (__ratelimit(&unseeded_warning))
> > -		pr_notice("random: %s called from %pS with crng_init=%d\n",
> > -			  func_name, caller, crng_init);
> > +		printk_deferred(KERN_NOTICE "random: %s called from %pS "
> > +				"with crng_init=%d\n", func_name, caller,
> > +				crng_init);
> >  }
> >  
> >  /*
> > @@ -2462,4 +2463,4 @@ void add_bootloader_randomness(const void *buf, unsigned int size)
> >  	else
> >  		add_device_randomness(buf, size);
> >  }
> > -EXPORT_SYMBOL_GPL(add_bootloader_randomness);
> > \ No newline at end of file
> > +EXPORT_SYMBOL_GPL(add_bootloader_randomness);  
> 
> This will also fix the hang.
> 
> Sergey, do you plan to submit this Ted?

Perhaps for a quick fix (and a comment that says this needs to be fixed
properly). I think the changes to printk() that was discussed at
Plumbers may also solve this properly.

-- Steve

