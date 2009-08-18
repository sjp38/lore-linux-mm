Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id F2C426B004D
	for <linux-mm@kvack.org>; Tue, 18 Aug 2009 06:29:44 -0400 (EDT)
Received: by ewy22 with SMTP id 22so3969166ewy.4
        for <linux-mm@kvack.org>; Tue, 18 Aug 2009 03:29:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LFD.2.00.0908172317470.32114@casper.infradead.org>
References: <alpine.LFD.2.00.0908172317470.32114@casper.infradead.org>
Date: Tue, 18 Aug 2009 11:29:43 +0100
Message-ID: <56e00de0908180329p2a37da3fp43ddcb8c2d63336a@mail.gmail.com>
Subject: Re: [PATCH 0/3]HTLB mapping for drivers (take 2)
From: Eric Munson <linux-mm@mgebm.net>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Alexey Korolev <akorolev@infradead.org>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 17, 2009 at 11:24 PM, Alexey Korolev<akorolev@infradead.org> wr=
ote:
> Hi,
>
> The patch set listed below provides device drivers with the ability to
> map memory regions to user space via HTLB interfaces.
>
> Why we need it?
> Device drivers often need to map memory regions to user-space to allow
> efficient data handling in user mode. Involving hugetlb mapping may
> bring performance gain if mapped regions are relatively large. Our tests
> showed that it is possible to gain up to 7% performance if hugetlb
> mapping is enabled. In my case involving hugetlb starts to make sense if
> buffer is more or equal to 4MB. Since typically, device throughput
> increase over time there are more and more reasons to involve huge pages
> to remap large regions.
> For example hugetlb remapping could be important for performance of Data
> acquisition systems (logic analyzers, DSO), Network monitoring systems
> (packet capture), HD video capture/frame buffer =A0and probably other.
>
> How it is implemented?
> Implementation and idea is very close to what is already done in
> ipc/shm.c.
> We create file on hugetlbfs vfsmount point and populate file with pages
> we want to mmap. Then we associate hugetlbfs file mapping with file
> mapping we want to access.
>
> So typical procedure for mapping of huge pages to userspace by drivers
> should be:
> 1 Allocate some huge pages
> 2 Create file on vfs mount of hugetlbfs
> 3 Add pages to page cache of mapping associated with hugetlbfs file
> 4 Replace file's mapping with the hugetlbfs file mapping
> ..............
> 5 Remove pages from page cache
> 6 Remove hugetlbfs file
> 7 Free pages
> (Please find example in following messages)
>
> Detailed description is given in the following messages.
> Thanks a lot to Mel Gorman who gave good advice and code prototype and
> Stephen Donnelly for assistance in description composing.
>
> Alexey

It sounds like this patch set working towards the same goal as my
MAP_HUGETLB set.  The only difference I see is you allocate huge page
at a time and (if I am understanding the patch) fault the page in
immediately, where MAP_HUGETLB only faults pages as needed.  Does the
MAP_HUGETLB patch set provide the functionality that you need, and if
not, what can be done to provide what you need?

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
