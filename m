Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3D4F66B7E4F
	for <linux-mm@kvack.org>; Fri,  7 Sep 2018 08:30:11 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id d18-v6so13793140qtj.20
        for <linux-mm@kvack.org>; Fri, 07 Sep 2018 05:30:11 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id o80-v6si2373523qkl.306.2018.09.07.05.30.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Sep 2018 05:30:10 -0700 (PDT)
Date: Fri, 7 Sep 2018 13:29:56 +0100
From: "Dr. David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [PATCH v36 0/5] Virtio-balloon: support free page reporting
Message-ID: <20180907122955.GD2544@work-vm>
References: <1532075585-39067-1-git-send-email-wei.w.wang@intel.com>
 <20180723122342-mutt-send-email-mst@kernel.org>
 <20180723143604.GB2457@work-vm>
 <5B911B03.2060602@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5B911B03.2060602@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, torvalds@linux-foundation.org, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com, peterx@redhat.com

* Wei Wang (wei.w.wang@intel.com) wrote:
> On 07/23/2018 10:36 PM, Dr. David Alan Gilbert wrote:
> > * Michael S. Tsirkin (mst@redhat.com) wrote:
> > > On Fri, Jul 20, 2018 at 04:33:00PM +0800, Wei Wang wrote:
> > > > This patch series is separated from the previous "Virtio-balloon
> > > > Enhancement" series. The new feature, VIRTIO_BALLOON_F_FREE_PAGE_HINT,
> > > > implemented by this series enables the virtio-balloon driver to report
> > > > hints of guest free pages to the host. It can be used to accelerate live
> > > > migration of VMs. Here is an introduction of this usage:
> > > > 
> > > > Live migration needs to transfer the VM's memory from the source machine
> > > > to the destination round by round. For the 1st round, all the VM's memory
> > > > is transferred. From the 2nd round, only the pieces of memory that were
> > > > written by the guest (after the 1st round) are transferred. One method
> > > > that is popularly used by the hypervisor to track which part of memory is
> > > > written is to write-protect all the guest memory.
> > > > 
> > > > This feature enables the optimization by skipping the transfer of guest
> > > > free pages during VM live migration. It is not concerned that the memory
> > > > pages are used after they are given to the hypervisor as a hint of the
> > > > free pages, because they will be tracked by the hypervisor and transferred
> > > > in the subsequent round if they are used and written.
> > > > 
> > > > * Tests
> > > > - Test Environment
> > > >      Host: Intel(R) Xeon(R) CPU E5-2699 v4 @ 2.20GHz
> > > >      Guest: 8G RAM, 4 vCPU
> > > >      Migration setup: migrate_set_speed 100G, migrate_set_downtime 2 second
> > > > 
> > > > - Test Results
> > > >      - Idle Guest Live Migration Time (results are averaged over 10 runs):
> > > >          - Optimization v.s. Legacy = 409ms vs 1757ms --> ~77% reduction
> > > > 	(setting page poisoning zero and enabling ksm don't affect the
> > > >           comparison result)
> > > >      - Guest with Linux Compilation Workload (make bzImage -j4):
> > > >          - Live Migration Time (average)
> > > >            Optimization v.s. Legacy = 1407ms v.s. 2528ms --> ~44% reduction
> > > >          - Linux Compilation Time
> > > >            Optimization v.s. Legacy = 5min4s v.s. 5min12s
> > > >            --> no obvious difference
> > > I'd like to see dgilbert's take on whether this kind of gain
> > > justifies adding a PV interfaces, and what kind of guest workload
> > > is appropriate.
> > > 
> > > Cc'd.
> > Well, 44% is great ... although the measurement is a bit weird.
> > 
> > a) A 2 second downtime is very large; 300-500ms is more normal
> > b) I'm not sure what the 'average' is  - is that just between a bunch of
> > repeated migrations?
> > c) What load was running in the guest during the live migration?
> > 
> > An interesting measurement to add would be to do the same test but
> > with a VM with a lot more RAM but the same load;  you'd hope the gain
> > would be even better.
> > It would be interesting, especially because the users who are interested
> > are people creating VMs allocated with lots of extra memory (for the
> > worst case) but most of the time migrating when it's fairly idle.
> > 
> > Dave
> > 
> 
> Hi Dave,
> 
> The results of the added experiments have been shown in the v37 cover
> letter.
> Could you have a look at https://lkml.org/lkml/2018/8/27/29 . Thanks.

OK, that's much better.
The ~50% reducton with a 8G VM and a real workload is great,
and it does what you expect when you put a lot more RAM in and see the
84% reduction on a guest with 128G RAM - 54s vs ~9s is a big win!

(The migrate_set_speed is a bit high, since that's in bytes/s - but it's
not important).

That looks good,

Thanks!

Dave

> Best,
> Wei
> 
--
Dr. David Alan Gilbert / dgilbert@redhat.com / Manchester, UK
