Date: Wed, 20 Feb 2008 10:03:33 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] Clarify mem_cgroup lock handling and avoid races.
Message-Id: <20080220100333.a014083c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0802191449490.6254@blonde.site>
References: <20080219215431.1aa9fa8a.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0802191449490.6254@blonde.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "riel@redhat.com" <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

Good morning ;)

On Tue, 19 Feb 2008 15:40:45 +0000 (GMT)
Hugh Dickins <hugh@veritas.com> wrote:

> Since then I've been working on patches too, testing, currently
> breaking up my one big patch into pieces while running more tests.
> A lot in common with yours, a lot not.  (And none of it addressing
> that issue of opt-out I raise in the last paragraph: haven't begun
> to go into that one, hoped you and Balbir would look into it.)
> 
I have some trial patches for reducing atomic_ops by do_it_lazy method.
Now, I'm afraid that performence is too bad when there is *no* memory pressure.

> I've not had time to study yours yet, but a first impression is
> that you're adding extra complexity (usage in addition to ref_cnt)
> where I'm more taking it away (it's pointless for ref_cnt to be an
> atomic: the one place which isn't already using lock_page_cgroup
> around it needs to).  But that could easily turn out to be because
> I'm skirting issues which you're addressing properly: we'll see.
> 
> I haven't completed my solution in mem_cgroup_move_lists yet: but
> the way it wants a lock in a structure which isn't stabilized until
> it's got that lock, reminds me very much of my page_lock_anon_vma,
> so I'm expecting to use a SLAB_DESTROY_BY_RCU cache there.
> 

IMHO, because tons of page_cgroup can be freed at once, we need some good
idea for reducing RCU's GC work to do that.

> Ha, you have lock_page_cgroup in your mem_cgroup_move_lists: yes,
> tried that too, and it deadlocks: someone holding lock_page_cgroup
> can be interrupted by an end of I/O interrupt which does
> rotate_reclaimable_page and wants the main lru_lock, but that
> main lru_lock is held across mem_cgroup_move_lists.  There are
> several different ways to address that, but for this release I
> think we just go for a try_lock_page_cgroup there.
> 
Hm, I'd like to remove mem_cgroup_move_lists if possible ;(
(But its result will be bad LRU ordering.)

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
