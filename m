Return-Path: <SRS0=s2+Z=O6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 076DAC43387
	for <linux-mm@archiver.kernel.org>; Fri, 21 Dec 2018 15:33:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9A9C521903
	for <linux-mm@archiver.kernel.org>; Fri, 21 Dec 2018 15:33:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9A9C521903
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 04E358E0002; Fri, 21 Dec 2018 10:33:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F3F378E0001; Fri, 21 Dec 2018 10:33:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DE1748E0002; Fri, 21 Dec 2018 10:33:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 811C88E0001
	for <linux-mm@kvack.org>; Fri, 21 Dec 2018 10:33:06 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id c34so6246851edb.8
        for <linux-mm@kvack.org>; Fri, 21 Dec 2018 07:33:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=26TJwrvrl0h9TBkI8Xeq9ioVy8IUCN2zSUwch7Ib6fU=;
        b=D9tDHYmedecwLyKiifvqExHlttiUQyYY0stY2uamqIMsne+sezE5hVcvkQrcqw/PMm
         2dDR+iXlXarMWOMHpJLY9j3RFOO6tf1tz4QdHYKCecKa30LWJS3wx/+mjLmM5g3N8LoI
         Ag55bxMIc1XfqqQWFdvqFUyRQqiAxMlMiUNkLmYGl7wzcjyhkIyDkH0I/HaFTGu73C9i
         AM16/4dNaoyYSz0vG74NbHYRvyMp+b3yeaj4HK8e7y2ySo/lk6qqjJR8qyLj5nce9ewx
         DjbMTab+Rfqb6aNmGo3bshGzeXBH3d2mYedJmfsZ67iWmlKvYKoOKcunbz7D0GAPRBV5
         Q08w==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AA+aEWbdJhSYCMUaPBHvnDX3m5QYP2HbU9KxWik3UVWSOTMIcJyrjQig
	poHGrliohaFN6VauYqJ18ydhkezxnMkIcyXPdouzFD+YPTvsX93dKU5EDWybSFTiV0KYKwN6ohc
	Zt169wh68tXrJyYzmint6vDAvcwJUAFId6yBnzIHckMmJY5dm+M9qYgqhYdrP9LQ=
X-Received: by 2002:a50:b32f:: with SMTP id q44mr2783668edd.70.1545406385970;
        Fri, 21 Dec 2018 07:33:05 -0800 (PST)
X-Google-Smtp-Source: AFSGD/U8b8tjYQIqb4uyKOaR8yLUWPSTmLvvNteO/GS5mw9dMNk6oFDIxw1Zj3Vhi/cRRUx9Sd5B
X-Received: by 2002:a50:b32f:: with SMTP id q44mr2783625edd.70.1545406385052;
        Fri, 21 Dec 2018 07:33:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545406385; cv=none;
        d=google.com; s=arc-20160816;
        b=qfI9nZrz6/irXxcSaVupLYDILZG+0/P4mgQYWseTnsYOascFqlfRP1kyRKrrxDUJRN
         h+cySzNiGu36r21D8zN/H6LX7/YFFybFZTKpqDfOrxFiZKvi7mB5SEi/BGQIhC+aFO97
         GaH1ZD/LLoD5l0231Ryjc7jyHWMsrZN6AmXBqulfI+HL+aBvFzwOyAjab4hzFcOp0J77
         +9gmfnmCGbsxQe5uCUPxhVUfrCIi8skrJukN71FtBUzxbcuq3MOHWCXKxYUXdzKCJr0u
         d010O15qDChpWPeoQf1sm3+5Dn471wK+4G0Fc3BHtDcJrYUQ28lBUYfqN26KtohExtBr
         Bjbw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=26TJwrvrl0h9TBkI8Xeq9ioVy8IUCN2zSUwch7Ib6fU=;
        b=lXEwaw03AjA/8pl3iUw0999yjkaF1BIdf81QuqDSK9ynOIIkie/wrTHBOmDm3msWzU
         OVmmwgpa67EtJeD91wemW5Qtc0Q14XZi/tidwVceTwpT8pkBuvVwBgV0hbYY7d84PtKs
         7gJ2CFak+fm0Fcl82coeUGvFu8JAiinrIib7cu10QNRn/E4Gqu9EcpiFRUgCCwwrtUh9
         VvOWpq/B7P/h0k3rru35WqDOgOos4lYXBufKM48pGHst7btKIMqVx7oYr0JMRIgiGfDP
         uaH0JUwRKGngxBy2G1t4jyqbM7AHwX6zCiq2VpkqLo/h7lkFIsGF4qn89qjNqP/Vil57
         IyYw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i6-v6si1255180ejo.242.2018.12.21.07.33.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Dec 2018 07:33:05 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 16C92AEA6;
	Fri, 21 Dec 2018 15:33:04 +0000 (UTC)
Date: Fri, 21 Dec 2018 16:33:02 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Burt Holzman <burt@fnal.gov>
Cc: "hannes@cmpxchg.org" <hannes@cmpxchg.org>,
	"vdavydov.dev@gmail.com" <vdavydov.dev@gmail.com>,
	"cgroups@vger.kernel.org" <cgroups@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Re: OOM notification for cgroupsv1 broken in 4.19
Message-ID: <20181221153302.GB6410@dhcp22.suse.cz>
References: <5ba5ba06-554c-d1ec-0967-b1d3486d0699@fnal.gov>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
In-Reply-To: <5ba5ba06-554c-d1ec-0967-b1d3486d0699@fnal.gov>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181221153302.s31ha_vczoV0XT0Fl7zsqV-ZimjvHzKswGv29v6dVXM@z>

On Fri 21-12-18 14:49:38, Burt Holzman wrote:
> Hi,
> 
> This patch: 29ef680ae7c21110af8e6416d84d8a72fc147b14
> [PATCH] memcg, oom: move out_of_memory back to the charge path
> 
> has broken the eventfd notification for cgroups-v1. This is because 
> mem_cgroup_oom_notify() is called only in mem_cgroup_oom_synchronize and 
> not with the new, additional call to mem_cgroup_out_of_memory in the 
> charge path.

Yes, you are right and this is a clear regression. Does the following
patch fixes the issue for you? I am not super happy about the code
duplication but I wasn't able to separate this out from
mem_cgroup_oom_synchronize because that one has to handle the oom_killer
disabled case which is not the case in the charge path because we simply
back off and hand over to mem_cgroup_oom_synchronize in that case.
---
From 51633f683173013741f4d0ab3e31bae575341c55 Mon Sep 17 00:00:00 2001
From: Michal Hocko <mhocko@suse.com>
Date: Fri, 21 Dec 2018 16:28:29 +0100
Subject: [PATCH] memcg, oom: notify on oom killer invocation from the charge
 path

Burt Holzman has noticed that memcg v1 doesn't notify about OOM events
via eventfd anymore. The reason is that 29ef680ae7c2 ("memcg, oom: move
out_of_memory back to the charge path") has moved the oom handling back
to the charge path. While doing so the notification was left behind in
mem_cgroup_oom_synchronize.

Fix the issue by replicating the oom hierarchy locking and the
notification.

Reported-by: Burt Holzman <burt@fnal.gov>
Fixes: 29ef680ae7c2 ("memcg, oom: move out_of_memory back to the charge path")
Cc: stable # 4.19+
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/memcontrol.c | 20 ++++++++++++++++++--
 1 file changed, 18 insertions(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 6e1469b80cb7..7e6bf74ddb1e 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1666,6 +1666,9 @@ enum oom_status {
 
 static enum oom_status mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask, int order)
 {
+	enum oom_status ret;
+	bool locked;
+
 	if (order > PAGE_ALLOC_COSTLY_ORDER)
 		return OOM_SKIPPED;
 
@@ -1700,10 +1703,23 @@ static enum oom_status mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask, int
 		return OOM_ASYNC;
 	}
 
+	mem_cgroup_mark_under_oom(memcg);
+
+	locked = mem_cgroup_oom_trylock(memcg);
+
+	if (locked)
+		mem_cgroup_oom_notify(memcg);
+
+	mem_cgroup_unmark_under_oom(memcg);
 	if (mem_cgroup_out_of_memory(memcg, mask, order))
-		return OOM_SUCCESS;
+		ret = OOM_SUCCESS;
+	else
+		ret = OOM_FAILED;
 
-	return OOM_FAILED;
+	if (locked)
+		mem_cgroup_oom_unlock(memcg);
+
+	return ret;
 }
 
 /**
-- 
2.19.2

-- 
Michal Hocko
SUSE Labs

