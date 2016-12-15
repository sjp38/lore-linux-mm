Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id B57CA6B0069
	for <linux-mm@kvack.org>; Thu, 15 Dec 2016 11:19:42 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id w13so12656460wmw.0
        for <linux-mm@kvack.org>; Thu, 15 Dec 2016 08:19:42 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id qr6si2804199wjc.79.2016.12.15.08.19.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 15 Dec 2016 08:19:41 -0800 (PST)
Date: Thu, 15 Dec 2016 17:19:39 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] Un-addressable device memory and
 block/fs implications
Message-ID: <20161215161939.GF13811@quack2.suse.cz>
References: <20161213181511.GB2305@redhat.com>
 <20161213201515.GB4326@dastard>
 <20161213203112.GE2305@redhat.com>
 <20161213211041.GC4326@dastard>
 <20161213212433.GF2305@redhat.com>
 <20161214111351.GC18624@quack2.suse.cz>
 <20161214171514.GB14755@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161214171514.GB14755@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, linux-block@vger.kernel.org, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org

On Wed 14-12-16 12:15:14, Jerome Glisse wrote:
<snipped explanation that the device has the same cabilities as CPUs wrt
page handling>

> > So won't it be easier to leave the pagecache page where it is and *copy* it
> > to the device? Can the device notify us *before* it is going to modify a
> > page, not just after it has modified it? Possibly if we just give it the
> > page read-only and it will have to ask CPU to get write permission? If yes,
> > then I belive this could work and even fs support should be doable.
> 
> Well yes and no. Device obey the same rule as CPU so if a file back page is
> map read only in the process it must first do a write fault which will call
> in the fs (page_mkwrite() of vm_ops). But once a page has write permission
> there is no way to be notify by hardware on every write. First the hardware
> do not have the capability. Second we are talking thousand (10 000 is upper
> range in today device) of concurrent thread, each can possibly write to page
> under consideration.

Sure, I meant whether the device is able to do equivalent of ->page_mkwrite
notification which apparently it is. OK.

> We really want the device page to behave just like regular page. Most fs code
> path never map file content, it only happens during read/write and i believe
> this can be handled either by migrating back or by using bounce page. I want
> to provide the choice between the two solutions as one will be better for some
> workload and the other for different workload.

I agree with keeping page used by the device behaving as similar as
possible as any other page. I'm just exploring different possibilities how
to make that happen. E.g. the scheme I was aiming at is:

When you want page A to be used by the device, you set up page A' in the
device but make sure any access to it will fault.

When the device wants to access A', it notifies the CPU, that writeprotects
all mappings of A, copy A to A' and map A' read-only for the device.

When the device wants to write to A', it notifies CPU, that will clear all
mappings of A and mark A as not-uptodate & dirty. When the CPU will then
want to access the data in A again - we need to catch ->readpage,
->readpages, ->writepage, ->writepages - it will writeprotect A' in
the device, copy data to A, mark A as uptodate & dirty, and off we go.

When we want to write to the page on CPU - we get either wp fault if it was
via mmap, or we have to catch that in places using kmap() - we just remove
access to A' from the device.

This scheme makes the device mapping functionality transparent to the
filesystem (you actually don't need to hook directly into ->readpage etc.
handlers, you can just have wrappers around them for this functionality)
and fairly straightforward... It is so transparent that even direct IO works
with this since the page cache invalidation pass we do before actually doing
the direct IO will make sure to pull all the pages from the device and write
them to disk if needed. What do you think?

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
