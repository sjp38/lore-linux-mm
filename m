Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id F176B6B0038
	for <linux-mm@kvack.org>; Tue,  2 May 2017 19:43:51 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id i25so4587807pfa.23
        for <linux-mm@kvack.org>; Tue, 02 May 2017 16:43:51 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id 23si804947pfb.370.2017.05.02.16.43.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 May 2017 16:43:51 -0700 (PDT)
Subject: Re: [PATCH RFC] hugetlbfs 'noautofill' mount option
References: <326e38dd-b4a8-e0ca-6ff7-af60e8045c74@oracle.com>
 <b0efc671-0d7a-0aef-5646-a635478c31b0@oracle.com>
 <7ff6fb32-7d16-af4f-d9d5-698ab7e9e14b@intel.com>
 <03127895-3c5a-5182-82de-3baa3116749e@oracle.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <22557bf3-14bb-de02-7b1b-a79873c583f1@intel.com>
Date: Tue, 2 May 2017 16:43:50 -0700
MIME-Version: 1.0
In-Reply-To: <03127895-3c5a-5182-82de-3baa3116749e@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Prakash Sangappa <prakash.sangappa@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 05/02/2017 04:34 PM, Prakash Sangappa wrote:
> Similarly, a madvise() option also requires additional system call by every
> process mapping the file, this is considered a overhead for the database.

How long-lived are these processes?  For a database, I'd assume that
this would happen a single time, or a single time per mmap() at process
startup time.  Such a syscall would be doing something on the order of
taking mmap_sem, walking the VMA tree, setting a bit per VMA, and
unlocking.  That's a pretty cheap one-time cost...

> If we do consider a new madvise() option, will it be acceptable
> since this will be specifically for hugetlbfs file mappings?

Ideally, it would be something that is *not* specifically for hugetlbfs.
 MADV_NOAUTOFILL, for instance, could be defined to SIGSEGV whenever
memory is touched that was not populated with MADV_WILLNEED, mlock(), etc...

> If so,
> would a new flag to mmap() call itself be acceptable, which would
> define the proposed behavior?. That way no additional system calls
> need to be made.

I don't feel super strongly about it, but I guess an mmap() flag could
work too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
