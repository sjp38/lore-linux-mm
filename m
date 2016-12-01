Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7DB84280254
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 09:16:32 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id j92so14843371ioi.2
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 06:16:32 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0039.hostedemail.com. [216.40.44.39])
        by mx.google.com with ESMTPS id 139si9410789itv.64.2016.12.01.06.16.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Dec 2016 06:16:31 -0800 (PST)
Date: Thu, 1 Dec 2016 09:16:28 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v2 3/6] dax: add tracepoint infrastructure, PMD tracing
Message-ID: <20161201091628.7057580f@gandalf.local.home>
In-Reply-To: <1480549533-29038-4-git-send-email-ross.zwisler@linux.intel.com>
References: <1480549533-29038-1-git-send-email-ross.zwisler@linux.intel.com>
	<1480549533-29038-4-git-send-email-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org

On Wed, 30 Nov 2016 16:45:30 -0700
Ross Zwisler <ross.zwisler@linux.intel.com> wrote:


> --- /dev/null
> +++ b/include/trace/events/fs_dax.h
> @@ -0,0 +1,68 @@
> +#undef TRACE_SYSTEM
> +#define TRACE_SYSTEM fs_dax
> +
> +#if !defined(_TRACE_FS_DAX_H) || defined(TRACE_HEADER_MULTI_READ)
> +#define _TRACE_FS_DAX_H
> +
> +#include <linux/tracepoint.h>
> +
> +DECLARE_EVENT_CLASS(dax_pmd_fault_class,
> +	TP_PROTO(struct inode *inode, struct vm_area_struct *vma,
> +		unsigned long address, unsigned int flags, pgoff_t pgoff,
> +		pgoff_t max_pgoff, int result),
> +	TP_ARGS(inode, vma, address, flags, pgoff, max_pgoff, result),
> +	TP_STRUCT__entry(
> +		__field(dev_t, dev)
> +		__field(unsigned long, ino)
> +		__field(unsigned long, vm_start)
> +		__field(unsigned long, vm_end)
> +		__field(unsigned long, vm_flags)
> +		__field(unsigned long, address)
> +		__field(unsigned int, flags)
> +		__field(pgoff_t, pgoff)
> +		__field(pgoff_t, max_pgoff)
> +		__field(int, result)

For better compaction, I would put flags and result together, as they
are both ints. Otherwise, you'll probably have 4 empty bytes after
flags.

-- Steve

> +	),
> +	TP_fast_assign(
> +		__entry->dev = inode->i_sb->s_dev;
> +		__entry->ino = inode->i_ino;
> +		__entry->vm_start = vma->vm_start;
> +		__entry->vm_end = vma->vm_end;
> +		__entry->vm_flags = vma->vm_flags;
> +		__entry->address = address;
> +		__entry->flags = flags;
> +		__entry->pgoff = pgoff;
> +		__entry->max_pgoff = max_pgoff;
> +		__entry->result = result;
> +	),
> +	TP_printk("dev %d:%d ino %#lx %s %s address %#lx vm_start "
> +			"%#lx vm_end %#lx pgoff %#lx max_pgoff %#lx %s",
> +		MAJOR(__entry->dev),
> +		MINOR(__entry->dev),
> +		__entry->ino,
> +		__entry->vm_flags & VM_SHARED ? "shared" : "private",
> +		__print_flags(__entry->flags, "|", FAULT_FLAG_TRACE),
> +		__entry->address,
> +		__entry->vm_start,
> +		__entry->vm_end,
> +		__entry->pgoff,
> +		__entry->max_pgoff,
> +		__print_flags(__entry->result, "|", VM_FAULT_RESULT_TRACE)
> +	)
> +)
> +
> +#define DEFINE_PMD_FAULT_EVENT(name) \
> +DEFINE_EVENT(dax_pmd_fault_class, name, \
> +	TP_PROTO(struct inode *inode, struct vm_area_struct *vma, \
> +		unsigned long address, unsigned int flags, pgoff_t pgoff, \
> +		pgoff_t max_pgoff, int result), \
> +	TP_ARGS(inode, vma, address, flags, pgoff, max_pgoff, result))
> +
> +DEFINE_PMD_FAULT_EVENT(dax_pmd_fault);
> +DEFINE_PMD_FAULT_EVENT(dax_pmd_fault_done);
> +
> +
> +#endif /* _TRACE_FS_DAX_H */
> +
> +/* This part must be outside protection */
> +#include <trace/define_trace.h>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
