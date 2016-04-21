Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id EAC2A828E8
	for <linux-mm@kvack.org>; Wed, 20 Apr 2016 23:10:34 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e190so123417993pfe.3
        for <linux-mm@kvack.org>; Wed, 20 Apr 2016 20:10:34 -0700 (PDT)
Received: from g1t5424.austin.hp.com (g1t5424.austin.hp.com. [15.216.225.54])
        by mx.google.com with ESMTPS id ur6si725418pac.226.2016.04.20.20.10.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Apr 2016 20:10:31 -0700 (PDT)
Subject: Re: [PATCH v3 0/2] Align mmap address for DAX pmd mappings
References: <1460652511-19636-1-git-send-email-toshi.kani@hpe.com>
 <20160415220531.c7b55adb5b26eb749fae3186@linux-foundation.org>
 <20160418202610.GA17889@quack2.suse.cz>
 <20160419182347.GA29068@linux.intel.com>
From: Toshi Kani <toshi.kani@hpe.com>
Message-ID: <571844A1.5080703@hpe.com>
Date: Wed, 20 Apr 2016 23:10:25 -0400
MIME-Version: 1.0
In-Reply-To: <20160419182347.GA29068@linux.intel.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>, Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, dan.j.williams@intel.com, viro@zeniv.linux.org.uk, ross.zwisler@linux.intel.com, kirill.shutemov@linux.intel.com, david@fromorbit.com, tytso@mit.edu, adilger.kernel@dilger.ca, linux-nvdimm@ml01.01.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 4/19/2016 2:23 PM, Matthew Wilcox wrote:
> On Mon, Apr 18, 2016 at 10:26:10PM +0200, Jan Kara wrote:
>> On Fri 15-04-16 22:05:31, Andrew Morton wrote:
>>> On Thu, 14 Apr 2016 10:48:29 -0600 Toshi Kani <toshi.kani@hpe.com> wrote:
>>>
>>>> When CONFIG_FS_DAX_PMD is set, DAX supports mmap() using pmd page
>>>> size.  This feature relies on both mmap virtual address and FS
>>>> block (i.e. physical address) to be aligned by the pmd page size.
>>>> Users can use mkfs options to specify FS to align block allocations.
>>>> However, aligning mmap address requires code changes to existing
>>>> applications for providing a pmd-aligned address to mmap().
>>>>
>>>> For instance, fio with "ioengine=mmap" performs I/Os with mmap() [1].
>>>> It calls mmap() with a NULL address, which needs to be changed to
>>>> provide a pmd-aligned address for testing with DAX pmd mappings.
>>>> Changing all applications that call mmap() with NULL is undesirable.
>>>>
>>>> This patch-set extends filesystems to align an mmap address for
>>>> a DAX file so that unmodified applications can use DAX pmd mappings.
>>> Matthew sounded unconvinced about the need for this patchset, but I
>>> must say that
>>>
>>> : The point is that we do not need to modify existing applications for using
>>> : DAX PMD mappings.
>>> :
>>> : For instance, fio with "ioengine=mmap" performs I/Os with mmap().
>>> : https://github.com/caius/fio/blob/master/engines/mmap.c
>>> :
>>> : With this change, unmodified fio can be used for testing with DAX PMD
>>> : mappings.  There are many examples like this, and I do not think we want
>>> : to modify all applications that we want to evaluate/test with.
>>>
>>> sounds pretty convincing?
>>>
>>>
>>> And if we go ahead with this, it looks like 4.7 material to me - it
>>> affects ABI and we want to get that stabilized asap.  What do people
>>> think?
>> So I think Mathew didn't question the patch set as a whole. I think we all
>> agree that we should align the virtual address we map to so that PMD
>> mappings can be used. What Mathew was questioning was whether we really
>> need to play tricks when logical offset in the file where mmap is starting
>> is not aligned (and similarly for map length). Whether allowing PMD
>> mappings for unaligned file offsets is worth the complication is IMO a
>> valid question.
> I was questioning the approach as a whole ... since we have userspace
> already doing this in the form of NVML, do we really need the kernel to
> do this for us?
>
> Now, a further wrinkle.  We have two competing patch sets (from Kirill
> and Hugh) which are going to give us THP for page cache filesystems.
> I would suggest that this is not DAX functionality but rather VFS
> functionality to opportunistically align all mmaps on files which are
> reasonably likely to be able to use THP.
>
> I hadn't thought about this until earlier today, and I'm sorry I didn't
> raise it further.  Perhaps we can do a lightning session on this later
> today at LSFMM since all six (Toshi, Andrew, Jan, Hugh, Kirill and myself)
> are here.

How about moving the function (as is) to mm/huge_memory.c, rename it to
get_hugepage_unmapped_area(), which is defined to NULL in huge_mm.h
when TRANSPARENT_HUGEPAGE is unset?

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
