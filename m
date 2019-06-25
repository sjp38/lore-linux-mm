Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4782EC48BD4
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 10:36:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 05C2D2084B
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 10:36:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 05C2D2084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9A0E46B0003; Tue, 25 Jun 2019 06:36:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 952978E0003; Tue, 25 Jun 2019 06:36:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8196B8E0002; Tue, 25 Jun 2019 06:36:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 32BC36B0003
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 06:36:53 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b12so24965918eds.14
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 03:36:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=rlZP8O4Gu+4XweOf/Sjj9q0ITCw6RM3/2hZjstdakzY=;
        b=prMbewPZt6ns1oraqgqgtEdUaST4khQ6NWcfVMAtMGU5xKVnoOn9N9oLGJEtdtVQg0
         znTM9YJ78UCDvn/f4jZ9/gPq9RlNls6K61oXQoTJtI+4Of/a8YyWtJuFIBQbGduNTDO8
         Bfc/lsdjj+cEOAag7lIO9RsLLtwkRvueEUGWc8gzqGuNvdQ1ATgSnRIwAiR8L0zVKu31
         er0fqm+Cem5SKNoSgGI5DCYFQPoK/CJEMcDGE9cET8cxp8mM3M2bobrajGDhtUTudujD
         0hPyd4Z5cjZyXdBHgjYrEqv4abMl3pepZj9Zsvo14iD1RAg3gWpF1EsQ7C9pmIiq32ra
         OTIg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVvBgGqAq05sZ9cX8wXYYYGkJ8MB6Nnanrmx4LtMCq2F4drq1TE
	uHHEinBrxKXEsT8Y51qO2wnqW8f8ebd/vpu/AVQDzAPb7pNc9EDC+6MohAMZddR7aH93IZX4PCT
	wBdBpJbXLhoYfQczjmBiaGp7GCrVlj24ERtwD4pRXoCcaqr8iThyRv7UA+NDhNv4=
X-Received: by 2002:a50:b1bd:: with SMTP id m58mr66378983edd.185.1561459012640;
        Tue, 25 Jun 2019 03:36:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx6qNUtZwHLa6tAEE2ZQXTEygV2OAvwnWvomvFrbCtoMiy4C6X7LTkcsoqXv5u6Hgp50FUM
X-Received: by 2002:a50:b1bd:: with SMTP id m58mr66378903edd.185.1561459011719;
        Tue, 25 Jun 2019 03:36:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561459011; cv=none;
        d=google.com; s=arc-20160816;
        b=Y6pAYuw08APOzjhpU02YlspEHawaIEL+yYMl5aG+1OOPqpp8sMA4gQSNC4BYC2rW2B
         LPutv8e2kvizMlHWSbvHoJp1DocbZ7BbM4UUsQco0wzGCkQuyZVgH1HEkgJoftIV4Pr8
         vPfFImYgJVRT4JQLm0CuQoU2xR0nn/Nwe7WkS9I5uP+Y/FW+vfkZUjm2hXSBOQWpEc+n
         Qk5dQPR0MT4mDkUhBnTLr32bcWFHjib8pGUdUtk91Da0rvDuLEzeO3SjXSem3ROCxxsS
         5VfVEU/OPsWfGVZ8U1FelU7ybJEtMpXcPd3vaO0vpGOnBUhHF8Cs7jL7xmpDYb7dtGAG
         zZLg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=rlZP8O4Gu+4XweOf/Sjj9q0ITCw6RM3/2hZjstdakzY=;
        b=zVaMB42Eqnju/7kfDtaoaCY/0eplCnlyTM/YMqYYhgsAK5KvMIj8sw195u5d8/meIr
         c7zWipWyujkOZVxtrdcamU6z5Cy5ZQttKZ0CQ1LHuZpNgIdAfw+HxE/KgUzsZINW7G3K
         BcXJDiRfbt98rvx2ydq7YheqYW6p1VGZ/gwrYKpMss2v4o/P3kZZ779n/rYuNwbFpi18
         u0Zv33dUMrbX7h8PSaceDrpBvn0vcJQ62h4YR0oLIQn/h7MQEmEDHPzX3K1VvkgTdMp2
         Cwwp9I3rWw164eemqoQhBZlUsQHupD2uqS953IOq75737cE5JP0nqUznl0C5LfIu3f2L
         07Vg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r5si71165edm.368.2019.06.25.03.36.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 03:36:51 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 49BABACCE;
	Tue, 25 Jun 2019 10:36:51 +0000 (UTC)
Date: Tue, 25 Jun 2019 12:36:50 +0200
From: Michal Hocko <mhocko@kernel.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>,
	Minchan Kim <minchan@kernel.org>, Vlastimil Babka <vbabka@suse.cz>,
	Linux Memory Management List <linux-mm@kvack.org>,
	"Wangkefeng (Kevin)" <wangkefeng.wang@huawei.com>
Subject: Re: Frequent oom introduced in mainline when migrate_highatomic
 replace migrate_reserve
Message-ID: <20190625103650.GI11400@dhcp22.suse.cz>
References: <5D1054EE.20402@huawei.com>
 <20190624081011.GA11400@dhcp22.suse.cz>
 <5D10CC1B.3080201@huawei.com>
 <20190624140120.GD11400@dhcp22.suse.cz>
 <5D10FE8F.2010906@huawei.com>
 <20190624175448.GG11400@dhcp22.suse.cz>
 <5D118C61.7040308@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5D118C61.7040308@huawei.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 25-06-19 10:52:17, zhong jiang wrote:
> On 2019/6/25 1:54, Michal Hocko wrote:
> > On Tue 25-06-19 00:47:11, zhong jiang wrote:
> >> On 2019/6/24 22:01, Michal Hocko wrote:
> >>> On Mon 24-06-19 21:11:55, zhong jiang wrote:
> >>>> [  652.272622] sh invoked oom-killer: gfp_mask=0x26080c0, order=3, oom_score_adj=0
> >>>> [  652.272683] CPU: 0 PID: 1748 Comm: sh Tainted: P           O    4.4.171 #8
> >>>> [  653.452827] Mem-Info:
> >>>> [  653.466390] active_anon:20377 inactive_anon:187 isolated_anon:0
> >>>> [  653.466390]  active_file:5087 inactive_file:4825 isolated_file:0
> >>>> [  653.466390]  unevictable:12 dirty:0 writeback:32 unstable:0
> >>>> [  653.466390]  slab_reclaimable:636 slab_unreclaimable:1754
> >>>> [  653.466390]  mapped:5338 shmem:194 pagetables:231 bounce:0
> >>>> [  653.466390]  free:1086 free_pcp:85 free_cma:0
> >>>> [  653.625286] Normal free:4248kB min:1696kB low:2120kB high:2544kB active_anon:81508kB inactive_anon:748kB active_file:20348kB inactive_file:19300kB unevictable:48kB isolated(anon):0kB isolated(file):0kB present:252928kB managed:180496kB mlocked:0kB dirty:0kB writeback:128kB mapped:21352kB shmem:776kB slab_reclaimable:2544kB slab_unreclaimable:7016kB kernel_stack:9856kB pagetables:924kB unstable:0kB bounce:0kB free_pcp:392kB local_pcp:392kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
> >>>> [  654.177121] lowmem_reserve[]: 0 0 0
> >>>> [  654.462015] Normal: 752*4kB (UME) 128*8kB (UM) 21*16kB (M) 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 4368kB
> >>>> [  654.601093] 10132 total pagecache pages
> >>>> [  654.606655] 63232 pages RAM
> >>> [...]
> >>>>>> As the process is created,  kernel stack will use the higher order to allocate continuous memory.
> >>>>>> Due to the fragmentabtion,  we fails to allocate the memory.   And the low memory will result
> >>>>>> in hardly memory compction.  hence,  it will easily to reproduce the oom.
> >>>>> How get your get such a large fragmentation that you cannot allocate
> >>>>> order-1 pages and compaction is not making any progress?
> >>>> >From the above oom report,  we can see that  there is not order-2 pages.  It wil hardly to allocate kernel stack when
> >>>> creating the process.  And we can easily to reproduce the situation when runing some userspace program.
> >>>>
> >>>> But it rarely trigger the oom when It do not introducing the highatomic.  we test that in the kernel 3.10.
> >>> I do not really see how highatomic reserves could make any difference.
> >>> We do drain them before OOM killer is invoked. The above oom report
> >>> confirms that there is indeed no order-3+ free page to be used.
> >> I mean that all order with migrate_highatomic is alway zero,  it can be  true that
> > Yes, highatomic is meant to be used for higher order allocations which
> > already do have access to memory reserves. E.g. via __GFP_ATOMIC.
> If current kernel have not use __GFP_ATOMIC to allocate memory,  highatomic will have not available higher order.
> And we have order-3 kernel stack allocation requirement in the system.  
> 
> There is not  memory reserve to use for us in the emergency situation,  which is different from migrate_reserve.
> Maybe I  think that we can change the reserve memory behaviour,  Not only reserve higher order in GFP_ATOMIC.

Let me repeat. This is unlikely to help for something like a fork code
path which can be triggered by userspace and no matter how much you
reserve it can get depleted easily. Your real problem is to require
an order-3 allocation for this particular path.
-- 
Michal Hocko
SUSE Labs

