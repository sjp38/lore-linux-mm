Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 908766B0033
	for <linux-mm@kvack.org>; Mon, 16 Oct 2017 04:18:08 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id t69so8502352wmt.7
        for <linux-mm@kvack.org>; Mon, 16 Oct 2017 01:18:08 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j89si5405413wrj.390.2017.10.16.01.18.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 16 Oct 2017 01:18:07 -0700 (PDT)
Date: Mon, 16 Oct 2017 10:18:04 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 3/3] mm/map_contig: Add mmap(MAP_CONTIG) support
Message-ID: <20171016081804.yiqck2g4bwlbdqi6@dhcp22.suse.cz>
References: <20171012014611.18725-1-mike.kravetz@oracle.com>
 <20171012014611.18725-4-mike.kravetz@oracle.com>
 <20171012143756.p5bv4zx476qkmqhh@dhcp22.suse.cz>
 <f4a46a19-5f71-ebcc-3098-a35728fbfd03@oracle.com>
 <20171013084054.me3kxhgbxzgm2lpr@dhcp22.suse.cz>
 <alpine.DEB.2.20.1710131015420.3949@nuc-kabylake>
 <20171013152801.nbpk6nluotgbmfrs@dhcp22.suse.cz>
 <alpine.DEB.2.20.1710131040570.4247@nuc-kabylake>
 <20171013154747.2jv7rtfqyyagiodn@dhcp22.suse.cz>
 <20171015065856.GC3916@xo-6d-61-c0.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171015065856.GC3916@xo-6d-61-c0.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Christopher Lameter <cl@linux.com>, Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Guy Shattah <sguy@mellanox.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Laura Abbott <labbott@redhat.com>, Vlastimil Babka <vbabka@suse.cz>

On Sun 15-10-17 08:58:56, Pavel Machek wrote:
> Hi!
> 
> > Yes you wrote that already and my counter argument was that this generic
> > posix interface shouldn't bypass virtual memory abstraction.
> > 
> > > > > The contiguous allocations are particularly useful for the RDMA API which
> > > > > allows registering user space memory with devices.
> > > >
> > > > then make those devices expose an implementation of an mmap which does
> > > > that. You would get both a proper access control (via fd), accounting
> > > > and others.
> > > 
> > > There are numerous RDMA devices that would all need the mmap
> > > implementation. And this covers only the needs of one subsystem. There are
> > > other use cases.
> > 
> > That doesn't prevent providing a library function which could be reused
> > by all those drivers. Nothing really too much different from
> > remap_pfn_range.
> 
> So you'd suggest using ioctl() for allocating memory?

Why not using standard mmap on the device fd?
 
> That sounds quite ugly to me... mmap(MAP_CONTIG) is not nice, either, but better than
> each driver inventing custom interface...

As already pointed out elsewhere, I do not really see a different to
remap_pfn_range from the API point of view. A driver has some
requirements to the memory so those can be reflected in the mmap
implementation for the driver. I really do not see how that would be a
general interface without a lot of headache in future. Contiguous memory
is a hard requirement to guarantee or give out without risks.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
