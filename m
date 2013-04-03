Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 9C3F66B00B8
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 04:30:16 -0400 (EDT)
Message-ID: <515BE8C3.6040205@parallels.com>
Date: Wed, 3 Apr 2013 12:30:59 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH -v2] memcg: don't do cleanup manually if mem_cgroup_css_online()
 fails
References: <515A8A40.6020406@huawei.com> <20130402121600.GK24345@dhcp22.suse.cz> <20130402141646.GQ24345@dhcp22.suse.cz> <515AE948.1000704@parallels.com> <20130402142825.GA32520@dhcp22.suse.cz> <515AEC3A.2030401@parallels.com> <20130402150422.GB32520@dhcp22.suse.cz> <515BA6C9.2000704@huawei.com> <20130403074300.GA14384@dhcp22.suse.cz> <515BDEF2.1080900@huawei.com> <20130403081843.GC14384@dhcp22.suse.cz>
In-Reply-To: <20130403081843.GC14384@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

On 04/03/2013 12:18 PM, Michal Hocko wrote:
> Dang. You are right! Glauber, is there any reason why
> memcg_kmem_mark_dead checks only KMEM_ACCOUNTED_ACTIVE rather than
> KMEM_ACCOUNTED_MASK?
> 
> This all is very confusing to say the least.
Yes, it is.

In kmemcg we need to differentiate between "active" and "activated"
states due to static branches management. This is only important in the
first activation, to make sure the static branches patching are
synchronized.

>From this point on, the ACTIVE flag is the one we should be looking at.

Again, I fully agree it is complicated, but being that a property of the
static branches (we tried to fix it in the static branches itself but
without a lot of luck, since by their design they patch one site at a
time). I tried to overcome this by testing handcrafted errors and
documenting the states as well as I could.

But that not always work *that* well. Maybe we can use the results of
this discussion to document the tear down process a bit more?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
