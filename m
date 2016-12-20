Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id DAF476B0340
	for <linux-mm@kvack.org>; Tue, 20 Dec 2016 13:33:37 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id i88so276220943pfk.3
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 10:33:37 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [184.105.139.130])
        by mx.google.com with ESMTP id q78si23308504pfl.46.2016.12.20.10.33.36
        for <linux-mm@kvack.org>;
        Tue, 20 Dec 2016 10:33:36 -0800 (PST)
Date: Tue, 20 Dec 2016 13:33:34 -0500 (EST)
Message-Id: <20161220.133334.158286071772728328.davem@davemloft.net>
Subject: Re: [RFC PATCH 04/14] sparc64: load shared id into context
 register 1
From: David Miller <davem@davemloft.net>
In-Reply-To: <62091365-2797-ed99-847f-7281f4666633@oracle.com>
References: <1481913337-9331-5-git-send-email-mike.kravetz@oracle.com>
	<20161217.221442.430708127662119954.davem@davemloft.net>
	<62091365-2797-ed99-847f-7281f4666633@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mike.kravetz@oracle.com
Cc: sparclinux@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, bob.picco@oracle.com, nitin.m.gupta@oracle.com, vijay.ac.kumar@oracle.com, julian.calaby@gmail.com, adam.buchbinder@gmail.com, kirill.shutemov@linux.intel.com, mhocko@suse.com, akpm@linux-foundation.org

From: Mike Kravetz <mike.kravetz@oracle.com>
Date: Sun, 18 Dec 2016 16:06:01 -0800

> Ok, let me try to find a way to eliminate these loads unless the application
> is using shared context.
> 
> Part of the issue is a 'backwards compatibility' feature of the processor
> which loads/overwrites register 1 every time register 0 is loaded.  Somewhere
> in the evolution of the processor, a feature was added so that register 0
> could be loaded without overwriting register 1.  That could be used to
> eliminate the extra load in some/many cases.  But, that would likely lead
> to more runtime kernel patching based on processor level.  And, I don't
> really want to add more of that if possible.  Or, perhaps we only enable
> the shared context ID feature on processors which have the ability to work
> around the backwards compatibility feature.

Until the first process uses shared mappings, you should not touch the
context 1 register in any way for any reason at all.

And even once a process _does_ use shared mappings, you only need to
access the context 1 register in 2 cases:

1) TLB processing for the processes using shared mappings.

2) Context switch MMU state handling, where either the previous or
   next process is using shared mappings.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
