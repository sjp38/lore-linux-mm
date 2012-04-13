Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 83B506B00EB
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 21:04:51 -0400 (EDT)
Received: by qadb15 with SMTP id b15so5007972qad.9
        for <linux-mm@kvack.org>; Thu, 12 Apr 2012 18:04:50 -0700 (PDT)
Date: Fri, 13 Apr 2012 03:04:45 +0200
From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: [PATCH 1/7] res_counter: add a function
 res_counter_move_parent().
Message-ID: <20120413010443.GD12484@somewhere.redhat.com>
References: <4F86B9BE.8000105@jp.fujitsu.com>
 <4F86BA66.2010503@jp.fujitsu.com>
 <4F86D733.50809@parallels.com>
 <CAFTL4hyKOkoTv=717MkYx4QB0j3B6xA0ZPp1jg6HkrtTkAu7nQ@mail.gmail.com>
 <4F8779DF.3080307@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F8779DF.3080307@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Glauber Costa <glommer@parallels.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>

On Fri, Apr 13, 2012 at 09:57:03AM +0900, KAMEZAWA Hiroyuki wrote:
> (2012/04/12 23:30), Frederic Weisbecker wrote:
> 
> > 2012/4/12 Glauber Costa <glommer@parallels.com>:
> >> On 04/12/2012 08:20 AM, KAMEZAWA Hiroyuki wrote:
> >>>
> >>> This function is used for moving accounting information to its
> >>> parent in the hierarchy of res_counter.
> >>>
> >>> Signed-off-by: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
> >>
> >> Frederic has a patch in his fork cgroup series, that allows you to
> >> uncharge a counter until you reach a specific ancestor.
> >> You pass the parent as a parameter, and then only you gets uncharged.
> > 
> > I'm missing the referring patchset from Kamezawa. Ok I'm going to
> > subscribe to the
> > cgroup mailing list. Meanwhile perhaps would it be nice to keep Cc
> > LKML for cgroup patches?
> > 
> 
> Ah, sorry. I will do next time.
> 
> > Some comments below:
> > 
> >>
> >> I think that is a much better interface than this you are proposing.
> >> We should probably merge that patch and use it.
> >>
> >>> ---
> >>>   include/linux/res_counter.h |    3 +++
> >>>   kernel/res_counter.c        |   13 +++++++++++++
> >>>   2 files changed, 16 insertions(+), 0 deletions(-)
> >>>
> >>> diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
> >>> index da81af0..8919d3c 100644
> >>> --- a/include/linux/res_counter.h
> >>> +++ b/include/linux/res_counter.h
> >>> @@ -135,6 +135,9 @@ int __must_check res_counter_charge_nofail(struct res_counter *counter,
> >>>   void res_counter_uncharge_locked(struct res_counter *counter, unsigned long val);
> >>>   void res_counter_uncharge(struct res_counter *counter, unsigned long val);
> >>>
> >>> +/* move resource to parent counter...i.e. just forget accounting in a child */
> >>> +void res_counter_move_parent(struct res_counter *counter, unsigned long val);
> >>> +
> >>>   /**
> >>>    * res_counter_margin - calculate chargeable space of a counter
> >>>    * @cnt: the counter
> >>> diff --git a/kernel/res_counter.c b/kernel/res_counter.c
> >>> index d508363..fafebf0 100644
> >>> --- a/kernel/res_counter.c
> >>> +++ b/kernel/res_counter.c
> >>> @@ -113,6 +113,19 @@ void res_counter_uncharge(struct res_counter *counter, unsigned long val)
> >>>       local_irq_restore(flags);
> >>>   }
> >>>
> >>> +/*
> >>> + * In hierarchical accounting, child's usage is accounted into ancestors.
> >>> + * To move local usage to its parent, just forget current level usage.
> > 
> > The way I understand this comment and the changelog matches the opposite
> > of what the below function is doing.
> > 
> > The function charges a child and ignore all its parents. The comments says it
> > charges the parents but not the child.
> > 
> 
> 
> Sure, I'll fix...and look into your code first.
> "uncharge a counter until you reach a specific ancestor"...
> Is it in linux-next ?

No, it's part of the task counter so it's still out of tree.
You were Cc'ed but if you can't find it in your inbox I can
resend it:

http://thread.gmane.org/gmane.linux.kernel.containers/22378

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
