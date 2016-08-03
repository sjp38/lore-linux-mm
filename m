Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4487F6B0253
	for <linux-mm@kvack.org>; Wed,  3 Aug 2016 17:08:09 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id v184so373622553qkc.0
        for <linux-mm@kvack.org>; Wed, 03 Aug 2016 14:08:09 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i26si6017346qte.95.2016.08.03.14.08.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Aug 2016 14:08:08 -0700 (PDT)
Date: Wed, 3 Aug 2016 23:08:04 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [RFC PATCH] kernel/fork: fix CLONE_CHILD_CLEARTID regression in
 nscd
Message-ID: <20160803210804.GA11549@redhat.com>
References: <1470039287-14643-1-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1470039287-14643-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, William Preston <wpreston@suse.com>, Michal Hocko <mhocko@suse.com>, Roland McGrath <roland@hack.frob.com>, Andreas Schwab <schwab@suse.com>

sorry for delay, I am travelling till the end of the week.

On 08/01, Michal Hocko wrote:
>
> fec1d0115240 ("[PATCH] Disable CLONE_CHILD_CLEARTID for abnormal exit")

almost 10 years ago ;)

> has caused a subtle regression in nscd which uses CLONE_CHILD_CLEARTID
> to clear the nscd_certainly_running flag in the shared databases, so
> that the clients are notified when nscd is restarted.

So iiuc with this patch nscd_certainly_running should be cleared even if
ncsd was killed by !sig_kernel_coredump() signal, right?

> We should also check for vfork because
> this is killable since d68b46fe16ad ("vfork: make it killable").

Hmm, why? Can't understand... In any case this check doesn't look right, the
comment says "a killed vfork parent" while tsk->vfork_done != NULL means it
is a vforked child.

So if we want this change, why we can't simply do

	-	if (!(tsk->flags & PF_SIGNALED) &&
	+	if (!(tsk->signal->flags & SIGNAL_GROUP_COREDUMP) &&

?

And I think PF_SIGNALED must die in any case... but this is off-topic.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
