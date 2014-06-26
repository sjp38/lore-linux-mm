Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 473B96B0037
	for <linux-mm@kvack.org>; Thu, 26 Jun 2014 00:08:51 -0400 (EDT)
Received: by mail-ig0-f176.google.com with SMTP id c1so259655igq.3
        for <linux-mm@kvack.org>; Wed, 25 Jun 2014 21:08:51 -0700 (PDT)
Received: from mail-ie0-x231.google.com (mail-ie0-x231.google.com [2607:f8b0:4001:c03::231])
        by mx.google.com with ESMTPS id l3si296047igx.12.2014.06.25.21.08.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 25 Jun 2014 21:08:50 -0700 (PDT)
Received: by mail-ie0-f177.google.com with SMTP id tp5so2540962ieb.36
        for <linux-mm@kvack.org>; Wed, 25 Jun 2014 21:08:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140625150318.4355468ab59a5293e870605e@linux-foundation.org>
References: <20140624201606.18273.44270.stgit@zurg>
	<20140624201614.18273.39034.stgit@zurg>
	<20140625150318.4355468ab59a5293e870605e@linux-foundation.org>
Date: Thu, 26 Jun 2014 08:08:50 +0400
Message-ID: <CALYGNiOtO9bV2RJuM_42fc-R_9aHpjkfRxX7V_zy=GBX68UW_A@mail.gmail.com>
Subject: Re: [PATCH 3/3] mm: catch memory commitment underflow
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Jun 26, 2014 at 2:03 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Wed, 25 Jun 2014 00:16:14 +0400 Konstantin Khlebnikov <koct9i@gmail.com> wrote:
>
>> This patch prints warning (if CONFIG_DEBUG_VM=y) when
>> memory commitment becomes too negative.
>>
>> ...
>>
>> --- a/mm/mmap.c
>> +++ b/mm/mmap.c
>> @@ -134,6 +134,12 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
>>  {
>>       unsigned long free, allowed, reserve;
>>
>> +#ifdef CONFIG_DEBUG_VM
>> +     WARN_ONCE(percpu_counter_read(&vm_committed_as) <
>> +                     -(s64)vm_committed_as_batch * num_online_cpus(),
>> +                     "memory commitment underflow");
>> +#endif
>> +
>>       vm_acct_memory(pages);
>
> The changelog doesn't describe the reasons for making the change.
>
> I assume this warning will detect the situation which the previous two
> patches just fixed?

Yep. Otherwise there is no way to validate these bugs, /proc/meminfo
hides negative values.

> Why not use VM_WARN_ON_ONCE()?

This patch is older than this macro.
Previously I've sent it in the last september and it was ignored. Now
I've found it again in my backlog.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
