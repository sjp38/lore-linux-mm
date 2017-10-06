Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7A4D46B0253
	for <linux-mm@kvack.org>; Fri,  6 Oct 2017 03:52:18 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id j14so8290946wre.4
        for <linux-mm@kvack.org>; Fri, 06 Oct 2017 00:52:18 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b105si786486wrd.480.2017.10.06.00.52.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 06 Oct 2017 00:52:17 -0700 (PDT)
Date: Fri, 6 Oct 2017 09:52:16 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] kvm, mm: account kvm related kmem slabs to kmemcg
Message-ID: <20171006075216.vuulcnckksp7culq@dhcp22.suse.cz>
References: <20171006010724.186563-1-shakeelb@google.com>
 <a6707959-fe38-0bf6-5281-1c60ba63bc8c@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a6707959-fe38-0bf6-5281-1c60ba63bc8c@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Shakeel Butt <shakeelb@google.com>, Paolo Bonzini <pbonzini@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, x86@kernel.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri 06-10-17 09:58:30, Anshuman Khandual wrote:
> On 10/06/2017 06:37 AM, Shakeel Butt wrote:
> > The kvm slabs can consume a significant amount of system memory
> > and indeed in our production environment we have observed that
> > a lot of machines are spending significant amount of memory that
> > can not be left as system memory overhead. Also the allocations
> > from these slabs can be triggered directly by user space applications
> > which has access to kvm and thus a buggy application can leak
> > such memory. So, these caches should be accounted to kmemcg.
> 
> But there may be other situations like this where user space can
> trigger allocation from various SLAB objects inside the kernel
> which are accounted as system memory. So how we draw the line
> which ones should be accounted for memcg. Just being curious.

The thing is that we used to have an opt-out approach for kmem
accounting but we decided to go opt-in in a9bb7e620efd ("memcg: only
account kmem allocations marked as __GFP_ACCOUNT").

Since then we are adding the flag to caches/allocations which can go
wild and consume a lot of or even unbounded amount of memory.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
