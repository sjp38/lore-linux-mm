Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 221156B0035
	for <linux-mm@kvack.org>; Tue, 12 Aug 2014 11:01:38 -0400 (EDT)
Received: by mail-wi0-f178.google.com with SMTP id hi2so5930398wib.17
        for <linux-mm@kvack.org>; Tue, 12 Aug 2014 08:01:37 -0700 (PDT)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.194])
        by mx.google.com with ESMTP id gf9si22695208wib.23.2014.08.12.08.01.35
        for <linux-mm@kvack.org>;
        Tue, 12 Aug 2014 08:01:36 -0700 (PDT)
Date: Tue, 12 Aug 2014 18:01:31 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: x86: vmalloc and THP
Message-ID: <20140812150131.GA12187@node.dhcp.inet.fi>
References: <53E99F86.5020100@scalemp.com>
 <20140812060745.GA7987@node.dhcp.inet.fi>
 <1407846532.10122.66.camel@edumazet-glaptop2.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1407846532.10122.66.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Oren Twaig <oren@scalemp.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, "Shai Fultheim (Shai@ScaleMP.com)" <Shai@scalemp.com>

On Tue, Aug 12, 2014 at 05:28:52AM -0700, Eric Dumazet wrote:
> On Tue, 2014-08-12 at 09:07 +0300, Kirill A. Shutemov wrote:
> > On Tue, Aug 12, 2014 at 08:00:54AM +0300, Oren Twaig wrote:
> > >If not, is there any fast way to change this behavior ? Maybe by
> > >changing the granularity/alignment of such allocations to allow such
> > >mapping ?
> > 
> > What's the point to use vmalloc() in this case?
> 
> Look at various large hashes we have in the system, all using
> vmalloc() :
> 
> [    0.006856] Dentry cache hash table entries: 16777216 (order: 15, 134217728 bytes)
> [    0.033130] Inode-cache hash table entries: 8388608 (order: 14, 67108864 bytes)
> [    1.197621] TCP established hash table entries: 524288 (order: 11, 8388608 bytes)

I see lower-order allocation in upstream code. Is it some distribution
tweak?

> I would imagine a performance difference if we were using hugepages.

Okay, it's *probably* a valid point.

The hash tables are only allocated with vmalloc() on NUMA system, if
hashdist=1 (default on NUMA).  It does it to distribute memory between
nodes. vmalloc() in NUMA_NO_NODE case will allocate all memory with
0-order page allocations: no physical contiguous memory for hugepage
mappings.

I guess we could teach vmalloc() to interleave between nodes on PMD_SIZE
chunks rather then on PAGE_SIZE if caller asks for big memory allocations.
Although, I'm not sure it it would fit all vmalloc() users.

We also would need to allocate PMD_SIZE-aligned virtual address range
to be able to mapped allocated memory with pmds.

It's *potentially* interesting research project. Any volunteers?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
