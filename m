Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 242566B0005
	for <linux-mm@kvack.org>; Tue, 31 May 2016 18:53:08 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id x189so7438253ywe.2
        for <linux-mm@kvack.org>; Tue, 31 May 2016 15:53:08 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 75si19191332qgo.49.2016.05.31.15.53.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 May 2016 15:53:07 -0700 (PDT)
Date: Wed, 1 Jun 2016 00:53:03 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 1/6] proc, oom: drop bogus task_lock and mm check
Message-ID: <20160531225303.GE26582@redhat.com>
References: <1464613556-16708-1-git-send-email-mhocko@kernel.org>
 <1464613556-16708-2-git-send-email-mhocko@kernel.org>
 <20160530174324.GA25382@redhat.com>
 <20160531073227.GA26128@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160531073227.GA26128@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On 05/31, Michal Hocko wrote:
>
> Oleg has pointed out that can simplify both oom_adj_write and
> oom_score_adj_write even further and drop the sighand lock. The only
> purpose of the lock was to protect p->signal from going away but this
> will not happen since ea6d290ca34c ("signals: make task_struct->signal
> immutable/refcountable").

Sorry for confusion, I meant oom_adj_read() and oom_score_adj_read().

As for oom_adj_write/oom_score_adj_write we can remove it too, but then
we need to ensure (say, using cmpxchg) that unpriviliged user can not
not decrease signal->oom_score_adj_min if its oom_score_adj_write()
races with someone else (say, admin) which tries to increase the same
oom_score_adj_min.

If you think this is not a problem - I am fine with this change. But
please also update oom_adj_read/oom_score_adj_read ;)

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
