Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 3BCE76B004D
	for <linux-mm@kvack.org>; Sat, 28 Jan 2012 14:25:58 -0500 (EST)
Date: Sat, 28 Jan 2012 12:25:53 -0700
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [PATCH/RFC G-U-P experts] IB/umem: Modernize our
 get_user_pages() parameters
Message-ID: <20120128192553.GA16231@obsidianresearch.com>
References: <1327557574-6125-1-git-send-email-roland@kernel.org>
 <alpine.LSU.2.00.1201261133230.1369@eggly.anvils>
 <CAG4TOxNEV2VY9wOE86p9RnKGqpruB32ci9Wq3yBt8O2zc7f05w@mail.gmail.com>
 <CAL1RGDVBR49QrAbkZ0Wa9Gh98HTwjtsQbFQ4Ws3Ra7rEjT1Mng@mail.gmail.com>
 <alpine.LSU.2.00.1201271819260.3402@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1201271819260.3402@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Roland Dreier <roland@kernel.org>, linux-rdma@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jan 27, 2012 at 06:31:07PM -0800, Hugh Dickins wrote:

> My first impression is that that's not what you want at all: that will
> not do a preliminary COW of anonymous page to be written into by the
> driver when the user only wants VM_READ access.  But perhaps I'm
> worrying about the second order while you're sticking to first order.

IMHO, in this instance, the RDMA driver should not violate the
mprotect flags of the page, ie if you ask to register memory for
RDMA WRITE that the process cannot write to, that should be denied.

I know accessing system memory (eg obtained via mmap on
/sys/bus/pci/devices/0000:00:02.0/resource0) has been asked for in the
past, and IIRC, the problem was that some of the common code, (GUP?)
errored on these maps. I don't know if Roland's case is similar.

The main point (at least before) was to have a uniform userspace API
for memory registration that worked on any address range mapped into
the process no matter where it came from. Currently the API just calls
GUP unconditionally...

Jason

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
