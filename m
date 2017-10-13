Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 88ABF6B0033
	for <linux-mm@kvack.org>; Fri, 13 Oct 2017 04:40:59 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id y10so5430463wmd.4
        for <linux-mm@kvack.org>; Fri, 13 Oct 2017 01:40:59 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y74si600073wme.191.2017.10.13.01.40.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 13 Oct 2017 01:40:58 -0700 (PDT)
Date: Fri, 13 Oct 2017 10:40:54 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 3/3] mm/map_contig: Add mmap(MAP_CONTIG) support
Message-ID: <20171013084054.me3kxhgbxzgm2lpr@dhcp22.suse.cz>
References: <21f1ec96-2822-1189-1c95-79a2bb491571@oracle.com>
 <20171012014611.18725-1-mike.kravetz@oracle.com>
 <20171012014611.18725-4-mike.kravetz@oracle.com>
 <20171012143756.p5bv4zx476qkmqhh@dhcp22.suse.cz>
 <f4a46a19-5f71-ebcc-3098-a35728fbfd03@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f4a46a19-5f71-ebcc-3098-a35728fbfd03@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Guy Shattah <sguy@mellanox.com>, Christoph Lameter <cl@linux.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Laura Abbott <labbott@redhat.com>, Vlastimil Babka <vbabka@suse.cz>

On Thu 12-10-17 10:19:16, Mike Kravetz wrote:
> On 10/12/2017 07:37 AM, Michal Hocko wrote:
> > On Wed 11-10-17 18:46:11, Mike Kravetz wrote:
> >> Add new MAP_CONTIG flag to mmap system call.  Check for flag in normal
> >> mmap flag processing.  If present, pre-allocate a contiguous set of
> >> pages to back the mapping.  These pages will be used a fault time, and
> >> the MAP_CONTIG flag implies populating the mapping at the mmap time.
> > 
> > I have only briefly read through the previous discussion and it is still
> > not clear to me _why_ we want such a interface. I didn't give it much
> > time yet but I do not think this is a good idea at all.
> 
> Thanks for looking Michal.  The primary use case comes from devices that can
> realize performance benefits if operating on physically contiguous memory.
> What sparked this effort was Christoph and Guy's plumbers presentation
> where they showed RDMA performance benefits that could be realized with
> contiguous memory.  I also remember sitting in a presentation about
> Intel's QuackAssist technology at Vault last year.  The presenter mentioned
> that their compression engine needed to be passed a physically contiguous
> buffer.  I asked how a user could obtain such a buffer.  They said they
> had a special driver/ioctl for that.  Yuck!  I'm guessing there are other
> specific use cases.  That is why I wanted to start the discussion as to
> whether there should be an interface to provide this functionality.

I would, quite contrary, suggest a device specific mmap implementation
which would guarantee both the best memory wrt. physical contiguous
aspect as well as the placement - what if the device have a restriction
on that as well?
 
> > any user to simply consume larger order memory blocks? What would
> > prevent from that?
> 
> We certainly would want to put restrictions in place for contiguous
> memory allocations.  Since it makes sense to pre-populate and lock
> contiguous allocations, using the same restrictions as mlock is a start.
> However, I can see the possible need for more restrictions.

Absolutely. mlock limit is per process (resp. mm) so a single user could
simply deplete large blocks. No good...
 
> > Does the memory always stays contiguous? How much contiguous it will be?
> 
> Yes, it remains contiguous.  It is locked in memory.

Hmm, so hugetlb on steroids...

> > Who is going to use such an interface? And probably many other
> > questions...
> 
> Thanks for asking.  I am just throwing out the idea of providing an interface
> for doing contiguous memory allocations from user space.  There are at least
> two (and possibly more) devices that could benefit from such an interface.

I am not really convinced this is a good interface. You are basically
trying to bypass virtual memory abstraction and that is quite
contradicting the mmap API to me.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
