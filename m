Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id C3DA26B0081
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 20:01:24 -0400 (EDT)
Received: by vbbey12 with SMTP id ey12so1278320vbb.14
        for <linux-mm@kvack.org>; Fri, 27 Apr 2012 17:01:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALWz4ixHGCqfWh1U+JyiJWTkGmCDtXQy1vbHRjrHaU_pOgGuBw@mail.gmail.com>
References: <4F9A327A.6050409@jp.fujitsu.com>
	<4F9A359C.10107@jp.fujitsu.com>
	<CALWz4ixHGCqfWh1U+JyiJWTkGmCDtXQy1vbHRjrHaU_pOgGuBw@mail.gmail.com>
Date: Sat, 28 Apr 2012 09:01:23 +0900
Message-ID: <CABEgKgpCyWhe1KMgcF7ob0myzcCypNbw5SebhVpSX_Xaz7yOBw@mail.gmail.com>
Subject: Re: [RFC][PATCH 5/9 v2] move charges to root at rmdir if
 use_hierarchy is unset
From: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux Kernel <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Frederic Weisbecker <fweisbec@gmail.com>, Glauber Costa <glommer@parallels.com>, Tejun Heo <tj@kernel.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>

On Sat, Apr 28, 2012 at 4:12 AM, Ying Han <yinghan@google.com> wrote:
> On Thu, Apr 26, 2012 at 10:58 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> Now, at removal of cgroup, ->pre_destroy() is called and move charges
>> to the parent cgroup. A major reason of -EBUSY returned by ->pre_destroy=
()
>> is that the 'moving' hits parent's resource limitation. It happens only
>> when use_hierarchy=3D0. This was a mistake of original design.(it's me..=
.)
>
> Nice patch, i can see how broken it is now with use_hierarchy=3D0...
>
> nitpick on the documentation below:
>
>>
>> Considering use_hierarchy=3D0, all cgroups are treated as flat. So, no o=
ne
>> cannot justify moving charges to parent...parent and children are in
>> flat configuration, not hierarchical.
>>
>> This patch modifes to move charges to root cgroup at rmdir/force_empty
>> if use_hierarchy=3D=3D0. This will much simplify rmdir() and reduce erro=
r
>> in ->pre_destroy.
>>
>> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> ---
>> =A0Documentation/cgroups/memory.txt | =A0 12 ++++++----
>> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 39 +++++++++=
++++------------------------
>> =A02 files changed, 21 insertions(+), 30 deletions(-)
>>
>> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/me=
mory.txt
>> index 54c338d..82ce1ef 100644
>> --- a/Documentation/cgroups/memory.txt
>> +++ b/Documentation/cgroups/memory.txt
>> @@ -393,14 +393,14 @@ cgroup might have some charge associated with it, =
even though all
>> =A0tasks have migrated away from it. (because we charge against pages, n=
ot
>> =A0against tasks.)
>>
>> -Such charges are freed or moved to their parent. At moving, both of RSS
>> -and CACHES are moved to parent.
>> -rmdir() may return -EBUSY if freeing/moving fails. See 5.1 also.
>> +Such charges are freed or moved to their parent if use_hierarchy=3D1.
>> +if use_hierarchy=3D0, the charges will be moved to root cgroup.
>
> It is more clear that we move the stats to root (if use_hierarchy=3D=3D0)
> or parent (if use_hierarchy=3D=3D1), and no change on the charge except
> uncharging from the child.
>

Seems nicer. I'll use your text in next ver.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
