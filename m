Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 089B56B0009
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 13:44:03 -0500 (EST)
Received: by mail-pf0-f180.google.com with SMTP id x65so33560493pfb.1
        for <linux-mm@kvack.org>; Thu, 11 Feb 2016 10:44:03 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id sp7si14022221pac.230.2016.02.11.10.44.02
        for <linux-mm@kvack.org>;
        Thu, 11 Feb 2016 10:44:02 -0800 (PST)
Date: Thu, 11 Feb 2016 11:43:50 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: DAX: __dax_fault race question
Message-ID: <20160211184350.GA27848@linux.intel.com>
References: <87bn7rwim2.fsf@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87bn7rwim2.fsf@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Monakhov <dmonakhov@openvz.org>
Cc: Linux Memory Management <linux-mm@kvack.org>, willy@linux.intel.com, ross.zwisler@linux.intel.com

On Mon, Feb 08, 2016 at 02:23:49PM +0300, Dmitry Monakhov wrote:
> 
> Hi,
> 
> I try to understand locking rules for dax and realized that there is
> some suspicious case in dax_fault
> 
> On __dax_fault we try to replace normal page with dax-entry
> Basically dax_fault steps looks like follows
> 
> 1) page = find_get_page(..)
> 2) lock_page_or_retry(page)
> 3) get_block
> 4) delete_from_page_cache(page)
> 5) unlock_page(page)
> 6) dax_insert_mapping(inode, &bh, vma, vmf)
> ...
> 
> But what protects us from other taks does new page_fault after (4) but
> before (6).
> AFAIU this case is not prohibited
> Let's see what happens for two read/write tasks does fault inside file-hole
> task_1(writer)                  task_2(reader)
> __dax_fault(write)
>   ->lock_page_or_retry
>   ->delete_from_page_cache()    __dax_fault(read)
>                                 ->dax_load_hole
>                                   ->find_or_create_page()
>                                     ->new page in mapping->radix_tree               
>   ->dax_insert_mapping
>      ->dax_radix_entry->collision: return -EIO
> 
> Before dax/fsync patch-set this race result in silent dax/page duality(which
> likely result data incoherence or data corruption), Luckily now this
> race result in collision on insertion to radix_tree and return -EIO.
> From first glance testcase looks very simple, but I can not reproduce
> this in my environment. 
> 
> Imho it is reasonable pass locked page to dax_insert_mapping and let
> dax_radix_entry use atomic page/dax-entry replacement similar to
> replace_page_cache_page. Am I right?

We are trying to come up with a general locking scheme that will solve this
race as well as others.

https://lkml.org/lkml/2016/2/9/607

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
