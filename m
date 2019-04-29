Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4ADD0C43219
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 13:26:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EAEA52173E
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 13:26:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EAEA52173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8AB586B0003; Mon, 29 Apr 2019 09:26:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8825C6B0005; Mon, 29 Apr 2019 09:26:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 770D16B0007; Mon, 29 Apr 2019 09:26:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 54B736B0003
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 09:26:52 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id q79so8876882qke.18
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 06:26:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=ogIk0YqzPu7FykB7kXuLpHfgUbGhWHYOsUzUU8DFbkw=;
        b=q404M1i1zpw49ShPaHDEzYbSUjAN4KNSkinn77CyxcGpBeN4d08mYRFuuSLs6Z0ltT
         x/qQwpw8vVXL6hnU/Y+3JbmE89ZhPTYIRWg+wdCR5ymOT9BwseDnzbdXtf2+esMTIUYg
         yH3A9NfbvNXqivO590kp28Ro6AFbNw2wFcCqQMXjtIbYJrM2s/wcGx7ceI7kzZ1U9gSP
         JQ+0V6nC5Y7g//A56Dl1VPbwWsKJxGIyIOYGLNPpuWRRtnlRoJ2mTlEbX7dpcN4tQRrr
         ey633KVNvPFzZFVufXAJZXeG6rMP/k4HCOVeKIhXBNsP48l4hJrMe7DplM6jM9rTOPj/
         NA1w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXNSngWhNMwbERwFNtIm0WvsL0bbc2vKBa6peUuYzCoyClAVRUR
	i0YBW/tkz6/BM7RgKzLEPHMO+DqBvYwCLd1T8+QUgo+izFMcI5nBbMNxGqeIbFriDfHW8dehv/a
	FAibGWdNnq/2nvgvwurjsPnPm6uOmaWZJMQIyjJN3VQc4lj04q8JE4uL/T2wA9g4M8g==
X-Received: by 2002:a37:63cf:: with SMTP id x198mr38908006qkb.353.1556544412012;
        Mon, 29 Apr 2019 06:26:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxhYjt5R1Z8ub8p5r7cruj4JPvi8gIO3Z6kk0utXY3mnxd57YaiSNKjb8fcJdvHAjhi/D2H
X-Received: by 2002:a37:63cf:: with SMTP id x198mr38907913qkb.353.1556544410546;
        Mon, 29 Apr 2019 06:26:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556544410; cv=none;
        d=google.com; s=arc-20160816;
        b=ZVTLMCbw0xGrKD9Lvdh6sutbN1fnHQGILZuvO5WdgDeLo5nsKeOZjoMjk+fhWGR+n2
         6vHqo2FOU0k7meCg7Htg3ahHS2b29iuhzxsV/qVcYvMI2weSqkYV2XzNH/7qg1UqLfD8
         Lw43DmaaI86CVD9Wbj3IIimhxu2UWGexw+K3Ma+RkC8XYnKCxSAB+YLV4nMtYNlnaBcB
         1bnFGW3wXXvjxFHTQ5tFy3a5KTHhqCXBTKVHEkHdTJDtrkgIaO8dudsKNT9A+22gjw17
         NnumYo17hHvCrF4lhWiNhPbwnb8DQYbbRlVj81E9a5d/4kv7o/dlDiEXKkRqPmbnHV8o
         egUA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=ogIk0YqzPu7FykB7kXuLpHfgUbGhWHYOsUzUU8DFbkw=;
        b=I6+NVdn2L3lHXKsiHxBrnamvU4x6mrv7cJq/CDg9MR9aWHe9ATK+QPkzd6bUVKu8s8
         FCcdaKdNFQ3fBTUUBTD7bLqnaLlcVoPIf0nhiwTTAuwq3fDhnWLr/u3N6+RnbPeSeRQ6
         dX8q2TiCEBtXe4Vfrdo07gRtumRe8JYn4rXysd/OIUBQn6BsTTBZ9qrP9zCdbgv26+oQ
         WssdTIlig/CumdsLti+NcP3eDjWc1st8hlR0JtN9jdwMTNMCJoyS6uqSVFj/81lwfFkB
         +SsqWnB8YtkzIw05FHg5NRdCgXiaStxxuoYt3aKRDv7IJB9dI+vuh93DaZ+6wgRBbyKM
         COtw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d123si2257552qkb.178.2019.04.29.06.26.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Apr 2019 06:26:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A1C7A7E44B;
	Mon, 29 Apr 2019 13:26:49 +0000 (UTC)
Received: from redhat.com (ovpn-123-191.rdu2.redhat.com [10.10.123.191])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 041715D6A9;
	Mon, 29 Apr 2019 13:26:47 +0000 (UTC)
Date: Mon, 29 Apr 2019 09:26:45 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Dave Chinner <david@fromorbit.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [LSF/MM TOPIC] Direct block mapping through fs for device
Message-ID: <20190429132643.GB3036@redhat.com>
References: <20190426013814.GB3350@redhat.com>
 <20190426062816.GG1454@dread.disaster.area>
 <20190426152044.GB13360@redhat.com>
 <20190427012516.GH1454@dread.disaster.area>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190427012516.GH1454@dread.disaster.area>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Mon, 29 Apr 2019 13:26:49 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Apr 27, 2019 at 11:25:16AM +1000, Dave Chinner wrote:
> On Fri, Apr 26, 2019 at 11:20:45AM -0400, Jerome Glisse wrote:
> > On Fri, Apr 26, 2019 at 04:28:16PM +1000, Dave Chinner wrote:
> > > On Thu, Apr 25, 2019 at 09:38:14PM -0400, Jerome Glisse wrote:
> > > > I see that they are still empty spot in LSF/MM schedule so i would like to
> > > > have a discussion on allowing direct block mapping of file for devices (nic,
> > > > gpu, fpga, ...). This is mm, fs and block discussion, thought the mm side
> > > > is pretty light ie only adding 2 callback to vm_operations_struct:
> > > 
> > > The filesystem already has infrastructure for the bits it needs to
> > > provide. They are called file layout leases (how many times do I
> > > have to keep telling people this!), and what you do with the lease
> > > for the LBA range the filesystem maps for you is then something you
> > > can negotiate with the underlying block device.
> > > 
> > > i.e. go look at how xfs_pnfs.c works to hand out block mappings to
> > > remote pNFS clients so they can directly access the underlying
> > > storage. Basically, anyone wanting to map blocks needs a file layout
> > > lease and then to manage the filesystem state over that range via
> > > these methods in the struct export_operations:
> > > 
> > >         int (*get_uuid)(struct super_block *sb, u8 *buf, u32 *len, u64 *offset);
> > >         int (*map_blocks)(struct inode *inode, loff_t offset,
> > >                           u64 len, struct iomap *iomap,
> > >                           bool write, u32 *device_generation);
> > >         int (*commit_blocks)(struct inode *inode, struct iomap *iomaps,
> > >                              int nr_iomaps, struct iattr *iattr);
> > > 
> > > Basically, before you read/write data, you map the blocks. if you've
> > > written data, then you need to commit the blocks (i.e. tell the fs
> > > they've been written to).
> > > 
> > > The iomap will give you a contiguous LBA range and the block device
> > > they belong to, and you can then use that to whatever smart DMA stuff
> > > you need to do through the block device directly.
> > > 
> > > If the filesystem wants the space back (e.g. because truncate) then
> > > the lease will be revoked. The client then must finish off it's
> > > outstanding operations, commit them and release the lease. To access
> > > the file range again, it must renew the lease and remap the file
> > > through ->map_blocks....
> > 
> > Sorry i should have explain why lease do not work. Here are list of
> > lease shortcoming AFAIK:
> >     - only one process
> 
> Sorry, what? The lease is taken by a application process that then
> hands out the mapping to whatever parts of it - processes, threads,
> remote clients, etc - need access. If your application doesn't
> have an access co-ordination method, then you're already completely
> screwed.

Then i am completely screw :) The thing is that today mmap of a file
does not mandate any kind of synchronization between process than
mmap files and thus we have a lot of existing applications that are
just happy with that programming model and i do not see any reasons
to force something new on them.

Here i am only trying an optimization by possibly skipping the page
cache intermediary if filesystem and blocks device allows it and can
do it (depending on any number of runtime conditions).

So lease is inherently not compatible with mmap of file by multiple
processes. I understand you want to push your access model but the
reality is that we have existing applications that just do not fit
that model and i do not see any reasons to ask them to change, it
is never a successful approach.

> 
> >     - program ie userspace is responsible for doing the right thing
> >       so heavy burden on userspace program
> 
> You're asking for direct access to storage owned by the filesystem.
> The application *must* play by the filesystem rules. Stop trying to
> hack around the fact that the filesystem controls access to the
> block mapping.

This is a filesystem opt-in feature if a given filesystem do not want
to implement it then just do not implement it and it will use page
cache. It is not mandatory i am not forcing anyone. The first reasons
for those are not filesystem but mmap of device file. But as LSF/MM
is up i thought it would be a good time to maybe propose that for file-
system too. If you do not want that for your filesystem then just NAK
any patch that add that to filesystem you care about.

> 
> >     - lease break time induce latency
> 
> Lease breaks should never happen in normal workloads, so this isn't
> an issue. IF you have an application that requires exclusive access,
> then ensure that the file can only be accessed by the application
> and the lease should never be broken.
> 
> But if you are going to ask for filesystems to hand out block
> mapping for thrid party access, the 3rd parties need to play by the
> filesystem's access rules, and that means they /must/ break access
> if the filesystem asks them to.

The mmu notifier give you revocation at any _time_ without round
trip to user space.

> 
> >     - lease may require privileges for the applications
> 
> If you can directly access the underlying block device (which
> requires root/CAP_SYS_ADMIN) then the application has sufficient
> privilege to get a file layout lease.

Again here i am tageting mmap of file and thus do not necessarily
need the same privileges as lease (AFAIK).

> 
> >     - work on file descriptor not virtual addresses
> 
> Sorry, what? You want direct access to the underlying storage device
> for direct DMA, not access to the page cache. i.e. you need a
> mapping for a range of a file (from offset X to Y) and you most
> definitely do not need the file to be virtually mapped for that.
> 
> If you want to DMA from a userspace or peer device memory to storage
> directly, then you definitely do not want the file to mapped into
> the page cache, and so mmap() is most definitely the wrong interface
> to be using to set up direct storage access to a file.

I am starting from _existing_ application that do mmap and thus mmap
is the base assumption it is my starting point. I am not trying to
do some kind of new workload, i am trying to allow existing application
to leverage new storage technology more efficiently without changing
a single line in those application.

I believe kernel should always try to improve existing application
workload with no modification to the application whenever possible.

> 
> > While what i am trying to achieve is:
> >     - support any number of process
> 
> file leases don't prevent that.

I was under the impression that there could be only one lease at a
time per file. Sorry if i was wrong.

> 
> >     - work on virtual addresses
> 
> like direct io, get_user_pages() works just fine for this.

Here i am getting away of GUP to avoid the pinning issues related
to GUP hence why there is no need in what i propose to pin anything.
What i am trying to do is skip out the page cache copy if at all
possible (depending on many factors) so that application can get
better performance without modification.

> >     - is an optimization ie falling back to page cache is _always_
> >       acceptable
> 
> No, it isn't. Falling back to the page cache will break the layout
> lease because the lock filesystem does IO that breaks existing
> leases. You can't have both a layout lease and page cache access to
> the same file.

Yes and this is what i want to do, mmap access is from where i start
so as a starting point it is what i would like to allow. If you do
not want that for your filesystem fine.

> 
> >     - no changes to userspace program ie existing program can
> >       benefit from this by just running on a kernel with the
> >       feature on the system with hardware that support this.
> 
> That's a pipe dream. Existing direct access applications /don't work/ with
> file-backed mmap() ranges. They will not work with DAX, either, so
> please stop with the "work with unmodified existing applications"
> already.

I am talking about existing application that do mmap, i do not care
about application that do direct access this is not what i am trying
to address. I want to improve application that use mmap.

> 
> If you want peer to peer DMA to filesystem managed storage, then you
> *must* use the filesystem to manage access to that storage.

And the callback just do that, they give control to the filesystem, if
the callback is not there then page cache is use, if it is there then
the filesystem do not always have to succeed and it can fails and just
fallbacks to page cache.

> 
> >     - allow multiple different devices to map the block (can be
> >       read only if the fabric between devices is not cache coherent)
> 
> Nothing about a layout lease prevents that. What the application
> does with the layout lease is it's own business.
> 
> >     - it is an optimization ie avoiding to waste main memory if file
> >       is only accessed by device
> 
> Layout leases don't prevent this - they are explicitly for allowing
> this sort of access to be made safely.
> 
> >     - there is _no pin_ and it can be revoke at _any_ time from within
> >       the kernel ie there is no need to rely on application to do the
> >       right thing
> 
> Revoke how, exactly? Are you really proposing sending SEGV to user
> processes as the revoke mechanism?

No, just mmu notifier, exactly what happens on write-back, truncate, ...
you can walk all rmap of page and trigger mmu notifier for it or reverse
walk file offset range and trigger mmu notifier for those.

So there is no disruption to the application. After revocation it page
fault again and the cycle start again either it end up in page cache
or the same callback is call again.

> 
> >     - not only support filesystem but also vma that comes from device
> >       file
> 
> What's a "device file" and how is that any difference from a normal
> kernel file?

Many device driver expose object (for instance all the GPU driver) through
their device file and allow userspace to mmap the device file to access
those object. At a given offset in the device file you will find a given
object and this can be per application or global to all application.

> 
> > The motivation is coming from new storage technology (NVMe with CMB for
> > instance) where block device can offer byte addressable access to block.
> > It can be read only or read and write. When you couple this with gpu,
> > fgpa, tpu that can crunch massive data set (in the tera bytes ranges)
> > then avoiding going through main memory becomes an appealing prospect.
> >
> > If we can achieve that with no disruption to the application programming
> > model the better it is. By allowing to mediate direct block access through
> > vma we can achieve that.
> 
> I have a hammer that I can use to mediate direct block access, too.
> 
> That doesn't mean it's the right tool for the job. At it's most
> fundamental level, the block mapping is between an inode, the file
> offset and the LBA range in the block device that the storage device
> presents to users. This is entirely /filesystem information/ and we
> already have interfaces to manage and arbitrate safe direct storage
> access for third parties.
> 
> Stop trying to re-invent the wheel and use the one we already have

I have a starting point mmap and this is what i try to improve.
.
> 
> > This is why i am believe something at the vma level is better suited to
> > make such thing as easy and transparent as possible. Note that unlike
> > GUP there is _no pinning_ so filesystem is always in total control and
> > can revoke at _any_ time.
> 
> Revoke how, exactly? And how do applications pause and restart when
> this undefined revoke mechanism is invoked? What happens to access
> latency when this revoke occurs and why is this any different to
> having a file layout lease revoked?

Application do not pause in anyway, after invalidation it will page
fault exactly as with truncate or write back. Then the callback is
call again and the filesystem can say no this time and it will fall
back to the page cache. There is no change to existing application
it just works as it does now with no changes in behavior.

> 
> > Also because it is all kernel side we should
> > achieve much better latency (flushing device page table is usualy faster
> > then switching to userspace and having userspace calling back into the
> > driver).
> > 
> > 
> > > 
> > > > So i would like to gather people feedback on general approach and few things
> > > > like:
> > > >     - Do block device need to be able to invalidate such mapping too ?
> > > > 
> > > >       It is easy for fs the to invalidate as it can walk file mappings
> > > >       but block device do not know about file.
> > > 
> > > If you are needing the block device to invalidate filesystem level
> > > information, then your model is all wrong.
> > 
> > It is _not_ a requirement. It is a feature and it does not need to be
> > implemented right away the motivation comes from block device that can
> > manage their PCIE BAR address space dynamicly and they might want to
> > unmap some block to make room for other block. For this they would need
> > to make sure that they can revoke access from device or CPU they might
> > have mapped the block they want to evict.
> 
> This has nothing to do with the /layout lease/. Layout leases are
> for managing direct device access, not how the application interacts
> with the hardware that it has been given a block mapping for.
> 
> Jerome, it seems to me like you're conflating hardware management
> issues with block device access and LBA management. These are
> completely separate things that the application has to manage - the
> filesystem and the layout lease doesn't give a shit about whether
> the application has exhausted the hardware PCIE BAR space.  i.e.
> hardware kicking out a user address mapping does not invalidate the
> layout lease in any way - it just requires the application to set up
> that direct access map in the hardware again.  The file offset to
> LBA mapping that the layout lease manages is entirely unaffected by
> this sort of problem.

Ignore this point if it confuse you, it just something that can be
ignore unless it becomes a problem.

> 
> > > >     - Maybe some share helpers for block devices that could track file
> > > >       corresponding to peer mapping ?
> > > 
> > > If the application hasn't supplied the peer with the file it needs
> > > to access, get a lease from and then map an LBA range out of, then
> > > you are doing it all wrong.
> > 
> > I do not have the same programming model than one you have in mind, i
> > want to allow existing application which mmap files and access that
> > mapping through a device or CPU to directly access those blocks through
> > the virtual address.
> 
> Which is the *wrong model*.
> 
> mmap() of a file-backed mapping does not provide a sane, workable
> direct storage access management API. It's fundamentally flawed
> because it does not provide any guarantee about the underlying
> filesystem information (e.g. the block mapping) and as such, results
> in a largely unworkable model that we need all sorts of complexity
> to sorta make work.
> 
> Layout leases and the export ops provide the application with the
> exact information they need to directly access the storage
> underneath the filesystem in a safe manner. They do not, in any way,
> control how the application then uses that information. If you
> really want to use mmap() to access the storage, then you can mmap()
> the ranges of the block device the ->map_blocks() method tells you
> belong to that file. 
> 
> You can do whatever you want with those vmas and the filesystem
> doesn't care - it's not involved in /any way whatsoever/ with the
> data transfer into and out of the storage because ->map_blocks has
> guaranteed that the storage is allocated. All the application needs
> to do is call ->commit_blocks on each range of the mapping it writes
> data into to tell the filesystem it now contains valid data.  It's
> simple, straight forward, and hard to get wrong from both userspace
> and the kernel filesystem side.\
> 
> Please stop trying to invent new and excitingly complex ways to do
> direct block access because we ialready have infrastructure we know
> works, we already support and is flexible enough to provide exactly
> the sort of direct block device access mechainsms that you are
> asking for.

I understand you do not like mmap but it has been around long enough
that it is extensively use and we have to accept that. There is no
changing all the applications that exist out there and that rely on
mmap and this is for those applications that such optimization would
help.

Cheers,
Jérôme

