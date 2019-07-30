Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 211B7C433FF
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 08:11:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C628920679
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 08:11:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="rxPQWpq1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C628920679
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5FDA38E0006; Tue, 30 Jul 2019 04:11:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5AED28E0001; Tue, 30 Jul 2019 04:11:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 49D5C8E0006; Tue, 30 Jul 2019 04:11:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2AF348E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 04:11:38 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id x17so70120018iog.8
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 01:11:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=lqG3hFLeHki6KlZNi6gozV3r9j/aZGFzc0fdJeJSVQ8=;
        b=fimCBHYvj4ySvzwaQ1LBFifOyheTdBYYG0NRDe0l5fMsw9OukjTQENu3KkS5hNdHzJ
         5sWxthf3e+cYFayQSDgQdG/MsJh75ThdblIyTOraBLkvJ0PAzWvuZAUvaluhjCo2u3Jq
         sxQp5nRTmKenC139v15Vc9aMBVOHBNUFyzjElmCtsTpMEg8bp576OrXORobqnhtPywEr
         2OaNtMYFhNejzz35jh1AkCXHBXzZ9MLB6elOI1uNsBmfaGGNKYO2coiVInciyFdSll61
         r1Bq7lipJhmZpwn8uv0dHKOsGTWljxhr7e3qa1zCg/cOe/sUspfLbf5SekA5eCwtqgsA
         /Itw==
X-Gm-Message-State: APjAAAWV6qwKydxq2il0zI5hZtbYvis/bs53ge5FCFvyTFwcoairtZ44
	eHR0m1dmc1x8l9SRaLg5zVyiCp6ECyRLpJdbC8GDWx6+hbJ53bFNABG1dHjtA6X9PsmUOkR+pDc
	9olHy0HWTmkBqHCal89Lnc5OWu2VWuAdf4Oj9VF9Cv4vBGsJJgfrCfAvIdTzSd/5+4A==
X-Received: by 2002:a5d:884d:: with SMTP id t13mr26395231ios.233.1564474297895;
        Tue, 30 Jul 2019 01:11:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwkYHPhIUy+vyn9ZqwQ/EwwNw4M+EufySDl5PbTEN0EifPObZ4ayvGh7d/QwI+Mj681qKuW
X-Received: by 2002:a5d:884d:: with SMTP id t13mr26395186ios.233.1564474297237;
        Tue, 30 Jul 2019 01:11:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564474297; cv=none;
        d=google.com; s=arc-20160816;
        b=yK5gaJxt7Kd7YVkkhTku8Qr8godVvwabRclNyxpda7Mk2yiboqukFrbzF/hi1tfFB0
         323vGpP+USVQLcLcqaZ8AGBNfyRlj8wrxfPftEiHVlfLVWctRx+gHieYPyEq080COf7T
         fQPVrZ3E1R9kffH1hSyjfzqzE9j4Zco7GCgBOCoDxr4zdt6pB6iVshy9K9dcKBTmAv1+
         yRGvqhwzhk+EN+hxPQ1vCNkbGCUVWJ4IEU18700JV9EhibNJRjMMDMKCrsKfO6g9UcHD
         c/p5lFNgI4nN4CHEBQ6cA6AOHWSiF03aWZYKy/ZduzxuFG7tgHutpbdIkhECykrR0gZs
         W1Ng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=lqG3hFLeHki6KlZNi6gozV3r9j/aZGFzc0fdJeJSVQ8=;
        b=lfjZte4Y0+R3CZK/B4pVbifoswJo3tjP7JE4Waif6XNUYB4gTMT1h38dhNk5WjLrmL
         ySOuNFoejOefJErNrMKjIuN8jXpdS6txtigHhiRUFx2D1v8Lm/crESMYUewRUFWljL6s
         C5YltK3kzCnHrQYS3EurE9AtmarQ7Je5uTdLg6sdluNEF/8dwE3XqtFjuiy90dXHA9Hr
         o23vgDYSTimNKSH25QD1sy22vFgnwZziYogaUi/u94fJ7vsaJ/CAlridTN6YttYOOWzD
         xHEFyPBY9d2phlpIIg8r0vZVyJxiFN6agyWxt+S79aaUtc8ONTjreoTW5pBsNNL7gGFn
         3Ayw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=rxPQWpq1;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id f125si83143415jaf.28.2019.07.30.01.11.37
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 30 Jul 2019 01:11:37 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=rxPQWpq1;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=lqG3hFLeHki6KlZNi6gozV3r9j/aZGFzc0fdJeJSVQ8=; b=rxPQWpq1LSCp6jnJK/v6L8dDR
	SkDfaijqdixP9Xmv7Riil22otsXN/ASK8qonDt1a1WnmCwcZFzOTSgAbcTOGAJ/q0YjwnjWVOAN4J
	aQItm82TxPGN0WVkOpGnPl0gdgabuNsroTPsKVPIGkdefwHCL43Mywg9MUHzTccgCcvBp/fp4Tg4Y
	yb89urip9Lk2Qp+GyN86WBbHtK6btdzda9xLD4lNnQyxBqeCeVecQ6vHWKegBrGJD6R9nuf6igjct
	DKTn0E8lGqly9r6I8JgKv/fXzc1I4FI5mzOw56W98AiFk6F9PGvDdRWJkXs8fM1iS6LW9Cqh9J+Sr
	mV+nqySTw==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hsNEB-0005KX-Sn; Tue, 30 Jul 2019 08:11:24 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id A37B120D27EAA; Tue, 30 Jul 2019 10:11:22 +0200 (CEST)
Date: Tue, 30 Jul 2019 10:11:22 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Suren Baghdasaryan <surenb@google.com>
Cc: mingo@redhat.com, lizefan@huawei.com, hannes@cmpxchg.org,
	axboe@kernel.dk, dennis@kernel.org, dennisszhou@gmail.com,
	akpm@linux-foundation.org, linux-mm@kvack.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@android.com, Nick Kralevich <nnk@google.com>,
	Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 1/1] psi: do not require setsched permission from the
 trigger creator
Message-ID: <20190730081122.GH31381@hirez.programming.kicks-ass.net>
References: <20190730013310.162367-1-surenb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190730013310.162367-1-surenb@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 29, 2019 at 06:33:10PM -0700, Suren Baghdasaryan wrote:
> When a process creates a new trigger by writing into /proc/pressure/*
> files, permissions to write such a file should be used to determine whether
> the process is allowed to do so or not. Current implementation would also
> require such a process to have setsched capability. Setting of psi trigger
> thread's scheduling policy is an implementation detail and should not be
> exposed to the user level. Remove the permission check by using _nocheck
> version of the function.
> 
> Suggested-by: Nick Kralevich <nnk@google.com>
> Signed-off-by: Suren Baghdasaryan <surenb@google.com>
> ---
>  kernel/sched/psi.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/kernel/sched/psi.c b/kernel/sched/psi.c
> index 7acc632c3b82..ed9a1d573cb1 100644
> --- a/kernel/sched/psi.c
> +++ b/kernel/sched/psi.c
> @@ -1061,7 +1061,7 @@ struct psi_trigger *psi_trigger_create(struct psi_group *group,
>  			mutex_unlock(&group->trigger_lock);
>  			return ERR_CAST(kworker);
>  		}
> -		sched_setscheduler(kworker->task, SCHED_FIFO, &param);
> +		sched_setscheduler_nocheck(kworker->task, SCHED_FIFO, &param);

ARGGH, wtf is there a FIFO-99!! thread here at all !?

>  		kthread_init_delayed_work(&group->poll_work,
>  				psi_poll_work);
>  		rcu_assign_pointer(group->poll_kworker, kworker);
> -- 
> 2.22.0.709.g102302147b-goog
> 

