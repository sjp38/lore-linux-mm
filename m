Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f180.google.com (mail-io0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id A52D26B0038
	for <linux-mm@kvack.org>; Mon,  2 Nov 2015 09:22:23 -0500 (EST)
Received: by iody8 with SMTP id y8so144437471iod.1
        for <linux-mm@kvack.org>; Mon, 02 Nov 2015 06:22:23 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id yq6si12153250igb.95.2015.11.02.06.22.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Nov 2015 06:22:22 -0800 (PST)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [RFC 00/11] DAX fsynx/msync support
References: <1446149535-16200-1-git-send-email-ross.zwisler@linux.intel.com>
	<20151030035533.GU19199@dastard>
	<20151030183938.GC24643@linux.intel.com>
	<20151101232948.GF10656@dastard>
Date: Mon, 02 Nov 2015 09:22:15 -0500
In-Reply-To: <20151101232948.GF10656@dastard> (Dave Chinner's message of "Mon,
	2 Nov 2015 10:29:48 +1100")
Message-ID: <x49vb9kqy5k.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Dan Williams <dan.j.williams@intel.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@ml01.01.org, x86@kernel.org, xfs@oss.sgi.com, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>

Dave Chinner <david@fromorbit.com> writes:

> Further, REQ_FLUSH/REQ_FUA are more than just "put the data on stable
> storage" commands. They are also IO barriers that affect scheduling
> of IOs in progress and in the request queues.  A REQ_FLUSH/REQ_FUA
> IO cannot be dispatched before all prior IO has been dispatched and
> drained from the request queue, and IO submitted after a queued
> REQ_FLUSH/REQ_FUA cannot be scheduled ahead of the queued
> REQ_FLUSH/REQ_FUA operation.
>
> IOWs, REQ_FUA/REQ_FLUSH not only guarantee data is on stable
> storage, they also guarantee the order of IO dispatch and
> completion when concurrent IO is in progress.

This hasn't been the case for several years, now.  It used to work that
way, and that was deemed a big performance problem.  Since file systems
already issued and waited for all I/O before sending down a barrier, we
decided to get rid of the I/O ordering pieces of barriers (and stop
calling them barriers).

See commit 28e7d184521 (block: drop barrier ordering by queue draining).

Cheers,
Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
