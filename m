Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 5DAEA8D0039
	for <linux-mm@kvack.org>; Sun, 20 Feb 2011 16:34:55 -0500 (EST)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <AANLkTincrnq1kMcAYEWYLf5vdbQ4DYbYObbg=0cLfHnm@mail.gmail.com>
	<m1oc67zcov.fsf@fess.ebiederm.org>
	<AANLkTik8kjt1TZ5vOoAm_y0f7toGtOSpxOsgCXO-bey9@mail.gmail.com>
	<20110220.115355.59672016.davem@davemloft.net>
Date: Sun, 20 Feb 2011 13:34:41 -0800
In-Reply-To: <20110220.115355.59672016.davem@davemloft.net> (David Miller's
	message of "Sun, 20 Feb 2011 11:53:55 -0800 (PST)")
Message-ID: <m1d3mmxudq.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Subject: Re: BUG: Bad page map in process udevd (anon_vma: (null)) in 2.6.38-rc4
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: torvalds@linux-foundation.org, mhocko@suse.cz, mingo@elte.hu, linux-mm@kvack.org, linux-kernel@vger.kernel.org, eric.dumazet@gmail.com

David Miller <davem@davemloft.net> writes:

> From: Linus Torvalds <torvalds@linux-foundation.org>
> Date: Sat, 19 Feb 2011 22:15:23 -0800
>
>> So unregister_netdevice_many() should always return with the list
>> empty and destroyed. There is no valid use of a list of netdevices
>> after you've unregistered them.
>> 
>> Now, dev_deactivate_many() actually has uses of that list after
>> they've been de-activated (__dev_close_many will deactivate them, and
>> then after that do the whole ndo_stop dance too, so I guess all (two)
>> callers of that function need to get rid of their list manually. So I
>> think your patch to sch_generic.c is good, but I really think the
>> semantics of unregister_netdevice_many() should just be changed.
>
> The key, as Eric D. mentioned, is the moment we changed the "scope" of
> this list.
>
> Previously all manipulations and use were guareded entirely inside of
> holding the RTNL mutex.
>
> The commit that introduced this regression allowed the list to be
> "live" across RTNL mutex drop/re-grab.

No.

Previoously there was exactly one usage of dev->unreg_list:  To gather
a list of network devices to unregister_netdevice_many.

We added using dev->unreg_list to dev_deactivate and dev_close.

Using this list head multiple times when done carefully is safe because
every usage is covered entirely by the RTNL lock.

The essence is of the trigger case was to drop the link (dev_deactivate)
or down the interface (dev_close) and then remove the network device
(rmmod or ip link del).

If we ever dropped the rtnl lock while using dev->unreg_list we would
have mysterious errors that would be a pain to track down.

> Anyways, Eric B.'s patch (which I've just added to net-2.6) should
> handle the known remaining cases, and as Eric D. said we should do one
> more audit to make sure we got them all now.

My tests have been running without an list debug errors since I applied
my change.  So we should be good on that front. Thanks for applying my fixes.

Still on my list of bugs I can see in 2.6.38-rc5+ are:
- macvlan use after free of macvlan_port.
- tftp over ipv6 getpeername problems.
- Something that is resulting in 'address already in use', and 
  'connection reset by peer' errors that only happen in 2.6.38.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
