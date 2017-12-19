Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id D2D0F6B0038
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 10:12:22 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id k44so5946672wre.1
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 07:12:22 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id s26sor4529151wrb.64.2017.12.19.07.12.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Dec 2017 07:12:21 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171219124908.GS2787@dhcp22.suse.cz>
References: <20171219000131.149170-1-shakeelb@google.com> <20171219124908.GS2787@dhcp22.suse.cz>
From: Shakeel Butt <shakeelb@google.com>
Date: Tue, 19 Dec 2017 07:12:19 -0800
Message-ID: <CALvZod5jU9vPoJaf44TVT0_HQpEESiELJU5MD_DDRbcOkPNQbg@mail.gmail.com>
Subject: Re: [RFC PATCH] mm: memcontrol: memory+swap accounting for cgroup-v2
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Roman Gushchin <guro@fb.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-doc@vger.kernel.org

On Tue, Dec 19, 2017 at 4:49 AM, Michal Hocko <mhocko@kernel.org> wrote:
> On Mon 18-12-17 16:01:31, Shakeel Butt wrote:
>> The memory controller in cgroup v1 provides the memory+swap (memsw)
>> interface to account to the combined usage of memory and swap of the
>> jobs. The memsw interface allows the users to limit or view the
>> consistent memory usage of their jobs irrespectibe of the presense of
>> swap on the system (consistent OOM and memory reclaim behavior). The
>> memory+swap accounting makes the job easier for centralized systems
>> doing resource usage monitoring, prediction or anomaly detection.
>>
>> In cgroup v2, the 'memsw' interface was dropped and a new 'swap'
>> interface has been introduced which allows to limit the actual usage of
>> swap by the job. For the systems where swap is a limited resource,
>> 'swap' interface can be used to fairly distribute the swap resource
>> between different jobs. There is no easy way to limit the swap usage
>> using the 'memsw' interface.
>>
>> However for the systems where the swap is cheap and can be increased
>> dynamically (like remote swap and swap on zram), the 'memsw' interface
>> is much more appropriate as it makes swap transparent to the jobs and
>> gives consistent memory usage history to centralized monitoring systems.
>>
>> This patch adds memsw interface to cgroup v2 memory controller behind a
>> mount option 'memsw'. The memsw interface is mutually exclusive with
>> the existing swap interface. When 'memsw' is enabled, reading or writing
>> to 'swap' interface files will return -ENOTSUPP and vice versa. Enabling
>> or disabling memsw through remounting cgroup v2, will only be effective
>> if there are no decendants of the root cgroup.
>>
>> When memsw accounting is enabled then "memory.high" is comapred with
>> memory+swap usage. So, when the allocating job's memsw usage hits its
>> high mark, the job will be throttled by triggering memory reclaim.
>
> From a quick look, this looks like a mess.

The main motivation behind this patch is to convince that memsw has
genuine use-cases. How to provide memsw is still in RFC stage.
Suggestions and comments are welcomed.

> We have agreed to go with
> the current scheme for some good reasons.

Yes I agree, when the swap is a limited resource the current 'swap'
interface should be used to fairly distribute it between different
jobs.

> There are cons/pros for both
> approaches but I am not convinced we should convolute the user API for
> the usecase you describe.
>

Yes, there are pros & cons, therefore we should give users the option
to select the API that is better suited for their use-cases and
environment. Both approaches are not interchangeable. We use memsw
internally for use-cases I mentioned in commit message. This is one of
the main blockers for us to even consider cgroup-v2 for memory
controller.

>> Signed-off-by: Shakeel Butt <shakeelb@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
