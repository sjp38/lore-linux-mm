Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 2E9C66B004D
	for <linux-mm@kvack.org>; Thu, 15 Oct 2009 20:07:14 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n9G07BX0028423
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 16 Oct 2009 09:07:11 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5CED645DE7B
	for <linux-mm@kvack.org>; Fri, 16 Oct 2009 09:07:11 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2355745DE60
	for <linux-mm@kvack.org>; Fri, 16 Oct 2009 09:07:11 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id EC0911DB8042
	for <linux-mm@kvack.org>; Fri, 16 Oct 2009 09:07:10 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9C2041DB803B
	for <linux-mm@kvack.org>; Fri, 16 Oct 2009 09:07:10 +0900 (JST)
Date: Fri, 16 Oct 2009 09:04:46 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 8/9] swap_info: note SWAP_MAP_SHMEM
Message-Id: <20091016090446.824292c4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0910152317290.4447@sister.anvils>
References: <Pine.LNX.4.64.0910150130001.2250@sister.anvils>
	<Pine.LNX.4.64.0910150156060.3291@sister.anvils>
	<20091015123219.43cfd7b1.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0910152317290.4447@sister.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 15 Oct 2009 23:23:24 +0100 (BST)
Hugh Dickins <hugh.dickins@tiscali.co.uk> wrote:

> On Thu, 15 Oct 2009, KAMEZAWA Hiroyuki wrote:
> > On Thu, 15 Oct 2009 01:57:28 +0100 (BST)
> > Hugh Dickins <hugh.dickins@tiscali.co.uk> wrote:
> > 
> > > While we're fiddling with the swap_map values, let's assign a particular
> > > value to shmem/tmpfs swap pages: their swap counts are never incremented,
> > > and it helps swapoff's try_to_unuse() a little if it can immediately
> > > distinguish those pages from process pages.
> > > 
> > > Since we've no use for SWAP_MAP_BAD | COUNT_CONTINUED,
> > > we might as well use that 0xbf value for SWAP_MAP_SHMEM.
> > > 
> > > Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> > 
> > I welcome this!
> 
> Ah, I did wonder whether you might find some memcg use for it too:
> I'm guessing your welcome means that you do have some such in mind.
> 
yes, I'm thinking I can use this or not on memcg for simplifying memcg's hooks
for shmem. It's complicated ;)
I have to test memcg+shmem carefully again after this patch but I think
there will be no trouble, now.

> (By the way, there's no particular need to use that 0xbf value:
> during most of my testing I was using SWAP_MAP_SHMEM 0x3e and
> SWAP_MAP_MAX 0x3d; but then noticed that 0xbf just happened to be
> free, and also happened to sail through the tests in the right way.
> But if it ever becomes a nuisance there, no problem to move it.)
> 

Hmm. I myself have no troubles whatever free vaule is used. 
let me clarify..

  xx00 0000
  xx11 1110 - swap count max
  01xx xxxx - swap has cache
  1xxx xxxx - swap count has continuation
  1x11 1111 - swap for shmem

seems not very bad.

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
