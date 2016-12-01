Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5E509280254
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 09:19:35 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id g8so15029023ioi.0
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 06:19:35 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0193.hostedemail.com. [216.40.44.193])
        by mx.google.com with ESMTPS id u74si9364759itu.40.2016.12.01.06.19.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Dec 2016 06:19:34 -0800 (PST)
Date: Thu, 1 Dec 2016 09:19:30 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v2 6/6] dax: add tracepoints to dax_pmd_insert_mapping()
Message-ID: <20161201091930.2084d32c@gandalf.local.home>
In-Reply-To: <1480549533-29038-7-git-send-email-ross.zwisler@linux.intel.com>
References: <1480549533-29038-1-git-send-email-ross.zwisler@linux.intel.com>
	<1480549533-29038-7-git-send-email-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org

On Wed, 30 Nov 2016 16:45:33 -0700
Ross Zwisler <ross.zwisler@linux.intel.com> wrote:

> diff --git a/include/linux/pfn_t.h b/include/linux/pfn_t.h
> index a3d90b9..033fc7b 100644
> --- a/include/linux/pfn_t.h
> +++ b/include/linux/pfn_t.h
> @@ -15,6 +15,12 @@
>  #define PFN_DEV (1ULL << (BITS_PER_LONG_LONG - 3))
>  #define PFN_MAP (1ULL << (BITS_PER_LONG_LONG - 4))
>  
> +#define PFN_FLAGS_TRACE \
> +	{ PFN_SG_CHAIN,	"SG_CHAIN" }, \
> +	{ PFN_SG_LAST,	"SG_LAST" }, \
> +	{ PFN_DEV,	"DEV" }, \
> +	{ PFN_MAP,	"MAP" }
> +
>  static inline pfn_t __pfn_to_pfn_t(unsigned long pfn, u64 flags)
>  {
>  	pfn_t pfn_t = { .val = pfn | (flags & PFN_FLAGS_MASK), };
> diff --git a/include/trace/events/fs_dax.h b/include/trace/events/fs_dax.h
> index 9f0a455..7d0ea33 100644
> --- a/include/trace/events/fs_dax.h
> +++ b/include/trace/events/fs_dax.h
> @@ -104,6 +104,57 @@ DEFINE_EVENT(dax_pmd_load_hole_class, name, \
>  DEFINE_PMD_LOAD_HOLE_EVENT(dax_pmd_load_hole);
>  DEFINE_PMD_LOAD_HOLE_EVENT(dax_pmd_load_hole_fallback);
>  
> +DECLARE_EVENT_CLASS(dax_pmd_insert_mapping_class,
> +	TP_PROTO(struct inode *inode, struct vm_area_struct *vma,
> +		unsigned long address, int write, long length, pfn_t pfn,
> +		void *radix_entry),
> +	TP_ARGS(inode, vma, address, write, length, pfn, radix_entry),
> +	TP_STRUCT__entry(
> +		__field(dev_t, dev)
> +		__field(unsigned long, ino)
> +		__field(unsigned long, vm_flags)
> +		__field(unsigned long, address)
> +		__field(int, write)

Place "write" at the end. The ring buffer is 4 byte aligned, so on
archs that can access 8 bytes on 4 byte alignment, this will be packed
tighter. Otherwise, you'll get 4 empty bytes after "write".

-- Steve

> +		__field(long, length)
> +		__field(u64, pfn_val)
> +		__field(void *, radix_entry)
> +	),
> +	TP_fast_assign(
> +		__entry->dev = inode->i_sb->s_dev;
> +		__entry->ino = inode->i_ino;
> +		__entry->vm_flags = vma->vm_flags;
> +		__entry->address = address;
> +		__entry->write = write;
> +		__entry->length = length;
> +		__entry->pfn_val = pfn.val;
> +		__entry->radix_entry = radix_entry;
> +	),
> +	TP_printk("dev %d:%d ino %#lx %s %s address %#lx length %#lx "
> +			"pfn %#llx %s radix_entry %#lx",
> +		MAJOR(__entry->dev),
> +		MINOR(__entry->dev),
> +		__entry->ino,
> +		__entry->vm_flags & VM_SHARED ? "shared" : "private",
> +		__entry->write ? "write" : "read",
> +		__entry->address,
> +		__entry->length,
> +		__entry->pfn_val & ~PFN_FLAGS_MASK,
> +		__print_flags_u64(__entry->pfn_val & PFN_FLAGS_MASK, "|",
> +			PFN_FLAGS_TRACE),
> +		(unsigned long)__entry->radix_entry
> +	)
> +)
> +
> +#define DEFINE_PMD_INSERT_MAPPING_EVENT(name) \
> +DEFINE_EVENT(dax_pmd_insert_mapping_class, name, \
> +	TP_PROTO(struct inode *inode, struct vm_area_struct *vma, \
> +		unsigned long address, int write, long length, pfn_t pfn, \
> +		void *radix_entry), \
> +	TP_ARGS(inode, vma, address, write, length, pfn, radix_entry))
> +
> +DEFINE_PMD_INSERT_MAPPING_EVENT(dax_pmd_insert_mapping);
> +DEFINE_PMD_INSERT_MAPPING_EVENT(dax_pmd_insert_mapping_fallback);
> +
>  #endif /* _TRACE_FS_DAX_H */
>  
>  /* This part must be outside protection */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
