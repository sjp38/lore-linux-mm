Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1440C6B0292
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 09:50:34 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id m84so3605668qki.5
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 06:50:34 -0700 (PDT)
Received: from mail-qt0-x241.google.com (mail-qt0-x241.google.com. [2607:f8b0:400d:c0d::241])
        by mx.google.com with ESMTPS id u43si5708927qte.372.2017.08.10.06.50.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Aug 2017 06:50:32 -0700 (PDT)
Received: by mail-qt0-x241.google.com with SMTP id c15so745035qta.3
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 06:50:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170809183825.GA26387@cmpxchg.org>
References: <20170805155241.GA94821@jaegeuk-macbookpro.roam.corp.google.com>
 <20170808010150.4155-1-bradleybolen@gmail.com> <20170808162122.GA14689@cmpxchg.org>
 <20170808165601.GA7693@jaegeuk-macbookpro.roam.corp.google.com>
 <20170808173704.GA22887@cmpxchg.org> <CADvgSZSn1v-tTpa07ebqr19heQbkzbavdPM_nbRNR1WF-EBnFw@mail.gmail.com>
 <20170808200849.GA1104@cmpxchg.org> <20170809014459.GB7693@jaegeuk-macbookpro.roam.corp.google.com>
 <CADvgSZSNn7N3R7+jjeCgns2ZEPtYc6c3MWmkkQ3PA+0LHO_MfA@mail.gmail.com> <20170809183825.GA26387@cmpxchg.org>
From: Brad Bolen <bradleybolen@gmail.com>
Date: Thu, 10 Aug 2017 09:50:31 -0400
Message-ID: <CADvgSZT0sV5UQayO_cLkhFFFBPrvjhdGn1v=cvtZ51V7oOO8qw@mail.gmail.com>
Subject: Re: kernel panic on null pointer on page->mem_cgroup
Content-Type: multipart/alternative; boundary="001a11404c3ae14c940556667ab2"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Jaegeuk Kim <jaegeuk@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

--001a11404c3ae14c940556667ab2
Content-Type: text/plain; charset="UTF-8"

I'm sorry.  I've been away.  I should be able to try it this afternoon.

On Wednesday, August 9, 2017, Johannes Weiner <hannes@cmpxchg.org> wrote:

> On Tue, Aug 08, 2017 at 10:39:27PM -0400, Brad Bolen wrote:
> > Yes, the BUG_ON(!page_count(page)) fired for me as well.
>
> Brad, Jaegeuk, does the following patch address this problem?
>
> ---
>
> From cf0060892eb70bccbc8cedeac0a5756c8f7b975e Mon Sep 17 00:00:00 2001
> From: Johannes Weiner <hannes@cmpxchg.org <javascript:;>>
> Date: Wed, 9 Aug 2017 12:06:03 -0400
> Subject: [PATCH] mm: memcontrol: fix NULL pointer crash in
>  test_clear_page_writeback()
>
> Jaegeuk and Brad report a NULL pointer crash when writeback ending
> tries to update the memcg stats:
>
> [] BUG: unable to handle kernel NULL pointer dereference at
> 00000000000003b0
> [] IP: test_clear_page_writeback+0x12e/0x2c0
> [...]
> [] RIP: 0010:test_clear_page_writeback+0x12e/0x2c0
> [] RSP: 0018:ffff8e3abfd03d78 EFLAGS: 00010046
> [] RAX: 0000000000000000 RBX: ffffdb59c03f8900 RCX: ffffffffffffffe8
> [] RDX: 0000000000000000 RSI: 0000000000000010 RDI: ffff8e3abffeb000
> [] RBP: ffff8e3abfd03da8 R08: 0000000000020059 R09: 00000000fffffffc
> [] R10: 0000000000000000 R11: 0000000000020048 R12: ffff8e3a8c39f668
> [] R13: 0000000000000001 R14: ffff8e3a8c39f680 R15: 0000000000000000
> [] FS:  0000000000000000(0000) GS:ffff8e3abfd00000(0000)
> knlGS:0000000000000000
> [] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [] CR2: 00000000000003b0 CR3: 000000002c5e1000 CR4: 00000000000406e0
> [] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> [] Call Trace:
> []  <IRQ>
> []  end_page_writeback+0x47/0x70
> []  f2fs_write_end_io+0x76/0x180 [f2fs]
> []  bio_endio+0x9f/0x120
> []  blk_update_request+0xa8/0x2f0
> []  scsi_end_request+0x39/0x1d0
> []  scsi_io_completion+0x211/0x690
> []  scsi_finish_command+0xd9/0x120
> []  scsi_softirq_done+0x127/0x150
> []  __blk_mq_complete_request_remote+0x13/0x20
> []  flush_smp_call_function_queue+0x56/0x110
> []  generic_smp_call_function_single_interrupt+0x13/0x30
> []  smp_call_function_single_interrupt+0x27/0x40
> []  call_function_single_interrupt+0x89/0x90
> [] RIP: 0010:native_safe_halt+0x6/0x10
>
> (gdb) l *(test_clear_page_writeback+0x12e)
> 0xffffffff811bae3e is in test_clear_page_writeback
> (./include/linux/memcontrol.h:619).
> 614             mod_node_page_state(page_pgdat(page), idx, val);
> 615             if (mem_cgroup_disabled() || !page->mem_cgroup)
> 616                     return;
> 617             mod_memcg_state(page->mem_cgroup, idx, val);
> 618             pn = page->mem_cgroup->nodeinfo[page_to_nid(page)];
> 619             this_cpu_add(pn->lruvec_stat->count[idx], val);
> 620     }
> 621
> 622     unsigned long mem_cgroup_soft_limit_reclaim(pg_data_t *pgdat, int
> order,
> 623                                                     gfp_t gfp_mask,
>
> The issue is that writeback doesn't hold a page reference and the page
> might get freed after PG_writeback is cleared (and the mapping is
> unlocked) in test_clear_page_writeback(). The stat functions looking
> up the page's node or zone are safe, as those attributes are static
> across allocation and free cycles. But page->mem_cgroup is not, and it
> will get cleared if we race with truncation or migration.
>
> It appears this race window has been around for a while, but less
> likely to trigger when the memcg stats were updated first thing after
> PG_writeback is cleared. Recent changes reshuffled this code to update
> the global node stats before the memcg ones, though, stretching the
> race window out to an extent where people can reproduce the problem.
>
> Update test_clear_page_writeback() to look up and pin page->mem_cgroup
> before clearing PG_writeback, then not use that pointer afterward. It
> is a partial revert of 62cccb8c8e7a ("mm: simplify lock_page_memcg()")
> but leaves the pageref-holding callsites that aren't affected alone.
>
> Fixes: 62cccb8c8e7a ("mm: simplify lock_page_memcg()")
> Reported-by: Jaegeuk Kim <jaegeuk@kernel.org <javascript:;>>
> Reported-by: Bradley Bolen <bradleybolen@gmail.com <javascript:;>>
> Cc: <stable@vger.kernel.org <javascript:;>> # 4.6+
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org <javascript:;>>
> ---
>  include/linux/memcontrol.h | 10 ++++++++--
>  mm/memcontrol.c            | 43 ++++++++++++++++++++++++++++++
> +------------
>  mm/page-writeback.c        | 15 ++++++++++++---
>  3 files changed, 51 insertions(+), 17 deletions(-)
>
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 3914e3dd6168..9b15a4bcfa77 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -484,7 +484,8 @@ bool mem_cgroup_oom_synchronize(bool wait);
>  extern int do_swap_account;
>  #endif
>
> -void lock_page_memcg(struct page *page);
> +struct mem_cgroup *lock_page_memcg(struct page *page);
> +void __unlock_page_memcg(struct mem_cgroup *memcg);
>  void unlock_page_memcg(struct page *page);
>
>  static inline unsigned long memcg_page_state(struct mem_cgroup *memcg,
> @@ -809,7 +810,12 @@ mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
> struct task_struct *p)
>  {
>  }
>
> -static inline void lock_page_memcg(struct page *page)
> +static inline struct mem_cgroup *lock_page_memcg(struct page *page)
> +{
> +       return NULL;
> +}
> +
> +static inline void __unlock_page_memcg(struct mem_cgroup *memcg)
>  {
>  }
>
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 3df3c04d73ab..e09741af816f 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1611,9 +1611,13 @@ bool mem_cgroup_oom_synchronize(bool handle)
>   * @page: the page
>   *
>   * This function protects unlocked LRU pages from being moved to
> - * another cgroup and stabilizes their page->mem_cgroup binding.
> + * another cgroup.
> + *
> + * It ensures lifetime of the returned memcg. Caller is responsible
> + * for the lifetime of the page; __unlock_page_memcg() is available
> + * when @page might get freed inside the locked section.
>   */
> -void lock_page_memcg(struct page *page)
> +struct mem_cgroup *lock_page_memcg(struct page *page)
>  {
>         struct mem_cgroup *memcg;
>         unsigned long flags;
> @@ -1622,18 +1626,24 @@ void lock_page_memcg(struct page *page)
>          * The RCU lock is held throughout the transaction.  The fast
>          * path can get away without acquiring the memcg->move_lock
>          * because page moving starts with an RCU grace period.
> -        */
> +        *
> +        * The RCU lock also protects the memcg from being freed when
> +        * the page state that is going to change is the only thing
> +        * preventing the page itself from being freed. E.g. writeback
> +        * doesn't hold a page reference and relies on PG_writeback to
> +        * keep off truncation, migration and so forth.
> +         */
>         rcu_read_lock();
>
>         if (mem_cgroup_disabled())
> -               return;
> +               return NULL;
>  again:
>         memcg = page->mem_cgroup;
>         if (unlikely(!memcg))
> -               return;
> +               return NULL;
>
>         if (atomic_read(&memcg->moving_account) <= 0)
> -               return;
> +               return memcg;
>
>         spin_lock_irqsave(&memcg->move_lock, flags);
>         if (memcg != page->mem_cgroup) {
> @@ -1649,18 +1659,18 @@ void lock_page_memcg(struct page *page)
>         memcg->move_lock_task = current;
>         memcg->move_lock_flags = flags;
>
> -       return;
> +       return memcg;
>  }
>  EXPORT_SYMBOL(lock_page_memcg);
>
>  /**
> - * unlock_page_memcg - unlock a page->mem_cgroup binding
> - * @page: the page
> + * __unlock_page_memcg - unlock and unpin a memcg
> + * @memcg: the memcg
> + *
> + * Unlock and unpin a memcg returned by lock_page_memcg().
>   */
> -void unlock_page_memcg(struct page *page)
> +void __unlock_page_memcg(struct mem_cgroup *memcg)
>  {
> -       struct mem_cgroup *memcg = page->mem_cgroup;
> -
>         if (memcg && memcg->move_lock_task == current) {
>                 unsigned long flags = memcg->move_lock_flags;
>
> @@ -1672,6 +1682,15 @@ void unlock_page_memcg(struct page *page)
>
>         rcu_read_unlock();
>  }
> +
> +/**
> + * unlock_page_memcg - unlock a page->mem_cgroup binding
> + * @page: the page
> + */
> +void unlock_page_memcg(struct page *page)
> +{
> +       __unlock_page_memcg(page->mem_cgroup);
> +}
>  EXPORT_SYMBOL(unlock_page_memcg);
>
>  /*
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index 96e93b214d31..bf050ab025b7 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -2724,9 +2724,12 @@ EXPORT_SYMBOL(clear_page_dirty_for_io);
>  int test_clear_page_writeback(struct page *page)
>  {
>         struct address_space *mapping = page_mapping(page);
> +       struct mem_cgroup *memcg;
> +       struct lruvec *lruvec;
>         int ret;
>
> -       lock_page_memcg(page);
> +       memcg = lock_page_memcg(page);
> +       lruvec = mem_cgroup_page_lruvec(page, page_pgdat(page));
>         if (mapping && mapping_use_writeback_tags(mapping)) {
>                 struct inode *inode = mapping->host;
>                 struct backing_dev_info *bdi = inode_to_bdi(inode);
> @@ -2754,12 +2757,18 @@ int test_clear_page_writeback(struct page *page)
>         } else {
>                 ret = TestClearPageWriteback(page);
>         }
> +       /*
> +        * NOTE: Page might be free now! Writeback doesn't hold a page
> +        * reference on its own, it relies on truncation to wait for
> +        * the clearing of PG_writeback. The below can only access
> +        * page state that is static across allocation cycles.
> +        */
>         if (ret) {
> -               dec_lruvec_page_state(page, NR_WRITEBACK);
> +               dec_lruvec_state(lruvec, NR_WRITEBACK);
>                 dec_zone_page_state(page, NR_ZONE_WRITE_PENDING);
>                 inc_node_page_state(page, NR_WRITTEN);
>         }
> -       unlock_page_memcg(page);
> +       __unlock_page_memcg(memcg);
>         return ret;
>  }
>
> --
> 2.13.3
>
>

--001a11404c3ae14c940556667ab2
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

I&#39;m sorry.=C2=A0 I&#39;ve been away.=C2=A0 I should be able to try it t=
his afternoon.=C2=A0<br><br>On Wednesday, August 9, 2017, Johannes Weiner &=
lt;<a href=3D"mailto:hannes@cmpxchg.org">hannes@cmpxchg.org</a>&gt; wrote:<=
br><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left=
:1px #ccc solid;padding-left:1ex">On Tue, Aug 08, 2017 at 10:39:27PM -0400,=
 Brad Bolen wrote:<br>
&gt; Yes, the BUG_ON(!page_count(page)) fired for me as well.<br>
<br>
Brad, Jaegeuk, does the following patch address this problem?<br>
<br>
---<br>
<br>
>From cf0060892eb70bccbc8cedeac0a575<wbr>6c8f7b975e Mon Sep 17 00:00:00 2001=
<br>
From: Johannes Weiner &lt;<a href=3D"javascript:;" onclick=3D"_e(event, &#3=
9;cvml&#39;, &#39;hannes@cmpxchg.org&#39;)">hannes@cmpxchg.org</a>&gt;<br>
Date: Wed, 9 Aug 2017 12:06:03 -0400<br>
Subject: [PATCH] mm: memcontrol: fix NULL pointer crash in<br>
=C2=A0test_clear_page_writeback()<br>
<br>
Jaegeuk and Brad report a NULL pointer crash when writeback ending<br>
tries to update the memcg stats:<br>
<br>
[] BUG: unable to handle kernel NULL pointer dereference at 00000000000003b=
0<br>
[] IP: test_clear_page_writeback+<wbr>0x12e/0x2c0<br>
[...]<br>
[] RIP: 0010:test_clear_page_<wbr>writeback+0x12e/0x2c0<br>
[] RSP: 0018:ffff8e3abfd03d78 EFLAGS: 00010046<br>
[] RAX: 0000000000000000 RBX: ffffdb59c03f8900 RCX: ffffffffffffffe8<br>
[] RDX: 0000000000000000 RSI: 0000000000000010 RDI: ffff8e3abffeb000<br>
[] RBP: ffff8e3abfd03da8 R08: 0000000000020059 R09: 00000000fffffffc<br>
[] R10: 0000000000000000 R11: 0000000000020048 R12: ffff8e3a8c39f668<br>
[] R13: 0000000000000001 R14: ffff8e3a8c39f680 R15: 0000000000000000<br>
[] FS:=C2=A0 0000000000000000(0000) GS:ffff8e3abfd00000(0000) knlGS:0000000=
000000000<br>
[] CS:=C2=A0 0010 DS: 0000 ES: 0000 CR0: 0000000080050033<br>
[] CR2: 00000000000003b0 CR3: 000000002c5e1000 CR4: 00000000000406e0<br>
[] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000<br>
[] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400<br>
[] Call Trace:<br>
[]=C2=A0 &lt;IRQ&gt;<br>
[]=C2=A0 end_page_writeback+0x47/0x70<br>
[]=C2=A0 f2fs_write_end_io+0x76/0x180 [f2fs]<br>
[]=C2=A0 bio_endio+0x9f/0x120<br>
[]=C2=A0 blk_update_request+0xa8/0x2f0<br>
[]=C2=A0 scsi_end_request+0x39/0x1d0<br>
[]=C2=A0 scsi_io_completion+0x211/0x690<br>
[]=C2=A0 scsi_finish_command+0xd9/0x120<br>
[]=C2=A0 scsi_softirq_done+0x127/0x150<br>
[]=C2=A0 __blk_mq_complete_request_<wbr>remote+0x13/0x20<br>
[]=C2=A0 flush_smp_call_function_queue+<wbr>0x56/0x110<br>
[]=C2=A0 generic_smp_call_function_<wbr>single_interrupt+0x13/0x30<br>
[]=C2=A0 smp_call_function_single_<wbr>interrupt+0x27/0x40<br>
[]=C2=A0 call_function_single_<wbr>interrupt+0x89/0x90<br>
[] RIP: 0010:native_safe_halt+0x6/0x10<br>
<br>
(gdb) l *(test_clear_page_writeback+<wbr>0x12e)<br>
0xffffffff811bae3e is in test_clear_page_writeback (./include/linux/memcont=
rol.h:<wbr>619).<br>
614=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0mod_node_page_state(page=
_<wbr>pgdat(page), idx, val);<br>
615=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (mem_cgroup_disabled(=
) || !page-&gt;mem_cgroup)<br>
616=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0return;<br>
617=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0mod_memcg_state(page-&gt=
;mem_<wbr>cgroup, idx, val);<br>
618=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pn =3D page-&gt;mem_cgro=
up-&gt;nodeinfo[<wbr>page_to_nid(page)];<br>
619=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0this_cpu_add(pn-&gt;lruv=
ec_stat-&gt;<wbr>count[idx], val);<br>
620=C2=A0 =C2=A0 =C2=A0}<br>
621<br>
622=C2=A0 =C2=A0 =C2=A0unsigned long mem_cgroup_soft_limit_reclaim(<wbr>pg_=
data_t *pgdat, int order,<br>
623=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0gfp_t gfp_mask,<br>
<br>
The issue is that writeback doesn&#39;t hold a page reference and the page<=
br>
might get freed after PG_writeback is cleared (and the mapping is<br>
unlocked) in test_clear_page_writeback(). The stat functions looking<br>
up the page&#39;s node or zone are safe, as those attributes are static<br>
across allocation and free cycles. But page-&gt;mem_cgroup is not, and it<b=
r>
will get cleared if we race with truncation or migration.<br>
<br>
It appears this race window has been around for a while, but less<br>
likely to trigger when the memcg stats were updated first thing after<br>
PG_writeback is cleared. Recent changes reshuffled this code to update<br>
the global node stats before the memcg ones, though, stretching the<br>
race window out to an extent where people can reproduce the problem.<br>
<br>
Update test_clear_page_writeback() to look up and pin page-&gt;mem_cgroup<b=
r>
before clearing PG_writeback, then not use that pointer afterward. It<br>
is a partial revert of 62cccb8c8e7a (&quot;mm: simplify lock_page_memcg()&q=
uot;)<br>
but leaves the pageref-holding callsites that aren&#39;t affected alone.<br=
>
<br>
Fixes: 62cccb8c8e7a (&quot;mm: simplify lock_page_memcg()&quot;)<br>
Reported-by: Jaegeuk Kim &lt;<a href=3D"javascript:;" onclick=3D"_e(event, =
&#39;cvml&#39;, &#39;jaegeuk@kernel.org&#39;)">jaegeuk@kernel.org</a>&gt;<b=
r>
Reported-by: Bradley Bolen &lt;<a href=3D"javascript:;" onclick=3D"_e(event=
, &#39;cvml&#39;, &#39;bradleybolen@gmail.com&#39;)">bradleybolen@gmail.com=
</a>&gt;<br>
Cc: &lt;<a href=3D"javascript:;" onclick=3D"_e(event, &#39;cvml&#39;, &#39;=
stable@vger.kernel.org&#39;)">stable@vger.kernel.org</a>&gt; # 4.6+<br>
Signed-off-by: Johannes Weiner &lt;<a href=3D"javascript:;" onclick=3D"_e(e=
vent, &#39;cvml&#39;, &#39;hannes@cmpxchg.org&#39;)">hannes@cmpxchg.org</a>=
&gt;<br>
---<br>
=C2=A0include/linux/memcontrol.h | 10 ++++++++--<br>
=C2=A0mm/memcontrol.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | 43 +++++++=
+++++++++++++++++++++++<wbr>+------------<br>
=C2=A0mm/page-writeback.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 | 15 ++++++++++++---<b=
r>
=C2=A03 files changed, 51 insertions(+), 17 deletions(-)<br>
<br>
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h<br>
index 3914e3dd6168..9b15a4bcfa77 100644<br>
--- a/include/linux/memcontrol.h<br>
+++ b/include/linux/memcontrol.h<br>
@@ -484,7 +484,8 @@ bool mem_cgroup_oom_synchronize(<wbr>bool wait);<br>
=C2=A0extern int do_swap_account;<br>
=C2=A0#endif<br>
<br>
-void lock_page_memcg(struct page *page);<br>
+struct mem_cgroup *lock_page_memcg(struct page *page);<br>
+void __unlock_page_memcg(struct mem_cgroup *memcg);<br>
=C2=A0void unlock_page_memcg(struct page *page);<br>
<br>
=C2=A0static inline unsigned long memcg_page_state(struct mem_cgroup *memcg=
,<br>
@@ -809,7 +810,12 @@ mem_cgroup_print_oom_info(<wbr>struct mem_cgroup *memc=
g, struct task_struct *p)<br>
=C2=A0{<br>
=C2=A0}<br>
<br>
-static inline void lock_page_memcg(struct page *page)<br>
+static inline struct mem_cgroup *lock_page_memcg(struct page *page)<br>
+{<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0return NULL;<br>
+}<br>
+<br>
+static inline void __unlock_page_memcg(struct mem_cgroup *memcg)<br>
=C2=A0{<br>
=C2=A0}<br>
<br>
diff --git a/mm/memcontrol.c b/mm/memcontrol.c<br>
index 3df3c04d73ab..e09741af816f 100644<br>
--- a/mm/memcontrol.c<br>
+++ b/mm/memcontrol.c<br>
@@ -1611,9 +1611,13 @@ bool mem_cgroup_oom_synchronize(<wbr>bool handle)<br=
>
=C2=A0 * @page: the page<br>
=C2=A0 *<br>
=C2=A0 * This function protects unlocked LRU pages from being moved to<br>
- * another cgroup and stabilizes their page-&gt;mem_cgroup binding.<br>
+ * another cgroup.<br>
+ *<br>
+ * It ensures lifetime of the returned memcg. Caller is responsible<br>
+ * for the lifetime of the page; __unlock_page_memcg() is available<br>
+ * when @page might get freed inside the locked section.<br>
=C2=A0 */<br>
-void lock_page_memcg(struct page *page)<br>
+struct mem_cgroup *lock_page_memcg(struct page *page)<br>
=C2=A0{<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 struct mem_cgroup *memcg;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long flags;<br>
@@ -1622,18 +1626,24 @@ void lock_page_memcg(struct page *page)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* The RCU lock is held throughout the tra=
nsaction.=C2=A0 The fast<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* path can get away without acquiring the=
 memcg-&gt;move_lock<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* because page moving starts with an RCU =
grace period.<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 */<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 *<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 * The RCU lock also protects the memcg from be=
ing freed when<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 * the page state that is going to change is th=
e only thing<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 * preventing the page itself from being freed.=
 E.g. writeback<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 * doesn&#39;t hold a page reference and relies=
 on PG_writeback to<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 * keep off truncation, migration and so forth.=
<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 rcu_read_lock();<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (mem_cgroup_disabled())<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return NULL;<br>
=C2=A0again:<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 memcg =3D page-&gt;mem_cgroup;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (unlikely(!memcg))<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return NULL;<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (atomic_read(&amp;memcg-&gt;moving_<wbr>acco=
unt) &lt;=3D 0)<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return memcg;<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_lock_irqsave(&amp;memcg-&gt;<wbr>move_lock=
, flags);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (memcg !=3D page-&gt;mem_cgroup) {<br>
@@ -1649,18 +1659,18 @@ void lock_page_memcg(struct page *page)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 memcg-&gt;move_lock_task =3D current;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 memcg-&gt;move_lock_flags =3D flags;<br>
<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0return;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0return memcg;<br>
=C2=A0}<br>
=C2=A0EXPORT_SYMBOL(lock_page_memcg)<wbr>;<br>
<br>
=C2=A0/**<br>
- * unlock_page_memcg - unlock a page-&gt;mem_cgroup binding<br>
- * @page: the page<br>
+ * __unlock_page_memcg - unlock and unpin a memcg<br>
+ * @memcg: the memcg<br>
+ *<br>
+ * Unlock and unpin a memcg returned by lock_page_memcg().<br>
=C2=A0 */<br>
-void unlock_page_memcg(struct page *page)<br>
+void __unlock_page_memcg(struct mem_cgroup *memcg)<br>
=C2=A0{<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0struct mem_cgroup *memcg =3D page-&gt;mem_cgrou=
p;<br>
-<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (memcg &amp;&amp; memcg-&gt;move_lock_task =
=3D=3D current) {<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long flags=
 =3D memcg-&gt;move_lock_flags;<br>
<br>
@@ -1672,6 +1682,15 @@ void unlock_page_memcg(struct page *page)<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 rcu_read_unlock();<br>
=C2=A0}<br>
+<br>
+/**<br>
+ * unlock_page_memcg - unlock a page-&gt;mem_cgroup binding<br>
+ * @page: the page<br>
+ */<br>
+void unlock_page_memcg(struct page *page)<br>
+{<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0__unlock_page_memcg(page-&gt;mem_<wbr>cgroup);<=
br>
+}<br>
=C2=A0EXPORT_SYMBOL(unlock_page_<wbr>memcg);<br>
<br>
=C2=A0/*<br>
diff --git a/mm/page-writeback.c b/mm/page-writeback.c<br>
index 96e93b214d31..bf050ab025b7 100644<br>
--- a/mm/page-writeback.c<br>
+++ b/mm/page-writeback.c<br>
@@ -2724,9 +2724,12 @@ EXPORT_SYMBOL(clear_page_<wbr>dirty_for_io);<br>
=C2=A0int test_clear_page_writeback(<wbr>struct page *page)<br>
=C2=A0{<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 struct address_space *mapping =3D page_mapping(=
page);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0struct mem_cgroup *memcg;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0struct lruvec *lruvec;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 int ret;<br>
<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0lock_page_memcg(page);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0memcg =3D lock_page_memcg(page);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0lruvec =3D mem_cgroup_page_lruvec(page, page_pg=
dat(page));<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (mapping &amp;&amp; mapping_use_writeback_ta=
gs(<wbr>mapping)) {<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct inode *inode=
 =3D mapping-&gt;host;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct backing_dev_=
info *bdi =3D inode_to_bdi(inode);<br>
@@ -2754,12 +2757,18 @@ int test_clear_page_writeback(<wbr>struct page *pag=
e)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 } else {<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D TestClearPa=
geWriteback(page);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 }<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0/*<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 * NOTE: Page might be free now! Writeback does=
n&#39;t hold a page<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 * reference on its own, it relies on truncatio=
n to wait for<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 * the clearing of PG_writeback. The below can =
only access<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 * page state that is static across allocation =
cycles.<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 */<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (ret) {<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0dec_lruvec_page_sta=
te(page, NR_WRITEBACK);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0dec_lruvec_state(lr=
uvec, NR_WRITEBACK);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dec_zone_page_state=
(page, NR_ZONE_WRITE_PENDING);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 inc_node_page_state=
(page, NR_WRITTEN);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 }<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0unlock_page_memcg(page);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0__unlock_page_memcg(memcg);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 return ret;<br>
=C2=A0}<br>
<br>
--<br>
2.13.3<br>
<br>
</blockquote>

--001a11404c3ae14c940556667ab2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
