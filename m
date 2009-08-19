Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id A5B766B004D
	for <linux-mm@kvack.org>; Wed, 19 Aug 2009 01:48:06 -0400 (EDT)
Received: by yxe14 with SMTP id 14so5462394yxe.12
        for <linux-mm@kvack.org>; Tue, 18 Aug 2009 22:48:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <56e00de0908180329p2a37da3fp43ddcb8c2d63336a@mail.gmail.com>
References: <alpine.LFD.2.00.0908172317470.32114@casper.infradead.org>
	 <56e00de0908180329p2a37da3fp43ddcb8c2d63336a@mail.gmail.com>
Date: Wed, 19 Aug 2009 17:48:11 +1200
Message-ID: <202cde0e0908182248we01324em2d24b9e741727a7b@mail.gmail.com>
Subject: Re: [PATCH 0/3]HTLB mapping for drivers (take 2)
From: Alexey Korolev <akorolex@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Eric Munson <linux-mm@mgebm.net>
Cc: Alexey Korolev <akorolev@infradead.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,
>
> It sounds like this patch set working towards the same goal as my
> MAP_HUGETLB set. =C2=A0The only difference I see is you allocate huge pag=
e
> at a time and (if I am understanding the patch) fault the page in
> immediately, where MAP_HUGETLB only faults pages as needed. =C2=A0Does th=
e
> MAP_HUGETLB patch set provide the functionality that you need, and if
> not, what can be done to provide what you need?
>
> Eric
>
Thanks a lot for willing to help. I'll be much appreciate if you have
an interesting idea how HTLB mapping for drivers can be done.

It is better to describe use case in order to make it clear what needs
to be done.
Driver provides mapping of device DMA buffers to user level
applications. User level applications process the data.
Device is using a master DMA to send data to the user buffer, buffer
size can be >1GB and performance is very important. (So huge pages
mapping really makes sense.)

In addition we have to mention that:
1. It is hard for user to tell how much huge pages needs to be
reserved by the driver.
2. Devices add constrains on memory regions. For example it needs to
be contiguous with in the physical address space. It is necessary to
have ability to specify special gfp flags.
3 The HW needs to access physical memory before the user level
software can access it. (Hugetlbfs picks up pages on page fault from
pool).
It means memory allocation needs to be driven by device driver.

Original idea was: create hugetlbfs file which has common mapping with
device file. Allocate memory. Populate page cache of hugetlbfs file
with allocated pages.
When fault occurs, page will be taken from page cache and then
remapped to user space by hugetlbfs.

Another possible approach is described here:
http://marc.info/?l=3Dlinux-mm&m=3D125065257431410&w=3D2
But currently not sure  will it work or not.


Thanks,
Alexey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
