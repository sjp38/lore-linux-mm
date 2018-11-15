Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id C89B56B0325
	for <linux-mm@kvack.org>; Thu, 15 Nov 2018 08:38:47 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id z126so44690029qka.10
        for <linux-mm@kvack.org>; Thu, 15 Nov 2018 05:38:47 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g10si6708596qkm.38.2018.11.15.05.38.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Nov 2018 05:38:46 -0800 (PST)
Date: Thu, 15 Nov 2018 21:38:40 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: Memory hotplug softlock issue
Message-ID: <20181115133840.GR2653@MiWiFi-R3L-srv>
References: <5a6c6d6b-ebcd-8bfa-d6e0-4312bfe86586@redhat.com>
 <20181114090134.GG23419@dhcp22.suse.cz>
 <20181114145250.GE2653@MiWiFi-R3L-srv>
 <20181114150029.GY23419@dhcp22.suse.cz>
 <20181115051034.GK2653@MiWiFi-R3L-srv>
 <20181115073052.GA23831@dhcp22.suse.cz>
 <20181115075349.GL2653@MiWiFi-R3L-srv>
 <20181115083055.GD23831@dhcp22.suse.cz>
 <20181115131211.GP2653@MiWiFi-R3L-srv>
 <20181115131927.GT23831@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181115131927.GT23831@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: David Hildenbrand <david@redhat.com>, linux-mm@kvack.org, pifang@redhat.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, aarcange@redhat.com

On 11/15/18 at 02:19pm, Michal Hocko wrote:
> On Thu 15-11-18 21:12:11, Baoquan He wrote:
> > On 11/15/18 at 09:30am, Michal Hocko wrote:
> [...]
> > > It would be also good to find out whether this is fs specific. E.g. does
> > > it make any difference if you use a different one for your stress
> > > testing?
> > 
> > Created a ramdisk and put stress bin there, then run stress -m 200, now
> > seems it's stuck in libc-2.28.so migrating. And it's still xfs. So now xfs
> > is a big suspect. At bottom I paste numactl printing, you can see that it's
> > the last 4G.
> > 
> > Seems it's trying to migrate libc-2.28.so, but stress program keeps trying to
> > access and activate it.
> 
> Is this still with faultaround disabled? I have seen exactly same
> pattern in the bug I am working on. It was ext4 though.

After a long time struggling, the last 2nd block where libc-2.28.so is
located is reclaimed, now it comes to the last memory block, still
stress program itself. swap migration entry has been made and trying to
unmap, now it's looping there.

[  +0.004445] migrating pfn 190ff2bb0 failed 
[  +0.000013] page:ffffea643fcaec00 count:203 mapcount:201 mapping:ffff888dfb268f48 index:0x0
[  +0.012809] shmem_aops 
[  +0.000011] name:"stress" 
[  +0.002550] flags: 0x1dfffffc008004e(referenced|uptodate|dirty|workingset|swapbacked)
[  +0.010715] raw: 01dfffffc008004e ffffea643fcaec48 ffffea643fc714c8 ffff888dfb268f48
[  +0.007828] raw: 0000000000000000 0000000000000000 000000cb000000c8 ffff888e72e92000
[  +0.007810] page->mem_cgroup:ffff888e72e92000
[  +0.004466] migrating pfn 190ff2bb1 failed 
[  +0.000013] page:ffffea643fcaec40 count:203 mapcount:201 mapping:ffff888dfb268f48 index:0x2
[  +0.014321] shmem_aops 
[  +0.000024] name:"stress" 
[  +0.002535] flags: 0x1dfffffc008004e(referenced|uptodate|dirty|workingset|swapbacked)
[  +0.010680] raw: 01dfffffc008004e ffffc900000e3d80 ffffea643fcaec08 ffff888dfb268f48
[  +0.007863] raw: 0000000000000002 0000000000000000 000000cb000000c8 ffff888e72e92000
[  +0.007828] page->mem_cgroup:ffff888e72e92000
[  +1.357302] migrating pfn 190ff1c53 failed 
[  +0.000011] page:ffffea643fc714c0 count:202 mapcount:201 mapping:ffff888e5e395109 index:0x28
[  +0.012756] anon 
[  +0.000024] flags: 0x1dfffffc008004c(uptodate|dirty|workingset|swapbacked)
[  +0.008961] raw: 01dfffffc008004c ffffea643fcaec08 ffffc900000e3d80 ffff888e5e395109
[  +0.007847] raw: 0000000000000028 0000000000000000 000000ca000000c8 ffff888e72e92000
[  +0.007844] page->mem_cgroup:ffff888e72e92000
[  +0.004455] migrating pfn 190ff2bb0 failed 
[  +0.000018] page:ffffea643fcaec00 count:203 mapcount:201 mapping:ffff888dfb268f48 index:0x0
[  +0.014392] shmem_aops 
[  +0.000010] name:"stress" 
[  +0.002565] flags: 0x1dfffffc008004e(referenced|uptodate|dirty|workingset|swapbacked)
[  +0.010675] raw: 01dfffffc008004e ffffea643fcaec48 ffffea643fc714c8 ffff888dfb268f48
[  +0.007819] raw: 0000000000000000 0000000000000000 000000cb000000c8 ffff888e72e92000
[  +0.007808] page->mem_cgroup:ffff888e72e92000
[  +0.004431] migrating pfn 190ff2bb1 failed 
[  +0.000019] page:ffffea643fcaec40 count:203 mapcount:201 mapping:ffff888dfb268f48 index:0x2
[  +0.012688] shmem_aops 
[  +0.000012] name:"stress" 
[  +0.002525] flags: 0x1dfffffc008004e(referenced|uptodate|dirty|workingset|swapbacked)
[  +0.012385] raw: 01dfffffc008004e ffffc900000e3d80 ffffea643fcaec08 ffff888dfb268f48
[  +0.007840] raw: 0000000000000002 0000000000000000 000000cb000000c8 ffff888e72e92000
[  +0.007832] page->mem_cgroup:ffff888e72e92000
