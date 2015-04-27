Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f169.google.com (mail-yk0-f169.google.com [209.85.160.169])
	by kanga.kvack.org (Postfix) with ESMTP id 30EBB6B006E
	for <linux-mm@kvack.org>; Mon, 27 Apr 2015 12:51:55 -0400 (EDT)
Received: by ykep21 with SMTP id p21so20424478yke.3
        for <linux-mm@kvack.org>; Mon, 27 Apr 2015 09:51:53 -0700 (PDT)
Received: from resqmta-ch2-09v.sys.comcast.net (resqmta-ch2-09v.sys.comcast.net. [2001:558:fe21:29:69:252:207:41])
        by mx.google.com with ESMTPS id 76si11854137yhw.132.2015.04.27.09.51.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 27 Apr 2015 09:51:53 -0700 (PDT)
Date: Mon, 27 Apr 2015 11:51:51 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Interacting with coherent memory on external devices
In-Reply-To: <20150427164325.GB26980@gmail.com>
Message-ID: <alpine.DEB.2.11.1504271148240.29735@gentwo.org>
References: <20150424164325.GD3840@gmail.com> <alpine.DEB.2.11.1504241148420.10475@gentwo.org> <20150424171957.GE3840@gmail.com> <alpine.DEB.2.11.1504241353280.11285@gentwo.org> <20150424192859.GF3840@gmail.com> <alpine.DEB.2.11.1504241446560.11700@gentwo.org>
 <20150425114633.GI5561@linux.vnet.ibm.com> <alpine.DEB.2.11.1504271004240.28895@gentwo.org> <20150427154728.GA26980@gmail.com> <alpine.DEB.2.11.1504271113480.29515@gentwo.org> <20150427164325.GB26980@gmail.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Mon, 27 Apr 2015, Jerome Glisse wrote:

> > Well lets avoid that. Access to device memory comparable to what the
> > drivers do today by establishing page table mappings or a generalization
> > of DAX approaches would be the most straightforward way of implementing it
> > and would build based on existing functionality. Page migration currently
> > does not work with driver mappings or DAX because there is no struct page
> > that would allow the lockdown of the page. That may require either
> > continued work on the DAX with page structs approach or new developments
> > in the page migration logic comparable to the get_user_page() alternative
> > of simply creating a scatter gather table to just submit a couple of
> > memory ranges to the I/O subsystem thereby avoiding page structs.
>
> What you refuse to see is that DAX is geared toward filesystem and as such
> rely on special mapping. There is a reason why dax.c is in fs/ and not mm/
> and i keep pointing out we do not want our mecanism to be perceive as fs
> from userspace point of view. We want to be below the fs, at the mm level
> where we could really do thing transparently no matter what kind of memory
> we are talking about (anonymous, file mapped, share).

Ok that is why I mentioned the device memory mappings that are currently
used for this purpose. You could generalize the DAX approach (which I
understand as providing rw mappings to memory outside of the memory
managed by the kernel and not as a fs specific thing).

We can drop the DAX name and just talk about mapping to external memory if
that confuses the issue.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
