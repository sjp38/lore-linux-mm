Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.0 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 85BB6C43331
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 04:32:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2F0B22075C
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 04:32:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Q3BuF2fB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2F0B22075C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 80F9E6B0003; Fri,  6 Sep 2019 00:32:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 798676B0006; Fri,  6 Sep 2019 00:32:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 686CD6B0007; Fri,  6 Sep 2019 00:32:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0193.hostedemail.com [216.40.44.193])
	by kanga.kvack.org (Postfix) with ESMTP id 4090C6B0003
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 00:32:31 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id B38C9181AC9AE
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 04:32:30 +0000 (UTC)
X-FDA: 75903224460.24.flag20_32fa81cb97d05
X-HE-Tag: flag20_32fa81cb97d05
X-Filterd-Recvd-Size: 4869
Received: from mail-pf1-f196.google.com (mail-pf1-f196.google.com [209.85.210.196])
	by imf36.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 04:32:30 +0000 (UTC)
Received: by mail-pf1-f196.google.com with SMTP id r12so3489238pfh.1
        for <linux-mm@kvack.org>; Thu, 05 Sep 2019 21:32:30 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=/FnnT+XGY6LiCYmK28My012gZf6Sb+2aTvY99K4lAnU=;
        b=Q3BuF2fBnREwoZv5O0AULfEwU50686QrzaKhLHMbWisLQZzidLcHnWw7inOhq+X5d0
         A7knkkQ3nLa7oS8l1UsfvfKguV8y5dLyN1LfgryRRtb3GWx6t4b8WXdkq3QbZUbh+70i
         BxNMcc5vP4B3FudQvzW0CJLc/VZEYAvqa2DXFt89TaP8Hw1i+W3BnmPyWO0M7A3wFSvH
         nhkXpPqf1fDndZZZQkIMX9cgFVSpB5beYnftiuo3f2HCETrBTme40co3jJXniSJmbrdG
         s1+UqzUA1KIPC7d3657NGcX5QQTDBTnN6ABFTeuGkvx8XadIGA4C1F//o59yUrr5Rx10
         vAzw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:content-transfer-encoding
         :in-reply-to:user-agent;
        bh=/FnnT+XGY6LiCYmK28My012gZf6Sb+2aTvY99K4lAnU=;
        b=jkTS/XhfNKjlZxSYn5baIu3PHlScWuGtT46nvVeixUUCnuneK2o8f3UetVVz1denDN
         1/BE2m/+wzMqceNB76P1A2tVq2efsNLHFJJekIN1wLH5F6ODthz9oJP3NzN60sxrI1Qx
         AMJG2XUfpzQzUVu5lLdWGhukQsX1BmrbQt1ZT+ZVoIf9ul/Ahdb+Md2NjvHHeafpsJfU
         qFW7UX5UcRs0jOGAuD+FfqOZSa16sK4DeXfSRUoeBXMinI8+wQdc/Z7NS047RVNTk//u
         nygh4E4229/yPuzFnIBqgWUfQ3OzMWP3V4OD7nfC6dHb3YUBMPOuWZUax2YFAY2CgnOq
         XJ9A==
X-Gm-Message-State: APjAAAXiMR78ShaA83gOkg/zPQMKSSapZ55uCw1n82YzUkYUwxPfg+CU
	jI+hHtvUKxM7OBrSHwOw6j8=
X-Google-Smtp-Source: APXvYqxc2uuv0Y76XwL+zuFYgZvhJZ59EpeDPE8ua3TPxZjuvmHYXMQb7gErTzcoocI8nf9EL8w66A==
X-Received: by 2002:a63:e901:: with SMTP id i1mr6181363pgh.451.1567744349121;
        Thu, 05 Sep 2019 21:32:29 -0700 (PDT)
Received: from localhost ([175.223.27.235])
        by smtp.gmail.com with ESMTPSA id w13sm4344619pfi.30.2019.09.05.21.32.26
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 05 Sep 2019 21:32:28 -0700 (PDT)
Date: Fri, 6 Sep 2019 13:32:24 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
To: Qian Cai <cai@lca.pw>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Petr Mladek <pmladek@suse.com>,
	Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
	Michal Hocko <mhocko@kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] net/skbuff: silence warnings under memory pressure
Message-ID: <20190906043224.GA18163@jagdpanzerIV>
References: <20190904061501.GB3838@dhcp22.suse.cz>
 <20190904064144.GA5487@jagdpanzerIV>
 <20190904065455.GE3838@dhcp22.suse.cz>
 <20190904071911.GB11968@jagdpanzerIV>
 <20190904074312.GA25744@jagdpanzerIV>
 <1567599263.5576.72.camel@lca.pw>
 <20190904144850.GA8296@tigerII.localdomain>
 <1567629737.5576.87.camel@lca.pw>
 <20190905113208.GA521@jagdpanzerIV>
 <1567699393.5576.96.camel@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1567699393.5576.96.camel@lca.pw>
User-Agent: Mutt/1.12.1 (2019-06-15)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000036, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On (09/05/19 12:03), Qian Cai wrote:
> > ---
> > diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
> > index cd51aa7d08a9..89cb47882254 100644
> > --- a/kernel/printk/printk.c
> > +++ b/kernel/printk/printk.c
> > @@ -2027,8 +2027,11 @@ asmlinkage int vprintk_emit(int facility, int =
level,
> > =A0	pending_output =3D (curr_log_seq !=3D log_next_seq);
> > =A0	logbuf_unlock_irqrestore(flags);
> > =A0
> > +	if (!pending_output)
> > +		return printed_len;
> > +
> > =A0	/* If called from the scheduler, we can not call up(). */
> > -	if (!in_sched && pending_output) {
> > +	if (!in_sched) {
> > =A0		/*
> > =A0		=A0* Disable preemption to avoid being preempted while holding
> > =A0		=A0* console_sem which would prevent anyone from printing to
> > @@ -2043,10 +2046,11 @@ asmlinkage int vprintk_emit(int facility, int=
 level,
> > =A0		if (console_trylock_spinning())
> > =A0			console_unlock();
> > =A0		preempt_enable();
> > -	}
> > =A0
> > -	if (pending_output)
> > +		wake_up_interruptible(&log_wait);
> > +	} else {
> > =A0		wake_up_klogd();
> > +	}
> > =A0	return printed_len;
> > =A0}
> > =A0EXPORT_SYMBOL(vprintk_emit);
> > ---

Qian Cai, any chance you can test that patch?

	-ss

