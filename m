Return-Path: <SRS0=d6aY=VB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 79F34C0651F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Jul 2019 14:24:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 42F37218A3
	for <linux-mm@archiver.kernel.org>; Thu,  4 Jul 2019 14:24:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 42F37218A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ellerman.id.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A0FAD6B0003; Thu,  4 Jul 2019 10:23:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9BFF68E0003; Thu,  4 Jul 2019 10:23:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8D7838E0001; Thu,  4 Jul 2019 10:23:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 672306B0003
	for <linux-mm@kvack.org>; Thu,  4 Jul 2019 10:23:59 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id 30so3810999pgk.16
        for <linux-mm@kvack.org>; Thu, 04 Jul 2019 07:23:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:message-id:mime-version;
        bh=yb2+40oI/7C/LZVxqYp35Us0Se/150bRhrGjlqlUXoE=;
        b=Ps4mN9V/Cciw9NazZP/JZfCf0J1xx+mV75e9aVh6evPPCerOobJmL8MF2gxvGWtkTI
         tgS8CxEwlohr6WfZrR06JvSBlOOn1k3ILRvcLosIo4Bx4sUz7VctMEpvrS32ZPqDdh3h
         v/t0iZ5v/bSG2052qr8IeFbaynE67q9WesYovn1WtNgarYePpd1gztkwDE/5hzdm73p1
         n8VsA0+rZhaxiu2NDkNenjoNuaAoEJ5ViZ+DyCpMWGyf+8W8DofCfaNIcQeYywK/yVot
         NkGyTZwaAi3RIJtSAUHgA+QpK6g6Anq77l9KF14r5bQn2VB3V55kCD0ygLUk+PuzO90M
         pFQw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
X-Gm-Message-State: APjAAAUXoGBSBeri8Jl3SOeRHHwt/mQLZ3PstFKjs4+vqQhCzG6QB+3H
	GwiBr75r/fjNDBaZ5Jdk7WkxmxJ7WCkVtRZWIkrAhlhVXCSxe3ndlDZG8gMvgKnl7YCZFfZbohG
	yJA0z7396toR6SzzKcWBJMMD4FykMUZea3T/rzSUqyGgpHyKJgyl62QN7zX3BBhQ=
X-Received: by 2002:a63:2364:: with SMTP id u36mr34825511pgm.449.1562250238953;
        Thu, 04 Jul 2019 07:23:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyFt7n4BqwD/s3DcGKl5XPSmVBLCaNhICURDoFSZe0G42dRex9YPwTk0qocdItwwgMtDtCY
X-Received: by 2002:a63:2364:: with SMTP id u36mr34825445pgm.449.1562250237887;
        Thu, 04 Jul 2019 07:23:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562250237; cv=none;
        d=google.com; s=arc-20160816;
        b=PDvc0Esau8kHliPEyPPESvkO7nypPA06ErxowbV8lt3qBuVwnA7sz/Ej2olFDZ/F2K
         7SJ5Apce/hnBkDPkscj/ZYDsF6KpOBcGwCqHZ5DDmFvdzboh+uTV4hlOSv+n/H5px5O6
         km6ZC1uVa3t8ErVmt5CVoV2jqOqtvufcJM9h1PGshklUdCZg5HIwhrWZkXOMzix4ezw8
         Av2UtKBmAiAjfOiDuX6FeHdlNpKIoEZjtowt66jyP7NEbisXJiuJwNRQSBKGj9Pre6AA
         bOhzfSz1J/RAZlDvmTTcb0xAnFO0TAH5+QLov6b+f3eIq72qi371ME7CK4cUjXnURmfc
         JETQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:references:in-reply-to:subject:cc:to
         :from;
        bh=yb2+40oI/7C/LZVxqYp35Us0Se/150bRhrGjlqlUXoE=;
        b=uePXrHto37lKTFTh8cC8AHMLqi3JA9PP/js/FG7MIlJcQd0+Ob849RoyQDA6LyU3KC
         mrMXx952CZLv/xligSwAVLiSoQjxYktp2/eJEp+drzFRJ0QWeaofCqzt0Gs9e7qy72ZG
         IxOjMtOv4Bd9XmoDZ59ZiLWtEEUKNLKLsRFjXsbB2jsohuQ9t/HAEvvnQ3wqI3s577sM
         xA9+VpVP/GWru1+FQ4v5X8NZE4G6YbYQ28UWFc6AG/qC8U1TnJYjv2N/5H8yP6VxqCgI
         UYhcXptVQja2DEArEkg7GB9IfkWrsDZBqb8EK5F0dcF094DNeop8z/47DrM2J+9YIJW6
         7swA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from ozlabs.org (ozlabs.org. [203.11.71.1])
        by mx.google.com with ESMTPS id j37si5504808plb.58.2019.07.04.07.23.57
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 04 Jul 2019 07:23:57 -0700 (PDT)
Received-SPF: neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) client-ip=203.11.71.1;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by mail.ozlabs.org (Postfix) with ESMTPSA id 45fgFg4cF4z9sPB;
	Fri,  5 Jul 2019 00:23:51 +1000 (AEST)
From: Michael Ellerman <mpe@ellerman.id.au>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, dan.j.williams@intel.com, linuxppc-dev@lists.ozlabs.org, linux-nvdimm@lists.01.org
Subject: Re: [PATCH] mm/nvdimm: Add is_ioremap_addr and use that to check ioremap address
In-Reply-To: <87r2792jq5.fsf@linux.ibm.com>
References: <20190701134038.14165-1-aneesh.kumar@linux.ibm.com> <20190701165152.7a55299eb670b0ca326f24dd@linux-foundation.org> <87r2792jq5.fsf@linux.ibm.com>
Date: Fri, 05 Jul 2019 00:23:49 +1000
Message-ID: <87a7dt3mkq.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com> writes:
> Andrew Morton <akpm@linux-foundation.org> writes:
>
>> On Mon,  1 Jul 2019 19:10:38 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com> wrote:
>>
>>> Architectures like powerpc use different address range to map ioremap
>>> and vmalloc range. The memunmap() check used by the nvdimm layer was
>>> wrongly using is_vmalloc_addr() to check for ioremap range which fails for
>>> ppc64. This result in ppc64 not freeing the ioremap mapping. The side effect
>>> of this is an unbind failure during module unload with papr_scm nvdimm driver
>>
>> The patch applies to 5.1.  Does it need a Fixes: and a Cc:stable?
>
> Actually, we want it to be backported to an older kernel possibly one
> that added papr-scm driver, b5beae5e224f ("powerpc/pseries: Add driver
> for PAPR SCM regions"). But that doesn't apply easily. It does apply
> without conflicts to 5.0

Don't worry about where it applies or doesn't, just tag it with the
correct Fixes: and stable versions and then if it doesn't backport
cleanly then we deal with that later.

cheers

