Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 058F36B0253
	for <linux-mm@kvack.org>; Thu, 15 Dec 2016 14:14:58 -0500 (EST)
Received: by mail-vk0-f72.google.com with SMTP id x186so59033635vkd.1
        for <linux-mm@kvack.org>; Thu, 15 Dec 2016 11:14:58 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 198si1289763vkf.108.2016.12.15.11.14.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Dec 2016 11:14:57 -0800 (PST)
Date: Thu, 15 Dec 2016 14:14:53 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] Un-addressable device memory and
 block/fs implications
Message-ID: <20161215191453.GA3122@redhat.com>
References: <20161213181511.GB2305@redhat.com>
 <20161213201515.GB4326@dastard>
 <20161213203112.GE2305@redhat.com>
 <20161213211041.GC4326@dastard>
 <20161213212433.GF2305@redhat.com>
 <20161214111351.GC18624@quack2.suse.cz>
 <20161214171514.GB14755@redhat.com>
 <20161215161939.GF13811@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20161215161939.GF13811@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Dave Chinner <david@fromorbit.com>, linux-block@vger.kernel.org, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org

On Thu, Dec 15, 2016 at 05:19:39PM +0100, Jan Kara wrote:
> On Wed 14-12-16 12:15:14, Jerome Glisse wrote:
> <snipped explanation that the device has the same cabilities as CPUs wrt
> page handling>
> 
> > > So won't it be easier to leave the pagecache page where it is and *copy* it
> > > to the device? Can the device notify us *before* it is going to modify a
> > > page, not just after it has modified it? Possibly if we just give it the
> > > page read-only and it will have to ask CPU to get write permission? If yes,
> > > then I belive this could work and even fs support should be doable.
> > 
> > Well yes and no. Device obey the same rule as CPU so if a file back page is
> > map read only in the process it must first do a write fault which will call
> > in the fs (page_mkwrite() of vm_ops). But once a page has write permission
> > there is no way to be notify by hardware on every write. First the hardware
> > do not have the capability. Second we are talking thousand (10 000 is upper
> > range in today device) of concurrent thread, each can possibly write to page
> > under consideration.
> 
> Sure, I meant whether the device is able to do equivalent of ->page_mkwrite
> notification which apparently it is. OK.
> 
> > We really want the device page to behave just like regular page. Most fs code
> > path never map file content, it only happens during read/write and i believe
> > this can be handled either by migrating back or by using bounce page. I want
> > to provide the choice between the two solutions as one will be better for some
> > workload and the other for different workload.
> 
> I agree with keeping page used by the device behaving as similar as
> possible as any other page. I'm just exploring different possibilities how
> to make that happen. E.g. the scheme I was aiming at is:
> 
> When you want page A to be used by the device, you set up page A' in the
> device but make sure any access to it will fault.
> 
> When the device wants to access A', it notifies the CPU, that writeprotects
> all mappings of A, copy A to A' and map A' read-only for the device.
> 
> When the device wants to write to A', it notifies CPU, that will clear all
> mappings of A and mark A as not-uptodate & dirty. When the CPU will then
> want to access the data in A again - we need to catch ->readpage,
> ->readpages, ->writepage, ->writepages - it will writeprotect A' in
> the device, copy data to A, mark A as uptodate & dirty, and off we go.
> 
> When we want to write to the page on CPU - we get either wp fault if it was
> via mmap, or we have to catch that in places using kmap() - we just remove
> access to A' from the device.
> 
> This scheme makes the device mapping functionality transparent to the
> filesystem (you actually don't need to hook directly into ->readpage etc.
> handlers, you can just have wrappers around them for this functionality)
> and fairly straightforward... It is so transparent that even direct IO works
> with this since the page cache invalidation pass we do before actually doing
> the direct IO will make sure to pull all the pages from the device and write
> them to disk if needed. What do you think?

This is do-able but i think it will require the same amount of changes than
what i had in mind (excluding the block bounce code) with one drawback. Doing
it that way we can not free page A.

On some workload this probably does not hurt much but on workload where you
read a big dataset from disk and then use it only on the GPU for long period
of time (minutes/hours) you will waste GB of system memory.

Right now i am working on some other patchset, i intend to take a stab at this
in January/February time frame, before summit so i can post an RFC and have a
clear picture of every code path that needs modifications. I expect this would
provide better frame for discussion.

I assume i will have to change >readpage >readpages writepage >writepages but
i think that the only place i really need to change are do_generic_file_read()
and generic_perform_write() (or iov_iter_copy_*). Of course this only apply to
fs that use those generic helpers.

I also probably will change >mmap or rather the helper it uses to set the pte
depending on what looks better.

Note that i don't think wrapping is an easy task. I would need to replace page
A mapping (struct page.mapping) to point to a wrapping address_space but there
is enough place in the kernel that directly dereference that and expect to hit
the right (real) address_space. I would need to replace all dereference of
page->mapping to an helper function and possibly would need to change some of
the call site logic accordingly. This might prove a bigger change than just
having to use bounce in do_generic_file_read() and generic_perform_write().

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
