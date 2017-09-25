Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id EA6A26B0038
	for <linux-mm@kvack.org>; Mon, 25 Sep 2017 07:41:23 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id x85so7673478oix.3
        for <linux-mm@kvack.org>; Mon, 25 Sep 2017 04:41:23 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b204si3496247oif.199.2017.09.25.04.41.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Sep 2017 04:41:22 -0700 (PDT)
Date: Mon, 25 Sep 2017 13:41:18 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC v1 0/2] Per-arch page checksumming and comparison
Message-ID: <20170925114118.GO31084@redhat.com>
References: <1506329174-19265-1-git-send-email-imbrenda@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1506329174-19265-1-git-send-email-imbrenda@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, borntraeger@de.ibm.com, kvm@vger.kernel.org, linux-mm@kvack.org, nefelim4ag@gmail.com, akpm@linux-foundation.org, mingo@kernel.org, zhongjiang@huawei.com, kirill.shutemov@linux.intel.com, arvind.yadav.cs@gmail.com, solee@os.korea.ac.kr, ak@linux.intel.com

On Mon, Sep 25, 2017 at 10:46:12AM +0200, Claudio Imbrenda wrote:
> Since we now have two different proposals on how to speed up KSM, I
> thought I'd share what I had done too, so we can now have three :)
> 
> I have analysed the performance of KSM, and I have found out that both
> the checksum and the memcmp take up a significant amount of time.
> Depending on the content of the pages, either function can be the
> "bottleneck".
> 
> I did some synthetic benchmarks, using different checksum functions and
> with different page content scenarios. Only in the best case (e.g.
> pages differing at the very beginning) was the checksum consuming more
> CPU time than the memcmps.
> Using a simpler function (like CRC32 or even just a simple sum)
> significantly reduced the CPU load. 
> In other scenarios, like when the pages differ in the middle or at the
> end, the biggest offender is the memcmp. Still, using simpler checksums
> lowers the overall CPU load.
> 
> The idea I had in this patchseries was to provide arch-overridable
> functions to checksum and compare whole pages.

I suppose you want to create a memcmp function that compares bits and
pieces not in physical address order? Why to do that only on s390 or
per arch? That issue is common for all archs. If then you want to
implement memcmp_scatter1 (or how you want to call it) different for
each archs, that is an override for memcmp_scatter1, but the common
code version of memcmp_scatter1 should still do memcmp_scatter1 not
fallback in per-arch optimized memcmp.

> Depending on the arch, the best memcmp/checksum to use in the
> specialized case of comparing/checksumming one whole page might not
> necessarily be the one that is the best in the general case. So what I
> did here was to factor out the old code and make it generic, and then
> provide an s390-specific implementation for the checksum using the CKSM
> instruction, which is also used to calculate the checksum of IP
> headers, the idea being that other architectures can then follow and
> use their preferred checksum.

IP csum as in csum_partial feels very weak to me.

> I like Sioh Lee's proposal of using the crypto API to choose a fast but
> good checksum, since this can be made arch-dependant too, and CRC32 is
> also almost as fast as the simple checksum. Also, I had underestimated
> how many more collisions the simple checksum could potentially cause
> (although I did not see any performance regressions in my tests).
> 
> While there is a crypto API to choose between different hash functions,
> there is nothing like that for page comparison.
> 
> 
> I think at this point we need to coordinate a little, to avoid
> reinventing the wheel three times and in different ways.

Yes.

I don't like that these memcmp and cksum variants are hardcoded in the
kernel and not tunable with sysfs and even different across archs
which invalidates all testing we do on x86.

I like that from an algorithmic point of view KSM works the same with
default settings on all archs. And then you can tune it with sysfs
setting csum or jhash2 as hash, or memcmp_scatter1 instead of memcmp
as mem comparison. It's trivial to implement the tuning, just need to
wait for run == 2, same as altering the ksm_max_page_sharing.

The performance of the scan I think are secondary in priority than
keeping the algorithms the same so that testing on one arch when all
common code behaves the same in all archs, guarantees things will work
ok on s390 too.

There are a ton of workloads KSM has to handle, so having to double up
the testing isn't ideal, even if IP csum worked for your tests. Doing
things in steps (and also in a way that is easy to rollback if any
problem is then found in practice) seems safer. This way we could keep
also a sysfs jhash2 fallback (in case anybody has issues with
crc32c-intel on x86 or crc32c-be on s390).

If certain selectable tunings for memcmp_fn and cksum_fn then work
better for different archs, different arch would just need to change
the defaults for such tunings value then. The cksum or page function
would not be hardcoded per-arch this way, and if there's a problem
then if s390 in the future alters one default, one just needs to add a
sysctl tweak and not require a downgrade of the kernel to restore the
previous behavior. It'll require two pointer two functions compared to
the hardcoding, but I think it's safer that way. We could always
hardcode later to drop those two pointer to functions in invoking
cksum variants and memcmp variants, once we're sure there are no
regressions and enough testing has been done on enough different
workloads. The best feature is however that if arch alters the default
tuning, it's trivial to fix and restore the previous behavior with
sysfs.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
