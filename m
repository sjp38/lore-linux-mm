Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 7A7546B0031
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 07:41:16 -0400 (EDT)
Date: Wed, 5 Jun 2013 13:41:14 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: Handling NUMA page migration
Message-ID: <20130605114114.GO15997@dhcp22.suse.cz>
References: <201306040922.10235.frank.mehnert@oracle.com>
 <201306051132.15788.frank.mehnert@oracle.com>
 <20130605095630.GL15997@dhcp22.suse.cz>
 <201306051222.32786.frank.mehnert@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201306051222.32786.frank.mehnert@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frank Mehnert <frank.mehnert@oracle.com>
Cc: Robin Holt <holt@sgi.com>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>

On Wed 05-06-13 03:22:32, Frank Mehnert wrote:
> On Wednesday 05 June 2013 11:56:30 Michal Hocko wrote:
> > On Wed 05-06-13 11:32:15, Frank Mehnert wrote:
> > [...]
> > 
> > > Thank you very much for your help. As I said, this problem happens _only_
> > > with NUMA_BALANCING enabled. I understand that you treat the VirtualBox
> > > code as untrusted but the reason for the problem is that some assumption
> > > is obviously not met: The VirtualBox code assumes that the memory it
> > > allocates using case A and case B is
> > > 
> > >  1. always present and
> > >  2. will always be backed by the same phyiscal memory
> > > 
> > > over the entire life time. Enabling NUMA_BALANCING seems to make this
> > > assumption false. I only want to know why.
> > 
> > As I said earlier. Both the manual node migration and numa_fault handler
> > do not migrate pages with elevated ref count (your A case) and pages
> > that are not on the LRU. So if your Referenced pages might be on the LRU
> > then you probably have to look into numamigrate_isolate_page and do an
> > exception for PageReserved pages. But I am a bit suspicious this is the
> > cause because the reclaim doesn't consider PageReserved pages either so
> > they could get reclaimed. Or maybe you have handled that path in your
> > kernel.
> 
> Thanks, I will also investigate into this direction.
> 
> > Or the other option is that you depend on a timing or something like
> > that which doesn't hold anymore. That would be hard to debug though.
> > 
> > > I see, you don't believe me. I will add more code to the kernel logging
> > > which pages were migrated.
> > 
> > Simple test for PageReserved flag in numamigrate_isolate_page should
> > tell you more.
> > 
> > This would cover the migration part. Another potential problem could be
> > that the page might get unmapped and marked for the numa fault (see
> > do_numa_page). So maybe your code just assumes that the page even
> > doesn't get unmapped?
> 
> Exactly, that's the assumption -- therefore all these vm_flags tricks.
> If this assumption is wrong or not always true, can this requirement
> (page is _never_ unmapped) be met at all?

yes, just pin the page by get_page(). Reserved pages are usually not
touched because they are not sitting in the LRU (that just doesn't make
any sense) - why we would age such pages in the first place.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
