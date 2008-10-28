Date: Tue, 28 Oct 2008 13:45:36 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC][PATCH] lru_add_drain_all() don't use
 schedule_on_each_cpu()
Message-Id: <20081028134536.9a7a5351.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0810280914010.15939@quilx.com>
References: <2f11576a0810210851g6e0d86benef5d801871886dd7@mail.gmail.com>
	<2f11576a0810211018g5166c1byc182f1194cfdd45d@mail.gmail.com>
	<20081023235425.9C40.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20081027145509.ebffcf0e.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0810280914010.15939@quilx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, heiko.carstens@de.ibm.com, npiggin@suse.de, linux-kernel@vger.kernel.org, hugh@veritas.com, torvalds@linux-foundation.org, riel@redhat.com, lee.schermerhorn@hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 28 Oct 2008 09:25:31 -0500 (CDT)
Christoph Lameter <cl@linux-foundation.org> wrote:

> On Mon, 27 Oct 2008, Andrew Morton wrote:
> 
> > Can we fix that instead?
> 
> How about this fix?
> 
> 
> 
> Subject: Move migrate_prep out from under mmap_sem
> 
> Move the migrate_prep outside the mmap_sem for the following system calls
> 
> 1. sys_move_pages
> 2. sys_migrate_pages
> 3. sys_mbind()
> 
> It really does not matter when we flush the lru. The system is free to add
> pages onto the lru even during migration which will make the page 
> migration either skip the page (mbind, migrate_pages) or return a busy 
> state (move_pages).
> 

That looks nicer, thanks.  Hopefully it fixes the
lockdep-warning/deadlock...

I guess we should document our newly discovered schedule_on_each_cpu()
problems before we forget about it and later rediscover it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
