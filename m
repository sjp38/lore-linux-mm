Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f41.google.com (mail-yh0-f41.google.com [209.85.213.41])
	by kanga.kvack.org (Postfix) with ESMTP id 2CD6E6B006E
	for <linux-mm@kvack.org>; Mon, 27 Apr 2015 12:43:32 -0400 (EDT)
Received: by yhda23 with SMTP id a23so19778538yhd.2
        for <linux-mm@kvack.org>; Mon, 27 Apr 2015 09:43:32 -0700 (PDT)
Received: from mail-vn0-x229.google.com (mail-vn0-x229.google.com. [2607:f8b0:400c:c0f::229])
        by mx.google.com with ESMTPS id d5si11861687ykf.174.2015.04.27.09.43.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Apr 2015 09:43:31 -0700 (PDT)
Received: by vnbg1 with SMTP id g1so12638195vnb.2
        for <linux-mm@kvack.org>; Mon, 27 Apr 2015 09:43:31 -0700 (PDT)
Date: Mon, 27 Apr 2015 12:43:27 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: Interacting with coherent memory on external devices
Message-ID: <20150427164325.GB26980@gmail.com>
References: <20150424164325.GD3840@gmail.com>
 <alpine.DEB.2.11.1504241148420.10475@gentwo.org>
 <20150424171957.GE3840@gmail.com>
 <alpine.DEB.2.11.1504241353280.11285@gentwo.org>
 <20150424192859.GF3840@gmail.com>
 <alpine.DEB.2.11.1504241446560.11700@gentwo.org>
 <20150425114633.GI5561@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1504271004240.28895@gentwo.org>
 <20150427154728.GA26980@gmail.com>
 <alpine.DEB.2.11.1504271113480.29515@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <alpine.DEB.2.11.1504271113480.29515@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Mon, Apr 27, 2015 at 11:17:43AM -0500, Christoph Lameter wrote:
> On Mon, 27 Apr 2015, Jerome Glisse wrote:
> 
> > > Improvements to the general code would be preferred instead of
> > > having specialized solutions for a particular hardware alone.  If the
> > > general code can then handle the special coprocessor situation then we
> > > avoid a lot of code development.
> >
> > I think Paul only big change would be the memory ZONE changes. Having a
> > way to add the device memory as struct page while blocking the kernel
> > allocation from using this memory. Beside that i think the autonuma changes
> > he would need would really be specific to his usecase but would still
> > reuse all of the low level logic.
> 
> Well lets avoid that. Access to device memory comparable to what the
> drivers do today by establishing page table mappings or a generalization
> of DAX approaches would be the most straightforward way of implementing it
> and would build based on existing functionality. Page migration currently
> does not work with driver mappings or DAX because there is no struct page
> that would allow the lockdown of the page. That may require either
> continued work on the DAX with page structs approach or new developments
> in the page migration logic comparable to the get_user_page() alternative
> of simply creating a scatter gather table to just submit a couple of
> memory ranges to the I/O subsystem thereby avoiding page structs.

What you refuse to see is that DAX is geared toward filesystem and as such
rely on special mapping. There is a reason why dax.c is in fs/ and not mm/
and i keep pointing out we do not want our mecanism to be perceive as fs
from userspace point of view. We want to be below the fs, at the mm level
where we could really do thing transparently no matter what kind of memory
we are talking about (anonymous, file mapped, share).

The fact is that DAX is about persistant storage but the people that
develop the persitant storage think it would be nice to expose it as some
kind of special memory. I am all for the direct mapping of this kind of
memory but still it is use as a backing store for a filesystem.

While in our case we are talking about "usual" _volatile_ memory that
should be use or expose as a filesystem.

I can't understand why you are so hellbent on the DAX paradigm, but it is
not what suit us in no way. We are not filesystem, we are regular memory,
our realm is mm/ not fs/

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
