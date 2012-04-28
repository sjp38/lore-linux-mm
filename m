Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id C74F46B0044
	for <linux-mm@kvack.org>; Sat, 28 Apr 2012 05:31:39 -0400 (EDT)
Received: by vcbfy7 with SMTP id fy7so1504902vcb.14
        for <linux-mm@kvack.org>; Sat, 28 Apr 2012 02:31:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120428020003.GA26573@mtj.dyndns.org>
References: <4F9A327A.6050409@jp.fujitsu.com>
	<4F9A36DE.30301@jp.fujitsu.com>
	<20120427204035.GN26595@google.com>
	<CABEgKgrJ68wU-L17zwN4_htX948TNFnLVgts=hFeY7QG3etwCA@mail.gmail.com>
	<20120428020003.GA26573@mtj.dyndns.org>
Date: Sat, 28 Apr 2012 18:31:38 +0900
Message-ID: <CABEgKgpPXPu3L6oS6+2+dZmcPS=t-ZR7PnCvm0mo8UFeXPHDog@mail.gmail.com>
Subject: Re: [RFC][PATCH 8/9 v2] cgroup: avoid creating new cgroup under a
 cgroup being destroyed
From: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux Kernel <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Frederic Weisbecker <fweisbec@gmail.com>, Glauber Costa <glommer@parallels.com>, Han Ying <yinghan@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>

On Sat, Apr 28, 2012 at 11:00 AM, Tejun Heo <tj@kernel.org> wrote:
> Hi, KAME.
>
> On Sat, Apr 28, 2012 at 09:20:52AM +0900, Hiroyuki Kamezawa wrote:
>> What I thought was...
>> Assume a memory cgoup A, with use_hierarchy=3D=3D1.
>>
>> 1. =A0thread:0 =A0 start calling pre->destroy of cgroup A
>> 2. =A0thread:0 =A0 it sometimes calls cond_resched or other sleep functi=
ons.
>> 3. =A0thread:1 =A0 create a cgroup B under "A"
>> 4. =A0thread:1 =A0 attach a thread X to cgroup A/B
>> 5. =A0res_counter of A charged up. but pre_destroy() can't find what hap=
pens
>> =A0 =A0 because it scans LRU of A.
>>
>> So, we have -EBUSY now. I considered some options to fix this.
>>
>> option 1) just return 0 instead of -EBUSY when pre_destroy() finds a
>> task or a child.
>>
>> There is a race....even if we return 0 here and expects cgroup code
>> can catch it,
>> the thread or a child we found may be moved to other cgroup before we ch=
eck it
>> in cgroup's final check.
>> In that case, the cgroup will be freed before full-ack of
>> pre_destory() and the charges
>> will be lost.
>
> So, cgroup code won't proceed with rmdir if children are created
> inbetween and note that the race condition of lost charge you
> described above existed before this change - ie. new cgroup could be
> created after pre_destroy() is complete.
>
> The current cgroup rmdir code is transitional. =A0It has to support both
> retrying and non-retrying pre_destroy()s and that means we can't mark
> the cgroup DEAD before starting invoking pre_destroy(); however, we
> can do that once memcg's pre_destroy() is converted which will also
> remove all the WAIT_ON_RMDIR mechanism and the above described race.
>
> There really isn't much point in trying to make the current cgroup
> rmdir behave perfectly when the next step is removing all the fixed up
> parts.
>
> So, IMHO, just making pre_destroy() clean up its own charges and
> always returning 0 is enough. =A0There's no need to fix up old
> non-critical race condition at this point in the patch stream. =A0cgroup
> rmdir simplification will make them disappear anyway.
>
So, hmm, ok. I'll drop patch 7 & 8. memcg may return -EBUSY in very very
race case but users will not see it in the most case.
I'll fix limit, move-charge and use_hierarchy problem first.
Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
