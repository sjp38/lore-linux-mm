Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5DF136B0038
	for <linux-mm@kvack.org>; Tue, 23 Aug 2016 11:27:38 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id g124so299809810qkd.1
        for <linux-mm@kvack.org>; Tue, 23 Aug 2016 08:27:38 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t1si2526812qkl.34.2016.08.23.08.27.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Aug 2016 08:27:37 -0700 (PDT)
Date: Tue, 23 Aug 2016 17:27:11 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [RFC PATCH] kernel/fork: fix CLONE_CHILD_CLEARTID regression
	in nscd
Message-ID: <20160823152711.GA4067@redhat.com>
References: <1470039287-14643-1-git-send-email-mhocko@kernel.org> <20160803210804.GA11549@redhat.com> <20160812094113.GE3639@dhcp22.suse.cz> <20160819132511.GH32619@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160819132511.GH32619@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, William Preston <wpreston@suse.com>, Roland McGrath <roland@hack.frob.com>, Andreas Schwab <schwab@suse.com>

On 08/19, Michal Hocko wrote:
>
> On Fri 12-08-16 11:41:13, Michal Hocko wrote:
> > On Wed 03-08-16 23:08:04, Oleg Nesterov wrote:
> > >
> > > So if we want this change, why we can't simply do
> > >
> > > 	-	if (!(tsk->flags & PF_SIGNALED) &&
> > > 	+	if (!(tsk->signal->flags & SIGNAL_GROUP_COREDUMP) &&
> > >
> > > ?
> >
> > This is what I had initially. But then the comment above the check made
> > me worried that the parent of vforked child might get confused if the
> > flag is cleared.

I don't think the child can be confused... At least I can't imagine how
this can happen.

Anyway, I objected because the tsk->vfork != NULL check was wrong, in this
case this tsk is vforke'd child, not parent.

> So should I drop the vfork check and repost

Probably yes. At least the SIGNAL_GROUP_COREDUMP will match the comment.

> or we do not care about this
> "regression"

Honestly, I do not know ;) Personally, I am always scared when it comes
to the subtle changes like this, you can never know what can be broken.
And note that it can be broken 10 years later, like it happened with
nscd ;)

But if you send the s/PF_SIGNALED/SIGNAL_GROUP_COREDUMP/ change I will
ack it ;) Even if it won't really fix this nscd problem (imo), because
I guess nscd wants to reset ->clear_child_tid even if the signal was
sig_kernel_coredump().

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
