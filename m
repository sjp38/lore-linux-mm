Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4A077C3A5A7
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 14:49:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0AF3A208E4
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 14:49:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="WqjoJjQ8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0AF3A208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 90B6D6B0003; Wed,  4 Sep 2019 10:48:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8BADB6B0006; Wed,  4 Sep 2019 10:48:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7AA556B0007; Wed,  4 Sep 2019 10:48:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0175.hostedemail.com [216.40.44.175])
	by kanga.kvack.org (Postfix) with ESMTP id 581696B0003
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 10:48:57 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id E03D0824CA30
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 14:48:56 +0000 (UTC)
X-FDA: 75897520272.07.straw60_4e03b63014153
X-HE-Tag: straw60_4e03b63014153
X-Filterd-Recvd-Size: 5791
Received: from mail-pg1-f196.google.com (mail-pg1-f196.google.com [209.85.215.196])
	by imf29.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 14:48:55 +0000 (UTC)
Received: by mail-pg1-f196.google.com with SMTP id u17so11374098pgi.6
        for <linux-mm@kvack.org>; Wed, 04 Sep 2019 07:48:55 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:date:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=Y0Way3KHGFmyr4IdZ55Bi63R1MS1mhVmJWvvJPi7ufE=;
        b=WqjoJjQ8S4lX609PlOBqGbYMVGDW7BSa431Cl3izLPCn2DMGQleTv8LbHmsWiS7r8y
         3JBCO4Y7rkL3QwMisIOFGqPHMRGV1eYsP2nTVd7+HwuE+3C0R0aiKGrpBfCK60fVcbX2
         he68y1N5zS8z7CyMnvMi5M+U7rBvjYxHV/cj1ewYaH+4V/YN13QxCf2oX0yCS/S5kPt5
         HDYpFbswKqkb6MfUh8lIsVrnwnSBMUUb/2Xj7bVOnd+ieTuy4ee2NK1wYGtdpo1iHMRK
         5pFsIVK7r+xOWL8aIhfOGEVEuZOWvZ6HNWXP9SlgVmFFA8hEu1/HHk4sys20eOt9tLql
         6vHw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:date:to:cc:subject:message-id:references
         :mime-version:content-disposition:content-transfer-encoding
         :in-reply-to:user-agent;
        bh=Y0Way3KHGFmyr4IdZ55Bi63R1MS1mhVmJWvvJPi7ufE=;
        b=sz2YsdmGpHCjaabubAQvnER+KFI+zBinVl/pULqu1Gec8pEtGRFb433qqSCAEkZUpQ
         LrCuwrfdUDaq06E3k3tHTO9y6uzwu3xp35wFubVVWdpMZlN+C2uf1KrhCWNz64hJhoKy
         GvcD0aEx+pHk3g0/qQGYJI2hEsDb2/vYl5baFnaoslldtiJOPtWG6kOkfUw6oT1k0KOr
         4UlVHo05v9BB7YUaP6IRD0vwLyzT8Twu6ymwdAZC2UEYgg603s9cfSOZvxNpFJpmgtib
         QRozFqG3sRkngsj2w2nhShXg3vWSesvGhCgeyMfA389RU37lPC2h64vlx/xXOKw6NF+0
         7ovw==
X-Gm-Message-State: APjAAAUo6trDuoqfLOkJ4fmtr0LQviGLB6oqHeO1zcPaep9/DbCJqsX3
	FYh+9mAic7Nqe7NHSfqARRU=
X-Google-Smtp-Source: APXvYqxW6zv9Q8MMQUyy/57EoTj5mk4de72N7EcxPzQhS0BTGdBSndFBF7RHG+eJ6QvAnkqTlGVRzA==
X-Received: by 2002:a17:90a:ac14:: with SMTP id o20mr5434986pjq.143.1567608534744;
        Wed, 04 Sep 2019 07:48:54 -0700 (PDT)
Received: from localhost ([121.137.63.184])
        by smtp.gmail.com with ESMTPSA id m4sm21145034pgs.71.2019.09.04.07.48.52
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 04 Sep 2019 07:48:53 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
X-Google-Original-From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Date: Wed, 4 Sep 2019 23:48:50 +0900
To: Qian Cai <cai@lca.pw>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>,
	Michal Hocko <mhocko@kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>,
	Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
	Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] net/skbuff: silence warnings under memory pressure
Message-ID: <20190904144850.GA8296@tigerII.localdomain>
References: <20190903132231.GC18939@dhcp22.suse.cz>
 <1567525342.5576.60.camel@lca.pw>
 <20190903185305.GA14028@dhcp22.suse.cz>
 <1567546948.5576.68.camel@lca.pw>
 <20190904061501.GB3838@dhcp22.suse.cz>
 <20190904064144.GA5487@jagdpanzerIV>
 <20190904065455.GE3838@dhcp22.suse.cz>
 <20190904071911.GB11968@jagdpanzerIV>
 <20190904074312.GA25744@jagdpanzerIV>
 <1567599263.5576.72.camel@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1567599263.5576.72.camel@lca.pw>
User-Agent: Mutt/1.12.1 (2019-06-15)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On (09/04/19 08:14), Qian Cai wrote:
> > Plus one more check - waitqueue_active(&log_wait). printk() adds
> > pending irq_work only if there is a user-space process sleeping on
> > log_wait and irq_work is not already scheduled. If the syslog is
> > active or there is noone to wakeup then we don't queue irq_work.
>=20
> Another possibility for this potential livelock is that those printk() =
from
> warn_alloc(), dump_stack() and show_mem() increase the time it needs to=
 process
> build_skb() allocation failures significantly under memory pressure. As=
 the
> result, ksoftirqd() could be rescheduled during that time via a differe=
nt CPU
> (this is a large x86 NUMA system anyway),
>=20
> [83605.577256][=A0=A0=A0C31]=A0=A0run_ksoftirqd+0x1f/0x40
> [83605.577256][=A0=A0=A0C31]=A0=A0smpboot_thread_fn+0x255/0x440
> [83605.577256][=A0=A0=A0C31]=A0=A0kthread+0x1df/0x200
> [83605.577256][=A0=A0=A0C31]=A0=A0ret_from_fork+0x35/0x40

Hum hum hum...

So I can, _probably_, think of several patches.

First, move wake_up_klogd() back to console_unlock().

Second, move `printk_pending' out of per-CPU region and make it global.
So we will have just one printk irq_work scheduled across all CPUs;
currently we have one irq_work per CPU. I think I sent a patch a long
long time ago, but we never discussed it, as far as I remember.

> In addition, those printk() will deal with console drivers or even a ne=
tworking
> console, so it is probably not unusual that it could call irq_exit()-
>__do_softirq() at one point and then this livelock.

Do you use netcon? Because this, theoretically, can open up one more
vector. netcon allocates skbs from ->write() path. We call con drivers'
->write() from printk_safe context, so should netcon skb allocation
warn we will scedule one more irq_work on that CPU to flush per-CPU
printk_safe buffer.

If this is the case, then we can stop calling console_driver() under
printk_safe. I sent a patch a while ago, but we agreed to keep the
things the way they are, fot the time being.

Let me think more.

	-ss

