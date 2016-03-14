Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 36D796B007E
	for <linux-mm@kvack.org>; Mon, 14 Mar 2016 17:23:10 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id tt10so165809871pab.3
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 14:23:10 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id yp3si15156621pac.120.2016.03.14.14.23.09
        for <linux-mm@kvack.org>;
        Mon, 14 Mar 2016 14:23:09 -0700 (PDT)
Date: Mon, 14 Mar 2016 17:23:44 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH RFC 1/1] Add support for ZONE_DEVICE IO memory with
 struct pages.
Message-ID: <20160314212344.GC23727@linux.intel.com>
References: <1457979277-26791-1-git-send-email-stephen.bates@pmcs.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1457979277-26791-1-git-send-email-stephen.bates@pmcs.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Bates <stephen.bates@pmcs.com>
Cc: linux-mm@kvack.org, linux-rdma@vger.kernel.org, linux-nvdimm@lists.01.org, haggaie@mellanox.com, javier@cnexlabs.com, sagig@mellanox.com, jgunthorpe@obsidianresearch.com, leonro@mellanox.com, artemyko@mellanox.com, hch@infradead.org

On Mon, Mar 14, 2016 at 12:14:37PM -0600, Stephen Bates wrote:
> 3. Coherency Issues. When IOMEM is written from both the CPU and a PCIe
> peer there is potential for coherency issues and for writes to occur out
> of order. This is something that users of this feature need to be
> cognizant of and may necessitate the use of CONFIG_EXPERT. Though really,
> this isn't much different than the existing situation with RDMA: if
> userspace sets up an MR for remote use, they need to be careful about
> using that memory region themselves.

There's more to the coherency problem than this.  As I understand it, on
x86, memory in a PCI BAR does not participate in the coherency protocol.
So you can get a situation where CPU A stores 4 bytes to offset 8 in a
cacheline, then CPU B stores 4 bytes to offset 16 in the same cacheline,
and CPU A's write mysteriously goes missing.

I may have misunderstood the exact details when this was explained to me a
few years ago, but the details were horrible enough to run away screaming.
Pretending PCI BARs are real memory?  Just Say No.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
