Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7245C6B0279
	for <linux-mm@kvack.org>; Tue,  4 Jul 2017 12:40:38 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id o8so110047939qtc.1
        for <linux-mm@kvack.org>; Tue, 04 Jul 2017 09:40:38 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b12si18897536qkb.344.2017.07.04.09.40.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Jul 2017 09:40:37 -0700 (PDT)
Date: Tue, 4 Jul 2017 18:40:34 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC PATCH] userfaultfd: Add feature to request for a signal
 delivery
Message-ID: <20170704164034.GH5738@redhat.com>
References: <20170627070643.GA28078@dhcp22.suse.cz>
 <20170627153557.GB10091@rapoport-lnx>
 <51508e99-d2dd-894f-8d8a-678e3747c1ee@oracle.com>
 <20170628131806.GD10091@rapoport-lnx>
 <3a8e0042-4c49-3ec8-c59f-9036f8e54621@oracle.com>
 <20170629080910.GC31603@dhcp22.suse.cz>
 <936bde7b-1913-5589-22f4-9bbfdb6a8dd5@oracle.com>
 <20170630094718.GE22917@dhcp22.suse.cz>
 <20170630130813.GA5738@redhat.com>
 <5956F2EC.1000805@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5956F2EC.1000805@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: prakash sangappa <prakash.sangappa@oracle.com>
Cc: Michal Hocko <mhocko@kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mike Kravetz <mike.kravetz@oracle.com>, Dave Hansen <dave.hansen@intel.com>, Christoph Hellwig <hch@infradead.org>, linux-api@vger.kernel.org, John Stultz <john.stultz@linaro.org>

On Fri, Jun 30, 2017 at 05:55:08PM -0700, prakash sangappa wrote:
> Interesting that UFFDIO_COPY is faster then fallocate().  In the DB use case
> the page does not need to be allocated at the time a process trips on 
> the hugetlbfs
> file hole and receives SIGBUS.  fallocate() is called on the hugetlbfs file,
> when more memory needs to be allocated by a separate process.

The major difference is that with UFFDIO_COPY the hugepage will be
immediately mapped into the virtual address without requiring any
further minor fault. So it's ideal if you could arrange to call
UFFDIO_COPY from the same process that is going to touch and use the
hugetlbfs data immediately after. You would eliminate a minor fault
that way.

UFFDIO_COPY at least for anon was measured to perform better than a
regular page fault too.

> Regarding hugetlbfs mount option, one consideration is to allow mounts of
> hugetlbfs inside user namespaces's mount namespace. Which would allow
> non privileged processes to mount hugetlbfs for use inside a user 
> namespace.
> This may be needed even for the 'min_size' mount option using which an
> application could reserve huge pages and mount a filesystem for its use,
> with out the need to have privileges given the system has enough hugepages
> configured.  It seems if non privileged processes are allowed to mount 
> hugetlbfs
> filesystem, then min_size should be subject to some resource limits.
> 
> Mounting inside user namespace will be a different patch proposal later.

There's no particular reason to make UFFDIO_FEATURE_SIGBUS a
privileged op unless we want to eliminate the branch with the static
key, so it's certainly simpler than dealing with hugetlbfs min_size
reserves.

I'm positive about the UFFDIO_FEATURE_SIGBUS tradeoffs, but others
feel free to comment.

If you could make second patch to extend the selftest to exercise and
validates UFFDIO_FEATURE_SIGBUS in anon/shmem/hugetlbfs it'd be great.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
