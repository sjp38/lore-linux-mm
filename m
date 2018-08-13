Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2D7466B0007
	for <linux-mm@kvack.org>; Mon, 13 Aug 2018 04:56:39 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id g5-v6so6988831pgq.5
        for <linux-mm@kvack.org>; Mon, 13 Aug 2018 01:56:39 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z19-v6si16157596pgi.388.2018.08.13.01.56.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Aug 2018 01:56:37 -0700 (PDT)
Date: Mon, 13 Aug 2018 10:56:35 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [BUG] mm: truncate: a possible sleep-in-atomic-context bug in
 truncate_exceptional_pvec_entries()
Message-ID: <20180813085635.GA8927@quack2.suse.cz>
References: <f863cf8d-615f-c622-812a-a6370efe757b@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f863cf8d-615f-c622-812a-a6370efe757b@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jia-Ju Bai <baijiaju1990@gmail.com>
Cc: akpm@linux-foundation.org, jack@suse.cz, mgorman@techsingularity.net, ak@linux.intel.com, mawilcox@microsoft.com, viro@zeniv.linux.org.uk, ross.zwisler@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>

Hi,

On Mon 13-08-18 11:10:23, Jia-Ju Bai wrote:
> The kernel may sleep with holding a spinlock.
> 
> The function call paths (from bottom to top) in Linux-4.16 are:
> 
> [FUNC] schedule
> fs/dax.c, 259: schedule in get_unlocked_mapping_entry
> fs/dax.c, 450: get_unlocked_mapping_entry in __dax_invalidate_mapping_entry
> fs/dax.c, 471: __dax_invalidate_mapping_entry in dax_delete_mapping_entry
> mm/truncate.c, 97: dax_delete_mapping_entry in
> truncate_exceptional_pvec_entries
> mm/truncate.c, 82: spin_lock_irq in truncate_exceptional_pvec_entries
> 
> I do not find a good way to fix, so I only report.
> This is found by my static analysis tool (DSAC).

Thanks for report but this is a false positive. Note that the lock is
acquired only if we are not operating on DAX mapping but we can get to
dax_delete_mapping_entry() only if we are operating on DAX mapping.

								Honza

-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
