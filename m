Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6B8CC2802FE
	for <linux-mm@kvack.org>; Fri, 30 Jun 2017 20:55:20 -0400 (EDT)
Received: by mail-ua0-f197.google.com with SMTP id g40so48339647uaa.4
        for <linux-mm@kvack.org>; Fri, 30 Jun 2017 17:55:20 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id q8si4377221vkd.207.2017.06.30.17.55.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Jun 2017 17:55:19 -0700 (PDT)
Message-ID: <5956F2EC.1000805@oracle.com>
Date: Fri, 30 Jun 2017 17:55:08 -0700
From: prakash sangappa <prakash.sangappa@oracle.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH] userfaultfd: Add feature to request for a signal
 delivery
References: <9363561f-a9cd-7ab6-9c11-ab9a99dc89f1@oracle.com> <20170627070643.GA28078@dhcp22.suse.cz> <20170627153557.GB10091@rapoport-lnx> <51508e99-d2dd-894f-8d8a-678e3747c1ee@oracle.com> <20170628131806.GD10091@rapoport-lnx> <3a8e0042-4c49-3ec8-c59f-9036f8e54621@oracle.com> <20170629080910.GC31603@dhcp22.suse.cz> <936bde7b-1913-5589-22f4-9bbfdb6a8dd5@oracle.com> <20170630094718.GE22917@dhcp22.suse.cz> <20170630130813.GA5738@redhat.com>
In-Reply-To: <20170630130813.GA5738@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mike Kravetz <mike.kravetz@oracle.com>, Dave Hansen <dave.hansen@intel.com>, Christoph Hellwig <hch@infradead.org>, linux-api@vger.kernel.org, John Stultz <john.stultz@linaro.org>


On 6/30/2017 6:08 AM, Andrea Arcangeli wrote:
> On Fri, Jun 30, 2017 at 11:47:35AM +0200, Michal Hocko wrote:
[...]
>> As an aside, I rememeber that prior to MADV_FREE there was long
>> discussion about lazy freeing of memory from userspace. Some users
>> wanted to be signalled when their memory was freed by the system so that
>> they could rebuild the original content (e.g. uncompressed images in
>> memory). It seems like MADV_FREE + this signalling could be used for
>> that usecase. John would surely know more about those usecases.
> That would provide an equivalent API to the one volatile pages
> provided agreed. So it would allow to adapt code (if any?) more easily
> to drop the duplicate feature in volatile pages code (however it would
> be faster if the userland code using volatile pages lazy reclaim mode
> was converted to poll the uffd so the kernel talks directly to the
> monitor without involving a SIGBUS signal handler which will cause
> spurious enter/exit if compared to signal-less uffd API).
>
> The main benefit in my view is not volatile pages but that
> UFFD_FEATURE_SIGBUS would work equally well to enforce robustness on
> all kind of memory not only hugetlbfs (so one could run the database
> with robustness on THP over tmpfs) and the new cache can be injected
> in the filesystem using UFFDIO_COPY which is likely faster than
> fallocate as UFFDIO_COPY was already demonstrated to be faster even
> than a regular page fault.

Interesting that UFFDIO_COPY is faster then fallocate().  In the DB use case
the page does not need to be allocated at the time a process trips on 
the hugetlbfs
file hole and receives SIGBUS.  fallocate() is called on the hugetlbfs file,
when more memory needs to be allocated by a separate process.

> It's also simpler to handle backwards compatibility with the
> UFFDIO_API call, that allows probing if UFFD_FEATURE_SIGBUS is
> supported by the running kernel regardless of kernel version (so it
> can be backported and enabled by the database, without the database
> noticing it's on a older kernel version).

Yes, this is useful as this change will need to be back ported.

> So while this wasn't the intended way to use the userfault and I
> already pointed out the possibility to use a single monitor to do all
> this, I'm positive about UFFD_FEATURE_SIGBUS if the overhead of having
> a monitor is so concerning.
>
> Ultimately there are many pros and just a single cons: the branch in
> handle_userfault().
>
> I wonder if it would be possible to use static_branch_enable() in
> UFFDIO_API and static_branch_unlikely in handle_userfault() to
> eliminate that branch but perhaps it's overkill and UFFDIO_API is
> unprivileged and it would send an IPI to all CPUs. I don't think we
> normally expose the static_branch_enable() to unprivileged userland
> and making UFFD_FEATURE_SIGBUS a privileged op doesn't sound
> attractive (although the alternative of altering a hugetlbfs mount
> option would be a privileged op).

Regarding hugetlbfs mount option, one consideration is to allow mounts of
hugetlbfs inside user namespaces's mount namespace. Which would allow
non privileged processes to mount hugetlbfs for use inside a user 
namespace.
This may be needed even for the 'min_size' mount option using which an
application could reserve huge pages and mount a filesystem for its use,
with out the need to have privileges given the system has enough hugepages
configured.  It seems if non privileged processes are allowed to mount 
hugetlbfs
filesystem, then min_size should be subject to some resource limits.

Mounting inside user namespace will be a different patch proposal later.


>
> Thanks,
> Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
