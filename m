Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 2884D6B0044
	for <linux-mm@kvack.org>; Thu, 17 May 2012 05:54:22 -0400 (EDT)
Message-ID: <4FB4CA4D.50608@parallels.com>
Date: Thu, 17 May 2012 13:52:13 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 2/2] decrement static keys on real destroy time
References: <1336767077-25351-1-git-send-email-glommer@parallels.com> <1336767077-25351-3-git-send-email-glommer@parallels.com> <20120516140637.17741df6.akpm@linux-foundation.org> <4FB46B4C.3000307@parallels.com> <20120516223715.5d1b4385.akpm@linux-foundation.org>
In-Reply-To: <20120516223715.5d1b4385.akpm@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, netdev@vger.kernel.org, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>

On 05/17/2012 09:37 AM, Andrew Morton wrote:
>> >  If that happens, locking in static_key_slow_inc will prevent any damage.
>> >  My previous version had explicit code to prevent that, but we were
>> >  pointed out that this is already part of the static_key expectations, so
>> >  that was dropped.
> This makes no sense.  If two threads run that code concurrently,
> key->enabled gets incremented twice.  Nobody anywhere has a record that
> this happened so it cannot be undone.  key->enabled is now in an
> unknown state.

Kame, Tejun,

Andrew is right. It seems we will need that mutex after all. Just this 
is not a race, and neither something that should belong in the 
static_branch interface.

We want to make sure that enabled is not updated before the jump label 
update, because we need a specific ordering guarantee at the patched 
sites. And *that*, the interface guarantees, and we were wrong to 
believe it did not. That is a correction issue for the accounting, and 
that part is right.

But when we disarm it, we'll need to make sure that happened only once, 
otherwise we may never unpatch it. That, or we'd need that to be a 
counter. The jump label interface does not - and should not - keep track 
of how many updates happened to a key. That's the role of whoever is 
using it.

If you agree with the above, I'll send this patch again with the correction.

Andrew, thank you very much. Do you spot anything else here?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
