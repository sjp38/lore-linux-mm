Return-Path: <SRS0=cZWw=UO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E7886C31E51
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 13:50:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8F33321773
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 13:50:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8F33321773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 049116B0003; Sat, 15 Jun 2019 09:50:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F3BC98E0002; Sat, 15 Jun 2019 09:50:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E05258E0001; Sat, 15 Jun 2019 09:50:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8FA356B0003
	for <linux-mm@kvack.org>; Sat, 15 Jun 2019 09:50:00 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b3so7997456edd.22
        for <linux-mm@kvack.org>; Sat, 15 Jun 2019 06:50:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=vHCh/SzK/RVYchv5wpIz2F9+8aZQD2jtbcZKh+KTgQc=;
        b=s+BZgc3aShW60WebGbu2lBgPVUkmom30RO0L1XNp+L+hExscXqC7UDj2KoBvVej0lG
         KSqtRoGGtDnDjiod98KDDH6/Mru7zGGxyHgGiIaYbkQiaQIGU+54/JQZ/STI5bgoQYNw
         gVv3ltrp0fopKCEzhEr/dKX5hK0jXbd80/W0vbgpP8CN10P1rPt/9ykgsl3EhvWCAww3
         nZnRjPSRaD6ngmTF1AyvXHaS1HoMInxwWj/iPaJJ6K0AxigWk9VQy1o8zPixtkCew6V3
         CahPrga7Lb/0lCZy6+6eq6IBVcD6HAzuwoAyx+OQVle1iESqVhD42dxPB+f1SISEuKbq
         QlnQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXSWNOp+s/08eQSEHpVaAB8lHs/wsXkWLikYIDKZFyedMbjTGdm
	SlN447WlYLmw9cJSSn3TiOjLEtLuiRohamQ4RozlhUrFtTQ6XlYnzZJjqsOX5sK5iZe59K7qSZZ
	McF3Qj7RR/+4xYgNjOdzuBVzuy6mZ/6pzLy5ubnrWDb6+Pm17QQN46J7txmhNiMQ=
X-Received: by 2002:a05:6402:134c:: with SMTP id y12mr6891693edw.96.1560606599963;
        Sat, 15 Jun 2019 06:49:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxEo2im+pH1wsB8uAP1acmtW/b2XUGDIxy+9qYjxHoi0KqGnauJJe1Bfx2V2m2Q9HvdseCn
X-Received: by 2002:a05:6402:134c:: with SMTP id y12mr6891640edw.96.1560606599015;
        Sat, 15 Jun 2019 06:49:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560606599; cv=none;
        d=google.com; s=arc-20160816;
        b=vxvG1Mn2xLlnXYapPQLV5brzdTRk+JW6pSptSb2pPpgkrFTDVKonvDDL7Aj/Raj4vE
         lFFIvzHiRbdmPPVNaO0NYmF+iz6OC9EZ/kMBLNENzUwYGDAsUZVAkLbokWhcF9h798Hk
         PDzNd874/zNjzDROlMWcpEjipc/fgc8jbJCuQRkb2gENOS9wRwSVko1RfEHmGBXAP5/A
         rXw/ZiTB9MqOsscNhZwfCeZ6S3PqKduZE8tLV9h33hQbh/ELNYA9yfb9hUgdF7aub8+a
         FHm4txtopSWVEZOWywzoU7KPphE+VOgjVqQKjWP3FvXuxxB3DJoK03eOyHx4h7OZosZ0
         7GBA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=vHCh/SzK/RVYchv5wpIz2F9+8aZQD2jtbcZKh+KTgQc=;
        b=FLIRRf2QelPARiMbpY1Lfx8oxYT5/4yi8IU1Ak4iKInxNIKth8AKz68atRdOhmKuTv
         0AIjJyr0o8V57MtK6jgLaSkKMGKwGGx24aFrJWbxnPpo1Tr0Tut92DApzKmiqhTcqMUK
         yvtYEqSBxZq6s0fRNIhj9pWjbXI9HeJCGelBqJNbTdPzK2nEKDf6Xj29PA76IOZCaRC6
         AqHO5ic8a0UjDyIYv33OKnRUkL5R1shqmBCSl0TAgeUtIUXhlN97YJM/J1WompZ9NBOz
         xt1vdBWLODV2DndZwuyBibSHLFdF5SkB1Zyn0v4GWRph2/xqJLWSNrnj+hC54TnNUoEy
         48AA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d28si4477569eda.375.2019.06.15.06.49.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Jun 2019 06:49:59 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id E77FAAF90;
	Sat, 15 Jun 2019 13:49:57 +0000 (UTC)
Date: Sat, 15 Jun 2019 15:49:55 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: syzbot <syzbot+d0fc9d3c166bc5e4a94b@syzkaller.appspotmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	syzkaller-bugs <syzkaller-bugs@googlegroups.com>,
	yuzhoujian@didichuxing.com
Subject: Re: general protection fault in oom_unkillable_task
Message-ID: <20190615134955.GA28441@dhcp22.suse.cz>
References: <0000000000004143a5058b526503@google.com>
 <CALvZod72=KuBZkSd0ey5orJFGFpwx462XY=cZvO3NOXC0MogFw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALvZod72=KuBZkSd0ey5orJFGFpwx462XY=cZvO3NOXC0MogFw@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 14-06-19 20:15:31, Shakeel Butt wrote:
> On Fri, Jun 14, 2019 at 6:08 PM syzbot
> <syzbot+d0fc9d3c166bc5e4a94b@syzkaller.appspotmail.com> wrote:
> >
> > Hello,
> >
> > syzbot found the following crash on:
> >
> > HEAD commit:    3f310e51 Add linux-next specific files for 20190607
> > git tree:       linux-next
> > console output: https://syzkaller.appspot.com/x/log.txt?x=15ab8771a00000
> > kernel config:  https://syzkaller.appspot.com/x/.config?x=5d176e1849bbc45
> > dashboard link: https://syzkaller.appspot.com/bug?extid=d0fc9d3c166bc5e4a94b
> > compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
> >
> > Unfortunately, I don't have any reproducer for this crash yet.
> >
> > IMPORTANT: if you fix the bug, please add the following tag to the commit:
> > Reported-by: syzbot+d0fc9d3c166bc5e4a94b@syzkaller.appspotmail.com
> >
> > kasan: CONFIG_KASAN_INLINE enabled
> > kasan: GPF could be caused by NULL-ptr deref or user memory access
> > general protection fault: 0000 [#1] PREEMPT SMP KASAN
> > CPU: 0 PID: 28426 Comm: syz-executor.5 Not tainted 5.2.0-rc3-next-20190607
> > #11
> > Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> > Google 01/01/2011
> > RIP: 0010:__read_once_size include/linux/compiler.h:194 [inline]
> > RIP: 0010:has_intersects_mems_allowed mm/oom_kill.c:84 [inline]
> 
> It seems like oom_unkillable_task() is broken for memcg OOMs. It
> should not be calling has_intersects_mems_allowed() for memcg OOMs.

You are right. It doesn't really make much sense to check for the NUMA
policy/cpusets when the memcg oom is NUMA agnostic. Now that I am
looking at the code then I am really wondering why do we even call
oom_unkillable_task from oom_badness. proc_oom_score shouldn't care
about NUMA either.

In other words the following should fix this unless I am missing
something (task_in_mem_cgroup seems to be a relict from before the group
oom handling). But please note that I am still not fully operation and
laying in the bed.

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 5a58778c91d4..43eb479a5dc7 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -161,8 +161,8 @@ static bool oom_unkillable_task(struct task_struct *p,
 		return true;
 
 	/* When mem_cgroup_out_of_memory() and p is not member of the group */
-	if (memcg && !task_in_mem_cgroup(p, memcg))
-		return true;
+	if (memcg)
+		return false;
 
 	/* p may not have freeable memory in nodemask */
 	if (!has_intersects_mems_allowed(p, nodemask))
@@ -318,7 +318,7 @@ static int oom_evaluate_task(struct task_struct *task, void *arg)
 	struct oom_control *oc = arg;
 	unsigned long points;
 
-	if (oom_unkillable_task(task, NULL, oc->nodemask))
+	if (oom_unkillable_task(task, oc->memcg, oc->nodemask))
 		goto next;
 
-- 
Michal Hocko
SUSE Labs

