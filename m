Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id CFA9C280254
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 11:54:47 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id j92so22140086ioi.2
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 08:54:47 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0036.hostedemail.com. [216.40.44.36])
        by mx.google.com with ESMTPS id u63si964983ioi.37.2016.12.01.08.54.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Dec 2016 08:54:47 -0800 (PST)
Date: Thu, 1 Dec 2016 11:54:43 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v3 2/5] dax: add tracepoint infrastructure, PMD tracing
Message-ID: <20161201115443.77135c91@gandalf.local.home>
In-Reply-To: <1480610271-23699-3-git-send-email-ross.zwisler@linux.intel.com>
References: <1480610271-23699-1-git-send-email-ross.zwisler@linux.intel.com>
	<1480610271-23699-3-git-send-email-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org

On Thu,  1 Dec 2016 09:37:48 -0700
Ross Zwisler <ross.zwisler@linux.intel.com> wrote:

> Tracepoints are the standard way to capture debugging and tracing
> information in many parts of the kernel, including the XFS and ext4
> filesystems.  Create a tracepoint header for FS DAX and add the first DAX
> tracepoints to the PMD fault handler.  This allows the tracing for DAX to
> be done in the same way as the filesystem tracing so that developers can
> look at them together and get a coherent idea of what the system is doing.
> 
> I added both an entry and exit tracepoint because future patches will add
> tracepoints to child functions of dax_iomap_pmd_fault() like
> dax_pmd_load_hole() and dax_pmd_insert_mapping(). We want those messages to
> be wrapped by the parent function tracepoints so the code flow is more
> easily understood.  Having entry and exit tracepoints for faults also
> allows us to easily see what filesystems functions were called during the
> fault.  These filesystem functions get executed via iomap_begin() and
> iomap_end() calls, for example, and will have their own tracepoints.
> 
> For PMD faults we primarily want to understand the type of mapping, the
> fault flags, the faulting address and whether it fell back to 4k faults.
> If it fell back to 4k faults the tracepoints should let us understand why.
> 
> I named the new tracepoint header file "fs_dax.h" to allow for device DAX
> to have its own separate tracing header in the same directory at some
> point.
> 
> Here is an example output for these events from a successful PMD fault:
> 
> big-1441  [005] ....    32.582758: xfs_filemap_pmd_fault: dev 259:0 ino
> 0x1003
> 
> big-1441  [005] ....    32.582776: dax_pmd_fault: dev 259:0 ino 0x1003
> shared WRITE|ALLOW_RETRY|KILLABLE|USER address 0x10505000 vm_start
> 0x10200000 vm_end 0x10700000 pgoff 0x200 max_pgoff 0x1400
> 
> big-1441  [005] ....    32.583292: dax_pmd_fault_done: dev 259:0 ino 0x1003
> shared WRITE|ALLOW_RETRY|KILLABLE|USER address 0x10505000 vm_start
> 0x10200000 vm_end 0x10700000 pgoff 0x200 max_pgoff 0x1400 NOPAGE
> 
> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> Suggested-by: Dave Chinner <david@fromorbit.com>
> Reviewed-by: Jan Kara <jack@suse.cz>

Acked-by: Steven Rostedt <rostedt@goodmis.org>

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
