Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id BA99E6B0033
	for <linux-mm@kvack.org>; Fri, 14 Jun 2013 12:16:58 -0400 (EDT)
Message-ID: <51BB41EF.7080508@redhat.com>
Date: Fri, 14 Jun 2013 12:16:47 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/7] mm: remove ZONE_RECLAIM_LOCKED
References: <1370445037-24144-1-git-send-email-aarcange@redhat.com> <1370445037-24144-2-git-send-email-aarcange@redhat.com> <20130606090430.GC1936@suse.de> <51B0C8D8.7070708@redhat.com>
In-Reply-To: <51B0C8D8.7070708@redhat.com>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>

On 06/06/2013 01:37 PM, Rik van Riel wrote:
> On 06/06/2013 05:04 AM, Mel Gorman wrote:
>> On Wed, Jun 05, 2013 at 05:10:31PM +0200, Andrea Arcangeli wrote:
>>> Zone reclaim locked breaks zone_reclaim_mode=1. If more than one
>>> thread allocates memory at the same time, it forces a premature
>>> allocation into remote NUMA nodes even when there's plenty of clean
>>> cache to reclaim in the local nodes.
>>>
>>> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
>>
>> Be aware that after this patch is applied that it is possible to have a
>> situation like this
>>
>> 1. 4 processes running on node 1
>> 2. Each process tries to allocate 30% of memory
>> 3. Each process reads the full buffer in a loop (stupid, just an example)
>>
>> In this situation the processes will continually interfere with each
>> other until one of them gets migrated to another zone by the scheduler.
>
> This is a very good point.
>
> Andrea, I suspect we will need some kind of safeguard against
> this problem.

Never mind me.

In __zone_reclaim we set the flags in swap_control so
we never unmap pages or swap pages out at all by
default, so this should not be an issue at all.

In order to get the problem illustrated above, the
user will have to enable RECLAIM_SWAP through sysfs
manually.

The series looks fine as is.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
