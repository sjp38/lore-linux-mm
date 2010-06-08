Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 97CE66B01C4
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 17:34:46 -0400 (EDT)
Date: Tue, 8 Jun 2010 14:34:01 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 02/18] oom: introduce find_lock_task_mm() to fix !mm
 false positives
Message-Id: <20100608143401.65d7c932.akpm@linux-foundation.org>
In-Reply-To: <20100608201739.GA11028@redhat.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1006061521310.32225@chino.kir.corp.google.com>
	<20100608124246.9258ccab.akpm@linux-foundation.org>
	<20100608201403.GA10264@redhat.com>
	<20100608201739.GA11028@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 8 Jun 2010 22:17:39 +0200
Oleg Nesterov <oleg@redhat.com> wrote:

> On 06/08, Oleg Nesterov wrote:
> >
> > On 06/08, Andrew Morton wrote:
> > >
> > > > -		/* skip tasks that have already released their mm */
> > > > -		if (!p->mm)
> > > > -			continue;
> >
> > We shouldn't remove this without removing OR updating the PF_EXITING check
> > below. That is why we had another patch.
> >
> > This change alone allows to trivially disable oom-kill. If we have a process
> > with the dead leader, select_bad_process() will always return -1.
> >
> > We either need another patch from Kosaki's series
> >
> > 	- if (p->flags & PF_EXITING)
> > 	+ if (p->flags & PF_EXITING && p->mm)
> 
> OOPS, sorry.
> 
> I didn't understand you are going to merge this change too.
> 
> Probably oom-pf_exiting-check-should-take-mm-into-account.patch should
> go ahead of this one for bisecting.

OK, thanks, I did that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
