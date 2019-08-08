Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 71B1EC0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 16:32:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2F8CA2173E
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 16:32:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2F8CA2173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C051E6B000E; Thu,  8 Aug 2019 12:32:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B8E326B0010; Thu,  8 Aug 2019 12:32:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A55686B0266; Thu,  8 Aug 2019 12:32:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 50DB36B000E
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 12:32:32 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b12so58512175ede.23
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 09:32:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=MVBWtkHdRnfuS21lrUs4i3Ylv1eitpUH0JZwxhadCoc=;
        b=eckH/4REV4vDLPxrTih50Ba8AiEBo9ibRmCGLcNhlX3TFK7b0RpF6EjPw2y3Ip06Pg
         3Xx8/S4TGyXfQaKcv6hFNbVAdWGEdaOkakRO5TNLsQfPgJ3EQHgNY66T4a+LP7bBq9pi
         MT9dPID9Rqb23Ydbz4nETiMXEuyimjWU5nzeJ4vHPwW7ImMdvxMLGt0cK0W9snNTCC8j
         svg/tgBh5g2jtil7+RfE8o0F9/X7C1cvf2QR3zpCBrFxLIVhKAS6RtNmF7iz59pl90FS
         7/j8n+WXZFMQRctXz8KZ6gyds6dTFvaAqQmXf62WbY2EGfoxDBTFV7DL6ccbDH5AbKzk
         T+gw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUERJbtxaYeYgLoEdWdDD4/TJa+jNJG94UTv3u/3VwSQtGK5hcN
	9wz3bRnF1W7CkauBK3BEHCjDxSKxClbKBYBQsBCrjwmycVuChpP0qn0ukeR5+jRa/bealLdqzZI
	/N1Nl88lPEmCdI8uyzduq6ceFPmMass+gxbrnkddCGiNmovNTxe3HwgAdzY5gM0U=
X-Received: by 2002:a17:906:304d:: with SMTP id d13mr13773079ejd.99.1565281951855;
        Thu, 08 Aug 2019 09:32:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy1Xot+wPZMS4TPKu+NAVTrOgi+Sp//urR+j01s3+1V0dpA+pQjYg36zecH1cJ+1At75CCQ
X-Received: by 2002:a17:906:304d:: with SMTP id d13mr13773014ejd.99.1565281950825;
        Thu, 08 Aug 2019 09:32:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565281950; cv=none;
        d=google.com; s=arc-20160816;
        b=OCtRIkp7nCbWK+EUBcFTySZj8Z5C8Kds9aD2LWLuJdrgCCnzyfFZ0WC1YWkW5vCb6E
         VWK73SWQP9rrzUb5m5T7pbCvPbzQdmHubFJXIMXjcptG06VHsAjXHooiOU4uCGCfT50R
         ujO2WG4VPMX97frhVftFLEYAEwWJp7iqYenu/mZiEvLvJwCu99Yw+qiH38ABVk5Sig4B
         dsJQd0GJxXk0bwjAnK92z7tjt//ZtwzMPYCZSOEGufS/PXNe2GXNQHvJTsWTnK1c6Xuu
         sA7LBpgqKp4BdLlL2FVm/u+kA93gG9JYQzlL+3qWWd+U30V2z9uHZugXr+5xaN7JJFfG
         QI+A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=MVBWtkHdRnfuS21lrUs4i3Ylv1eitpUH0JZwxhadCoc=;
        b=Fm12oa9WrUs45ZWigMI0tKIi6elp56cIvPlAQdlwrbGk2x+GjGpIvW8kywCXsku0zb
         kJyw+O+tmh5PRXSoNckNgl9m4wK76xR31vFpVFkxX45ezf7VaFihTt+Lj6yOZLs3zoQY
         yeTjT7ICZ3nuBq8520LBraS75t9ulKaKEGlEbgcVAyhj4XRPDYFzcFYhCUTcwPwvFvFq
         CwnplQqwNv7fiTJdwjyKVcK21twTG+F9w/QbmyMlUSP0NcY16Qex/PuWUni0a2nPymFZ
         Fq5lrA95V+AyALgnY8Du+gL+8z5q0QHgOtoN0fztJhsRdivnVRf/A7aJWGJDK/mOVMVk
         EVHg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p9si816397ejf.115.2019.08.08.09.32.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 09:32:30 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id DEBE0AE7F;
	Thu,  8 Aug 2019 16:32:29 +0000 (UTC)
Date: Thu, 8 Aug 2019 18:32:28 +0200
From: Michal Hocko <mhocko@kernel.org>
To: ndrw.xf@redhazel.co.uk
Cc: Johannes Weiner <hannes@cmpxchg.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	"Artem S. Tashkinov" <aros@gmx.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
Subject: Re: Let's talk about the elephant in the room - the Linux kernel's
 inability to gracefully handle low memory pressure
Message-ID: <20190808163228.GE18351@dhcp22.suse.cz>
References: <CAJuCfpHhR+9ybt9ENzxMbdVUd_8rJN+zFbDm+5CeE2Desu82Gg@mail.gmail.com>
 <398f31f3-0353-da0c-fc54-643687bb4774@suse.cz>
 <20190806142728.GA12107@cmpxchg.org>
 <20190806143608.GE11812@dhcp22.suse.cz>
 <CAJuCfpFmOzj-gU1NwoQFmS_pbDKKd2XN=CS1vUV4gKhYCJOUtw@mail.gmail.com>
 <20190806220150.GA22516@cmpxchg.org>
 <20190807075927.GO11812@dhcp22.suse.cz>
 <20190807205138.GA24222@cmpxchg.org>
 <20190808114826.GC18351@dhcp22.suse.cz>
 <806F5696-A8D6-481D-A82F-49DEC1F2B035@redhazel.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <806F5696-A8D6-481D-A82F-49DEC1F2B035@redhazel.co.uk>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 08-08-19 16:10:07, ndrw.xf@redhazel.co.uk wrote:
> 
> 
> On 8 August 2019 12:48:26 BST, Michal Hocko <mhocko@kernel.org> wrote:
> >> 
> >> Per default, the OOM killer will engage after 15 seconds of at least
> >> 80% memory pressure. These values are tunable via sysctls
> >> vm.thrashing_oom_period and vm.thrashing_oom_level.
> >
> >As I've said earlier I would be somehow more comfortable with a kernel
> >command line/module parameter based tuning because it is less of a
> >stable API and potential future stall detector might be completely
> >independent on PSI and the current metric exported. But I can live with
> >that because a period and level sounds quite generic.
> 
> Would it be possible to reserve a fixed (configurable) amount of RAM for caches,

I am afraid there is nothing like that available and I would even argue
it doesn't make much sense either. What would you consider to be a
cache? A kernel/userspace reclaimable memory? What about any other in
kernel memory users? How would you setup such a limit and make it
reasonably maintainable over different kernel releases when the memory
footprint changes over time?

Besides that how does that differ from the existing reclaim mechanism?
Once your cache hits the limit, there would have to be some sort of the
reclaim to happen and then we are back to square one when the reclaim is
making progress but you are effectively treshing over the hot working
set (e.g. code pages)

> and trigger OOM killer earlier, before most UI code is evicted from memory?

How does the kernel knows that important memory is evicted? E.g. say
that your graphic stack is under pressure and it has to drop internal
caches. No outstanding processes will be swapped out yet your UI will be
completely frozen like.

> In my use case, I am happy sacrificing e.g. 0.5GB and kill runaway
> tasks _before_ the system freezes. Potentially OOM killer would also
> work better in such conditions. I almost never work at close to full
> memory capacity, it's always a single task that goes wrong and brings
> the system down.

If you know which task is that then you can put it into a memory cgroup
with a stricter memory limit and have it killed before the overal system
starts suffering.

> The problem with PSI sensing is that it works after the fact (after
> the freeze has already occurred). It is not very different from
> issuing SysRq-f manually on a frozen system, although it would still
> be a handy feature for batched tasks and remote access.

Not really. PSI is giving you a matric that tells you how much time you
spend on the memory reclaim. So you can start watching the system from
lower utilization already.
-- 
Michal Hocko
SUSE Labs

