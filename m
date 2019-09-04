Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0F2BEC3A5A8
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 06:41:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C860022CF5
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 06:41:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="FjCcM5Nc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C860022CF5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6576F6B0007; Wed,  4 Sep 2019 02:41:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6086F6B000A; Wed,  4 Sep 2019 02:41:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 51EFD6B000C; Wed,  4 Sep 2019 02:41:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0124.hostedemail.com [216.40.44.124])
	by kanga.kvack.org (Postfix) with ESMTP id 2FF776B0007
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 02:41:51 -0400 (EDT)
Received: from smtpin06.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id C0A75181AC9B6
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 06:41:50 +0000 (UTC)
X-FDA: 75896292780.06.hill22_2d267302fd627
X-HE-Tag: hill22_2d267302fd627
X-Filterd-Recvd-Size: 4878
Received: from mail-pg1-f196.google.com (mail-pg1-f196.google.com [209.85.215.196])
	by imf07.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 06:41:50 +0000 (UTC)
Received: by mail-pg1-f196.google.com with SMTP id i18so10664383pgl.11
        for <linux-mm@kvack.org>; Tue, 03 Sep 2019 23:41:50 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=DMpkUZoYpQuFlQy5IOlVsmVJ1SynRY2j23KVkYnZyyw=;
        b=FjCcM5NcsALyToL+/efgvC10cKWuqAB0RrY/JdhE1rrAavMTWUVT2Va1pxl4+6dfjc
         ATNamgIRbZdeqT26YDOWRLRksxuy2GgYbX0gZQwfAaIBWshGqhVn5qlLbphca4ajsMqJ
         rxOd4uQtu0aFOsIKM8ORWHN/VqnLM7rSY0+Ck0XmrE+7MusNB16oYMpS3HAASXXerExy
         IENPoRF8Yd8lTFWd09ip1MiqKXWHnNTfTp/WKFt45OYwSc8soXmjAiB99WLWyxVUWfiT
         dZ4rxmssPdThUID22OHy0Gr3E2X7mWEfm+4BEBmJ2moopZKpSbKYBZcr3IJ56rPFWe73
         X/sg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:content-transfer-encoding
         :in-reply-to:user-agent;
        bh=DMpkUZoYpQuFlQy5IOlVsmVJ1SynRY2j23KVkYnZyyw=;
        b=WaJcA1t1zJJH4FRFoYv9U7/1uL8AGbER0OL/uqiuvqm9h0KaDJqW4DSx/vt+UZ1GBq
         DRX+JnECPXscCct5jR+uABHHCcvGzadHNiRTZHQibaPWkHeOpDJdbSexJZsFyCBNTrjf
         C8s3JLOIEUqoIR9+h7AutodLYDD0Wt7nkt6U2INAlLlrDTF8dTdysKPwL/nVeX50Q1bn
         fp48uVmJjxx9gJVVIqouGI1vNG+Db6KTESRqrWx/TkFiflBAKfk9CQzaaKbpJf6fWCxN
         QVFYKe0s9Feyw2lUuM4BjxYbmlhNuzDfLEQndV1sYhGNW9/Tx+aPfVkqs+L754ZzWWAS
         0WcA==
X-Gm-Message-State: APjAAAX2lVoP4BNyYE7m/E2Llybq6UbwBjvuR6lhy1ACHWbHxu1tcJpB
	qW7kBRbCA4pR5VbOs6ejSyg=
X-Google-Smtp-Source: APXvYqyfXC8L7rj1syVBr+7repNVVgjAKOV7Ku9+6MkbERA0AwGQUvVilgxRxmnY29sZeht3XH0xuQ==
X-Received: by 2002:a62:65c7:: with SMTP id z190mr45930199pfb.9.1567579309211;
        Tue, 03 Sep 2019 23:41:49 -0700 (PDT)
Received: from localhost ([175.223.23.37])
        by smtp.gmail.com with ESMTPSA id e189sm23617073pgc.15.2019.09.03.23.41.47
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 03 Sep 2019 23:41:48 -0700 (PDT)
Date: Wed, 4 Sep 2019 15:41:44 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: Qian Cai <cai@lca.pw>, Eric Dumazet <eric.dumazet@gmail.com>,
	davem@davemloft.net, netdev@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>,
	Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
	Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] net/skbuff: silence warnings under memory pressure
Message-ID: <20190904064144.GA5487@jagdpanzerIV>
References: <1567177025-11016-1-git-send-email-cai@lca.pw>
 <6109dab4-4061-8fee-96ac-320adf94e130@gmail.com>
 <1567178728.5576.32.camel@lca.pw>
 <229ebc3b-1c7e-474f-36f9-0fa603b889fb@gmail.com>
 <20190903132231.GC18939@dhcp22.suse.cz>
 <1567525342.5576.60.camel@lca.pw>
 <20190903185305.GA14028@dhcp22.suse.cz>
 <1567546948.5576.68.camel@lca.pw>
 <20190904061501.GB3838@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20190904061501.GB3838@dhcp22.suse.cz>
User-Agent: Mutt/1.12.1 (2019-06-15)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On (09/04/19 08:15), Michal Hocko wrote:
> > If you look at the original report, the failed allocation dump_stack(=
) is,
> >=20
> > =A0<IRQ>
> > =A0warn_alloc.cold.43+0x8a/0x148
> > =A0__alloc_pages_nodemask+0x1a5c/0x1bb0
> > =A0alloc_pages_current+0x9c/0x110
> > =A0allocate_slab+0x34a/0x11f0
> > =A0new_slab+0x46/0x70
> > =A0___slab_alloc+0x604/0x950
> > =A0__slab_alloc+0x12/0x20
> > =A0kmem_cache_alloc+0x32a/0x400
> > =A0__build_skb+0x23/0x60
> > =A0build_skb+0x1a/0xb0
> > =A0igb_clean_rx_irq+0xafc/0x1010 [igb]
> > =A0igb_poll+0x4bb/0xe30 [igb]
> > =A0net_rx_action+0x244/0x7a0
> > =A0__do_softirq+0x1a0/0x60a
> > =A0irq_exit+0xb5/0xd0
> > =A0do_IRQ+0x81/0x170
> > =A0common_interrupt+0xf/0xf
> > =A0</IRQ>
> >=20
> > Since it has no __GFP_NOWARN to begin with, it will call,

I think that DEFAULT_RATELIMIT_INTERVAL and DEFAULT_RATELIMIT_BURST
are good when we ratelimit just a single printk() call, so the ratelimit
is "max 10 kernel log lines in 5 seconds".

But the thing is different in case of dump_stack() + show_mem() +
some other output. Because now we ratelimit not a single printk() line,
but hundreds of them. The ratelimit becomes - 10 * $$$ lines in 5 seconds
(IOW, now we talk about thousands of lines). Significantly more permissiv=
e
ratelimiting.

	-ss

