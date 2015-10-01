Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f51.google.com (mail-qg0-f51.google.com [209.85.192.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0D8D782F69
	for <linux-mm@kvack.org>; Wed, 30 Sep 2015 20:06:31 -0400 (EDT)
Received: by qgev79 with SMTP id v79so50695249qge.0
        for <linux-mm@kvack.org>; Wed, 30 Sep 2015 17:06:30 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w72si3201769qha.53.2015.09.30.17.06.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Sep 2015 17:06:30 -0700 (PDT)
Date: Thu, 1 Oct 2015 02:06:25 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00/12] userfaultfd non-x86 and selftest updates for 4.2.0+
Message-ID: <20151001000625.GF19466@redhat.com>
References: <1441745010-14314-1-git-send-email-aarcange@redhat.com>
 <560C5A83.9080103@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <560C5A83.9080103@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Pavel Emelyanov <xemul@parallels.com>, zhang.zhanghailiang@huawei.com, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Michael Ellerman <mpe@ellerman.id.au>, Bamvor Zhang Jian <bamvor.zhangjian@linaro.org>, Bharata B Rao <bharata@linux.vnet.ibm.com>, Geert Uytterhoeven <geert@linux-m68k.org>

Hello Mike,

On Wed, Sep 30, 2015 at 02:56:19PM -0700, Mike Kravetz wrote:
> On 09/08/2015 01:43 PM, Andrea Arcangeli wrote:
> > Here are some pending updates for userfaultfd mostly to the self test,
> > the rest are cleanups.
> 
> I have a potential use case for userfualtfd.  So, I started experimenting

Glad to hear you may have one more use case.

On a side note, there's also a patch posted to CRIU to pagein lazily
anonymous memory during restore using userfaultfd, that's yet another
recent user.

> with the self test code.  I replaced the posix_memalign() calls to allocate
> area_src and area_dst with mmap().  mmap(MAP_PRIVATE | MAP_ANONYMOUS) works
> as expected.  However, mmap(MAP_SHARED | MAP_ANONYMOUS) causes the test to
> fail without any errros from the userfaultfd APIs.
> 
> --------------------
> running userfaultfd
> --------------------
> nr_pages: 32768, nr_pages_per_cpu: 8192
> bounces: 31, mode: rnd racing ver poll, page_nr 31523 wrong count 0 1
> 
> I would expect some type of error from the ioctl() that registers the
> range, or perhaps the poll/copy code?  Just curious about the expected
> behavior.

That should return an error during UFFDIO_REGISTER and the testcase
shouldn't start, not sure what went wrong. Can you send the
modification to the testcase?

UFFDIO_REGISTER is the point where userfaultfd is first told which
kind of memory you want to manage with userfaults. It was planned to
fail there (and it cannot fail any earlier).

This check has to fail and return -EINVAL in the ioctl(UFFDIO_REGISTER).

		/* check not compatible vmas */
		ret = -EINVAL;
		if (cur->vm_ops)
			goto out_unlock;

In the testcase you should get an exit 1 and the fprintf printed:

		if (ioctl(uffd, UFFDIO_REGISTER, &uffdio_register)) {
			fprintf(stderr, "register failure\n");
			return 1;
		}

Could you double check these two paths to find what's wrong?

> FYI - My use case is for hugetlbfs.  I would like a mechanism to catch all
> new huge page allocations as a result of page faults.  I have some very
> rough code to extend userfualtfd and add the required functionality to
> hugetlbfs.  Still working on it.

Adding support for hugetlbfs sounds great to me.

Only anonymous memory has null vm_ops, so once you extend the code to
track hugetlbfs (tracking at least tmpfs and not just anonymous memory
is needed for volatile pages which also work on tmpfs) you should
relax the above check to accept &hugetlb_vm_ops.

You then need to specify which kind of ioctl you supported in the
current kernel for that kind of memory you registered on in the
uffdio_register->ioctl parameter.

		/*
		 * Now that we scanned all vmas we can already tell
		 * userland which ioctls methods are guaranteed to
		 * succeed on this range.
		 */
		if (put_user(UFFD_API_RANGE_IOCTLS,
			     &user_uffdio_register->ioctls))
			ret = -EFAULT;

#define UFFD_API_RANGE_IOCTLS			\
	((__u64)1 << _UFFDIO_WAKE |		\
	 (__u64)1 << _UFFDIO_COPY |		\
	 (__u64)1 << _UFFDIO_ZEROPAGE)

hugetlbfs doesn't seem to support the zeropage. So if vma->vm_ops ==
&hugetlb_vm_ops, it should return only WAKE|COPY in
uffdio_register->ioctl.

hugetlbfs is non standard, there's no sysconf(_SC_PAGE_SIZE) to know
the minimum granularity supported by the UFFDIO_COPY|WAKE of
hugetlbfs. This is a generic issue with hugetlbfs, not really related
to userfaultfd. The same constraints of hugetlbfs minimum granularity
and alignment applies to all other memory management syscalls too.

So the app itself using hugetlbfs will have to know by other means
(i.e. sysfs mangling) that the minimum granularity supported by
UFFDIO_COPY is 2MB (or 1GB). That is again because it registered
userfaultfd on hugetlbfs, and hugetlbfs has non standard
constraints. In turn UFFDIO_COPY of hugetlbfs has to fail if len is
not a multiple of 2MB (never the case for all other kinds of memory
that userfaultfd could ever manage).

There's flexibility in the userfaultfd API to gradually expand the
coverage to a variety of types of virtual memory while at the same
time not risking random behavior from a new app if run on a old
kernel. The new app will be able to tell reliably to the user, to
upgrade the kernel (or it can fallback to a non-userfaultfd mode with
just a warning to the user).

We need to handle the write protection faults too as soon as possible
(VM_UFFD_WP/UFFD_FEATURE_PAGEFAULT_FLAG_WP). The uffdio_api->features
are already prepared to report to userland the availability of the
UFFD_FEATURE_PAGEFAULT_FLAG_WP. Then the app can set
UFFDIO_REGISTER_MODE_WP in uffdio_register.mode.

I mentioned this because while there's flexibility to expand the
coverage gradually, it'd be great if all kinds of memory supporting
UFFDIO_REGISTER_MODE_MISSING would also support
UFFDIO_REGISTER_MODE_WP once that gets available, as it'd keep
userfaultfd_register() a bit simpler to maintain.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
