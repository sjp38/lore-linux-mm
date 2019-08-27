Return-Path: <SRS0=oLae=WX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8BC22C3A5A3
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 17:14:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 49FFF214DA
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 17:14:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 49FFF214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EE62E6B0008; Tue, 27 Aug 2019 13:14:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E96A66B000A; Tue, 27 Aug 2019 13:14:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DAC8B6B000C; Tue, 27 Aug 2019 13:14:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0182.hostedemail.com [216.40.44.182])
	by kanga.kvack.org (Postfix) with ESMTP id B732F6B0008
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 13:14:18 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 65887824CA3E
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 17:14:18 +0000 (UTC)
X-FDA: 75868856196.17.rail18_864d117c5525
X-HE-Tag: rail18_864d117c5525
X-Filterd-Recvd-Size: 11979
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf19.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 17:14:17 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 8E9DE550BB;
	Tue, 27 Aug 2019 17:14:16 +0000 (UTC)
Received: from mail (ovpn-121-95.rdu2.redhat.com [10.10.121.95])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 748E15C1D6;
	Tue, 27 Aug 2019 17:14:12 +0000 (UTC)
Date: Tue, 27 Aug 2019 13:14:10 -0400
From: Andrea Arcangeli <aarcange@redhat.com>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Kefeng Wang <wangkefeng.wang@huawei.com>, linux-mm <linux-mm@kvack.org>,
	Peter Xu <peterx@redhat.com>, Mike Rapoport <rppt@linux.ibm.com>,
	Jann Horn <jannh@google.com>, Jason Gunthorpe <jgg@mellanox.com>,
	Michal Hocko <mhocko@suse.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [BUG] kernel BUG at fs/userfaultfd.c:385 after 04f5866e41fb
Message-ID: <20190827171410.GB4823@redhat.com>
References: <d4583416-5e4a-95e7-a08a-32bf2c9a95fb@huawei.com>
 <20190827163334.GB6291@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190827163334.GB6291@redhat.com>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Tue, 27 Aug 2019 17:14:16 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

On Tue, Aug 27, 2019 at 06:33:35PM +0200, Oleg Nesterov wrote:
> Hi Kefeng,
> 
> On 08/13, Kefeng Wang wrote:
> >
> > Syzkaller reproducer:
> > # {Threaded:true Collide:true Repeat:false RepeatTimes:0 Procs:1 Sandbox:none Fault:false FaultCall:-1 FaultNth:0 EnableTun:true EnableNetDev:true EnableNetReset:false EnableCgroups:false EnableBinfmtMisc:true EnableCloseFds:true UseTmpDir:true HandleSegv:true Repro:false Trace:false}
> > r0 = userfaultfd(0x80800)
> > ioctl$UFFDIO_API(r0, 0xc018aa3f, &(0x7f0000000200))
> > ioctl$UFFDIO_REGISTER(r0, 0xc020aa00, &(0x7f0000000080)={{&(0x7f0000ff2000/0xe000)=nil, 0xe000}, 0x1})
> > ioctl$UFFDIO_COPY(r0, 0xc028aa03, 0x0)
> > ioctl$UFFDIO_COPY(r0, 0xc028aa03, &(0x7f0000000000)={&(0x7f0000ffc000/0x3000)=nil, &(0x7f0000ffd000/0x2000)=nil, 0x3000})
> > syz_execute_func(&(0x7f00000000c0)="4134de984013e80f059532058300000071f3c4e18dd1ce5a65460f18320ce0b9977d8f64360f6e54e3a50fe53ff30fb837c42195dc42eddb8f087ca2a4d2c4017b708fa878c3e600f3266440d9a200000000c4016c5bdd7d0867dfe07f00f20f2b5f0009404cc442c102282cf2f20f51e22ef2e1291010f2262ef045814cb39700000000f32e3ef0fe05922f79a4000030470f3b58c1312fe7460f50ce0502338d00858526660f346253f6010f0f801d000000470f0f2c0a90c7c7df84feefff3636260fe02c98c8b8fcfc81fc51720a40400e700064660f71e70d2e0f57dfe819d0253f3ecaf06ad647608c41ffc42249bccb430f9bc8b7a042420f8d0042171e0f95ca9f7f921000d9fac4a27d5a1fc4a37961309de9000000003171460fc4d303c466410fd6389dc4426c456300c4233d4c922d92abf90ac6c34df30f5ee50909430f3a15e7776f6e866b0fdfdfc482797841cf6ffc842d9b9a516dc2e52ef2ac2636f20f114832d46231bffd4834eaeac4237d09d0003766420f160182c4a37d047882007f108f2808a6e68fc401505d6a82635d1467440fc7ba0c000000d4c482359652745300")
> > poll(&(0x7f00000000c0)=[{}], 0x1, 0x0)
> > 
> > ./syz-execprog -executor=./syz-executor -repeat=0 -procs=16 -cover=0 repofile
> 
> I tried to reproduce using the C code provided by Tetsuo but it doesn't work
> for me.

I could reproduce fine here but with the full suite.

> Could you run this test-case with the patch below? (on top of the fix you have
> already tested).

I finished the debugging of the ioctl refcounting last week, but I
didn't yet post an update sorry.

There were two uffd ctx per process, so the UFFDIO_COPY ioctl is
holding one ctx refcount through the open fd (there's more than one
thread so the file refcount is used), while the userfault triggers in
a vma registered to another uffd ctx. Then the ctx of the vma is
closed.

It was important to verify the uffd ctx of the UFFDIO_COPY ioctl is
different than the one registered on the vma where UFFDIO_COPY hits
handle_userfault, otherwise the release() shouldn't have triggered the
BUG_ON from a stack trace nested in UFFDIO_COPY (because ioctl should
have hold a refcount the ctx through the file open).

uffd ctx pointer triggering the use after free is 0xffff888058adfbc0
on mm 0xffff8880665416c0. When the kprobes are called nested there's a
space in front (i.e. like when handle_userfault runs inside the
UFFDIO_COPY ioctl).

To verify you can look what 6915 tid was doing just before it repeats
the first userfault with released 1. It was doing this:

0xffff888058adf880 0xffff8880665416c0 6915 ioctl
 0xffff888058adfbc0 0xffff8880665416c0 6915 userfault released 0

That's an UFFDIO_COPY holding the refcount of uffd ctx 0xffff888058adf880 
triggering handle_userfault on a vma registered on uffd ctx
0xffff888058adfbc0.

When release of 0xffff888058adfbc0 runs that wakes up the stuck
userfault in 6915 which is being retried immediately and the second
time the BUG_ON triggers with released = 1.

uffd_ctx       	   mm	    	      tid  kprobe point
0xffff888058adfbc0 0xffff8880665416c0 6911 ioctl
ret-ioctl 6911
0xffff888058adfbc0 0xffff8880665416c0 6911 ioctl
ret-ioctl 6911
0xffff888058adfbc0 0xffff8880665416c0 6911 ioctl
ret-ioctl 6911
0xffff888058adfbc0 0xffff8880665416c0 6911 ioctl
 0xffff888058adfbc0 0xffff8880665416c0 6911 userfault released 0

#6911 stuck in handle_userfault of vma->vm_userfaultfd_ctx
#0xffff888058adfbc0 and the ioctl uffd ctx is also 0xffff888058adfbc0

0xffff888058ad8380 0xffff888066547840 6912 ioctl
ret-ioctl 6912
0xffff888058ad8380 0xffff888066547840 6914 ioctl
ret-ioctl 6914
0xffff888058ad8380 0xffff888066547840 6912 ioctl
0xffff888058ad8380 0xffff888066547840 6914 ioctl
ret-ioctl 6912
 0xffff888058ad8040 0xffff888066547840 6914 userfault released 0
0xffff888058adf880 0xffff8880665416c0 6915 ioctl
0xffff888058adf880 0xffff8880665416c0 6913 ioctl
ret-ioctl 6913
ret-ioctl 6915
0xffff888058adf880 0xffff8880665416c0 6913 ioctl
ret-ioctl 6913
0xffff888058adf880 0xffff8880665416c0 6915 ioctl
 0xffff888058adfbc0 0xffff8880665416c0 6915 userfault released 0

#6915 stuck in userfault of vma->vm_userfaultfd_ctx
#0xffff888058adfbc0, but the ioctl uffd is 0xffff888058adf880

 ret-userfault 6914
 0xffff888058ad8040 0xffff888066547840 6914 userfault released 0
  ret-userfault 6908
 0xffff888058ad8040 0xffff888066547840 6908 userfault released 0
 ret-userfault 6914
ret-userfault 6908
ret-ioctl 6914
0xffff888058ad8380 0xffff888066547840 6914 release
ret-ioctl 6908
0xffff888058ad8040 0xffff888066547840 6908 release
ret-release 6914
ret-release 6908
0xffff888058ad86c0 0xffff8880665470c0 6918 ioctl
ret-ioctl 6918
0xffff888058ad86c0 0xffff8880665470c0 6918 ioctl
ret-ioctl 6918
0xffff888058ad86c0 0xffff8880665470c0 6918 ioctl
ret-ioctl 6918
0xffff888058ad86c0 0xffff8880665470c0 6918 ioctl
 0xffff888058ad86c0 0xffff8880665470c0 6918 userfault released 0
 ret-userfault 6911

# 6911 got waken up, somebody must have closed the uffd ctx
# 0xffff888058adfbc0 or the task are getting killed, the uffd ctx not
# released yet because it's still pinned by the handle_userfault

 0xffff888058adfbc0 0xffff8880665416c0 6911 userfault released 0
 ret-userfault 6911

# 6911 retries

ret-ioctl 6911 # ioctl on uffd ctx 0xffff888058adfbc0 returns
 ret-userfault 6915

# 6915 waken up too by the close of the uffd and then 6911 frees the
# ctx when the ioctl method returns and the fd is closed. 6911 ioctl
# was on 0xffff888058adfbc0, 6915 ioctl was on 0xffff888058adf880. So
# 6915 ioctl file refcount holds no refcount on the
# vma->vm_userfaultfd_ctx.

0xffff888058adfbc0 0xffff8880665416c0 6911 release
 0xffff888058adfbc0 0xffff8880665416c0 6915 userfault released 1

# uffdio-copy of 6915 retries the fault with ctx freed at the previous
# line after the ioctl syscall returns in 6911 -> BUG_ON

 ret-userfault 6915
 0xffff888058adfbc0 0xffff8880665416c0 6915 userfault released 1
 ret-userfault 6915
ret-release 6911
 0xffff888058adfbc0 0xffff8880665416c0 6915 userfault released 1
 ret-userfault 6915
0xffff888058adfbc0 0xffff8880665416c0 6915 userfault released 1
 ret-userfault 6915
 0xffff888058adfbc0 0xffff8880665416c0 6915 userfault released 1
 ret-userfault 6915
 0xffff888058adfbc0 0xffff8880665416c0 6915 userfault released 1
 ret-userfault 6915
 0xffff888058adfbc0 0xffff8880665416c0 6915 userfault released 1
 ret-userfault 6915
 0xffff888058adfbc0 0xffff8880665416c0 6915 userfault released 1
 ret-userfault 6915
 0xffff888058adfbc0 0xffff8880665416c0 6915 userfault released 1
 ret-userfault 6915

#!/usr/bin/env bpftrace

#include <linux/fs.h>
#include <linux/mm.h>

enum userfaultfd_state {
	UFFD_STATE_WAIT_API,
	UFFD_STATE_RUNNING,
};

struct userfaultfd_ctx {
	/* waitqueue head for the pending (i.e. not read) userfaults */
	wait_queue_head_t fault_pending_wqh;
	/* waitqueue head for the userfaults */
	wait_queue_head_t fault_wqh;
	/* waitqueue head for the pseudo fd to wakeup poll/read */
	wait_queue_head_t fd_wqh;
	/* waitqueue head for events */
	wait_queue_head_t event_wqh;
	/* a refile sequence protected by fault_pending_wqh lock */
	struct seqcount refile_seq;
	/* pseudo fd refcounting */
	refcount_t refcount;
	/* userfaultfd syscall flags */
	unsigned int flags;
	/* features requested from the userspace */
	unsigned int features;
	/* state machine */
	enum userfaultfd_state state;
	/* released */
	bool released;
	/* memory mappings are changing because of non-cooperative event */
	bool mmap_changing;
	/* mm with one ore more vmas attached to this userfaultfd_ctx */
	struct mm_struct *mm;
};

kprobe:userfaultfd_release
{
	$x = (struct userfaultfd_ctx *) (((struct file *)arg1)->private_data);
	$mm = $x->mm;
	if (@nested[tid]) {
		printf(" ");
	}
	if (@nested[tid] > 1) {
		printf(" ");
	}
	if (@nested[tid] > 2) {
		printf(" ");
	}
	printf("%p %p %d release\n", $x, $mm, tid);
	@release[tid] = 1;
	@nested[tid]++;
}

kretprobe:userfaultfd_release /@release[tid]/
{
	if (!--@nested[tid]) {
	   delete(@nested[tid]);
	}
	if (@nested[tid]) {
		printf(" ");
	}
	if (@nested[tid] > 1) {
		printf(" ");
	}
	if (@nested[tid] > 2) {
		printf(" ");
	}
	printf("ret-release %d\n", tid);
	delete(@release[tid]);
}

kprobe:userfaultfd_ioctl
{
	$x = (struct userfaultfd_ctx *) (((struct file *)arg0)->private_data);
	$mm = $x->mm;
	if (@nested[tid]) {
		printf(" ");
	}
	if (@nested[tid] > 1) {
		printf(" ");
	}
	if (@nested[tid] > 2) {
		printf(" ");
	}
	printf("%p %p %d ioctl\n", $x, $mm, tid);
	@ioctl[tid] = 1;
	@nested[tid]++;
}

kretprobe:userfaultfd_ioctl /@ioctl[tid]/
{
	if (!--@nested[tid]) {
	   delete(@nested[tid]);
	}
	if (@nested[tid]) {
		printf(" ");
	}
	if (@nested[tid] > 1) {
		printf(" ");
	}
	if (@nested[tid] > 2) {
		printf(" ");
	}
	printf("ret-ioctl %d\n", tid);
	delete(@ioctl[tid]);
}


kprobe:handle_userfault
{
	$x = ((struct vm_fault *)arg0)->vma->vm_userfaultfd_ctx.ctx;
	$mm = $x->mm;
	if (@nested[tid]) {
		printf(" ");
	}
	if (@nested[tid] > 1) {
		printf(" ");
	}
	if (@nested[tid] > 2) {
		printf(" ");
	}
	printf("%p %p %d userfault released %d\n", $x, $mm, tid,
		   ((struct userfaultfd_ctx *)$x)->released);
	@userfault[tid] = 1;
	@nested[tid]++;
}

kretprobe:handle_userfault /@userfault[tid]/
{
	if (!--@nested[tid]) {
	   delete(@nested[tid]);
	}
	if (@nested[tid]) {
		printf(" ");
	}
	if (@nested[tid] > 1) {
		printf(" ");
	}
	if (@nested[tid] > 2) {
		printf(" ");
	}
	printf("ret-userfault %d\n", tid);
	delete(@userfault[tid]);
}

