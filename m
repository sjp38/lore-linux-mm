Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 3E2AE6B005D
	for <linux-mm@kvack.org>; Tue, 21 Aug 2012 14:22:19 -0400 (EDT)
Date: Tue, 21 Aug 2012 14:55:03 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH v8 1/5] mm: introduce a common interface for balloon
 pages mobility
Message-ID: <20120821175502.GC12294@t510.redhat.com>
References: <cover.1345519422.git.aquini@redhat.com>
 <e24f3073ef539985dea52943dcb84762213a0857.1345519422.git.aquini@redhat.com>
 <20120821135223.GA7117@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120821135223.GA7117@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>

On Tue, Aug 21, 2012 at 04:52:23PM +0300, Michael S. Tsirkin wrote:
> > + * address_space_operations utilized methods for ballooned pages:
> > + *   .migratepage    - used to perform balloon's page migration (as is)
> > + *   .launder_page   - used to isolate a page from balloon's page list
> > + *   .freepage       - used to reinsert an isolated page to balloon's page list
> > + */
> 
> It would be a good idea to document the assumptions here.
> Looks like .launder_page and .freepage are called in rcu critical
> section.
> But migratepage isn't - why is that safe?
> 

The migratepage callback for virtio_balloon can sleep, and IIUC we cannot sleep
within a RCU critical section. 

Also, The migratepage callback is called at inner migration's circle function
move_to_new_page(), and I don't think embedding it in a RCU critical section
would be a good idea, for the same understanding aforementioned.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
