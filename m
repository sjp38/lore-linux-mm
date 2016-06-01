Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id A7DCA6B0005
	for <linux-mm@kvack.org>; Wed,  1 Jun 2016 02:53:44 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id w16so4761748lfd.0
        for <linux-mm@kvack.org>; Tue, 31 May 2016 23:53:44 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id w5si41519560wma.42.2016.05.31.23.53.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 May 2016 23:53:41 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id q62so3786697wmg.3
        for <linux-mm@kvack.org>; Tue, 31 May 2016 23:53:41 -0700 (PDT)
Date: Wed, 1 Jun 2016 08:53:39 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/6] proc, oom: drop bogus task_lock and mm check
Message-ID: <20160601065339.GA26601@dhcp22.suse.cz>
References: <1464613556-16708-1-git-send-email-mhocko@kernel.org>
 <1464613556-16708-2-git-send-email-mhocko@kernel.org>
 <20160530174324.GA25382@redhat.com>
 <20160531073227.GA26128@dhcp22.suse.cz>
 <20160531225303.GE26582@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160531225303.GE26582@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Wed 01-06-16 00:53:03, Oleg Nesterov wrote:
> On 05/31, Michal Hocko wrote:
> >
> > Oleg has pointed out that can simplify both oom_adj_write and
> > oom_score_adj_write even further and drop the sighand lock. The only
> > purpose of the lock was to protect p->signal from going away but this
> > will not happen since ea6d290ca34c ("signals: make task_struct->signal
> > immutable/refcountable").
> 
> Sorry for confusion, I meant oom_adj_read() and oom_score_adj_read().
> 
> As for oom_adj_write/oom_score_adj_write we can remove it too, but then
> we need to ensure (say, using cmpxchg) that unpriviliged user can not
> not decrease signal->oom_score_adj_min if its oom_score_adj_write()
> races with someone else (say, admin) which tries to increase the same
> oom_score_adj_min.

I am introducing oom_adj_mutex in a later patch so I will move it here.

> If you think this is not a problem - I am fine with this change. But
> please also update oom_adj_read/oom_score_adj_read ;)

will do. It stayed in the blind spot... Thanks for pointing that out

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
