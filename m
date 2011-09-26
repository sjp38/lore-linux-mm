Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id AAF289000BD
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 08:29:42 -0400 (EDT)
Received: by wyf22 with SMTP id 22so6785324wyf.14
        for <linux-mm@kvack.org>; Mon, 26 Sep 2011 05:29:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAFPAmTQPiHU8AKnQvzMM5KiQr1GnUY+Yf8PwVC6++QK8u149Ew@mail.gmail.com>
References: <1316948380-1879-1-git-send-email-consul.kautuk@gmail.com>
	<20110926112944.GC14333@redhat.com>
	<CAFPAmTQPiHU8AKnQvzMM5KiQr1GnUY+Yf8PwVC6++QK8u149Ew@mail.gmail.com>
Date: Mon, 26 Sep 2011 17:59:39 +0530
Message-ID: <CAFPAmTQbHhj8wodFEutpstXdQ6Kc2_qRV6Pe69ngHwz1erF29Q@mail.gmail.com>
Subject: Re: [patch] mm: remove sysctl to manually rescue unevictable pages
From: "kautuk.c @samsung.com" <consul.kautuk@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Lee Schermerhorn <lee.schermerhorn@hp.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Mon, Sep 26, 2011 at 5:40 PM, kautuk.c @samsung.com
<consul.kautuk@gmail.com> wrote:
> On Mon, Sep 26, 2011 at 4:59 PM, Johannes Weiner <jweiner@redhat.com> wro=
te:
>> On Sun, Sep 25, 2011 at 04:29:40PM +0530, Kautuk Consul wrote:
>>> write_scan_unavictable_node checks the value req returned by
>>> strict_strtoul and returns 1 if req is 0.
>>>
>>> However, when strict_strtoul returns 0, it means successful conversion
>>> of buf to unsigned long.
>>>
>>> Due to this, the function was not proceeding to scan the zones for
>>> unevictable pages even though we write a valid value to the
>>> scan_unevictable_pages sys file.
>>
>> Given that there is not a real reason for this knob (anymore) and that
>> it apparently never really worked since the day it was introduced, how
>> about we just drop all that code instead?
>>
>> =A0 =A0 =A0 =A0Hannes
>>
>> ---
>> From: Johannes Weiner <jweiner@redhat.com>
>> Subject: mm: remove sysctl to manually rescue unevictable pages
>>
>> At one point, anonymous pages were supposed to go on the unevictable
>> list when no swap space was configured, and the idea was to manually
>> rescue those pages after adding swap and making them evictable again.
>> But nowadays, swap-backed pages on the anon LRU list are not scanned
>> without available swap space anyway, so there is no point in moving
>> them to a separate list anymore.
>
> Is this code only for anonymous pages ?
> It seems to look at all pages in the zone both file as well as anon.
>
>>
>> The manual rescue could also be used in case pages were stranded on
>> the unevictable list due to race conditions. =A0But the code has been
>> around for a while now and newly discovered bugs should be properly
>> reported and dealt with instead of relying on such a manual fixup.
>
> What you say seems to be all right for anon pages, but what about file
> pages ?
> I'm not sure about how this could happen, but what if some file-system ca=
used
> a file cache page to be set to evictable or reclaimable without
> actually removing
> that page from the unevictable list ?

What I would like to also add is that while the transition of an anon
page from and
to the unevictable lists is straight-forward, should we make the same assum=
ption
about file cache pages ?
I am not sure about this, but could a file-system cause this kind of a prob=
lem
independent of the mlocking behaviour of a user-mode app ?

>
>>
>> Signed-off-by: Johannes Weiner <jweiner@redhat.com>
>> ---
>> =A0drivers/base/node.c =A0| =A0 =A03 -
>> =A0include/linux/swap.h | =A0 16 ------
>> =A0kernel/sysctl.c =A0 =A0 =A0| =A0 =A07 ---
>> =A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0| =A0130 -----------------------------=
---------------------
>> =A04 files changed, 0 insertions(+), 156 deletions(-)
>>
>> diff --git a/drivers/base/node.c b/drivers/base/node.c
>> index 9e58e71..b9d6e93 100644
>> --- a/drivers/base/node.c
>> +++ b/drivers/base/node.c
>> @@ -278,8 +278,6 @@ int register_node(struct node *node, int num, struct=
 node *parent)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sysdev_create_file(&node->sysdev, &attr_d=
istance);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sysdev_create_file_optional(&node->sysdev=
, &attr_vmstat);
>>
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 scan_unevictable_register_node(node);
>> -
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0hugetlb_register_node(node);
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0compaction_register_node(node);
>> @@ -303,7 +301,6 @@ void unregister_node(struct node *node)
>> =A0 =A0 =A0 =A0sysdev_remove_file(&node->sysdev, &attr_distance);
>> =A0 =A0 =A0 =A0sysdev_remove_file_optional(&node->sysdev, &attr_vmstat);
>>
>> - =A0 =A0 =A0 scan_unevictable_unregister_node(node);
>> =A0 =A0 =A0 =A0hugetlb_unregister_node(node); =A0 =A0 =A0 =A0 =A0/* no-o=
p, if memoryless node */
>>
>> =A0 =A0 =A0 =A0sysdev_unregister(&node->sysdev);
>> diff --git a/include/linux/swap.h b/include/linux/swap.h
>> index b156e80..a6a9ee5 100644
>> --- a/include/linux/swap.h
>> +++ b/include/linux/swap.h
>> @@ -276,22 +276,6 @@ static inline int zone_reclaim(struct zone *z, gfp_=
t mask, unsigned int order)
>> =A0extern int page_evictable(struct page *page, struct vm_area_struct *v=
ma);
>> =A0extern void scan_mapping_unevictable_pages(struct address_space *);
>>
>> -extern unsigned long scan_unevictable_pages;
>> -extern int scan_unevictable_handler(struct ctl_table *, int,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 void __user *, size_t *, loff_t *);
>> -#ifdef CONFIG_NUMA
>> -extern int scan_unevictable_register_node(struct node *node);
>> -extern void scan_unevictable_unregister_node(struct node *node);
>> -#else
>> -static inline int scan_unevictable_register_node(struct node *node)
>> -{
>> - =A0 =A0 =A0 return 0;
>> -}
>> -static inline void scan_unevictable_unregister_node(struct node *node)
>> -{
>> -}
>> -#endif
>> -
>> =A0extern int kswapd_run(int nid);
>> =A0extern void kswapd_stop(int nid);
>> =A0#ifdef CONFIG_CGROUP_MEM_RES_CTLR
>> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
>> index 4f057f9..0d66092 100644
>> --- a/kernel/sysctl.c
>> +++ b/kernel/sysctl.c
>> @@ -1325,13 +1325,6 @@ static struct ctl_table vm_table[] =3D {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.extra2 =A0 =A0 =A0 =A0 =3D &one,
>> =A0 =A0 =A0 =A0},
>> =A0#endif
>> - =A0 =A0 =A0 {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 .procname =A0 =A0 =A0 =3D "scan_unevictabl=
e_pages",
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 .data =A0 =A0 =A0 =A0 =A0 =3D &scan_unevic=
table_pages,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 .maxlen =A0 =A0 =A0 =A0 =3D sizeof(scan_un=
evictable_pages),
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 .mode =A0 =A0 =A0 =A0 =A0 =3D 0644,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 .proc_handler =A0 =3D scan_unevictable_han=
dler,
>> - =A0 =A0 =A0 },
>> =A0#ifdef CONFIG_MEMORY_FAILURE
>> =A0 =A0 =A0 =A0{
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.procname =A0 =A0 =A0 =3D "memory_failure=
_early_kill",
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index 7502726..c99a097 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -3396,133 +3396,3 @@ void scan_mapping_unevictable_pages(struct addre=
ss_space *mapping)
>> =A0 =A0 =A0 =A0}
>>
>> =A0}
>> -
>> -/**
>> - * scan_zone_unevictable_pages - check unevictable list for evictable p=
ages
>> - * @zone - zone of which to scan the unevictable list
>> - *
>> - * Scan @zone's unevictable LRU lists to check for pages that have beco=
me
>> - * evictable. =A0Move those that have to @zone's inactive list where th=
ey
>> - * become candidates for reclaim, unless shrink_inactive_zone() decides
>> - * to reactivate them. =A0Pages that are still unevictable are rotated
>> - * back onto @zone's unevictable list.
>> - */
>> -#define SCAN_UNEVICTABLE_BATCH_SIZE 16UL /* arbitrary lock hold batch s=
ize */
>> -static void scan_zone_unevictable_pages(struct zone *zone)
>> -{
>> - =A0 =A0 =A0 struct list_head *l_unevictable =3D &zone->lru[LRU_UNEVICT=
ABLE].list;
>> - =A0 =A0 =A0 unsigned long scan;
>> - =A0 =A0 =A0 unsigned long nr_to_scan =3D zone_page_state(zone, NR_UNEV=
ICTABLE);
>> -
>> - =A0 =A0 =A0 while (nr_to_scan > 0) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long batch_size =3D min(nr_to_sca=
n,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 SCAN_UNEVICTABLE_BATCH_SIZE);
>> -
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock_irq(&zone->lru_lock);
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (scan =3D 0; =A0scan < batch_size; sca=
n++) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct page *page =3D lru_=
to_page(l_unevictable);
>> -
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!trylock_page(page))
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>> -
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 prefetchw_prev_lru_page(pa=
ge, l_unevictable, flags);
>> -
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (likely(PageLRU(page) &=
& PageUnevictable(page)))
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 check_move=
_unevictable_page(page, zone);
>> -
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unlock_page(page);
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock_irq(&zone->lru_lock);
>> -
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_to_scan -=3D batch_size;
>> - =A0 =A0 =A0 }
>> -}
>> -
>> -
>> -/**
>> - * scan_all_zones_unevictable_pages - scan all unevictable lists for ev=
ictable pages
>> - *
>> - * A really big hammer: =A0scan all zones' unevictable LRU lists to che=
ck for
>> - * pages that have become evictable. =A0Move those back to the zones'
>> - * inactive list where they become candidates for reclaim.
>> - * This occurs when, e.g., we have unswappable pages on the unevictable=
 lists,
>> - * and we add swap to the system. =A0As such, it runs in the context of=
 a task
>> - * that has possibly/probably made some previously unevictable pages
>> - * evictable.
>> - */
>> -static void scan_all_zones_unevictable_pages(void)
>> -{
>> - =A0 =A0 =A0 struct zone *zone;
>> -
>> - =A0 =A0 =A0 for_each_zone(zone) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 scan_zone_unevictable_pages(zone);
>> - =A0 =A0 =A0 }
>> -}
>> -
>> -/*
>> - * scan_unevictable_pages [vm] sysctl handler. =A0On demand re-scan of
>> - * all nodes' unevictable lists for evictable pages
>> - */
>> -unsigned long scan_unevictable_pages;
>> -
>> -int scan_unevictable_handler(struct ctl_table *table, int write,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0void __user *buffer=
,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0size_t *length, lof=
f_t *ppos)
>> -{
>> - =A0 =A0 =A0 proc_doulongvec_minmax(table, write, buffer, length, ppos)=
;
>> -
>> - =A0 =A0 =A0 if (write && *(unsigned long *)table->data)
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 scan_all_zones_unevictable_pages();
>> -
>> - =A0 =A0 =A0 scan_unevictable_pages =3D 0;
>> - =A0 =A0 =A0 return 0;
>> -}
>> -
>> -#ifdef CONFIG_NUMA
>> -/*
>> - * per node 'scan_unevictable_pages' attribute. =A0On demand re-scan of
>> - * a specified node's per zone unevictable lists for evictable pages.
>> - */
>> -
>> -static ssize_t read_scan_unevictable_node(struct sys_device *dev,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 struct sysdev_attribute *attr,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 char *buf)
>> -{
>> - =A0 =A0 =A0 return sprintf(buf, "0\n"); =A0 =A0 /* always zero; should=
 fit... */
>> -}
>> -
>> -static ssize_t write_scan_unevictable_node(struct sys_device *dev,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0struct sysdev_attribute *attr,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 const char *buf, size_t count)
>> -{
>> - =A0 =A0 =A0 struct zone *node_zones =3D NODE_DATA(dev->id)->node_zones=
;
>> - =A0 =A0 =A0 struct zone *zone;
>> - =A0 =A0 =A0 unsigned long res;
>> - =A0 =A0 =A0 unsigned long req =3D strict_strtoul(buf, 10, &res);
>> -
>> - =A0 =A0 =A0 if (!req)
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 1; =A0 =A0 =A0 /* zero is no-op */
>> -
>> - =A0 =A0 =A0 for (zone =3D node_zones; zone - node_zones < MAX_NR_ZONES=
; ++zone) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!populated_zone(zone))
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 scan_zone_unevictable_pages(zone);
>> - =A0 =A0 =A0 }
>> - =A0 =A0 =A0 return 1;
>> -}
>> -
>> -
>> -static SYSDEV_ATTR(scan_unevictable_pages, S_IRUGO | S_IWUSR,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 read_scan_unevictable_node=
,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 write_scan_unevictable_nod=
e);
>> -
>> -int scan_unevictable_register_node(struct node *node)
>> -{
>> - =A0 =A0 =A0 return sysdev_create_file(&node->sysdev, &attr_scan_unevic=
table_pages);
>> -}
>> -
>> -void scan_unevictable_unregister_node(struct node *node)
>> -{
>> - =A0 =A0 =A0 sysdev_remove_file(&node->sysdev, &attr_scan_unevictable_p=
ages);
>> -}
>> -#endif
>> --
>> 1.7.6.2
>>
>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
