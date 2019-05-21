Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 075B4C04AAF
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 15:44:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BD23D208C3
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 15:44:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BD23D208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3F3B66B0003; Tue, 21 May 2019 11:44:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3A8696B0006; Tue, 21 May 2019 11:44:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 294A46B000A; Tue, 21 May 2019 11:44:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0B1956B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 11:44:27 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id y13so17697300qtc.7
        for <linux-mm@kvack.org>; Tue, 21 May 2019 08:44:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=wwgXvngLUewduEoJk6vGYKWssdUC6gdpM8dVj9HDemM=;
        b=T8xgwQYnlz9a/4vbsoV5E1bYodduy57J3bC8oo7m9z0XgyLo6Mhkxkhf3Fo8SR7UHU
         QSeAXZ+9HMDge4T/H4NZQgH5cXWjuTK6GcMYU848yDSpz8q5Vli6qjjHrszvHmkPToKr
         fd1IKF11sEhVGWx2qg11HjqQxlX5zDCGxizzt0tb1Sj2vswQgjuHm3aEVfSh+lZM8zok
         JUngOmCD//BHRxgTp48jtbx4v5LE4boCT961Yu8yFSooS/S3NbLWv3t8dv3gGtn8xrjs
         RuXmcXzO3LrDaZOz9DP50V6EnJozkknQ50AV9EkN1+U8tOn3xlSzLA7Ag7WnpXdfW0sl
         jOHA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW1TVyHczZTG5+MkW9Z/iBsCehsoqtuo6+RqAx8LZ6R1uO/toCV
	JkWDAmBbHUr8f7lpsXLYR6bkH6MFNnYthCcyazKEeWOymOjWBSM3lhwFLS4TnN7NSYT3f80ul2r
	DgKTNucMSSjCdBCpKUiut93ogbuHRwNZQ3keMvNc4bN0FUn8/mscu8MAXddB21sfq9Q==
X-Received: by 2002:a0c:88d1:: with SMTP id 17mr16189879qvo.116.1558453466819;
        Tue, 21 May 2019 08:44:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw/ThDT8PWrWGQxSogdEx2rj8nvezOXXOCkMCVLBq8TwPelMXeH0/GWKEeCGmj1GfbFpAZd
X-Received: by 2002:a0c:88d1:: with SMTP id 17mr16189818qvo.116.1558453466161;
        Tue, 21 May 2019 08:44:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558453466; cv=none;
        d=google.com; s=arc-20160816;
        b=JC2pHCiFR1mKs79nPu56SKLR0UPb/DiXMv6fhQdCbpXGjOAq5v5dN94Vom2HMMxJoK
         gvJUMoMCnMBkstKGNV1cU3GTWcOBg/vAdrEU4DwVDZ12eVHdQb0yj3loZAP28Q8fp6tS
         5KGPwzTHmdH6pIz4QYKnsxlQxGtC7GC/8ujxF3tpStu7/f6Op22SMt0NAsAslqiUyGFw
         9CDSuMf9D9UZkvkle5OglQlSFfIQv+9C7fUuUZADvwk5q6A30TuhMEkptZvGdf0zkYbZ
         ulBURbUF7UBDKsd05N6+2sR56PV+Si+O20/gKwThws4bjFAhNRxtQMgEB0AkSXLEsJbE
         rTlQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=wwgXvngLUewduEoJk6vGYKWssdUC6gdpM8dVj9HDemM=;
        b=taqxCAtUBzqEkhvSpDgWDSROdB8XlHpnZmHk6NDZKJp7GHLL2CdIU7h5+WOOk3E0nq
         3SseD45R2X160c/BZqKRASjXMGwHNCiJM4YzHIVvIrSLIpbySnDuBkbWzT+Wl4utnOBF
         jBWzRiHK2G9noaccpHZvw9+lYjU/P5d9A5UpFixg4gqcPL40zn7WTwzU59rU0F/UaIpb
         19lkd5vJK4/euE1uVh+iGRyb8bEWwP3hHCXuuFN3AnPx+/8cbTMHSXFcaANnkRkQpAI6
         UwpQxY3v+RNIxH/B8tLHRqfAQiejO6icr0HwGRFX58bY/ddH0SWF6+eHnqFBRwQqYd3a
         2M1g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p5si5907334qke.193.2019.05.21.08.44.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 May 2019 08:44:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 53D0AC05E760;
	Tue, 21 May 2019 15:44:15 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.178])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 3DA9D17F34;
	Tue, 21 May 2019 15:44:13 +0000 (UTC)
Date: Tue, 21 May 2019 11:44:11 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Daniel Vetter <daniel.vetter@ffwll.ch>
Cc: DRI Development <dri-devel@lists.freedesktop.org>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	David Rientjes <rientjes@google.com>,
	Paolo Bonzini <pbonzini@redhat.com>,
	Daniel Vetter <daniel.vetter@intel.com>
Subject: Re: [PATCH 1/4] mm: Check if mmu notifier callbacks are allowed to
 fail
Message-ID: <20190521154411.GD3836@redhat.com>
References: <20190520213945.17046-1-daniel.vetter@ffwll.ch>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190520213945.17046-1-daniel.vetter@ffwll.ch>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Tue, 21 May 2019 15:44:20 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 20, 2019 at 11:39:42PM +0200, Daniel Vetter wrote:
> Just a bit of paranoia, since if we start pushing this deep into
> callchains it's hard to spot all places where an mmu notifier
> implementation might fail when it's not allowed to.
> 
> Inspired by some confusion we had discussing i915 mmu notifiers and
> whether we could use the newly-introduced return value to handle some
> corner cases. Until we realized that these are only for when a task
> has been killed by the oom reaper.
> 
> An alternative approach would be to split the callback into two
> versions, one with the int return value, and the other with void
> return value like in older kernels. But that's a lot more churn for
> fairly little gain I think.
> 
> Summary from the m-l discussion on why we want something at warning
> level: This allows automated tooling in CI to catch bugs without
> humans having to look at everything. If we just upgrade the existing
> pr_info to a pr_warn, then we'll have false positives. And as-is, no
> one will ever spot the problem since it's lost in the massive amounts
> of overall dmesg noise.
> 
> v2: Drop the full WARN_ON backtrace in favour of just a pr_warn for
> the problematic case (Michal Hocko).
> 
> v3: Rebase on top of Glisse's arg rework.
> 
> v4: More rebase on top of Glisse reworking everything.
> 
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: "Christian König" <christian.koenig@amd.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Daniel Vetter <daniel.vetter@ffwll.ch>
> Cc: "Jérôme Glisse" <jglisse@redhat.com>
> Cc: linux-mm@kvack.org
> Cc: Paolo Bonzini <pbonzini@redhat.com>
> Reviewed-by: Christian König <christian.koenig@amd.com>
> Signed-off-by: Daniel Vetter <daniel.vetter@intel.com>

Reviewed-by: Jérôme Glisse <jglisse@redhat.com>

> ---
>  mm/mmu_notifier.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
> index ee36068077b6..c05e406a7cd7 100644
> --- a/mm/mmu_notifier.c
> +++ b/mm/mmu_notifier.c
> @@ -181,6 +181,9 @@ int __mmu_notifier_invalidate_range_start(struct mmu_notifier_range *range)
>  				pr_info("%pS callback failed with %d in %sblockable context.\n",
>  					mn->ops->invalidate_range_start, _ret,
>  					!mmu_notifier_range_blockable(range) ? "non-" : "");
> +				if (!mmu_notifier_range_blockable(range))
> +					pr_warn("%pS callback failure not allowed\n",
> +						mn->ops->invalidate_range_start);
>  				ret = _ret;
>  			}
>  		}
> -- 
> 2.20.1
> 

