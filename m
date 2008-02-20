Date: Wed, 20 Feb 2008 04:27:33 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [RFC][PATCH] Clarify mem_cgroup lock handling and avoid races.
In-Reply-To: <20080220023226.6FB051E3C11@siro.lan>
Message-ID: <Pine.LNX.4.64.0802200416100.3569@blonde.site>
References: <20080220111506.27cb60f6.kamezawa.hiroyu@jp.fujitsu.com>
 <20080220023226.6FB051E3C11@siro.lan>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: kamezawa.hiroyu@jp.fujitsu.com, balbir@linux.vnet.ibm.com, linux-mm@kvack.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Wed, 20 Feb 2008, YAMAMOTO Takashi wrote:
> > On Wed, 20 Feb 2008 11:05:12 +0900 (JST)
> > yamamoto@valinux.co.jp (YAMAMOTO Takashi) wrote:
> > 
> > 	error = 0;
> > > > >  		lock_page_cgroup(page);
> > > > 
> > > > What is !page case in mem_cgroup_charge_xxx() ?
> > > 
> > > see a hack in shmem_getpage.

My hack, yes.  I did wonder even when submitting it, and was slightly
surprised no voices raised against it.  I've left it in because it
poses no real problem at all, apart from complicating the flow in
charge_common.

But I'll happily remove it if you like: shmem_getpage has proved to
get along fine using charge and uncharge on swappage there instead -
since it only happens once per freeing-batch of pages,
the unnecessary overhead remains in the noise.

> > Aha, ok. maybe we should add try_to_shrink_page_cgroup() for making room
> > rather than adding special case.
> 
> yes.
> or, even better, implement cgroup background reclaim.

Well, either of those might be wanted in some future, but not by me:
for now it sounds like I'll please you both if I remove the !page
special case from charge_common.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
