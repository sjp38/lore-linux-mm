Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id AFEF66B006C
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 10:18:58 -0400 (EDT)
Received: by iget9 with SMTP id t9so89223465ige.1
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 07:18:58 -0700 (PDT)
Received: from resqmta-po-09v.sys.comcast.net (resqmta-po-09v.sys.comcast.net. [2001:558:fe16:19:96:114:154:168])
        by mx.google.com with ESMTPS id x15si18483152ioi.89.2015.04.28.07.18.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 28 Apr 2015 07:18:57 -0700 (PDT)
Date: Tue, 28 Apr 2015 09:18:55 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Interacting with coherent memory on external devices
In-Reply-To: <20150427205206.GD26980@gmail.com>
Message-ID: <alpine.DEB.2.11.1504280907350.4809@gentwo.org>
References: <20150424192859.GF3840@gmail.com> <alpine.DEB.2.11.1504241446560.11700@gentwo.org> <20150425114633.GI5561@linux.vnet.ibm.com> <alpine.DEB.2.11.1504271004240.28895@gentwo.org> <20150427154728.GA26980@gmail.com> <alpine.DEB.2.11.1504271113480.29515@gentwo.org>
 <20150427164325.GB26980@gmail.com> <alpine.DEB.2.11.1504271148240.29735@gentwo.org> <20150427172143.GC26980@gmail.com> <alpine.DEB.2.11.1504271411060.30615@gentwo.org> <20150427205206.GD26980@gmail.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Mon, 27 Apr 2015, Jerome Glisse wrote:

> > is the mechanism that DAX relies on in the VM.
>
> Which would require fare more changes than you seem to think. First using
> MIXED|PFNMAP means we loose any kind of memory accounting and forget about
> memcg too. Seconds it means we would need to set those flags on all vma,
> which kind of point out that something must be wrong here. You will also
> need to have vm_ops for all those vma (including for anonymous private vma
> which sounds like it will break quite few place that test for that). Then
> you have to think about vma that already have vm_ops but you would need
> to override it to handle case where its device memory and then forward
> other case to the existing vm_ops, extra layering, extra complexity.

These vmas would only be used for those section of memory that use
memory in the coprocessor. Special memory accounting etc can be done at
the device driver layer. Multiple processes would be able to use different
GPU contexts (or devices) which provides proper isolations.

memcg is about accouting for regular memory and this is not regular
memory. It ooks like one would need a lot of special casing in
the VM if one wanted to handle f.e. GPU memory as regular memory under
Linux.

> I think at this point there is nothing more to discuss here. It is pretty
> clear to me that any solution using block device/MIXEDMAP would be far
> more complex and far more intrusive. I do not mind being prove wrong but
> i will certainly not waste my time trying to implement such solution.

The device driver method is the current solution used by the GPUS and
that would be the natural starting point for development. And they do not
currently add code to the core vm. I think we first need to figure out if
we cannot do what you want through that method.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
