Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f179.google.com (mail-ob0-f179.google.com [209.85.214.179])
	by kanga.kvack.org (Postfix) with ESMTP id A08B76B0032
	for <linux-mm@kvack.org>; Wed,  8 Apr 2015 16:19:30 -0400 (EDT)
Received: by obbgh1 with SMTP id gh1so147671772obb.1
        for <linux-mm@kvack.org>; Wed, 08 Apr 2015 13:19:30 -0700 (PDT)
Received: from mail-ob0-x22f.google.com (mail-ob0-x22f.google.com. [2607:f8b0:4003:c01::22f])
        by mx.google.com with ESMTPS id y4si11766582oej.86.2015.04.08.13.19.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Apr 2015 13:19:29 -0700 (PDT)
Received: by oblw8 with SMTP id w8so106399303obl.0
        for <linux-mm@kvack.org>; Wed, 08 Apr 2015 13:19:29 -0700 (PDT)
Date: Wed, 8 Apr 2015 15:19:26 -0500
From: Shawn Bohrer <shawn.bohrer@gmail.com>
Subject: Re: HugePages_Rsvd leak
Message-ID: <20150408201926.GB29546@sbohrermbp13-local.rgmadvisors.com>
References: <20150408161539.GA29546@sbohrermbp13-local.rgmadvisors.com>
 <1428521343.11099.4.camel@stgolabs.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1428521343.11099.4.camel@stgolabs.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Apr 08, 2015 at 12:29:03PM -0700, Davidlohr Bueso wrote:
> On Wed, 2015-04-08 at 11:15 -0500, Shawn Bohrer wrote:
> > AnonHugePages:    241664 kB
> > HugePages_Total:     512
> > HugePages_Free:      512
> > HugePages_Rsvd:      384
> > HugePages_Surp:        0
> > Hugepagesize:       2048 kB
> > 
> > So here I have 384 pages reserved and I can't find anything that is
> > using them. 
> 
> The output clearly shows all available hugepages are free, Why are you
> assuming that reserved implies allocated/in use? This is not true,
> please read one of the millions of docs out there -- you can start with:
> https://www.kernel.org/doc/Documentation/vm/hugetlbpage.txt
 
As that fine document states:

HugePages_Rsvd  is short for "reserved," and is the number of huge pages for
                which a commitment to allocate from the pool has been made,
                but no allocation has yet been made.  Reserved huge pages
                guarantee that an application will be able to allocate a
                huge page from the pool of huge pages at fault time.

Thus in my example above while I have 512 pages free 384 are reserved
and therefore if a new application comes along it can only reserve/use
the remaining 128 pages.

For example:

[scratch]$ grep Huge /proc/meminfo 
AnonHugePages:         0 kB
HugePages_Total:       1
HugePages_Free:        1
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:       2048 kB

[scratch]$ cat map_hugetlb.c
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/mman.h>

#define LENGTH (2UL*1024*1024)
#define PROTECTION (PROT_READ | PROT_WRITE)
#define ADDR (void *)(0x0UL)
#define FLAGS (MAP_PRIVATE | MAP_ANONYMOUS | MAP_HUGETLB)

int main(void)
{
        void *addr;
        addr = mmap(ADDR, LENGTH, PROTECTION, FLAGS, 0, 0);
        if (addr == MAP_FAILED) {
                perror("mmap");
                exit(1);
        }

        getchar();

        munmap(addr, LENGTH);
        return 0;
}

[scratch]$ make map_hugetlb
cc     map_hugetlb.c   -o map_hugetlb

[scratch]$ ./map_hugetlb &
[1] 7359
[1]+  Stopped                 ./map_hugetlb

[scratch]$ grep Huge /proc/meminfo 
AnonHugePages:         0 kB
HugePages_Total:       1
HugePages_Free:        1
HugePages_Rsvd:        1
HugePages_Surp:        0
Hugepagesize:       2048 kB

[scratch]$ ./map_hugetlb
mmap: Cannot allocate memory


As you can see I still have 1 huge page free but that one huge page is
reserved by PID 7358.  If I then try to run a new map_hugetlb process
the mmap fails because even though I have 1 page free it is reserved.

Furthermore we can find that 7358 has that page in the following ways:

[scratch]$ sudo grep "KernelPageSize:.*2048" /proc/*/smaps
/proc/7359/smaps:KernelPageSize:     2048 kB
[scratch]$ sudo grep "VmFlags:.*ht" /proc/*/smaps
/proc/7359/smaps:VmFlags: rd wr mr mw me de ht sd
[scratch]$ sudo grep -w huge /proc/*/numa_maps
/proc/7359/numa_maps:7f3233000000 default file=/anon_hugepage\040(deleted) huge

Which leads back to my original question.  I have machines that have a
non-zero HugePages_Rsvd count but I cannot find any processes that
seem to have those pages reserved using the three methods shown above.
Is there some other way to identify which process has those pages
reserved?  Or is there possibly a leak which is failing to decrement
the reserve count?

Thanks,
Shawn

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
