Return-Path: <SRS0=QnEd=U5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1,USER_IN_DEF_DKIM_WL autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E938FC06508
	for <linux-mm@archiver.kernel.org>; Sun, 30 Jun 2019 23:06:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7D121208C3
	for <linux-mm@archiver.kernel.org>; Sun, 30 Jun 2019 23:06:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="NclGqIAT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7D121208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DF6226B0003; Sun, 30 Jun 2019 19:06:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DB0BA8E0003; Sun, 30 Jun 2019 19:06:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C95908E0002; Sun, 30 Jun 2019 19:06:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f77.google.com (mail-ot1-f77.google.com [209.85.210.77])
	by kanga.kvack.org (Postfix) with ESMTP id 9B7716B0003
	for <linux-mm@kvack.org>; Sun, 30 Jun 2019 19:06:48 -0400 (EDT)
Received: by mail-ot1-f77.google.com with SMTP id n19so6656983ota.14
        for <linux-mm@kvack.org>; Sun, 30 Jun 2019 16:06:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=bl+8fccvQ+Vw0cb2jDFiMa7kxLSzzNYBzyYR78H/6zs=;
        b=ILF2ShCO+8n380w5gWB/CSapu9H0oemvyHjVCS2JEqUw9xxQakZBIe+iVhz/b95Ca0
         L50/AeqBOkEidyXxdssMCZtEfJUTrYxYj/3m9mYguQjIK66epxHJp7i/9AW8p4lQXqJA
         9HuUU/I9gnfC7aanVQInAejk0pZe/jTcmCcr41nJpgdDH8KpiKhF1bAdNPNYQZEttU1J
         B50FYgB6MZI1hOI84ap9Mfcw92CWY7CYffYfnp69PMwBRDBsko1uQq2G9mXfqIwS4sV0
         F919+tAv9Uf58KAgZapziSRDmrhzpHLJxjjhsXYIHy1tLGE73kRBIhlWyj7kq0v+90MX
         krQg==
X-Gm-Message-State: APjAAAWUG29QGbjjzi5bc5cybD3dv6eo0eFcvgxFwqVVvO/PKOFvD2Fx
	m3rj74/V7Vj7Zw3P/pZkXgxvKwoeHHESqPCPrw80oNlTJpI++lIRukBPhpAMgjwMNj8dgNsVbfn
	9SctBWtPNqQp4dXE9nlTfNsX70YKmroLPsPnki5K/hn2ROewu3f5/D1jftHMBk6ic9w==
X-Received: by 2002:aca:a884:: with SMTP id r126mr5243419oie.11.1561936008170;
        Sun, 30 Jun 2019 16:06:48 -0700 (PDT)
X-Received: by 2002:aca:a884:: with SMTP id r126mr5243395oie.11.1561936007361;
        Sun, 30 Jun 2019 16:06:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561936007; cv=none;
        d=google.com; s=arc-20160816;
        b=cjpaE1uhaltpxGzlsGECK49Imgqx7l16L2e+Nt9OsIGk9ZM2Iyr6Lwy1YicZpo1+hf
         eC8ZzkEvwS2kC6vpBFIxORyCwHaXcCBn36+FICb1jB7+CbGgDXnIh8g3tR3sbuUudd4c
         odnTNVTJcbnYpH9+19SbFn+aZVgR9tVnkafCbhIf3z1DvrhaoCX7GKflUbhsEvW2LDYJ
         JgFI6KJkwxrivhn7Jjr5j3EkLIkxjRujDHn4wtSV1dy9xKK2JgwiaWV5JUp0f9Rm/RAd
         U3HyMP8v1n8jIwBoZjrsCYSu3KiiDFL88ie1gBdCue85SdWIHbMUP7AHHa6FEQO9OUfx
         xqUA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=bl+8fccvQ+Vw0cb2jDFiMa7kxLSzzNYBzyYR78H/6zs=;
        b=FxUHSIb+VawN37id/sPY8aXxl6qYZVg1aghBL3DYJe/eIrEX4bsfnpHChDzp4zdf7u
         Zi4ClPBtFA0X7c7iN4W0Ct1ODwYy9zKIymenMyDHb7MPWuzs0zaVTcL+wDxQgMgQ81wt
         flbU9VvexEsq4imbTfsTvUeKTbkda6Tr1DF7KRMo7R9Vt1sZ/UkyG+w1F9w8UEOv1hIE
         rkwLPC7vbYnMOb2am/Sm2SDjKot13RGUPHbVe2WrffsFFydqoiCLLSIqAvIsdmYTYNfr
         I8ezByy7GlFdUFNCkAH4n/ACvdAUcI+NSbknAuyBPQj8hAAJ55WkX7An9WJJ2ru9Xblh
         VE1g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=NclGqIAT;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a23sor4919009otd.150.2019.06.30.16.06.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 30 Jun 2019 16:06:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=NclGqIAT;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=bl+8fccvQ+Vw0cb2jDFiMa7kxLSzzNYBzyYR78H/6zs=;
        b=NclGqIATbUTGEGvFGfvyAKJsQ3Wsyo9OEJAJV4eNIIXaQtWTv1qGxGwG65g02Quva7
         p/M3ofz5qKgSpMrd//ezAR7w3QAI/1GuPsVtnm7N0AgVJjM1umhgZ+XoxtR4bcOnjtWA
         kRrh01URyCYf8NBw6Hs539A1pNVWhcK9JfhM+VWY/nlPevY0fk1lcmJi3jN6BTx1EIa7
         L97hbwq1GAMoGw/eUC10KjlA7sENrYhRhrQT+cxc47LKeOW0jtvy093Phu13g7k5Zw9h
         6/j3Ui2uRJ37DSDkBxVukEjHdL6IqYOQPdF1yie7lNtnv+1Xv8FADP6iF8d1+DwqE8Yk
         HSKw==
X-Google-Smtp-Source: APXvYqwsNJqRsUaScDSVFeKcrfnQNXKYf7CsN+IusCoyenNGR11PQ6HvLabLyOiq5tnxR0X7o8uN/A==
X-Received: by 2002:a9d:7a45:: with SMTP id z5mr18205451otm.197.1561936006723;
        Sun, 30 Jun 2019 16:06:46 -0700 (PDT)
Received: from eggly.attlocal.net (172-10-233-147.lightspeed.sntcca.sbcglobal.net. [172.10.233.147])
        by smtp.gmail.com with ESMTPSA id n106sm2153839ota.31.2019.06.30.16.06.44
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 30 Jun 2019 16:06:45 -0700 (PDT)
Date: Sun, 30 Jun 2019 16:06:25 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
X-X-Sender: hugh@eggly.anvils
To: Jens Axboe <axboe@kernel.dk>, Oleg Nesterov <oleg@redhat.com>
cc: Peter Zijlstra <peterz@infradead.org>, Qian Cai <cai@lca.pw>, 
    akpm@linux-foundation.org, hch@lst.de, gkohli@codeaurora.org, 
    mingo@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] block: fix a crash in do_task_dead()
In-Reply-To: <ddf9ee34-cd97-a62b-6e91-6b4511586339@kernel.dk>
Message-ID: <alpine.LSU.2.11.1906301542410.1105@eggly.anvils>
References: <1559161526-618-1-git-send-email-cai@lca.pw> <20190530080358.GG2623@hirez.programming.kicks-ass.net> <82e88482-1b53-9423-baad-484312957e48@kernel.dk> <20190603123705.GB3419@hirez.programming.kicks-ass.net>
 <ddf9ee34-cd97-a62b-6e91-6b4511586339@kernel.dk>
User-Agent: Alpine 2.11 (LSU 23 2013-08-11)
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 5 Jun 2019, Jens Axboe wrote:
> 
> How about the following plan - if folks are happy with this sched patch,
> we can queue it up for 5.3. Once that is in, I'll kill the block change
> that special cases the polled task wakeup. For 5.2, we go with Oleg's
> patch for the swap case.

I just hit the do_task_dead() kernel BUG at kernel/sched/core.c:3463!
while heavy swapping on 5.2-rc7: it looks like Oleg's patch intended
for 5.2 was not signed off, and got forgotten.

I did hit the do_task_dead() BUG (but not at all easily) on early -rcs
before seeing Oleg's patch, then folded it in and and didn't hit the BUG
again; then just tried again without it, and luckily hit in a few hours.

So I can give it an enthusiastic
Acked-by: Hugh Dickins <hughd@google.com>
because it makes good sense to avoid the get/blk_wake/put overhead on
the asynch path anyway, even if it didn't work around a bug; but only
Half-Tested-by: Hugh Dickins <hughd@google.com>
since I have not been exercising the synchronous path at all.

Hugh, requoting Oleg:

> 
> I don't understand this code at all but I am just curious, can we do
> something like incomplete patch below ?
> 
> Oleg.
> 
> --- x/mm/page_io.c
> +++ x/mm/page_io.c
> @@ -140,8 +140,10 @@ int swap_readpage(struct page *page, bool synchronous)
>  	unlock_page(page);
>  	WRITE_ONCE(bio->bi_private, NULL);
>  	bio_put(bio);
> -	blk_wake_io_task(waiter);
> -	put_task_struct(waiter);
> +	if (waiter) {
> +		blk_wake_io_task(waiter);
> +		put_task_struct(waiter);
> +	}
>  }
>  
>  int generic_swapfile_activate(struct swap_info_struct *sis,
> @@ -398,11 +400,12 @@ int swap_readpage(struct page *page, boo
>  	 * Keep this task valid during swap readpage because the oom killer may
>  	 * attempt to access it in the page fault retry time check.
>  	 */
> -	get_task_struct(current);
> -	bio->bi_private = current;
>  	bio_set_op_attrs(bio, REQ_OP_READ, 0);
> -	if (synchronous)
> +	if (synchronous) {
>  		bio->bi_opf |= REQ_HIPRI;
> +		get_task_struct(current);
> +		bio->bi_private = current;
> +	}
>  	count_vm_event(PSWPIN);
>  	bio_get(bio);
>  	qc = submit_bio(bio);

