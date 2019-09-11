Return-Path: <SRS0=IwQ2=XG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2580EC5ACAE
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 15:16:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D901C206A5
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 15:16:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D901C206A5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7D0126B0279; Wed, 11 Sep 2019 11:16:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 75A466B027A; Wed, 11 Sep 2019 11:16:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 620AC6B027B; Wed, 11 Sep 2019 11:16:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0153.hostedemail.com [216.40.44.153])
	by kanga.kvack.org (Postfix) with ESMTP id 39CC76B0279
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 11:16:16 -0400 (EDT)
Received: from smtpin10.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id E927C81FB
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 15:16:15 +0000 (UTC)
X-FDA: 75922990710.10.cats27_8df050b35a20c
X-HE-Tag: cats27_8df050b35a20c
X-Filterd-Recvd-Size: 6451
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf34.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 15:16:15 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 78FB8B7DF;
	Wed, 11 Sep 2019 15:16:13 +0000 (UTC)
Date: Wed, 11 Sep 2019 17:16:12 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Shakeel Butt <shakeelb@google.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Thomas Lindroth <thomas.lindroth@gmail.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Subject: Re: [PATCH] memcg, kmem: do not fail __GFP_NOFAIL charges
Message-ID: <20190911151612.GI4023@dhcp22.suse.cz>
References: <31131c2d-a936-8bbf-e58d-a3baaa457340@gmail.com>
 <20190906125608.32129-1-mhocko@kernel.org>
 <CALvZod5w72jH8fJSFRaw7wgQTnzF6nb=+St-sSXVGSiG6Bs3Lg@mail.gmail.com>
 <20190909112245.GH27159@dhcp22.suse.cz>
 <20190911120002.GQ4023@dhcp22.suse.cz>
 <20190911073740.b5c40cd47ea845884e25e265@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190911073740.b5c40cd47ea845884e25e265@linux-foundation.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 11-09-19 07:37:40, Andrew Morton wrote:
> On Wed, 11 Sep 2019 14:00:02 +0200 Michal Hocko <mhocko@kernel.org> wrote:
> 
> > On Mon 09-09-19 13:22:45, Michal Hocko wrote:
> > > On Fri 06-09-19 11:24:55, Shakeel Butt wrote:
> > [...]
> > > > I wonder what has changed since
> > > > <http://lkml.kernel.org/r/20180525185501.82098-1-shakeelb@google.com/>.
> > > 
> > > I have completely forgot about that one. It seems that we have just
> > > repeated the same discussion again. This time we have a poor user who
> > > actually enabled the kmem limit.
> > > 
> > > I guess there was no real objection to the change back then. The primary
> > > discussion revolved around the fact that the accounting will stay broken
> > > even when this particular part was fixed. Considering this leads to easy
> > > to trigger crash (with the limit enabled) then I guess we should just
> > > make it less broken and backport to stable trees and have a serious
> > > discussion about discontinuing of the limit. Start by simply failing to
> > > set any limit in the current upstream kernels.
> > 
> > Any more concerns/objections to the patch? I can add a reference to your
> > earlier post Shakeel if you want or to credit you the way you prefer.
> > 
> > Also are there any objections to start deprecating process of kmem
> > limit? I would see it in two stages
> > - 1st warn in the kernel log
> > 	pr_warn("kmem.limit_in_bytes is deprecated and will be removed.
> > 	        "Please report your usecase to linux-mm@kvack.org if you "
> > 		"depend on this functionality."
> 
> pr_warn_once() :)
> 
> > - 2nd fail any write to kmem.limit_in_bytes
> > - 3rd remove the control file completely
> 
> Sounds good to me.

Here we go

From 512822e551fe2960040c23b12c7b27a5fdab9013 Mon Sep 17 00:00:00 2001
From: Michal Hocko <mhocko@suse.com>
Date: Wed, 11 Sep 2019 17:02:33 +0200
Subject: [PATCH] memcg, kmem: deprecate kmem.limit_in_bytes

Cgroup v1 memcg controller has exposed a dedicated kmem limit to users
which turned out to be really a bad idea because there are paths which
cannot shrink the kernel memory usage enough to get below the limit
(e.g. because the accounted memory is not reclaimable). There are cases
when the failure is even not allowed (e.g. __GFP_NOFAIL). This means
that the kmem limit is in excess to the hard limit without any way to
shrink and thus completely useless. OOM killer cannot be invoked to
handle the situation because that would lead to a premature oom killing.

As a result many places might see ENOMEM returning from kmalloc and
result in unexpected errors. E.g. a global OOM killer when there is a
lot of free memory because ENOMEM is translated into VM_FAULT_OOM in #PF
path and therefore pagefault_out_of_memory would result in OOM killer.

Please note that the kernel memory is still accounted to the overall
limit along with the user memory so removing the kmem specific limit
should still allow to contain kernel memory consumption. Unlike the kmem
one, though, it invokes memory reclaim and targeted memcg oom killing if
necessary.

Start the deprecation process by crying to the kernel log. Let's see
whether there are relevant usecases and simply return to EINVAL in the
second stage if nobody complains in few releases.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 Documentation/admin-guide/cgroup-v1/memory.rst | 3 +++
 mm/memcontrol.c                                | 3 +++
 2 files changed, 6 insertions(+)

diff --git a/Documentation/admin-guide/cgroup-v1/memory.rst b/Documentation/admin-guide/cgroup-v1/memory.rst
index 41bdc038dad9..e53fc2f31549 100644
--- a/Documentation/admin-guide/cgroup-v1/memory.rst
+++ b/Documentation/admin-guide/cgroup-v1/memory.rst
@@ -87,6 +87,9 @@ Brief summary of control files.
 				     node
 
  memory.kmem.limit_in_bytes          set/show hard limit for kernel memory
+                                     This knob is deprecated it shouldn't be
+                                     used. It is planned to be removed in
+                                     a foreseeable future.
  memory.kmem.usage_in_bytes          show current kernel memory allocation
  memory.kmem.failcnt                 show the number of kernel memory usage
 				     hits limits
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e18108b2b786..113969bc57e8 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3518,6 +3518,9 @@ static ssize_t mem_cgroup_write(struct kernfs_open_file *of,
 			ret = mem_cgroup_resize_max(memcg, nr_pages, true);
 			break;
 		case _KMEM:
+			pr_warn_once("kmem.limit_in_bytes is deprecated and will be removed. "
+				     "Please report your usecase to linux-mm@kvack.org if you "
+				     "depend on this functionality.\n");
 			ret = memcg_update_kmem_max(memcg, nr_pages);
 			break;
 		case _TCP:
-- 
2.20.1


-- 
Michal Hocko
SUSE Labs

