Return-Path: <SRS0=T9E7=U7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.1 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2B9EDC06510
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 19:12:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E83F92184C
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 19:12:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="KYjUX95h"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E83F92184C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 856FD8E0003; Tue,  2 Jul 2019 15:12:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8086A8E0001; Tue,  2 Jul 2019 15:12:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 71ED58E0003; Tue,  2 Jul 2019 15:12:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3A1948E0001
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 15:12:11 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id e7so859495plt.13
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 12:12:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=ustizs9nQ/dvH8f3l0VeRsX7a+gE2MyRDhi2ExuynrQ=;
        b=ezcF7mMQPD0sOyy3WamaaJXWSSmoB6GYFWU0CviAql4R3FGCdcgT/XmWVA+2DUzfdZ
         Dfym0wpUU5kmTvAiC1mSeOdrciOQVKAedVZ1Z0ljPipNBm1O+kBzoZEau4aD1QIKAnt/
         S8qoxlboiXhX7XXlc6OaPnFXQOLqVQW1B/ZvDrqq98eY2EJnCE4SGOJfHFhAcHyjDAfi
         kuNY6mMnFxDaR1ghxxRJy3fkZ7TTxSred8A9WraMubCipezA1g4grWkMl9+7hmix7uAe
         M0MjaP7fRKgxrcexDokrq/OQZSoSGCJs93tKmXx38CnVFknZ+MsHilnMlw4InjRz3jjY
         modg==
X-Gm-Message-State: APjAAAUUPw6tOxTrGn5y9c+IcRrEl5rBxhjm7APtcupZ9yZb99psMzJi
	Wi++RDvYWKlui3TEz8PCHDt3+48Co1TQDhBSJtHAuOfLh9E3MeBVNJKB1ZXSJHDt8Wdn96+C8m8
	sCLH+QOgYjL/WE+RhpZoHAffUukfSrd33DdZdxf4jULrYw3JIc2EavA1STj61bCgSCA==
X-Received: by 2002:a17:902:7248:: with SMTP id c8mr223173pll.162.1562094730835;
        Tue, 02 Jul 2019 12:12:10 -0700 (PDT)
X-Received: by 2002:a17:902:7248:: with SMTP id c8mr223122pll.162.1562094730239;
        Tue, 02 Jul 2019 12:12:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562094730; cv=none;
        d=google.com; s=arc-20160816;
        b=bXzMycObMwJfhnnw9vLJalriXxVUAUbm+yKeGUueq9FXioXOzxn13WVFSIODF+4IGH
         uvYZpOTco7SRwh3PtLr2TZF5iR7QeOZIqDb3SxUBnBcv/NXiuWnLrlR966SAgQbQeaga
         cwZrUIHhL0YB+yFfixXAdxESRj1kBcqVrUXgcYt6agESb5Jo3HjMa9tU9QIpRqhSHVjO
         jmMfMx0t2HO1mkrqcezSjcNXmc1Onla78ZMLwrdaozN4bkN8eu174XKxCdIfqSaaiRJM
         caE8CTDtr7elX9DbV3wpTjWlV4xoqWHQ45/samWPozYbre1uVCH+vzwV/rQCm8mEQRRB
         0yXg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=ustizs9nQ/dvH8f3l0VeRsX7a+gE2MyRDhi2ExuynrQ=;
        b=L1viFONPCqgTbscH5f8tuuXXRoz8ktePulKCG648XH6abxxCI33TPJTJOa2TAzlGgs
         SduWYNfFeLulysExa/EQpJmNyUw4mUCHRG3jstpfDyDrmjjA+rwxOoeC/hF1q2u5RgTh
         YNnICgpTX3KlY3MIO3t6sQ++hiy5/bPfsZYKcmsKU5EQJ957G37Xpw08foYEVTTdGa+7
         1BMBfu7Z2GTMZ0Rax8ZbbK7kaOmDD/celtD2YUJJ6n/RTKXX5l/wi986mdvmPQai/kKW
         b5Lp/7z783ZeFvADRKRwkIaumWJHmbe9WQ34VLn5mKw3JELLyM4ro6iecqtJ9dAJdtPN
         DPNg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=KYjUX95h;
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id o32sor17426162pld.12.2019.07.02.12.12.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Jul 2019 12:12:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of rientjes@google.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=KYjUX95h;
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=ustizs9nQ/dvH8f3l0VeRsX7a+gE2MyRDhi2ExuynrQ=;
        b=KYjUX95hqXNvTfv32exnncUWRJEABX4uz/Gycd9AFxTIST4OXEiGp4h81QjfCiwIH7
         ycunBDhPiYn7b+bF4IYG/9nVqdpsTIUVKM6pP0OyRG8kCdFjOHAzw4Wa/lu6Z6d2u4d5
         PaScNBBegnKeTlIExx5CGoRSHq4bnnGkAkH2VKz+Fgje571NP5805RomuRs3D20LQZkw
         lCxjPGH/aymTPbHLFypkVaN9qcfE5RKJIyQ6CyOAL/HkqGfWVZER54G9nOVrdbTFy8/g
         FXpYf6REqgjmdxuLG+qlfCONPcsujmuGvEVQeMm4pzqqYcntCojNNQfHWLZQALSjhCW3
         8MHg==
X-Google-Smtp-Source: APXvYqz4wXXllh26Sw2vwZ0czX/JHY7+mfDNBiC+q6EuLJRFW2nSu4csXD4xq7TUdIQ+mg9+YBbouQ==
X-Received: by 2002:a17:902:9897:: with SMTP id s23mr36862985plp.47.1562094729587;
        Tue, 02 Jul 2019 12:12:09 -0700 (PDT)
Received: from [2620:15c:17:3:3a5:23a7:5e32:4598] ([2620:15c:17:3:3a5:23a7:5e32:4598])
        by smtp.gmail.com with ESMTPSA id l44sm3000865pje.29.2019.07.02.12.12.08
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 02 Jul 2019 12:12:08 -0700 (PDT)
Date: Tue, 2 Jul 2019 12:12:07 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
X-X-Sender: rientjes@chino.kir.corp.google.com
To: Waiman Long <longman@redhat.com>
cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, 
    Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
    Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, 
    linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, 
    Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, 
    Shakeel Butt <shakeelb@google.com>, 
    Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH-next v2] mm, memcg: Add ":deact" tag for reparented kmem
 caches in memcg_slabinfo
In-Reply-To: <20190627184324.5875-1-longman@redhat.com>
Message-ID: <alpine.DEB.2.21.1907021211570.67286@chino.kir.corp.google.com>
References: <20190627184324.5875-1-longman@redhat.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 27 Jun 2019, Waiman Long wrote:

> With Roman's kmem cache reparent patch, multiple kmem caches of the same
> type can be seen attached to the same memcg id. All of them, except
> maybe one, are reparent'ed kmem caches. It can be useful to tag those
> reparented caches by adding a new slab flag "SLAB_DEACTIVATED" to those
> kmem caches that will be reparent'ed if it cannot be destroyed completely.
> 
> For the reparent'ed memcg kmem caches, the tag ":deact" will now be
> shown in <debugfs>/memcg_slabinfo.
> 
> [v2: Set the flag in the common code as suggested by Roman.]
> 
> Signed-off-by: Waiman Long <longman@redhat.com>
> Reviewed-by: Shakeel Butt <shakeelb@google.com>
> Acked-by: Roman Gushchin <guro@fb.com>

Acked-by: David Rientjes <rientjes@google.com>

