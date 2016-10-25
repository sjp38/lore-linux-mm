Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3057D6B026B
	for <linux-mm@kvack.org>; Tue, 25 Oct 2016 11:33:00 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id z190so213066237qkc.4
        for <linux-mm@kvack.org>; Tue, 25 Oct 2016 08:33:00 -0700 (PDT)
Received: from mail-qt0-x241.google.com (mail-qt0-x241.google.com. [2607:f8b0:400d:c0d::241])
        by mx.google.com with ESMTPS id f186si13812927qkj.69.2016.10.25.08.32.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Oct 2016 08:32:59 -0700 (PDT)
Received: by mail-qt0-x241.google.com with SMTP id 12so1064342qtm.0
        for <linux-mm@kvack.org>; Tue, 25 Oct 2016 08:32:59 -0700 (PDT)
Date: Tue, 25 Oct 2016 11:32:56 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [RFC 0/8] Define coherent device memory node
Message-ID: <20161025153256.GB6131@gmail.com>
References: <1477283517-2504-1-git-send-email-khandual@linux.vnet.ibm.com>
 <20161024170902.GA5521@gmail.com>
 <877f8xaurp.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <877f8xaurp.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, js1304@gmail.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, akpm@linux-foundation.org, bsingharora@gmail.com

On Tue, Oct 25, 2016 at 10:29:38AM +0530, Aneesh Kumar K.V wrote:
> Jerome Glisse <j.glisse@gmail.com> writes:
> > On Mon, Oct 24, 2016 at 10:01:49AM +0530, Anshuman Khandual wrote:

[...]

> > You can take a look at hmm-v13 if you want to see how i do non LRU page
> > migration. While i put most of the migration code inside hmm_migrate.c it
> > could easily be move to migrate.c without hmm_ prefix.
> >
> > There is 2 missing piece with existing migrate code. First is to put memory
> > allocation for destination under control of who call the migrate code. Second
> > is to allow offloading the copy operation to device (ie not use the CPU to
> > copy data).
> >
> > I believe same requirement also make sense for platform you are targeting.
> > Thus same code can be use.
> >
> > hmm-v13 https://cgit.freedesktop.org/~glisse/linux/log/?h=hmm-v13
> >
> > I haven't posted this patchset yet because we are doing some modifications
> > to the device driver API to accomodate some new features. But the ZONE_DEVICE
> > changes and the overall migration code will stay the same more or less (i have
> > patches that move it to migrate.c and share more code with existing migrate
> > code).
> >
> > If you think i missed anything about lru and page cache please point it to
> > me. Because when i audited code for that i didn't see any road block with
> > the few fs i was looking at (ext4, xfs and core page cache code).
> >
> 
> The other restriction around ZONE_DEVICE is, it is not a managed zone.
> That prevents any direct allocation from coherent device by application.
> ie, we would like to force allocation from coherent device using
> interface like mbind(MPOL_BIND..) . Is that possible with ZONE_DEVICE ?
 
To achieve this we rely on device fault code path ie when device take a page fault
with help of HMM it will use existing memory if any for fault address but if CPU
page table is empty (and it is not file back vma because of readback) then device
can directly allocate device memory and HMM will update CPU page table to point to
newly allocated device memory.

So in fact i am not using existing kernel API to achieve this but the whole policy
of where to allocate and what to allocate is under device driver responsability and
device driver leverage its existing userspace API to get proper hint/direction from
the application.

Device memory is really a special case in my view, it only make sense to use it if
memory is actively access by device and only way device access memory is when it is
program to do so through the device driver API. There is nothing such as GPU threads
in the kernel and there is no way to spawn or move work thread to GPU. This are
specialize device and they require special per device API. So in my view using
existing kernel API such as mbind() is counter productive. You might have buggy
software that will mbind their memory to device and never use the device which
lead to device memory being wasted for a process that never use the device.

So my opinion is that you should not try to use existing kernel API to get policy
information from userspace but let the device driver gather such policy through its
own private API.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
