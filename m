Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id CECBA90010D
	for <linux-mm@kvack.org>; Fri, 13 May 2011 20:55:23 -0400 (EDT)
Received: from hpaq14.eem.corp.google.com (hpaq14.eem.corp.google.com [172.25.149.14])
	by smtp-out.google.com with ESMTP id p4E0tLme020466
	for <linux-mm@kvack.org>; Fri, 13 May 2011 17:55:21 -0700
Received: from qyk27 (qyk27.prod.google.com [10.241.83.155])
	by hpaq14.eem.corp.google.com with ESMTP id p4E0tI2h027107
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 13 May 2011 17:55:19 -0700
Received: by qyk27 with SMTP id 27so2084097qyk.13
        for <linux-mm@kvack.org>; Fri, 13 May 2011 17:55:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110513182534.bebd904e.kamezawa.hiroyu@jp.fujitsu.com>
References: <1305276473-14780-1-git-send-email-gthelen@google.com> <20110513182534.bebd904e.kamezawa.hiroyu@jp.fujitsu.com>
From: Greg Thelen <gthelen@google.com>
Date: Fri, 13 May 2011 17:54:58 -0700
Message-ID: <BANLkTi=VwDK2G1j3D6vFAf7DEfsknn9oqg@mail.gmail.com>
Subject: Re: [RFC][PATCH v7 00/14] memcg: per cgroup dirty page accounting
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Vivek Goyal <vgoyal@redhat.com>, Dave Chinner <david@fromorbit.com>

On Fri, May 13, 2011 at 2:25 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Fri, 13 May 2011 01:47:39 -0700
> Greg Thelen <gthelen@google.com> wrote:
>
>> This patch series provides the ability for each cgroup to have independe=
nt dirty
>> page usage limits. =A0Limiting dirty memory fixes the max amount of dirt=
y (hard to
>> reclaim) page cache used by a cgroup. =A0This allows for better per cgro=
up memory
>> isolation and fewer ooms within a single cgroup.
>>
>> Having per cgroup dirty memory limits is not very interesting unless wri=
teback
>> is cgroup aware. =A0There is not much isolation if cgroups have to write=
back data
>> from other cgroups to get below their dirty memory threshold.
>>
>> Per-memcg dirty limits are provided to support isolation and thus cross =
cgroup
>> inode sharing is not a priority. =A0This allows the code be simpler.
>>
>> To add cgroup awareness to writeback, this series adds a memcg field to =
the
>> inode to allow writeback to isolate inodes for a particular cgroup. =A0W=
hen an
>> inode is marked dirty, i_memcg is set to the current cgroup. =A0When ino=
de pages
>> are marked dirty the i_memcg field compared against the page's cgroup. =
=A0If they
>> differ, then the inode is marked as shared by setting i_memcg to a speci=
al
>> shared value (zero).
>>
>> Previous discussions suggested that a per-bdi per-memcg b_dirty list was=
 a good
>> way to assoicate inodes with a cgroup without having to add a field to s=
truct
>> inode. =A0I prototyped this approach but found that it involved more com=
plex
>> writeback changes and had at least one major shortcoming: detection of w=
hen an
>> inode becomes shared by multiple cgroups. =A0While such sharing is not e=
xpected to
>> be common, the system should gracefully handle it.
>>
>> balance_dirty_pages() calls mem_cgroup_balance_dirty_pages(), which chec=
ks the
>> dirty usage vs dirty thresholds for the current cgroup and its parents. =
=A0If any
>> over-limit cgroups are found, they are marked in a global over-limit bit=
map
>> (indexed by cgroup id) and the bdi flusher is awoke.
>>
>> The bdi flusher uses wb_check_background_flush() to check for any memcg =
over
>> their dirty limit. =A0When performing per-memcg background writeback,
>> move_expired_inodes() walks per bdi b_dirty list using each inode's i_me=
mcg and
>> the global over-limit memcg bitmap to determine if the inode should be w=
ritten.
>>
>> If mem_cgroup_balance_dirty_pages() is unable to get below the dirty pag=
e
>> threshold writing per-memcg inodes, then downshifts to also writing shar=
ed
>> inodes (i_memcg=3D0).
>>
>> I know that there is some significant writeback changes associated with =
the
>> IO-less balance_dirty_pages() effort. =A0I am not trying to derail that,=
 so this
>> patch series is merely an RFC to get feedback on the design. =A0There ar=
e probably
>> some subtle races in these patches. =A0I have done moderate functional t=
esting of
>> the newly proposed features.
>>
>> Here is an example of the memcg-oom that is avoided with this patch seri=
es:
>> =A0 =A0 =A0 # mkdir /dev/cgroup/memory/x
>> =A0 =A0 =A0 # echo 100M > /dev/cgroup/memory/x/memory.limit_in_bytes
>> =A0 =A0 =A0 # echo $$ > /dev/cgroup/memory/x/tasks
>> =A0 =A0 =A0 # dd if=3D/dev/zero of=3D/data/f1 bs=3D1k count=3D1M &
>> =A0 =A0 =A0 =A0 # dd if=3D/dev/zero of=3D/data/f2 bs=3D1k count=3D1M &
>> =A0 =A0 =A0 =A0 # wait
>> =A0 =A0 =A0 [1]- =A0Killed =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dd if=3D/d=
ev/zero of=3D/data/f1 bs=3D1M count=3D1k
>> =A0 =A0 =A0 [2]+ =A0Killed =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dd if=3D/d=
ev/zero of=3D/data/f1 bs=3D1M count=3D1k
>>
>> Known limitations:
>> =A0 =A0 =A0 If a dirty limit is lowered a cgroup may be over its limit.
>>
>
>
> Thank you, I think this should be merged earlier than all other works. Wi=
thout this,
> I think all memory reclaim changes of memcg will do something wrong.
>
> I'll do a brief review today but I'll be busy until Wednesday, sorry.

Thank you.

> In general, I agree with inode->i_mapping->i_memcg, simple 2bytes field a=
nd
> ignoring a special case of shared inode between memcg.

These proposed patches do not optimize for sharing, but the patches do
attempt to handle sharing to ensure forward progress.  The sharing
case I have in mind is where an inode is transferred between memcg
(e.g. if cgroup_a appends to a log file and then cgroup_b appends to
the same file).  While such cases are thought to be somewhat rare for
isolated memcg workloads, they will happen sometimes.  In these
situations I want to make sure that the memcg that is charged for
dirty pages of a shared inode is able to make forward progress to
write dirty pages to drop below the cgroup dirty memory threshold.

The patches try to perform well for cgroups that operate on non-shared
inodes.  If a cgroup has no shared inodes, then that cgroup should not
be punished if other cgroups have shared inodes.

Currently the patches perform the following:
1) when exceeding background limit, wake bdi flusher to write any
inodes of over-limit cgroups.
2) when exceeding foreground limit, write dirty inodes of the
over-limit cgroup.  This will change when integrated with IO-less
balance_dirty_pages().  If unable to make forward progress, also write
shared inodes.

One could argue that step (2) should always consider writing shared
inodes, but I wanted to avoid burdening cgroups that had no shared
inodes with the responsibility of writing dirty shared inodes.

> BTW, IIUC, i_memcg is resetted always when mark_inode_dirty() sets new I_=
DIRTY to
> the flags, right ?

Yes.

> Thanks,
> -Kame

One small bug in this patch series is that per memcg background
writeback does not write shared inode pages.  In the (potentially
common) case where the system dirty memory usage is below the system
background dirty threshold but at least one cgroup is over its
background dirty limit, then per memcg background writeback is queued
for any over-background-threshold cgroups.  In this case background
writeback should be allowed to writeback shared inodes.  The hope is
that writing such inodes has good chance of cleaning the inodes so
they can transition from shared to non-shared.  Such a transition is
good because then the inode will remain unshared until it is written
by multiple cgroup.  This is easy to fix if
wb_check_background_flush() sets shared_inodes=3D1.  I will include this
change in the next version of these patches.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
