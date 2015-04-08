Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id 911E46B0075
	for <linux-mm@kvack.org>; Wed,  8 Apr 2015 17:42:45 -0400 (EDT)
Received: by oblw8 with SMTP id w8so109690450obl.0
        for <linux-mm@kvack.org>; Wed, 08 Apr 2015 14:42:45 -0700 (PDT)
Received: from mail-ob0-x22a.google.com (mail-ob0-x22a.google.com. [2607:f8b0:4003:c01::22a])
        by mx.google.com with ESMTPS id a10si11961007oby.11.2015.04.08.14.42.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Apr 2015 14:42:44 -0700 (PDT)
Received: by obbeb7 with SMTP id eb7so84381986obb.3
        for <linux-mm@kvack.org>; Wed, 08 Apr 2015 14:42:44 -0700 (PDT)
Date: Wed, 8 Apr 2015 16:42:42 -0500
From: Shawn Bohrer <shawn.bohrer@gmail.com>
Subject: Re: HugePages_Rsvd leak
Message-ID: <20150408214242.GC29546@sbohrermbp13-local.rgmadvisors.com>
References: <20150408161539.GA29546@sbohrermbp13-local.rgmadvisors.com>
 <55259A95.3030500@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55259A95.3030500@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Apr 08, 2015 at 02:16:05PM -0700, Mike Kravetz wrote:
> On 04/08/2015 09:15 AM, Shawn Bohrer wrote:
> >I've noticed on a number of my systems that after shutting down my
> >application that uses huge pages that I'm left with some pages still
> >in HugePages_Rsvd.  It is possible that I still have something using
> >huge pages that I'm not aware of but so far my attempts to find
> >anything using huge pages have failed.  I've run some simple tests
> >using map_hugetlb.c from the kernel source and can see that pages that
> >have been reserved but not allocated still show up in
> >/proc/<pid>/smaps and /proc/<pid>/numa_maps.  Are there any cases
> >where this is not true?
> 
> Just a quick question.  Are you using hugetlb filesystem(s)?

I can't say for sure that nothing is using hugetlbfs. It is mounted
but as far as I can tell on the affected system(s) it is empty.

[root@dev106 ~]# grep hugetlbfs /proc/mounts
hugetlbfs /dev/hugepages hugetlbfs rw,relatime 0 0
[root@dev106 ~]# ls -al /dev/hugepages/
total 0
drwxr-xr-x  2 root root    0 Apr  8 16:22 .
drwxr-xr-x 16 root root 4360 Apr  8 03:53 ..
[root@dev106 ~]# lsof | grep hugepages

> If so, you might want to take a look at files residing in the
> filesystem(s).  As an experiment, I had a program do a simple
> mmap() of a file in a hugetlb filesystem.  The program just
> created the mapping, and did not actually fault/allocate any
> huge pages.  The result was the reservation (HugePages_Rsvd)
> of sufficient huge pages to cover the mapping.  When the program
> exited, the reservations remained.  If I remove (unlink) the
> file the reservations will be removed.

That makes sense but I don't think it is the issue here.

Thanks,
Shawn

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
