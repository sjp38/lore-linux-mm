Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 33F4C6B0639
	for <linux-mm@kvack.org>; Wed,  2 Aug 2017 18:27:21 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id q198so28745662qke.13
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 15:27:21 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 81si30452193qka.271.2017.08.02.15.27.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Aug 2017 15:27:19 -0700 (PDT)
Date: Thu, 3 Aug 2017 00:27:14 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 0/6] userfaultfd updates for v4.13-rc3
Message-ID: <20170802222714.GH21775@redhat.com>
References: <20170802165145.22628-1-aarcange@redhat.com>
 <20170802142925.4a3ad06ff7b0e769046f52db@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170802142925.4a3ad06ff7b0e769046f52db@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Maxime Coquelin <maxime.coquelin@redhat.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mike Kravetz <mike.kravetz@oracle.com>, Alexey Perevalov <a.perevalov@samsung.com>

On Wed, Aug 02, 2017 at 02:29:25PM -0700, Andrew Morton wrote:
> On Wed,  2 Aug 2017 18:51:39 +0200 Andrea Arcangeli <aarcange@redhat.com> wrote:
> 
> > Hello,
> > 
> > these are some uffd updates I have pending that looks ready for
> > merging. vhost-user KVM developement run into a crash so patch 1/6 is
> > urgent (and simple), the rest is not urgent.
> > 
> > The testcase has been updated to exercise it.
> > 
> > This should apply clean to -mm, and I reviewed in detail all other
> > userfaultfd patches that are in -mm and they're all great, including
> > the shmem zeropage addition.
> > 
> > Alexey Perevalov (1):
> >   userfaultfd: provide pid in userfault msg
> > 
> > Andrea Arcangeli (5):
> >   userfaultfd: hugetlbfs: remove superfluous page unlock in VM_SHARED
> >     case
> >   userfaultfd: selftest: exercise UFFDIO_COPY/ZEROPAGE -EEXIST
> >   userfaultfd: selftest: explicit failure if the SIGBUS test failed
> >   userfaultfd: call userfaultfd_unmap_prep only if __split_vma succeeds
> >   userfaultfd: provide pid in userfault msg - add feat union
> 
> I'm thinking "userfaultfd: hugetlbfs: remove superfluous page unlock in
> VM_SHARED case" goes into 4.13-rc and the other patches into 4.14-rc1. 
> Sound sane?

That would be perfect!

Mike spotted that 2/6 needs the incremental fix below, my compiler
didn't warn about it and the difference would be only noticeable in
case of fatal errors. I can resend 2/6 if you prefer.

diff --git a/tools/testing/selftests/vm/userfaultfd.c b/tools/testing/selftests/vm/userfaultfd.c
index 34838d5b33f3..a2c53a3d223d 100644
--- a/tools/testing/selftests/vm/userfaultfd.c
+++ b/tools/testing/selftests/vm/userfaultfd.c
@@ -813,13 +813,14 @@ static int uffdio_zeropage(int ufd, unsigned long offset)
 		if (uffdio_zeropage.zeropage != page_size) {
 			fprintf(stderr, "UFFDIO_ZEROPAGE unexpected %Ld\n",
 				uffdio_zeropage.zeropage), exit(1);
-		} else
+		} else {
 			if (test_uffdio_zeropage_eexist) {
 				test_uffdio_zeropage_eexist = false;
 				retry_uffdio_zeropage(ufd, &uffdio_zeropage,
 						      offset);
 			}
 			return 1;
+		}
 	} else {
 		fprintf(stderr,
 			"UFFDIO_ZEROPAGE succeeded %Ld\n",

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
