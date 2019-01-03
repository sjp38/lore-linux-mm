Return-Path: <SRS0=O33Z=PL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 90F92C43612
	for <linux-mm@archiver.kernel.org>; Thu,  3 Jan 2019 08:37:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 21FB021479
	for <linux-mm@archiver.kernel.org>; Thu,  3 Jan 2019 08:36:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 21FB021479
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 682DB8E0061; Thu,  3 Jan 2019 03:36:59 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 62F258E0002; Thu,  3 Jan 2019 03:36:59 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 51DF58E0061; Thu,  3 Jan 2019 03:36:59 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id EFBF58E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 03:36:58 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id l45so33459580edb.1
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 00:36:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:from:openpgp:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=pz8mjqjYcILoWzFqzC2EpvUtLUkqxstNeOj9U1VoUpc=;
        b=rYmIYFFZf8sqPedzFOwvjbkKwQYcfDyJktPDoMWjxkQmcm3qwYOjybNGCmfpg1wuwL
         ELHYT9S6Zu3L64l26/MCKBxpa3dDOLhQ6IPW9We1jvWTY8d933kslhLEnZZiNaZnkCB5
         B+Yqb/fEwVaPR6EdY3RJVKds+QU06wGJmAvpUPGEQBmt/fix/22vCvZSmVIQzSj2Yeon
         n8/SCArRZBVyJvNBuDYuUXXrIwhfqIKgzZ95FyJHTex9CKUaSpP7s9r+p/nm+/T4aiIa
         QoHeXTGWuAGssamRI5RTpD8poLMWqNd1bba6IBzZaqpmQgf/SG4GwzDqsioCqGEcei2S
         XbFA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: AA+aEWaIMBxuNdqgi3q5NfdqC/jyWliY3QCYWGWjRLLTSJrFqzPOYESr
	FHz0d0YrkMBJY25EBCX6RDYlJdRU3guxS1ijswDz6ONGdHn7hCOYUYsHAtodR6gwF7XP1dfzN9C
	GF5fy6FXgKdvdxN8xylXKhi2XpBVM15fzkX0tdtGpjrJ/ZQPFHM0M4XFdOyofHejDWA==
X-Received: by 2002:a50:82c7:: with SMTP id 65mr42415292edg.94.1546504618507;
        Thu, 03 Jan 2019 00:36:58 -0800 (PST)
X-Google-Smtp-Source: AFSGD/U3Ih62qmJumhnfh3kOkh8nDWvr/l9+jvuAHCLmmQDhuf2fQsp0t4no+byupM6qk84NZyvy
X-Received: by 2002:a50:82c7:: with SMTP id 65mr42415243edg.94.1546504617358;
        Thu, 03 Jan 2019 00:36:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546504617; cv=none;
        d=google.com; s=arc-20160816;
        b=tLk7V2rGwnAIL54xCmKxyel0YC6LFzIUCn6zuqnE1drbqCp/3XRrQJJBzgxd6hdsvA
         OLRm5e0K0c5J+VUvDgSKwdx5QqMuERUlzNguN5Srn63y4IEhGnKk2I/a6l6bUZm6K4we
         E8pcy/QbSNHcL4GPn27HJ0l59bT5mrj5jjCpdPdxBt18R71Hs8KH1QerI8T4NSL2E6hi
         1idUlnZ6ChNlmVnKLxe+mVABiljJOX04Sel9SKZxTMK42nFaf9UkMdL42VdkgkpU/hoK
         CCjEqU7SjR84oTK18/I0JWoN6JrZjdwOoCMijfCJcahCFVLToAZDMxyolyHYHWsDHtXy
         cqRQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:openpgp:from:references:to:subject;
        bh=pz8mjqjYcILoWzFqzC2EpvUtLUkqxstNeOj9U1VoUpc=;
        b=oBHS3FxQrRR9MflBoVyGssaxoo9ClpCN0EyuR39qMdzr8CzN5ekB9Hfdb/DSszg0Wg
         +b5xLdHWe3qIjfh+7pL9ymxabqCfDZ01g3OwCXfysFxg9K+Vn5TfNsjmmC8nxQMWCZAk
         vimMmX/un+kSsniuoZKZldHnftpyXftkmMn9eOYc9VIeJibuc4Mg3yzvrHschvU0l+Pb
         F9eeAtVZusU0XNBBo4sd6LqnybTgT2lydT7RcZrvfdwA66c9BXoOVy1t9FW/GncuLNhf
         sKXmP0b5IIxeFNrl68tnae9BXD2njcQPV94x6kOc2DGET0f4x8BgfdiizOyG3Ml0TtaD
         Vuww==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o4-v6si4553554eje.73.2019.01.03.00.36.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jan 2019 00:36:57 -0800 (PST)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 44418AE23;
	Thu,  3 Jan 2019 08:36:56 +0000 (UTC)
Subject: Re: KMSAN: uninit-value in mpol_rebind_mm
To: syzbot <syzbot+b19c2dc2c990ea657a71@syzkaller.appspotmail.com>,
 aarcange@redhat.com, akpm@linux-foundation.org, glider@google.com,
 kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, linux@dominikbrodowski.net, mhocko@suse.com,
 rientjes@google.com, syzkaller-bugs@googlegroups.com,
 xieyisheng1@huawei.com, zhongjiang@huawei.com
References: <000000000000c06550057e4cac7c@google.com>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Message-ID: <a71997c3-e8ae-a787-d5ce-3db05768b27c@suse.cz>
Date: Thu, 3 Jan 2019 09:36:55 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.3.3
MIME-Version: 1.0
In-Reply-To: <000000000000c06550057e4cac7c@google.com>
Content-Type: text/plain; charset="UTF-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190103083655.7sx8-OLX5zPaC_yMzGoTB4KLY1OnSWwBP1yiOjXTkNA@z>


On 12/31/18 8:51 AM, syzbot wrote:
> Hello,
> 
> syzbot found the following crash on:
> 
> HEAD commit:    79fc24ff6184 kmsan: highmem: use kmsan_clear_page() in cop..
> git tree:       kmsan
> console output: https://syzkaller.appspot.com/x/log.txt?x=13c48b67400000
> kernel config:  https://syzkaller.appspot.com/x/.config?x=901dd030b2cc57e7
> dashboard link: https://syzkaller.appspot.com/bug?extid=b19c2dc2c990ea657a71
> compiler:       clang version 8.0.0 (trunk 349734)
> 
> Unfortunately, I don't have any reproducer for this crash yet.
> 
> IMPORTANT: if you fix the bug, please add the following tag to the commit:
> Reported-by: syzbot+b19c2dc2c990ea657a71@syzkaller.appspotmail.com
> 
> ==================================================================
> BUG: KMSAN: uninit-value in mpol_rebind_policy mm/mempolicy.c:353 [inline]
> BUG: KMSAN: uninit-value in mpol_rebind_mm+0x249/0x370 mm/mempolicy.c:384

The report doesn't seem to indicate where the uninit value resides in
the mempolicy object. I'll have to guess. mm/mempolicy.c:353 contains:

        if (!mpol_store_user_nodemask(pol) &&
            nodes_equal(pol->w.cpuset_mems_allowed, *newmask))

"mpol_store_user_nodemask(pol)" is testing pol->flags, which I couldn't
see being uninitialized after leaving mpol_new(). So I'll guess it's
actually about accessing pol->w.cpuset_mems_allowed on line 354.

For w.cpuset_mems_allowed to be not initialized and the nodes_equal()
reachable for a mempolicy where mpol_set_nodemask() is called in
do_mbind(), it seems the only possibility is a MPOL_PREFERRED policy
with empty set of nodes, i.e. MPOL_LOCAL equivalent. Let's see if the
patch below helps. This code is a maze to me. Note the uninit access
should be benign, rebinding this kind of policy is always a no-op.

----8<----
From ff0ca29da6bc2572d7b267daa77ced6083e3f02d Mon Sep 17 00:00:00 2001
From: Vlastimil Babka <vbabka@suse.cz>
Date: Thu, 3 Jan 2019 09:31:59 +0100
Subject: [PATCH] mm, mempolicy: fix uninit memory access

---
 mm/mempolicy.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index d4496d9d34f5..a0b7487b9112 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -350,7 +350,7 @@ static void mpol_rebind_policy(struct mempolicy *pol, const nodemask_t *newmask)
 {
 	if (!pol)
 		return;
-	if (!mpol_store_user_nodemask(pol) &&
+	if (!mpol_store_user_nodemask(pol) && !(pol->flags & MPOL_F_LOCAL) &&
 	    nodes_equal(pol->w.cpuset_mems_allowed, *newmask))
 		return;
 
-- 
2.19.2

