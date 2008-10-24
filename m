Date: Fri, 24 Oct 2008 06:55:47 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC][PATCH] lru_add_drain_all() don't use schedule_on_each_cpu()
Message-ID: <20081024045547.GA24555@wotan.suse.de>
References: <20081023235425.9C40.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20081024012831.GE5004@wotan.suse.de> <20081024135149.9C46.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081024135149.9C46.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, Oct 24, 2008 at 01:54:46PM +0900, KOSAKI Motohiro wrote:
> > > 
> > > Actually, schedule_on_each_cpu() is very problematic function.
> > > it introduce the dependency of all worker on keventd_wq, 
> > > but we can't know what lock held by worker in kevend_wq because
> > > keventd_wq is widely used out of kernel drivers too.
> > > 
> > > So, the task of any lock held shouldn't wait on keventd_wq.
> > > Its task should use own special purpose work queue.
> > 
> > I don't see a better way to solve it, other than avoiding lru_add_drain_all
> 
> Well,
> 
> Unfortunately, lru_add_drain_all is also used some other VM place
> (page migration and memory hotplug).
> and page migration's usage is the same of this mlock usage.
> (1. grab mmap_sem  2.  call lru_add_drain_all)
> 
> Then, change mlock usage isn't solution ;-)

No, not mlock alone.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
