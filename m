Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id AED8A6B0038
	for <linux-mm@kvack.org>; Tue, 13 Dec 2016 15:22:53 -0500 (EST)
Received: by mail-vk0-f72.google.com with SMTP id x186so66181047vkd.1
        for <linux-mm@kvack.org>; Tue, 13 Dec 2016 12:22:53 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q18si13878386uaa.35.2016.12.13.12.22.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Dec 2016 12:22:52 -0800 (PST)
Date: Tue, 13 Dec 2016 15:22:49 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [LSF/MM TOPIC] Un-addressable device memory and block/fs
 implications
Message-ID: <20161213202248.GD2305@redhat.com>
References: <20161213181511.GB2305@redhat.com>
 <1481653252.2473.51.camel@HansenPartnership.com>
 <20161213185545.GC2305@redhat.com>
 <1481659264.2473.59.camel@HansenPartnership.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1481659264.2473.59.camel@HansenPartnership.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org

On Tue, Dec 13, 2016 at 12:01:04PM -0800, James Bottomley wrote:
> On Tue, 2016-12-13 at 13:55 -0500, Jerome Glisse wrote:
> > On Tue, Dec 13, 2016 at 10:20:52AM -0800, James Bottomley wrote:
> > > On Tue, 2016-12-13 at 13:15 -0500, Jerome Glisse wrote:
> > > > I would like to discuss un-addressable device memory in the
> > > > context 
> > > > of filesystem and block device. Specificaly how to handle write
> > > > -back,
> > > > read, ... when a filesystem page is migrated to device memory
> > > > that 
> > > > CPU can not access.
> > > > 
> > > > I intend to post a patchset leveraging the same idea as the
> > > > existing
> > > > block bounce helper (block/bounce.c) to handle this. I believe
> > > > this 
> > > > is worth discussing during summit see how people feels about such
> > > > plan and if they have better ideas.
> > > 
> > > Isn't this pretty much what the transcendent memory interfaces we
> > > currently have are for?  It's current use cases seem to be
> > > compressed
> > > swap and distributed memory, but there doesn't seem to be any
> > > reason in
> > > principle why you can't use the interface as well.
> > > 
> > 
> > I am not a specialist of tmem or cleancache
> 
> Well, that makes two of us; I just got to sit through Dan Magenheimer's
> talks and some stuff stuck.
> 
> >  but my understand is that there is no way to allow for file back 
> > page to be dirtied while being in this special memory.
> 
> Unless you have some other definition of dirtied, I believe that's what
> an exclusive tmem get in frontswap actually does.  It marks the page
> dirty when it comes back because it may have been modified.

Well frontswap only support anonymous or share page, not random filemap
page. So it doesn't help for what i am aiming at :) Note that in my case
the device report accurate dirty information (did the device modified
the page or not) assuming hardware bugs doesn't exist.


> > In my case when you migrate a page to the device it might very well 
> > be so that the device can write something in it (results of some sort 
> > of computation). So page might migrate to device memory as clean but
> > return from it in dirty state.
> > 
> > Second aspect is that even if memory i am dealing with is un
> > -addressable i still have struct page for it and i want to be able to 
> > use regular page migration.
> 
> Tmem keeps a struct page ... what's the problem with page migration?
> the fact that tmem locks the page when it's not addressable and you
> want to be able to migrate the page even when it's not addressable?

Well the way cleancache or frontswap works is that they are use when
kernel is trying to make room or evict something. In my case it is the
device that trigger the migration for a range of virtual address of a
process. Sure i can make a weird helper that would force to frontswap
or cleancache pages i want to migrate but it seems counter intuitive
to me.

One extra requirement for me is to be able to easily and quickly find
the migrated page by looking at the CPU page table of the process.
With frontswap it adds a level of indirection where i need to find
through frontswap the memory. With cleancache there isn't even any
information left (the page table entry is cleared).


> 
> > So given my requirement i didn't thought that cleancache was the way
> > to address them. Maybe i am wrong.
> 
> I'm not saying it is, I just asked if you'd considered it, since the
> requirements look similar.

Yes i briefly consider it but from the highlevel overview i had it did
not seems to address all my requirement. Maybe it is because i lack
in depth knowledge of cleancache/frontswap but skiming through code
didn't convince me that i needed to dig deeper.

The solution i am pursuing use struct page and thus everything is as
if it was regular page to the kernel. The only thing that doesn't work
is kmap or mapping it into a process. But this can easily be handled.
For filesystem issues are about anything that do I/O so read/write/
writeback.

In many case if CPU I/O happens what i want to do is migrate back to a
regular page, so the read/write case is easy. But for writeback if page
is dirty on the device and device reports it (calling set_page_dirty())
then i still want to have writeback to work so i don't loose data (if
device dirtied the page it is probably because it was instructed to
save current computations).

With this in mind, the bounce helper design to work around block device
limitation in respect to page they can access seemed to be a perfect fit.
All i care about is providing a bounce page allowing writeback to happen
without having to go through the "slow" page migration back to system
page.

Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
