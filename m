Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id F021F600786
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 04:46:10 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nB19k8Bl001952
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 1 Dec 2009 18:46:08 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5475A45DE5D
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 18:46:08 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2794245DE57
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 18:46:08 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E816B1DB8044
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 18:46:07 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6FE231DB803E
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 18:46:07 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/9] ksm: let shared pages be swappable
In-Reply-To: <20091201093738.GL30235@random.random>
References: <20091201181633.5C31.A69D9226@jp.fujitsu.com> <20091201093738.GL30235@random.random>
Message-Id: <20091201184535.5C37.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  1 Dec 2009 18:46:06 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, Chris Wright <chrisw@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Tue, Dec 01, 2009 at 06:28:16PM +0900, KOSAKI Motohiro wrote:
> > This patch doesn't works correctly. shrink_active_list() use page_referenced() for
> > clear young bit and doesn't use return value.
> 
> The whole point is that it's inefficient to clear all young bits just
> to move it to inactive list in the hope that new young bits will be
> set right before the page reaches the end of the inactive list.
> 
> > after this patch apply, shrink_active_list() move the page to inactive list although
> > the page still have many young bit. then, next shrink_inactive_list() move the page
> > to active list again.
> 
> yes it's not the end of the world, this only alter behavior for pages
> that have plenty of mappings. However I still it's inefficient to
> pretend to clear all young bits at once when page is deactivated. But
> this is not something I'm interested to argue about... let do what you
> like there, but as long as you pretend to clear all dirty bits there
> is no way we can fix anything. Plus we should touch ptes only in
> presence of heavy memory pressure, with light memory pressure ptes
> should _never_ be touched, and we should only shrink unmapped
> cache. And active/inactive movements must still happen even in
> presence of light memory pressure. The reason is that with light
> memory pressure we're not I/O bound and we don't want to waste time
> there. My patch is ok, what is not ok is the rest, you got to change
> the rest to deal with this.

Ah, well. please wait a bit. I'm under reviewing Larry's patch. I don't
dislike your idea. last mail only pointed out implementation thing.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
