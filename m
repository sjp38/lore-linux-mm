Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 035B66B0005
	for <linux-mm@kvack.org>; Mon, 13 Aug 2018 05:31:03 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id m2-v6so13215220ioc.22
        for <linux-mm@kvack.org>; Mon, 13 Aug 2018 02:31:02 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t23-v6sor5345506iob.328.2018.08.13.02.31.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 13 Aug 2018 02:31:01 -0700 (PDT)
Subject: Re: [BUG] mm: truncate: a possible sleep-in-atomic-context bug in
 truncate_exceptional_pvec_entries()
References: <f863cf8d-615f-c622-812a-a6370efe757b@gmail.com>
 <20180813085635.GA8927@quack2.suse.cz>
From: Jia-Ju Bai <baijiaju1990@gmail.com>
Message-ID: <91c44d76-ff62-7cdc-3f78-e0c3acc58637@gmail.com>
Date: Mon, 13 Aug 2018 17:30:55 +0800
MIME-Version: 1.0
In-Reply-To: <20180813085635.GA8927@quack2.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: akpm@linux-foundation.org, mgorman@techsingularity.net, ak@linux.intel.com, mawilcox@microsoft.com, viro@zeniv.linux.org.uk, ross.zwisler@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>



On 2018/8/13 16:56, Jan Kara wrote:
> Hi,
>
> On Mon 13-08-18 11:10:23, Jia-Ju Bai wrote:
>> The kernel may sleep with holding a spinlock.
>>
>> The function call paths (from bottom to top) in Linux-4.16 are:
>>
>> [FUNC] schedule
>> fs/dax.c, 259: schedule in get_unlocked_mapping_entry
>> fs/dax.c, 450: get_unlocked_mapping_entry in __dax_invalidate_mapping_entry
>> fs/dax.c, 471: __dax_invalidate_mapping_entry in dax_delete_mapping_entry
>> mm/truncate.c, 97: dax_delete_mapping_entry in
>> truncate_exceptional_pvec_entries
>> mm/truncate.c, 82: spin_lock_irq in truncate_exceptional_pvec_entries
>>
>> I do not find a good way to fix, so I only report.
>> This is found by my static analysis tool (DSAC).
> Thanks for report but this is a false positive. Note that the lock is
> acquired only if we are not operating on DAX mapping but we can get to
> dax_delete_mapping_entry() only if we are operating on DAX mapping.

Thanks for your reply :)
My tool does not well check the path condition here...
Sorry for this false report.


Best wishes,
Jia-Ju Bai
