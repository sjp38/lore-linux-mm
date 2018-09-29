Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 67CCE8E0001
	for <linux-mm@kvack.org>; Sat, 29 Sep 2018 06:33:05 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id g8-v6so9757756otj.18
        for <linux-mm@kvack.org>; Sat, 29 Sep 2018 03:33:05 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id r23-v6si1337292otg.170.2018.09.29.03.33.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 29 Sep 2018 03:33:04 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w8TATm8F075952
	for <linux-mm@kvack.org>; Sat, 29 Sep 2018 06:33:03 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2mt5j9ka9b-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 29 Sep 2018 06:33:03 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Sat, 29 Sep 2018 11:33:01 +0100
Date: Sat, 29 Sep 2018 13:32:52 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/3] userfaultfd: selftest: recycle lock threads first
References: <20180929084311.15600-1-peterx@redhat.com>
 <20180929084311.15600-4-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180929084311.15600-4-peterx@redhat.com>
Message-Id: <20180929103252.GC6429@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Xu <peterx@redhat.com>
Cc: linux-kernel@vger.kernel.org, Shuah Khan <shuah@kernel.org>, Jerome Glisse <jglisse@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, Zi Yan <zi.yan@cs.rutgers.edu>, "Kirill A . Shutemov" <kirill@shutemov.name>, linux-kselftest@vger.kernel.org, Shaohua Li <shli@fb.com>, Andrea Arcangeli <aarcange@redhat.com>, "Dr . David Alan Gilbert" <dgilbert@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

On Sat, Sep 29, 2018 at 04:43:11PM +0800, Peter Xu wrote:
> Now we recycle the uffd servicing threads earlier than the lock
> threads.  It might happen that when the lock thread is still blocked at
> a pthread mutex lock while the servicing thread has already quitted for
> the cpu so the lock thread will be blocked forever and hang the test
> program.  To fix the possible race, recycle the lock threads first.
> 
> This never happens with current missing-only tests, but when I start to
> run the write-protection tests (the feature is not yet posted upstream)
> it happens every time of the run possibly because in that new test we'll
> need to service two page faults for each lock operation.
> 
> Signed-off-by: Peter Xu <peterx@redhat.com>

Acked-by: Mike Rapoport <rppt@linux.vnt.ibm.com>

> ---
>  tools/testing/selftests/vm/userfaultfd.c | 11 ++++++-----
>  1 file changed, 6 insertions(+), 5 deletions(-)
> 
> diff --git a/tools/testing/selftests/vm/userfaultfd.c b/tools/testing/selftests/vm/userfaultfd.c
> index f79706f13ce7..a388675b15af 100644
> --- a/tools/testing/selftests/vm/userfaultfd.c
> +++ b/tools/testing/selftests/vm/userfaultfd.c
> @@ -623,6 +623,12 @@ static int stress(unsigned long *userfaults)
>  	if (uffd_test_ops->release_pages(area_src))
>  		return 1;
> 
> +
> +	finished = 1;
> +	for (cpu = 0; cpu < nr_cpus; cpu++)
> +		if (pthread_join(locking_threads[cpu], NULL))
> +			return 1;
> +
>  	for (cpu = 0; cpu < nr_cpus; cpu++) {
>  		char c;
>  		if (bounces & BOUNCE_POLL) {
> @@ -640,11 +646,6 @@ static int stress(unsigned long *userfaults)
>  		}
>  	}
> 
> -	finished = 1;
> -	for (cpu = 0; cpu < nr_cpus; cpu++)
> -		if (pthread_join(locking_threads[cpu], NULL))
> -			return 1;
> -
>  	return 0;
>  }
> 
> -- 
> 2.17.1
> 

-- 
Sincerely yours,
Mike.
