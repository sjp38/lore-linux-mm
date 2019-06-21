Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D91DEC48BE3
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 20:52:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9B54320665
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 20:52:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="rv+E/7b7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9B54320665
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3A5366B0003; Fri, 21 Jun 2019 16:52:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 356808E0002; Fri, 21 Jun 2019 16:52:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 24DD28E0001; Fri, 21 Jun 2019 16:52:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id E53636B0003
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 16:52:29 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id z35so1237210pgl.17
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 13:52:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=xsZwkR1O4dGnGMsIIG/ufAmeJ6Z+ZenaQocCY4Tza70=;
        b=hAj0sP1LOnJ6by2t2ykaO79tEOsfm0tvtUgdhZ2bYC1KvMOmojo5+mkZapVNUCAbBs
         aSo2Og4zIjE4xWDBaPzh9meqROhQR6aBcEGMAjQmCfbf5VdCFwyHn5/D6NOKljEv2B85
         wdkgtuQp1yo+O+qa+tlWCvNNv1J1LT1CX1HwmsVX5FfL21jowB1XYHbEFwPxsgxlLX7h
         83r1M+ArKe7zglGIxgkUmCtnkJPdM9fXFaL69m4vZyWP7par/TQlbhi8AwLXFW6y4PoU
         4b5U6HqlQLqwbbkeBt4WH4GDWHciO7H++6jtp7FwuOLCGAFiiyPPrp1zBgE8mHzwbPyr
         D8ug==
X-Gm-Message-State: APjAAAXHdoB6v2vFSZyT2s1kHBGlynmoRsqx0J6iaZyhOryyEI6a/O3U
	Kw3myoYbqWk29unRfiDu0SqxXTsQrMbsS1M58SE/zZzr8rD7pfoLpOWeDFoyPSIDgKt2A5467pe
	LLCDn+wNwsPUp3ZDfjOJ7TqUhW756kVJ0J77QXHrfCLVYXxlbZ8qaOtsCd3C/YqpKpg==
X-Received: by 2002:a65:41c7:: with SMTP id b7mr20280003pgq.165.1561150349419;
        Fri, 21 Jun 2019 13:52:29 -0700 (PDT)
X-Received: by 2002:a65:41c7:: with SMTP id b7mr20279966pgq.165.1561150348631;
        Fri, 21 Jun 2019 13:52:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561150348; cv=none;
        d=google.com; s=arc-20160816;
        b=bCoO9V9JPq/jC3YqC16dwpx+Lpp5KJ5uOXfUQN+DcvAYed9cBTWHh4Mv9tpzZBZdiI
         DcokhBiL9rnYslZDBXSxDu0voU8l0Vv5dps7wrmeK4KIQE+otSc7+2uF9RTrE0dFYX47
         q7tXC1Txs2S5TYXigLurhXfX3eqxLqt/tXY1Zirb+5ufmAdh1fjZqCdLjVaZoBWy+pkA
         uJ8pUwpR7DWKcnhATb0KeIZfAcF+kd770DvarsaELAGA39yz+430KUN8pkS4EQgIV5Up
         qg8byWe17MT+dai+KX0j1G4ajRAeI9NnO+fdjSgVBNKDXY884CXexaxiQLYv5jc61ge+
         yDOg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=xsZwkR1O4dGnGMsIIG/ufAmeJ6Z+ZenaQocCY4Tza70=;
        b=jwiz4d0+eYomEsmgbJ200a/AlmJPnQ+slfO9VH0v+stzu996slHQHlZI8o/1U0vWUm
         igW/SZrszKaj4Af+Ib7qFEyCZ5LfinGrVHoCe4jbFCHzWfyEReiFYxDUoE9IEFnxuhaA
         hZYOtAdsSI/mSKoCSMPndWTZRSuFyR+LDpohXtGEqL2ojvzd6F6wbqFBuF5E/7b2TKVW
         nBY1SipsZ+pSIYTBiP4D6R5ptGeyturYpgKCpMKccI8m1iK0nPCCwUd5nRtHjhFbTf6s
         BjVh0NE45BYWIILNlQtKSmWdq4mbfzImHHgrpogtAhi54EO7amP2UMYaBSgR2IdPesj3
         80WA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="rv+E/7b7";
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c12sor4731405plo.34.2019.06.21.13.52.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Jun 2019 13:52:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="rv+E/7b7";
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=xsZwkR1O4dGnGMsIIG/ufAmeJ6Z+ZenaQocCY4Tza70=;
        b=rv+E/7b7JY6cpCuEo3QEn8sbHqI1ZR79p1uD+ayLvYUjdZXy45cMBXnpOBANzRD/h9
         AKwFkx5YKkPwDV+z+alIPV1uhD4Us31/0w7Onebbflsxun6qItXz81HGcxTZ7S45mQkF
         mdeJXXlNrRYxGieY6CO5sW7OvYILoQQwQhzFqNXgIR9sUhMfzb7yJehRXESr28JDm6lq
         IJUwCKmkCEQEHh2qvgZDsesKij6FJXeF66csul2evLnnuuXC21nlojygQcdLk+8jHF2L
         PqLK6XveRhNJzO6G5iTrQWirXDKQbFegQGPu2Np+nWTUBVb8ggftrLbBsHWiZy5kTdaQ
         g5dg==
X-Google-Smtp-Source: APXvYqz8pEu9QXTZCF8KWb47EU2DnXnK1n2Nyy53mjFvIfV6G+FleV8pUn/1peh0vqHcvEjyo/py0Q==
X-Received: by 2002:a17:902:f089:: with SMTP id go9mr64259063plb.81.1561150347844;
        Fri, 21 Jun 2019 13:52:27 -0700 (PDT)
Received: from [2620:15c:17:3:3a5:23a7:5e32:4598] ([2620:15c:17:3:3a5:23a7:5e32:4598])
        by smtp.gmail.com with ESMTPSA id f17sm3582163pgv.16.2019.06.21.13.52.27
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 21 Jun 2019 13:52:27 -0700 (PDT)
Date: Fri, 21 Jun 2019 13:52:26 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
X-X-Sender: rientjes@chino.kir.corp.google.com
To: Shakeel Butt <shakeelb@google.com>
cc: Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, 
    Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, 
    Roman Gushchin <guro@fb.com>, Pekka Enberg <penberg@kernel.org>, 
    Joonsoo Kim <iamjoonsoo.kim@lge.com>, cgroups@vger.kernel.org, 
    linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
    Dave Hansen <dave.hansen@intel.com>
Subject: Re: [PATCH] slub: Don't panic for memcg kmem cache creation
 failure
In-Reply-To: <20190619232514.58994-1-shakeelb@google.com>
Message-ID: <alpine.DEB.2.21.1906211352130.77141@chino.kir.corp.google.com>
References: <20190619232514.58994-1-shakeelb@google.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 19 Jun 2019, Shakeel Butt wrote:

> Currently for CONFIG_SLUB, if a memcg kmem cache creation is failed and
> the corresponding root kmem cache has SLAB_PANIC flag, the kernel will
> be crashed. This is unnecessary as the kernel can handle the creation
> failures of memcg kmem caches. Additionally CONFIG_SLAB does not
> implement this behavior. So, to keep the behavior consistent between
> SLAB and SLUB, removing the panic for memcg kmem cache creation
> failures. The root kmem cache creation failure for SLAB_PANIC correctly
> panics for both SLAB and SLUB.
> 
> Reported-by: Dave Hansen <dave.hansen@intel.com>
> Signed-off-by: Shakeel Butt <shakeelb@google.com>

Acked-by: David Rientjes <rientjes@google.com>

