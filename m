Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 905D96B0035
	for <linux-mm@kvack.org>; Wed, 13 Aug 2014 08:08:27 -0400 (EDT)
Received: by mail-wi0-f176.google.com with SMTP id bs8so7283996wib.15
        for <linux-mm@kvack.org>; Wed, 13 Aug 2014 05:08:26 -0700 (PDT)
Received: from mail-we0-x236.google.com (mail-we0-x236.google.com [2a00:1450:400c:c03::236])
        by mx.google.com with ESMTPS id v3si25828990wix.58.2014.08.13.05.08.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 13 Aug 2014 05:08:25 -0700 (PDT)
Received: by mail-we0-f182.google.com with SMTP id k48so11206194wev.13
        for <linux-mm@kvack.org>; Wed, 13 Aug 2014 05:08:25 -0700 (PDT)
Message-ID: <53EB5536.8020702@gmail.com>
Date: Wed, 13 Aug 2014 15:08:22 +0300
From: Boaz Harrosh <openosd@gmail.com>
MIME-Version: 1.0
Subject: [RFC 0/9] pmem: Support for "struct page" with Persistent Memory
 storage
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Matthew Wilcox <willy@linux.intel.com>, Sagi Manole <sagi@plexistor.com>, Yigal Korman <yigal@plexistor.com>

Hi Folks

There are already NvDIMMs and other PMEM devices in the market, though very rare still.
However in Linux we like to get ready for them before hand.

Current stack is coming along very nice, and filesystems supporting and leveraging this
technologies have been submitted for review in the DAX series by Matthew Wilcox.

The PMEM industry has been speaking of re inventing the wheel of storage and providing
an alternative API for storage in the form of persist_alloc(,UUID,...) for applications
to use.

But The general consensus by the Kernel flocks is that an FS like ext4 over a "direct_access"
block device supplies that API perfectly with a user simple call sequence of:
	fd = open(,"UUID_STR",);
	mmap(fd,);
And there, the wheel has already been invented.

So the PMEM stack is the usual:
	block-device
	partition
	file-system
	application file

With extra care, see Matthew's DAX patches, to shorten the stack so at the application
level when finally a store/load CPU operation is done on an mmaped pointer it will go
directly to pmem. (OK after the call to msync to flush CPU caches), but certainly
no extra copies are made anywhere in the stack.

The only thing missing from current design is that this pmem memory region is very
alien to the rest of the Kernel, application access to this memory is enabled but
if we want to send this memory on the network or to a slower block device and/or to
any device in the system. We are not able to do this. This is because of a missing
struct page support for this memory.
This shortcomings is easily fixable by this patchset. Actually by the last two
patches. The other patches are just development stuff of the prd.ko (Persistent Ram Disk)
that is destined to mange the pmem devices.

Ross hi, I have based a *prd* tree on my brd-partition branch which I hope will go into Kernel
ASAP, even into 3.17. This tree includes all your patches, slightly re-orders you can
see it here:
	git://git.open-osd.org/linux-open-osd.git branch prd-3.16
on web:
	http://git.open-osd.org/gitweb.cgi?p=linux-open-osd.git;a=shortlog;h=refs/heads/prd-3.16

This is what one will fine on the prd-3.16 branch:
7a70a75 Boaz Harrosh        |  (prd-3.16) prd: Add support for page struct mapping 
9a367c6 Yigal Korman        |  MM: export sparse_add_one_section/sparse_remove_one_section 
62c96b7 Boaz Harrosh        |  SQUASHME: prd: Support of multiple memory regions 
9290c1b Boaz Harrosh        |  SQUASHME: prd: Let each prd-device manage private memory region 
bfefdbb Boaz Harrosh        |  SQUASHME: prd: Last fixes for partitions 
0a7c7e4 Boaz Harrosh        |  SQUASHME: prd: Fixs to getgeo 

  From here on this is exactly Ross's prd tree, patches slight reordered.

709891f Ross Zwisler        |  prd: Add getgeo to block ops 
3ce69f4fe Ross Zwisler      |  prd: add support for rw_page() 
4fb0ac8 Ross Zwisler        |  SQUASHME: prd: Remove Kconfig default for PRD 
8dafb03 Ross Zwisler        |  SQUASHME: prd: remove redundant checks in prd_direct_access 
0373be8 Ross Zwisler        |  SQUASHME: prd: Updates to comments & whitespace 
0ef8f82 Ross Zwisler        |  SQUASHME: prd: Improve wording in Kconfig 
eb11421 Ross Zwisler        |  SQUASHME: prd: Dynamically allocate partition numbers 
9021eae Ross Zwisler        |  SQUASHME: prd: Remove support for discard 
4805046 Ross Zwisler        |  SQUASHME: prd: enable partitions and surface by default 
9550836 Ross Zwisler        |  SQUASHME: prd: workaround to stop weird partition overlap 
c9d84b3 Ross Zwisler        |  SQUASHME: prd: fix error handling in prd_init 
252aaff Ross Zwisler        |  prd: Initial version of Persistent RAM Driver 
a49772c Boaz Harrosh        |  (ooo/brd-partitions, brd-partitions) brd: Request from fdisk 4k alignment 

[I have edited all the commit messages to add "SQUASHME" at start so to denote to user that
 these will be incorporated into a previous patch before online submission.]

For review and discussion here I am submitting the SQUASHed prd-initial-version for
the reviewers to have a context on what we are talking about, then a set of my patches
for prd. Finally two patches one to mm and the second to prd for page-struct support.

List of patches:
[RFC 1/9] prd: Initial version of Persistent RAM Driver
[RFC 2/9] prd: add support for rw_page()
[RFC 3/9] prd: Add getgeo to block ops

	Up to here it is the latest code from Ross's prd tree

[RFC 4/9] SQUASHME: prd: Fixs to getgeo
[RFC 5/9] SQUASHME: prd: Last fixes for partitions
[RFC 6/9] SQUASHME: prd: Let each prd-device manage private memory
[RFC 7/9] SQUASHME: prd: Support of multiple memory regions

	These 4 are my fixes to the prd driver. Ross please review
	and submit to your tree.

[RFC 8/9] mm: export sparse_add/remove_one_section
[RFC 9/9] prd: Add support for page struct mapping

	These two are for the MM guys to comment, and for anyone
	that is interested in the PMEM technology.
	I wanted to post an example Kernel module that will demonstrate
	the use of pages, on top of bdev_direct_access(). But its not
	cleaned up and finished, I will send it later.

These can be found here:
	git://git.open-osd.org/linux-open-osd.git branch prd
on web:
	http://git.open-osd.org/gitweb.cgi?p=linux-open-osd.git;a=shortlog;h=refs/heads/prd

And one last Rant if I may?
I hate the prd name, why why? OK so a freak of bad luck forced us to invent a new name for
/dev/ram because it would be weird to do an lsmod and see a ram.ko hanging there which is actually
a block device driver. OK so a brd == /dev/ram. But why do we need to carry this punishment forever?
Why an additional/different name in the namespace? /dev/foo should just be foo.ko in lsmod, No?
So please, please, for my peace of mind can we call this driver pmem.ko?
I know, I would hate it if I was inventing a name and people change it, so Ross it is your call, is
it OK if we move back to just call it pmem everywhere?

Thanks
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
