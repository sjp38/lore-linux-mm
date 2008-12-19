Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 6A2CD6B0044
	for <linux-mm@kvack.org>; Fri, 19 Dec 2008 02:18:04 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mBJ7KALf005255
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 19 Dec 2008 16:20:10 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id AD35145DD79
	for <linux-mm@kvack.org>; Fri, 19 Dec 2008 16:20:10 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8279245DD7A
	for <linux-mm@kvack.org>; Fri, 19 Dec 2008 16:20:10 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B82AD1DB8044
	for <linux-mm@kvack.org>; Fri, 19 Dec 2008 16:20:09 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 379AA1DB804A
	for <linux-mm@kvack.org>; Fri, 19 Dec 2008 16:20:08 +0900 (JST)
Date: Fri, 19 Dec 2008 16:19:11 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Corruption with O_DIRECT and unaligned user buffers
Message-Id: <20081219161911.dcf15331.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081218152952.GW24856@random.random>
References: <491DAF8E.4080506@quantum.com>
	<200811191526.00036.nickpiggin@yahoo.com.au>
	<20081119165819.GE19209@random.random>
	<20081218152952.GW24856@random.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Tim LaBerge <tim.laberge@quantum.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 18 Dec 2008 16:29:52 +0100
Andrea Arcangeli <aarcange@redhat.com> wrote:

> On Wed, Nov 19, 2008 at 05:58:19PM +0100, Andrea Arcangeli wrote:
> > On Wed, Nov 19, 2008 at 03:25:59PM +1100, Nick Piggin wrote:
> > > The solution either involves synchronising forks and get_user_pages,
> > > or probably better, to do copy on fork rather than COW in the case
> > > that we detect a page is subject to get_user_pages. The trick is in
> > > the details :)
> > 

> From: Andrea Arcangeli <aarcange@redhat.com>
> Subject: fork-o_direct-race
> 
> Think a thread writing constantly to the last 512bytes of a page, while another
> thread read and writes to/from the first 512bytes of the page. We can lose
> O_DIRECT reads, the very moment we mark any pte wrprotected because a third
> unrelated thread forks off a child.
> 
> This fixes it by never wprotecting anon ptes if there can be any direct I/O in
> flight to the page, and by instantiating a readonly pte and triggering a COW in
> the child. The only trouble here are O_DIRECT reads (writes to memory, read
> from disk). Checking the page_count under the PT lock guarantees no
> get_user_pages could be running under us because if somebody wants to write to
> the page, it has to break any cow first and that requires taking the PT lock in
> follow_page before increasing the page count.
> 
> The COW triggered inside fork will run while the parent pte is read-write, this
> is not usual but that's ok as it's only a page copy and it doesn't modify the
> page contents.
> 
> In the long term there should be a smp_wmb() in between page_cache_get and
> SetPageSwapCache in __add_to_swap_cache and a smp_rmb in between the
> PageSwapCache and the page_count() to remove the trylock op.
> 
> Fixed version of original patch from Nick Piggin.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Confirmed this fixes the problem.

Hmm, but, fork() gets slower. 

Result of cost-of-fork() on ia64.
==
  size of memory  before  after
  Anon=1M   	, 0.07ms, 0.08ms
  Anon=10M  	, 0.17ms, 0.22ms
  Anon=100M 	, 1.15ms, 1.64ms
  Anon=1000M	, 11.5ms, 15.821ms
==

fork() cost is 135% when the process has 1G of Anon.

test program is below. (used "/usr/bin/time" for measurement.)
==
#include <stdlib.h>
#include <sys/types.h>
#include <sys/wait.h>


int main(int argc, char *argv[])
{
        int size, i, status;
        char *c;

        size = atoi(argv[1]) * 1024 * 1024;
        c = malloc(size);
        memset(c, 0,size);
        for (i = 0; i < 5000; i++) {
                if (!fork()) {
                        exit(0);
                }
                wait(&status);
        }
}
==





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
