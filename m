Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 57DC2280260
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 10:44:34 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id p66so103312546pga.4
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 07:44:34 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id t1si625453pge.38.2016.12.01.07.44.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Dec 2016 07:44:33 -0800 (PST)
Date: Thu, 1 Dec 2016 08:44:32 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v2 6/6] dax: add tracepoints to dax_pmd_insert_mapping()
Message-ID: <20161201154432.GD5160@linux.intel.com>
References: <1480549533-29038-1-git-send-email-ross.zwisler@linux.intel.com>
 <1480549533-29038-7-git-send-email-ross.zwisler@linux.intel.com>
 <20161201091930.2084d32c@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161201091930.2084d32c@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org

On Thu, Dec 01, 2016 at 09:19:30AM -0500, Steven Rostedt wrote:
> On Wed, 30 Nov 2016 16:45:33 -0700
> Ross Zwisler <ross.zwisler@linux.intel.com> wrote:
> 
> > diff --git a/include/linux/pfn_t.h b/include/linux/pfn_t.h
> > index a3d90b9..033fc7b 100644
> > --- a/include/linux/pfn_t.h
> > +++ b/include/linux/pfn_t.h
> > @@ -15,6 +15,12 @@
> >  #define PFN_DEV (1ULL << (BITS_PER_LONG_LONG - 3))
> >  #define PFN_MAP (1ULL << (BITS_PER_LONG_LONG - 4))
> >  
> > +#define PFN_FLAGS_TRACE \
> > +	{ PFN_SG_CHAIN,	"SG_CHAIN" }, \
> > +	{ PFN_SG_LAST,	"SG_LAST" }, \
> > +	{ PFN_DEV,	"DEV" }, \
> > +	{ PFN_MAP,	"MAP" }
> > +
> >  static inline pfn_t __pfn_to_pfn_t(unsigned long pfn, u64 flags)
> >  {
> >  	pfn_t pfn_t = { .val = pfn | (flags & PFN_FLAGS_MASK), };
> > diff --git a/include/trace/events/fs_dax.h b/include/trace/events/fs_dax.h
> > index 9f0a455..7d0ea33 100644
> > --- a/include/trace/events/fs_dax.h
> > +++ b/include/trace/events/fs_dax.h
> > @@ -104,6 +104,57 @@ DEFINE_EVENT(dax_pmd_load_hole_class, name, \
> >  DEFINE_PMD_LOAD_HOLE_EVENT(dax_pmd_load_hole);
> >  DEFINE_PMD_LOAD_HOLE_EVENT(dax_pmd_load_hole_fallback);
> >  
> > +DECLARE_EVENT_CLASS(dax_pmd_insert_mapping_class,
> > +	TP_PROTO(struct inode *inode, struct vm_area_struct *vma,
> > +		unsigned long address, int write, long length, pfn_t pfn,
> > +		void *radix_entry),
> > +	TP_ARGS(inode, vma, address, write, length, pfn, radix_entry),
> > +	TP_STRUCT__entry(
> > +		__field(dev_t, dev)
> > +		__field(unsigned long, ino)
> > +		__field(unsigned long, vm_flags)
> > +		__field(unsigned long, address)
> > +		__field(int, write)
> 
> Place "write" at the end. The ring buffer is 4 byte aligned, so on
> archs that can access 8 bytes on 4 byte alignment, this will be packed
> tighter. Otherwise, you'll get 4 empty bytes after "write".

Actually I think it may be ideal to stick it as the 2nd entry after 'dev'.
dev_t is:

typedef __u32 __kernel_dev_t;
typedef __kernel_dev_t		dev_t;

So those two 32 bit values should combine into a single 64 bit space.

Thanks for the help, I obviously wasn't considering packing when ordering the
elements.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
