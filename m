Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id CC23A6B03CD
	for <linux-mm@kvack.org>; Mon,  8 May 2017 11:58:07 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id a66so66545201pfl.6
        for <linux-mm@kvack.org>; Mon, 08 May 2017 08:58:07 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id p30si8603525pgn.165.2017.05.08.08.58.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 May 2017 08:58:06 -0700 (PDT)
Subject: Re: [PATCH RFC] hugetlbfs 'noautofill' mount option
References: <326e38dd-b4a8-e0ca-6ff7-af60e8045c74@oracle.com>
 <b0efc671-0d7a-0aef-5646-a635478c31b0@oracle.com>
 <7ff6fb32-7d16-af4f-d9d5-698ab7e9e14b@intel.com>
 <03127895-3c5a-5182-82de-3baa3116749e@oracle.com>
 <22557bf3-14bb-de02-7b1b-a79873c583f1@intel.com>
 <7677d20e-5d53-1fb7-5dac-425edda70b7b@oracle.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <48a544c4-61b3-acaf-0386-649f073602b6@intel.com>
Date: Mon, 8 May 2017 08:58:05 -0700
MIME-Version: 1.0
In-Reply-To: <7677d20e-5d53-1fb7-5dac-425edda70b7b@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Prakash Sangappa <prakash.sangappa@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 05/03/2017 12:02 PM, Prakash Sangappa wrote:
>>> If we do consider a new madvise()option, will it be acceptable
>>> since this will be specifically for hugetlbfs file mappings?
>> Ideally, it would be something that is *not* specifically for
>> hugetlbfs. MADV_NOAUTOFILL, for instance, could be defined to
>> SIGSEGV whenever memory is touched that was not populated with
>> MADV_WILLNEED, mlock(), etc...
> 
> If this is a generic advice type, necessary support will have to be 
> implemented in various filesystems which can support this.

Yep.

> The proposed behavior for 'noautofill' was to not fill holes in 
> files(like sparse files). In the page fault path, mm would not know
> if the mmapped address on which the fault occurred, is over a hole in
> the file or just that the page is not available in the page cache.

It depends on how you define the feature.  I think you have three choices:

1. "Error" on page fault.  Require all access to be pre-faulted.
2. Allow faults, but "Error" if page cache has to be allocated
3. Allow faults and page cache allocations, but error on filesystem
   backing storage allocation.

All of those are useful in some cases.  But the implementations probably
happen in different places:

#1 can be implemented in core mm code
#2 can be implemented in the VFS
#3 needs filesystem involvement

> The underlying filesystem would be called and it determines if it is
> a hole and that is where it would fail and not fill the hole, if this
> support is added. Normally, filesystem which support sparse
> files(holes in file) automatically fill the hole when accessed. Then
> there is the issue of file system block size and page size. If the 
> block sizes are smaller then page size, it could mean the noautofill 
> would only work if the hole size is equal to or a multiple of, page
> size?

It depends on how you define the feature whether this is true.

> In case of hugetlbfs it is much straight forward. Since this
> filesystem is not like a normal filesystems and and the file sizes
> are multiple of huge pages. The hole will be a multiple of the huge
> page size. For this reason then should the advise be specific to
> hugetlbfs?

Let me paraphrase: it's simpler to implement it if it's specific to
hugetlbfs, thus we should implement it only for hugetlbfs, and keep it
specific to hugetlbfs.

The bigger question is: do we want to continue adding to the complexity
of hugetlbfs and increase its divergence from the core mm?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
