Return-Path: <SRS0=L2Uh=RS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C350BC10F00
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 21:39:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 865EB218A1
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 21:39:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 865EB218A1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 016C06B02CB; Fri, 15 Mar 2019 17:39:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EE1146B02CC; Fri, 15 Mar 2019 17:39:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DABAC6B02CD; Fri, 15 Mar 2019 17:39:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id B5DA36B02CB
	for <linux-mm@kvack.org>; Fri, 15 Mar 2019 17:39:49 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id l87so8966929qki.10
        for <linux-mm@kvack.org>; Fri, 15 Mar 2019 14:39:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=swqwZha9BXWgetb1NNjrOQQKfGmgkrLsd+O2BNX0Vag=;
        b=Bp5w31C6siyaQYGfsO3dS8+r82f2cq7+HfiZfuyxsXVaTDZpHGJ5QY+vTEs95dvWer
         t0QyTbVTLUdWIBPRhESvDDRcDotgpPn1eSkNIgk9ndS4SYtXFiOvHLOk5nAdPlxvl9hP
         ckH5tgwS2UkTHbVraOUHDdrM2gW1xhpdhNkwFoI7AL8Du64z270Rrv/lAQgpXCnIdJdf
         LNbCbQ82xmbRvSlnTpVK2mD21juIn/NyYg7aklM08T1+/mjG1eIwko/7RfwYs8hBbJPn
         uEqBqaEQIVP+E81+npw1n16Jf1IvuYB+VHNM8ubBYk0cDssmD2xIYLawfS6tV7Yde5Dn
         7INg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAX/1hWeVaX5cfGuaZqeYZP9UqsieRSRKmw8MXPDewJG9pp16zgI
	6zyxE4sw4lZJiegMxMW1xd2gJSPMxGWGJw6WRo+YbdYZN2hBXqExAlXzz5NjFB53ep9ha1TZ/z5
	g2S//QPig2v7Dr9WV8Uk2qtDEqkFaS/wk+KQzk7qyG8zcQoM4I/eFsVgIjyYA6Q7Fqg==
X-Received: by 2002:a37:c0d4:: with SMTP id v81mr4722108qkv.336.1552685989531;
        Fri, 15 Mar 2019 14:39:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzHPFmYaWU7/p7VjlXvNWcGBfVqVeBtYPrlV8XA1mvtEEdUfgZWyPsz9wgbdYiqEiz+bntL
X-Received: by 2002:a37:c0d4:: with SMTP id v81mr4722077qkv.336.1552685988733;
        Fri, 15 Mar 2019 14:39:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552685988; cv=none;
        d=google.com; s=arc-20160816;
        b=ScYetbrSkQ7l/ApP+HZgPc1JRNJ/SJmQON7GrSkJ/gozR6o/cbB6eLd9AT8JevdhRh
         EPap2rwEvv/z5nC7hes8t11AlSzxCWh7HeGyoKO/AhfWdsgFFY4m0/vCeZ6z9pNTivyx
         izaxpU++queJ7mMbVgV/YGeTU4Z/Is3YwEoYxDoCaS3xBtd/PAfIC+F8sU9tGZqOX7yr
         4uImgR0qPK0Uc4cCPIC4Ldid5uuwp+USVxENnD5zlstr08lMBSjCvIsiGgIbp9TyW+ds
         Rf7WrQ7Db7PiIBwd25lmvWdwAsHiFpurLDq142SZfyUuDZsNcHPQ5BZDfo03afpafnkM
         uPOQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=swqwZha9BXWgetb1NNjrOQQKfGmgkrLsd+O2BNX0Vag=;
        b=GYWDBw8r+B5ZmNfj/doddJqni9Itw8nklH3lLMG3MW1kUo5nLxXTdyQp2Fkuk6wCSG
         JYD7zpEHjuQudIN+mlIn19PQc4cH5ALQoEqW3WsPnM4wlHu8laTmAVrvadJjUY+UwdHv
         Hw834G03F9U1ZwjBwlIRQQiv+6Ajn0eIqKqgx89VT1IgpcF6sLkDoGHbftzzwmqWxx5B
         lDdYB0P5lskOWR8Lo8zwrvSnSUD54DQjAJkrBswmhPZF6f9Jw49Bmu+pb7XJyX/sTGSJ
         o60QOBwFweDbEyrGuScbR7BQprcQDtUcluc+qQNRv3OEvjqo3g6ydZK/bJutxQWqR6Hx
         JqYA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z2si1911987qti.353.2019.03.15.14.39.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Mar 2019 14:39:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id D20D93082B40;
	Fri, 15 Mar 2019 21:39:47 +0000 (UTC)
Received: from sky.random (ovpn-121-1.rdu2.redhat.com [10.10.121.1])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id A36055D6A6;
	Fri, 15 Mar 2019 21:39:45 +0000 (UTC)
Date: Fri, 15 Mar 2019 17:39:44 -0400
From: Andrea Arcangeli <aarcange@redhat.com>
To: zhong jiang <zhongjiang@huawei.com>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>, Peter Xu <peterx@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	syzbot <syzbot+cbb52e396df3e565ab02@syzkaller.appspotmail.com>,
	Michal Hocko <mhocko@kernel.org>, cgroups@vger.kernel.org,
	Johannes Weiner <hannes@cmpxchg.org>,
	LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
	syzkaller-bugs <syzkaller-bugs@googlegroups.com>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	David Rientjes <rientjes@google.com>,
	Hugh Dickins <hughd@google.com>,
	Matthew Wilcox <willy@infradead.org>, Mel Gorman <mgorman@suse.de>,
	Vlastimil Babka <vbabka@suse.cz>
Subject: Re: KASAN: use-after-free Read in get_mem_cgroup_from_mm
Message-ID: <20190315213944.GD9967@redhat.com>
References: <00000000000006457e057c341ff8@google.com>
 <5C7BFE94.6070500@huawei.com>
 <CACT4Y+Z+CH0UTdSz-w_woMPrBwg-GuobV1Su4qd9ReffTkyfVg@mail.gmail.com>
 <5C7D2F82.40907@huawei.com>
 <CACT4Y+agwaszODNGJHCqn4fSk4Le9exn3Cau0nornJ0RaTpDJw@mail.gmail.com>
 <5C7D4500.3070607@huawei.com>
 <CACT4Y+b6y_3gTpR8LvNREHOV0TP7jB=Zp1L03dzpaz_SaeESng@mail.gmail.com>
 <5C7E1A38.2060906@huawei.com>
 <20190306020540.GA23850@redhat.com>
 <5C821550.50506@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5C821550.50506@huawei.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Fri, 15 Mar 2019 21:39:48 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 08, 2019 at 03:10:08PM +0800, zhong jiang wrote:
> I can reproduce the issue in arm64 qemu machine.  The issue will leave after applying the
> patch.
> 
> Tested-by: zhong jiang <zhongjiang@huawei.com>

Thanks a lot for the quick testing!

> Meanwhile,  I just has a little doubt whether it is necessary to use RCU to free the task struct or not.
> I think that mm->owner alway be NULL after failing to create to process. Because we call mm_clear_owner.

I wish it was enough, but the problem is that the other CPU may be in
the middle of get_mem_cgroup_from_mm() while this runs, and it would
dereference mm->owner while it is been freed without the call_rcu
affter we clear mm->owner. What prevents this race is the
rcu_read_lock() in get_mem_cgroup_from_mm() and the corresponding
call_rcu to free the task struct in the fork failure path (again only
if CONFIG_MEMCG=y is defined). Considering you can reproduce this tiny
race on arm64 qemu (perhaps tcg JIT timing variantions helps?), you
might also in theory be able to still reproduce the race condition if
you remove the call_rcu from delayed_free_task and you replace it with
free_task.

