Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f174.google.com (mail-lb0-f174.google.com [209.85.217.174])
	by kanga.kvack.org (Postfix) with ESMTP id BE63B6B0035
	for <linux-mm@kvack.org>; Mon,  3 Feb 2014 08:00:16 -0500 (EST)
Received: by mail-lb0-f174.google.com with SMTP id l4so5285608lbv.19
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 05:00:15 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id e10si10346905laa.11.2014.02.03.05.00.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Feb 2014 05:00:14 -0800 (PST)
Message-ID: <52EF92DA.1060607@parallels.com>
Date: Mon, 3 Feb 2014 17:00:10 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/8] memcg: export kmemcg cache id via cgroup fs
References: <cover.1391356789.git.vdavydov@parallels.com> <570a97e4dfaded0939a9ddbea49055019dcc5803.1391356789.git.vdavydov@parallels.com> <alpine.DEB.2.02.1402022219101.10847@chino.kir.corp.google.com> <52EF3DBF.3000404@parallels.com> <alpine.DEB.2.02.1402030250110.31061@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1402030250110.31061@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: akpm@linux-foundation.org, mhocko@suse.cz, penberg@kernel.org, cl@linux.com, glommer@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@openvz.org

On 02/03/2014 03:04 PM, David Rientjes wrote:
> On Mon, 3 Feb 2014, Vladimir Davydov wrote:
>
>> AFAIU, cgroup identifiers dumped on oom (cgroup paths, currently) and
>> memcg slab cache names serve for different purposes.
> Sure, you may dump the name for a number of legitimate reasons, but the 
> problem still exists that it's difficult to determine what memcg is being 
> referenced without a flat hierarchy and unique memcg names for all 
> children.
>
>> The point is oom is
>> a perfectly normal situation for the kernel, and info dumped to dmesg is
>> for admin to find out the cause of the problem (a greedy user or
>> cgroup).
> Hmm, so if we hand out top-level memcgs to individual jobs or users, like 
> our userspace does, and they are able to configure their child memcgs as 
> they wish, and then they or the admin finds in the kernel log that a 
> memory hog was killed from the memcg with the perfectly anonymous memcg 
> name of "memcg", how do we determine what job or user triggered that kill?  
> User id is not going to be conclusive in a production environment with 
> shared user accounts.
>
>> On the other hand, slab cache names are dumped to dmesg only on
>> extraordinary situations - like bugs in slab implementation, or double
>> free, or detected memory leaks - where we usually do not need the name
>> of the memcg that triggered the problem, because the bug is likely to be
>> in the kernel subsys using the cache.
> There's certainly overlap here since slab leaks triggered by a particular 
> workload, perhaps by usage of a particular syscall, can occur and cause 
> oom killing but the problem remains that neither the memcg name nor the 
> slab cache name may be conclusive to determine what job or user triggered 
> the issue.  That's why we make strict demands that memcg names are always 
> unique and encode several key values to identify the user and job and we 
> don't rely on the parent.
>
> I can also see the huge maintenance burden it would be to keep around a 
> mapping of kmem ids to {user, job} pairs just in case we later identify a 
> problem and in 99% of the cases would be just wasted storage.
>
>> Plus, the names are exported to
>> sysfs in case of slub, again for debugging purposes, AFAIK. So IMO the
>> use cases for oom vs slab names are completely different - information
>> vs debugging - and I want to export kmem.id only for the ability of
>> debugging kmemcg and slab subsystems.
>>
> Eeek, I'm not sure I agree.  I've often found that reproducing rare slab 
> issues is very difficult without knowledge of the workload so that I can 
> reproduce it.  Whereas X is a very large number of machines and we see 
> this issue on 0.0001% of X machines, I would be required to enable this 
> "debugging" aid unconditionally to ever be able to map the stored kmem id 
> back to a user and job, that mapping would be extremely costly to 
> maintain, and we've gained nothing if we had already demanded that 
> userspace identify their memcg names with unique identifiers regardless of 
> where they are in the hierarchy.

I see your point, and it sounds quite reasonable to me. So I guess I'll
drop the patch removing the cgroup name part from slab cache names
(patch 2) and resend.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
