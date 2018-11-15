Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 63BB96B0003
	for <linux-mm@kvack.org>; Thu, 15 Nov 2018 02:54:03 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id w185so43920432qka.9
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 23:54:03 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 54si1510700qtm.62.2018.11.14.23.54.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Nov 2018 23:54:02 -0800 (PST)
Date: Thu, 15 Nov 2018 15:53:56 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: Memory hotplug softlock issue
Message-ID: <20181115075349.GL2653@MiWiFi-R3L-srv>
References: <20181114070909.GB2653@MiWiFi-R3L-srv>
 <5a6c6d6b-ebcd-8bfa-d6e0-4312bfe86586@redhat.com>
 <20181114090134.GG23419@dhcp22.suse.cz>
 <20181114145250.GE2653@MiWiFi-R3L-srv>
 <20181114150029.GY23419@dhcp22.suse.cz>
 <20181115051034.GK2653@MiWiFi-R3L-srv>
 <20181115073052.GA23831@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181115073052.GA23831@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: David Hildenbrand <david@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, aarcange@redhat.com

On 11/15/18 at 08:30am, Michal Hocko wrote:
> On Thu 15-11-18 13:10:34, Baoquan He wrote:
> > On 11/14/18 at 04:00pm, Michal Hocko wrote:
> > > On Wed 14-11-18 22:52:50, Baoquan He wrote:
> > > > On 11/14/18 at 10:01am, Michal Hocko wrote:
> > > > > I have seen an issue when the migration cannot make a forward progress
> > > > > because of a glibc page with a reference count bumping up and down. Most
> > > > > probable explanation is the faultaround code. I am working on this and
> > > > > will post a patch soon. In any case the migration should converge and if
> > > > > it doesn't do then there is a bug lurking somewhere.
> > > > > 
> > > > > Failing on ENOMEM is a questionable thing. I haven't seen that happening
> > > > > wildly but if it is a case then I wouldn't be opposed.
> > > > 
> > > > Applied your debugging patches, it helps a lot to printing message.
> > > > 
> > > > Below is the dmesg log about the migrating failure. It can't pass
> > > > migrate_pages() and loop forever.
> > > > 
> > > > [  +0.083841] migrating pfn 10fff7d0 failed 
> > > > [  +0.000005] page:ffffea043ffdf400 count:208 mapcount:201 mapping:ffff888dff4bdda8 index:0x2
> > > > [  +0.012689] xfs_address_space_operations [xfs] 
> > > > [  +0.000030] name:"stress" 
> > > > [  +0.004556] flags: 0x5fffffc0000004(uptodate)
> > > > [  +0.007339] raw: 005fffffc0000004 ffffc900000e3d80 ffffc900000e3d80 ffff888dff4bdda8
> > > > [  +0.009488] raw: 0000000000000002 0000000000000000 000000cb000000c8 ffff888e7353d000
> > > > [  +0.007726] page->mem_cgroup:ffff888e7353d000
> > > > [  +0.084538] migrating pfn 10fff7d0 failed 
> > > > [  +0.000006] page:ffffea043ffdf400 count:210 mapcount:201 mapping:ffff888dff4bdda8 index:0x2
> > > > [  +0.012798] xfs_address_space_operations [xfs] 
> > > > [  +0.000034] name:"stress" 
> > > > [  +0.004524] flags: 0x5fffffc0000004(uptodate)
> > > > [  +0.007068] raw: 005fffffc0000004 ffffc900000e3d80 ffffc900000e3d80 ffff888dff4bdda8
> > > > [  +0.009359] raw: 0000000000000002 0000000000000000 000000cb000000c8 ffff888e7353d000
> > > > [  +0.007728] page->mem_cgroup:ffff888e7353d000
> > > 
> > > I wouldn't be surprised if this was a similar/same issue I've been
> > > chasing recently. Could you try to disable faultaround to see if that
> > > helps. It seems that it helped in my particular case but I am still
> > > waiting for the final good-to-go to post the patch as I do not own the
> > > workload which triggered that issue.
> > 
> > Tried, still stuck in last block sometime. Usually after several times
> > of hotplug/unplug. If stop stress program, the last block will be
> > offlined immediately.
> 
> Is the pattern still the same? I mean failing over few pages with
> reference count jumping up and down between attempts?

->count jumping up and down, mapcount stays the same value.

> 
> > [root@ ~]# cat /sys/kernel/debug/fault_around_bytes 
> > 4096
> 
> Can you make it 0?

I executed 'echo 0 > fault_around_bytes', value less than one page size
will round up to one page.

/*
 * fault_around_bytes must be rounded down to the nearest page order as it's
 * what do_fault_around() expects to see.
 */
static int fault_around_bytes_set(void *data, u64 val)
{
        if (val / PAGE_SIZE > PTRS_PER_PTE)
                return -EINVAL;
        if (val > PAGE_SIZE)
                fault_around_bytes = rounddown_pow_of_two(val);
        else
                fault_around_bytes = PAGE_SIZE; /* rounddown_pow_of_two(0) is undefined */
        return 0;
}
