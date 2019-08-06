Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C1113C433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 08:29:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 81CB02075B
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 08:29:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 81CB02075B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2CD156B000A; Tue,  6 Aug 2019 04:29:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2ACF66B000C; Tue,  6 Aug 2019 04:29:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 16CFF6B000D; Tue,  6 Aug 2019 04:29:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id BD4356B000A
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 04:29:12 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id r21so53350001edc.6
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 01:29:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=iR9MoQ3t9Si+1vsvMXnJ/bwYAiwL4QPBUb5NFrEXrwM=;
        b=d8ptN0O2HMQuHXY0vUffP3IONaOVi7tqZ1gCJTEUdZ3Slgmrk1TIgQau6X6mD3X7Bj
         iYHx3poTZ3/cwNpoDA3lK9vk8Cg7hEZgHbpsqg75ryn/X3pNJTI5kLBnlS9A7RQjgyCj
         i2Kvr2ncW3EaTiDUIFdtIx+YH3d+xEtQpzkXm+g2nWAwRTVAOK8Mf2T50HGoYrDonJNo
         jemFX0evbiTOD2s+n1NqVxPEsVrDWOMLKnFh5ptk9B0M7QI/RKxerBCMvq3yCYfkF1KU
         pi+1v8Z9ahuv21GSPns6a0h+dazcfERL5Ku6zA1qy1yu/1AdAR7VWf6FVKhGpbg7qmGv
         HSTw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAW0a4PGxKZClKOwdSXQyMiuETeLrJuRhe9JcxoMzruB8Cnzyw0t
	FKBeesF0ppkgATUKNavNvF/PZmLnf/6PUOQX9J9r6Avwmy7+QFDKRm5XyS2d4fyP354I6RBlQr8
	Qu24mcGyS2ltRh6aeRSt9ee3broedOVf5ap+nvMz01CG4Vb/unVaPLJ0TP0BWs2A=
X-Received: by 2002:a50:9f4e:: with SMTP id b72mr2513476edf.252.1565080152325;
        Tue, 06 Aug 2019 01:29:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx1kf2Rjd7qWS9mWfHXmsxO4Os0s7O5/X0EjdWOBGLZxQ7JGN6+FiJ5BiRqIEcjX+QZjAgm
X-Received: by 2002:a50:9f4e:: with SMTP id b72mr2513436edf.252.1565080151609;
        Tue, 06 Aug 2019 01:29:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565080151; cv=none;
        d=google.com; s=arc-20160816;
        b=nWyQOLxxBU6/mfl7b6tOxWNx/lqpfAxFynlstv9e0iSAhLZfLd4ADQnMqRWN3ia0+i
         q48yaZcjK+DiAcbVlSjc1CKc9Mghxm/q7wN4r480r1diZ2vx7/1QWbPv5ZCFaLn+vyJ+
         HtxhEzO5AdrDieRJhZz1CVJM05CkuS5EO4UmhD4oK8ukPJZtZMSvjCFYeLF3UXiawDp1
         4Uhr/FrYgnX0+/TPS7mZOTkVi8iPxg8BWvLP09qiuMIqu7j84LVkskGw44FcjVKaN84u
         fcmfRDWsDkfmdG0NHEQCQ111806AQEQ1/vt+YAodTybcGqbRQHw3TJHfjfS5yt0NhXBW
         l8ew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=iR9MoQ3t9Si+1vsvMXnJ/bwYAiwL4QPBUb5NFrEXrwM=;
        b=Kgw83O1lNcl+oZuqD/uMADRNLBk64d7QptTjbyUFggB3P/rMtAkLWupcxOJCDI7xNb
         SEYm+rd7aQnN2PEzEO0zSf5lREn3DVjaF5yQ6y4ZZeRVb3PsDcgEinjvO42H8dfUpzqH
         ZHu/kmKSWRVbT8eBZRRFuqeJ7y67GoDW7rBiZrJW0qDrH9JheV4wI+3llhdB2+y/ELAA
         SJ1r/Sa5VKzulQxKCbb7w+4SAWGyKhy/DsyXmy7j4mIA0hdduC1xUnwxnhfStDoj5y9K
         v8Zxjswie4uP6t5cNVtqVtg/Q1UDCsp/wIqhRSJ2EIL4wENK2r/hQFPfgJFpnQ7WP9h0
         A/tA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s41si29683980edd.252.2019.08.06.01.29.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 01:29:11 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 9C99FAF1D;
	Tue,  6 Aug 2019 08:29:10 +0000 (UTC)
Date: Tue, 6 Aug 2019 10:29:07 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Minchan Kim <minchan@kernel.org>
Cc: syzbot <syzbot+8e6326965378936537c3@syzkaller.appspotmail.com>,
	akpm@linux-foundation.org, chris@chrisdown.name, chris@zankel.net,
	dancol@google.com, dave.hansen@intel.com, hannes@cmpxchg.org,
	hdanton@sina.com, james.bottomley@hansenpartnership.com,
	kirill.shutemov@linux.intel.com, ktkhai@virtuozzo.com,
	laoar.shao@gmail.com, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, mgorman@techsingularity.net,
	oleksandr@redhat.com, ralf@linux-mips.org, rth@twiddle.net,
	sfr@canb.auug.org.au, shakeelb@google.com, sonnyrao@google.com,
	surenb@google.com, syzkaller-bugs@googlegroups.com,
	timmurray@google.com, yang.shi@linux.alibaba.com
Subject: Re: kernel BUG at mm/vmscan.c:LINE! (2)
Message-ID: <20190806082907.GI11812@dhcp22.suse.cz>
References: <000000000000a9694d058f261963@google.com>
 <20190802200643.GA181880@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190802200643.GA181880@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat 03-08-19 05:06:43, Minchan Kim wrote:
> On Fri, Aug 02, 2019 at 10:58:05AM -0700, syzbot wrote:
> > Hello,
> > 
> > syzbot found the following crash on:
> > 
> > HEAD commit:    0d8b3265 Add linux-next specific files for 20190729
> > git tree:       linux-next
> > console output: https://syzkaller.appspot.com/x/log.txt?x=1663c7d0600000
> > kernel config:  https://syzkaller.appspot.com/x/.config?x=ae96f3b8a7e885f7
> > dashboard link: https://syzkaller.appspot.com/bug?extid=8e6326965378936537c3
> > compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
> > syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=133c437c600000
> > C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=15645854600000
> > 
> > The bug was bisected to:
> > 
> > commit 06a833a1167e9cbb43a9a4317ec24585c6ec85cb
> > Author: Minchan Kim <minchan@kernel.org>
> > Date:   Sat Jul 27 05:12:38 2019 +0000
> > 
> >     mm: introduce MADV_PAGEOUT
> > 
> > bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=1545f764600000
> > final crash:    https://syzkaller.appspot.com/x/report.txt?x=1745f764600000
> > console output: https://syzkaller.appspot.com/x/log.txt?x=1345f764600000
> > 
> > IMPORTANT: if you fix the bug, please add the following tag to the commit:
> > Reported-by: syzbot+8e6326965378936537c3@syzkaller.appspotmail.com
> > Fixes: 06a833a1167e ("mm: introduce MADV_PAGEOUT")
> > 
> > raw: 01fffc0000090025 dead000000000100 dead000000000122 ffff88809c49f741
> > raw: 0000000000020000 0000000000000000 00000002ffffffff ffff88821b6eaac0
> > page dumped because: VM_BUG_ON_PAGE(PageActive(page))
> > page->mem_cgroup:ffff88821b6eaac0
> > ------------[ cut here ]------------
> > kernel BUG at mm/vmscan.c:1156!
> > invalid opcode: 0000 [#1] PREEMPT SMP KASAN
> > CPU: 1 PID: 9846 Comm: syz-executor110 Not tainted 5.3.0-rc2-next-20190729
> > #54
> > Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> > Google 01/01/2011
> > RIP: 0010:shrink_page_list+0x2872/0x5430 mm/vmscan.c:1156
> 
> My old version had PG_active flag clear but it seems to lose it with revising
> patchsets. Thanks, Sizbot!
> 
> >From 66d64988619ef7e86b0002b2fc20fdf5b84ad49c Mon Sep 17 00:00:00 2001
> From: Minchan Kim <minchan@kernel.org>
> Date: Sat, 3 Aug 2019 04:54:02 +0900
> Subject: [PATCH] mm: Clear PG_active on MADV_PAGEOUT
> 
> shrink_page_list expects every pages as argument should be no active
> LRU pages so we need to clear PG_active.

Ups, missed that during review.

> 
> Reported-by: syzbot+8e6326965378936537c3@syzkaller.appspotmail.com
> Fixes: 06a833a1167e ("mm: introduce MADV_PAGEOUT")

This is not a valid sha1 because it likely comes from linux-next. I
guess Andrew will squash it into mm-introduce-madv_pageout.patch

Just for the record
Acked-by: Michal Hocko <mhocko@suse.com>

And thanks for syzkaller to exercise the new interface so quickly!

> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  mm/vmscan.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 47aa2158cfac2..e2a8d3f5bbe48 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2181,6 +2181,7 @@ unsigned long reclaim_pages(struct list_head *page_list)
>  		}
>  
>  		if (nid == page_to_nid(page)) {
> +			ClearPageActive(page);
>  			list_move(&page->lru, &node_page_list);
>  			continue;
>  		}
> -- 
> 2.22.0.770.g0f2c4a37fd-goog

-- 
Michal Hocko
SUSE Labs

