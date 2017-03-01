Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 55F716B0389
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 19:39:49 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 6so31621060pfd.6
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 16:39:49 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id o1si3099573pld.248.2017.02.28.16.39.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Feb 2017 16:39:48 -0800 (PST)
Date: Tue, 28 Feb 2017 16:39:47 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/5] mm: support parallel free of memory
Message-Id: <20170228163947.cbd83e48dcb149c697b316cd@linux-foundation.org>
In-Reply-To: <20170224114036.15621-1-aaron.lu@intel.com>
References: <20170224114036.15621-1-aaron.lu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@intel.com>, Tim Chen <tim.c.chen@intel.com>, Ying Huang <ying.huang@intel.com>

On Fri, 24 Feb 2017 19:40:31 +0800 Aaron Lu <aaron.lu@intel.com> wrote:

> For regular processes, the time taken in its exit() path to free its
> used memory is not a problem. But there are heavy ones that consume
> several Terabytes memory and the time taken to free its memory could
> last more than ten minutes.
> 
> To optimize this use case, a parallel free method is proposed here.
> For detailed explanation, please refer to patch 2/5.
> 
> I'm not sure if we need patch 4/5 which can avoid page accumulation
> being interrupted in some case(patch description has more information).
> My test case, which only deal with anon memory doesn't get any help out
> of this of course. It can be safely dropped if it is deemed not useful.
> 
> A test program that did a single malloc() of 320G memory is used to see
> how useful the proposed parallel free solution is, the time calculated
> is for the free() call. Test machine is a Haswell EX which has
> 4nodes/72cores/144threads with 512G memory. All tests are done with THP
> disabled.
> 
> kernel                             time
> v4.10                              10.8s  __2.8%
> this patch(with default setting)   5.795s __5.8%

Dumb question: why not do this in userspace, presumably as part of the
malloc() library?  malloc knows where all the memory is and should be
able to kick off N threads to run around munmapping everything?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
