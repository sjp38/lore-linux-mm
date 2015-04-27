Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vn0-f52.google.com (mail-vn0-f52.google.com [209.85.216.52])
	by kanga.kvack.org (Postfix) with ESMTP id E350D6B0038
	for <linux-mm@kvack.org>; Mon, 27 Apr 2015 13:21:48 -0400 (EDT)
Received: by vnbf190 with SMTP id f190so12807197vnb.1
        for <linux-mm@kvack.org>; Mon, 27 Apr 2015 10:21:48 -0700 (PDT)
Received: from mail-vn0-x235.google.com (mail-vn0-x235.google.com. [2607:f8b0:400c:c0f::235])
        by mx.google.com with ESMTPS id xd8si30840998vdb.89.2015.04.27.10.21.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Apr 2015 10:21:47 -0700 (PDT)
Received: by vnbf1 with SMTP id f1so12803370vnb.5
        for <linux-mm@kvack.org>; Mon, 27 Apr 2015 10:21:47 -0700 (PDT)
Date: Mon, 27 Apr 2015 13:21:44 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: Interacting with coherent memory on external devices
Message-ID: <20150427172143.GC26980@gmail.com>
References: <20150424171957.GE3840@gmail.com>
 <alpine.DEB.2.11.1504241353280.11285@gentwo.org>
 <20150424192859.GF3840@gmail.com>
 <alpine.DEB.2.11.1504241446560.11700@gentwo.org>
 <20150425114633.GI5561@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1504271004240.28895@gentwo.org>
 <20150427154728.GA26980@gmail.com>
 <alpine.DEB.2.11.1504271113480.29515@gentwo.org>
 <20150427164325.GB26980@gmail.com>
 <alpine.DEB.2.11.1504271148240.29735@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <alpine.DEB.2.11.1504271148240.29735@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Mon, Apr 27, 2015 at 11:51:51AM -0500, Christoph Lameter wrote:
> On Mon, 27 Apr 2015, Jerome Glisse wrote:
> 
> > > Well lets avoid that. Access to device memory comparable to what the
> > > drivers do today by establishing page table mappings or a generalization
> > > of DAX approaches would be the most straightforward way of implementing it
> > > and would build based on existing functionality. Page migration currently
> > > does not work with driver mappings or DAX because there is no struct page
> > > that would allow the lockdown of the page. That may require either
> > > continued work on the DAX with page structs approach or new developments
> > > in the page migration logic comparable to the get_user_page() alternative
> > > of simply creating a scatter gather table to just submit a couple of
> > > memory ranges to the I/O subsystem thereby avoiding page structs.
> >
> > What you refuse to see is that DAX is geared toward filesystem and as such
> > rely on special mapping. There is a reason why dax.c is in fs/ and not mm/
> > and i keep pointing out we do not want our mecanism to be perceive as fs
> > from userspace point of view. We want to be below the fs, at the mm level
> > where we could really do thing transparently no matter what kind of memory
> > we are talking about (anonymous, file mapped, share).
> 
> Ok that is why I mentioned the device memory mappings that are currently
> used for this purpose. You could generalize the DAX approach (which I
> understand as providing rw mappings to memory outside of the memory
> managed by the kernel and not as a fs specific thing).
> 
> We can drop the DAX name and just talk about mapping to external memory if
> that confuses the issue.

DAX is for direct access block layer (X is for the cool name factor)
there is zero code inside DAX that would be usefull to us. Because it
is all about filesystem and short circuiting the pagecache. So DAX is
_not_ about providing rw mappings to non regular memory, it is about
allowing to directly map _filesystem backing storage_ into a process.
Moreover DAX is not about managing that persistent memory, all the
management is done inside the fs (ext4, xfs, ...) in the same way as
for non persistent memory. While in our case we want to manage the
memory as a runtime resources that is allocated to process the same
way regular system memory is managed.

So current DAX code have nothing of value for our usecase nor what we
propose will have anyvalue for DAX. Unless they decide to go down the
struct page road for persistent memory (which from last discussion i
heard was not there plan, i am pretty sure they entirely dismissed
that idea for now).

My point is that this is 2 differents non overlapping problems, and
thus mandate 2 differents solution.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
