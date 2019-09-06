Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_2 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D3EBEC00307
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 21:17:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7449A2070C
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 21:17:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="lxuHvaTg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7449A2070C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C483C6B0005; Fri,  6 Sep 2019 17:17:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BF90B6B0006; Fri,  6 Sep 2019 17:17:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AE77D6B0007; Fri,  6 Sep 2019 17:17:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0102.hostedemail.com [216.40.44.102])
	by kanga.kvack.org (Postfix) with ESMTP id 86B7F6B0005
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 17:17:36 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 3D2B1180AD7C3
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 21:17:36 +0000 (UTC)
X-FDA: 75905757312.30.arm22_5f6e23c7e5a3f
X-HE-Tag: arm22_5f6e23c7e5a3f
X-Filterd-Recvd-Size: 5064
Received: from mail-qt1-f195.google.com (mail-qt1-f195.google.com [209.85.160.195])
	by imf36.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 21:17:35 +0000 (UTC)
Received: by mail-qt1-f195.google.com with SMTP id k10so8860969qth.2
        for <linux-mm@kvack.org>; Fri, 06 Sep 2019 14:17:35 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=KH2KM3AxaNxDfikJW3s2OI5HLlEQIpgR2HO2RNdIwJQ=;
        b=lxuHvaTgGzySasvfmE+zrfBd04thDMbIuR5Ckmjnj0FASAFn3jzKRQkkMniznIHGuu
         HnvEB7JQQCYNEFYZcarpvD2SN6lVyaZMk3/7+08Bneq+FJcf21D2d85fkp3qc2eRI8Nv
         CS6bgUREEMFD5bcPzZKrzqRRoZwjMHTHGH6C5acZA0DNK6933vsozwjNvo4F6K6nlbD/
         ozB4KgdnDvHu+o6VfENxQTvLiXXfdhojPqmes3QqFXmfjzNFOOViIB3llNkhDWnEf0qJ
         EE3R4b0NMI4faEF6LHZjCG2cCCATP/GcjlWYmiIVLOlufKCGvpIVx0XybdceTvGBpLWr
         1Itg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:cc:date:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=KH2KM3AxaNxDfikJW3s2OI5HLlEQIpgR2HO2RNdIwJQ=;
        b=ZGUENu2swmoYcPEcFQB4oN5/j75XTHVK/ze5X3f67JTRC707S4FfClI2YNxy9U02AK
         +KOOiWJG7v0Z1tgq+E4HlqHabSehiLnOn3whll+DP9Ju94488gvwrQ0fJAkkdhBrBBAV
         3g4aWUA+KERSvVPjKIzD+LQ1y6HGaIC/Q62oEHzrEISSxC68tuhLZOg5JuHaG1CVvWvs
         Zi5Q4SDN2Ea6rhf8HCBkpUgdFsTb3r5VcTqABUZ4tz5zDmxjRb/0XzBgyHvKijVEzfyt
         JHVVuqVTcjXidKLdYJJLKHNVefJ3dfqX0p0i3AJelHgL1YT3xHaNQqNte+kvxwcvRtQe
         bAQA==
X-Gm-Message-State: APjAAAUMEgwuToZhZcdIPR23aBT2IooQ9HibYzLuJEMIkY38zTYxs0wm
	AA/aGXTBn8+eWZpTHnNL+uU9Wg==
X-Google-Smtp-Source: APXvYqykWMJGC4WBJ7KYNk5n5eG2BjjJPxU8wawDh2GhocFTjSs4UJhyG5sFCP6hwBG0GPPCx3q5YQ==
X-Received: by 2002:ac8:2d2c:: with SMTP id n41mr11412578qta.335.1567804654971;
        Fri, 06 Sep 2019 14:17:34 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id x33sm1049112qtd.79.2019.09.06.14.17.33
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Sep 2019 14:17:34 -0700 (PDT)
Message-ID: <1567804651.5576.114.camel@lca.pw>
Subject: Re: [PATCH] net/skbuff: silence warnings under memory pressure
From: Qian Cai <cai@lca.pw>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Petr Mladek <pmladek@suse.com>, 
 Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Michal Hocko
 <mhocko@kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>, 
 davem@davemloft.net, netdev@vger.kernel.org, linux-mm@kvack.org, 
 linux-kernel@vger.kernel.org
Date: Fri, 06 Sep 2019 17:17:31 -0400
In-Reply-To: <20190906043224.GA18163@jagdpanzerIV>
References: <20190904061501.GB3838@dhcp22.suse.cz>
	 <20190904064144.GA5487@jagdpanzerIV> <20190904065455.GE3838@dhcp22.suse.cz>
	 <20190904071911.GB11968@jagdpanzerIV> <20190904074312.GA25744@jagdpanzerIV>
	 <1567599263.5576.72.camel@lca.pw>
	 <20190904144850.GA8296@tigerII.localdomain>
	 <1567629737.5576.87.camel@lca.pw> <20190905113208.GA521@jagdpanzerIV>
	 <1567699393.5576.96.camel@lca.pw> <20190906043224.GA18163@jagdpanzerIV>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2019-09-06 at 13:32 +0900, Sergey Senozhatsky wrote:
> On (09/05/19 12:03), Qian Cai wrote:
> > > ---
> > > diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
> > > index cd51aa7d08a9..89cb47882254 100644
> > > --- a/kernel/printk/printk.c
> > > +++ b/kernel/printk/printk.c
> > > @@ -2027,8 +2027,11 @@ asmlinkage int vprintk_emit(int facility, in=
t level,
> > > =C2=A0	pending_output =3D (curr_log_seq !=3D log_next_seq);
> > > =C2=A0	logbuf_unlock_irqrestore(flags);
> > > =C2=A0
> > > +	if (!pending_output)
> > > +		return printed_len;
> > > +
> > > =C2=A0	/* If called from the scheduler, we can not call up(). */
> > > -	if (!in_sched && pending_output) {
> > > +	if (!in_sched) {
> > > =C2=A0		/*
> > > =C2=A0		=C2=A0* Disable preemption to avoid being preempted while h=
olding
> > > =C2=A0		=C2=A0* console_sem which would prevent anyone from printin=
g to
> > > @@ -2043,10 +2046,11 @@ asmlinkage int vprintk_emit(int facility, i=
nt level,
> > > =C2=A0		if (console_trylock_spinning())
> > > =C2=A0			console_unlock();
> > > =C2=A0		preempt_enable();
> > > -	}
> > > =C2=A0
> > > -	if (pending_output)
> > > +		wake_up_interruptible(&log_wait);
> > > +	} else {
> > > =C2=A0		wake_up_klogd();
> > > +	}
> > > =C2=A0	return printed_len;
> > > =C2=A0}
> > > =C2=A0EXPORT_SYMBOL(vprintk_emit);
> > > ---
>=20
> Qian Cai, any chance you can test that patch?

So far as good, but it is hard to tell if this really nail the issue down=
. I'll
leave it running over the weekend and report back if it occurs again.

