Date: Tue, 19 Feb 2008 15:40:45 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [RFC][PATCH] Clarify mem_cgroup lock handling and avoid races.
In-Reply-To: <20080219215431.1aa9fa8a.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0802191449490.6254@blonde.site>
References: <20080219215431.1aa9fa8a.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "riel@redhat.com" <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, 19 Feb 2008, KAMEZAWA Hiroyuki wrote:
> I'd like to start from RFC.
> 
> In following code
> ==
>   lock_page_cgroup(page);
>   pc = page_get_page_cgroup(page);
>   unlock_page_cgroup(page);
> 
>   access 'pc' later..
> == (See, page_cgroup_move_lists())
> 
> There is a race because 'pc' is not a stable value without lock_page_cgroup().
> (mem_cgroup_uncharge can free this 'pc').
> 
> For example, page_cgroup_move_lists() access pc without lock.
> There is a small race window, between page_cgroup_move_lists()
> and mem_cgroup_uncharge(). At uncharge, page_cgroup struct is immedieately
> freed but move_list can access it after taking lru_lock.
> (*) mem_cgroup_uncharge_page() can be called without zone->lru lock.
> 
> This is not good manner.
> .....
> There is no quick fix (maybe). Moreover, I hear some people around me said
> current memcontrol.c codes are very complicated.
> I agree ;( ..it's caued by my work.
> 
> I'd like to fix problems in clean way.
> (Note: current -rc2 codes works well under heavy pressure. but there
>  is possibility of race, I think.)

Yes, yes, indeed, I've been working away on this too.

Ever since the VM_BUG_ON(page_get_page_cgroup(page)) went into
free_hot_cold_page (at my own prompting), I've been hitting it
just very occasionally in my kernel build testing.  Was unable
to reproduce it over the New Year, but a week or two ago found
one machine and config on which it is relatively reproducible,
pretty sure to happen within 12 hours.

And on Saturday evening at last identified the cause, exactly
where you have: that unsafety in mem_cgroup_move_lists - which
has the nice property of putting pages from the lru on to SLUB's
freelist!

Unlike the unsafeties of force_empty, this is liable to hit anyone
running with MEM_CONT compiled in, they don't have to be consciously
using mem_cgroups at all.

(I consider that, by the way, quite a serious defect in the current
mem_cgroup work: that a distro compiling it in for 1% of customers
is then subjecting all to the mem_cgroup overhead - effectively
doubled struct page size and unnecessary accounting overhead.  I
believe there needs to be a way to opt out, a force_empty which
sticks.  Yes, I know the page_cgroup which does that doubling of
size is only allocated on demand, but every page cache page and
every anonymous page is going to have one.  A kmem_cache for them
will reduce the extra, but there still needs to be a way to opt
out completely.)

Since then I've been working on patches too, testing, currently
breaking up my one big patch into pieces while running more tests.
A lot in common with yours, a lot not.  (And none of it addressing
that issue of opt-out I raise in the last paragraph: haven't begun
to go into that one, hoped you and Balbir would look into it.)

I've not had time to study yours yet, but a first impression is
that you're adding extra complexity (usage in addition to ref_cnt)
where I'm more taking it away (it's pointless for ref_cnt to be an
atomic: the one place which isn't already using lock_page_cgroup
around it needs to).  But that could easily turn out to be because
I'm skirting issues which you're addressing properly: we'll see.

I haven't completed my solution in mem_cgroup_move_lists yet: but
the way it wants a lock in a structure which isn't stabilized until
it's got that lock, reminds me very much of my page_lock_anon_vma,
so I'm expecting to use a SLAB_DESTROY_BY_RCU cache there.

Ha, you have lock_page_cgroup in your mem_cgroup_move_lists: yes,
tried that too, and it deadlocks: someone holding lock_page_cgroup
can be interrupted by an end of I/O interrupt which does
rotate_reclaimable_page and wants the main lru_lock, but that
main lru_lock is held across mem_cgroup_move_lists.  There are
several different ways to address that, but for this release I
think we just go for a try_lock_page_cgroup there.

(And that answers my old question, of why you use spin_lock_irq
on your mz->lru_lock: because if you didn't, the same deadlock
could hit one of the other places which lock mz->lru_lock.)

How should I proceed now?  I think it's best if I press ahead with
my patchset, to get that out on to the list; and only then come
back to look at yours, while you can be looking at mine.  Then
we take the best out of both and push that forward - this does
need to be fixed for 2.6.25.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
