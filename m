Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 491086B004D
	for <linux-mm@kvack.org>; Sat, 20 Feb 2010 06:56:47 -0500 (EST)
Received: by wyb42 with SMTP id 42so109451wyb.14
        for <linux-mm@kvack.org>; Sat, 20 Feb 2010 03:56:45 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20100220132217.17dc7dd3.kamezawa.hiroyu@jp.fujitsu.com>
References: <05f582d6cdc85fbb96bfadc344572924c0776730.1266618391.git.kirill@shutemov.name>
	 <a2717b1f5e0b49db7b6ecd1a5a41e65c1dc6b50a.1266618391.git.kirill@shutemov.name>
	 <20100220132217.17dc7dd3.kamezawa.hiroyu@jp.fujitsu.com>
Date: Sat, 20 Feb 2010 13:56:45 +0200
Message-ID: <cc557aab1002200356j17ef419ex104cbc28125258b2@mail.gmail.com>
Subject: Re: [PATCH -mmotm 2/4] cgroups: remove events before destroying
	subsystem state objects
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: containers@lists.linux-foundation.org, linux-mm@kvack.org, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Dan Malek <dan@embeddedalley.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Sat, Feb 20, 2010 at 6:22 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Sat, 20 Feb 2010 00:28:17 +0200
> "Kirill A. Shutemov" <kirill@shutemov.name> wrote:
>
>> Events should be removed after rmdir of cgroup directory, but before
>> destroying subsystem state objects. Let's take reference to cgroup
>> directory dentry to do that.
>>
>> Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
>
> Okay, I welcome this.
>
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hioryu@jp.fujitsu.com>
>
> Just a quesion...After this change, if cgroup has remaining event,
> cgroup is removed by workqueue of event->remove() -> d_put(), finally. Ri=
ght ?

Yes

> Do you have a test set for checking this behavior ?

Run ./cgroup_event_listener to listen any event in the cgroup. Remove direc=
tory
of the cgroup (cgroup_event_listener will detect it). And check 'num_cgroup=
s'
column in /proc/cgroups.

>
> Thanks,
> -Kame
>
>
>
>> ---
>> =C2=A0include/linux/cgroup.h | =C2=A0 =C2=A03 ---
>> =C2=A0kernel/cgroup.c =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A08 ++++++=
++
>> =C2=A0mm/memcontrol.c =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A09 ------=
---
>> =C2=A03 files changed, 8 insertions(+), 12 deletions(-)
>>
>> diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
>> index 64cebfe..1719c75 100644
>> --- a/include/linux/cgroup.h
>> +++ b/include/linux/cgroup.h
>> @@ -395,9 +395,6 @@ struct cftype {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0* closes the eventfd or on cgroup removing.
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0* This callback must be implemented, if you w=
ant provide
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0* notification functionality.
>> - =C2=A0 =C2=A0 =C2=A0*
>> - =C2=A0 =C2=A0 =C2=A0* Be careful. It can be called after destroy(), so=
 you have
>> - =C2=A0 =C2=A0 =C2=A0* to keep all nesessary data, until all events are=
 removed.
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>> =C2=A0 =C2=A0 =C2=A0 int (*unregister_event)(struct cgroup *cgrp, struct=
 cftype *cft,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 struct eventfd_ctx *eventfd);
>> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
>> index 46903cb..d142524 100644
>> --- a/kernel/cgroup.c
>> +++ b/kernel/cgroup.c
>> @@ -2979,6 +2979,7 @@ static void cgroup_event_remove(struct work_struct=
 *work)
>>
>> =C2=A0 =C2=A0 =C2=A0 eventfd_ctx_put(event->eventfd);
>> =C2=A0 =C2=A0 =C2=A0 kfree(event);
>> + =C2=A0 =C2=A0 dput(cgrp->dentry);
>> =C2=A0}
>>
>> =C2=A0/*
>> @@ -3099,6 +3100,13 @@ static int cgroup_write_event_control(struct cgro=
up *cgrp, struct cftype *cft,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto fail;
>> =C2=A0 =C2=A0 =C2=A0 }
>>
>> + =C2=A0 =C2=A0 /*
>> + =C2=A0 =C2=A0 =C2=A0* Events should be removed after rmdir of cgroup d=
irectory, but before
>> + =C2=A0 =C2=A0 =C2=A0* destroying subsystem state objects. Let's take r=
eference to cgroup
>> + =C2=A0 =C2=A0 =C2=A0* directory dentry to do that.
>> + =C2=A0 =C2=A0 =C2=A0*/
>> + =C2=A0 =C2=A0 dget(cgrp->dentry);
>> +
>> =C2=A0 =C2=A0 =C2=A0 spin_lock(&cgrp->event_list_lock);
>> =C2=A0 =C2=A0 =C2=A0 list_add(&event->list, &cgrp->event_list);
>> =C2=A0 =C2=A0 =C2=A0 spin_unlock(&cgrp->event_list_lock);
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index a443c30..8fe6e7f 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -3358,12 +3358,6 @@ static int mem_cgroup_register_event(struct cgrou=
p *cgrp, struct cftype *cft,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> =C2=A0 =C2=A0 =C2=A0 }
>>
>> - =C2=A0 =C2=A0 /*
>> - =C2=A0 =C2=A0 =C2=A0* We need to increment refcnt to be sure that all =
thresholds
>> - =C2=A0 =C2=A0 =C2=A0* will be unregistered before calling __mem_cgroup=
_free()
>> - =C2=A0 =C2=A0 =C2=A0*/
>> - =C2=A0 =C2=A0 mem_cgroup_get(memcg);
>> -
>> =C2=A0 =C2=A0 =C2=A0 if (type =3D=3D _MEM)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rcu_assign_pointer(memc=
g->thresholds, thresholds_new);
>> =C2=A0 =C2=A0 =C2=A0 else
>> @@ -3457,9 +3451,6 @@ assign:
>> =C2=A0 =C2=A0 =C2=A0 /* To be sure that nobody uses thresholds before fr=
eeing it */
>> =C2=A0 =C2=A0 =C2=A0 synchronize_rcu();
>>
>> - =C2=A0 =C2=A0 for (i =3D 0; i < thresholds->size - size; i++)
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mem_cgroup_put(memcg);
>> -
>> =C2=A0 =C2=A0 =C2=A0 kfree(thresholds);
>> =C2=A0unlock:
>> =C2=A0 =C2=A0 =C2=A0 mutex_unlock(&memcg->thresholds_lock);
>> --
>> 1.6.6.2
>>
>>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
