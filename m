Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0F1DBC04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 13:21:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8E1882070B
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 13:21:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8E1882070B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=units.it
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2C8CE6B0279; Thu,  6 Jun 2019 09:21:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 279506B027A; Thu,  6 Jun 2019 09:21:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 18F236B027B; Thu,  6 Jun 2019 09:21:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id AAD926B0279
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 09:21:18 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id v23so536398ljj.1
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 06:21:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:to:from:cc
         :subject:in-reply-to:mime-version:content-id
         :content-transfer-encoding:date:message-id;
        bh=IgrIHGGlJn6M+tzBuCMGggHkGRPdqDfZ6Lf3LtzQ2oQ=;
        b=VIUO/dtn3aoFTrhV8LiCc1YzDGfWNgdVOOmBHM3ihTvIsOLN6CFTeYqnX0SoQxt1kd
         1V5F+uR28eInzzda46gEUBSxdYFkdvHFOHHH1RIJDNHuyCe9LCW90Gd7rfb8d4DVI19A
         kIy1nFEAWwzqx3syyr1HeoIXSnoQn9Mpz+1Wl47QeN9zcSmrFqEIVOooxWviyfWsDNmK
         b/8BOZt0HLtzT7Wxj1ohr3qOKPzUp/eoyPJbijMQlSgNLqcOWpsu6rgCCMajzj96Bwi/
         0rl9PqifirJF8J96g1BTCwFokAhII5RgLYBOD0ezIsjyfYoiVhsAlMGB3WKbjEYMYVIp
         FMdA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of balducci@units.it designates 140.105.55.81 as permitted sender) smtp.mailfrom=balducci@units.it
X-Gm-Message-State: APjAAAXxK6mnSdr2c7Yo2RRWQA/KtdVfMIX5R1suEOr+BOM16X+JdnyE
	8KoR/OM2q9CNfmASFNzuLBK5OVj1dkjwuGNGn07h7wiJeAYA671QTgnP2w3g9qkK7BBbfROFD0C
	1DxQMYKGcQsNSjtK6byaBwdmMHiwzx1hXa+kMO1FolEAEZ6IQqmqN8rGlEk5eBLcoCQ==
X-Received: by 2002:a19:e34e:: with SMTP id c14mr23464058lfk.47.1559827277996;
        Thu, 06 Jun 2019 06:21:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz8tTcyUFlmTW3SrUHgjhEtmTDZ2OZ+WOYJguhQN7d4KDMHJjh2HOWiNqSw3PnCBtXT5kZg
X-Received: by 2002:a19:e34e:: with SMTP id c14mr23464019lfk.47.1559827277083;
        Thu, 06 Jun 2019 06:21:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559827277; cv=none;
        d=google.com; s=arc-20160816;
        b=GrV6i2V3KTY9DEBGLXKbBSw8CSanD1b/g+dx3HrWy5lp0anbkDqwLhZjwXC3OtJvJf
         TyA3zEteO3XlIsykPhRiZ8otYkQZIOogfI2XFNCO9fbjdXtbS42JlcvTA00TjS4Pj4t6
         gh5SjngmoTwHxxmvS/a34u7RtoGKhzcXuydnKNSEismwdm+RYzv0qtZFHnebzcJzBINW
         Jbix6APRmzGYAxesv/KPumV6h4qh/qET/kgLhAnk8Um5UfyzBxywSYl2sgNnQcoSzHKa
         1G+10SyDktlOhGt2iazOdT+V8aYHlC9limIVevPOP2Wfm4Y/9vi2HFyqIImRnkbxaA3p
         8Uxg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:content-transfer-encoding:content-id:mime-version
         :in-reply-to:subject:cc:from:to;
        bh=IgrIHGGlJn6M+tzBuCMGggHkGRPdqDfZ6Lf3LtzQ2oQ=;
        b=ts5nc4LUYQ7lBA4kHAQkXcsanwFvYMEDJQryjO6GLdu+KvdzEGIckbC1NNuid+yP7y
         RDx4j9t4LmulKkSSCnohIaxheaHKbYOqwC9tfsu5XmourLOa61M0v9T3tuiCLBa8z+6W
         jJ29npdXmoN2qUwbHuDY0fKdNb8V1/Dk/u5WPpk+jj75giXU3Vd4Tel2RxyYdaBb9LTI
         bblkrm6LxCL1xHjy+r2l6+GHl63+31pxe2GP6wCmkpjICrdYw8Lk1pTTnKjcmoq+3x07
         Esd+IEni1qz++OIdRQ+VNshJDbed1SQ5lxNpKKpk7O8n0Y994xQgn/AGR5XGILWK9G3A
         bOxw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of balducci@units.it designates 140.105.55.81 as permitted sender) smtp.mailfrom=balducci@units.it
Received: from dschgrazlin2.units.it (dschgrazlin2.univ.trieste.it. [140.105.55.81])
        by mx.google.com with ESMTP id n6si2050837lji.196.2019.06.06.06.21.16
        for <linux-mm@kvack.org>;
        Thu, 06 Jun 2019 06:21:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of balducci@units.it designates 140.105.55.81 as permitted sender) client-ip=140.105.55.81;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of balducci@units.it designates 140.105.55.81 as permitted sender) smtp.mailfrom=balducci@units.it
Received: from dschgrazlin2.units.it (loopback [127.0.0.1])
	by dschgrazlin2.units.it (8.15.2/8.15.2) with ESMTP id x56DKn0R027680;
	Thu, 6 Jun 2019 15:20:49 +0200
To: Mel Gorman <mgorman@techsingularity.net>
From: balducci@units.it
CC: bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org,
        akpm@linux-foundation.org
Subject: Re: [Bug 203715] New: BUG: unable to handle kernel NULL pointer dereference under stress (possibly related to https://lkml.org/lkml/2019/5/24/292 ?)
In-reply-to: Your message of "Wed, 05 Jun 2019 18:21:36 +0100."
             <20190605172136.GC4626@techsingularity.net>
X-Mailer: MH-E 8.6+git; nmh 1.7.1; GNU Emacs 26.2
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <27678.1559827273.1@dschgrazlin2.units.it>
Content-Transfer-Encoding: quoted-printable
Date: Thu, 06 Jun 2019 15:20:49 +0200
Message-ID: <27679.1559827273@dschgrazlin2.units.it>
X-Greylist: inspected by milter-greylist-4.6.2 (dschgrazlin2.units.it [0.0.0.0]); Thu, 06 Jun 2019 15:20:49 +0200 (CEST) for IP:'127.0.0.1' DOMAIN:'loopback' HELO:'dschgrazlin2.units.it' FROM:'balducci@units.it' RCPT:''
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.6.2 (dschgrazlin2.units.it [0.0.0.0]); Thu, 06 Jun 2019 15:20:49 +0200 (CEST)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> Can you try the following compile-tested only patch please?
>
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 9e1b9acb116b..b3f18084866c 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -277,8 +277,7 @@ __reset_isolation_pfn(struct zone *zone, unsigned lo=
ng pf
> n, bool check_source,
>  	}
>  =

>  	/* Ensure the end of the pageblock or zone is online and valid */
> -	block_pfn +=3D pageblock_nr_pages;
> -	block_pfn =3D min(block_pfn, zone_end_pfn(zone) - 1);
> +	block_pfn =3D min(pageblock_end_pfn(block_pfn), zone_end_pfn(zone) - 1=
);
>  	end_page =3D pfn_to_online_page(block_pfn);
>  	if (!end_page)
>  		return false;
>

Unfortunately it doesn't help: the test firefox build very soon crashed
as before; this time the machine froze completely (had to hardware
reboot) and I couldn't find any kernel log in the log files (however the
screen of the frozen console looked pretty the same as the previous
times)

(I applied the patch on top of e577c8b64d58fe307ea4d5149d31615df2d90861,
right?)

