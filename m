Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id BC3EF8D0039
	for <linux-mm@kvack.org>; Sun, 20 Feb 2011 14:53:21 -0500 (EST)
Date: Sun, 20 Feb 2011 11:53:55 -0800 (PST)
Message-Id: <20110220.115355.59672016.davem@davemloft.net>
Subject: Re: BUG: Bad page map in process udevd (anon_vma: (null)) in
 2.6.38-rc4
From: David Miller <davem@davemloft.net>
In-Reply-To: <AANLkTik8kjt1TZ5vOoAm_y0f7toGtOSpxOsgCXO-bey9@mail.gmail.com>
References: <AANLkTincrnq1kMcAYEWYLf5vdbQ4DYbYObbg=0cLfHnm@mail.gmail.com>
	<m1oc67zcov.fsf@fess.ebiederm.org>
	<AANLkTik8kjt1TZ5vOoAm_y0f7toGtOSpxOsgCXO-bey9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: ebiederm@xmission.com, mhocko@suse.cz, mingo@elte.hu, linux-mm@kvack.org, linux-kernel@vger.kernel.org, eric.dumazet@gmail.com

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 19 Feb 2011 22:15:23 -0800

> So unregister_netdevice_many() should always return with the list
> empty and destroyed. There is no valid use of a list of netdevices
> after you've unregistered them.
> 
> Now, dev_deactivate_many() actually has uses of that list after
> they've been de-activated (__dev_close_many will deactivate them, and
> then after that do the whole ndo_stop dance too, so I guess all (two)
> callers of that function need to get rid of their list manually. So I
> think your patch to sch_generic.c is good, but I really think the
> semantics of unregister_netdevice_many() should just be changed.

The key, as Eric D. mentioned, is the moment we changed the "scope" of
this list.

Previously all manipulations and use were guareded entirely inside of
holding the RTNL mutex.

The commit that introduced this regression allowed the list to be
"live" across RTNL mutex drop/re-grab.

Anyways, Eric B.'s patch (which I've just added to net-2.6) should
handle the known remaining cases, and as Eric D. said we should do one
more audit to make sure we got them all now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
