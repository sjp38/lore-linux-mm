Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7A3F86B0033
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 17:38:56 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 204so329435992pfx.1
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 14:38:56 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id h7si486776pgn.325.2017.01.26.14.38.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jan 2017 14:38:55 -0800 (PST)
Date: Thu, 26 Jan 2017 14:38:54 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 2/3] mm, x86: Add support for PUD-sized transparent
 hugepages
Message-Id: <20170126143854.9694811975f4c0945aba58b9@linux-foundation.org>
In-Reply-To: <148545059381.17912.8602162635537598445.stgit@djiang5-desk3.ch.intel.com>
References: <148545012634.17912.13951763606410303827.stgit@djiang5-desk3.ch.intel.com>
	<148545059381.17912.8602162635537598445.stgit@djiang5-desk3.ch.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jiang <dave.jiang@intel.com>
Cc: dave.hansen@linux.intel.com, mawilcox@microsoft.com, linux-nvdimm@ml01.01.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, vbabka@suse.cz, jack@suse.com, dan.j.williams@intel.com, linux-ext4@vger.kernel.org, ross.zwisler@linux.intel.com, kirill.shutemov@linux.intel.com

On Thu, 26 Jan 2017 10:09:53 -0700 Dave Jiang <dave.jiang@intel.com> wrote:

> The current transparent hugepage code only supports PMDs.  This patch
> adds support for transparent use of PUDs with DAX.  It does not include
> support for anonymous pages. x86 support code also added.
> 
> Most of this patch simply parallels the work that was done for huge PMDs.
> The only major difference is how the new ->pud_entry method in mm_walk
> works.  The ->pmd_entry method replaces the ->pte_entry method, whereas
> the ->pud_entry method works along with either ->pmd_entry or ->pte_entry.
> The pagewalk code takes care of locking the PUD before calling ->pud_walk,
> so handlers do not need to worry whether the PUD is stable.

The patch adds a lot of new BUG()s and BG_ON()s.  We'll get in trouble
if any of those triggers.  Please recheck everything and decide if we
really really need them.  It's far better to drop a WARN and to back
out and recover in some fashion.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
