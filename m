Date: Fri, 29 Apr 2005 16:06:59 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [PATCH 3/3] Page Fault Scalability V20: Avoid lock for anonymous
 write fault
In-Reply-To: <20050429210240.GA14774@infradead.org>
Message-ID: <Pine.LNX.4.58.0504291600500.16690@schroedinger.engr.sgi.com>
References: <20050429195901.15694.28520.sendpatchset@schroedinger.engr.sgi.com>
 <20050429195917.15694.21053.sendpatchset@schroedinger.engr.sgi.com>
 <20050429210240.GA14774@infradead.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 29 Apr 2005, Christoph Hellwig wrote:

> On Fri, Apr 29, 2005 at 12:59:17PM -0700, Christoph Lameter wrote:
> > Do not use the page_table_lock in do_anonymous_page. This will significantly
> > increase the parallelism in the page fault handler for SMP systems. The patch
> > also modifies the definitions of _mm_counter functions so that rss and anon_rss
> > become atomic (and will use atomic64_t if available).
>
> I thought we said all architectures should provide an atomic64_t (and
> given that it's not actually 64bit on 32bit architecture we should
> probably rename it to atomic_long_t)

Yes the way atomic types are provided may need a revision.
First of all we need atomic types that are size bound

	atomic8_t
	atomic16_t
	atomic32_t

and (if available)

	atomic64_t

and then some aliases

	atomic_t -> atomic type for int
	atomic_long_t -> atomic type for long

If these types are available then this patch could be cleaned up to
just use atomic_long_t.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
