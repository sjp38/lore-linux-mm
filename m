Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EE346C2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 13:35:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B353620B7C
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 13:35:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="E234jJcA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B353620B7C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4C85C6B000C; Fri,  7 Jun 2019 09:35:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 478C56B000E; Fri,  7 Jun 2019 09:35:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 367596B0266; Fri,  7 Jun 2019 09:35:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 145F56B000C
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 09:35:57 -0400 (EDT)
Received: by mail-it1-f199.google.com with SMTP id p19so1943135itm.3
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 06:35:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=lVEgFqucFox4g1IviFAgPH+wq2tolwksp9dr8CFQhYQ=;
        b=PFgIS+F0Iufz41tjnva3xi6MBfV4tMT9FXi/RIbdP1mN4HszixBT6PDB5FrTF/EO28
         1bFfcvt27K0om9qPX64UOg+8nSykt6FKcZbYora05V3U7K7ix1syHzbiZBnSM9dj6MiO
         4KHsWdypLmWYSVdHeZ0XAwmnXxjst/bBdOxJXPZeMyaj6rXtvlSb/s/UPOYiAKzbhvrE
         lxiaFKXCV36GoYyxbmG/Z1rKka5zraUMeSYQlLAkTnqzYwYBbFy8sDLjBSh2exHMRa/s
         +7/wPZiVjL5oZ+uGK4kkQCbYrnE8tewPXvIMOu9mn80PR0JtP82FoV5wL/lRbiFz4l+w
         tCcg==
X-Gm-Message-State: APjAAAVhE4C9n6f/rSm22QBLzkmoUMVv0kengUk0MNe5BxRf7LyDOBLX
	r9cYHRKG31blt+vgrIHeCMtW2RMqGukFX8usBuQfK588WOLulVW0dsZawSki2f7dKlYfhflpbaR
	KFNTYX9tIn8VKCK4gFHVLXR/fzXBROQr/Sp8waEgNlm6NYYNlqjFJ+LUFBCJJeUYvdg==
X-Received: by 2002:a5e:c00a:: with SMTP id u10mr25020163iol.24.1559914556861;
        Fri, 07 Jun 2019 06:35:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx3AA6Ir9glM8J2SPO6cET+IGC8+VV0e8+F4kIz2asRMzbueVytgwmbjonXtebGhB+U/ju2
X-Received: by 2002:a5e:c00a:: with SMTP id u10mr25020127iol.24.1559914556249;
        Fri, 07 Jun 2019 06:35:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559914556; cv=none;
        d=google.com; s=arc-20160816;
        b=ootPIoDBx0oTE30xHbaFShEhqYiLzELhYyNp9AFwpo/I1fz8KvM5aDA8Oz+xGajfuT
         qYqatEDk5kI+caMw2PEv0pgcI6Rq+jnj1ZULQ00dR5A7l+YhUfj169lJDBD2mtUOU+M4
         TvkWHveSUWVPdeF7Shf9ztRMRQeSfuPIPXiZ7UBmuZZoDUk7S2m43lD9ooGMBBkpDA7z
         3TTpSbCYNs5m0Ws+G98FG+c+zNVLph713MT5kxeJHseZSM/kD/8r+6zyk8OkVGqutUi5
         tw/g+XFYPGHSL5ds2ZP/Kc8+HaO6Facp2PkvkAcu33sZmIywMHego0/Kqq7TaI0uUizh
         BFWw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=lVEgFqucFox4g1IviFAgPH+wq2tolwksp9dr8CFQhYQ=;
        b=x1U9RPpqn7+QEguI2126U5cRlTBNI/9sV69jBIGW1czLf22+e5wB52nGaFjp4skuFS
         EIuunwDpO1FHJXedYgoMupf4MQN96sAklzhD4bFTYugy0TbRa9T0BLV/BS+WiE19hRHl
         HLAsw3p/pG/Ly1pEzaKAwKecVaqGKNdApu2CtU8peN4Rfx/sQAHH2JSlyJbXxVgYxRvP
         ncE7DT8aSmWevK9Inl7vMlbgzNm3nvB/Z6i8wd2DRJhrxfeFyiN7N7j69uRG8OhIA7Pk
         DVA1I9qoqHnN6JRsS0PgJgVi70ZiRMbU/SkXarVmg+H5qFkVrLl7FGeXmi4VJwjb7rXE
         Knfw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=E234jJcA;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id z187si1333482jab.56.2019.06.07.06.35.56
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 07 Jun 2019 06:35:56 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=E234jJcA;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=lVEgFqucFox4g1IviFAgPH+wq2tolwksp9dr8CFQhYQ=; b=E234jJcArQlGrReDPRTDlQHQw
	/51XA81tWbNBlNGxjegBAG8xYGT10JhKdGURd6yq4uCPjy6al62Aq3+i5MqZmTBQWE2Jxd9aEgq/b
	wJN1kFrziNof1cTWsCOA+Kro46LMQL8l0tTMmo20PPlvS2PC9TbtRQUqklSoDNjY5uEhSQLS9nXow
	R0foGNit83P0n3Jp6w76ssk7IkHaJl4axBNuofWSbBG9wzs4ALgYpEcy6+azMIrtkFq5rBdT76H7y
	IVGo9zhzexKE60uh1YvVJPfp2JQ2kTZPq0+6O6pfvn828eCNoKFIUwfGg9DdWWPruXIHZExArLGYS
	XtVrEgXIg==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hZF22-0001XU-1L; Fri, 07 Jun 2019 13:35:46 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id E5C8D20216EFA; Fri,  7 Jun 2019 15:35:41 +0200 (CEST)
Date: Fri, 7 Jun 2019 15:35:41 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: Qian Cai <cai@lca.pw>, akpm@linux-foundation.org, hch@lst.de,
	oleg@redhat.com, gkohli@codeaurora.org, mingo@redhat.com,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] block: fix a crash in do_task_dead()
Message-ID: <20190607133541.GJ3436@hirez.programming.kicks-ass.net>
References: <1559161526-618-1-git-send-email-cai@lca.pw>
 <20190530080358.GG2623@hirez.programming.kicks-ass.net>
 <82e88482-1b53-9423-baad-484312957e48@kernel.dk>
 <20190603123705.GB3419@hirez.programming.kicks-ass.net>
 <ddf9ee34-cd97-a62b-6e91-6b4511586339@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ddf9ee34-cd97-a62b-6e91-6b4511586339@kernel.dk>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 05, 2019 at 09:04:02AM -0600, Jens Axboe wrote:
> How about the following plan - if folks are happy with this sched patch,
> we can queue it up for 5.3. Once that is in, I'll kill the block change
> that special cases the polled task wakeup. For 5.2, we go with Oleg's
> patch for the swap case.

OK, works for me. I'll go write a proper patch.

Thanks!

