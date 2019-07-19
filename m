Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 14184C76188
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 06:14:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D70E821850
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 06:14:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D70E821850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4AC2E6B0007; Fri, 19 Jul 2019 02:14:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 45AFB6B0008; Fri, 19 Jul 2019 02:14:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 323958E0001; Fri, 19 Jul 2019 02:14:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id F0D8A6B0007
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 02:14:13 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id i9so21380964edr.13
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 23:14:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=U6lfhUTpLh8RwOJxXk2ilzCB0fStqbliWJAvXMuMpuQ=;
        b=Gat9GhizyCe5Hz9+ZycDG++zTTXXmXMr5q+6kA+Nd7Il/af1R4VtcZ6gBRN7LCHhQr
         kQlOT5ujsfpW680X44zaoVGxady7tLE1qQJTWTJPTX35IsJWss4THNnVRY11KGlDAdOc
         thBaHlF/ejaEDslPJWRYe6GPtN3fAGeL8fJyeXGIg+uXMkRl370a24uzmPeysD+KK3Zt
         cQmRhlMcNLGldkiX/0V4pnP5N2hHKr6brMzWlCQDpX4Dv1mo+9+G4Tss4ynfQfWyNV9P
         BEIAD3a3iZ8Uvj8duYLM5TE2X/1TMjnGxX+lxCEe2VvB4qQnvgic6UokAcbJ8TiFrvC7
         ZRHg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWwf0ZpolpsKfuJD/+26g53p/P98Gzk9/adBBJ3gPhoew1oE/Ek
	RsA8A4vqPvPiBLyhFmrg55ywcVTwweOp4QSaFPdDCJLO1n4h7ZrnXu6GhDTgrd429udN8Gn2zBu
	oE5a4pOr+ekE0krbgyoufyeX6ncDPSLT1P6LVO0DnpLpqID3t8cyD7EPirN44NNg=
X-Received: by 2002:a50:a56d:: with SMTP id z42mr45368951edb.241.1563516853568;
        Thu, 18 Jul 2019 23:14:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxNSAA+9fBlRWW53lEWvsdJn9UyoZXL7SuADI59USi87kHcLYCukboNehr6S3IgkvQWh4bc
X-Received: by 2002:a50:a56d:: with SMTP id z42mr45368911edb.241.1563516852895;
        Thu, 18 Jul 2019 23:14:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563516852; cv=none;
        d=google.com; s=arc-20160816;
        b=0iMTMPg7jqXz1TZ9VeppyUsqmYPkPQggl9ca3r8tg0zxLacPisV2REZoV3g7qiqIc7
         6wVzzKejavb4aLJ8dqMDCW+47hFRb2ujFjYXDT8Yq5CvgekZMbxzaT4T0c9ZpSqaBS6V
         C1tLOiO9t/CX6C+rlGoo3EL0p7dO5h8QDmxjzWgktVhud2jrZM+3YI25tSUw2EmG2HDP
         ds7+hqEg6c6Huv1Bi7quA6BBFD0Ld3Les3jdpbgPHUW6Mnm+NfaUiw+tN7eCDy00vyoC
         q2hW1DWgFDrps//RERw46mnb0dEDKn3Iyh/ISAYQCG1mmY0KcvEx92HFGVgnI/EdcpsX
         Xs6g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=U6lfhUTpLh8RwOJxXk2ilzCB0fStqbliWJAvXMuMpuQ=;
        b=J+9iCHNFYTrg3c+7ZI7dU6rWtueenIFN1nYfQZCobxahXAGsoibqlGpntTcBB82UNn
         OnWupG3G49w+rford1A4gflJfpo/16J9iPRQYMjzLUOkkJn6wbb9GcBMu4F0sNzMdktL
         xuuisbw8GEMW6LiSET9kHEuq2+G9cYPTfM2iV8AY17O8kFqMzoHPkZdtwJyTwi9VUSf5
         XsR2SjsPDooVLuXr3uQUU/epoHEAjfM3CzM8yO1lkiPaqBxuxdQ83QH5SKNVRjdhD/rF
         iYbfaa342igLqkZPc9VmaW9UZY2NL6uGvsLUBiKALCjr3FpbWBDCsGRY6M+nLdno2tJN
         4nww==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t2si277765edq.237.2019.07.18.23.14.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 23:14:12 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 376D3ACCE;
	Fri, 19 Jul 2019 06:14:12 +0000 (UTC)
Date: Fri, 19 Jul 2019 08:14:10 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Waiman Long <longman@redhat.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Roman Gushchin <guro@fb.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Shakeel Butt <shakeelb@google.com>,
	Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH v2 2/2] mm, slab: Show last shrink time in us when
 slab/shrink is read
Message-ID: <20190719061410.GJ30461@dhcp22.suse.cz>
References: <20190717202413.13237-1-longman@redhat.com>
 <20190717202413.13237-3-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190717202413.13237-3-longman@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 17-07-19 16:24:13, Waiman Long wrote:
> The show method of /sys/kernel/slab/<slab>/shrink sysfs file currently
> returns nothing. This is now modified to show the time of the last
> cache shrink operation in us.

Isn't this something that tracing can be used for without any kernel
modifications?
-- 
Michal Hocko
SUSE Labs

