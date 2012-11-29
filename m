Return-Path: <owner-linux-mm@kvack.org>
Date: Thu, 29 Nov 2012 15:39:30 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [BUG REPORT] [mm-hotplug, aio] aio ring_pages can't be offlined
Message-Id: <20121129153930.477e9709.akpm@linux-foundation.org>
In-Reply-To: <1354172098-5691-1-git-send-email-linfeng@cn.fujitsu.com>
References: <1354172098-5691-1-git-send-email-linfeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lin Feng <linfeng@cn.fujitsu.com>
Cc: viro@zeniv.linux.org.uk, bcrl@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suse.cz, hughd@google.com, cl@linux.com, mgorman@suse.de, minchan@kernel.org, isimatu.yasuaki@jp.fujitsu.com, laijs@cn.fujitsu.com, wency@cn.fujitsu.com, tangchen@cn.fujitsu.com, linux-fsdevel@vger.kernel.org, linux-aio@kvack.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 29 Nov 2012 14:54:58 +0800
Lin Feng <linfeng@cn.fujitsu.com> wrote:

> Hi all,
> 
> We encounter a "Resource temporarily unavailable" fail while trying
> to offline a memory section in a movable zone. We found that there are 
> some pages can't be migrated. The offline operation fails in function 
> migrate_page_move_mapping() returning -EAGAIN till timeout because 
> the if assertion 'page_count(page) != 1' fails.
> I wonder in the case 'page_count(page) != 1', should we always wait
> (return -EAGAING)? Or in other words, can we do something here for 
> migration if we know where the pages from?
> 
> And finally found that such pages are used by /sbin/multipathd in the form
> of aio ring_pages. Besides once increment introduced by the offline calling
> chain, another increment is added by aio_setup_ring() via callling
> get_userpages(), it won't decrease until we call aio_free_ring().
> 
> The dump_page info in the offline context is showed as following:
> page:ffffea0011e69140 count:2 mapcount:0 mapping:ffff8801d6949881 index:0x7fc4b6d1d
> page flags: 0x30000000018081d(locked|referenced|uptodate|dirty|swapbacked|unevictable)
> page:ffffea0011fb0480 count:2 mapcount:0 mapping:ffff8801d6949881 index:0x7fc4b6d1c
> page flags: 0x30000000018081d(locked|referenced|uptodate|dirty|swapbacked|unevictable)
> page:ffffea0011fbaa80 count:2 mapcount:0 mapping:ffff8801d6949881 index:0x7fc4b6d1a
> page flags: 0x30000000018081d(locked|referenced|uptodate|dirty|swapbacked|unevictable)
> page:ffffea0011ff21c0 count:2 mapcount:0 mapping:ffff8801d6949881 index:0x7fc4b6d1b
> page flags: 0x30000000018081d(locked|referenced|uptodate|dirty|swapbacked|unevictable)
> 
> The multipathd seems never going to release the ring_pages until we reboot the box.
> Furthermore, if some guy makes app which only calls io_setup() but never calls 
> io_destroy() for the reason that he has to keep the io_setup() for a long time 
> or just forgets to or even on purpose that we can't expect.
> So I think the mm-hotplug framwork should get the capability to deal with such
> situation. And should we consider adding migration support for such pages?
> 
> However I don't know if there are any other kinds of such particular pages in 
> current kernel/Linux system. If unluckily there are many apparently it's hard to 
> handle them all, just adding migrate support for aio ring_pages is insufficient. 
> 
> But if luckily can we use the private field of page struct to track the
> ring_pages[] pointer so that we can retrieve the user when migrate? 
> Doing so another problem occurs, how to distinguish such special pages?
> Use pageflag may cause an impact on current pageflag layout, add new pageflag
> item also seems to be impossible.
> 
> I'm not sure what way is the right approach, seeking for help.
> Any comments are extremely needed, thanks :)

Tricky.

I expect the same problem would occur with pages which are under
O_DIRECT I/O.  Obviously O_DIRECT pages won't be pinned for such long
periods, but the durations could still be lengthy (seconds).

Worse is a futex page, which could easily remain pinned indefinitely.

The best I can think of is to make changes in or around
get_user_pages(), to steal the pages from userspace and replace them
with non-movable ones before pinning them.  The performance cost of
something like this would surely be unacceptable for direct-io, but
maybe OK for the aio ring and futexes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
