Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9O4sm0N007231
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 24 Oct 2008 13:54:48 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 18AAA1B8020
	for <linux-mm@kvack.org>; Fri, 24 Oct 2008 13:54:48 +0900 (JST)
Received: from s8.gw.fujitsu.co.jp (s8.gw.fujitsu.co.jp [10.0.50.98])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E24B32DC01E
	for <linux-mm@kvack.org>; Fri, 24 Oct 2008 13:54:47 +0900 (JST)
Received: from s8.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s8.gw.fujitsu.co.jp (Postfix) with ESMTP id A64691DB803A
	for <linux-mm@kvack.org>; Fri, 24 Oct 2008 13:54:47 +0900 (JST)
Received: from ml12.s.css.fujitsu.com (ml12.s.css.fujitsu.com [10.249.87.102])
	by s8.gw.fujitsu.co.jp (Postfix) with ESMTP id 64D1B1DB803E
	for <linux-mm@kvack.org>; Fri, 24 Oct 2008 13:54:47 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] lru_add_drain_all() don't use schedule_on_each_cpu()
In-Reply-To: <20081024012831.GE5004@wotan.suse.de>
References: <20081023235425.9C40.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20081024012831.GE5004@wotan.suse.de>
Message-Id: <20081024135149.9C46.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 24 Oct 2008 13:54:46 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: kosaki.motohiro@jp.fujitsu.com, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> > 
> > Actually, schedule_on_each_cpu() is very problematic function.
> > it introduce the dependency of all worker on keventd_wq, 
> > but we can't know what lock held by worker in kevend_wq because
> > keventd_wq is widely used out of kernel drivers too.
> > 
> > So, the task of any lock held shouldn't wait on keventd_wq.
> > Its task should use own special purpose work queue.
> 
> I don't see a better way to solve it, other than avoiding lru_add_drain_all

Well,

Unfortunately, lru_add_drain_all is also used some other VM place
(page migration and memory hotplug).
and page migration's usage is the same of this mlock usage.
(1. grab mmap_sem  2.  call lru_add_drain_all)

Then, change mlock usage isn't solution ;-)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
