Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4BF88C43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 17:54:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0A24420673
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 17:54:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0A24420673
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7AE856B0006; Mon, 24 Jun 2019 13:54:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 760458E0003; Mon, 24 Jun 2019 13:54:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 64F258E0002; Mon, 24 Jun 2019 13:54:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 177E66B0006
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 13:54:51 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id c27so21524432edn.8
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 10:54:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=vEovS816TCrnuE755nLbl53w7YThsepSXD+/D4xfscc=;
        b=m90tGRzNK64vMJSM/Ymklq0bYwG1uqSy2KIQIYEZXx+QUSao8uXcJzMdhkv2bl5pNZ
         C888CX70i2IGUDhiIykPafrUoOx4ZPzy7lllC6ZeyRPIGdDh5vPm7xC0ubD3IjAmCqaq
         UvGjsW9a5wXQ80re1AnOSon10vyX+wGtKzevDVAa/8sVLNxisnSwqTlbO5qtl2rM0Af8
         ZQJ/9+WIgeNvkWhVBXrqMdD5lFC5yTKrW7SrdRxrCsJWeVelNiAlKpTb7VVcuplpy+Lw
         RyKplSSt5aY0sOoaXX3siqdAlUfrTKD4eIen97ozXGF2IMGgVnfhr+nRTDj8EUWSFRcw
         eVpA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAV3a3rYw4TShxYp13FRQFj8ZMqSkTY24nOTN6kXU5dxopm30sDm
	xYICUUglu7Uw8I+ZVZa7M/sepKK31uLcHy4fXU/kJ/CqhU3qnNLt4jv8L3+GBTEwUPpD0pjqr4m
	zwitLApSuav7wv+rdfHPrFo5HbWj4P5ZYleck1MgtULIorSAuikngxkC3CtJaofU=
X-Received: by 2002:a50:b3b8:: with SMTP id s53mr84622194edd.61.1561398890663;
        Mon, 24 Jun 2019 10:54:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyqKKXlQrMp3vMFsm9narw9P/1eVc7th1xy4nnvnDv/cMCHpFSuWDCvtD/ySNvh7ttTCkTt
X-Received: by 2002:a50:b3b8:: with SMTP id s53mr84622150edd.61.1561398889940;
        Mon, 24 Jun 2019 10:54:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561398889; cv=none;
        d=google.com; s=arc-20160816;
        b=NB/QF8XqJLHzd62gLlf9g4sf9wIkRQROXpjmDOBegz7RMFQJ5yJQuA8MoqaJHwdPWB
         dRdi28gpcMkobDXlz2OZ4MWDzNn4St07Uoh9PLNSLq9HoNs25TZubp4O4QDwx9XKCM6a
         4KXqEVt+VtmKunFWOIH3K14P1VHdxrAlTHMrT0ztqohJ3ga/M0V35z2jMkdvB3OVwbGH
         +J9FIUwDX+eIOnmCI7DE1hM1RSQh0TWyuVKTLu8dMr5QU7fX5X2nUPwkb8adBJjJrI1h
         Gol4hlE/wkFeyujqhSDq8Oj8Cua6Y6Rjm3QAL00KD45DcnN46swjwJFFeT9F7BTjaIhg
         TqXA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=vEovS816TCrnuE755nLbl53w7YThsepSXD+/D4xfscc=;
        b=AI5MzxjYb0IQojAEuSvyZ3f5tS3KDk6p2IshBjO5mzqQPul/xz4y00g4FtYBp19JGT
         1c/S8vZCty/28ZalaIdc4JcA62PWC+t8EM40+9OzXLaDMrwa7NCsZIOtANrdK7nxk5Ln
         jkgEiPA5Fg/Mp8dL/rfAGWW3NtzEigHea9cwE8RcgKSIeVLXkG5kCc7E1mjMrWfxqgR1
         pTViLQe1Z/7by4jDdpPgjAuoPbgWwv5n20KTyEBjcsQDSTtpT2Wa5ynIFwhQjhaEdWb+
         cGFd5AHpVGBeqMIBPOupb9vQ7ZIClV7BW32f9gNChZCc4910YReudgTEM1i7sMBUntd0
         /26Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l5si5913216eja.12.2019.06.24.10.54.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jun 2019 10:54:49 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 82C75AC8C;
	Mon, 24 Jun 2019 17:54:49 +0000 (UTC)
Date: Mon, 24 Jun 2019 19:54:48 +0200
From: Michal Hocko <mhocko@kernel.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>,
	Minchan Kim <minchan@kernel.org>, Vlastimil Babka <vbabka@suse.cz>,
	Linux Memory Management List <linux-mm@kvack.org>,
	"Wangkefeng (Kevin)" <wangkefeng.wang@huawei.com>
Subject: Re: Frequent oom introduced in mainline when migrate_highatomic
 replace migrate_reserve
Message-ID: <20190624175448.GG11400@dhcp22.suse.cz>
References: <5D1054EE.20402@huawei.com>
 <20190624081011.GA11400@dhcp22.suse.cz>
 <5D10CC1B.3080201@huawei.com>
 <20190624140120.GD11400@dhcp22.suse.cz>
 <5D10FE8F.2010906@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5D10FE8F.2010906@huawei.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 25-06-19 00:47:11, zhong jiang wrote:
> On 2019/6/24 22:01, Michal Hocko wrote:
> > On Mon 24-06-19 21:11:55, zhong jiang wrote:
> >> [  652.272622] sh invoked oom-killer: gfp_mask=0x26080c0, order=3, oom_score_adj=0
> >> [  652.272683] CPU: 0 PID: 1748 Comm: sh Tainted: P           O    4.4.171 #8
> >> [  653.452827] Mem-Info:
> >> [  653.466390] active_anon:20377 inactive_anon:187 isolated_anon:0
> >> [  653.466390]  active_file:5087 inactive_file:4825 isolated_file:0
> >> [  653.466390]  unevictable:12 dirty:0 writeback:32 unstable:0
> >> [  653.466390]  slab_reclaimable:636 slab_unreclaimable:1754
> >> [  653.466390]  mapped:5338 shmem:194 pagetables:231 bounce:0
> >> [  653.466390]  free:1086 free_pcp:85 free_cma:0
> >> [  653.625286] Normal free:4248kB min:1696kB low:2120kB high:2544kB active_anon:81508kB inactive_anon:748kB active_file:20348kB inactive_file:19300kB unevictable:48kB isolated(anon):0kB isolated(file):0kB present:252928kB managed:180496kB mlocked:0kB dirty:0kB writeback:128kB mapped:21352kB shmem:776kB slab_reclaimable:2544kB slab_unreclaimable:7016kB kernel_stack:9856kB pagetables:924kB unstable:0kB bounce:0kB free_pcp:392kB local_pcp:392kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
> >> [  654.177121] lowmem_reserve[]: 0 0 0
> >> [  654.462015] Normal: 752*4kB (UME) 128*8kB (UM) 21*16kB (M) 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 4368kB
> >> [  654.601093] 10132 total pagecache pages
> >> [  654.606655] 63232 pages RAM
> > [...]
> >>>> As the process is created,  kernel stack will use the higher order to allocate continuous memory.
> >>>> Due to the fragmentabtion,  we fails to allocate the memory.   And the low memory will result
> >>>> in hardly memory compction.  hence,  it will easily to reproduce the oom.
> >>> How get your get such a large fragmentation that you cannot allocate
> >>> order-1 pages and compaction is not making any progress?
> >> >From the above oom report,  we can see that  there is not order-2 pages.  It wil hardly to allocate kernel stack when
> >> creating the process.  And we can easily to reproduce the situation when runing some userspace program.
> >>
> >> But it rarely trigger the oom when It do not introducing the highatomic.  we test that in the kernel 3.10.
> > I do not really see how highatomic reserves could make any difference.
> > We do drain them before OOM killer is invoked. The above oom report
> > confirms that there is indeed no order-3+ free page to be used.
> I mean that all order with migrate_highatomic is alway zero,  it can be  true that

Yes, highatomic is meant to be used for higher order allocations which
already do have access to memory reserves. E.g. via __GFP_ATOMIC.
-- 
Michal Hocko
SUSE Labs

