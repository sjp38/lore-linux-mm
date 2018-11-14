Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id AC7A96B0005
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 10:00:32 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id c8-v6so8148239edt.23
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 07:00:32 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q4si4281475edr.173.2018.11.14.07.00.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Nov 2018 07:00:31 -0800 (PST)
Date: Wed, 14 Nov 2018 16:00:29 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Memory hotplug softlock issue
Message-ID: <20181114150029.GY23419@dhcp22.suse.cz>
References: <20181114070909.GB2653@MiWiFi-R3L-srv>
 <5a6c6d6b-ebcd-8bfa-d6e0-4312bfe86586@redhat.com>
 <20181114090134.GG23419@dhcp22.suse.cz>
 <20181114145250.GE2653@MiWiFi-R3L-srv>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181114145250.GE2653@MiWiFi-R3L-srv>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baoquan He <bhe@redhat.com>
Cc: David Hildenbrand <david@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, aarcange@redhat.com

On Wed 14-11-18 22:52:50, Baoquan He wrote:
> On 11/14/18 at 10:01am, Michal Hocko wrote:
> > I have seen an issue when the migration cannot make a forward progress
> > because of a glibc page with a reference count bumping up and down. Most
> > probable explanation is the faultaround code. I am working on this and
> > will post a patch soon. In any case the migration should converge and if
> > it doesn't do then there is a bug lurking somewhere.
> > 
> > Failing on ENOMEM is a questionable thing. I haven't seen that happening
> > wildly but if it is a case then I wouldn't be opposed.
> 
> Applied your debugging patches, it helps a lot to printing message.
> 
> Below is the dmesg log about the migrating failure. It can't pass
> migrate_pages() and loop forever.
> 
> [  +0.083841] migrating pfn 10fff7d0 failed 
> [  +0.000005] page:ffffea043ffdf400 count:208 mapcount:201 mapping:ffff888dff4bdda8 index:0x2
> [  +0.012689] xfs_address_space_operations [xfs] 
> [  +0.000030] name:"stress" 
> [  +0.004556] flags: 0x5fffffc0000004(uptodate)
> [  +0.007339] raw: 005fffffc0000004 ffffc900000e3d80 ffffc900000e3d80 ffff888dff4bdda8
> [  +0.009488] raw: 0000000000000002 0000000000000000 000000cb000000c8 ffff888e7353d000
> [  +0.007726] page->mem_cgroup:ffff888e7353d000
> [  +0.084538] migrating pfn 10fff7d0 failed 
> [  +0.000006] page:ffffea043ffdf400 count:210 mapcount:201 mapping:ffff888dff4bdda8 index:0x2
> [  +0.012798] xfs_address_space_operations [xfs] 
> [  +0.000034] name:"stress" 
> [  +0.004524] flags: 0x5fffffc0000004(uptodate)
> [  +0.007068] raw: 005fffffc0000004 ffffc900000e3d80 ffffc900000e3d80 ffff888dff4bdda8
> [  +0.009359] raw: 0000000000000002 0000000000000000 000000cb000000c8 ffff888e7353d000
> [  +0.007728] page->mem_cgroup:ffff888e7353d000

I wouldn't be surprised if this was a similar/same issue I've been
chasing recently. Could you try to disable faultaround to see if that
helps. It seems that it helped in my particular case but I am still
waiting for the final good-to-go to post the patch as I do not own the
workload which triggered that issue.
-- 
Michal Hocko
SUSE Labs
