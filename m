Return-Path: <SRS0=T9E7=U7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.1 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 923A5C06510
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 18:58:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5E25D21721
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 18:58:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="L+GRL2o3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5E25D21721
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ECB206B0007; Tue,  2 Jul 2019 14:58:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E53848E0005; Tue,  2 Jul 2019 14:58:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D1B2B8E0001; Tue,  2 Jul 2019 14:58:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9865C6B0007
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 14:58:52 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id q14so11419223pff.8
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 11:58:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=NoPQm7BhluIQixsWy6jjw3GeJMnTyieWyQFDmLwmwJ4=;
        b=OyVRvDCG6LSPKoqQW5v2yOeecL6tmAsT/SdkO00/aEVUf9dVcA1maGlXROnfdwQWeD
         C2ldYPHCSIRV/zMmAr5TJVvIxpUIrywbGOK5Uez6bMbjtwOZGLqrlVoQVq5vnnMj4JnS
         iDp5069ZfMME4PW/Mbo1ori/24gmCgVIVeesFGtxfTAqFEVHxzFUb8vcKkrVw0uxbKRm
         7XTIMv5dc87vl6w4JV3Gn6+t8xcsJBMkG7ccasHILCAx69MeaxmeR5EiwMVQ5V2RRLUI
         BdBpW3WkCPvpIPUEjlYQNs74g0wMW1z86sylDMlqKKew2T2Gf/sKCYN1iRYsFQg1Wt1z
         POrw==
X-Gm-Message-State: APjAAAVp5g7hyG5PIdL03laxfhQjmACjzjuHUs2QHvLU9uyqZwaOk2GR
	bxyjYwGLNTsrag1lU83Jw5oKlf+DEbvAPMvW1yIrVmeUF6llyxCf8JAOdBCEUnd8P/5L2g4kFkp
	Gq/6zupsZyycoG5pIPcZJwU0dOf8pYPEbdXDcpr2jePWo+ICV0nyRZ8w89RvyOnS7Xw==
X-Received: by 2002:a65:4945:: with SMTP id q5mr32758955pgs.9.1562093932091;
        Tue, 02 Jul 2019 11:58:52 -0700 (PDT)
X-Received: by 2002:a65:4945:: with SMTP id q5mr32758882pgs.9.1562093931181;
        Tue, 02 Jul 2019 11:58:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562093931; cv=none;
        d=google.com; s=arc-20160816;
        b=X9uG0TAt2MQNlfauso2r7B3PrkJH1Dxf2bowufdyly7/hzFN6A9Sx3hm/7WwRYff6P
         8qq6mtr/WJu2+Iduj/KnXG1nSA2IH+MohdmkQ9bWLsRi75DLn+SjMeBmzH1hIVj3IFpF
         3ngliQgozoi739wCS0oiDuNEnpB/ges/VbIplBHPB0Mtac7+252Ih5qtG82AuRdzq9Zc
         +f2o0ygn6+SdqlradJy73yzE/DfR+UllUVRBdGKbe4woAYYdFsTfxNeDxTifD/CNKIp8
         sSpdm0v+yhEV+adNdJ7nel5C7OHxytM0+qTLGS8SBowvMhYDxKVMJ9USWViZYg7cIOMm
         A0fw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=NoPQm7BhluIQixsWy6jjw3GeJMnTyieWyQFDmLwmwJ4=;
        b=vT4RdQ7JEND/QMqx9TzRmfyMi1kzj8rfPq/6PCbWCBRBZiE/RWB5m/0uCvGBikJrkb
         lAtHf0iFy2+c7+b2FwnRS/Ye1eDBK8N0x1DZcpcB/enWZ3wB8/bOAkHv5RZG3MiXsPvp
         7OzObX4PtsJCcWBjvhoxHM3sfcwv3ph4rxErZZeGSyjLRn13BR3eBpYGSmX3XoQBpUuz
         de3FNwkAMUz57YxjFRAds8tm/1w8p7mY/0Ul0n97bUmzIrBhcjl/VywjgwujwAJK+aDJ
         uN5KQp71h0fIxOYagOnWCo6G47+nGfBvjkIgDGpzHC5DKRTFmjvNv4RogrB6THs3tIi+
         EDag==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=L+GRL2o3;
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h90sor17206231plb.26.2019.07.02.11.58.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Jul 2019 11:58:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=L+GRL2o3;
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=NoPQm7BhluIQixsWy6jjw3GeJMnTyieWyQFDmLwmwJ4=;
        b=L+GRL2o36NtPs2femln+N8HVw/kCQfXaqfis0fXDHxD/9YaQS/UQyEEms9tRuHu4sG
         AQ/COT6gGNIL97ops6sXUkIvBWkWPKwpcRkKrWvZOtlChMJUZ1slW/YWRBnuTIjqQWYG
         L3m6awM0Ef3ffxm2Z6hzQnkE17/rJ5hn3mDclRhMRxMEkfFTa6DvrFqutyBemXokpU2R
         aB1JKz2hvWC3uk6LNFnLyJzB9mBQG2EqN+8IpSwBNXTL+/kK1P2SZqwlx9zndbu6bK4D
         FAz16WRHLJwbxZwuIMwUdFP2XTHVM1y7UOTUbnrc3jVnLZsUHW+YY/dNyJ3G/tZAdZPe
         LxaA==
X-Google-Smtp-Source: APXvYqw8dPKGUwJocSZOV9TVMQyFfZPDSfOEdfcX1CMRr/CyHjcQzbd3apmIL9aFvsRRF68+qlj8AA==
X-Received: by 2002:a17:902:ac88:: with SMTP id h8mr37313013plr.12.1562093930455;
        Tue, 02 Jul 2019 11:58:50 -0700 (PDT)
Received: from [2620:15c:17:3:3a5:23a7:5e32:4598] ([2620:15c:17:3:3a5:23a7:5e32:4598])
        by smtp.gmail.com with ESMTPSA id q36sm12654814pgl.23.2019.07.02.11.58.49
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 02 Jul 2019 11:58:49 -0700 (PDT)
Date: Tue, 2 Jul 2019 11:58:48 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
X-X-Sender: rientjes@chino.kir.corp.google.com
To: Henry Burns <henryburns@google.com>
cc: Vitaly Wool <vitalywool@gmail.com>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Vitaly Vul <vitaly.vul@sony.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, 
    Xidong Wang <wangxidong_97@163.com>, Shakeel Butt <shakeelb@google.com>, 
    Jonathan Adams <jwadams@google.com>, linux-mm@kvack.org, 
    linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2] mm/z3fold.c: Lock z3fold page before 
 __SetPageMovable()
In-Reply-To: <20190702005122.41036-1-henryburns@google.com>
Message-ID: <alpine.DEB.2.21.1907021158360.67286@chino.kir.corp.google.com>
References: <20190702005122.41036-1-henryburns@google.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 1 Jul 2019, Henry Burns wrote:

> __SetPageMovable() expects it's page to be locked, but z3fold.c doesn't
> lock the page. Following zsmalloc.c's example we call trylock_page() and
> unlock_page(). Also makes z3fold_page_migrate() assert that newpage is
> passed in locked, as documentation.
> 
> Signed-off-by: Henry Burns <henryburns@google.com>
> Suggested-by: Vitaly Wool <vitalywool@gmail.com>

Acked-by: David Rientjes <rientjes@google.com>

