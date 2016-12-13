Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 238B56B0253
	for <linux-mm@kvack.org>; Tue, 13 Dec 2016 15:31:17 -0500 (EST)
Received: by mail-vk0-f69.google.com with SMTP id y197so66627328vky.6
        for <linux-mm@kvack.org>; Tue, 13 Dec 2016 12:31:17 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z131si13929059vke.101.2016.12.13.12.31.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Dec 2016 12:31:16 -0800 (PST)
Date: Tue, 13 Dec 2016 15:31:13 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [LSF/MM TOPIC] Un-addressable device memory and block/fs
 implications
Message-ID: <20161213203112.GE2305@redhat.com>
References: <20161213181511.GB2305@redhat.com>
 <20161213201515.GB4326@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20161213201515.GB4326@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org

On Wed, Dec 14, 2016 at 07:15:15AM +1100, Dave Chinner wrote:
> On Tue, Dec 13, 2016 at 01:15:11PM -0500, Jerome Glisse wrote:
> > I would like to discuss un-addressable device memory in the context of
> > filesystem and block device. Specificaly how to handle write-back, read,
> > ... when a filesystem page is migrated to device memory that CPU can not
> > access.
> 
> You mean pmem that is DAX-capable that suddenly, without warning,
> becomes non-DAX capable?
> 
> If you are not talking about pmem and DAX, then exactly what does
> "when a filesystem page is migrated to device memory that CPU can
> not access" mean? What "filesystem page" are we talking about that
> can get migrated from main RAM to something the CPU can't access?

I am talking about GPU, FPGA, ... any PCIE device that have fast on
board memory that can not be expose transparently to the CPU. I am
reusing ZONE_DEVICE for this, you can see HMM patchset on linux-mm
https://lwn.net/Articles/706856/

So in my case i am only considering non DAX/PMEM filesystem ie any
"regular" filesystem back by a "regular" block device. I want to be
able to migrate mmaped area of such filesystem to device memory while
the device is actively using that memory.

>From kernel point of view such memory is almost like any other, it
has a struct page and most of the mm code is non the wiser, nor need
to be about it. CPU access trigger a migration back to regular CPU
accessible page.

But for thing like writeback i want to be able to do writeback with-
out having to migrate page back first. So that data can stay on the
device while writeback is happening.

Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
