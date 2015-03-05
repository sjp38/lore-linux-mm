Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 58EB86B0038
	for <linux-mm@kvack.org>; Thu,  5 Mar 2015 05:47:35 -0500 (EST)
Received: by wibhm9 with SMTP id hm9so14190911wib.2
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 02:47:34 -0800 (PST)
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com. [209.85.212.178])
        by mx.google.com with ESMTPS id i9si32136504wix.79.2015.03.05.02.47.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Mar 2015 02:47:33 -0800 (PST)
Received: by wibbs8 with SMTP id bs8so6017355wib.0
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 02:47:33 -0800 (PST)
Message-ID: <54F83442.2060101@plexistor.com>
Date: Thu, 05 Mar 2015 12:47:30 +0200
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3 v2] dax: use pfn_mkwrite to update c/mtime + freeze
 protection
References: <54F733BD.7060807@plexistor.com> <54F73746.5020300@plexistor.com> <20150304171935.GA5443@quack.suse.cz> <54F820E2.9060109@plexistor.com> <54F822A9.7090707@plexistor.com> <20150305103529.GA2836@quack.suse.cz>
In-Reply-To: <20150305103529.GA2836@quack.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Dave Chinner <david@fromorbit.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-nvdimm <linux-nvdimm@ml01.01.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On 03/05/2015 12:35 PM, Jan Kara wrote:
> On Thu 05-03-15 11:32:25, Boaz Harrosh wrote:
>> On 03/05/2015 11:24 AM, Boaz Harrosh wrote:
<>
>>
>> Just as curiosity, does the freezing code goes and turns all mappings
>> into read-only, Also for pfn mapping?
>   Hum, that's a good question. Probably we don't end up doing that. For
>
> normal filesystems we sync all inodes which also writeprotects all pages
> (in clear_page_dirty_for_io() - for normal filesystems we know that if page
> is writeably mapped it is dirty). However this won't happen for pfn
> mapping as we don't have dirty pages. So we probably need dax_freeze()
> implementation that will walk through all inodes with writeable mappings and
> writeprotect them.
> 

I'll go head and try my shot on implementing a dax_freeze(). But I will
please need help with where to call it from.

Probably something like:
	if (IS_DAX(inode))
		dax_freeze(inode);
	else
		sync(inode)

So to share the for-all-inodes-in-sb loop. And also the IS_DAX(inode)
is per inode, for example dirs need the regular sync (if they are using page cache)

>> Do you think there is already an xfstest freezing test that should now
>> fail, and will succeed after this patch (v2). Something like:
>>   * mmap-read/write before the freeze
>>   * freeze the fs
>>   * Another thread tries to mmap-write, should get stuck
>>   * unfreeze the fs
>>   * Now mmap-writer continues
>   I don't remember there would be any test to specifically test this.
> 

OK Thanks, I was hopping we should already test for mmap vs freeze. This
is not special for our case. Actually mmap is the most fragile access.

> 								Honza
> 

Thanks
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
