Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1223E6B025E
	for <linux-mm@kvack.org>; Fri, 19 Aug 2016 09:25:15 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id k135so31452750lfb.2
        for <linux-mm@kvack.org>; Fri, 19 Aug 2016 06:25:15 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id ch18si6314638wjb.75.2016.08.19.06.25.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Aug 2016 06:25:13 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id q128so3440222wma.1
        for <linux-mm@kvack.org>; Fri, 19 Aug 2016 06:25:13 -0700 (PDT)
Date: Fri, 19 Aug 2016 15:25:11 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] kernel/fork: fix CLONE_CHILD_CLEARTID regression in
 nscd
Message-ID: <20160819132511.GH32619@dhcp22.suse.cz>
References: <1470039287-14643-1-git-send-email-mhocko@kernel.org>
 <20160803210804.GA11549@redhat.com>
 <20160812094113.GE3639@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160812094113.GE3639@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, William Preston <wpreston@suse.com>, Roland McGrath <roland@hack.frob.com>, Andreas Schwab <schwab@suse.com>

On Fri 12-08-16 11:41:13, Michal Hocko wrote:
> On Wed 03-08-16 23:08:04, Oleg Nesterov wrote:
> > sorry for delay, I am travelling till the end of the week.
> 
> Same here...
> 
> > On 08/01, Michal Hocko wrote:
[...]
> > > We should also check for vfork because
> > > this is killable since d68b46fe16ad ("vfork: make it killable").
> > 
> > Hmm, why? Can't understand... In any case this check doesn't look right, the
> > comment says "a killed vfork parent" while tsk->vfork_done != NULL means it
> > is a vforked child.
> > 
> > So if we want this change, why we can't simply do
> > 
> > 	-	if (!(tsk->flags & PF_SIGNALED) &&
> > 	+	if (!(tsk->signal->flags & SIGNAL_GROUP_COREDUMP) &&
> > 
> > ?
> 
> This is what I had initially. But then the comment above the check made
> me worried that the parent of vforked child might get confused if the
> flag is cleared. I might have completely misunderstood the point of the
> comment though. So if you believe that vfork_done check is incorrect I
> can drop it. It shouldn't have any effect on the nscd usecase AFAIU.

So should I drop the vfork check and repost or we do not care about this
"regression" and declare nscd broken because it relies on a behavior
which is not in fact guaranteed by the kernel?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
