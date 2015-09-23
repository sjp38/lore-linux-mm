From: Dave Hansen <dave@sr71.net>
Subject: Re: [PATCH 11/15] mm, dax, pmem: introduce __pfn_t
Date: Wed, 23 Sep 2015 09:02:17 -0700
Message-ID: <5602CD09.3080801@sr71.net>
References: <20150923043737.36490.70547.stgit@dwillia2-desk3.jf.intel.com>
 <20150923044211.36490.18084.stgit@dwillia2-desk3.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150923044211.36490.18084.stgit@dwillia2-desk3.jf.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Dan Williams <dan.j.williams@intel.com>, akpm@linux-foundation.org
Cc: linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>
List-Id: linux-mm.kvack.org

On 09/22/2015 09:42 PM, Dan Williams wrote:
>  /*
> + * __pfn_t: encapsulates a page-frame number that is optionally backed
> + * by memmap (struct page).  Whether a __pfn_t has a 'struct page'
> + * backing is indicated by flags in the low bits of the value;
> + */
> +typedef struct {
> +	unsigned long val;
> +} __pfn_t;
> +
> +/*
> + * PFN_SG_CHAIN - pfn is a pointer to the next scatterlist entry
> + * PFN_SG_LAST - pfn references a page and is the last scatterlist entry
> + * PFN_DEV - pfn is not covered by system memmap by default
> + * PFN_MAP - pfn has a dynamic page mapping established by a device driver
> + */
> +enum {
> +	PFN_SHIFT = 4,
> +	PFN_MASK = (1UL << PFN_SHIFT) - 1,
> +	PFN_SG_CHAIN = (1UL << 0),
> +	PFN_SG_LAST = (1UL << 1),
> +	PFN_DEV = (1UL << 2),
> +	PFN_MAP = (1UL << 3),
> +};

Please forgive a little bikeshedding here...

Why __pfn_t?  Because the KVM code has a pfn_t?  If so, I think we
should rescue pfn_t from KVM and give them a kvm_pfn_t.

I think you should do one of two things:  Make PFN_SHIFT 12 so that a
physical addr can be stored in a __pfn_t with no work.  Or, use the
*high* 12 bits of __pfn_t.val.

If you use the high bits, *and* make it store a plain pfn when all the
bits are 0, then you get a zero-cost pfn<->__pfn_t conversion which will
hopefully generate the exact same code which is there today.

The one disadvantage here is that it makes it more likely that somebody
that's just setting __pfn_t.val=foo will get things subtly wrong
somehow, but that it will work most of the time.

Also, about naming...  PFN_SHIFT is pretty awful name for this.  It
probably needs to be __PFN_T_SOMETHING.  We don't want folks doing
craziness like:

	unsigned long phys_addr = pfn << PFN_SHIFT.

Which *looks* OK.
