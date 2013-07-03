Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 391356B0034
	for <linux-mm@kvack.org>; Wed,  3 Jul 2013 12:00:01 -0400 (EDT)
Date: Wed, 3 Jul 2013 17:59:58 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH next-20130703] net: sock: Add ifdef CONFIG_MEMCG_KMEM for
 mem_cgroup_sockets_{init,destroy}
Message-ID: <20130703155958.GC5153@dhcp22.suse.cz>
References: <1372853998-15353-1-git-send-email-sedat.dilek@gmail.com>
 <51D41E34.5010802@huawei.com>
 <20130703152058.GA30267@dhcp22.suse.cz>
 <CA+icZUX+mB2v9ghdhaLvpncCu+yxP4xJzzbFxXisFsB2tDM7TA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+icZUX+mB2v9ghdhaLvpncCu+yxP4xJzzbFxXisFsB2tDM7TA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sedat Dilek <sedat.dilek@gmail.com>
Cc: Li Zefan <lizefan@huawei.com>, akpm@linux-foundation.org, davem@davemloft.net, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, linux-mm@kvack.org

On Wed 03-07-13 17:53:21, Sedat Dilek wrote:
> On Wed, Jul 3, 2013 at 5:20 PM, Michal Hocko <mhocko@suse.cz> wrote:
> > On Wed 03-07-13 20:51:00, Li Zefan wrote:
> > [...]
> >> [PATCH] memcg: fix build error if CONFIG_MEMCG_KMEM=n
> >>
> >> Fix this build error:
> >>
> >> mm/built-in.o: In function `mem_cgroup_css_free':
> >> memcontrol.c:(.text+0x5caa6): undefined reference to
> >> 'mem_cgroup_sockets_destroy'
> >>
> >> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> >> Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
> >> Signed-off-by: Li Zefan <lizefan@huawei.com>
> >
> > I am seeing the same thing I just didn't get to reporting it.
> > The other approach is not bad as well but I find this tiny better
> > because mem_cgroup_css_free should care only about a single cleanup
> > function for whole kmem. If that one needs to do tcp kmem specific
> > cleanup then it should be done inside kmem_cgroup_css_offline.
> >
> 
> As said in my other mail, for me this makes sense as it is a followup.
> 
> But, still I don't know why sock.c has is own mem_cgroup_sockets_{init,destroy}.

That is the only definition AFAICS (except for !CONFIG_NET where it
expands to NOOP). Please note that memcg_init_kmem is a common kmem
initializator and it needs to be prepared for !CONFIG_NET.

The same applies to _destroy.
Makes more sense now?

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
