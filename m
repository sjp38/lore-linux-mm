Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 879186B0002
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 18:23:36 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id kx1so1538944pab.28
        for <linux-mm@kvack.org>; Mon, 01 Apr 2013 15:23:35 -0700 (PDT)
Date: Mon, 1 Apr 2013 15:23:33 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: THP: AnonHugePages in /proc/[pid]/smaps is correct or not?
In-Reply-To: <383590596.664138.1364803227470.JavaMail.root@redhat.com>
Message-ID: <alpine.DEB.2.02.1304011512490.17714@chino.kir.corp.google.com>
References: <383590596.664138.1364803227470.JavaMail.root@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhouping Liu <zliu@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Amos Kong <akong@redhat.com>

On Mon, 1 Apr 2013, Zhouping Liu wrote:

> Hi all,
> 
> I found THP can't correctly distinguish one anonymous hugepage map.
> 
> 1. when /sys/kernel/mm/transparent_hugepage/enabled is 'always', the
>    amount of THP always is one less.
> 

It's not a problem with identifying an anonymous mapping as a hugepage, 
setting thp enabled to "always" does not guarantee that they will always 
be allocatable or that your mmap() will be 2MB aligned.  Your sample code 
is using mmap() instead of posix_memalign() so you'll probably only get 
100% hugepages only 1/512th of the time.

> 2. when /sys/kernel/mm/transparent_hugepage/enabled is 'madvise', THP can't
>    distinguish any one anonymous hugepage size:
> 
>    Testing code:
> -------- snip --------
> unsigned long hugepagesize = (1UL << 21);
> 
> int main()
> {
> 	void *addr;
> 	int i;
> 
> 	printf("pid is %d\n", getpid());
> 
> 	for (i = 0; i < 5; i++) {
> 		addr = mmap(NULL, hugepagesize, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANON, -1, 0);
> 
> 		if (addr == MAP_FAILED) {
> 			perror("mmap");
> 			return -1;
> 		}
> 
> 		if (madvise(addr, hugepagesize, MADV_HUGEPAGE) == -1) {
> 			perror("madvise");
> 			return -1;
> 		}
> 
> 		memset(addr, i, hugepagesize);
> 	}
> 
> 	sleep(50);
> 
> 	return 0;
> }
> --------- snip ----------
> 
> The result is that it can't find any AnonHugePages from /proc/[pid]/smaps :
> -------------- snip -------
> 7f0b38cd0000-7f0b396d0000 rw-p 00000000 00:00 0
> Size:              10240 kB
> Rss:               10240 kB
> Pss:               10240 kB
> Shared_Clean:          0 kB
> Shared_Dirty:          0 kB
> Private_Clean:         0 kB
> Private_Dirty:     10240 kB
> Referenced:        10240 kB
> Anonymous:         10240 kB
> AnonHugePages:         0 kB
> Swap:                  0 kB
> KernelPageSize:        4 kB
> MMUPageSize:           4 kB
> Locked:                0 kB
> VmFlags: rd wr mr mw me ac

"hg" would be shown in VmFlags if your MADV_HUGEPAGE was successful, are 
you sure this is the right vma?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
