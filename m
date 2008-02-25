Date: Mon, 25 Feb 2008 17:03:52 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] radix-tree based page_cgroup. [1/7] definitions
 for page_cgroup
Message-Id: <20080225170352.2415dc58.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080225.164745.47821156.taka@valinux.co.jp>
References: <20080225120758.27648297.kamezawa.hiroyu@jp.fujitsu.com>
	<20080225121034.bd74be07.kamezawa.hiroyu@jp.fujitsu.com>
	<20080225.164745.47821156.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>
Cc: balbir@linux.vnet.ibm.com, hugh@veritas.com, yamamoto@valinux.co.jp, ak@suse.de, nickpiggin@yahoo.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Feb 2008 16:47:45 +0900 (JST)
Hirokazu Takahashi <taka@valinux.co.jp> wrote:
> > +struct mem_cgroup;
> > +
> > +struct page_cgroup {
> > +	struct page 		*page;       /* the page this accounts for*/
> > +	struct mem_cgroup 	*mem_cgroup; /* current cgroup subsys */
> > +	int    			flags;	     /* See below */
> > +	int    			refcnt;      /* reference count */
> > +	spinlock_t		lock;        /* lock for all above members */
> > +	struct list_head 	lru;         /* for per cgroup LRU */
> > +};
> 
> You can possible reduce the size of page_cgroup structure not to consume
> a lot of memory. I think this is important.
> 
> I have some ideas:
> (1) I don't think every struct page_cgroup needs to have a "lock" member.
>     I think one "lock" variable for several page_cgroup will be also enough
>     from a performance viewpoint. In addition, it will become low-impact for
>     cache memory. I guess it may be okay if each array of page_cgroup --
>     which you just introduced now -- has one lock variable.

I think it will increase cache-bouncing, but I have no data.
(I notices that lock bit can be moved to flags and use bit_spin_lock.
 But I wouldn't like to do it at this stage.)


> (2) The "flags" member and the "refcnt" member can be encoded into
>     one member.

I don't like this idea.
Because some people discuss about enlarging 32bit countes in struct 'page'
to be 64bit, I wonder refcnt should be "unsigned long", now.

> (3) The page member can be replaced with the page frame number and it will be
>     also possible to use some kind of ID instead of the mem_cgroup member.
>     This means these members can be encoded to one members with other members
>     such as "flags" and "refcnt"
 
I think there is a case that "pfn" doesn't fit in 32bit.
(64bit system tend to have sparse address space.)
We need unsigned long anyway.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
