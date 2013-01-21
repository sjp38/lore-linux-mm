Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 6467E6B0005
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 03:39:16 -0500 (EST)
Date: Mon, 21 Jan 2013 03:39:07 -0500 (EST)
From: Zhouping Liu <zliu@redhat.com>
Message-ID: <389106003.8637801.1358757547754.JavaMail.root@redhat.com>
In-Reply-To: <4FEE7665.6020409@jp.fujitsu.com>
Subject: Re: memcg: cat: memory.memsw.* : Operation not supported
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Li Zefan <lizefan@huawei.com>, CAI Qian <caiqian@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>



----- Original Message -----
> From: "Kamezawa Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
> To: "Tejun Heo" <tj@kernel.org>
> Cc: "David Rientjes" <rientjes@google.com>, "Michal Hocko" <mhocko@suse.cz>, "Zhouping Liu" <zliu@redhat.com>,
> linux-mm@kvack.org, "Li Zefan" <lizefan@huawei.com>, "CAI Qian" <caiqian@redhat.com>, "LKML"
> <linux-kernel@vger.kernel.org>, "Andrew Morton" <akpm@linux-foundation.org>
> Sent: Saturday, June 30, 2012 11:45:41 AM
> Subject: Re: memcg: cat: memory.memsw.* : Operation not supported
> 
> (2012/06/29 3:31), Tejun Heo wrote:
> > Hello, KAME.
> >
> > On Thu, Jun 28, 2012 at 01:04:16PM +0900, Kamezawa Hiroyuki wrote:
> >>> I still wish it's folded into CONFIG_MEMCG and conditionalized
> >>> just on
> >>> CONFIG_SWAP tho.
> >>>
> >>
> >> In old days, memsw controller was not very stable. So, we devided
> >> the config.
> >> And, it makes size of memory for swap-device double (adds 2bytes
> >> per swapent.)
> >> That is the problem.
> >
> > I see.  Do you think it's now reasonable to drop the separate
> > config
> > option?  Having memcg enabled but swap unaccounted sounds
> > half-broken
> > to me.
> >
> 
> Hmm. Maybe it's ok if we can keep boot option. I'll cook a patch in
> the next week.

Hello Kame and All,

Sorry for so delay to open the thread. (please open the link https://lkml.org/lkml/2012/6/26/547 if you don't remember the topic)

do you have any updates for the issue?

I checked the latest version, if we don't open CONFIG_MEMCG_SWAP_ENABLED(commit c255a458055e changed
CONFIG_CGROUP_MEM_RES_CTLR_SWAP_ENABLED as CONFIG_MEMCG_SWAP_ENABLED), the issue still exist:

[root@dhcp-8-128 ~] cat .config  | grep -i memcg
CONFIG_MEMCG=y
CONFIG_MEMCG_SWAP=y
# CONFIG_MEMCG_SWAP_ENABLED is not set
CONFIG_MEMCG_KMEM=y
[root@dhcp-8-128 ~] uname -r
3.8.0-rc4+
[root@dhcp-8-128 ~] cat memory.memsw.*
cat: memory.memsw.failcnt: Operation not supported
cat: memory.memsw.limit_in_bytes: Operation not supported
cat: memory.memsw.max_usage_in_bytes: Operation not supported
cat: memory.memsw.usage_in_bytes: Operation not supported

As David said, we should not export memory.memsw.* files if we disable CONFIG_MEMCG_SWAP_ENABLED, or return -EINVAL, right?
(please correct me if I'm wrong)

-- 
Thanks,
Zhouping

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
