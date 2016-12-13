Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 846BD6B0038
	for <linux-mm@kvack.org>; Tue, 13 Dec 2016 13:55:50 -0500 (EST)
Received: by mail-vk0-f72.google.com with SMTP id x186so63739568vkd.1
        for <linux-mm@kvack.org>; Tue, 13 Dec 2016 10:55:50 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e10si13677100uaa.209.2016.12.13.10.55.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Dec 2016 10:55:49 -0800 (PST)
Date: Tue, 13 Dec 2016 13:55:46 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [LSF/MM TOPIC] Un-addressable device memory and block/fs
 implications
Message-ID: <20161213185545.GC2305@redhat.com>
References: <20161213181511.GB2305@redhat.com>
 <1481653252.2473.51.camel@HansenPartnership.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1481653252.2473.51.camel@HansenPartnership.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org

On Tue, Dec 13, 2016 at 10:20:52AM -0800, James Bottomley wrote:
> On Tue, 2016-12-13 at 13:15 -0500, Jerome Glisse wrote:
> > I would like to discuss un-addressable device memory in the context 
> > of filesystem and block device. Specificaly how to handle write-back,
> > read, ... when a filesystem page is migrated to device memory that 
> > CPU can not access.
> > 
> > I intend to post a patchset leveraging the same idea as the existing
> > block bounce helper (block/bounce.c) to handle this. I believe this 
> > is worth discussing during summit see how people feels about such 
> > plan and if they have better ideas.
> 
> Isn't this pretty much what the transcendent memory interfaces we
> currently have are for?  It's current use cases seem to be compressed
> swap and distributed memory, but there doesn't seem to be any reason in
> principle why you can't use the interface as well.
> 

I am not a specialist of tmem or cleancache but my understand is that
there is no way to allow for file back page to be dirtied while being
in this special memory.

In my case when you migrate a page to the device it might very well be
so that the device can write something in it (results of some sort of
computation). So page might migrate to device memory as clean but
return from it in dirty state.

Second aspect is that even if memory i am dealing with is un-addressable
i still have struct page for it and i want to be able to use regular
page migration.

So given my requirement i didn't thought that cleancache was the way
to address them. Maybe i am wrong.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
