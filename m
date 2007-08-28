Date: Tue, 28 Aug 2007 20:05:10 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 4/4] add SGI Altix cross partition memory (XPMEM) driver
Message-ID: <20070828190510.GA3256@infradead.org>
References: <20070827155622.GA25589@sgi.com> <20070827164112.GF25589@sgi.com> <20070828180235.GB32585@infradead.org> <20070828190043.GB7140@lnx-holt.americas.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=unknown-8bit
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20070828190043.GB7140@lnx-holt.americas.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Christoph Hellwig <hch@infradead.org>, Dean Nelson <dcn@sgi.com>, tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, jes@sgi.com
List-ID: <linux-mm.kvack.org>

On Tue, Aug 28, 2007 at 02:00:43PM -0500, Robin Holt wrote:
> The ioctl is sort of historical.  IIRC, in ProPack 3 (RHEL4 based 2.4
> kernel), we added system calls.  When the community started making noise
> about system calls being bad, we went to a device special file with a
> read/write (couldn't get the needed performance from the ioctl() interface
> which used to acquire the BKL).  Now that the community fixed the ioctl
> issues, we went to using an ioctl, but are completely open to change.
> 
> If you want to introduce system calls, we would expect to need, IIRC, 8.
> We also pondered an xpmem filesystem today.  It really felt wrong,
> but we could pursue that as an alternative.

The problem is not ioctls per sae, but the kind of operation you
export.

> What is the correct direction to go with this?  get_user_pages() does
> currently require the task_struct.  Are you proposing we develop a way
> to fault pages without the task_struct of the owning process/thread group?

Stop trying to mess with vmas and get_user_pages on processes entirely.
The only region of virtual memory a driver can deal with is the one it
got a mmap request for, or when using get_user_pages the one it's got
a read/write request for.  You're doing a worse variant of the rdma page
pinning scheme we're rejected countless times.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
