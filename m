Date: Wed, 20 Feb 2008 04:32:13 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [RFC][PATCH] Clarify mem_cgroup lock handling and avoid races.
In-Reply-To: <20080220121455.d4e4daf6.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0802200428090.3569@blonde.site>
References: <20080219215431.1aa9fa8a.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0802191449490.6254@blonde.site>
 <20080220121455.d4e4daf6.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "riel@redhat.com" <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, 20 Feb 2008, KAMEZAWA Hiroyuki wrote:
> On Tue, 19 Feb 2008 15:40:45 +0000 (GMT)
> Hugh Dickins <hugh@veritas.com> wrote:
> 
> > I haven't completed my solution in mem_cgroup_move_lists yet: but
> > the way it wants a lock in a structure which isn't stabilized until
> > it's got that lock, reminds me very much of my page_lock_anon_vma,
> > so I'm expecting to use a SLAB_DESTROY_BY_RCU cache there.
> > 
> Could I make a question about anon_vma's RCU ?
> 
> I think SLAB_DESTROY_BY_RCU guarantees that slab's page is not freed back
> to buddy allocator while some holds rcu_read_lock().
> 
> Why it's safe against reusing freed one by slab fast path (array_cache) ?

Because so long as that piece of memory is used for the same type of
structure, what's a spinlock remains a spinlock, so (if you've got
rcu_read_lock) it's safe to take the spinlock in the structure even
if it's no longer "yours": then, once you've got the spinlock,
check to see if it's still yours and get out immediately if not.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
