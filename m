Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id DB9F16B002C
	for <linux-mm@kvack.org>; Wed, 12 Oct 2011 16:35:58 -0400 (EDT)
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id p9CKZtVh026722
	for <linux-mm@kvack.org>; Wed, 12 Oct 2011 13:35:55 -0700
Received: from pzd13 (pzd13.prod.google.com [10.243.17.205])
	by hpaq2.eem.corp.google.com with ESMTP id p9CKUrU0009471
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 12 Oct 2011 13:35:53 -0700
Received: by pzd13 with SMTP id 13so1436130pzd.3
        for <linux-mm@kvack.org>; Wed, 12 Oct 2011 13:35:53 -0700 (PDT)
Date: Wed, 12 Oct 2011 13:35:51 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: possible slab deadlock while doing ifenslave
In-Reply-To: <201110121019.53100.hans@schillstrom.com>
Message-ID: <alpine.DEB.2.00.1110121333560.7646@chino.kir.corp.google.com>
References: <201110121019.53100.hans@schillstrom.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hans Schillstrom <hans@schillstrom.com>
Cc: linux-mm@kvack.org

On Wed, 12 Oct 2011, Hans Schillstrom wrote:

> Hello,
> I got this when I was testing a VLAN patch i.e. using Dave Millers net-next from today.
> When doing this on a single core i686 I got the warning every time,
> however ifenslave is not hanging it's just a warning
> Have not been testing this on a multicore jet.
> 
> There is no warnings with a 3.0.4 kernel.
> 
> Is this a known warning ?
> 
> ~ # ifenslave bond0 eth1 eth2
> 
> =============================================
> [ INFO: possible recursive locking detected ]
> 3.1.0-rc9+ #3
> ---------------------------------------------
> ifenslave/749 is trying to acquire lock:
>  (&(&parent->list_lock)->rlock){-.-...}, at: [<c14234a0>] cache_flusharray+0x41/0xdb
> 
> but task is already holding lock:
>  (&(&parent->list_lock)->rlock){-.-...}, at: [<c14234a0>] cache_flusharray+0x41/0xdb
> 

Hmm, the only candidate that I can see that may have caused this is 
83835b3d9aec ("slab, lockdep: Annotate slab -> rcu -> debug_object -> 
slab").  Could you try reverting that patch in your local tree and seeing 
if it helps?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
