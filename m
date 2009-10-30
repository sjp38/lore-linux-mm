Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id A1DA36B005A
	for <linux-mm@kvack.org>; Fri, 30 Oct 2009 11:16:01 -0400 (EDT)
Date: Fri, 30 Oct 2009 16:15:44 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: Memory overcommit
Message-ID: <20091030151544.GR9640@random.random>
References: <alpine.DEB.2.00.0910272047430.8988@chino.kir.corp.google.com>
 <4AE846E8.1070303@gmail.com>
 <alpine.DEB.2.00.0910281307370.23279@chino.kir.corp.google.com>
 <4AE9068B.7030504@gmail.com>
 <alpine.DEB.2.00.0910290132320.11476@chino.kir.corp.google.com>
 <4AE97618.6060607@gmail.com>
 <alpine.DEB.2.00.0910291225460.27732@chino.kir.corp.google.com>
 <4AEAEFDD.5060009@gmail.com>
 <20091030141250.GQ9640@random.random>
 <4AEAFB08.8050305@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <4AEAFB08.8050305@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Vedran =?utf-8?B?RnVyYcSN?= <vedran.furac@gmail.com>
Cc: David Rientjes <rientjes@google.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, minchan.kim@gmail.com, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, Oct 30, 2009 at 03:41:12PM +0100, Vedran FuraA? wrote:
> Oh... so this is because apps "reserve" (Committed_AS?) more then they
> currently need.

They don't actually reserve, they end up "reserving" if overcommit is
set to 2 (OVERCOMMIT_NEVER)... Apps aren't reserving, more likely they
simply avoid a flood of mmap when a single one is enough to map an
huge MAP_PRIVATE region like shared libs that you may only execute
partially (this is why total_vm is usually much bigger than real ram
mapped by pagetables represented in rss). But those shared libs are
99% pageable and they don't need to stay in swap or ram, so
overcommit-as greatly overstimates the actual needs even if shared lib
loading wouldn't be 64bit optimized (i.e. large and a single one).

> A the time of "malloc: Cannot allocate memory":
> 
> CommitLimit:     3364440 kB
> Committed_AS:    3240200 kB
> 
> So probably everything is ok (and free is misleading). Overcommit is
> unfortunately necessary if I want to be able to use all my memory.

Add more swap.

> Btw. http://www.redhat.com/advice/tips/meminfo.html says Committed_AS is
> a (gu)estimate. Hope it is a good (not to high) guesstimate. :)

It is a guess in the sense to guarantee no ENOMEM it has to take into
account the worst possible case, that is all shared lib MAP_PRIVATE
mappings are cowed, which is very far from reality. Other than that
the overcommitas should exactly match all mmapped possibly writeable
space that can only fit in ram+swap, so from that point of view it's
not a guessed number (modulo the smp read out of order). The only
guess is how much slab, cache and other stuff is freeable, which
doesn't provide true perfection to OVERCOMMIT_NEVER.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
