Return-Path: <owner-linux-mm@kvack.org>
Date: Tue, 14 May 2013 09:58:50 -0400
From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [PATCH V2 1/2] mm: hotplug: implement non-movable version of get_user_pages() called get_user_pages_non_movable()
Message-ID: <20130514135850.GG13845@kvack.org>
References: <1360056113-14294-2-git-send-email-linfeng@cn.fujitsu.com> <20130205120137.GG21389@suse.de> <20130206004234.GD11197@blaptop> <20130206095617.GN21389@suse.de> <5190AE4F.4000103@cn.fujitsu.com> <20130513091902.GP11497@suse.de> <20130513143757.GP31899@kvack.org> <x49obcfnd6c.fsf@segfault.boston.devel.redhat.com> <20130513150147.GQ31899@kvack.org> <5191926A.2090608@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5191926A.2090608@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: Jeff Moyer <jmoyer@redhat.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Lin Feng <linfeng@cn.fujitsu.com>, akpm@linux-foundation.org, viro@zeniv.linux.org.uk, khlebnikov@openvz.org, walken@google.com, kamezawa.hiroyu@jp.fujitsu.com, riel@redhat.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, jiang.liu@huawei.com, zab@redhat.com, linux-mm@kvack.org, linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Marek Szyprowski <m.szyprowski@samsung.com>

On Tue, May 14, 2013 at 09:24:58AM +0800, Tang Chen wrote:
> Hi Mel, Benjamin, Jeff,
> 
> On 05/13/2013 11:01 PM, Benjamin LaHaise wrote:
> >On Mon, May 13, 2013 at 10:54:03AM -0400, Jeff Moyer wrote:
> >>How do you propose to move the ring pages?
> >
> >It's the same problem as doing a TLB shootdown: flush the old pages from
> >userspace's mapping, copy any existing data to the new pages, then
> >repopulate the page tables.  It will likely require the addition of
> >address_space_operations for the mapping, but that's not too hard to do.
> >
> 
> I think we add migrate_unpin() callback to decrease page->count if 
> necessary,
> and migrate the page to a new page, and add migrate_pin() callback to pin
> the new page again.

You can't just decrease the page count for this to work.  The pages are 
pinned because aio_complete() can occur at any time and needs to have a 
place to write the completion events.  When changing pages, aio has to 
take the appropriate lock when changing one page for another.

> The migrate procedure will work just as before. We use callbacks to 
> decrease
> the page->count before migration starts, and increase it when the migration
> is done.
> 
> And migrate_pin() and migrate_unpin() callbacks will be added to
> struct address_space_operations.

I think the existing migratepage operation in address_space_operations can 
be used.  Does it get called when hot unplug occurs?  That is: is testing 
with the migrate_pages syscall similar enough to the memory removal case?

		-ben

> Is that right ?
> 
> If so, I'll be working on it.
> 
> Thanks. :)

-- 
"Thought is the essence of where you are now."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
