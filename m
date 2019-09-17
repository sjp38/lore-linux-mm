Return-Path: <SRS0=uo52=XM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.9 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1D286C4CECD
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 21:23:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CA6D421881
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 21:23:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="wVOe/Ydd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CA6D421881
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 44EC06B0005; Tue, 17 Sep 2019 17:23:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 400986B0006; Tue, 17 Sep 2019 17:23:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2C8BE6B0007; Tue, 17 Sep 2019 17:23:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0142.hostedemail.com [216.40.44.142])
	by kanga.kvack.org (Postfix) with ESMTP id 0535A6B0005
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 17:23:13 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 9AE961B66E
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 21:23:13 +0000 (UTC)
X-FDA: 75945688266.24.humor42_3938e929e4d4b
X-HE-Tag: humor42_3938e929e4d4b
X-Filterd-Recvd-Size: 3354
Received: from mail-pg1-f193.google.com (mail-pg1-f193.google.com [209.85.215.193])
	by imf13.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 21:23:13 +0000 (UTC)
Received: by mail-pg1-f193.google.com with SMTP id u17so2667227pgi.6
        for <linux-mm@kvack.org>; Tue, 17 Sep 2019 14:23:13 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=dkVBs4zSzdoiTgFubYHQRj4hsdd1sH32Fqwe9PFIl1E=;
        b=wVOe/YddR4PEOW3182urUd3iwixirM6pkgMLHtyn7FokoYN8LS8B6SMKt5l9whP5Xd
         a41neH7o7zLWQxvGN5M5g0frQiA2ej+vQjgGay7TLUFHp+TANnV9USPjLDhR6zvRgL7W
         k8H+9BQ5dmOU7ShP367cEpHTrfWC+bsBvSQ0KXrS7qKbQQFNSHXzd5b+g3oqHZQONOd/
         zUSuxUdQK59oR8cxKz87iKCuw6w4V76d1rG8SwlQ7fMK96l8ElmiECWhn7959fLCsXKO
         LiIohUJ/XepjXUw/fl3S3CZmdbvsoDifuqOV7B8/s8Lc9uy8/GvDdOdZifDF6MWOoJBx
         eCrA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:in-reply-to:message-id
         :references:user-agent:mime-version;
        bh=dkVBs4zSzdoiTgFubYHQRj4hsdd1sH32Fqwe9PFIl1E=;
        b=fDnq72yPkn9kfLGWIZcUPLWSKXRXeUkTMD/pWLn1smtyGdb+Ud/rClJhzWLQPv6l2E
         KbqaCYCfSibSUbvwQ3LzKGeFIKn9/Kcwl1HRmFBxeU89IxqUSbSLBR7JFp0ybyfeCUVz
         jPeuax+pgqxjrZ4vb4fMC8kDo3Lp7MVtjO7icq8jSEGrHxZ3M9EggnJiDq9MLFz0w/ml
         yGwlFAzrpBETv6/ZH3tMZQc5LMlQvmhb64G46X1yqQm/Dxj1w6aQDuuOkqOxmRqZyGNK
         H7aNEcuUmb7+3BYYXmsmmBmRYKXqIBNGezmLo2vMsnNA/DpspCcd//B/i5+iZCCyc1yy
         hwkg==
X-Gm-Message-State: APjAAAXWxyWBTXYTJMdooXiCh9kxNBcHVQOOazMDS1LHO7jFKgKdOpC3
	a5Esef9+cvv09wZ+ktg/cR18tQ==
X-Google-Smtp-Source: APXvYqwg9LNi+p1+U++EQh5F7CE9dUr0dz4AtnURwATfkLVnhYCkiEcmfusC9N1DvFAukd0L3bSzFA==
X-Received: by 2002:a65:6903:: with SMTP id s3mr818977pgq.269.1568755391787;
        Tue, 17 Sep 2019 14:23:11 -0700 (PDT)
Received: from [2620:15c:17:3:3a5:23a7:5e32:4598] ([2620:15c:17:3:3a5:23a7:5e32:4598])
        by smtp.gmail.com with ESMTPSA id m24sm2801001pgj.71.2019.09.17.14.23.10
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 17 Sep 2019 14:23:11 -0700 (PDT)
Date: Tue, 17 Sep 2019 14:23:10 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
X-X-Sender: rientjes@chino.kir.corp.google.com
To: Qian Cai <cai@lca.pw>
cc: akpm@linux-foundation.org, cl@linux.com, penberg@kernel.org, 
    linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/slub: fix -Wunused-function compiler warnings
In-Reply-To: <1568752232-5094-1-git-send-email-cai@lca.pw>
Message-ID: <alpine.DEB.2.21.1909171423000.168624@chino.kir.corp.google.com>
References: <1568752232-5094-1-git-send-email-cai@lca.pw>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.048480, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 17 Sep 2019, Qian Cai wrote:

> tid_to_cpu() and tid_to_event() are only used in note_cmpxchg_failure()
> when SLUB_DEBUG_CMPXCHG=y, so when SLUB_DEBUG_CMPXCHG=n by default,
> Clang will complain that those unused functions.
> 
> Signed-off-by: Qian Cai <cai@lca.pw>

Acked-by: David Rientjes <rientjes@google.com>

