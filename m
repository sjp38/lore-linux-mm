Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 260E36B0038
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 17:39:23 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id p8so8170108wrh.17
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 14:39:23 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 90sor7462434wrp.84.2017.12.19.14.39.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Dec 2017 14:39:21 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171219214107.GR3919388@devbig577.frc2.facebook.com>
References: <20171219000131.149170-1-shakeelb@google.com> <20171219124908.GS2787@dhcp22.suse.cz>
 <CALvZod5jU9vPoJaf44TVT0_HQpEESiELJU5MD_DDRbcOkPNQbg@mail.gmail.com>
 <20171219152444.GP3919388@devbig577.frc2.facebook.com> <CALvZod5sWWBX69QovOeLBSx9vij7=5cmoSocdTUvh2Uq8=noyQ@mail.gmail.com>
 <20171219173354.GQ3919388@devbig577.frc2.facebook.com> <CALvZod7pbp0fFUPRnC68qdzkCEUg2YTavq6C6OLxqooCU5VeyQ@mail.gmail.com>
 <20171219214107.GR3919388@devbig577.frc2.facebook.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Tue, 19 Dec 2017 14:39:19 -0800
Message-ID: <CALvZod5XRhXc3XrQw50Jw_OpRQB2iCCbgG-NMDCa8xRmGNdLrw@mail.gmail.com>
Subject: Re: [RFC PATCH] mm: memcontrol: memory+swap accounting for cgroup-v2
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Michal Hocko <mhocko@kernel.org>, Li Zefan <lizefan@huawei.com>, Roman Gushchin <guro@fb.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-doc@vger.kernel.org

On Tue, Dec 19, 2017 at 1:41 PM, Tejun Heo <tj@kernel.org> wrote:
> Hello,
>
> On Tue, Dec 19, 2017 at 10:25:12AM -0800, Shakeel Butt wrote:
>> Making the runtime environment, an invariant is very critical to make
>> the management of a job easier whose instances run on different
>> clusters across the world. Some clusters might have different type of
>> swaps installed while some might not have one at all and the
>> availability of the swap can be dynamic (i.e. swap medium outage).
>>
>> So, if users want to run multiple instances of a job across multiple
>> clusters, they should be able to specify the limits of their jobs
>> irrespective of the knowledge of cluster. The best case would be they
>> just submits their jobs without any config and the system figures out
>> the right limit and enforce that. And to figure out the right limit
>> and enforcing it, the consistent memory usage history and consistent
>> memory limit enforcement is very critical.
>
> I'm having a hard time extracting anything concrete from your
> explanation on why memsw is required.  Can you please ELI5 with some
> examples?
>

Suppose a user wants to run multiple instances of a specific job on
different datacenters and s/he has budget of 100MiB for each instance.
The instances are schduled on the requested datacenters and the
scheduler has set the memory limit of those instances to 100MiB. Now,
some datacenters have swap deployed, so, there, let's say, the swap
limit of those instances are set according to swap medium
availability. In this setting the user will see inconsistent memcg OOM
behavior. Some of the instances see OOMs at 100MiB usage (suppose only
anon memory) while some will see OOMs way above 100MiB due to swap.
So, the user is required to know the internal knowledge of datacenters
(like which has swap or not and swap type) and has to set the limits
accordingly and thus increase the chance of config bugs.

Also different types and sizes of swap mediums in data center will
further complicates the configuration. One datacenter might have SSD
as a swap, another might be doing swap on zram and third might be
doing swap on nvdimm. Each can have different size and can be assigned
to jobs differently. So, it is possible that the instances of the same
job might be assigned different swap limit on different datacenters.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
