Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3E53C6B0253
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 12:42:10 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id l125so41017290ywb.2
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 09:42:10 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x63si1674894qka.80.2016.07.07.09.42.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jul 2016 09:42:09 -0700 (PDT)
Date: Thu, 7 Jul 2016 18:42:05 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] mm,oom: use per signal_struct flag rather than clear
 TIF_MEMDIE
Message-ID: <20160707164204.GB3063@redhat.com>
References: <20160627155119.GA17686@redhat.com>
 <20160627160616.GN31799@dhcp22.suse.cz>
 <20160627175555.GA24370@redhat.com>
 <20160628101956.GA510@dhcp22.suse.cz>
 <20160629001353.GA9377@redhat.com>
 <20160629083314.GA27153@dhcp22.suse.cz>
 <20160629200108.GA19253@redhat.com>
 <20160630075904.GC18783@dhcp22.suse.cz>
 <20160703132147.GA28267@redhat.com>
 <20160707115125.GJ5379@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160707115125.GJ5379@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, vdavydov@virtuozzo.com, rientjes@google.com

On 07/07, Michal Hocko wrote:
>
> On Sun 03-07-16 15:21:47, Oleg Nesterov wrote:
> > >
> > > I am not sure I can see security implications but I agree this is less
> > > than optimal,
> >
> > Well, just suppose that a memory hog execs a setuid application which does
> > something important, then we can kill it in some "inconsistent" state. Say,
> > after it created a file-lock which blocks other instances.
>
> How that would differ from selecting and killing the suid application
> right away?

in this case we at least check oom_score_adj/has_capability_noaudit(CAP_SYS_ADMIN)
before we decide to kill it.

> > And it is not clear to me why "child_points > victim_points" can be true if
> > the victim was chosen by select_bad_process() (to simplify the discussion,
> > lets ignore has_intersects_mems_allowed/etc).
>
> Because victim_points is a bit of misnomer. It doesn't have anything to
> do with selected victim's score. victim_points is 0 before the loop.

Ah, thanks. Yes I misread the code.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
