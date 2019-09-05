Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_2 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F038BC43140
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 16:03:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 70B7C206DE
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 16:03:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="srJv115I"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 70B7C206DE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4E95D6B0266; Thu,  5 Sep 2019 12:03:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 475686B0272; Thu,  5 Sep 2019 12:03:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 361226B0273; Thu,  5 Sep 2019 12:03:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0153.hostedemail.com [216.40.44.153])
	by kanga.kvack.org (Postfix) with ESMTP id 0EA656B0266
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 12:03:18 -0400 (EDT)
Received: from smtpin10.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id AF2CF3D09
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 16:03:17 +0000 (UTC)
X-FDA: 75901336434.10.books18_39c44ac608413
X-HE-Tag: books18_39c44ac608413
X-Filterd-Recvd-Size: 6576
Received: from mail-qk1-f195.google.com (mail-qk1-f195.google.com [209.85.222.195])
	by imf31.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 16:03:16 +0000 (UTC)
Received: by mail-qk1-f195.google.com with SMTP id z67so2576508qkb.12
        for <linux-mm@kvack.org>; Thu, 05 Sep 2019 09:03:16 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=ARdJcCTl1yvQzK9KFLXbOHVAx1PUXY0NiCi5/Ki6zRU=;
        b=srJv115Is3P1U681GfWFzKE7i0Oyph2BEelIw9RQDw4Dln8DnSnc88Tiza/8Et1j36
         3OEPDoDLDWMDlfCdb9bby1HL0sCkqqlMEzLjdLZh8tpE4MRAyc99rr6a/hlqrGjxx2m/
         KaXYbChyJ7NwsgcfkNrN3Qr78Nqmzy3gFHjtA/dT2vDsmG502OtHEQGe9og31RxU+rJI
         tS2S5wrJxZz/0XgpVwuQsY+3fY3ghD8rqtVwNRBRhNdj8C68YXgGsHZ8G7KJlj71db1s
         oKW1//ih086eB7lxRtuLID5QBMTp+6gknvrXt5Gk+261Ch7f+flyF9712noDYKC6CGOJ
         B6fw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:cc:date:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=ARdJcCTl1yvQzK9KFLXbOHVAx1PUXY0NiCi5/Ki6zRU=;
        b=nOZTD2eADwqJkTaYf/DrjmXm/fUq4j0yrBe8W+Gvm8b2TGYsBtiT2re6MERfZy3jHr
         obtshXYvWdAT6cvDW4jYwEirBDOn1FVyZm6XploldaEPvn7Ibd91u2OIVQelQKBqzzPy
         o7FCYYSKmORa5hBPLWZHbXo73v0lsvLSQ+zmWsI/vRLZsJKfJnZKmghjgjYjYT6wGXve
         C4X/F4+7oDqct8aDd+pJ/t/cvG8LtTd/POh+OFcsbW2MO7uKh0DTMVOru0GPueCSWvNU
         GSIlHT7uOxkyw3UvcJFsk7SIk/IJ7CNvdPSqXFbLCyVRxCR158W4WjvhZqmLC4OOA9HP
         JjKg==
X-Gm-Message-State: APjAAAXWxwlXN8GQvtvZhe43IgmHWq91cAsPOGbP0E9h0dqQiRi3BJb1
	osbRXOgne1bDnGTvUsQP7Sipiw==
X-Google-Smtp-Source: APXvYqwz5Ih1cBni0LNoxZQih9BYTQsib4BYdkphk3cPMd+iJT2Lx0QIEW7e93FPRyn81x6iF6WcRA==
X-Received: by 2002:ae9:e50f:: with SMTP id w15mr3683737qkf.129.1567699396301;
        Thu, 05 Sep 2019 09:03:16 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id p126sm1346062qkc.84.2019.09.05.09.03.14
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Sep 2019 09:03:15 -0700 (PDT)
Message-ID: <1567699393.5576.96.camel@lca.pw>
Subject: Re: [PATCH] net/skbuff: silence warnings under memory pressure
From: Qian Cai <cai@lca.pw>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Steven Rostedt
	 <rostedt@goodmis.org>, Petr Mladek <pmladek@suse.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Michal Hocko
 <mhocko@kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>,
 davem@davemloft.net,  netdev@vger.kernel.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
Date: Thu, 05 Sep 2019 12:03:13 -0400
In-Reply-To: <20190905113208.GA521@jagdpanzerIV>
References: <20190903185305.GA14028@dhcp22.suse.cz>
	 <1567546948.5576.68.camel@lca.pw> <20190904061501.GB3838@dhcp22.suse.cz>
	 <20190904064144.GA5487@jagdpanzerIV> <20190904065455.GE3838@dhcp22.suse.cz>
	 <20190904071911.GB11968@jagdpanzerIV> <20190904074312.GA25744@jagdpanzerIV>
	 <1567599263.5576.72.camel@lca.pw>
	 <20190904144850.GA8296@tigerII.localdomain>
	 <1567629737.5576.87.camel@lca.pw> <20190905113208.GA521@jagdpanzerIV>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2019-09-05 at 20:32 +0900, Sergey Senozhatsky wrote:
> On (09/04/19 16:42), Qian Cai wrote:
> > > Let me think more.
> >=20
> > To summary, those look to me are all good long-term improvement that =
would
> > reduce the likelihood of this kind of livelock in general especially =
for
> > other
> > unknown allocations that happen while processing softirqs, but it is =
still
> > up to
> > the air if it fixes it 100% in all situations as printk() is going to=
 take
> > more
> > time
>=20
> Well. So. I guess that we don't need irq_work most of the time.
>=20
> We need to queue irq_work for "safe" wake_up_interruptible(), when we
> know that we can deadlock in scheduler. IOW, only when we are invoked
> from the scheduler. Scheduler has printk_deferred(), which tells printk=
()
> that it cannot do wake_up_interruptible(). Otherwise we can just use
> normal wake_up_process() and don't need that irq_work->wake_up_interrup=
tible()
> indirection. The parts of the scheduler, which by mistake call plain pr=
intk()
> from under pi_lock or rq_lock have chances to deadlock anyway and shoul=
d
> be switched to printk_deferred().
>=20
> I think we can queue significantly much less irq_work-s from printk().
>=20
> Petr, Steven, what do you think?
>=20
> Something like this. Call wake_up_interruptible(), switch to
> wake_up_klogd() only when called from sched code.
>=20
> ---
> diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
> index cd51aa7d08a9..89cb47882254 100644
> --- a/kernel/printk/printk.c
> +++ b/kernel/printk/printk.c
> @@ -2027,8 +2027,11 @@ asmlinkage int vprintk_emit(int facility, int le=
vel,
> =C2=A0	pending_output =3D (curr_log_seq !=3D log_next_seq);
> =C2=A0	logbuf_unlock_irqrestore(flags);
> =C2=A0
> +	if (!pending_output)
> +		return printed_len;
> +
> =C2=A0	/* If called from the scheduler, we can not call up(). */
> -	if (!in_sched && pending_output) {
> +	if (!in_sched) {
> =C2=A0		/*
> =C2=A0		=C2=A0* Disable preemption to avoid being preempted while holdi=
ng
> =C2=A0		=C2=A0* console_sem which would prevent anyone from printing to
> @@ -2043,10 +2046,11 @@ asmlinkage int vprintk_emit(int facility, int l=
evel,
> =C2=A0		if (console_trylock_spinning())
> =C2=A0			console_unlock();
> =C2=A0		preempt_enable();
> -	}
> =C2=A0
> -	if (pending_output)
> +		wake_up_interruptible(&log_wait);
> +	} else {
> =C2=A0		wake_up_klogd();
> +	}
> =C2=A0	return printed_len;
> =C2=A0}
> =C2=A0EXPORT_SYMBOL(vprintk_emit);
> ---
>=20
> > and could deal with console hardware that involve irq_exit() anyway.
>=20
> printk->console_driver->write() does not involve irq.

Hmm, from the article,

https://en.wikipedia.org/wiki/Universal_asynchronous_receiver-transmitter

"Since transmission of a single or multiple characters may take a long ti=
me
relative to CPU speeds, a UART maintains a flag showing busy status so th=
at the
host system knows if there is at least one character in the transmit buff=
er or
shift register; "ready for next character(s)" may also be signaled with a=
n
interrupt."

