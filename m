Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3AFE36B6DCA
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 03:40:55 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id s50so7806628edd.11
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 00:40:55 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l37sor8889057edb.2.2018.12.04.00.40.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Dec 2018 00:40:53 -0800 (PST)
Date: Tue, 4 Dec 2018 08:40:52 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm/alloc: fallback to first node if the wanted node
 offline
Message-ID: <20181204084052.gpwwlnp6n2zehjy5@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <1543892757-4323-1-git-send-email-kernelfans@gmail.com>
 <20181204072251.GT31738@dhcp22.suse.cz>
 <CAFgQCTv56drDBx-sTr6KdeQNKJnojG3g_a-k8wKe_q2y9w9NtA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFgQCTv56drDBx-sTr6KdeQNKJnojG3g_a-k8wKe_q2y9w9NtA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pingfan Liu <kernelfans@gmail.com>
Cc: mhocko@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Bjorn Helgaas <bhelgaas@google.com>, Jonathan Cameron <Jonathan.Cameron@huawei.com>

On Tue, Dec 04, 2018 at 04:20:32PM +0800, Pingfan Liu wrote:
>On Tue, Dec 4, 2018 at 3:22 PM Michal Hocko <mhocko@kernel.org> wrote:
>>
>> On Tue 04-12-18 11:05:57, Pingfan Liu wrote:
>> > During my test on some AMD machine, with kexec -l nr_cpus=x option, the
>> > kernel failed to bootup, because some node's data struct can not be allocated,
>> > e.g, on x86, initialized by init_cpu_to_node()->init_memory_less_node(). But
>> > device->numa_node info is used as preferred_nid param for
>> > __alloc_pages_nodemask(), which causes NULL reference
>> >   ac->zonelist = node_zonelist(preferred_nid, gfp_mask);
>> > This patch tries to fix the issue by falling back to the first online node,
>> > when encountering such corner case.
>>
>> We have seen similar issues already and the bug was usually that the
>> zonelists were not initialized yet or the node is completely bogus.
>> Zonelists should be initialized by build_all_zonelists quite early so I
>> am wondering whether the later is the case. What is the actual node
>> number the device is associated with?
>>
>The device's node num is 2. And in my case, I used nr_cpus param. Due
>to init_cpu_to_node() initialize all the possible node.  It is hard
>for me to figure out without this param, how zonelists is accessed
>before page allocator works.

If my understanding is correct, we can't do page alloc before zonelist
is initialized.

I guess Michal's point is to figure out this reason.

>
>> Your patch is not correct btw, because we want to fallback into the node in
>> the distance order rather into the first online node.
>> --
>What about this:
>+extern int find_next_best_node(int node, nodemask_t *used_node_mask);
>+
> /*
>  * We get the zone list from the current node and the gfp_mask.
>  * This zone list contains a maximum of MAXNODES*MAX_NR_ZONES zones.
>@@ -453,6 +455,11 @@ static inline int gfp_zonelist(gfp_t flags)
>  */
> static inline struct zonelist *node_zonelist(int nid, gfp_t flags)
> {
>+       if (unlikely(!node_online(nid))) {
>+               nodemask_t used_mask;
>+               nodes_complement(used_mask, node_online_map);
>+               nid = find_next_best_node(nid, &used_mask);
>+       }
>        return NODE_DATA(nid)->node_zonelists + gfp_zonelist(flags);
> }
>
>I just finished the compiling, not test it yet, since the machine is
>not on hand yet. It needs some time to get it again.
>
>Thanks,
>Pingfan

-- 
Wei Yang
Help you, Help me
