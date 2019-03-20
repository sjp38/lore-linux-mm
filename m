Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 86827C10F05
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 21:04:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3FF2B218CD
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 21:04:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="iNfJLn1V"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3FF2B218CD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E82B36B0003; Wed, 20 Mar 2019 17:04:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E0BD16B0006; Wed, 20 Mar 2019 17:04:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CABBE6B0007; Wed, 20 Mar 2019 17:04:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9B3E66B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 17:04:06 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id o66so4995827ywc.3
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 14:04:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=c7mFoY9c1LOx2DLi8HmPtRRejYVacIC2KISLRsK7znE=;
        b=Gz3dw5xmS6DzXQbQ3VWqxrstjGxmOjL7JLQqD+plyjlpuv4LRKAS3qLruKJm0ds+JN
         4yLi+Ps/eY35lkaU+VT2fSYYD2OB+9mi4tT8XdqrwaW6yMGKihTSrFSnFYyayaPMqllU
         DEVBDDNMXpbMB65c57PGVm21VFB6mwIhQklzKOAfzATIyic6yEGUI/sNhH3yGDVz6+RR
         w1AX2Mp62Rx4tVDe4O86lK8Qkl8ZdLyptaPKzVsdxJ+OpdJ+vNFY0DOsymqTEz2ozqVM
         k+8IgbVOtl1QHNHDEDN2dZiapeY6tO643T/RVxL/+ScFyLTiTtUcEERXFi0j/PQvedHi
         aihw==
X-Gm-Message-State: APjAAAXMlmJBb2hyT7cDXu8wJxrvVScblq8yrDSqcxRTaQ8PIG6XWqxo
	UYpVufpcNUKZ3HuTwaAUoMXkADcTX+8Tjw6RVqcE+TYWaYPkg6agq+ljF88RH6KeEpyfOj9YDyW
	l7XvG5pr/KTFvcIZ8AdLmeGxPowWOTiWXc/1P83v96AtUUFQ7q11YWgyatsPbcnrbNA==
X-Received: by 2002:a0d:d246:: with SMTP id u67mr197699ywd.162.1553115846403;
        Wed, 20 Mar 2019 14:04:06 -0700 (PDT)
X-Received: by 2002:a0d:d246:: with SMTP id u67mr197625ywd.162.1553115845599;
        Wed, 20 Mar 2019 14:04:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553115845; cv=none;
        d=google.com; s=arc-20160816;
        b=nz6OpYIaYiFS4AEzCPKtq2RsxPphhOiG2acNKfSBPSfyZm63k+dhyqv9wKwnYqh8xY
         y83ZZMH4o65pYP8ivESae9q/xeb60kWx0HD59uAYlV6MeZLzUjGnwFfbruQg+QVMODxc
         OY9eWCPh5VandfZlH+exABnacUoR/TyEcJP+WMucr2Xs18r6RkfCv34Tl9dB85M8/LAv
         Xpp8YuZrRC0GdPIVuZGM+S3eY+CnUtb75W04CSvkaCOaYiJdVq4oe1RKqv0i7gyXnmD1
         vBe9Q5lMw6pgmuP2iQ6fK2YvKgmA6ZTOXatVLflfintx6EMiAj+lpp5XSx6zE5Gdp/es
         vvow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=c7mFoY9c1LOx2DLi8HmPtRRejYVacIC2KISLRsK7znE=;
        b=C/TxqsEGZEtthvQ51agxAT52Ep7VSE92060Ok8n4di3pRYJAQ9HZqQqxqJFtcqtNMG
         E5Xg9+y+2Q+IPB0dDktJJIeJniPsxSpNLcULxHM7VvJWxXvtyuWZhtSExcBjFZsN4lYc
         C1ZfEliAMrGQrqTssQ52wvqylEk6D/PbAMO8DUXI2nlhlap3o6W1rD/g5olImhaKwmkn
         26bvG8HpaCIdoWFiSydt2DGuseB92+iyICEvTpqcDZ5+Ji2lo4+FFGzEOIS3j/vUcqB1
         zh0IcyFq55XadwYPdRGMlaHDx4yWPaX/GuKddoE9G3FrPG+d+EUclRj8Qz6gPWEP5wMD
         G9nQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=iNfJLn1V;
       spf=temperror (google.com: error in processing during lookup of hannes@cmpxchg.org: DNS error) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x2sor1531186ybb.49.2019.03.20.14.04.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Mar 2019 14:04:05 -0700 (PDT)
Received-SPF: temperror (google.com: error in processing during lookup of hannes@cmpxchg.org: DNS error) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=iNfJLn1V;
       spf=temperror (google.com: error in processing during lookup of hannes@cmpxchg.org: DNS error) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=c7mFoY9c1LOx2DLi8HmPtRRejYVacIC2KISLRsK7znE=;
        b=iNfJLn1VEvAICGg6+J8aTGo2WHwUAblrU8TC4P4d/YRBZXKDhFuHuWPyZ+0OcodA2R
         g7V3avx9WoHGDQcWiV6r3LM0LpMba9yJ3IUAj0x5QC+zKlzOmO4kgXtaoS+5XNfH35f6
         y3Q95eLIBZnLlHIgU2hmV3Z3aaaWgB2xG+sNBTD2NsA89KSRqyVkPML3RtWfJhtmFNdq
         uyW97pDsEiNY89ljQeenu9r/FX9qo6fKteLpOe4Ty8207DbRYrXxQ18O75u7haf4V8Sk
         XGHF1f5dd/S4jj+izKUS5beIisOqtB2HANTsNRLdkYtB97haZMPGFXeQ0p9W+YOT5XOm
         1Frw==
X-Google-Smtp-Source: APXvYqyTEHhGxdOJ0WUla4LiMKIGI1B1SD0+iCGoWa94KCfF7DznKo6uv1EmkH63I8BFjx4vQCSD9w==
X-Received: by 2002:a25:d601:: with SMTP id n1mr28266ybg.342.1553115845368;
        Wed, 20 Mar 2019 14:04:05 -0700 (PDT)
Received: from localhost ([2620:10d:c091:200::2:b52c])
        by smtp.gmail.com with ESMTPSA id 79sm1444881ywr.110.2019.03.20.14.04.04
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 20 Mar 2019 14:04:04 -0700 (PDT)
Date: Wed, 20 Mar 2019 17:04:03 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Suren Baghdasaryan <surenb@google.com>
Cc: gregkh@linuxfoundation.org, tj@kernel.org, lizefan@huawei.com,
	axboe@kernel.dk, dennis@kernel.org, dennisszhou@gmail.com,
	mingo@redhat.com, peterz@infradead.org, akpm@linux-foundation.org,
	corbet@lwn.net, cgroups@vger.kernel.org, linux-mm@kvack.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@android.com
Subject: Re: [PATCH v6 6/7] refactor header includes to allow kthread.h
 inclusion in psi_types.h
Message-ID: <20190320210403.GE19382@cmpxchg.org>
References: <20190319235619.260832-1-surenb@google.com>
 <20190319235619.260832-7-surenb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190319235619.260832-7-surenb@google.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 19, 2019 at 04:56:18PM -0700, Suren Baghdasaryan wrote:
> kthread.h can't be included in psi_types.h because it creates a circular
> inclusion with kthread.h eventually including psi_types.h and complaining
> on kthread structures not being defined because they are defined further
> in the kthread.h. Resolve this by removing psi_types.h inclusion from the
> headers included from kthread.h.
> 
> Signed-off-by: Suren Baghdasaryan <surenb@google.com>

> @@ -26,7 +26,6 @@
>  #include <linux/latencytop.h>
>  #include <linux/sched/prio.h>
>  #include <linux/signal_types.h>
> -#include <linux/psi_types.h>
>  #include <linux/mm_types_task.h>
>  #include <linux/task_io_accounting.h>
>  #include <linux/rseq.h>

Ah yes, earlier versions of the psi patches had a psi_task struct or
something embedded in task_struct. It's all just simple C types now.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

