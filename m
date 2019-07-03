Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1885DC5B57D
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 00:50:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C78DB218EA
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 00:50:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="AJ6E73LE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C78DB218EA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5AD236B0003; Tue,  2 Jul 2019 20:50:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 55D568E0003; Tue,  2 Jul 2019 20:50:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 44C3B8E0001; Tue,  2 Jul 2019 20:50:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0AB7D6B0003
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 20:50:28 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id o16so453380pgk.18
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 17:50:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=ZWwYr6O3tiOc5lWF56ulDA9pRcqusbdisVXTs1Pb+fs=;
        b=K4rT4EP8h+DljRsO5+M1G7Q6ilaZap9OuqSmXlLd2cbgHOusER7/D0QbAhJ1TmnfmK
         n4NAZ+ym35jEFItKpgDAQCZPxbUWKIHFRCF8tehjF7GaWACz1Q7KUP/dXO/6hV5RHUqs
         GhAuO9BwX8U3hPym9izWnufOjIyz9ThrxvKZZfMAer06nkJDo8h1qWwqrCR4JE/74yWz
         wCoBZzU3UkcMoYdTUpbMds2ZR3a1mNHYfhHgiEfUfoo+dyPcvirEB//tHo3ydcK+B5aB
         8EaOVZcm6pgLoAvieiX299yysTPkvNk/qib6fYjBMLHwE2J3LT1W6rcksWdTMe3Ot2eD
         92bA==
X-Gm-Message-State: APjAAAVhj6XFrCn8yPGYfn17Gp9sPUzSeVP7hkwJ70phs3e4qjriESCn
	JPiYIh7JxL5aT/6+Qep5EO9GzitEjtknIBRN94zsBcRpbbC6uv/tLtVM1PS09FmX/AXS8Wgb3Kf
	WYq4vPfNAcYOPxYU8ktEaTcbqDxtIgKU0pCVr8U+ZVzBZbdU+BieVWRfpayKJKaZt+g==
X-Received: by 2002:a63:5d45:: with SMTP id o5mr33965133pgm.40.1562115027451;
        Tue, 02 Jul 2019 17:50:27 -0700 (PDT)
X-Received: by 2002:a63:5d45:: with SMTP id o5mr33965088pgm.40.1562115026655;
        Tue, 02 Jul 2019 17:50:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562115026; cv=none;
        d=google.com; s=arc-20160816;
        b=cWr7Ih72urkcTNGVjv+UT7trDHKSETa/prN5pNUtgtaDc0JQIhNZCZUgggpHl41NJk
         blrHHP7IrqqQTG/U95nkJMx4iwqdd1r0O/cAf4D6TdkjvIOe2nT8KKs6Cl3umaVHdoIU
         6CI0xv/Eszzu4JgKrR4Qrlewb63UU37waCtU4ZdY3Vjgy9MP59M9OzcEq+jP8kPmgfhb
         tRenW4M6dAIxyD4o87TJoHJBoaOOubTjy5NvonsCngO+3QIS74GBIOJavyPqHtMaHAT7
         jYAHSWQ5UHf/f115YV8IrILFt2y+rOyfMUdVxZYwhpdlxN7eTJj6yERZWrlUHybDV1oV
         9epw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=ZWwYr6O3tiOc5lWF56ulDA9pRcqusbdisVXTs1Pb+fs=;
        b=f5gZFh5+McqEfibOhvl60v255xse/yVhSF6kO0zPUvDB+WgROHv6fpK/IgKid3bQhV
         Mm1BIflsl2R6jrp3sVgvU2xt7AXWMhMxmq6kZt4bApBwB+TErwGJ8HJiJ7ljMt3kjihN
         YMfjtFyHxCejPsebgtf57PEnm3cMdOvPoXWf/xxHs4X6xdGbzlfSwCJT5BStukP3BJ6I
         DL/7s8WDLuQxGb77CrQokpVBCEEB7Nd0S83Ex9GEKmuTKzvTqXA8gqCHuBXBXG/sAzWz
         Toe4DXNFRQRG/HAqEvLCz/OEd/p5AzcQLSWYdKs0oN3hbaP9jmlJT3hNar/afyNab8Bu
         Kw/g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=AJ6E73LE;
       spf=pass (google.com: domain of minwoo.im.dev@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minwoo.im.dev@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x9sor874898plv.3.2019.07.02.17.50.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Jul 2019 17:50:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of minwoo.im.dev@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=AJ6E73LE;
       spf=pass (google.com: domain of minwoo.im.dev@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minwoo.im.dev@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=ZWwYr6O3tiOc5lWF56ulDA9pRcqusbdisVXTs1Pb+fs=;
        b=AJ6E73LEeTQ60TV7MqG9ZbNeGcL4+ODQxlqYw4uUto0c+0517Yn2sQISVpvOuAKjKG
         k4rZc8JHnRB6kovJ4Q00fQ3s4gNGPyINsFLXbxaLkjLmfTZsXp+5kchVnq8MWEhOdpSe
         Q48nybcCkEM2t81fSakAiP4KZY0HlEqX3hLzpUo0SwCW9pGlMzFTDXAsDVQXvzzZ1DHU
         bh1ND71xLdwlKq9TnJbELh+V7jMv58EWvh1+gL11mwFcPlzsG+imoOt4aXSJRMuxRaOm
         svfP2tTuQa4btswl0Iccc/BeFY0zhBnHIwKvyQ7iG6ct4k+Tfm13IEfDd9ySAuFQY3hz
         ZFXQ==
X-Google-Smtp-Source: APXvYqwibmteSvxZ9mD4EXO7JscIFVbqKdIk9aRiaNZQCILYiLSOPZ2KqB/kEdXsbFRLgbjZFj32tg==
X-Received: by 2002:a17:90a:cf0d:: with SMTP id h13mr8805697pju.63.1562115026302;
        Tue, 02 Jul 2019 17:50:26 -0700 (PDT)
Received: from localhost ([123.213.206.190])
        by smtp.gmail.com with ESMTPSA id d6sm279276pgf.55.2019.07.02.17.50.24
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 02 Jul 2019 17:50:25 -0700 (PDT)
Date: Wed, 3 Jul 2019 09:50:23 +0900
From: Minwoo Im <minwoo.im.dev@gmail.com>
To: Chaitanya Kulkarni <chaitanya.kulkarni@wdc.com>
Cc: linux-mm@kvack.org, linux-block@vger.kernel.org, bvanassche@acm.org,
	axboe@kernel.dk, Minwoo Im <minwoo.im.dev@gmail.com>
Subject: Re: [PATCH 3/5] block: allow block_dump to print all REQ_OP_XXX
Message-ID: <20190703005023.GC19081@minwoo-desktop>
References: <20190701215726.27601-1-chaitanya.kulkarni@wdc.com>
 <20190701215726.27601-4-chaitanya.kulkarni@wdc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190701215726.27601-4-chaitanya.kulkarni@wdc.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> diff --git a/block/blk-core.c b/block/blk-core.c
> index 5143a8e19b63..9855c5d5027d 100644
> --- a/block/blk-core.c
> +++ b/block/blk-core.c
> @@ -1127,17 +1127,15 @@ EXPORT_SYMBOL_GPL(direct_make_request);
>   */
>  blk_qc_t submit_bio(struct bio *bio)
>  {
> +	unsigned int count = bio_sectors(bio);

Chaitanya,

Could it have a single empty line right after this just like you have
for the if-statement below for the block_dump.  It's just a nitpick.

>  	/*
>  	 * If it's a regular read/write or a barrier with data attached,
>  	 * go through the normal accounting stuff before submission.
>  	 */
>  	if (bio_has_data(bio)) {
> -		unsigned int count;
>  
>  		if (unlikely(bio_op(bio) == REQ_OP_WRITE_SAME))
>  			count = queue_logical_block_size(bio->bi_disk->queue) >> 9;
> -		else
> -			count = bio_sectors(bio);
>  
>  		if (op_is_write(bio_op(bio))) {
>  			count_vm_events(PGPGOUT, count);
> @@ -1145,15 +1143,16 @@ blk_qc_t submit_bio(struct bio *bio)
>  			task_io_account_read(bio->bi_iter.bi_size);
>  			count_vm_events(PGPGIN, count);
>  		}
> +	}
>  
> -		if (unlikely(block_dump)) {
> -			char b[BDEVNAME_SIZE];
> -			printk(KERN_DEBUG "%s(%d): %s block %Lu on %s (%u sectors)\n",
> -			current->comm, task_pid_nr(current),
> -				blk_op_str(bio_op(bio)),
> -				(unsigned long long)bio->bi_iter.bi_sector,
> -				bio_devname(bio, b), count);
> -		}
> +	if (unlikely(block_dump)) {
> +		char b[BDEVNAME_SIZE];
> +
> +		printk(KERN_DEBUG "%s(%d): %s block %Lu on %s (%u sectors)\n",
> +		current->comm, task_pid_nr(current),
> +			blk_op_str(bio_op(bio)),
> +			(unsigned long long)bio->bi_iter.bi_sector,
> +			bio_devname(bio, b), count);

It would be great if non-data command is traced, I think.

Reviewed-by: Minwoo Im <minwoo.im.dev@gmail.com>

