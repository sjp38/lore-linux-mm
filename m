From: Dave Hansen <dave@linux.vnet.ibm.com>
Subject: Re: [-mm] Add an owner to the mm_struct (v7)
Date: Thu, 03 Apr 2008 11:59:24 -0700
Message-ID: <1207249164.21922.71.camel@nimitz.home.sr71.net>
References: <20080403174433.26356.42121.sendpatchset@localhost.localdomain>
	 <1207247113.21922.63.camel@nimitz.home.sr71.net>
	 <47F52735.7090502@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759425AbYDCS7m@vger.kernel.org>
In-Reply-To: <47F52735.7090502@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: balbir@linux.vnet.ibm.com
Cc: Paul Menage <menage@google.com>, Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-Id: linux-mm.kvack.org

On Fri, 2008-04-04 at 00:21 +0530, Balbir Singh wrote:
> >> +static inline int
> >> +mm_need_new_owner(struct mm_struct *mm, struct task_struct *p)
> >> +{
> >> +	int ret;
> >> +
> >> +	/*
> >> +	 * If there are other users of the mm and the owner (us) is exiting
> >> +	 * we need to find a new owner to take on the responsibility.
> >> +	 * When we use thread groups (CLONE_THREAD), the thread group
> >> +	 * leader is kept around in zombie state, even after it exits.
> >> +	 * delay_group_leader() ensures that if the group leader is around
> >> +	 * we need not select a new owner.
> >> +	 */
> >> +	ret = (mm && (atomic_read(&mm->mm_users) > 1) && (mm->owner == p) &&
> >> +		!delay_group_leader(p));
> >> +	return ret;
> >> +}
> > 
> > Ugh.  Could you please spell this out a bit more.  I find that stuff
> > above really hard to read.  Something like:
> > 
> > 	if (!mm)
> > 		return 0;
> > 	if (atomic_read(&mm->mm_users) <= 1)
> > 		return 0;
> > 	if (mm->owner != p)
> > 		return 0;
> > 	if (delay_group_leader(p))
> > 		return 0;
> > 	return 1;
> > 
> 
> The problem with code above is 4 branch instructions and the code I have just 4
> AND operations.

Please give the compiler a little credit.  Give it a try.  Compile both
versions and see how different they look in the end.  What you see on
your screen in C has very little to do with whether the compiler uses
branch or AND instructions.

> I don't think &&'s are so hard to read. If there is a mixture of
> operations (&&, ||) then it can get a little harder

Yup, it's just a suggestion.  I think the extra parenthesis were the
hardest part for my weak little brain to parse.  It's not awful or
anything, I'm just suggesting what I think is a slightly better form.

> >> +retry:
> >> +	if (!mm_need_new_owner(mm, p))
> >> +		return;
> >> +
> >> +	rcu_read_lock();
> >> +	/*
> >> +	 * Search in the children
> >> +	 */
> >> +	list_for_each_entry(c, &p->children, sibling) {
> >> +		if (c->mm == mm)
> >> +			goto assign_new_owner;
> >> +	}
> >> +
> >> +	/*
> >> +	 * Search in the siblings
> >> +	 */
> >> +	list_for_each_entry(c, &p->parent->children, sibling) {
> >> +		if (c->mm == mm)
> >> +			goto assign_new_owner;
> >> +	}
> >> +
> >> +	/*
> >> +	 * Search through everything else. We should not get
> >> +	 * here often
> >> +	 */
> >> +	do_each_thread(g, c) {
> >> +		if (c->mm == mm)
> >> +			goto assign_new_owner;
> >> +	} while_each_thread(g, c);
> > 
> > What is the case in which we get here?  Threading that's two deep where
> > none of the immeidate siblings or children is still alive?
> > 
> 
> This usually happens for cases where threads were created without CLONE_THREAD.
> We need to scan for shared mm's between processes (siblings and children scans
> have not been successful).
> 
> > Have you happened to instrument this and see if it happens in practice
> > much?
> > 
> 
> Yes, I have. I removed the !delay_group_leader() and registered the cgroup
> mm_owner_changed callback and saw the mm->owner change.

I'm just wondering how *common* it is.  It's a slow operation so perhaps
we should optimize it if it's happening all the time.

-- Dave
