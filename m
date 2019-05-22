Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 24059C282DC
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 22:52:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A704E217D9
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 22:52:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="N3TAcSM7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A704E217D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4BECF6B0006; Wed, 22 May 2019 18:52:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 46CFB6B0007; Wed, 22 May 2019 18:52:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3348F6B0008; Wed, 22 May 2019 18:52:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1B40F6B0003
	for <linux-mm@kvack.org>; Wed, 22 May 2019 18:52:19 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id h189so3033326ioa.13
        for <linux-mm@kvack.org>; Wed, 22 May 2019 15:52:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=HWRXO+edmhSom/gacoPKkE1g/E36lS3QYMoiSV/+smA=;
        b=K39kI1Jll/hqcO52L2cJpbe+lsXFHUuJM+Pz9xrbcGhwKtaD/+PeVWpkjAQdg2GIoS
         nskPDzI514HlY1PKqlwuUQuvyKND99kqsS2naEEsbOOe5CqQnhGQlFd0Ro4jkJTFfMLz
         5EVa0ctJaWFr8NjQQBYFe5M1lu//2XnS+pO0Zviq877N9bVpXcurKzRqLYISC+9GnJ+F
         agZTJqbUu5ALiACA3lllyJHnHppaIrt6P+Xsyawgjzc6cu/SQnSKSajxj7RpB3vkS1Tt
         aa+tMhTrsBZJD5dLkkcbdgj5Xh7X0DgsRS7pVbfSJ7DpqkX7dMv2g9gO0g8taEArbWbp
         ryJA==
X-Gm-Message-State: APjAAAU3uAOMB4ppjiwHYDb/lT5qnfgOWOUHHdYAumxxiC77NNk8/5QJ
	OPlb8LgKGUeOORCviE3VwIqR5B9ewr0ZCWZ9gWVvFUI5VwJ53HVMk89vbfjdbFyebdI8h6Jq7no
	z0ecTLULKEG3ol1FlYQOFT1JhjE2P3whiVGQC/DGyLwdrVNf2JL8EfCYYD4OE6MGU4Q==
X-Received: by 2002:a6b:7d0d:: with SMTP id c13mr9410346ioq.249.1558565538792;
        Wed, 22 May 2019 15:52:18 -0700 (PDT)
X-Received: by 2002:a6b:7d0d:: with SMTP id c13mr9410324ioq.249.1558565538245;
        Wed, 22 May 2019 15:52:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558565538; cv=none;
        d=google.com; s=arc-20160816;
        b=c9GavxkALNPEf59Ta/mnhMCuvqzA2h+AjksnPXDFwywvf5mS7XI+4Vh8+bqoysiTTu
         jd6f6s6ygiUq/Lhx/ogeb8yE57VE0yVsPQvCnZDg0u4h1oyLjxicATRalsK9N2aZERCP
         fDDSiiQm9GlxtwsrnwwMEtqZnpzRqUKu0Go1uDJzgAUIBcV/lh01cT46b4EMXjk5JeBh
         q6Qu3YH94dp5ldcsjm3d3OJ4Bpb+kCIEaZl6h+CEuO5CslBiXJWH8TxqECEWFnFISTzC
         8x7Po8PEyTqpA0O4/oaRdzXIYBNRtJJZrdTkpG7/T0UJOhxh0Tj2TBULn8m/mdpRxlr9
         9gfQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=HWRXO+edmhSom/gacoPKkE1g/E36lS3QYMoiSV/+smA=;
        b=ZmiiD3RkJpd0/K0jeQb6MjSHVSn91xvPszBSKiuw1ODHVe8Eue4/2SNUrU3Rc5ioKo
         EwJjnZVMwnvGzrMzotJNosvmYAaQXthtW1ANguYdUwuJpA0sAED9ryVkfEE487KWMAMG
         bm3KK8ATRLWTZakAuh7fDgLdD7K11eIjr9GgV7FdYN5ujmJprTQyUnpjsdUF3xkeztrx
         WxMOPtuCKbdgVSrGGTkgqRqvfNWH6lQOEO8WCiKA4yZODIgaLNbGt2XQ/U7qnMp4SBBc
         4CjazRxYCeGqbynJIJ2zIiHLXZdyn5moV3ZtRb7j9drNr4aqb4kP3AlV1OpUSkPaWakD
         1zhA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=N3TAcSM7;
       spf=pass (google.com: domain of deepa.kernel@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=deepa.kernel@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n11sor10580485itb.27.2019.05.22.15.52.18
        (Google Transport Security);
        Wed, 22 May 2019 15:52:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of deepa.kernel@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=N3TAcSM7;
       spf=pass (google.com: domain of deepa.kernel@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=deepa.kernel@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=HWRXO+edmhSom/gacoPKkE1g/E36lS3QYMoiSV/+smA=;
        b=N3TAcSM7SiptL6E2SpY6CNVVfh0UKXMcbqLjx9uyZbqsLzAXlXzIw4pG7+IRVUlyu/
         rnf1eqzZuDVLHAjTNDrN/n9Mwe4jvqUXZvuc32062sb6vlqUfryK6Y6lUTuHl4kjwiIx
         7xPmzAoKwCv9929NQCCLoDfkfXlx4FVB1SdOHxSvEWRyYRVJomHwUB89NSpG/Xkli4bV
         n/SHezDeA2bj806k3LyjwH85p2tNOk3q0yXDISrFmkNjm+si0G+J06iz8tA9Gj0jlTxm
         B7hbMFRZsI5wegx8aNy51mnQ/7oP0cVlk5r2gyIczutHFeENqTgmpCBJ74wO8BCPtn/b
         Y7qg==
X-Google-Smtp-Source: APXvYqyjZ+tS45v8lDkdTg2/u2uz1fwRnLzCmsw1ZYvEykv/LDAKd+suzQDe/uZURzEU5Cb78LN9rF9D+ofHWhSGNCw=
X-Received: by 2002:a24:e084:: with SMTP id c126mr10298082ith.124.1558565537779;
 Wed, 22 May 2019 15:52:17 -0700 (PDT)
MIME-Version: 1.0
References: <20190522032144.10995-1-deepa.kernel@gmail.com> <20190522221805.GA30062@chrisdown.name>
In-Reply-To: <20190522221805.GA30062@chrisdown.name>
From: Deepa Dinamani <deepa.kernel@gmail.com>
Date: Wed, 22 May 2019 15:52:03 -0700
Message-ID: <CABeXuvo25MXCxhfMZNgnMaWRXMktQJ7ZKqm-7M70GaGM_54+0g@mail.gmail.com>
Subject: Re: [PATCH v2] signal: Adjust error codes according to restore_user_sigmask()
To: Chris Down <chris@chrisdown.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, axboe@kernel.dk, 
	Davidlohr Bueso <dave@stgolabs.net>, dbueso@suse.de, Eric Wong <e@80x24.org>, 
	Jason Baron <jbaron@akamai.com>, linux-aio <linux-aio@kvack.org>, 
	Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Oleg Nesterov <oleg@redhat.com>, 
	Omar Kilani <omar.kilani@gmail.com>, stable@vger.kernel.org, 
	Thomas Gleixner <tglx@linutronix.de>, Alexander Viro <viro@zeniv.linux.org.uk>, 
	linux-mm <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 22, 2019 at 3:18 PM Chris Down <chris@chrisdown.name> wrote:
>
> +Cc: linux-mm, since this broke mmots tree and has been applied there
>
> This patch is missing a definition for signal_detected in io_cqring_wait, which
> breaks the build.

This patch does not break the build.
The patch the breaks the build was the v2 of this patch since there
was an accidental deletion.
That's what the v3 fixed. I think v3 got picked up today morning into
the mm tree


-Deepa

