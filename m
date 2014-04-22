Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f174.google.com (mail-ie0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 9EC686B0035
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 06:58:52 -0400 (EDT)
Received: by mail-ie0-f174.google.com with SMTP id rp18so4866459iec.5
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 03:58:52 -0700 (PDT)
Received: from mail-ie0-x235.google.com (mail-ie0-x235.google.com [2607:f8b0:4001:c03::235])
        by mx.google.com with ESMTPS id l5si11575413igx.27.2014.04.22.03.58.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 22 Apr 2014 03:58:52 -0700 (PDT)
Received: by mail-ie0-f181.google.com with SMTP id tp5so4774156ieb.26
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 03:58:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140422103420.GI29311@dhcp22.suse.cz>
References: <1397861935-31595-1-git-send-email-nasa4836@gmail.com>
 <20140422094759.GC29311@dhcp22.suse.cz> <CAHz2CGWrk3kuR=BLt2vT-8gxJVtJcj6h17ase9=1CoWXwK6a3w@mail.gmail.com>
 <20140422103420.GI29311@dhcp22.suse.cz>
From: Jianyu Zhan <nasa4836@gmail.com>
Date: Tue, 22 Apr 2014 18:58:11 +0800
Message-ID: <CAHz2CGUZyv-dvUUoSi2Vk_vgPAMqRN4yEg4F4XsKQ8udHeo2bQ@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm/memcontrol.c: remove meaningless while loop in mem_cgroup_iter()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, kamezawa.hiroyu@jp.fujitsu.com, Cgroups <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Apr 22, 2014 at 6:34 PM, Michal Hocko <mhocko@suse.cz> wrote:
> Sorry, I should have been more specific that I was talking about
> mem_cgroup_reclaim_cookie path where the iteration for this particular
> zone and priority ended at the last node without finishing the full
> roundtrip last time. This new iteration (prev==NULL) wants to continue
> and it should start a new roundtrip.
>
> Makes sense?

Hi, Michal,

Good catch, it makes sense !
This reminds me of my draft edition of this patch, I specifically handle
this case as:

if (reclaim) {
               if (!memcg ) {
                              iter->generation++;
                              if (!prev) {
                                    memcg = root;
                                    mem_cgroup_iter_update(iter, NULL,
memcg, root,  seq);
                                    goto out_unlock:
                              }
              }
              mem_cgroup_iter_update(iter, last_visited, memcg, root,
                                seq);
              if (!prev && memcg)
                        reclaim->generation = iter->generation;
}

This is literally manual unwinding the second while loop, and thus omit
the while loop,
to save a   mem_cgroup_iter_update() and a mem_cgroup_iter_update()

But it maybe a bit hard to read.

If it is OK, I could resend a new one.

Thanks,
Jianyu Zhan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
