Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 793E6C0650F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 13:11:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 42DE920665
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 13:11:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 42DE920665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E6B248E0005; Tue, 30 Jul 2019 09:11:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DF39F8E0001; Tue, 30 Jul 2019 09:11:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D31658E0005; Tue, 30 Jul 2019 09:11:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9DF188E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 09:11:29 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id i9so40308097edr.13
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 06:11:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=IFn/4eI5GivNjuYfQ2mhxRun0FoouRkFwk+1cs/Wygo=;
        b=L86t+LFT1RNWx5GzYDD4A7Haz+dgl9EEkkFkEyKrWfBZLcD+LskWXXznD3OJNoniDw
         1g6MlVt0Fj0MF3Lg9C6SgjSLHwaPQCygXoQdZuCvfL5WJoFnO2dgjwaPF6wnY9H5sMKY
         3tjuPCCT2yb+xdELAOOP3HxMOVcjK228j4fQp16WhdB3n+199AF5lBfnA2LIDXcNrvDL
         hiamL9dlsEbbj2oWKpTK+lJRQN11tEJMDoKbHchbMeFW9LCX7Pblj8HooGk6z4L7avuN
         aN98gXM/p8879Mle1rJ/nbbyDFmdK0T5C6Ss2VI2kduHti/b3oNlwb4wbiwzCD/wVbC8
         FY5A==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVDb08IyQ2GO/rbiUPlDC/t6EASHztx45MWcyNArpn87FE55Rcq
	jiQ3hqGF9yl7CfDybOz3FTcBm9YWzSP1XgpU9b1GQXMVlASsaCzv5M4V/gLIUTDnvCf5W1xfOW2
	G7ZRlCexUny3f2GCToR+oGXFTe30w/ZKY1rZyHuGW1iqEn+uo21ZLeX/1zi7TDCI=
X-Received: by 2002:a50:8bfd:: with SMTP id n58mr100558013edn.272.1564492289243;
        Tue, 30 Jul 2019 06:11:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwG5/tyBBl/19Gchf3hA5Lmz5WaxcsbC5EujBYHIAwFSvDkMCLLi5Q7qc3zkpIVTSBOkBQP
X-Received: by 2002:a50:8bfd:: with SMTP id n58mr100557947edn.272.1564492288515;
        Tue, 30 Jul 2019 06:11:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564492288; cv=none;
        d=google.com; s=arc-20160816;
        b=bZV4VKzHrQl07qp0g1pjTTeF6WT0I6LSaKmRKpfjoNcqFBr7T1oewXUo3Lz9DdgKW9
         oZaKBlAljLz+C9DCE9rrjqPuVLzA/ocZ2fV/T+8+fGfIKO6WUqgPf6XBl7929j24XxTC
         EYx4jefrZ6tyAeK4tgKDp/H+tMPKqw5r8/JWNmbQ6YAp8eB5QhWIO9A3yw3dAYH4xRfJ
         S1/qPCgRZ4ayXISv/lZOMfZrmNfr/7THz0mE3eFRyclDa3i7LTYCDhGWS/w1beeOSNV1
         8Zq08xRQJ+95Mn6aMo/m8agU5UKsRawl2dnYoRtn1p4C6A1FInygsx5XFIWrYlg7oTGI
         94Qw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=IFn/4eI5GivNjuYfQ2mhxRun0FoouRkFwk+1cs/Wygo=;
        b=A2eWblfoZvp+HAJAxNFzKIj8mT9beGt4kJw/VJ6ZO29+9waE6XH86RY20fip0vdOZ6
         0CJJXYSzY6G8XlLqtny8j4Tpr47IBEWt6DKerMLzBIFeFOLsXBRqUlQj24O3Bij2tcOa
         Syf4bUMTfMzrmdAi+2ZkEEocCgeYIx+q25Mz+GXO29XBMa8h1Qi7qxXzVRxafPgC7a35
         DoV4swW4DehwKi+snbaPb9sa6CynsZ/RgfpHmh5c3kr3vihrpN4m3vIuAzH5J2kyvID9
         0TAC04Ftv9u8QCcKT7dJ2tfGPSWObeTrFFaaOOjBWYbpg/ku5v2t9+B6VWsnzaQv5TZc
         00oA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l23si16435646ejr.318.2019.07.30.06.11.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 06:11:28 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 02C8DB03A;
	Tue, 30 Jul 2019 13:11:27 +0000 (UTC)
Date: Tue, 30 Jul 2019 15:11:27 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Vlastimil Babka <vbabka@suse.cz>, Zi Yan <zi.yan@cs.rutgers.edu>,
	Stefan Priebe - Profihost AG <s.priebe@profihost.ag>,
	"Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/2] Revert "mm, thp: restore node-local hugepage
 allocations"
Message-ID: <20190730131127.GT9330@dhcp22.suse.cz>
References: <20190503223146.2312-1-aarcange@redhat.com>
 <20190503223146.2312-3-aarcange@redhat.com>
 <alpine.DEB.2.21.1905151304190.203145@chino.kir.corp.google.com>
 <20190520153621.GL18914@techsingularity.net>
 <alpine.DEB.2.21.1905201018480.96074@chino.kir.corp.google.com>
 <20190523175737.2fb5b997df85b5d117092b5b@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190523175737.2fb5b997df85b5d117092b5b@linux-foundation.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 23-05-19 17:57:37, Andrew Morton wrote:
[...]
> It does appear to me that this patch does more good than harm for the
> totality of kernel users, so I'm inclined to push it through and to try
> to talk Linus out of reverting it again.  

What is the status here? I do not see the patch upstream nor in the
mmotm tree.
-- 
Michal Hocko
SUSE Labs

