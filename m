Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 4E3566B004F
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 01:48:13 -0500 (EST)
Message-ID: <496D8A76.9040509@cn.fujitsu.com>
Date: Wed, 14 Jan 2009 14:47:18 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] memcg: fix a race when setting memcg.swappiness
References: <496D5AE2.2020403@cn.fujitsu.com> <20090114132616.3cb7d568.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090114132616.3cb7d568.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Paul Menage <menage@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Linux Containers <containers@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Wed, 14 Jan 2009 11:24:18 +0800
> Li Zefan <lizf@cn.fujitsu.com> wrote:
> 
>> (suppose: memcg->use_hierarchy == 0 and memcg->swappiness == 60)
>>
>> echo 10 > /memcg/0/swappiness   |
>>   mem_cgroup_swappiness_write() |
>>     ...                         | echo 1 > /memcg/0/use_hierarchy
>>                                 | mkdir /mnt/0/1
>>                                 |   sub_memcg->swappiness = 60;
>>     memcg->swappiness = 10;     |
>>
>> In the above scenario, we end up having 2 different swappiness
>> values in a single hierarchy.
>>
>> Note we can't use hierarchy_lock here, because it doesn't protect
>> the create() method.
>>
>> Though IMO use cgroup_lock() in simple write functions is OK,
>> Paul would like to avoid it. And he sugguested use a counter to
>> count the number of children instead of check cgrp->children list:
>>
>> =================
>> create() does:
>>
>> lock memcg_parent
>> memcg->swappiness = memcg->parent->swappiness;
>> memcg_parent->child_count++;
>> unlock memcg_parent
>>
>> and write() does:
>>
>> lock memcg
>> if (!memcg->child_count) {
>>   memcg->swappiness = swappiness;
>> } else {
>>   report error;
>> }
>> unlock memcg
>>
>> destroy() does:
>> lock memcg_parent
>> memcg_parent->child_count--;
>> unlock memcg_parent
>>
>> =================
>>
>> And there is a suble differnce with checking cgrp->children,
>> that a cgroup is removed from parent's list in cgroup_rmdir(),
>> while memcg->child_count is decremented in cgroup_diput().
>>
>>
>> Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
> 
> Seems reasonable, but, hmm...
> 

Do you mean you agree to avoid using cgroup_lock()?

> Why hierarchy_mutex can't be used for create() ?
> 

We can make hierarchy_mutex work for this race by:

@@ -2403,16 +2403,18 @@ static long cgroup_create(struct cgroup *parent, struct
        if (notify_on_release(parent))
                set_bit(CGRP_NOTIFY_ON_RELEASE, &cgrp->flags);

+       cgroup_lock_hierarchy(root);
+
        for_each_subsys(root, ss) {
                struct cgroup_subsys_state *css = ss->create(ss, cgrp);
                if (IS_ERR(css)) {
+                       cgroup_unlock_hierarchy(root);
                        err = PTR_ERR(css);
                        goto err_destroy;
                }
                init_cgroup_css(css, ss, cgrp);
        }

-       cgroup_lock_hierarchy(root);
        list_add(&cgrp->sibling, &cgrp->parent->children);
        cgroup_unlock_hierarchy(root);
        root->number_of_cgroups++;

But this may not be what we want, because hierarchy_mutex is meant to be
lightweight, so it's not held while subsys callbacks are invoked, except
bind().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
