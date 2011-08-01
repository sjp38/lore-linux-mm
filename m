Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5578F900137
	for <linux-mm@kvack.org>; Sun, 31 Jul 2011 20:29:33 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 38FF43EE0C1
	for <linux-mm@kvack.org>; Mon,  1 Aug 2011 09:29:29 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1F5DE45DE7F
	for <linux-mm@kvack.org>; Mon,  1 Aug 2011 09:29:29 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0208845DE6A
	for <linux-mm@kvack.org>; Mon,  1 Aug 2011 09:29:29 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A90601DB8040
	for <linux-mm@kvack.org>; Mon,  1 Aug 2011 09:29:28 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 720081DB8038
	for <linux-mm@kvack.org>; Mon,  1 Aug 2011 09:29:28 +0900 (JST)
Date: Mon, 1 Aug 2011 09:22:05 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [GIT PULL] Lockless SLUB slowpaths for v3.1-rc1
Message-Id: <20110801092205.14881df1.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <m2livez6vl.fsf@firstfloor.org>
References: <alpine.DEB.2.00.1107290145080.3279@tiger>
	<CA+55aFzut1tF6CLAPJUUh2H_7M4wcDpp2+Zb85Lqvofe+3v_jQ@mail.gmail.com>
	<CA+55aFw9V-VM5TBwqdKiP0E_g8urth+08nX-_inZ8N1_gFQF4w@mail.gmail.com>
	<m2livez6vl.fsf@firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, cl@linux-foundation.org, akpm@linux-foundation.org, rientjes@google.com, hughd@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kosaki.motohiro@jp.fujitsu.com, yinghan@google.com

On Sun, 31 Jul 2011 10:39:58 -0700
Andi Kleen <andi@firstfloor.org> wrote:

> Linus Torvalds <torvalds@linux-foundation.org> writes:
> 
> > On Sat, Jul 30, 2011 at 8:27 AM, Linus Torvalds
> > <torvalds@linux-foundation.org> wrote:
> >>
> >> Do we allocate the page map array sufficiently aligned that we
> >> actually don't ever have the case of straddling a cacheline? I didn't
> >> check.
> >
> > Oh, and another thing worth checking: did somebody actually check the
> > timings for:
> 
> I would like to see a followon patch that moves the mem_cgroup
> pointer back into struct page. Copying some mem_cgroup people.
> 

A very big change itself is in a future plan. It will do memory usage of
page_cgroup from 32bytes to 8bytes.

A small change, moving page_cgroup->mem_cgroup to struct page, may make
sense. But...IIUC, there is an another user of a field as blkio cgroup.
(They planned to add page_cgroup->blkio_cgroup)

So, my idea is adding

	page->owner

field and encode it in some way. For example, if we can encode it as

	|owner_flags | blkio_id | | memcg_id|

this will work. (I'm not sure how performance will be..)
And we can reduce size of page_cgroup from 32->24(or 16).

In this usage, page->owner will be just required when CGROUP is used.
So, a small machine will not need to increase size of struct page.

If you increase size of 'struct page', memcg will try to make use of
the field.

But we have now some pending big patches (dirty_ratio etc...), moving
pointer may take longer than expected. 

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
