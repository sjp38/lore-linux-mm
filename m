Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 399F6C46477
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 06:31:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D352B218CD
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 06:31:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D352B218CD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2E7898E0003; Mon, 17 Jun 2019 02:31:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 272898E0001; Mon, 17 Jun 2019 02:31:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0EAC58E0003; Mon, 17 Jun 2019 02:31:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id B11838E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 02:31:22 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id l26so14967218eda.2
        for <linux-mm@kvack.org>; Sun, 16 Jun 2019 23:31:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=uH03hmg1T5fiwePErmZLVpRo+iUXU29nS/hW+tbLcJU=;
        b=UsJ2Eq8gUVGfLGhy/jTsmYUXdLiA8HhpSov4J4rsxrWGwy0BgjU7de89xa07FyDB0Q
         Mwe4FhU6XuMkD93wev2Sl/hASnMwA52ql4mZ7EApge03XPZXVn/9tFuzFbrDGHRIjUov
         4IIrThZZNTrGZgckf+ctLjLphkWPMWVO7PI9JFqNXBtET6Lyc9TzipMR+CkoG/kWKxZM
         FDKUVKiDQtIl5pf3z0oUIpObX1Hk314Tk/TQ0eeSSqLELELhfmMNPBN0YUuodwWbi6VZ
         CaIcC7aUjL7ngMKd5kb5isRsnCmzj5g/GSwKRwepZFCQItxT06p7gioUsB/9W6SKCFZ3
         R7rQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWwsTHQWKoHpe/7cIjtgntgoY7X8ZgOf/54S6W2+HYDWOTrDTGx
	XI1AMC20kEmebFG4+oXlCzBTVk2OJ/mKhv+LVPS2XVZPuZ4W76QPi6Nn9Yq1As3VQ2R3IX8yFVU
	caVlTcOo0B8VjGTxCRDuCjL1+qHZAOAN7A0K0EiuyNDKOvD2PkJ6VRHJ2BA17Y7Y=
X-Received: by 2002:a17:906:55d4:: with SMTP id z20mr2382389ejp.205.1560753082203;
        Sun, 16 Jun 2019 23:31:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyo4r7OlGtTxXV/fUyRXpA6qPJd7NJypvuCP1Tx8/t7rcO6UD5skrMmwsljdcUk7lhgoaGe
X-Received: by 2002:a17:906:55d4:: with SMTP id z20mr2382343ejp.205.1560753081411;
        Sun, 16 Jun 2019 23:31:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560753081; cv=none;
        d=google.com; s=arc-20160816;
        b=Xo+iXgp3AbNdlA+ssJ+k35MLlPxn0omEu8N23bV202XSIsVzXEpcoLmIj4KmyLTo/g
         fislXkRizjy0uZ0/SO5RV4XjWgpLZFdtCT8x4oSLCUuThO8sEY686BEjJYUnBdbKvLWi
         MSd2CMcZY21vqyc3pXhWsfOpdSWH2/jOjDXV5yz7jutPYQLa8s7fkiWZM5yFISXoUfsS
         yehoPY6EMCdxlu71+7LSqHwjS7YMADjBucf/6HIlQj9V5Ni7QKnbxmLIWP6EQR2ik6fP
         3FkhCf9x+ig+rRt3mu7jMk8tH1eXj17mbYVNqsmxVRGMPArG8hkXDFK0BYz6TQQss2xg
         yUQw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=uH03hmg1T5fiwePErmZLVpRo+iUXU29nS/hW+tbLcJU=;
        b=hdjBZdEoJ1Ngw5QLnPXylqZR7bJ/imkYsxmowlmiR6rlC2KwvKvbcUxOJ6x5m1blvF
         ntI3H3yXQjxupNppHg4KOEg0W4GGTcqPPv9U61uTIlmok4/UnsDK0QSLgyLFIxHE6Rva
         6EpHws3AurMQBNzWkSdgP4rGoGbPTiNx4R+y0P3/11NFZaLcaK94owdtpbttWet3d0bd
         laDYX3sCoasNmFegw1Uzu23OkO78QKKNmGs4B9Jcn2jIrwAjtymtRw/QEZCoiHGCfur5
         2q/WyS1Kuw57MwyfJLk/8W5KSGvChWmmuOVBokhvBKbtaoLTrsvuf+CYFXF54VKo/Bv4
         pyuw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a6si5661197ejj.232.2019.06.16.23.31.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 16 Jun 2019 23:31:21 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 6195FAFAC;
	Mon, 17 Jun 2019 06:31:20 +0000 (UTC)
Date: Mon, 17 Jun 2019 08:31:18 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Shakeel Butt <shakeelb@google.com>,
	syzbot <syzbot+d0fc9d3c166bc5e4a94b@syzkaller.appspotmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>,
	syzkaller-bugs <syzkaller-bugs@googlegroups.com>,
	yuzhoujian@didichuxing.com
Subject: Re: general protection fault in oom_unkillable_task
Message-ID: <20190617063118.GA30420@dhcp22.suse.cz>
References: <0000000000004143a5058b526503@google.com>
 <CALvZod72=KuBZkSd0ey5orJFGFpwx462XY=cZvO3NOXC0MogFw@mail.gmail.com>
 <20190615134955.GA28441@dhcp22.suse.cz>
 <CALvZod4hT39PfGt9Ohj+g77om5=G0coHK=+G1=GKcm-PowkXsw@mail.gmail.com>
 <5bb1fe5d-f0e1-678b-4f64-82c8d5d81f61@i-love.sakura.ne.jp>
 <CALvZod4etSv9Hv4UD=E6D7U4vyjCqhxQgq61AoTUCd+VubofFg@mail.gmail.com>
 <791594c6-45a3-d78a-70b5-901aa580ed9f@i-love.sakura.ne.jp>
 <840fa9f1-07e2-e206-2fc0-725392f96baf@i-love.sakura.ne.jp>
 <c763afc8-f0ae-756a-56a7-395f625b95fc@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c763afc8-f0ae-756a-56a7-395f625b95fc@i-love.sakura.ne.jp>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 17-06-19 00:13:47, Tetsuo Handa wrote:
[...]
> >From 415e52cf55bc4ad931e4f005421b827f0b02693d Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Mon, 17 Jun 2019 00:09:38 +0900
> Subject: [PATCH] mm: memcontrol: Use CSS_TASK_ITER_PROCS at mem_cgroup_scan_tasks().
> 
> Since commit c03cd7738a83b137 ("cgroup: Include dying leaders with live
> threads in PROCS iterations") corrected how CSS_TASK_ITER_PROCS works,
> mem_cgroup_scan_tasks() can use CSS_TASK_ITER_PROCS in order to check
> only one thread from each thread group.

O(Threads#) is definitely much worse than O(proc#)

> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

> ---
>  mm/memcontrol.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index ba9138a..b09ff45 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1163,7 +1163,7 @@ int mem_cgroup_scan_tasks(struct mem_cgroup *memcg,
>  		struct css_task_iter it;
>  		struct task_struct *task;
>  
> -		css_task_iter_start(&iter->css, 0, &it);
> +		css_task_iter_start(&iter->css, CSS_TASK_ITER_PROCS, &it);
>  		while (!ret && (task = css_task_iter_next(&it)))
>  			ret = fn(task, arg);
>  		css_task_iter_end(&it);
> -- 
> 1.8.3.1

-- 
Michal Hocko
SUSE Labs

