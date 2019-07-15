Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2BA61C76191
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 15:15:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E218F2054F
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 15:15:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="O8dlhQ7t"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E218F2054F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 773826B000A; Mon, 15 Jul 2019 11:15:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 725A56B0010; Mon, 15 Jul 2019 11:15:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6394C6B0266; Mon, 15 Jul 2019 11:15:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 43DE36B000A
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 11:15:09 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id e103so10041818ote.2
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 08:15:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=VqjufVPoXvgJvARCtCBUh9v6bqMYapirXw3cBlnyEIs=;
        b=SGvFGv15G7B1FRmc9i3wUSjl/qtBtNKVJH/ChdsM7i955fvI4m3/pzEuLSSMR0hHa7
         acrZY6y6yPpwk8kpJ2ZqgFib/gnamHH7jnzoPjKRCs8dH+9J1MWXYM0Vltn0ZceQTmss
         6cxEGnTsXcGcSQj2SjB9SRlf5XAMgwXfQSdFkEaitIHsZneY2vAtsvZZehWBN6r8WaxE
         x0KTEGG6QWx1X10bMftzTzGALwioTmChfdcNyQAzpVUt3/41lr0Rrz0ASWWoLBWl7gov
         hiiE0qz/I8/EYKqCvFHzhDS2Ik7LL6dF2ZyatHNuATdaZREkgRGnDCubafcpTRzEc5jc
         6FbQ==
X-Gm-Message-State: APjAAAXP0yIBJeMtRvSnvNTXNyyA7PBxrlBZAZWEB1/msX5Qmhrd6dBU
	g94oy3FmwYA//iNqi+e9ljgE77Aq57ag1wEDNdMRLJce3WgWvEVJz0i43HPwlhGodCTNGdIVVpV
	y8ENFG/e8aZXK8oi/YgkEWHm7GFvvZpU1ULvBvcR1E1l2WRahGEfys7TVPD0RUleiiQ==
X-Received: by 2002:aca:af06:: with SMTP id y6mr13131921oie.137.1563203708797;
        Mon, 15 Jul 2019 08:15:08 -0700 (PDT)
X-Received: by 2002:aca:af06:: with SMTP id y6mr13131871oie.137.1563203707893;
        Mon, 15 Jul 2019 08:15:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563203707; cv=none;
        d=google.com; s=arc-20160816;
        b=g87jJywOV5RfUa0axw3VtcNRYPNOvS1P/gZIhUOc376KRWKTnXLX1mikcvqrmFS0Uh
         6FFEKTyhe3gCTqrApAqY1sD2RU06TjC1Dc1veiHn/Cj/zG3Jwp98ZufWtYaXgJRHl3jU
         4BzgDyozgNfpmkNHu3ZrwVBiuj3nZbSltmbrCm3ZeHba0ND9ntmsAVJo5t4eC0WQoNLB
         hCfHxlzWyVRjaZInbcDdfurTsKq7GcRWzNT9yPSiRNaLDixDK/xR4DzrQ6F1PC2FX2dK
         ez40babgxYC7xefYeYPQ7M/F99zNo4UU7fSos91oPwLmULe8QXDnwVMw8NQ3Y2y4MF1+
         hEmw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=VqjufVPoXvgJvARCtCBUh9v6bqMYapirXw3cBlnyEIs=;
        b=FDQyPl0+aRYNgCLaqFyr/+vPiHMMKJDy8EjbMXUiBYFg70cMLtRTTXpT9nDO8BXS9k
         wIWdBHX4xde20lSXRZJ4jPKWFglgEBisNXPFStb4TW2NNL97zS7gN/01CnVeuq4IYiqR
         xaj7C32bks36b4lczx7oXOdLefHFM2KdLrJ+QBQ3jmh7fPNz34b9quuBZ8xxwH85DdAe
         AZVjB8iY3OMQKR/N1Nvbrzds5C+rPlnaghJKFG8vtfc6/Q79VyKTc/OA/yNmP9MGMRpE
         prHbcEJVD83TDxcD3RIS3WvXAJNmYu1A0CG4fkGziKQOqddShYQnxMr/Ah/WGZO97oZQ
         MkYw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=O8dlhQ7t;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n7sor9202427otn.15.2019.07.15.08.15.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 15 Jul 2019 08:15:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=O8dlhQ7t;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=VqjufVPoXvgJvARCtCBUh9v6bqMYapirXw3cBlnyEIs=;
        b=O8dlhQ7tEwCGSNNRtDiyTDb9IWXGI4eiN1ELr1nGeIhobJqOcrFuahArn7YqD+HTvV
         32n1hIUTFBgkn5VPXUIM5Vaz+lyxkXQ0e0JGgXBjKL3trWKM5k4L5n+u+vgibvAcIUva
         dDvIdZYFueg88PuarcxCrfwwHobkjPL5s0W7JTkfRXOV9+880H2F6VvilMljv/vZ/ZEG
         kn9nvqVCDtelv7ArEeZ8Qmnrn4y3ZI966n+ZBJNpXW5qkh6PE2uEsI5Vw8CInGEh7bLP
         5oco2zwc3rYBesv+lffCkdb4eC5fzpeKJ+/3ySKEtZ2Kvk2pvaU1FDLzJc+TpfO00ww9
         kYrQ==
X-Google-Smtp-Source: APXvYqxb+9cSzZ2YZwM8qbkpbdnL6k33GARlIs2Kr7cuoB90km3/7ggBT9ro2njCwJpou04Vmgesx175RQCsD8JmyQ4=
X-Received: by 2002:a9d:5e11:: with SMTP id d17mr142706oti.50.1563203707690;
 Mon, 15 Jul 2019 08:15:07 -0700 (PDT)
MIME-Version: 1.0
References: <20190712120213.2825-1-lpf.vector@gmail.com> <20190712120213.2825-3-lpf.vector@gmail.com>
 <20190712134955.GV32320@bombadil.infradead.org> <CAD7_sbEoGRUOJdcHnfUTzP7GfUhCdhfo8uBpUFZ9HGwS36VkSg@mail.gmail.com>
 <20190715142754.pw55g4b2l6lzoznn@pc636>
In-Reply-To: <20190715142754.pw55g4b2l6lzoznn@pc636>
From: Pengfei Li <lpf.vector@gmail.com>
Date: Mon, 15 Jul 2019 23:14:56 +0800
Message-ID: <CAD7_sbH9_7DWekJNpfLVjv8Z+JZWH8RK7JiUXM=LP_sMZud6mw@mail.gmail.com>
Subject: Re: [PATCH v4 2/2] mm/vmalloc.c: Modify struct vmap_area to reduce
 its size
To: Uladzislau Rezki <urezki@gmail.com>
Cc: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, rpenyaev@suse.de, 
	peterz@infradead.org, guro@fb.com, rick.p.edgecombe@intel.com, 
	rppt@linux.ibm.com, aryabinin@virtuozzo.com, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, Vlad

Thanks for the comments form you and Matthew, now I am sure
v3 is enough.

I will follow the next version of your "mm/vmalloc: do not
keep unpurged areas in the busy tree".

Thanks again for your patience with me!

--
Pengfei

