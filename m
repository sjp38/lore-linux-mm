Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5E1C06B0033
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 13:19:26 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id k70so4243602itk.11
        for <linux-mm@kvack.org>; Thu, 12 Oct 2017 10:19:26 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id s2si433607itg.59.2017.10.12.10.19.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Oct 2017 10:19:25 -0700 (PDT)
Subject: Re: [RFC PATCH 3/3] mm/map_contig: Add mmap(MAP_CONTIG) support
References: <21f1ec96-2822-1189-1c95-79a2bb491571@oracle.com>
 <20171012014611.18725-1-mike.kravetz@oracle.com>
 <20171012014611.18725-4-mike.kravetz@oracle.com>
 <20171012143756.p5bv4zx476qkmqhh@dhcp22.suse.cz>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <f4a46a19-5f71-ebcc-3098-a35728fbfd03@oracle.com>
Date: Thu, 12 Oct 2017 10:19:16 -0700
MIME-Version: 1.0
In-Reply-To: <20171012143756.p5bv4zx476qkmqhh@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Guy Shattah <sguy@mellanox.com>, Christoph Lameter <cl@linux.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Laura Abbott <labbott@redhat.com>, Vlastimil Babka <vbabka@suse.cz>

On 10/12/2017 07:37 AM, Michal Hocko wrote:
> On Wed 11-10-17 18:46:11, Mike Kravetz wrote:
>> Add new MAP_CONTIG flag to mmap system call.  Check for flag in normal
>> mmap flag processing.  If present, pre-allocate a contiguous set of
>> pages to back the mapping.  These pages will be used a fault time, and
>> the MAP_CONTIG flag implies populating the mapping at the mmap time.
> 
> I have only briefly read through the previous discussion and it is still
> not clear to me _why_ we want such a interface. I didn't give it much
> time yet but I do not think this is a good idea at all.

Thanks for looking Michal.  The primary use case comes from devices that can
realize performance benefits if operating on physically contiguous memory.
What sparked this effort was Christoph and Guy's plumbers presentation
where they showed RDMA performance benefits that could be realized with
contiguous memory.  I also remember sitting in a presentation about
Intel's QuackAssist technology at Vault last year.  The presenter mentioned
that their compression engine needed to be passed a physically contiguous
buffer.  I asked how a user could obtain such a buffer.  They said they
had a special driver/ioctl for that.  Yuck!  I'm guessing there are other
specific use cases.  That is why I wanted to start the discussion as to
whether there should be an interface to provide this functionality.

>                                                         Why? Do we want
> any user to simply consume larger order memory blocks? What would
> prevent from that?

We certainly would want to put restrictions in place for contiguous
memory allocations.  Since it makes sense to pre-populate and lock
contiguous allocations, using the same restrictions as mlock is a start.
However, I can see the possible need for more restrictions.

>                    Also why should even userspace care about larger
> memory blocks? We have huge pages (be it preallocated or transparent)
> for that purpose already. Why should we add yet another another type

The 'sweet spot' for the Mellanox RDMA example is 2GB.  We can not
achieve that with huge pages (on x86) today.

>                                  What is the guaratee of such a mapping.

There is no guarantee.  My suggestion is that mmap(MAP_CONTIG) would fail
with ENOMEM if a sufficiently sized contiguous area could not be found.
The caller would need to deal with failure.

> Does the memory always stays contiguous? How much contiguous it will be?

Yes, it remains contiguous.  It is locked in memory.

> Who is going to use such an interface? And probably many other
> questions...

Thanks for asking.  I am just throwing out the idea of providing an interface
for doing contiguous memory allocations from user space.  There are at least
two (and possibly more) devices that could benefit from such an interface.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
