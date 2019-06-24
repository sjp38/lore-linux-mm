Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C136C43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 14:01:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D16DA2145D
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 14:01:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D16DA2145D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 725808E0005; Mon, 24 Jun 2019 10:01:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6D4DB8E0002; Mon, 24 Jun 2019 10:01:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 59E458E0005; Mon, 24 Jun 2019 10:01:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 11B878E0002
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 10:01:24 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id y130so2223249wmg.1
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 07:01:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=qOvjzqnB7tQOIgkEiXYukuH4lfJOMzYq11gLXrZAwFI=;
        b=HJ/IJnIXAHRpjelnnWkYu5l0p7ug8HOHuUHOhE9rrtmU2IEh3oLra+Q/Cck0ew5zk6
         m58oIRLIBblOYTWwyYLiqri6BzlRzZhBXynGm7Rx88bkjyf+6Sbg3TcVwWu+VoQOXYgf
         5O3zwyC0SRa6hA5P33WU8Y+W/5ldKG5Zzh7VW8R4e1wZ51VEiiQyu8jW/GRp4fS/YErb
         TJfrOpKttpeFwHP3sWlYg1VYo0G5LjJgEVJg0Ad30jSwe5gfNNGOi07xp8D26a2VtW1n
         bhracM9mUE5O7LU7N++/chW+U3CP6gsjRu3ZeGyOzOBWr+jWYDdEeUhcncDJ5Jz5ILxq
         kqdQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUe2TIxIbsCTB2Pfa86qGPpMbVDTdCoN5vuIb24C0YFW6fH9keS
	7bmRL/oR3ayf5KqprOjdIIf1l4jhv+bv1i8jeEyBTK79Zuk/biZMuEKKHlTcMp1XHRr7s5br4Sa
	dIOV8z49+ByfZJ5BHncGVOSol50Dl+/JXoIkXvW0QqhdTxceeX3tNGUXBFUNrbyY=
X-Received: by 2002:a7b:c7d8:: with SMTP id z24mr16469931wmk.10.1561384883552;
        Mon, 24 Jun 2019 07:01:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyNQs1VwaUyk4S8orTPu/UYzsTFUg4iTkB95pqjB0XXWl4JjZkofuzOnh+eBlzkhvuRcrA+
X-Received: by 2002:a7b:c7d8:: with SMTP id z24mr16469863wmk.10.1561384882548;
        Mon, 24 Jun 2019 07:01:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561384882; cv=none;
        d=google.com; s=arc-20160816;
        b=xjY9S+C/m1ARehiLqrygY3j/nz7+sdvI4PmNbHOug5El03ptjbEnB1QAupJrP+5MPZ
         /KZ0bDbpq4ga+EiVBU1SmlzRwBEkPcPzYV8mtOw0/8wWxSgcu+lP8S2uy6sRQc/IzUTh
         wKg1zDtW94RAKltxi4KD8n2jqXwkn2A6QRbzpkD/LxNrH5k6beND11FsBVnul3Ib4z8p
         +rpqHiwCp7fFx+WRMYbWZiGfJdklhLlL2YJDaDJVEN3iil7FHyMPZ3xaSqIMJc4kK06X
         RGFS7kqVFLMvitn0WMtPjluDctNgLmMhoucnuGEDR4YZ7WHqn3vowWpO+aP3Mr6Yvbx/
         LhgA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=qOvjzqnB7tQOIgkEiXYukuH4lfJOMzYq11gLXrZAwFI=;
        b=jbU8ULeIRMpyHBlFvEcrvfdNr/fxv+i5hqZ06Tfqj1Mr5tiCcMxUOul3KsNI3PDjK3
         IJCvTon5MYZ833CrYADSc98HsDI/BmPbcO3lsxCCJ7WFQHt9BiGFIn25H7ak1GFsXV0D
         B6aXlrdUg1hefWEc3McuIDsp5W3oNl9Id6txwRDAaVoMqeGuvQJbW1OdZoIsog302ROn
         uanmM3nPI4mYwBEPVW7LQjoZOJvIkNsJjf/4aDoMV3tO8da3CeIXSL2wGWs9erkVfc7L
         iJTrP4FrAmcOfihyhTw3c9F+ywfUURH/9ORw29B7dNVsJRTodXJcXUqhqEH9rWWRsYpj
         2JRA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z21si9677177edz.277.2019.06.24.07.01.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jun 2019 07:01:22 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 09EB1ADC4;
	Mon, 24 Jun 2019 14:01:22 +0000 (UTC)
Date: Mon, 24 Jun 2019 16:01:20 +0200
From: Michal Hocko <mhocko@kernel.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>,
	Minchan Kim <minchan@kernel.org>, Vlastimil Babka <vbabka@suse.cz>,
	Linux Memory Management List <linux-mm@kvack.org>,
	"Wangkefeng (Kevin)" <wangkefeng.wang@huawei.com>
Subject: Re: Frequent oom introduced in mainline when migrate_highatomic
 replace migrate_reserve
Message-ID: <20190624140120.GD11400@dhcp22.suse.cz>
References: <5D1054EE.20402@huawei.com>
 <20190624081011.GA11400@dhcp22.suse.cz>
 <5D10CC1B.3080201@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5D10CC1B.3080201@huawei.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 24-06-19 21:11:55, zhong jiang wrote:
> [  652.272622] sh invoked oom-killer: gfp_mask=0x26080c0, order=3, oom_score_adj=0
> [  652.272683] CPU: 0 PID: 1748 Comm: sh Tainted: P           O    4.4.171 #8
> [  653.452827] Mem-Info:
> [  653.466390] active_anon:20377 inactive_anon:187 isolated_anon:0
> [  653.466390]  active_file:5087 inactive_file:4825 isolated_file:0
> [  653.466390]  unevictable:12 dirty:0 writeback:32 unstable:0
> [  653.466390]  slab_reclaimable:636 slab_unreclaimable:1754
> [  653.466390]  mapped:5338 shmem:194 pagetables:231 bounce:0
> [  653.466390]  free:1086 free_pcp:85 free_cma:0
> [  653.625286] Normal free:4248kB min:1696kB low:2120kB high:2544kB active_anon:81508kB inactive_anon:748kB active_file:20348kB inactive_file:19300kB unevictable:48kB isolated(anon):0kB isolated(file):0kB present:252928kB managed:180496kB mlocked:0kB dirty:0kB writeback:128kB mapped:21352kB shmem:776kB slab_reclaimable:2544kB slab_unreclaimable:7016kB kernel_stack:9856kB pagetables:924kB unstable:0kB bounce:0kB free_pcp:392kB local_pcp:392kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
> [  654.177121] lowmem_reserve[]: 0 0 0
> [  654.462015] Normal: 752*4kB (UME) 128*8kB (UM) 21*16kB (M) 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 4368kB
> [  654.601093] 10132 total pagecache pages
> [  654.606655] 63232 pages RAM
[...]
> >> As the process is created,  kernel stack will use the higher order to allocate continuous memory.
> >> Due to the fragmentabtion,  we fails to allocate the memory.   And the low memory will result
> >> in hardly memory compction.  hence,  it will easily to reproduce the oom.
> > How get your get such a large fragmentation that you cannot allocate
> > order-1 pages and compaction is not making any progress?
> >From the above oom report,  we can see that  there is not order-2 pages.  It wil hardly to allocate kernel stack when
> creating the process.  And we can easily to reproduce the situation when runing some userspace program.
> 
> But it rarely trigger the oom when It do not introducing the highatomic.  we test that in the kernel 3.10.

I do not really see how highatomic reserves could make any difference.
We do drain them before OOM killer is invoked. The above oom report
confirms that there is indeed no order-3+ free page to be used.

It is hard to tell whether compaction has done all it could but there
have many changes in this area since 4.4 so I would be really curious
about the current upstream kernel behavior. I would also note that
relying on order-3 allocation is far from optimal. I am not sure what
exactly copy_process.part.2+0xe4 refers to but if this is really a stack
allocation then I would consider such a large stack really dangerous for
a small system.
-- 
Michal Hocko
SUSE Labs

