Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id B16238E0001
	for <linux-mm@kvack.org>; Fri, 28 Dec 2018 19:42:49 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id m16so20999024pgd.0
        for <linux-mm@kvack.org>; Fri, 28 Dec 2018 16:42:49 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id q20si38836885pgl.268.2018.12.28.16.42.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Dec 2018 16:42:48 -0800 (PST)
Date: Fri, 28 Dec 2018 16:42:46 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [v3 PATCH 1/2] mm: swap: check if swap backing device is
 congested or not
Message-Id: <20181228164246.4867201125a2123c8f6a6f9c@linux-foundation.org>
In-Reply-To: <1545428420-126557-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1545428420-126557-1-git-send-email-yang.shi@linux.alibaba.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: ying.huang@intel.com, tim.c.chen@intel.com, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, 22 Dec 2018 05:40:19 +0800 Yang Shi <yang.shi@linux.alibaba.com> wrote:

> Swap readahead would read in a few pages regardless if the underlying
> device is busy or not.  It may incur long waiting time if the device is
> congested, and it may also exacerbate the congestion.
> 
> Use inode_read_congested() to check if the underlying device is busy or
> not like what file page readahead does.  Get inode from swap_info_struct.
> Although we can add inode information in swap_address_space
> (address_space->host), it may lead some unexpected side effect, i.e.
> it may break mapping_cap_account_dirty().  Using inode from
> swap_info_struct seems simple and good enough.
> 
> Just does the check in vma_cluster_readahead() since
> swap_vma_readahead() is just used for non-rotational device which
> much less likely has congestion than traditional HDD.
> 
> Although swap slots may be consecutive on swap partition, it still may be
> fragmented on swap file. This check would help to reduce excessive stall
> for such case.

Some words about the observed effects of the patch would be more than
appropriate!
