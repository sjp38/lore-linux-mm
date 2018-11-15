Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5CEC46B0313
	for <linux-mm@kvack.org>; Thu, 15 Nov 2018 08:23:51 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id n68so44223820qkn.8
        for <linux-mm@kvack.org>; Thu, 15 Nov 2018 05:23:51 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a2si2560549qkj.36.2018.11.15.05.23.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Nov 2018 05:23:50 -0800 (PST)
Date: Thu, 15 Nov 2018 21:23:42 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: Memory hotplug softlock issue
Message-ID: <20181115132342.GQ2653@MiWiFi-R3L-srv>
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
To: Michal Hocko <mhocko@kernel.org>, pifang@redhat.com
Cc: David Hildenbrand <david@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, aarcange@redhat.com

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

No, forgot disabling faultround after reboot. Do we need to disable it and
retest?

> 
> > [ 5055.461652] migrating pfn 190f4fb3e failed 
> > [ 5055.461671] page:ffffea643d3ecf80 count:257 mapcount:251 mapping:ffff888e7a6ac528 index:0x85
> > [ 5055.474734] xfs_address_space_operations [xfs] 
> > [ 5055.474742] name:"libc-2.28.so" 
> > [ 5055.481070] flags: 0x1dfffffc0000026(referenced|uptodate|active)
> > [ 5055.490329] raw: 01dfffffc0000026 ffffc900000e3d80 ffffc900000e3d80 ffff888e7a6ac528
> > [ 5055.498080] raw: 0000000000000085 0000000000000000 000000fc000000f9 ffff88810a8f2000
> > [ 5055.505823] page->mem_cgroup:ffff88810a8f2000
> > [ 5056.335970] migrating pfn 190f4fb3e failed 
> > [ 5056.335990] page:ffffea643d3ecf80 count:255 mapcount:250 mapping:ffff888e7a6ac528 index:0x85
> > [ 5056.348994] xfs_address_space_operations [xfs] 
> > [ 5056.348998] name:"libc-2.28.so" 
> > [ 5056.353555] flags: 0x1dfffffc0000026(referenced|uptodate|active)
> > [ 5056.364680] raw: 01dfffffc0000026 ffffc900000e3d80 ffffc900000e3d80 ffff888e7a6ac528
> > [ 5056.372428] raw: 0000000000000085 0000000000000000 000000fc000000f9 ffff88810a8f2000
> > [ 5056.380172] page->mem_cgroup:ffff88810a8f2000
> > [ 5057.332806] migrating pfn 190f4fb3e failed 
> > [ 5057.332821] page:ffffea643d3ecf80 count:261 mapcount:250 mapping:ffff888e7a6ac528 index:0x85
> > [ 5057.345889] xfs_address_space_operations [xfs] 
> > [ 5057.345900] name:"libc-2.28.so" 
> > [ 5057.350451] flags: 0x1dfffffc0000026(referenced|uptodate|active)
> > [ 5057.359707] raw: 01dfffffc0000026 ffffc900000e3d80 ffffc900000e3d80 ffff888e7a6ac528
> > [ 5057.369285] raw: 0000000000000085 0000000000000000 000000fc000000f9 ffff88810a8f2000
> > [ 5057.377030] page->mem_cgroup:ffff88810a8f2000
> > [ 5058.285457] migrating pfn 190f4fb3e failed 
> > [ 5058.285489] page:ffffea643d3ecf80 count:257 mapcount:250 mapping:ffff888e7a6ac528 index:0x85
> > [ 5058.298544] xfs_address_space_operations [xfs] 
> > [ 5058.298556] name:"libc-2.28.so" 
> > [ 5058.303092] flags: 0x1dfffffc0000026(referenced|uptodate|active)
> > [ 5058.314358] raw: 01dfffffc0000026 ffffc900000e3d80 ffffc900000e3d80 ffff888e7a6ac528
> > [ 5058.322109] raw: 0000000000000085 0000000000000000 000000fc000000f9 ffff88810a8f2000
> > [ 5058.329848] page->mem_cgroup:ffff88810a8f2000
> -- 
> Michal Hocko
> SUSE Labs
