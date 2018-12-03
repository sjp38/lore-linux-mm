Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2CB166B6BAD
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 18:37:58 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id n95so15172712qte.16
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 15:37:58 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k15si2298567qke.86.2018.12.03.15.37.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 15:37:57 -0800 (PST)
Date: Mon, 3 Dec 2018 18:37:52 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH v8 0/7] mm: Merge hmm into devm_memremap_pages, mark
 GPL-only
Message-ID: <20181203233751.GA20742@redhat.com>
References: <154275556908.76910.8966087090637564219.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <154275556908.76910.8966087090637564219.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, stable@vger.kernel.org, Balbir Singh <bsingharora@gmail.com>, Logan Gunthorpe <logang@deltatee.com>, Christoph Hellwig <hch@lst.de>, Michal Hocko <mhocko@suse.com>, torvalds@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org

On Wed, Nov 21, 2018 at 05:20:55PM -0800, Andrew Morton wrote:
> On Tue, 20 Nov 2018 15:12:49 -0800 Dan Williams <dan.j.williams@intel.com> wrote:

[...]

> > I am also concerned that HMM was designed in a way to minimize further
> > engagement with the core-MM. That, with these hooks in place,
> > device-drivers are free to implement their own policies without much
> > consideration for whether and how the core-MM could grow to meet that
> > need. Going forward not only should HMM be EXPORT_SYMBOL_GPL, but the
> > core-MM should be allowed the opportunity and stimulus to change and
> > address these new use cases as first class functionality.
> > 
> 
> The arguments are compelling.  I apologize for not thinking of and/or
> not being made aware of them at the time.

So i wanted to comment on that part. Yes HMM is an impedence layer
that goes both way ie device driver are shielded from core mm and
core mm folks do not need to understand individual driver to modify
mm, they only need to understand what is provided to the driver by
HMM (and keeps HMM promise intact from driver POV no matter how it
is achieve). So this is intentional.

Nonetheless I want to grow core mm involvement in managing those
memory (see patchset i just posted about hbind() and heterogeneous
memory system). But i do not expect that core mm will be in full
control at least not for some time. The historical reasons is that
device like GPU are not only use for compute (which is where HMM
gets use) but also for graphics (simple desktop or even games).
Those are two differents workload using different API (CUDA/OpenCL
for compute, OpenGL/Vulkan for graphics) on the same underlying
hardware.

Those API expose the hardware in incompatible way when it comes to
memory management (especialy API like Vulkan). Managing memory page
wise is not well suited for graphics. The issues comes from the
fact that we do not want to exclude either workload from happening
concurrently (running your destkop while some compute job is running
in the background). So for this to work we need to keep the device
driver in control of its memory (hence why callback when page are
freed for instance). We also need to forbid things like pinning any
device memory pages ...


I still expect some commonality to emerge accross different hardware
so that we can grow more things and share more code into core mm but
i want to get their organicaly, not forcing everyone into a design
today. I expect this will happens by going from high level concept,
how things get use in userspace from end user POV, and working back-
ward from there to see what common API (if any) we can provided to
catter those common use case.

Cheers,
J�r�me
