Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 17B416B0038
	for <linux-mm@kvack.org>; Tue, 26 Aug 2014 16:34:20 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id r10so22781616pdi.6
        for <linux-mm@kvack.org>; Tue, 26 Aug 2014 13:34:19 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [143.182.124.21])
        by mx.google.com with ESMTP id bb4si5649073pdb.249.2014.08.26.13.34.18
        for <linux-mm@kvack.org>;
        Tue, 26 Aug 2014 13:34:18 -0700 (PDT)
Message-ID: <1409085242.6066.7.camel@rzwisler-mobl1.amr.corp.intel.com>
Subject: Re: [PATCH 5/9 v2] SQUASHME: prd: Last fixes for partitions
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Date: Tue, 26 Aug 2014 14:34:02 -0600
In-Reply-To: <53FCC593.6020201@gmail.com>
References: <53EB5536.8020702@gmail.com> <53EB5709.4090401@plexistor.com>
	 <53ECB480.4060104@plexistor.com>
	 <1408997403.17731.7.camel@rzwisler-mobl1.amr.corp.intel.com>
	 <53FC42C5.6040300@plexistor.com> <53FCC593.6020201@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <openosd@gmail.com>
Cc: Boaz Harrosh <boaz@plexistor.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Matthew Wilcox <willy@linux.intel.com>, Sagi Manole <sagi@plexistor.com>, Yigal Korman <yigal@plexistor.com>

On Tue, 2014-08-26 at 20:36 +0300, Boaz Harrosh wrote:
> Meanwhile without any explanations, these will come tomorrow, I'm attaching
> the most interesting bit which you have not seen before.
> 
> If you want you can inspect a preview of what's to come here:
> 	http://git.open-osd.org/gitweb.cgi?p=pmem.git;a=summary

Regarding the top patch "pmem: KISS, remove the all pmem_major registration",
I like that we're getting rid of lots of dead code.  The only issue I have is
that I'm pretty sure we aren't supposed to register our disks directly with a
major of BLOCK_EXT_MAJOR.  I think we still need to register our own major via
register_blkdev(), and use that.  I'm fine with getting rid of the module
parameter though, and always getting a major dynamically.

If you look at the other block devices that use the GENHD_FL_EXT_DEVT flag
(nvme, loop, md, etc.) they all register their own major.  You can't see this
major by doing 'ls -l' on the resulting devices in /dev, but you can see it by
looking at /proc/devices:

# ls -l /dev/pmem0
brw-rw---- 1 root disk 259, 0 Aug 26 12:37 /dev/pmem0

# grep pmem /proc/devices 
250 pmem

- Ross


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
