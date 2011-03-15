Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3A1AC8D003A
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 22:51:52 -0400 (EDT)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id p2F2phHv030635
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 19:51:43 -0700
Received: from qwb8 (qwb8.prod.google.com [10.241.193.72])
	by wpaz29.hot.corp.google.com with ESMTP id p2F2olF9019745
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 19:51:42 -0700
Received: by qwb8 with SMTP id 8so184701qwb.25
        for <linux-mm@kvack.org>; Mon, 14 Mar 2011 19:51:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110315105612.f600a659.kamezawa.hiroyu@jp.fujitsu.com>
References: <1299869011-26152-1-git-send-email-gthelen@google.com>
 <20110311171006.ec0d9c37.akpm@linux-foundation.org> <AANLkTimT-kRMQW3JKcJAZP4oD3EXuE-Bk3dqumH_10Oe@mail.gmail.com>
 <20110315105612.f600a659.kamezawa.hiroyu@jp.fujitsu.com>
From: Greg Thelen <gthelen@google.com>
Date: Mon, 14 Mar 2011 19:51:22 -0700
Message-ID: <AANLkTineM7M1R6fVFJe0ax-DN=_Rnb+7Cmk5HTH0D+Na@mail.gmail.com>
Subject: Re: [PATCH v6 0/9] memcg: per cgroup dirty page accounting
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Chad Talbott <ctalbott@google.com>, Justin TerAvest <teravest@google.com>, Vivek Goyal <vgoyal@redhat.com>

On Mon, Mar 14, 2011 at 6:56 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Mon, 14 Mar 2011 11:29:17 -0700
> Greg Thelen <gthelen@google.com> wrote:
>
>> On Fri, Mar 11, 2011 at 5:10 PM, Andrew Morton
>
>> My rational for pursuing bdi writeback was I/O locality. =A0I have heard=
 that
>> per-page I/O has bad locality. =A0Per inode bdi-style writeback should h=
ave better
>> locality.
>>
>> My hunch is the best solution is a hybrid which uses a) bdi writeback wi=
th a
>> target memcg filter and b) using the memcg lru as a fallback to identify=
 the bdi
>> that needed writeback. =A0I think the part a) memcg filtering is likely =
something
>> like:
>> =A0http://marc.info/?l=3Dlinux-kernel&m=3D129910424431837
>>
>> The part b) bdi selection should not be too hard assuming that page-to-m=
apping
>> locking is doable.
>>
>
> For now, I like b).
>
>> An alternative approach is to bind each inode to exactly one cgroup (pos=
sibly
>> the root cgroup). =A0Both the cache page allocations and dirtying charge=
s would be
>> accounted to the i_cgroup. =A0With this approach there is no foreign dir=
tier issue
>> because all pages are in a single cgroup. =A0I find this undesirable bec=
ause the
>> first memcg to touch an inode is charged for all pages later cached even=
 by
>> other memcg.
>>
>
> I don't think 'foreign dirtier' is a big problem. When program does write=
(),
> the file to be written is tend to be under control of the application in
> the cgroup. I don't think 'written file' is shared between several cgroup=
s,
> typically. But /var/log/messages is a shared one ;)
>
> But I know some other OSs has 'group for file cache'. I'll not nack if yo=
u
> propose such patch. Maybe there are some guys who want to limit the amoun=
t of
> file cache.
>
>
>
>> When a page is allocated it is charged to the current task's memcg. =A0W=
hen a
>> memcg page is later marked dirty the dirty charge is billed to the memcg=
 from
>> the original page allocation. =A0The billed memcg may be different than =
the
>> dirtying task's memcg.
>>
> yes.
>
>> After a rate limited number of file backed pages have been dirtied,
>> balance_dirty_pages() is called to enforce dirty limits by a) throttling
>> production of more dirty pages by current and b) queuing background writ=
eback to
>> the current bdi.
>>
>> balance_dirty_pages() receives a mapping and page count, which indicate =
what may
>> have been dirtied and the max number of pages that may have been dirtied=
. =A0Due
>> to per cpu rate limiting and batching (when nr_pages_dirtied > 0),
>> balance_dirty_pages() does not know which memcg were charged for recentl=
y dirty
>> pages.
>>
>> I think both bdi and system limits have the same issue in that a bdi may=
 be
>> pushed over its dirty limit but not immediately checked due to rate limi=
ts. =A0If
>> future dirtied pages are backed by different bdi, then future
>> balance_dirty_page() calls will check the second, compliant bdi ignoring=
 the
>> first, over-limit bdi. =A0The safety net is that the system wide limits =
are also
>> checked in balance_dirty_pages. =A0However, per bdi writeback is employe=
d in this
>> situation.
>>
>> Note: This memcg foreign dirtier issue does not make it any more likely =
that a
>> memcg is pushed above its usage limit (limit_in_bytes). =A0The only limi=
t with
>> this weak contract is the dirty limit.
>>
>> For reference, this issue was touch on in
>> http://marc.info/?l=3Dlinux-mm&m=3D128840780125261
>>
>> There are ways to handle this issue (my preferred option is option #1).
>>
>> 1) keep a (global?) foreign_dirtied_memcg list of memcg that were recent=
ly
>> =A0 charged for dirty pages by tasks outside of memcg. =A0When a memcg d=
irty page
>> =A0 count is elevated, the page's memcg would be queued to the list if c=
urrent's
>> =A0 memcg does not match the pages cgroup. =A0mem_cgroup_balance_dirty_p=
ages()
>> =A0 would balance the current memcg and each memcg it dequeues from this=
 list.
>> =A0 This should be a straightforward fix.
>>
>
> Can you implement this in an efficient way ? (without taking any locks ?)
> It seems cost > benefit.

I am not sure either.  But if we are willing to defer addressing the
foreign dirtier issue, then we can avoid this for now.

>> 2) When pages are dirtied, migrate them to the current task's memcg.
>> =A0 mem_cgroup_balance_dirty_pages would then have a better chance at se=
eing all
>> =A0 pages dirtied by the current operation. =A0This is still not perfect=
 solution
>> =A0 due to rate limiting. =A0This also is bad because such a migration w=
ould
>> =A0 involve charging and possibly memcg direct reclaim because the desti=
nation
>> =A0 memcg may be at its memory usage limit. =A0Doing all of this in
>> =A0 account_page_dirtied() seems like trouble, so I do not like this app=
roach.
>>
>
> I think this cannot be implemented in an efficnent way.
>
>
>
>> 3) Pass in some context which is represents a set of pages recently dirt=
ied into
>> =A0 [mem_cgroup]_balance_dirty_pages. =A0What would be a good context to=
 collect
>> =A0 the set of memcg that should be balanced?
>> =A0 - an extra passed in parameter - yuck.
>> =A0 - address_space extension - does not feel quite right because addres=
s space
>> =A0 =A0 is not a io context object, I presume it can be shared by concur=
rent
>> =A0 =A0 threads.
>> =A0 - something hanging on current. =A0Are there cases where pages becom=
e dirty
>> =A0 =A0 that are not followed by a call to balance dirty pages Note: thi=
s option
>> =A0 =A0 (3) is not a good idea because rate limiting make dirty limit en=
forcement
>> =A0 =A0 an inexact science. =A0There is no guarantee that a caller will =
have context
>> =A0 =A0 describing the pages (or bdis) recently dirtied.
>>
>
> I'd like to have an option =A0'cgroup only for file cache' rather than ad=
ding more
> hooks and complicated operations.
>
> But, if we need to record 'who dirtied ?' information, record it in page_=
cgroup
> or radix-tree and do filtering is what I can consider, now.
> In this case, some tracking information will be required to be stored int=
o
> struct inode, too.
>
>
> How about this ?
>
> =A01. record 'who dirtied memcg' into page_cgroup or radix-tree.
> =A0 I prefer recording in radix-tree rather than using more field in page=
_cgroup.
> =A02. bdi-writeback does some extra queueing operation per memcg.
> =A0 find a page, check 'who dirtied', enqueue it(using page_cgroup or lis=
t of pagevec)
> =A03. writeback it's own queue.(This can be done before 2. if cgroup has =
queue, already)
> =A04. Some GC may be required...
>
> Thanks,
> -Kame
>
>

The foreign dirtier issue is all about identifying the memcg (or
possibly multiple bdi) that need balancing.    If the foreign dirtier
issue is not important then we can focus on identifying inodes to
writeback that will lower the current's memcg dirty usage.  I am fine
ignoring the foreign dirtier issue for now and breaking the problem
into smaller pieces.

I think this can be done with out any additional state.  Can just scan
the memcg lru to find dirty file pages and thus inodes to pass to
sync_inode(), or some other per-inode writeback routine?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
