Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 58CADC32750
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 20:06:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0C1922087E
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 20:06:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="P+nLxp71"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0C1922087E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8EE6F6B0003; Fri,  2 Aug 2019 16:06:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8A0636B0005; Fri,  2 Aug 2019 16:06:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 78D7D6B0006; Fri,  2 Aug 2019 16:06:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 40AAE6B0003
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 16:06:55 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id h3so48105975pgc.19
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 13:06:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=0InaR80EjxBNmI3fwV/hvkwnwwTJdhOgE1ctQVb1Bpk=;
        b=VRsq0T5bjohcf35oDwxAvEHXOUAydAEbcQ6Q7G7KY9gloansTbdvc+5EX9zBpbEOMo
         q7EQPvR5PiXTX6sAHn/y+PFnCC+vE7suMkY6mCApOpbFdg+s/aomVd997DsU/AAZ2+ed
         L8S9KDnSYkcUuqDY4d2KWDRHVUzKWVq9dVQ3SzMuHLcXxIXQsonBqG1g5pLA13dcTvpL
         64fl+624RU0oVFxaebJ3x/3QsB52ICAqRTvFmuIuAe//YidCs08uT8J/KgYDvHXS/1+u
         ZR3OT1ZXPy3HnpGwWiwr8cumi+3IDCsA3H2khVCer51PazvIXQ2+9efR2uKV87mD5iZx
         w5BQ==
X-Gm-Message-State: APjAAAUo+XA0GYJNssI9IM8gYeQEPai+ea6RZ7L2xwIQjY5dYpeWJBGb
	R2g3Rs3t5qQCuTq7JZVenTHWL/ETMVcEB/EkbWzBFNgzoFQaxngTjjRTxj9S5PGo0J/DN1NFN1e
	0+atHYyveFWR+cnep3fURQhQfhSzTeHrz8680zW9lndR1k078YSu6KVOxuSdkpGs=
X-Received: by 2002:a17:902:8d92:: with SMTP id v18mr134900332plo.211.1564776414853;
        Fri, 02 Aug 2019 13:06:54 -0700 (PDT)
X-Received: by 2002:a17:902:8d92:: with SMTP id v18mr134900273plo.211.1564776414089;
        Fri, 02 Aug 2019 13:06:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564776414; cv=none;
        d=google.com; s=arc-20160816;
        b=T7slbNipDXGhxoWmRi9LmoC4+Kds8l37RcxPztUklKUEt8GiNkBK/czwOkJbuzGkNo
         7S1wC4FPX86wIOzFFV6QNaw5qD38auWFKuEnOtF0JB2fKNU5wirg258n5KZ2PIpYooeQ
         Q9xADvJAEi4CvEctjYLFrQVzGPYE8l9Wvix6wmBURS2N/VZI+27YGpsDVvQrPNpkAaSB
         gwllte2kFm00oXVQrBrdDMZPTjLqS6pfsh5RcpcS9hSeCiBqrZb5g4yEIcI6myuJyr9g
         MUxaIeteBP/QKsmh1KkfKeNlocQ2xBmH06zGauCnyRdDez+yLjlgugVi73DcuIncPoyz
         cjCA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=0InaR80EjxBNmI3fwV/hvkwnwwTJdhOgE1ctQVb1Bpk=;
        b=LSQX5Ddti/Uac4iBKbv3HzdU16/guRj38zYznO7JTRH6D/fR3m5WavbkwONf4xcpae
         PPx7kQ2T1A6bjLG9+utsgMKQo1g+CppH3TFauW7OGMX9hCJO45mQTnfoLOw1cJ5gCKZY
         XaH8KrMprW/y/bFMHZ/pXQG6PVEX56Pl/IkW8sGRDSRKJBITyX48B0n/iiXDq3IBMFtO
         hTy5kuwFmL+JbUzLxOBiFv7Z6vTdT0HrW/sb+6GnUCpaG20+Rfcj+giN4/et7NOzucw8
         SI9mR9gAGEIrQUXp0cjEw5LKDJmFOTc/WZYsW+ag3dNL7+J/fqCP1arr3BH23/rJG3kU
         hyYw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=P+nLxp71;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 15sor52130051pgs.16.2019.08.02.13.06.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 02 Aug 2019 13:06:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=P+nLxp71;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=0InaR80EjxBNmI3fwV/hvkwnwwTJdhOgE1ctQVb1Bpk=;
        b=P+nLxp71Ax6nF6Brzs8hAeO3lW81Nfn2pWE1wtjIrOnu0vAApKb+Ac0BIGkxNNixgl
         vvgSMEVd3hGcf+8pgQeCPPocX/qobEbmsb/raokvZUYpkUvWexGrDBLMoOpOzky+iQx1
         yvdR0PwbAGkJYzI+w5LUPtBCOEVrmfCkuzewmWpZ30NXyiMIjXEK79AJmvri+yiRHlHR
         3sVN/VDyt8xGfcC7j6k9VREgnun7p2yTzDHAj9ffoTRTS9skxG116Kd8RpKdBd1qdcnZ
         TImFNjbcq81sZfvkgbGCUKe8k2UnozWLhF0Zpt1rAk0XvRvdEsaDhQ6cpMzP8RjPxpdQ
         Jpww==
X-Google-Smtp-Source: APXvYqwL/2NXpEk4DSAtI/faL3gFN8waWWvvjCoZ3AbSupWJxwUfwu+Rw/I3REplZCbRF7+KcU/kpw==
X-Received: by 2002:a63:6206:: with SMTP id w6mr9781484pgb.428.1564776413328;
        Fri, 02 Aug 2019 13:06:53 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id g92sm13788643pje.11.2019.08.02.13.06.45
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 02 Aug 2019 13:06:51 -0700 (PDT)
Date: Sat, 3 Aug 2019 05:06:43 +0900
From: Minchan Kim <minchan@kernel.org>
To: syzbot <syzbot+8e6326965378936537c3@syzkaller.appspotmail.com>
Cc: akpm@linux-foundation.org, chris@chrisdown.name, chris@zankel.net,
	dancol@google.com, dave.hansen@intel.com, hannes@cmpxchg.org,
	hdanton@sina.com, james.bottomley@hansenpartnership.com,
	kirill.shutemov@linux.intel.com, ktkhai@virtuozzo.com,
	laoar.shao@gmail.com, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, mgorman@techsingularity.net, mhocko@kernel.org,
	mhocko@suse.com, oleksandr@redhat.com, ralf@linux-mips.org,
	rth@twiddle.net, sfr@canb.auug.org.au, shakeelb@google.com,
	sonnyrao@google.com, surenb@google.com,
	syzkaller-bugs@googlegroups.com, timmurray@google.com,
	yang.shi@linux.alibaba.com
Subject: Re: kernel BUG at mm/vmscan.c:LINE! (2)
Message-ID: <20190802200643.GA181880@google.com>
References: <000000000000a9694d058f261963@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <000000000000a9694d058f261963@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 02, 2019 at 10:58:05AM -0700, syzbot wrote:
> Hello,
> 
> syzbot found the following crash on:
> 
> HEAD commit:    0d8b3265 Add linux-next specific files for 20190729
> git tree:       linux-next
> console output: https://syzkaller.appspot.com/x/log.txt?x=1663c7d0600000
> kernel config:  https://syzkaller.appspot.com/x/.config?x=ae96f3b8a7e885f7
> dashboard link: https://syzkaller.appspot.com/bug?extid=8e6326965378936537c3
> compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
> syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=133c437c600000
> C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=15645854600000
> 
> The bug was bisected to:
> 
> commit 06a833a1167e9cbb43a9a4317ec24585c6ec85cb
> Author: Minchan Kim <minchan@kernel.org>
> Date:   Sat Jul 27 05:12:38 2019 +0000
> 
>     mm: introduce MADV_PAGEOUT
> 
> bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=1545f764600000
> final crash:    https://syzkaller.appspot.com/x/report.txt?x=1745f764600000
> console output: https://syzkaller.appspot.com/x/log.txt?x=1345f764600000
> 
> IMPORTANT: if you fix the bug, please add the following tag to the commit:
> Reported-by: syzbot+8e6326965378936537c3@syzkaller.appspotmail.com
> Fixes: 06a833a1167e ("mm: introduce MADV_PAGEOUT")
> 
> raw: 01fffc0000090025 dead000000000100 dead000000000122 ffff88809c49f741
> raw: 0000000000020000 0000000000000000 00000002ffffffff ffff88821b6eaac0
> page dumped because: VM_BUG_ON_PAGE(PageActive(page))
> page->mem_cgroup:ffff88821b6eaac0
> ------------[ cut here ]------------
> kernel BUG at mm/vmscan.c:1156!
> invalid opcode: 0000 [#1] PREEMPT SMP KASAN
> CPU: 1 PID: 9846 Comm: syz-executor110 Not tainted 5.3.0-rc2-next-20190729
> #54
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> Google 01/01/2011
> RIP: 0010:shrink_page_list+0x2872/0x5430 mm/vmscan.c:1156

My old version had PG_active flag clear but it seems to lose it with revising
patchsets. Thanks, Sizbot!

From 66d64988619ef7e86b0002b2fc20fdf5b84ad49c Mon Sep 17 00:00:00 2001
From: Minchan Kim <minchan@kernel.org>
Date: Sat, 3 Aug 2019 04:54:02 +0900
Subject: [PATCH] mm: Clear PG_active on MADV_PAGEOUT

shrink_page_list expects every pages as argument should be no active
LRU pages so we need to clear PG_active.

Reported-by: syzbot+8e6326965378936537c3@syzkaller.appspotmail.com
Fixes: 06a833a1167e ("mm: introduce MADV_PAGEOUT")
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/vmscan.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 47aa2158cfac2..e2a8d3f5bbe48 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2181,6 +2181,7 @@ unsigned long reclaim_pages(struct list_head *page_list)
 		}
 
 		if (nid == page_to_nid(page)) {
+			ClearPageActive(page);
 			list_move(&page->lru, &node_page_list);
 			continue;
 		}
-- 
2.22.0.770.g0f2c4a37fd-goog

