Date: Fri, 13 Sep 2002 15:10:32 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: Obtaining the kernel's PTEs
Message-ID: <20020913221032.GM2179@holomorphy.com>
References: <BDF7B0A2-C75C-11D6-8D39-000393829FA4@cs.amherst.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <BDF7B0A2-C75C-11D6-8D39-000393829FA4@cs.amherst.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Scott Kaplan <sfkaplan@cs.amherst.edu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Sep 13, 2002 at 05:06:59PM -0400, Scott Kaplan wrote:
> Yet another question...
> Assume that I'm not concerned with ZONE_HIGHMEM, and I have a struct page*
> .  How would I obtain a pointer to the PTE that maps the corresponding 
> virtual page in the kernel's address space to this given page?
> In case you're wondering, ``Why does he want that?'':  I want to remove 
> access permissions for pages, and I want to include the kernel in that 
> denial of permission.  An example of where this matters is when you have a 
> page cache page that was allocated by the VFS for read()/write() 
> operations on a regular (non-mmaped) file.  Only the kernel has a mapping 
> to that page, and I a trap to occur when the kernel tries to use that page.
> Must I get the PGD, PMD, and then PTE?  Is there a function that will do 
> this nicely for me so that I don't write redundant (and potentially buggy)
>  code for this little task?

Well, there are a couple of issues here.

(1) Pagetables are only meaningful to a couple of machines, most notably
	i386 and m68k. The rest is pretty much software TLB or inverted.
	So there's zero accounting of the direct-mapping within the kernel
	for some machines, not sure which since I've not gone about the
	task of hunting for the answer to "What does everyone do when
	they've taken a TLB miss on kernelspace?" My suspicion is TLB
	entries are generated on the fly for what is not bolted.

(2) The kernel is often mapped out using various tidbits of TLB magic not
	handled by user PTE manipulation routines. e.g. the G and PS bits
	on i386. i386 is even worse, as the PAT bit in a PTE has the same
	position as the PS bit in a PMD so a priori knowledge of mapping
	size is required. At the moment, hardware pagetable large pages
	such as i386's PTE's it keeps in PMD's are not understood by
	the core kernel to begin with...
	Also, since the kernel translations at least on i386 use the G
	bit which is basically "invalidate the TLB entry only when a
	specific page is targeted." This is also not a particularly
	friendly feature...

There is pain involved here.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
