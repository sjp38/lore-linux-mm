Subject: Re: Fw: [Lhms-devel] Making hotremovable attribute with memory
	section[0/4]
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <1092702436.21359.3.camel@localhost.localdomain>
References: <20040816153613.E6F7.YGOTO@us.fujitsu.com>
	 <1092699350.1822.43.camel@nighthawk>
	 <1092702436.21359.3.camel@localhost.localdomain>
Content-Type: text/plain
Message-Id: <1092729153.5415.19.camel@nighthawk>
Mime-Version: 1.0
Date: Tue, 17 Aug 2004 00:52:33 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Yasunori Goto <ygoto@us.fujitsu.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "Martin J. Bligh" <mbligh@aracnet.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2004-08-16 at 17:27, Alan Cox wrote:
> On Maw, 2004-08-17 at 00:35, Dave Hansen wrote:
> > In any case, the question of the day is, does anyone have any
> > suggestions on how to create 2 separate pools for pages: one
> > representing hot-removable pages, and the other pages that may not be
> > removed?
> 
> How do you define the split.

We would hope not to have to define the split explicitly.  Since we're
hotplugging memory and resizing zones anyway, it shouldn't be a real
functional problem to balance memory between the 2 states, no matter how
it is implemented.  

> There are lots of circumstances where user
> pages can be pinned for a long (near indefinite) period of time and used
> for DMA.

For simple cases, anything tricky like DMA will simply be in an
unremovable area.  However, some platforms like ppc64 logical
partitions, require firmware notification of DMA areas.  The ppc64
firmware provides consistent remapping functionality for these DMA areas
if they ever need to be hot-swapped. 

> Consider
> - Video capture
> - AGP Gart
> - AGP based framebuffer (intel i8/9xx)
> - O_DIRECT I/O
> 
> There are also things like cluster interconnects, sendfile and the like
> involved here.

When we get to trying to forcefully migrate the kinds of memory that you
reference above, we'll likely need firmware support like ppc64 has.  The
other option is to have some driver callbacks to tell them to reallocate
their buffers into new areas, if that's even possible.  But, even that's
not something I see ever happening to the entire tree, more likely a
small subset of the drivers that really need it.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
