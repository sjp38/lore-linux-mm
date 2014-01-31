Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id 666B56B0035
	for <linux-mm@kvack.org>; Fri, 31 Jan 2014 00:45:31 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id up15so4059375pbc.0
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 21:45:31 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id sd3si9083370pbb.312.2014.01.30.21.45.30
        for <linux-mm@kvack.org>;
        Thu, 30 Jan 2014 21:45:30 -0800 (PST)
Date: Thu, 30 Jan 2014 22:45:26 -0700 (MST)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v5 00/22] Rewrite XIP code and add XIP support to ext4
In-Reply-To: <20140131030652.GK13997@dastard>
Message-ID: <alpine.OSX.2.00.1401302227450.29315@scrumpy>
References: <cover.1389779961.git.matthew.r.wilcox@intel.com> <20140130064230.GG13997@dastard> <20140130092537.GH13997@dastard> <20140131030652.GK13997@dastard>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org

On Fri, 31 Jan 2014, Dave Chinner wrote:
> The read/write path is broken, Willy. We can't map arbitrary byte
> ranges to the DIO subsystem. I'm now certain that the data
> corruptions I'm seeing are in sub-sector regions from unaligned IOs
> from userspace. We still need to use the buffered IO path for non
> O_DIRECT IO to avoid these problems. I think I've worked out a way
> to short-circuit page cache lookups for the buffered IO path, so
> stay tuned....

Hi Dave,

I found an issue that would cause reads to return bad data earlier this week,
and sent a response to "[PATCH v5 22/22] XIP: Add support for unwritten
extents".  Just wanted to make sure you're not running into that issue.  

I'm also currently chasing a write corruption where we lose the data that we
had just written because ext4 thinks the portion of the extent we had just
written needs to be converted from an unwritten extent to a written extent, so
it clears the data to all zeros via:

	xip_clear_blocks+0x53/0xd7
	ext4_map_blocks+0x306/0x3d9 [ext4]
	jbd2__journal_start+0xbd/0x188 [jbd2]
	ext4_convert_unwritten_extents+0xf9/0x1ac [ext4]
	ext4_direct_IO+0x2ca/0x3a5 [ext4]

This bug can be easily reproduced by fallocating an empty file up to a page,
and then writing into that page.  The first write is essentially lost, and the
page remains all zeros.  Subsequent writes succeed.

I'm still in the process of figuring out exactly why this is happening, but
unfortunately I won't be able to look at again until next week.  I don't know
if it's related to the corruption that you're seeing or not, just wanted to
let you know.

- Ross

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
