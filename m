Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id D22316B02D2
	for <linux-mm@kvack.org>; Wed, 14 Dec 2011 05:53:30 -0500 (EST)
Date: Wed, 14 Dec 2011 11:53:28 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 2/2] memcg: fix livelock in try charge during readahead
Message-ID: <20111214105328.GC11786@tiehlicka.suse.cz>
References: <1323742608-9246-1-git-send-email-yinghan@google.com>
 <20111213061035.GA8513@barrios-laptop.redhat.com>
 <CALWz4iw1i_EtJD9y+JZb+5YnAOuZ93Bg=fO+-KGD6xR6a7znNw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CALWz4iw1i_EtJD9y+JZb+5YnAOuZ93Bg=fO+-KGD6xR6a7znNw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Minchan Kim <minchan@kernel.org>, Balbir Singh <bsingharora@gmail.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelyanov <xemul@openvz.org>, Fengguang Wu <fengguang.wu@intel.com>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org

On Tue 13-12-11 10:29:34, Ying Han wrote:
> On Mon, Dec 12, 2011 at 10:10 PM, Minchan Kim <minchan@kernel.org> wrote:
> > On Mon, Dec 12, 2011 at 06:16:48PM -0800, Ying Han wrote:
> >> Couple of kernel dumps are triggered by watchdog timeout. It turns out that two
> >> processes within a memcg livelock on a same page lock. We believe this is not
> >> memcg specific issue and the same livelock exists in non-memcg world as well.
> >>
> >> The sequence of triggering the livelock:
> >> 1. Task_A enters pagefault (filemap_fault) and then starts readahead
> >> filemap_fault
> >>  -> do_sync_mmap_readahead
> >>     -> ra_submit
> >>        ->__do_page_cache_readahead // here we allocate the readahead pages
> >>          ->read_pages
> >>          ...
> >>            ->add_to_page_cache_locked
> >>              //for each page, we do the try charge and then add the page into
> >>              //radix tree. If one of the try charge failed, it enters per-memcg
> >>              //oom while holding the page lock of previous readahead pages.
> >>
> >>             // in the memcg oom killer, it picks a task within the same memcg
> >>             // and mark it TIF_MEMDIE. then it goes back into retry loop and
> >>             // hopes the task exits to free some memory.
> >>
> >> 2. Task_B enters pagefault (filemap_fault) and finds the page in radix tree (
> >> one of the readahead pages from ProcessA)
> >>
> >> filemap_fault
> >>  ->__lock_page // here it is marked as TIF_MEMDIE. but it can not proceed since
> >>                // the page lock is hold by ProcessA looping at OOM.
> >>
> >> Since the TIF_MEMDIE task_B is live locked, it ends up blocking other tasks
> >> making forward progress since they are also checking the flag in
> >> select_bad_process. The same issue exists in the non-memcg world. Instead of
> >> entering oom through mem_cgroup_cache_charge(), we might enter it through
> >> radix_tree_preload().
> >>
> >> The proposed fix here is to pass __GFP_NORETRY gfp_mask into try charge under
> >> readahead. Then we skip entering memcg OOM kill which eliminates the case where
> >> it OOMs on one page and holds other page locks. It seems to be safe to do that
> >> since both filemap_fault() and do_generic_file_read() handles the fallback case
> >> of "no_cached_page".
> >>
> >> Note:
> >> After this patch, we might experience some charge fails for readahead pages
> >> (since we don't enter oom). But this sounds sane compared to letting the system
> >> trying extremely hard to charge a readahead page by doing reclaim and then oom,
> >> the later one also triggers livelock as listed above.
> >>
> >> Signed-off-by: Greg Thelen <gthelen@google.com>
> >> Signed-off-by: Ying Han <yinghan@google.com>
> >
> > Nice catch.
> >
> > The concern is GFP_KERNEL != avoid OOM.
> > Although it works now, it can be changed.
> >
> > With alternative idea, We can use explicit oom_killer_disable with __GFP_NOWARN
> > but it wouldn't work since oom_killer_disabled isn't reference count variable.
> > Of course, we can change it with reference-counted atomic variable.
> > The benefit is it's more explicit and doesn't depends on __GFP_NORETRY implementation.
> > So I don't have a good idea except above.
> 
> > If you want __GFP_NORTRY patch, thing we can do best is add comment in detail, at least.
> > both side, here add_to_page_cache_lru and there __GFP_NORETRY in include/linux/gfp.h.
> 
> Correct me in case i missed something, looks like I want to backport
> the " x86,mm: make pagefault killable" patch, and we might be able to
> solve the livelock w/o changing the readahead code.

Yes, that seems correct to me. 

Thanks
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
