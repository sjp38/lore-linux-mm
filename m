Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id BFCCB6B004A
	for <linux-mm@kvack.org>; Fri,  3 Jun 2011 19:46:29 -0400 (EDT)
Received: from kpbe16.cbf.corp.google.com (kpbe16.cbf.corp.google.com [172.25.105.80])
	by smtp-out.google.com with ESMTP id p53NkJeg015111
	for <linux-mm@kvack.org>; Fri, 3 Jun 2011 16:46:19 -0700
Received: from qwh5 (qwh5.prod.google.com [10.241.194.197])
	by kpbe16.cbf.corp.google.com with ESMTP id p53NkBWe001786
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 3 Jun 2011 16:46:18 -0700
Received: by qwh5 with SMTP id 5so1130840qwh.6
        for <linux-mm@kvack.org>; Fri, 03 Jun 2011 16:46:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110603230939.GA2073@thinkpad>
References: <1307117538-14317-1-git-send-email-gthelen@google.com>
 <1307117538-14317-4-git-send-email-gthelen@google.com> <20110603230939.GA2073@thinkpad>
From: Greg Thelen <gthelen@google.com>
Date: Fri, 3 Jun 2011 16:45:58 -0700
Message-ID: <BANLkTi=Uw+v80wG9pgOCanaThuO3wcoN9F-YY6OdE88K-FxZzQ@mail.gmail.com>
Subject: Re: [PATCH v8 03/12] memcg: add mem_cgroup_mark_inode_dirty()
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Righi <arighi@develer.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Vivek Goyal <vgoyal@redhat.com>, Dave Chinner <david@fromorbit.com>

On Fri, Jun 3, 2011 at 4:09 PM, Andrea Righi <arighi@develer.com> wrote:
> On Fri, Jun 03, 2011 at 09:12:09AM -0700, Greg Thelen wrote:
> ...
>> diff --git a/fs/inode.c b/fs/inode.c
>> index ce61a1b..9ecb0bb 100644
>> --- a/fs/inode.c
>> +++ b/fs/inode.c
>> @@ -228,6 +228,9 @@ int inode_init_always(struct super_block *sb, struct=
 inode *inode)
>> =A0 =A0 =A0 mapping->assoc_mapping =3D NULL;
>> =A0 =A0 =A0 mapping->backing_dev_info =3D &default_backing_dev_info;
>> =A0 =A0 =A0 mapping->writeback_index =3D 0;
>> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR
>> + =A0 =A0 mapping->i_memcg =3D 0;
>> +#endif
>
> It won't change too much, since it's always 0, but shouldn't we use
> I_MEMCG_SHARED by default?

I agree, I_MEMCG_SHARED should be used instead of 0.  Will include in
-v9, if there is a need for -v9.

>> =A0 =A0 =A0 /*
>> =A0 =A0 =A0 =A0* If the block_device provides a backing_dev_info for cli=
ent
>> diff --git a/include/linux/fs.h b/include/linux/fs.h
>> index 29c02f6..deabca3 100644
>> --- a/include/linux/fs.h
>> +++ b/include/linux/fs.h
>> @@ -645,6 +645,9 @@ struct address_space {
>> =A0 =A0 =A0 spinlock_t =A0 =A0 =A0 =A0 =A0 =A0 =A0private_lock; =A0 /* f=
or use by the address_space */
>> =A0 =A0 =A0 struct list_head =A0 =A0 =A0 =A0private_list; =A0 /* ditto *=
/
>> =A0 =A0 =A0 struct address_space =A0 =A0*assoc_mapping; /* ditto */
>> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR
>> + =A0 =A0 unsigned short =A0 =A0 =A0 =A0 =A0i_memcg; =A0 =A0 =A0 =A0/* c=
ss_id of memcg dirtier */
>> +#endif
>> =A0} __attribute__((aligned(sizeof(long))));
>> =A0 =A0 =A0 /*
>> =A0 =A0 =A0 =A0* On most architectures that alignment is already the cas=
e; but
>> @@ -652,6 +655,12 @@ struct address_space {
>> =A0 =A0 =A0 =A0* of struct page's "mapping" pointer be used for PAGE_MAP=
PING_ANON.
>> =A0 =A0 =A0 =A0*/
>>
>> +/*
>> + * When an address_space is shared by multiple memcg dirtieres, then i_=
memcg is
>> + * set to this special, wildcard, css_id value (zero).
>> + */
>> +#define I_MEMCG_SHARED 0
>> +
>> =A0struct block_device {
>> =A0 =A0 =A0 dev_t =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bd_dev; =A0/* not =
a kdev_t - it's a search key */
>> =A0 =A0 =A0 int =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bd_openers;
>> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
>> index 77e47f5..14b6d67 100644
>> --- a/include/linux/memcontrol.h
>> +++ b/include/linux/memcontrol.h
>> @@ -103,6 +103,8 @@ mem_cgroup_prepare_migration(struct page *page,
>> =A0extern void mem_cgroup_end_migration(struct mem_cgroup *mem,
>> =A0 =A0 =A0 struct page *oldpage, struct page *newpage, bool migration_o=
k);
>>
>> +void mem_cgroup_mark_inode_dirty(struct inode *inode);
>> +
>> =A0/*
>> =A0 * For memory reclaim.
>> =A0 */
>> @@ -273,6 +275,10 @@ static inline void mem_cgroup_end_migration(struct =
mem_cgroup *mem,
>> =A0{
>> =A0}
>>
>> +static inline void mem_cgroup_mark_inode_dirty(struct inode *inode)
>> +{
>> +}
>> +
>> =A0static inline int mem_cgroup_get_reclaim_priority(struct mem_cgroup *=
mem)
>> =A0{
>> =A0 =A0 =A0 return 0;
>> diff --git a/include/trace/events/memcontrol.h b/include/trace/events/me=
mcontrol.h
>> new file mode 100644
>> index 0000000..781ef9fc
>> --- /dev/null
>> +++ b/include/trace/events/memcontrol.h
>> @@ -0,0 +1,32 @@
>> +#undef TRACE_SYSTEM
>> +#define TRACE_SYSTEM memcontrol
>> +
>> +#if !defined(_TRACE_MEMCONTROL_H) || defined(TRACE_HEADER_MULTI_READ)
>> +#define _TRACE_MEMCONTROL_H
>> +
>> +#include <linux/types.h>
>> +#include <linux/tracepoint.h>
>> +
>> +TRACE_EVENT(mem_cgroup_mark_inode_dirty,
>> + =A0 =A0 TP_PROTO(struct inode *inode),
>> +
>> + =A0 =A0 TP_ARGS(inode),
>> +
>> + =A0 =A0 TP_STRUCT__entry(
>> + =A0 =A0 =A0 =A0 =A0 =A0 __field(unsigned long, ino)
>> + =A0 =A0 =A0 =A0 =A0 =A0 __field(unsigned short, css_id)
>> + =A0 =A0 =A0 =A0 =A0 =A0 ),
>> +
>> + =A0 =A0 TP_fast_assign(
>> + =A0 =A0 =A0 =A0 =A0 =A0 __entry->ino =3D inode->i_ino;
>> + =A0 =A0 =A0 =A0 =A0 =A0 __entry->css_id =3D
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 inode->i_mapping ? inode->i_ma=
pping->i_memcg : 0;
>> + =A0 =A0 =A0 =A0 =A0 =A0 ),
>> +
>> + =A0 =A0 TP_printk("ino=3D%ld css_id=3D%d", __entry->ino, __entry->css_=
id)
>> +)
>> +
>> +#endif /* _TRACE_MEMCONTROL_H */
>> +
>> +/* This part must be outside protection */
>> +#include <trace/define_trace.h>
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index bf642b5..e83ef74 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -54,6 +54,9 @@
>>
>> =A0#include <trace/events/vmscan.h>
>>
>> +#define CREATE_TRACE_POINTS
>> +#include <trace/events/memcontrol.h>
>> +
>> =A0struct cgroup_subsys mem_cgroup_subsys __read_mostly;
>> =A0#define MEM_CGROUP_RECLAIM_RETRIES =A0 5
>> =A0struct mem_cgroup *root_mem_cgroup __read_mostly;
>> @@ -1122,6 +1125,27 @@ static int calc_inactive_ratio(struct mem_cgroup =
*memcg, unsigned long *present_
>> =A0 =A0 =A0 return inactive_ratio;
>> =A0}
>>
>> +/*
>> + * Mark the current task's memcg as the memcg associated with inode. =
=A0Note: the
>> + * recorded cgroup css_id is not guaranteed to remain correct. =A0The c=
urrent task
>> + * may be moved to another cgroup. =A0The memcg may also be deleted bef=
ore the
>> + * caller has time to use the i_memcg.
>> + */
>> +void mem_cgroup_mark_inode_dirty(struct inode *inode)
>> +{
>> + =A0 =A0 struct mem_cgroup *mem;
>> + =A0 =A0 unsigned short id;
>> +
>> + =A0 =A0 rcu_read_lock();
>> + =A0 =A0 mem =3D mem_cgroup_from_task(current);
>> + =A0 =A0 id =3D mem ? css_id(&mem->css) : 0;
>
> Ditto.

I agree, I_MEMCG_SHARED should be used instead of 0.

>> + =A0 =A0 rcu_read_unlock();
>> +
>> + =A0 =A0 inode->i_mapping->i_memcg =3D id;
>> +
>> + =A0 =A0 trace_mem_cgroup_mark_inode_dirty(inode);
>> +}
>> +
>> =A0int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg)
>> =A0{
>> =A0 =A0 =A0 unsigned long active;
>> --
>> 1.7.3.1
>
> Thanks,
> -Andrea
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
