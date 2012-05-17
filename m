Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 497256B0044
	for <linux-mm@kvack.org>; Thu, 17 May 2012 06:20:11 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 6898C3EE0BD
	for <linux-mm@kvack.org>; Thu, 17 May 2012 19:20:09 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4AA2A45DE5E
	for <linux-mm@kvack.org>; Thu, 17 May 2012 19:20:09 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1EE8645DE52
	for <linux-mm@kvack.org>; Thu, 17 May 2012 19:20:09 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0F6A21DB8042
	for <linux-mm@kvack.org>; Thu, 17 May 2012 19:20:09 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B54311DB803A
	for <linux-mm@kvack.org>; Thu, 17 May 2012 19:20:08 +0900 (JST)
Message-ID: <4FB4D061.10406@jp.fujitsu.com>
Date: Thu, 17 May 2012 19:18:09 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 2/2] decrement static keys on real destroy time
References: <1336767077-25351-1-git-send-email-glommer@parallels.com> <1336767077-25351-3-git-send-email-glommer@parallels.com> <20120516140637.17741df6.akpm@linux-foundation.org> <4FB46B4C.3000307@parallels.com> <20120516223715.5d1b4385.akpm@linux-foundation.org> <4FB4CA4D.50608@parallels.com>
In-Reply-To: <4FB4CA4D.50608@parallels.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, cgroups@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org, netdev@vger.kernel.org, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>

(2012/05/17 18:52), Glauber Costa wrote:

> On 05/17/2012 09:37 AM, Andrew Morton wrote:
>>>>  If that happens, locking in static_key_slow_inc will prevent any damage.
>>>>  My previous version had explicit code to prevent that, but we were
>>>>  pointed out that this is already part of the static_key expectations, so
>>>>  that was dropped.
>> This makes no sense.  If two threads run that code concurrently,
>> key->enabled gets incremented twice.  Nobody anywhere has a record that
>> this happened so it cannot be undone.  key->enabled is now in an
>> unknown state.
> 
> Kame, Tejun,
> 
> Andrew is right. It seems we will need that mutex after all. Just this 
> is not a race, and neither something that should belong in the 
> static_branch interface.
> 


Hmm....how about having

res_counter_xchg_limit(res, &old_limit, new_limit);

if (!cg_proto->updated && old_limit == RESOURCE_MAX)
	....update labels...

Then, no mutex overhead maybe and activated will be updated only once.
Ah, but please fix in a way you like. Above is an example.

Thanks,
-Kame
(*) I'm sorry I won't be able to read e-mails, tomorrow.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
