Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id BD2276B0031
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 01:41:55 -0400 (EDT)
Date: Wed, 31 Jul 2013 14:41:55 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v3 6/9] mm, hugetlb: do not use a page in page cache for
 cow optimization
Message-ID: <20130731054154.GN2548@lge.com>
References: <1375075701-5998-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1375075701-5998-7-git-send-email-iamjoonsoo.kim@lge.com>
 <20130729223708.GG29970@voom.fritz.box>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130729223708.GG29970@voom.fritz.box>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Gibson <david@gibson.dropbear.id.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>

On Tue, Jul 30, 2013 at 08:37:08AM +1000, David Gibson wrote:
> On Mon, Jul 29, 2013 at 02:28:18PM +0900, Joonsoo Kim wrote:
> > Currently, we use a page with mapped count 1 in page cache for cow
> > optimization. If we find this condition, we don't allocate a new
> > page and copy contents. Instead, we map this page directly.
> > This may introduce a problem that writting to private mapping overwrite
> > hugetlb file directly. You can find this situation with following code.
> > 
> >         size = 20 * MB;
> >         flag = MAP_SHARED;
> >         p = mmap(NULL, size, PROT_READ|PROT_WRITE, flag, fd, 0);
> >         if (p == MAP_FAILED) {
> >                 fprintf(stderr, "mmap() failed: %s\n", strerror(errno));
> >                 return -1;
> >         }
> >         p[0] = 's';
> >         fprintf(stdout, "BEFORE STEAL PRIVATE WRITE: %c\n", p[0]);
> >         munmap(p, size);
> > 
> >         flag = MAP_PRIVATE;
> >         p = mmap(NULL, size, PROT_READ|PROT_WRITE, flag, fd, 0);
> >         if (p == MAP_FAILED) {
> >                 fprintf(stderr, "mmap() failed: %s\n", strerror(errno));
> >         }
> >         p[0] = 'c';
> >         munmap(p, size);
> > 
> >         flag = MAP_SHARED;
> >         p = mmap(NULL, size, PROT_READ|PROT_WRITE, flag, fd, 0);
> >         if (p == MAP_FAILED) {
> >                 fprintf(stderr, "mmap() failed: %s\n", strerror(errno));
> >                 return -1;
> >         }
> >         fprintf(stdout, "AFTER STEAL PRIVATE WRITE: %c\n", p[0]);
> >         munmap(p, size);
> > 
> > We can see that "AFTER STEAL PRIVATE WRITE: c", not "AFTER STEAL
> > PRIVATE WRITE: s". If we turn off this optimization to a page
> > in page cache, the problem is disappeared.
> 
> Please add this testcase to libhugetlbfs as well.

Okay!

Thanks.

> 
> -- 
> David Gibson			| I'll have my music baroque, and my code
> david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
> 				| _way_ _around_!
> http://www.ozlabs.org/~dgibson


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
