Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 18F856B01F8
	for <linux-mm@kvack.org>; Mon, 26 Apr 2010 06:18:39 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3QAIb7U007404
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 26 Apr 2010 19:18:37 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2D00945DE57
	for <linux-mm@kvack.org>; Mon, 26 Apr 2010 19:18:37 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0AC8045DE4F
	for <linux-mm@kvack.org>; Mon, 26 Apr 2010 19:18:37 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id DF9D41DB8038
	for <linux-mm@kvack.org>; Mon, 26 Apr 2010 19:18:36 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7E04E1DB803A
	for <linux-mm@kvack.org>; Mon, 26 Apr 2010 19:18:33 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: No one seems to be using AOP_WRITEPAGE_ACTIVATE?
In-Reply-To: <E1O5rld-0001AX-Lk@closure.thunk.org>
References: <E1O5rld-0001AX-Lk@closure.thunk.org>
Message-Id: <20100426094837.2E5E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 26 Apr 2010 19:18:32 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Theodore Ts'o <tytso@mit.edu>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, Hugh Dickins <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

Hi Ted


> I happened to be going through the source code for write_cache_pages(),
> and I came across a reference to AOP_WRITEPAGE_ACTIVATE.  I was curious
> what the heck that was, so I did search for it, and found this in
> Documentation/filesystems/vfs.txt:
> 
>       If wbc->sync_mode is WB_SYNC_NONE, ->writepage doesn't have to
>       try too hard if there are problems, and may choose to write out
>       other pages from the mapping if that is easier (e.g. due to
>       internal dependencies).  If it chooses not to start writeout, it
>       should return AOP_WRITEPAGE_ACTIVATE so that the VM will not keep
>       calling ->writepage on that page.
> 
>       See the file "Locking" for more details.
> 
> No filesystems are currently returning AOP_WRITEPAGE_ACTIVATE when it
> chooses not to writeout page and call redirty_page_for_writeback()
> instead.
> 
> Is this a change we should make, for example when btrfs refuses a
> writepage() when PF_MEMALLOC is set, or when ext4 refuses a writepage()
> if the page involved hasn't been allocated an on-disk block yet (i.e.,
> delayed allocation)?  The change seems to be that we should call
> redirty_page_for_writeback() as before, but then _not_ unlock the page,
> and return AOP_WRITEPAGE_ACTIVATE.  Is this a good and useful thing for
> us to do?

Sorry, no.

AOP_WRITEPAGE_ACTIVATE was introduced for ramdisk and tmpfs thing
(and later rd choosed to use another way).
Then, It assume writepage refusing aren't happen on majority pages.
IOW, the VM assume other many pages can writeout although the page can't.
Then, the VM only make page activation if AOP_WRITEPAGE_ACTIVATE is returned.
but now ext4 and btrfs refuse all writepage(). (right?)

IOW, I don't think such documentation suppose delayed allocation issue ;)

The point is, Our dirty page accounting only account per-system-memory
dirty ratio and per-task dirty pages. but It doesn't account per-numa-node
nor per-zone dirty ratio. and then, to refuse write page and fake numa
abusing can make confusing our vm easily. if _all_ pages in our VM LRU
list (it's per-zone), page activation doesn't help. It also lead to OOM.

And I'm sorry. I have to say now all vm developers fake numa is not
production level quority yet. afaik, nobody have seriously tested our
vm code on such environment. (linux/arch/x86/Kconfig says "This is only 
useful for debugging".)

	--------------------------------------------------------------
	config NUMA_EMU
	        bool "NUMA emulation"
	        depends on X86_64 && NUMA
	        ---help---
	          Enable NUMA emulation. A flat machine will be split
	          into virtual nodes when booted with "numa=fake=N", where N is the
	          number of nodes. This is only useful for debugging.


> 
> Right now, the only writepage() function which is returning
> AOP_WRITEPAGE_ACTIVATE is shmem_writepage(), and very curiously it's not
> using redirty_page_for_writeback().  Should it, out of consistency's
> sake if not to keep various zone accounting straight?

Umm. I don't know the reason. instead I've cc to hugh :)


> There are some longer-term issues, including the fact that ext4 and
> btrfs are violating some of the rules laid out in
> Documentation/vfs/Locking regarding what writepage() is supposed to do
> under direct reclaim -- something which isn't going to be practical for
> us to change on the file-system side, at least not without doing some
> pretty nasty and serious rework, for both ext4 and I suspect btrfs.  But
> if returning AOP_WRITEPAGE_ACTIVATE will help the VM deal more
> gracefully with the fact that ext4 and btrfs will be refusing
> writepage() calls under certain conditions, maybe we should make this
> change?

I'm sorry again. I'm pretty sure our vm also need to change if we need
to solve your company's fake numa use case. I think our vm is still delayed 
allocation unfriendly. we haven't noticed ext4 delayed allocation issue ;-)

So, I have two questions
 - I really hope to understand ext4 delayed allocation issue, can you please
   tell me which url explain ext4 high level design and behavior about delayed
   allocation.
 - If my understood is correctly, making very much fake numa node and
   simple dd can reproduce your issue. right?

Now I'm guessing enough small vm patch can solve this issue. (that's only
guess, maybe yes maybe no). but correct understanding and correct testing
way are really necessary. please help.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
