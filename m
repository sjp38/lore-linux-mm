Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 100FD6B0005
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 19:44:56 -0400 (EDT)
Date: Wed, 10 Apr 2013 16:44:55 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] vfs: dcache: cond_resched in shrink_dentry_list
Message-Id: <20130410164455.a3cbcbdf86bc72455c22f420@linux-foundation.org>
In-Reply-To: <xr9361zvdxvj.fsf@gthelen.mtv.corp.google.com>
References: <1364232151-23242-1-git-send-email-gthelen@google.com>
	<20130325235614.GI6369@dastard>
	<xr93fvzjgfke.fsf@gthelen.mtv.corp.google.com>
	<20130326024032.GJ6369@dastard>
	<xr934nfyg4ld.fsf@gthelen.mtv.corp.google.com>
	<xr9361zvdxvj.fsf@gthelen.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Dave Chinner <david@fromorbit.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 09 Apr 2013 17:37:20 -0700 Greg Thelen <gthelen@google.com> wrote:

> > Call cond_resched() in shrink_dcache_parent() to maintain
> > interactivity.
> >
> > Before this patch:
> >
> > void shrink_dcache_parent(struct dentry * parent)
> > {
> > 	while ((found = select_parent(parent, &dispose)) != 0)
> > 		shrink_dentry_list(&dispose);
> > }
> >
> > select_parent() populates the dispose list with dentries which
> > shrink_dentry_list() then deletes.  select_parent() carefully uses
> > need_resched() to avoid doing too much work at once.  But neither
> > shrink_dcache_parent() nor its called functions call cond_resched().
> > So once need_resched() is set select_parent() will return single
> > dentry dispose list which is then deleted by shrink_dentry_list().
> > This is inefficient when there are a lot of dentry to process.  This
> > can cause softlockup and hurts interactivity on non preemptable
> > kernels.
> >
> > This change adds cond_resched() in shrink_dcache_parent().  The
> > benefit of this is that need_resched() is quickly cleared so that
> > future calls to select_parent() are able to efficiently return a big
> > batch of dentry.
> >
> > These additional cond_resched() do not seem to impact performance, at
> > least for the workload below.
> >
> > Here is a program which can cause soft lockup on a if other system
> > activity sets need_resched().

I was unable to guess what word was missing from "on a if other" ;)

> Should this change go through Al's or Andrew's branch?

I'll fight him for it.


Softlockups are fairly serious, so I'll put a cc:stable in there.  Or
were the changes which triggered this problem added after 3.9?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
