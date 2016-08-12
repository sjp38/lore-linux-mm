Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id A15096B0253
	for <linux-mm@kvack.org>; Fri, 12 Aug 2016 05:41:16 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 1so12551926wmz.2
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 02:41:16 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id x2si6291543wjm.38.2016.08.12.02.41.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Aug 2016 02:41:15 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id q128so1861307wma.1
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 02:41:15 -0700 (PDT)
Date: Fri, 12 Aug 2016 11:41:13 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] kernel/fork: fix CLONE_CHILD_CLEARTID regression in
 nscd
Message-ID: <20160812094113.GE3639@dhcp22.suse.cz>
References: <1470039287-14643-1-git-send-email-mhocko@kernel.org>
 <20160803210804.GA11549@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160803210804.GA11549@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, William Preston <wpreston@suse.com>, Roland McGrath <roland@hack.frob.com>, Andreas Schwab <schwab@suse.com>

On Wed 03-08-16 23:08:04, Oleg Nesterov wrote:
> sorry for delay, I am travelling till the end of the week.

Same here...

> On 08/01, Michal Hocko wrote:
> >
> > fec1d0115240 ("[PATCH] Disable CLONE_CHILD_CLEARTID for abnormal exit")
> 
> almost 10 years ago ;)

Yes, it's been a while... I guess nscd doesn't enable persistent host
caching by default. I just know that our customer wanted to enable this
feature to find out it doesn't work properly. At least that is my
understanding.

> > has caused a subtle regression in nscd which uses CLONE_CHILD_CLEARTID
> > to clear the nscd_certainly_running flag in the shared databases, so
> > that the clients are notified when nscd is restarted.
> 
> So iiuc with this patch nscd_certainly_running should be cleared even if
> ncsd was killed by !sig_kernel_coredump() signal, right?

Yes.

> > We should also check for vfork because
> > this is killable since d68b46fe16ad ("vfork: make it killable").
> 
> Hmm, why? Can't understand... In any case this check doesn't look right, the
> comment says "a killed vfork parent" while tsk->vfork_done != NULL means it
> is a vforked child.
> 
> So if we want this change, why we can't simply do
> 
> 	-	if (!(tsk->flags & PF_SIGNALED) &&
> 	+	if (!(tsk->signal->flags & SIGNAL_GROUP_COREDUMP) &&
> 
> ?

This is what I had initially. But then the comment above the check made
me worried that the parent of vforked child might get confused if the
flag is cleared. I might have completely misunderstood the point of the
comment though. So if you believe that vfork_done check is incorrect I
can drop it. It shouldn't have any effect on the nscd usecase AFAIU.

Thanks!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
