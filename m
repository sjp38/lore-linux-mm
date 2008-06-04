Date: Wed, 4 Jun 2008 18:18:08 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 1/2] memcg: res_counter hierarchy
Message-Id: <20080604181808.70c86e05.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <6599ad830806040159i4dfd8350w54e41c5ba4e0c8c4@mail.gmail.com>
References: <20080604135815.498eaf82.kamezawa.hiroyu@jp.fujitsu.com>
	<20080604140153.fec6cc99.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830806040159i4dfd8350w54e41c5ba4e0c8c4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

On Wed, 4 Jun 2008 01:59:31 -0700
"Paul Menage" <menage@google.com> wrote:

> On Tue, Jun 3, 2008 at 10:01 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >        int ret;
> >        char *buf, *end;
> > @@ -133,13 +145,101 @@ ssize_t res_counter_write(struct res_cou
> >                if (*end != '\0')
> >                        goto out_free;
> >        }
> > -       spin_lock_irqsave(&counter->lock, flags);
> > -       val = res_counter_member(counter, member);
> > -       *val = tmp;
> > -       spin_unlock_irqrestore(&counter->lock, flags);
> > -       ret = nbytes;
> > +       if (set_strategy) {
> > +               ret = set_strategy(res, tmp, member);
> > +               if (!ret)
> > +                       ret = nbytes;
> > +       } else {
> > +               spin_lock_irqsave(&counter->lock, flags);
> > +               val = res_counter_member(counter, member);
> > +               *val = tmp;
> > +               spin_unlock_irqrestore(&counter->lock, flags);
> > +               ret = nbytes;
> > +       }
> 
> I think that the hierarchy/reclaim handling that you currently have in
> the memory controller should be here; the memory controller should
> just be able to pass a reference to try_to_free_mem_cgroup_pages() and
> have everything else handled by res_counter.
> 
Sounds reasonable. I'll re-design the whole AMAP. I think I can do more.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
