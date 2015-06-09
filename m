Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8F64B6B0032
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 04:26:48 -0400 (EDT)
Received: by pacyx8 with SMTP id yx8so9002305pac.2
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 01:26:48 -0700 (PDT)
Received: from e23smtp04.au.ibm.com (e23smtp04.au.ibm.com. [202.81.31.146])
        by mx.google.com with ESMTPS id y3si7889735pdq.207.2015.06.09.01.26.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Tue, 09 Jun 2015 01:26:47 -0700 (PDT)
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <raghavendra.kt@linux.vnet.ibm.com>;
	Tue, 9 Jun 2015 18:26:42 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 9228A3578048
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 18:26:36 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t598QSvf41222338
	for <linux-mm@kvack.org>; Tue, 9 Jun 2015 18:26:36 +1000
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t598Q3bo012008
	for <linux-mm@kvack.org>; Tue, 9 Jun 2015 18:26:03 +1000
Message-ID: <5576A32B.40008@linux.vnet.ibm.com>
Date: Tue, 09 Jun 2015 13:56:19 +0530
From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 0/4] idle memory tracking
References: <cover.1431437088.git.vdavydov@parallels.com> <CAC4Lta1isOa+OK7mqCDjL+aV1j=mXBA8p5xnrMEMj+jy6dRMaw@mail.gmail.com> <20150608123535.d82543cedbb9060612a10113@linux-foundation.org>
In-Reply-To: <20150608123535.d82543cedbb9060612a10113@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vladimir Davydov <vdavydov@parallels.com>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On 06/09/2015 01:05 AM, Andrew Morton wrote:
> On Sun, 7 Jun 2015 11:41:15 +0530 Raghavendra KT <raghavendra.kt@linux.vnet.ibm.com> wrote:
>
>> On Tue, May 12, 2015 at 7:04 PM, Vladimir Davydov
>> <vdavydov@parallels.com> wrote:
>>> Hi,
>>>
>>> This patch set introduces a new user API for tracking user memory pages
>>> that have not been used for a given period of time. The purpose of this
>>> is to provide the userspace with the means of tracking a workload's
>>> working set, i.e. the set of pages that are actively used by the
>>> workload. Knowing the working set size can be useful for partitioning
>>> the system more efficiently, e.g. by tuning memory cgroup limits
>>> appropriately, or for job placement within a compute cluster.
>>>
>>> ---- USE CASES ----
>>>
>>> The unified cgroup hierarchy has memory.low and memory.high knobs, which
>>> are defined as the low and high boundaries for the workload working set
>>> size. However, the working set size of a workload may be unknown or
>>> change in time. With this patch set, one can periodically estimate the
>>> amount of memory unused by each cgroup and tune their memory.low and
>>> memory.high parameters accordingly, therefore optimizing the overall
>>> memory utilization.
>>>
>>
>> Hi Vladimir,
>>
>> Thanks for the patches, I was able test how the series is helpful to determine
>> docker container workingset / idlemem with these patches. (tested on ppc64le
>> after porting to a distro kernel).
>
> And what were the results of your testing?  The more details the
> better, please.
>
>

Hi Andrew,
This is what I had done in my experiment (Theoretical):
1) created a docker container
2)
Ran the python script (example in first patch) provided by Vladimir
to get idle memory in the docker container. This would further help
in analyzing what is the rss docker container would ideally use
and hence we could set the memory limit for the container and we will
know how much we should ideally scale without degrading the performance 
of other containers.

# ~/raghu/idlemmetrack/idlememtrack.py
Setting the idle flag for each page...
Wait until the workload accesses its working set, then press Enter
Counting idle pages..
/sys/fs/cgroup/memory: 9764 KB
[...]
/sys/fs/cgroup/memory/system.slice/docker-[...].scope: 224 K
....

I understand that you might probably want how did the scaling experiment 
with memory limit tuning went after that, but I have not got
that data yet.. :(..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
