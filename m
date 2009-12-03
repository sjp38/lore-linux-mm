Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 96AF46B003D
	for <linux-mm@kvack.org>; Thu,  3 Dec 2009 10:10:13 -0500 (EST)
Date: Thu, 3 Dec 2009 23:03:23 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 22/24] HWPOISON: add memory cgroup filter
Message-ID: <20091203150323.GA15611@localhost>
References: <20091202031231.735876003@intel.com> <20091202043046.519053333@intel.com> <20091202124446.GA18989@one.firstfloor.org> <20091202125842.GA13277@localhost> <20091203105229.afb0efc4.kamezawa.hiroyu@jp.fujitsu.com> <20091203021915.GA13587@localhost> <20091203112822.ecee5bf5.kamezawa.hiroyu@jp.fujitsu.com> <20091203024739.GB17716@localhost> <20091203115840.45f73bd3.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091203115840.45f73bd3.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, Nick Piggin <npiggin@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, Dec 03, 2009 at 10:58:40AM +0800, KAMEZAWA Hiroyuki wrote:
> On Thu, 3 Dec 2009 10:47:39 +0800
> Wu Fengguang <fengguang.wu@intel.com> wrote:
> 
> > On Thu, Dec 03, 2009 at 10:28:22AM +0800, KAMEZAWA Hiroyuki wrote:
> > Ah please forgive my memcg ignorance..  Then how about bring back the
> > old css_id() based scheme (old patch follows)?
> > 
> maybe enough. but please take care of the fact that css is can be "reused"
> once freed.

OK.

> > > If you have more patches to be usable the function above,
> > > I recommend you to post this with some real-use patches, in step by step.
> > 
> > Do you mean user space test case? Here is a simple one:
> > 
> >         #!/bin/sh
> > 
> >         TEST_PROG=usemem
> >         TEST_PARM="-m 100 -s 100"
> > 
> >         test -d /cgroup/hwpoison && rmdir /cgroup/hwpoison
> >         mkdir /cgroup/hwpoison
> > 
> >         $TEST_PROG $TEST_PARM &
> >         echo `pidof $TEST_PROG` > /cgroup/hwpoison/tasks
> > 
> >         memcg_id=$(</cgroup/hwpoison/memory.id)
> >         echo $memcg_id > /debug/hwpoison/corrupt-filter-memcg
> > 
> >         ./corrupt-all-pfn
> > 
> Ah, this is nice to be put into changelog or some documentation.

Good idea, I'll add it.

> > > patch 19,20 is ok for me.
> > 
> > Thanks,
> > Fengguang
> > ---
> > memcg: show memory.id in cgroupfs
> > 
> > The hwpoison test suite need to selectively inject hwpoison to some
> > targeted task pages, and must not kill important system processes
> > such as init.
> > 
> > The memory cgroup serves this purpose well. We can put the target
> > processes under the control of a memory cgroup, tell the hwpoison
> > injection code the id of that memory cgroup so that it will only
> > poison pages associated with it.
> > 
> > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> 
> No objections from me. please use "id" check. or adds new flag to
> struct mem_cgroup, as you like.

There's a 3rd option: inode number in cgroupfs.

test case:
                memcg_ino=$(ls -id /cgroup/hwpoison | cut -f1 -d' ')
                echo $memcg_ino > /debug/hwpoison/corrupt-filter-memcg

kernel code:
                hwpoison_filter_memcg ==
                memcg->css->cgroup->dentry->d_inode->i_ino

It's pretty long chain, but performance is not a big concern for test
purpose :) As long as the inode number will be accessible and unique
in long term.

This avoids adding extra interfaces to memcg. What do you think?

> The style I prefer is
> ==
>  struct mem_cgroup {
>   ....
>   bool hwpoison_test_enabled;
>  };
> 
> +#ifdef CONFIG_HWPOISON_INJECT /* for now, only user is hwpoison testing */
> +	{
> +		.name = "hwpoison_test_enable",
> +		.read_u64 = ....
> +	},
> +#endif
> 
> and.
> 	mem = try_get_mem_cgroup_from_page(p);
> 	if (mem_cgroup_is_under_poison_test(mem))
> 		ret = true;
> 	mem_cgroup_put(mem);	/* calls css_put() */

It seems mem_cgroup_put() does atomic_dec_and_test(&mem->refcnt).
Is that changed to css_put() recently?

> Maybe not difficult. and this is an usual way. But it's ok if you don't want to
> scannter HWPOISON things to other function's files. This is test operation.
> 
> So, "including real use case and patches" is only my request, for this time.

OK, thanks for the review!

Regards,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
