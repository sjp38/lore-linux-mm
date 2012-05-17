Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 826406B0082
	for <linux-mm@kvack.org>; Thu, 17 May 2012 01:36:29 -0400 (EDT)
Date: Wed, 16 May 2012 22:37:15 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v5 2/2] decrement static keys on real destroy time
Message-Id: <20120516223715.5d1b4385.akpm@linux-foundation.org>
In-Reply-To: <4FB46B4C.3000307@parallels.com>
References: <1336767077-25351-1-git-send-email-glommer@parallels.com>
	<1336767077-25351-3-git-send-email-glommer@parallels.com>
	<20120516140637.17741df6.akpm@linux-foundation.org>
	<4FB46B4C.3000307@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, netdev@vger.kernel.org, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>

On Thu, 17 May 2012 07:06:52 +0400 Glauber Costa <glommer@parallels.com> wrote:

> ...
> >> +	else if (val != RESOURCE_MAX) {
> >> +		/*
> >> +		 * ->activated needs to be written after the static_key update.
> >> +		 *  This is what guarantees that the socket activation function
> >> +		 *  is the last one to run. See sock_update_memcg() for details,
> >> +		 *  and note that we don't mark any socket as belonging to this
> >> +		 *  memcg until that flag is up.
> >> +		 *
> >> +		 *  We need to do this, because static_keys will span multiple
> >> +		 *  sites, but we can't control their order. If we mark a socket
> >> +		 *  as accounted, but the accounting functions are not patched in
> >> +		 *  yet, we'll lose accounting.
> >> +		 *
> >> +		 *  We never race with the readers in sock_update_memcg(), because
> >> +		 *  when this value change, the code to process it is not patched in
> >> +		 *  yet.
> >> +		 */
> >> +		if (!cg_proto->activated) {
> >> +			static_key_slow_inc(&memcg_socket_limit_enabled);
> >> +			cg_proto->activated = true;
> >> +		}
> >
> > If two threads run this code concurrently, they can both see
> > cg_proto->activated==false and they will both run
> > static_key_slow_inc().
> >
> > Hopefully there's some locking somewhere which prevents this, but it is
> > unobvious.  We should comment this, probably at the cg_proto.activated
> > definition site.  Or we should fix the bug ;)
> >
> If that happens, locking in static_key_slow_inc will prevent any damage.
> My previous version had explicit code to prevent that, but we were 
> pointed out that this is already part of the static_key expectations, so 
> that was dropped.

This makes no sense.  If two threads run that code concurrently,
key->enabled gets incremented twice.  Nobody anywhere has a record that
this happened so it cannot be undone.  key->enabled is now in an
unknown state.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
