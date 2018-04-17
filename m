Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 45CFE6B0008
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 17:49:39 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id 47so15089596wru.19
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 14:49:39 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i62si3762888edi.355.2018.04.17.14.49.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 Apr 2018 14:49:37 -0700 (PDT)
Subject: Re: [PATCH v10 00/62] Convert page cache to XArray
References: <20180330034245.10462-1-willy@infradead.org>
 <a27d5689-49d9-2802-3819-afd0f1f98483@suse.com>
 <20180414195030.GB31523@bombadil.infradead.org>
 <20180414195859.GC31523@bombadil.infradead.org>
From: Goldwyn Rodrigues <rgoldwyn@suse.de>
Message-ID: <72e416d6-c723-fa0e-7411-8c8f1e9fbc22@suse.de>
Date: Tue, 17 Apr 2018 16:49:30 -0500
MIME-Version: 1.0
In-Reply-To: <20180414195859.GC31523@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>



On 04/14/2018 02:58 PM, Matthew Wilcox wrote:
> On Sat, Apr 14, 2018 at 12:50:30PM -0700, Matthew Wilcox wrote:
>> On Mon, Apr 09, 2018 at 04:18:07PM -0500, Goldwyn Rodrigues wrote:
>>
>> I'm sorry I missed this email.  My inbox is a disaster :(
>>
>>> I tried these patches against next-20180329 and added the patch for the
>>> bug reported by Mike Kravetz. I am getting the following BUG on ext4 and
>>> xfs, running generic/048 tests of fstests. Each trace is from a
>>> different instance/run.
>>
>> Yikes.  I haven't been able to reproduce this.  Maybe it's a matter of
>> filesystem or some other quirk.
>>
>> It seems easy for you to reproduce it, so would you mind bisecting it?
>> Should be fairly straightforward; I'd start at commit "xarray: Add
>> MAINTAINERS entry", since the page cache shouldn't be affected by anything
>> up to that point, then bisect forwards from there.
>>
>>> BTW, for my convenience, do you have these patches in a public git tree?
>>
>> I didn't publish it; it's hard to push out a tree based on linux-next.
>> I'll try to make that happen.
> 
> Figured it out:
> 
> http://git.infradead.org/users/willy/linux-dax.git/shortlog/refs/heads/xarray-20180413
> 
> aka
>  	git://git.infradead.org/users/willy/linux-dax.git xarray-20180413


Thanks.

I found the erroneous commit is
e14a33134244 mm: Convert workingset to XArray

mapping->nrexceptional is becoming negative.

An easy way to reproduce is to perform a large enough I/O to force it to
 swap out and inodes are evicted.

-- 
Goldwyn
