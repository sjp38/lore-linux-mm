Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9B41F8E0001
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 01:56:41 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id x24-v6so3377797edm.13
        for <linux-mm@kvack.org>; Thu, 13 Sep 2018 22:56:41 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h25-v6si1654005edb.423.2018.09.13.22.56.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Sep 2018 22:56:40 -0700 (PDT)
Date: Fri, 14 Sep 2018 07:56:37 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH V2 0/6] VA to numa node information
Message-ID: <20180914055637.GH20287@dhcp22.suse.cz>
References: <1536783844-4145-1-git-send-email-prakash.sangappa@oracle.com>
 <20180913084011.GC20287@dhcp22.suse.cz>
 <375951d0-f103-dec3-34d8-bbeb2f45f666@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <375951d0-f103-dec3-34d8-bbeb2f45f666@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "prakash.sangappa" <prakash.sangappa@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dave.hansen@intel.com, nao.horiguchi@gmail.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, khandual@linux.vnet.ibm.com, steven.sistare@oracle.com

On Thu 13-09-18 15:32:25, prakash.sangappa wrote:
> 
> 
> On 09/13/2018 01:40 AM, Michal Hocko wrote:
> > On Wed 12-09-18 13:23:58, Prakash Sangappa wrote:
> > > For analysis purpose it is useful to have numa node information
> > > corresponding mapped virtual address ranges of a process. Currently,
> > > the file /proc/<pid>/numa_maps provides list of numa nodes from where pages
> > > are allocated per VMA of a process. This is not useful if an user needs to
> > > determine which numa node the mapped pages are allocated from for a
> > > particular address range. It would have helped if the numa node information
> > > presented in /proc/<pid>/numa_maps was broken down by VA ranges showing the
> > > exact numa node from where the pages have been allocated.
> > > 
> > > The format of /proc/<pid>/numa_maps file content is dependent on
> > > /proc/<pid>/maps file content as mentioned in the manpage. i.e one line
> > > entry for every VMA corresponding to entries in /proc/<pids>/maps file.
> > > Therefore changing the output of /proc/<pid>/numa_maps may not be possible.
> > > 
> > > This patch set introduces the file /proc/<pid>/numa_vamaps which
> > > will provide proper break down of VA ranges by numa node id from where the
> > > mapped pages are allocated. For Address ranges not having any pages mapped,
> > > a '-' is printed instead of numa node id.
> > > 
> > > Includes support to lseek, allowing seeking to a specific process Virtual
> > > address(VA) starting from where the address range to numa node information
> > > can to be read from this file.
> > > 
> > > The new file /proc/<pid>/numa_vamaps will be governed by ptrace access
> > > mode PTRACE_MODE_READ_REALCREDS.
> > > 
> > > See following for previous discussion about this proposal
> > > 
> > > https://marc.info/?t=152524073400001&r=1&w=2
> > It would be really great to give a short summary of the previous
> > discussion. E.g. why do we need a proc interface in the first place when
> > we already have an API to query for the information you are proposing to
> > export [1]
> > 
> > [1] http://lkml.kernel.org/r/20180503085741.GD4535@dhcp22.suse.cz
> 
> The proc interface provides an efficient way to export address range
> to numa node id mapping information compared to using the API.

Do you have any numbers?

> For example, for sparsely populated mappings, if a VMA has large portions
> not have any physical pages mapped, the page walk done thru the /proc file
> interface can skip over non existent PMDs / ptes. Whereas using the
> API the application would have to scan the entire VMA in page size units.

What prevents you from pre-filtering by reading /proc/$pid/maps to get
ranges of interest?

> Also, VMAs having THP pages can have a mix of 4k pages and hugepages.
> The page walks would be efficient in scanning and determining if it is
> a THP huge page and step over it. Whereas using the API, the application
> would not know what page size mapping is used for a given VA and so would
> have to again scan the VMA in units of 4k page size.

Why does this matter for something that is for analysis purposes.
Reading the file for the whole address space is far from a free
operation. Is the page walk optimization really essential for usability?
Moreover what prevents move_pages implementation to be clever for the
page walk itself? In other words why would we want to add a new API
rather than make the existing one faster for everybody.
 
> If this sounds reasonable, I can add it to the commit / patch description.

This all is absolutely _essential_ for any new API proposed. Remember that
once we add a new user interface, we have to maintain it for ever. We
used to be too relaxed when adding new proc files in the past and it
backfired many times already.
-- 
Michal Hocko
SUSE Labs
