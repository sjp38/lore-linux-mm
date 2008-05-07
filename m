Received: from zps19.corp.google.com (zps19.corp.google.com [172.25.146.19])
	by smtp-out.google.com with ESMTP id m473bqAM001846
	for <linux-mm@kvack.org>; Wed, 7 May 2008 04:37:52 +0100
Received: from an-out-0708.google.com (anac38.prod.google.com [10.100.54.38])
	by zps19.corp.google.com with ESMTP id m473boRE023014
	for <linux-mm@kvack.org>; Tue, 6 May 2008 20:37:51 -0700
Received: by an-out-0708.google.com with SMTP id c38so27772ana.3
        for <linux-mm@kvack.org>; Tue, 06 May 2008 20:37:50 -0700 (PDT)
Message-ID: <6599ad830805062037n221ef8e2n9ee7ac33417ab499@mail.gmail.com>
Date: Tue, 6 May 2008 20:37:50 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: on CONFIG_MM_OWNER=y, kernel panic is possible.
In-Reply-To: <20080506153943.AC69.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080506151510.AC66.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <481FFAAB.3030008@linux.vnet.ibm.com>
	 <20080506153943.AC69.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, May 5, 2008 at 11:43 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
> > >  #ifdef CONFIG_MM_OWNER
>  > > -       struct task_struct *owner;      /* The thread group leader that */
>  > > -                                       /* owns the mm_struct.          */
>  > > +       struct task_struct *owner;      /* point to one of task that owns the mm_struct. */
>  > >  #endif
>  > >
>  > >  #ifdef CONFIG_PROC_FS
>  >
>  > How about just, the task that owns the mm_struct? One of, implies multiple owners.
>
>  Ah, below is better?
>
>  /* point to any one of task that related the mm_struct. */

I'd word it as

/*
 * "owner" points to a task that is regarded as the canonical
 * user/owner of this mm. All of the following must be true in
 * order for it to be changed:
 *
 * current == mm->owner
 * current->mm != mm
 * new_owner->mm == mm
 * new_owner->alloc_lock is held
 */

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
