Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 55C86C433FF
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 07:24:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 24E53217D4
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 07:24:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 24E53217D4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 97BC08E0003; Tue, 30 Jul 2019 03:24:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 904DE8E0002; Tue, 30 Jul 2019 03:24:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7CD548E0003; Tue, 30 Jul 2019 03:24:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2AB988E0002
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 03:24:42 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id z20so39795456edr.15
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 00:24:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=jhRzIYYEmuVUOTGwaq+DyR74kZDRRNMzR/NeqxkZ39w=;
        b=JhKtO9C6OVog41QKRjlrVDUad3XnjmznyP1yu4gV8ch7IhC9HAYSEFdc0V3g2HD36F
         fgUc3MBqNwFOnbFEujEAWPJ++LSO7rjGT9NkscyYYKqdKvUEWtXqK7qMylzjyxCBx86l
         rSaO7GVmSjyRhB7QhWJtdERgTAETlO+Hn+N44FgmSjqGYA6OfEFhWVAg50fWFdHDKocc
         eiX1HMrFj7YAs8G3Skj0r6oPwzU62PaWHk1Luld3rdV68ab4AvHcavSc6RhTHk4lY1lf
         lUa7FBvBAKkpDq2VEIePCesFIkzEwvbx2fi7fypHyy6afrvjBo+z/CiUfoWEA3lcHRJL
         lM5g==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUgOrm6iKArVrpXTmj0E7POiVKz4hg4iJXrimnNEIsLqZoA36dz
	3XNwdiE33iTtMDAqtjSpiGnh9Yk6S8uIlm+BwrDS0xZV6zCIPHoZSEy674Uxkd8lzThdTP8s3gZ
	+4F8HQA5qSOUdtm26Iq7L6MGx1aV9imQlorAn7uqahhG4QB1gmRX3UkRKVDG78Yw=
X-Received: by 2002:aa7:d404:: with SMTP id z4mr99929084edq.131.1564471481738;
        Tue, 30 Jul 2019 00:24:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwOXgg6v8fdrRO4MN6zcnKQtQpV4V8BwiMOtsugrXBct4/0QTAH4974zKTx+rbjHe4FJC8t
X-Received: by 2002:aa7:d404:: with SMTP id z4mr99929036edq.131.1564471480756;
        Tue, 30 Jul 2019 00:24:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564471480; cv=none;
        d=google.com; s=arc-20160816;
        b=zCTnhm8cQzBw2pKzqeeJYkqG4864arzkV2nuifiuJyoszrYqmISBbkFWhblHL8Mc29
         DNR65MsZMoGRRVO2QovfMCPvXtw07e+ffb6tHt2Hy6w2tua2JDU1eY8UQ2UVFz2IJv12
         FFi/dw9u3cO0xHQz5TQW7jptLD5S+lxqY3dQlxNaIBqXnovPWEFLwmLcpFOpd8Xqsdp4
         DWJ7ppIzfn4T69Mv7yMNK/1x8LhEkpQ1O/q7pYK5dmOC+JZKJ7NnPpD8YKAalsKeh5sE
         lRz1ATx+X0NVJfVKHGRF1LQxFUvvAuU8cZy7BLXHL8nfly8+PU6n1FOFvn9Ti6BC19pq
         HBKg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=jhRzIYYEmuVUOTGwaq+DyR74kZDRRNMzR/NeqxkZ39w=;
        b=R/avMltmanTyvydsZ7CZVlQF8P7mgdEMB90Y0N7wSnvG+bI+5jLg9Rs14w5Q8I2YKt
         Rmaw+ty6AyeH8c55HvgITysFeazdy7s+wxt5OwJSk5XOcXQduMI4Igkp9gSO6q7ScrQ8
         6lao1Jyo0QUhB1Bl3PV3YdIKS3sRnzKM8+mEmthYT49CGduSlDP8KxEMqfyV7rw9klWh
         2xj8O5IsVMzRi9szeAKwHFWIT2LEcn00PbvDRRFH6XUENdSE6rguHQEu/9RuykPugTPC
         5z2T0vPY9bIBzuyQ3z43wVLqLgfM+Pl+pMyargdwZWdJAiHnv2N+hLOPHK/+zqzMhKHC
         10pA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f15si19574864edf.297.2019.07.30.00.24.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 00:24:40 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 1B770AE5C;
	Tue, 30 Jul 2019 07:24:40 +0000 (UTC)
Date: Tue, 30 Jul 2019 09:24:39 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Waiman Long <longman@redhat.com>
Cc: Rik van Riel <riel@surriel.com>, Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	Phil Auld <pauld@redhat.com>
Subject: Re: [PATCH v3] sched/core: Don't use dying mm as active_mm of
 kthreads
Message-ID: <20190730072439.GL9330@dhcp22.suse.cz>
References: <20190729210728.21634-1-longman@redhat.com>
 <ec9effc07a94b28ecf364de40dee183bcfb146fc.camel@surriel.com>
 <3e2ff4c9-c51f-8512-5051-5841131f4acb@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3e2ff4c9-c51f-8512-5051-5841131f4acb@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 29-07-19 17:42:20, Waiman Long wrote:
> On 7/29/19 5:21 PM, Rik van Riel wrote:
> > On Mon, 2019-07-29 at 17:07 -0400, Waiman Long wrote:
> >> It was found that a dying mm_struct where the owning task has exited
> >> can stay on as active_mm of kernel threads as long as no other user
> >> tasks run on those CPUs that use it as active_mm. This prolongs the
> >> life time of dying mm holding up some resources that cannot be freed
> >> on a mostly idle system.
> > On what kernels does this happen?
> >
> > Don't we explicitly flush all lazy TLB CPUs at exit
> > time, when we are about to free page tables?
> 
> There are still a couple of calls that will be done until mm_count
> reaches 0:
> 
> - mm_free_pgd(mm);
> - destroy_context(mm);
> - mmu_notifier_mm_destroy(mm);
> - check_mm(mm);
> - put_user_ns(mm->user_ns);
> 
> These are not big items, but holding it off for a long time is still not
> a good thing.

It would be helpful to give a ball park estimation of how much that
actually is. If we are talking about few pages worth of pages per idle
cpu in the worst case then I am not sure we want to find an elaborate
way around that. We are quite likely having more in per-cpu caches in
different subsystems already. It is also quite likely that large
machines with many CPUs will have a lot of memory as well.
-- 
Michal Hocko
SUSE Labs

