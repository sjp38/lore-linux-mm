Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id F135F8D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 15:06:57 -0400 (EDT)
From: Sean Noonan <Sean.Noonan@twosigma.com>
Date: Tue, 29 Mar 2011 15:05:28 -0400
Subject: RE: XFS memory allocation deadlock in 2.6.38
Message-ID: <081DDE43F61F3D43929A181B477DCA95639B5359@MSXAOA6.twosigma.com>
References: <081DDE43F61F3D43929A181B477DCA95639B52FD@MSXAOA6.twosigma.com>
	<081DDE43F61F3D43929A181B477DCA95639B5327@MSXAOA6.twosigma.com>
	<20110324174311.GA31576@infradead.org>
	<AANLkTikwwRm6FHFtEdUg54NvmKdswQw-NPH5dtq1mXBK@mail.gmail.com>
	<081DDE43F61F3D43929A181B477DCA95639B5349@MSXAOA6.twosigma.com>
 <BANLkTin0jJevStg5P2hqsLbqMzo3o30sYg@mail.gmail.com>
 <081DDE43F61F3D43929A181B477DCA95639B534E@MSXAOA6.twosigma.com>
In-Reply-To: <081DDE43F61F3D43929A181B477DCA95639B534E@MSXAOA6.twosigma.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sean Noonan <Sean.Noonan@twosigma.com>, 'Michel Lespinasse' <walken@google.com>
Cc: 'Christoph Hellwig' <hch@infradead.org>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, Martin Bligh <Martin.Bligh@twosigma.com>, Trammell Hudson <Trammell.Hudson@twosigma.com>, Christos Zoulas <Christos.Zoulas@twosigma.com>, "'linux-xfs@oss.sgi.com'" <linux-xfs@oss.sgi.com>, Stephen Degler <Stephen.Degler@twosigma.com>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>

>> Could you test if you see the deadlock before
>> 5ecfda041e4b4bd858d25bbf5a16c2a6c06d7272 without MAP_POPULATE ?

> Built and tested 72ddc8f72270758951ccefb7d190f364d20215ab.
> Confirmed that the original bug does not present in this version.
> Confirmed that removing MAP_POPULATE does cause the deadlock to occur.

git bisect leads to this:

bdfb04301fa5fdd95f219539a9a5b9663b1e5fc2 is the first bad commit
commit bdfb04301fa5fdd95f219539a9a5b9663b1e5fc2
Author: Christoph Hellwig <hch@infradead.org>
Date:   Wed Jan 20 21:55:30 2010 +0000

    xfs: replace KM_LARGE with explicit vmalloc use
   =20
    We use the KM_LARGE flag to make kmem_alloc and friends use vmalloc
    if necessary.  As we only need this for a few boot/mount time
    allocations just switch to explicit vmalloc calls there.
   =20
    Signed-off-by: Christoph Hellwig <hch@lst.de>
    Signed-off-by: Alex Elder <aelder@sgi.com>

:040000 040000 1eed68ced17d8794fa842396c01c3b9677c6e709 d462932a318f8c823fa=
2a73156e980a688968cb2 M	fs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
