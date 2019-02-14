Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B4935C10F04
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 21:22:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 75E4E218FF
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 21:22:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 75E4E218FF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 17CBE8E0002; Thu, 14 Feb 2019 16:22:44 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1565F8E0001; Thu, 14 Feb 2019 16:22:44 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0695C8E0002; Thu, 14 Feb 2019 16:22:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id CDFD48E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 16:22:43 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id m34so7033253qtb.14
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 13:22:43 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=0Hts8HKfoq6xzawpRQkWO0Qyk4NLI1ZN8C3xnvZokNc=;
        b=IqJBeolGndwKulQVrEXwopkeE5EOORBTpRGws65gHthP1Xfk70HqSa1Fi2oHDwqjpI
         kVujU36lngIgbT2LxFFBFJ1eP1PpbvnFsqJ1f9x1WDbMErHMspBBGKB3w+rQblKjix1X
         U4W8LwsR73rjmGgwcxlXHoSVRhS+jwByGCQ9sdd92iJ+PAMz5RhyrGNbMbMvHqx4Zm4m
         /IVLnyOx2NkeZM6krNH7kTjz319wPlE6M+wlLu48CfyNs+YgUx6VKk8eFg19lYc5dK1g
         T0e1MAzEyzY2LgqbXJhz8HvDVSSpvZwVZi3LFFMt/ypOG3zmhMllJavR3KbxG+Kxk3ZW
         LVBg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAubfeXZqHkAGT62q5vD37iQs+k8VNHoqfAMSn+xDYbuQJmRoysbp
	TJn0X4vNPbZ/0hbREzoNRWtAeyQ5qrYhjueVg3I2XqAqbUuMBY+BTngLN6Cadp727hxEBAOfzgx
	zGRowdxnyBskXduG73sRA6SLNa2+d12Uq3MEheqFfaB3ilCVO8ciK9JYihevbXFx8rA==
X-Received: by 2002:a37:9f04:: with SMTP id i4mr4347071qke.221.1550179363534;
        Thu, 14 Feb 2019 13:22:43 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY/h3JfqAoE8iMq8+dx1j8Kfb0ovFxlbzqrgzZMmzG1LtLbAn4neiREdePLVIQ/2/Tsw7GL
X-Received: by 2002:a37:9f04:: with SMTP id i4mr4347043qke.221.1550179362944;
        Thu, 14 Feb 2019 13:22:42 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550179362; cv=none;
        d=google.com; s=arc-20160816;
        b=jkZ/hBdqdJJfyA7COF+iWHi7TYyu6bwKKn4EodfRHlRL3M3ffRZxGtU6834lCmNErH
         uleRj0tPI1bMoOnmyiYv/+s6D5/0NO7SndpEQS15pQSKBxSAS5D6R/sW73VLH5+hUfRi
         6KtvoBJOhKgE6nadLyOpzQAXQ4i5U37cy0hPpD+Im7CQhLydvizJpHoXm4hYjMWaqy3k
         MMb3x9yaVxJF9s59Ra5xMelP/OzWeLEItCdRGNiyzxdTPSJDhwYtEMil2p/Rjxc0vHpd
         KnG80uXe5wjZsYhbTgw/4eolc+yCGfkSIbUP64TxMrKwnR8sIi/JD6Vilw5PfDF2q9cL
         WR9A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=0Hts8HKfoq6xzawpRQkWO0Qyk4NLI1ZN8C3xnvZokNc=;
        b=UvBIkfx7NY3yeKcj9Y1IT8fNRaVMxwW1xnDRth+xMTrKDxxLotx669s4Ek2HCCkTgx
         4BJmTJ6Ha1Qf7mhvKXH0mPw0yX5SU6TLFYOT4QAjOzS55jtKHa78d/tbGjXwFNNtykus
         lDfKo4dbqZ/MuJIFHo42rW08YN2RkDNKiqfbEeAGfm8liC934qFEm88BmODIvt/bCBNW
         8pa5NoxHbrbeQUHBcRt16b3xVtHimrpxRKSHX3DTStQJGxkZb6fUjGAgeDX3l9vs311/
         5gnAssEg2ML1UmpGUeGRTdK2HiqGDAJxLXVAUQZ+DutVdW6wbVg88gy/dOMEscZ5fiAQ
         EDYA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z12si2593791qva.55.2019.02.14.13.22.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 13:22:42 -0800 (PST)
Received-SPF: pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 0B5DF42BDA;
	Thu, 14 Feb 2019 21:22:41 +0000 (UTC)
Received: from sky.random (ovpn-120-178.rdu2.redhat.com [10.10.120.178])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 38425611B3;
	Thu, 14 Feb 2019 21:22:37 +0000 (UTC)
Date: Thu, 14 Feb 2019 16:22:36 -0500
From: Andrea Arcangeli <aarcange@redhat.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, "Huang, Ying" <ying.huang@intel.com>,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Hugh Dickins <hughd@google.com>,
	"Paul E . McKenney" <paulmck@linux.vnet.ibm.com>,
	Minchan Kim <minchan@kernel.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Chen <tim.c.chen@linux.intel.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	David Rientjes <rientjes@google.com>,
	Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>,
	Dave Jiang <dave.jiang@intel.com>,
	Daniel Jordan <daniel.m.jordan@oracle.com>,
	Andrea Parri <andrea.parri@amarulasolutions.com>
Subject: Re: [PATCH -mm -V7] mm, swap: fix race between swapoff and some swap
 operations
Message-ID: <20190214212236.GA10698@redhat.com>
References: <20190211083846.18888-1-ying.huang@intel.com>
 <20190214143318.GJ4525@dhcp22.suse.cz>
 <20190214123002.b921b680fea07bf5f798df79@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190214123002.b921b680fea07bf5f798df79@linux-foundation.org>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Thu, 14 Feb 2019 21:22:42 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

On Thu, Feb 14, 2019 at 12:30:02PM -0800, Andrew Morton wrote:
> This was discussed to death and I think the changelog explains the
> conclusions adequately.  swapoff is super-rare so a stop_machine() in
> that path is appropriate if its use permits more efficiency in the
> regular swap code paths.  

The problem is precisely that the way the stop_machine callback is
implemented right now (a dummy noop), makes the stop_machine()
solution fully equivalent to RCU from the fast path point of view. It
does not permit more efficiency in the fast path which is all we care
about.

For the slow path point of view the only difference is possibly that
stop_machine will reach the quiescent state faster (i.e. swapoff may
return a few dozen milliseconds faster), but nobody cares about the
latency of swapoff and it's actually nicer if swapoff doesn't stop all
CPUs on large systems and it uses less CPU overall.

This is why I suggested if we keep using stop_machine() we should not
use a dummy function whose only purpose is to reach a queiscent state
(which is something that is more efficiently achieved with the
syncronize_rcu/sched/kernel RCU API of the day) but we should instead
try to leverage the UP-like serialization to remove more spinlocks
from the fast path and convert them to preempt_disable(). However the
current dummy callback cannot achieve that higher efficiency in the
fast paths, the code would need to be reshuffled to try to remove at
least the swap_lock.

If no spinlock is converted to preempt_disable() RCU I don't see the
point of stop_machine().

On a side note, the cmpxchge machinery I posted to run the function
simultaneously on all CPUs I think may actually be superflous if using
cpus=NULL like Hing suggested. Implementation details aside, still the
idea of stop_machine would be to do those p->swap_map = NULL and
everything protected by the swap_lock, should be executed inside the
callback that runs like in a UP system to speedup the fast path
further.

Thanks,
Andrea

