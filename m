Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 302076B0032
	for <linux-mm@kvack.org>; Mon,  9 Mar 2015 07:29:46 -0400 (EDT)
Received: by pdbfl12 with SMTP id fl12so63117444pdb.9
        for <linux-mm@kvack.org>; Mon, 09 Mar 2015 04:29:45 -0700 (PDT)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id n9si29662551pap.184.2015.03.09.04.29.43
        for <linux-mm@kvack.org>;
        Mon, 09 Mar 2015 04:29:44 -0700 (PDT)
Date: Mon, 9 Mar 2015 22:29:36 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 4/4] mm: numa: Slow PTE scan rate if migration failures
 occur
Message-ID: <20150309112936.GD26657@destitution>
References: <1425741651-29152-1-git-send-email-mgorman@suse.de>
 <1425741651-29152-5-git-send-email-mgorman@suse.de>
 <20150307163657.GA9702@gmail.com>
 <CA+55aFwDuzpL-k8LsV3touhNLh+TFSLKP8+-nPwMXkWXDYPhrg@mail.gmail.com>
 <20150308100223.GC15487@gmail.com>
 <CA+55aFyQyZXu2fi7X9bWdSX0utk8=sccfBwFaSoToROXoE_PLA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFyQyZXu2fi7X9bWdSX0utk8=sccfBwFaSoToROXoE_PLA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ingo Molnar <mingo@kernel.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, xfs@oss.sgi.com, ppc-dev <linuxppc-dev@lists.ozlabs.org>

On Sun, Mar 08, 2015 at 11:35:59AM -0700, Linus Torvalds wrote:
> On Sun, Mar 8, 2015 at 3:02 AM, Ingo Molnar <mingo@kernel.org> wrote:
> But:
> 
> > As a second hack (not to be applied), could we change:
> >
> >  #define _PAGE_BIT_PROTNONE      _PAGE_BIT_GLOBAL
> >
> > to:
> >
> >  #define _PAGE_BIT_PROTNONE      (_PAGE_BIT_GLOBAL+1)
> >
> > to double check that the position of the bit does not matter?
> 
> Agreed. We should definitely try that.
> 
> Dave?

As Mel has already mentioned, I'm in Boston for LSFMM and don't have
access to the test rig I've used to generate this.

> Also, is there some sane way for me to actually see this behavior on a
> regular machine with just a single socket? Dave is apparently running
> in some fake-numa setup, I'm wondering if this is easy enough to
> reproduce that I could see it myself.

Should be - I don't actually use 500TB of storage to generate this -
50GB on an SSD is all you need from the storage side. I just use a
sparse backing file to make it look like a 500TB device. :P

i.e. create an XFS filesystem on a 500TB sparse file with "mkfs.xfs
-d size=500t,file=1 /path/to/file.img", mount it on loopback or as a
virtio,cache=none device for the guest vm and then use fsmark to
generate several million files spread across many, many directories
such as:

$  fs_mark -D 10000 -S0 -n 100000 -s 1 -L 32 -d \
/mnt/scratch/0 -d /mnt/scratch/1 -d /mnt/scratch/2 -d \
/mnt/scratch/3 -d /mnt/scratch/4 -d /mnt/scratch/5 -d \
/mnt/scratch/6 -d /mnt/scratch/7

That should only take a few minutes to run - if you throw 8p at it
then it should run at >100k files/s being created.

Then unmount and run "xfs_repair -o bhash=101703 /path/to/file.img"
on the resultant image file.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
