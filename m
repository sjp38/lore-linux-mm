Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f170.google.com (mail-ie0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id A84316B0032
	for <linux-mm@kvack.org>; Fri, 24 Apr 2015 16:00:20 -0400 (EDT)
Received: by iebrs15 with SMTP id rs15so91542196ieb.3
        for <linux-mm@kvack.org>; Fri, 24 Apr 2015 13:00:20 -0700 (PDT)
Received: from resqmta-ch2-03v.sys.comcast.net (resqmta-ch2-03v.sys.comcast.net. [2001:558:fe21:29:69:252:207:35])
        by mx.google.com with ESMTPS id so2si10476669icb.67.2015.04.24.13.00.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 24 Apr 2015 13:00:19 -0700 (PDT)
Date: Fri, 24 Apr 2015 15:00:18 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Interacting with coherent memory on external devices
In-Reply-To: <20150424192859.GF3840@gmail.com>
Message-ID: <alpine.DEB.2.11.1504241446560.11700@gentwo.org>
References: <1429756456.4915.22.camel@kernel.crashing.org> <alpine.DEB.2.11.1504230925250.32297@gentwo.org> <20150423161105.GB2399@gmail.com> <alpine.DEB.2.11.1504240912560.7582@gentwo.org> <20150424150829.GA3840@gmail.com> <alpine.DEB.2.11.1504241052240.9889@gentwo.org>
 <20150424164325.GD3840@gmail.com> <alpine.DEB.2.11.1504241148420.10475@gentwo.org> <20150424171957.GE3840@gmail.com> <alpine.DEB.2.11.1504241353280.11285@gentwo.org> <20150424192859.GF3840@gmail.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, paulmck@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Fri, 24 Apr 2015, Jerome Glisse wrote:

> > Still no answer as to why is that not possible with the current scheme?
> > You keep on talking about pointers and I keep on responding that this is a
> > matter of making the address space compatible on both sides.
>
> So if do that in a naive way, how can we migrate a chunk of memory to video
> memory while still handling properly the case where CPU try to access that
> same memory while it is migrated to the GPU memory.

Well that the same issue that the migration code is handling which I
submitted a long time ago to the kernel.

> Without modifying a single line of mm code, the only way to do this is to
> either unmap from the cpu page table the range being migrated or to mprotect
> it in some way. In both case the cpu access will trigger some kind of fault.

Yes that is how Linux migration works. If you can fix that then how about
improving page migration in Linux between NUMA nodes first?

> This is not the behavior we want. What we want is same address space while
> being able to migrate system memory to device memory (who make that decision
> should not be part of that discussion) while still gracefully handling any
> CPU access.

Well then there could be a situation where you have concurrent write
access. How do you reconcile that then? Somehow you need to stall one or
the other until the transaction is complete.

> This means if CPU access it we want to migrate memory back to system memory.
> To achieve this there is no way around adding couple of if inside the mm
> page fault code path. Now do you want each driver to add its own if branch
> or do you want a common infrastructure to do just that ?

If you can improve the page migration in general then we certainly would
love that. Having faultless migration is certain a good thing for a lot of
functionality that depends on page migration.

> As i keep saying the solution you propose is what we have today, today we
> have fake share address space through the trick of remapping system memory
> at same address inside the GPU address space and also enforcing the use of
> a special memory allocator that goes behind the back of mm code.

Hmmm... I'd like to know more details about that.

> As you pointed out, not using GPU memory is a waste and we want to be able
> to use it. Now Paul have more sofisticated hardware that offer oportunities
> to do thing in a more transparent and efficient way.

Does this also work between NUMA nodes in a Power8 system?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
