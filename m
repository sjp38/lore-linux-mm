Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id CFBC56B0038
	for <linux-mm@kvack.org>; Sat, 28 Jan 2017 16:11:24 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id gt1so53224846wjc.0
        for <linux-mm@kvack.org>; Sat, 28 Jan 2017 13:11:24 -0800 (PST)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id k29si7605902wmh.124.2017.01.28.13.11.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 28 Jan 2017 13:11:23 -0800 (PST)
Received: by mail-wm0-x241.google.com with SMTP id r126so67210408wmr.3
        for <linux-mm@kvack.org>; Sat, 28 Jan 2017 13:11:23 -0800 (PST)
Date: Sat, 28 Jan 2017 23:11:19 +0200
From: Ahmed Samy <f.fallen45@gmail.com>
Subject: Re: ioremap_page_range: remapping of physical RAM ranges
Message-ID: <20170128211119.GA68646@devmasch>
References: <CADY3hbEy+oReL=DePFz5ZNsnvWpm55Q8=mRTxCGivSL64gAMMA@mail.gmail.com>
 <072b4406-16ef-cdf6-e968-711a60ca9a3f@nvidia.com>
 <20170125231529.GA14993@devmasch>
 <47fe454a-249d-967b-408f-83c5046615e4@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <47fe454a-249d-967b-408f-83c5046615e4@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: linux-mm@kvack.org, zhongjiang@huawei.com

On Thu, Jan 26, 2017 at 12:33:02AM -0800, John Hubbard wrote:
> 
> That's ioremap_page_range, I assume (rather than remap_page_range)?
> 
> Overall, the remap_ram_range approach looks reasonable to me so far. I'll
> look into the details tomorrow.
> 
> I'm sure that most people on this list already know this, but...could you
> say a few more words about how remapping system ram is used, why it's a good
> thing and not a bad thing? :)
> 
> thanks
> john h
> 
Please let me know if you're going to actually make a commit that either
	1) reverts that commit
	2) implements a "separate" function...

Either way, I don't think the un-export is reasonable in the slightest, if that
function is too low-level, then why not also un-export pmd_offset(),
pgd_offset(), perhaps current task too?  These interact directly with low-level
stuff, not meant for drivers, the function is meant to be low-level, I don't know
what made you think that people use it wrong?  How about writing proper
documentation about it instead?  Besides, even if that function does not exist,
you can always iterate the PTEs and set the physical address, it is not hard,
but the safe way is via the kernel knowledge, which is what that function
when combined with others (from vmalloc) provide...

How about this, a function as part of vmalloc, that says something like
`void *vremap(unsigned long phys, unsigned long size, unsigned long flags);`?
Then that solved the problem and there is no need for "low level" functions,
anymore.

Other than, if you're not going to apply a proper workaround, then let me know,
and I'll handle it myself from here.  I don't want this to get past the next
-rc release, so please let's get this fixed...

Thanks,
	asamy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
