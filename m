Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3E24C6B0385
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 19:37:38 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id w132so6262854ita.1
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 16:37:38 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w10si329508itf.56.2016.11.17.16.37.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Nov 2016 16:37:37 -0800 (PST)
Date: Fri, 18 Nov 2016 01:37:34 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 25/33] userfaultfd: shmem: add userfaultfd hook for
 shared memory faults
Message-ID: <20161118003734.GC10229@redhat.com>
References: <1478115245-32090-1-git-send-email-aarcange@redhat.com>
 <1478115245-32090-26-git-send-email-aarcange@redhat.com>
 <07ce01d23679$c2be2670$483a7350$@alibaba-inc.com>
 <20161104154438.GD5605@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161104154438.GD5605@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Hillf Danton <hillf.zj@alibaba-inc.com>, 'Andrew Morton' <akpm@linux-foundation.org>, linux-mm@kvack.org, 'Mike Kravetz' <mike.kravetz@oracle.com>, "'Dr. David Alan Gilbert'" <dgilbert@redhat.com>, 'Shaohua Li' <shli@fb.com>, 'Pavel Emelyanov' <xemul@virtuozzo.com>

Hello,

I found a minor issue with the non cooperative testcase, sometime an
userfault would trigger in between UFFD_EVENT_MADVDONTNEED and
UFFDIO_UNREGISTER:

		case UFFD_EVENT_MADVDONTNEED:
			uffd_reg.range.start = msg.arg.madv_dn.start;
			uffd_reg.range.len = msg.arg.madv_dn.end -
				msg.arg.madv_dn.start;
			if (ioctl(uffd, UFFDIO_UNREGISTER, &uffd_reg.range))

It always triggered at the nr == 0:

	for (nr = 0; nr < nr_pages; nr++) {
		if (my_bcmp(area_dst + nr * page_size, zeropage, page_size))

The userfault still pending after UFFDIO_UNREGISTER returned, lead to
poll() getting a UFFD_EVENT_PAGEFAULT and trying to do a UFFDIO_COPY
into the unregistered range, which gracefully results in -EINVAL.

So this could be all handled in userland, by storing the MADV_DONTNEED
range and calling UFFDIO_WAKE instead of UFFDIO_COPY... but I think
it's more reliable to fix it into the kernel.

If a pending userfault happens before UFFDIO_UNREGISTER it'll just
behave like if it happened after.

I also noticed the order of uffd notification of MADV_DONTNEED and the
pagetable zap was wrong, we've to notify userland first so it won't
risk to call UFFDIO_COPY while the process runs zap_page_range.

With the two patches appended below the -EINVAL error out of
UFFDIO_COPY is gone.
