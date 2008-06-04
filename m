Date: Wed, 4 Jun 2008 21:53:34 +0900
From: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>
Subject: Re: [RFC][PATCH 2/2] memcg: hardwall hierarhcy for memcg
Message-Id: <20080604215334.9f3a249b.d-nishimura@mtf.biglobe.ne.jp>
In-Reply-To: <20080604182626.fcc26e24.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080604135815.498eaf82.kamezawa.hiroyu@jp.fujitsu.com>
	<20080604140329.8db1b67e.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830806040159w1026003fhe3212beac895927a@mail.gmail.com>
	<20080604182626.fcc26e24.kamezawa.hiroyu@jp.fujitsu.com>
Reply-To: nishimura@mxp.nes.nec.co.jp
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Paul Menage <menage@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

> > > @@ -1096,6 +1238,12 @@ static void mem_cgroup_destroy(struct cg
> > >        int node;
> > >        struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
> > >
> > > +       if (cont->parent &&
> > > +           mem->hierarchy_model == MEMCG_HARDWALL_HIERARCHY) {
> > > +               /* we did what we can...just returns what we borrow */
> > > +               res_counter_return_resource(&mem->res, -1, NULL, 0);
> > > +       }
> > > +
> > 
> > Should we also re-account any remaining child usage to the parent?
> > 
> When this is called, there are no process in this group. Then, remaining
> resources in this level is
>   - file cache
>   - swap cache (if shared)
>   - shmem
> 
> And the biggest usage will be "file cache".
> So, I don't think it's necessary to move child's usage to the parent,
> in hurry. But maybe shmem is worth to be moved.
> 
> I'd like to revisit this when I implements "usage move at task move"
> logic. (currenty, memory usage doesn't move to new cgroup at task_attach.)
> 
> It will help me to implement the logic "move remaining usage to the parent"
> in clean way.
> 

I agree that "usage move at task move" is needed before
"move remaining usage to the parent".


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
