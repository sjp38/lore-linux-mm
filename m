Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id F0DD16B000A
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 13:43:03 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id h24-v6so18942096eda.10
        for <linux-mm@kvack.org>; Thu, 18 Oct 2018 10:43:03 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v10-v6si1039819ejr.314.2018.10.18.10.43.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Oct 2018 10:43:02 -0700 (PDT)
Date: Thu, 18 Oct 2018 19:43:00 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: Problems with VM_MIXEDMAP removal from /proc/<pid>/smaps
Message-ID: <20181018174300.GT23493@quack2.suse.cz>
References: <20181002142010.GB4963@linux-x5ow.site>
 <20181002144547.GA26735@infradead.org>
 <20181002150123.GD4963@linux-x5ow.site>
 <20181002150634.GA22209@infradead.org>
 <20181004100949.GF6682@linux-x5ow.site>
 <20181005062524.GA30582@infradead.org>
 <20181005063519.GA5491@linux-x5ow.site>
 <CAPcyv4jD4VgRaKDQF9eMmjhMEHjUJqRU8i6OC+-=0domCc9u3A@mail.gmail.com>
 <CAPcyv4i7WJsq3BMASozjjbpMmEiS4AqmRS0kt3=rHdGfb5YvLA@mail.gmail.com>
 <CAPcyv4jt_w-89+m4w=FcN0oF3axiGqPBTHfEcWwdhnr12_=17Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4jt_w-89+m4w=FcN0oF3axiGqPBTHfEcWwdhnr12_=17Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Johannes Thumshirn <jthumshirn@suse.de>, Christoph Hellwig <hch@infradead.org>, Jan Kara <jack@suse.cz>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, Michal Hocko <mhocko@suse.cz>

On Wed 17-10-18 13:01:15, Dan Williams wrote:
> On Sun, Oct 14, 2018 at 8:47 AM Dan Williams <dan.j.williams@intel.com> wrote:
> >
> > On Fri, Oct 5, 2018 at 6:17 PM Dan Williams <dan.j.williams@intel.com> wrote:
> > >
> > > On Thu, Oct 4, 2018 at 11:35 PM Johannes Thumshirn <jthumshirn@suse.de> wrote:
> > > >
> > > > On Thu, Oct 04, 2018 at 11:25:24PM -0700, Christoph Hellwig wrote:
> > > > > Since when is an article on some website a promise (of what exactly)
> > > > > by linux kernel developers?
> > > >
> > > > Let's stop it here, this doesn't make any sort of forward progress.
> > > >
> > >
> > > I do think there is some progress we can make if we separate DAX as an
> > > access mechanism vs DAX as a resource utilization contract. My attempt
> > > at representing Christoph's position is that the kernel should not be
> > > advertising / making access mechanism guarantees. That makes sense.
> > > Even with MAP_SYNC+DAX the kernel reserves the right to write-protect
> > > mappings at will and trap access into a kernel handler. Additionally,
> > > whether read(2) / write(2) does anything different behind the scenes
> > > in DAX mode, or not should be irrelevant to the application.
> > >
> > > That said what is certainly not irrelevant is a kernel giving
> > > userspace visibility and control into resource utilization. Jan's
> > > MADV_DIRECT_ACCESS let's the application make assumptions about page
> > > cache utilization, we just need to another mechanism to read if a
> > > mapping is effectively already in that state.
> >
> > I thought more about this today while reviewing the virtio-pmem driver
> > that will behave mostly like a DAX-capable pmem device except it will
> > be implemented by passing host page cache through to the guest as a
> > pmem device with a paravirtualized / asynchronous flush interface.
> > MAP_SYNC obviously needs to be disabled for this case, but still need
> > allow to some semblance of DAX operation to save allocating page cache
> > in the guest. The need to explicitly clarify the state of DAX is
> > growing with the different nuances of DAX operation.
> >
> > Lets use a new MAP_DIRECT flag to positively assert that a given
> > mmap() call is setting up a memory mapping without page-cache or
> > buffered indirection. To be clear not my original MAP_DIRECT proposal
> > from a while back, instead just a flag to mmap() that causes the
> > mapping attempt to fail if there is any software buffering fronting
> > the memory mapping, or any requirement for software to manage flushing
> > outside of pushing writes through the cpu cache. This way, if we ever
> > extend MAP_SYNC for a buffered use case we can still definitely assert
> > that the mapping is "direct". So, MAP_DIRECT would fail for
> > traditional non-DAX block devices, and for this new virtio-pmem case.
> > It would also fail for any pmem device where we cannot assert that the
> > platform will take care of flushing write-pending-queues on power-loss
> > events.
> 
> After letting this set for a few days I think I'm back to liking
> MADV_DIRECT_ACCESS more since madvise() is more closely related to the
> page-cache management than mmap. It does not solve the query vs enable
> problem, but it's still a step towards giving applications what they
> want with respect to resource expectations.

Yeah, I don't have a strong opinion wrt mmap flag vs madvise flag.

> Perhaps a new syscall to retrieve the effective advice for a range?
> 
>      int madvice(void *addr, size_t length, int *advice);

After some thought, I'm not 100% sure this is really needed. I know about
apps that want to make sure DRAM is not consumed - for those mmap / madvise
flag is fine if it returns error in case the feature cannot be provided.
Most other apps don't care whether DAX is on or off. So this call would be
needed only if someone wanted to behave differently depending on whether
DAX is used or not. And although I can imagine some application like that,
I'm not sure how real that is...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
