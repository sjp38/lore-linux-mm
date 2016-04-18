Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id 925F16B007E
	for <linux-mm@kvack.org>; Mon, 18 Apr 2016 13:18:21 -0400 (EDT)
Received: by mail-vk0-f70.google.com with SMTP id x6so365604575vkf.1
        for <linux-mm@kvack.org>; Mon, 18 Apr 2016 10:18:21 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s84si15034406qks.95.2016.04.18.10.18.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Apr 2016 10:18:20 -0700 (PDT)
Date: Mon, 18 Apr 2016 18:18:15 +0100
From: "Dr. David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: post-copy is broken?
Message-ID: <20160418171814.GH2222@work-vm>
References: <20160415125236.GA3376@node.shutemov.name>
 <20160415134233.GG2229@work-vm>
 <20160415152330.GB3376@node.shutemov.name>
 <20160415163448.GJ2229@work-vm>
 <F2CBF3009FA73547804AE4C663CAB28E04181101@shsmsx102.ccr.corp.intel.com>
 <20160418095528.GD2222@work-vm>
 <F2CBF3009FA73547804AE4C663CAB28E0418115C@shsmsx102.ccr.corp.intel.com>
 <20160418101555.GE2222@work-vm>
 <F2CBF3009FA73547804AE4C663CAB28E041813A6@shsmsx102.ccr.corp.intel.com>
 <20160418132338.GG2222@work-vm>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160418132338.GG2222@work-vm>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Li, Liang Z" <liang.z.li@intel.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrea Arcangeli <aarcange@redhat.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, Amit Shah <amit.shah@redhat.com>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "quintela@redhat.com" <quintela@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

* Dr. David Alan Gilbert (dgilbert@redhat.com) wrote:
> * Li, Liang Z (liang.z.li@intel.com) wrote:
> > > > > > > > > Interesting; it's failing reliably for me - but only with a
> > > > > > > > > reasonably freshly booted machine (so that the pages get THPd).
> > > > > > > >
> > > > > > > > The same here. Freshly booted machine with 64GiB ram. I've
> > > > > > > > checked
> > > > > > > > /proc/vmstat: huge pages were allocated
> > > > > > >
> > > > > > > Thanks for testing.
> > > > > > >
> > > > > > > Damn; this is confusing now.  I've got a RHEL7 box with
> > > > > > > 4.6.0-rc3 on where it works, and a fedora24 VM where it fails
> > > > > > > (the f24 VM is where I did the bisect so it works fine with the
> > > > > > > older kernel on the f24
> > > > > userspace in that VM).
> > > > > > >
> > > > > > > So lets see:
> > > > > > >    works: Kirill's (64GB machine)
> > > > > > >           Dave's RHEL7 host (24GB RAM, dual xeon, RHEL7
> > > > > > > userspace and kernel
> > > > > > > config)
> > > > > > >    fails: Dave's f24 VM (4GB RAM, 4 vcpus VM on my laptop24
> > > > > > > userspace and kernel config)
> > > > > > >
> > > > > > > So it's any of userspace, kernel config, machine hardware or hmm.
> > > > > > >
> > > > > > > My f24 box has transparent_hugepage_madvise, where my rhel7 has
> > > > > > > transparent_hugepage_always (but still works if I flip it to
> > > > > > > madvise at run time).  I'll try and get the configs closer together.
> > > > > > >
> > > > > > > Liang Li: Can you run my test on your setup which fails the
> > > > > > > migrate and tell me what your userspace is?
> > > > > > >
> > > > > > > (If you've not built my test yet, you might find you need to add a :
> > > > > > >    tests/postcopy-test$(EXESUF): tests/postcopy-test.o
> > > > > > >
> > > > > > >   to the tests/Makefile)
> > > > > > >
> > > > > >
> > > > > > Hi Dave,
> > > > > >
> > > > > >   How to build and run you test? I didn't do that before.
> > > > >
> > > > > Apply the code in:
> > > > > http://lists.gnu.org/archive/html/qemu-devel/2016-04/msg02138.html
> > > > >
> > > > > fix the:
> > > > > +            if ( ((b + 1) % 255) == last_byte && !hit_edge) {
> > > > > to:
> > > > > +            if ( ((b + 1) % 256) == last_byte && !hit_edge) {
> > > > >
> > > > > to tests/Makefile
> > > > >    tests/postcopy-test$(EXESUF): tests/postcopy-test.o
> > > > >
> > > > > and do a:
> > > > >     make check
> > > > >
> > > > > in qemu.
> > > > > Then you can rerun the test with:
> > > > >     QTEST_QEMU_BINARY=path/to/qemu-system-
> > > x86_64 ./tests/postcopy-
> > > > > test
> > > > >
> > > > > if it works, reboot and check it still works from a fresh boot.
> > > > >
> > > > > Can you describe the system which your full test failed on? What
> > > > > distro on the host? What type of host was it tested on?
> > > > >
> > > > > Dave
> > > > >
> > > >
> > > >
> > > > Thanks, Dave
> > > >
> > > > The host is CenOS7, its original kernel is 3.10.0-327.el7.x86_64
> > > > (CentOS 7.1?), The hardware platform is HSW-EP with 64GB RAM.
> > > 
> > > OK, so your test fails on real hardware; my guess is that my test will work on
> > > there.
> > > Can you try your test with THP disabled on the host:
> > > 
> > > echo never > /sys/kernel/mm/transparent_hugepage/enabled
> > > 
> > 
> > If the THP is disabled, no fails.
> > And your test was always passed, even when  real post-copy was failed. 
> > 
> > In my env, the output of 
> > 'cat /sys/kernel/mm/transparent_hugepage/enabled'  is:
> > 
> >  [always] ...
> 
> OK, I can't get my test to fail on real hardware - only in a VM; but my
> suspicion is we're looking at the same bug; both of them it goes away
> if we disable THP, both of them work on 4.4.x and fail on 4.5.x.
> I'd love to be able to find a nice easy test to be able to give to Andrea
> and Kirill
> 
> I've also just confirmed that running (in a VM) a fedora-24 4.5.0 kernel
> with a fedora-23 userspace (qemu built under f23) still fails with my test.
> So the problem there is definitely triggered by the newer kernel not
> the newer userspace.

OK, some more results - I *can* get it to fail on real hardware - it's just
really really rare, and the failure is slightly different than in the nest.

I'm using the following magic:
count=0; while true; do count=$(($count+1)); echo 3 >/proc/sys/vm/drop_caches; echo >/proc/sys/vm/compact_memory; echo "Iteration $count"; QTEST_QEMU_BINARY=./bin/qemu-system-x86_64 ./tests/postcopy-test || break; done

I've had about 4 failures out of about 5000 runs (ouch);

On the real hardware the failure addresses are always 2MB aligned, even though
other than the start address, everything in the test is 4K page based - so again
this is pointing the finger at THP:

/x86_64/postcopy: Memory content inconsistency at 4200000 first_byte = 48 last_byte = 47 current = 1 hit_edge = 1
postcopy-test: /root/git/qemu/tests/postcopy-test.c:274: check_guests_ram: Assertion `0' failed.
/x86_64/postcopy: Memory content inconsistency at 4200000 first_byte = e last_byte = d current = 9b hit_edge = 1
postcopy-test: /root/git/qemu/tests/postcopy-test.c:274: check_guests_ram: Assertion `0' failed.
/x86_64/postcopy: Memory content inconsistency at 4800000 first_byte = 19 last_byte = 18 current = 1 hit_edge = 1
postcopy-test: /root/git/qemu/tests/postcopy-test.c:274: check_guests_ram: Assertion `0' failed.
/x86_64/postcopy: Memory content inconsistency at 5e00000 first_byte = d6 last_byte = d5 current = 1 hit_edge = 1
postcopy-test: /root/git/qemu/tests/postcopy-test.c:274: check_guests_ram: Assertion `0' failed.

(My test host for the real hardware is 2x E5-2640 v3 running fedora 24)

where as in the VM I'm seeing immediate failures with addresses just on any 4k alignment.

You can run a couple in parallel; but if your load is too high the test will fail with an
assertion (postcopy-test.c:196 ...(qdict_haskey(rsp, "return")) - but that's
my test - so don't worry if you hit that; decreasing the migrate_speed_set value should
avoid that if you're hitting it repeatedly.

(Could this be something like a missing TLB flush?)

Dave


> 
> Dave
> 
> > 
> > Liang
> > 
> > > Dave
> > > 
> > > >
> > > >
> > > > > >
> > > > > > Thanks!
> > > > > > Liang
> > > > > >
> > > > > > >
> > > > > > > Dave
> > > > > > > >
> > > > > > > > --
> > > > > > > >  Kirill A. Shutemov
> > > > > > > --
> > > > > > > Dr. David Alan Gilbert / dgilbert@redhat.com / Manchester, UK
> > > > > --
> > > > > Dr. David Alan Gilbert / dgilbert@redhat.com / Manchester, UK
> > > --
> > > Dr. David Alan Gilbert / dgilbert@redhat.com / Manchester, UK
> --
> Dr. David Alan Gilbert / dgilbert@redhat.com / Manchester, UK
--
Dr. David Alan Gilbert / dgilbert@redhat.com / Manchester, UK

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
