Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1E2DDC04AB6
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 08:50:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E05BF2479C
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 08:50:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E05BF2479C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7FD656B0278; Fri, 31 May 2019 04:50:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7ADFE6B027A; Fri, 31 May 2019 04:50:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6C4156B027C; Fri, 31 May 2019 04:50:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 211396B0278
	for <linux-mm@kvack.org>; Fri, 31 May 2019 04:50:48 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id n52so12992510edd.2
        for <linux-mm@kvack.org>; Fri, 31 May 2019 01:50:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Jai/c1DPn86hELIM2uJHklMp6HBcuf60Wda5Y6RSn4I=;
        b=GvwExONO+ggcS0GkFBmMQThlpnIm2b7M+r0e5TxUj8b8DTRPtLYw0Kh9vEujufvWex
         Jw8RkK3rNxA46agqpEZYSp6HbvEKMM4ZPWYKrvGvuIiltU8Ze4wEb7FkEQkVTKDFQYas
         QVwDmZmgnMa3qPrJu5ON47PZX3TNPykamA43Jlt2IgvGuwqU++hy8TtzD8BAwutFODqa
         X6/yqcOYl2gEaum01l3OH8bmhLHJ9+MWSeloMiraGU/kwV5rs5CtHTCuBS7Bo4e28oMS
         hrC+3VVKcdu3rBXUxpu7XfHWCQFIS0InevSLdrm2doGxOXdgeVJ50Smn8WkorJwEV2+K
         /8Dg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUs85eh3ce86L1URQYXmJHv+2PxVFy5xHljT6FDPgoQliAiNOEc
	/EfN5mw660d6NbQJOhc+VItJUkehbYNCWnfw70x53tdDZUW6gZdBzrcPot3qSTTsL6F1rystjZy
	vkWsuaFV+w9niLS5Xp56s7t0eyvlpNFUNP+eX1HXtGbhNbEPaut3rbKC88WRYjXE=
X-Received: by 2002:a17:906:31c8:: with SMTP id f8mr3030664ejf.131.1559292647702;
        Fri, 31 May 2019 01:50:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzDmtPOnjN4g5X/cz77NuIWjO+ceXdz9hSSQbErbeM5AslsdPTUuvt/+Ls/UEWBw4QYOJzI
X-Received: by 2002:a17:906:31c8:: with SMTP id f8mr3030614ejf.131.1559292646967;
        Fri, 31 May 2019 01:50:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559292646; cv=none;
        d=google.com; s=arc-20160816;
        b=W7oqCDr0O8rryVfVJiWZ+gkbp+3PnxwHZVAKPSahPOV5pRFRQq/20Ck/rLg9XEEXJA
         wFf7cTjZu1YZkEAXi0jQmHgAZiIeLgZRQkzJZ4FwZBWbwFpKbpfU/cCuGQ+qQccPdzrY
         xgL3dSqfnGyc/g/oX72pTe/2BFiODSzkIxXyU2HbBpKtFRWWBreeU+2nVuMweIUQGPOl
         11k+Q8tJ+/t/6zkgDpQvIcKr+YCEfLZBv9eavFEKK1DaPmhMaS1zmZm+K8ehvQednnQl
         LfW9NCnsH7bLjbJeOE2zF/dWBe5oJMU7ayinpe18UeZmZLg1/AG8RtZ9RruLT1juysCK
         1UAw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Jai/c1DPn86hELIM2uJHklMp6HBcuf60Wda5Y6RSn4I=;
        b=obmlbE6DxeprsGKdaa96thEEIHnyzCXhe53wTxuEj1PBJ2N647PV6wzEpNxBfFBmMj
         E0s6iA4Ptt/p2/tJQzWD3npVcHfnzxbzZjyXjpAjrc2j8/Zs4+w+nSXcX6FUlpll2XOH
         mX9OnoTblKTIc0Z5RlyzSXLdw9/dkNSxdrOSmUpVwQfTnVTGDUYUKAxB/nfr7ySGaAuq
         l44mHX6tdNzXP8APuRnDxb9zm+iEF5pV3NolRMSU54qhDNatGRMZC0SrdAMxwdACAHC2
         m1KdjZZG/u2HkQafssJf0jPUFLf8nEduzFlkqLBobRRgKBWyqCczyKyew81HZ2bcEpVg
         Tbug==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z21si143945edz.277.2019.05.31.01.50.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 May 2019 01:50:46 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 2BDD5AF55;
	Fri, 31 May 2019 08:50:46 +0000 (UTC)
Date: Fri, 31 May 2019 10:50:44 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>, jannh@google.com,
	oleg@redhat.com, christian@brauner.io, oleksandr@redhat.com,
	hdanton@sina.com
Subject: Re: [RFCv2 3/6] mm: introduce MADV_PAGEOUT
Message-ID: <20190531085044.GJ6896@dhcp22.suse.cz>
References: <20190531064313.193437-1-minchan@kernel.org>
 <20190531064313.193437-4-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190531064313.193437-4-minchan@kernel.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 31-05-19 15:43:10, Minchan Kim wrote:
> When a process expects no accesses to a certain memory range
> for a long time, it could hint kernel that the pages can be
> reclaimed instantly but data should be preserved for future use.
> This could reduce workingset eviction so it ends up increasing
> performance.
> 
> This patch introduces the new MADV_PAGEOUT hint to madvise(2)
> syscall. MADV_PAGEOUT can be used by a process to mark a memory
> range as not expected to be used for a long time so that kernel
> reclaims the memory instantly. The hint can help kernel in deciding
> which pages to evict proactively.

Again, are there any restictions on what kind of memory can be paged out?
Private/Shared, anonymous/file backed. Any restrictions on mapping type.
Etc. Please make sure all that is in the changelog.

What are the failure modes? E.g. what if the swap is full, does the call
fails or it silently ignores the error?

Thanks!
-- 
Michal Hocko
SUSE Labs

