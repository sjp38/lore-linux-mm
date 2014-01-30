Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f44.google.com (mail-oa0-f44.google.com [209.85.219.44])
	by kanga.kvack.org (Postfix) with ESMTP id 92D416B0035
	for <linux-mm@kvack.org>; Thu, 30 Jan 2014 12:15:34 -0500 (EST)
Received: by mail-oa0-f44.google.com with SMTP id g12so3973256oah.3
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 09:15:34 -0800 (PST)
Received: from g5t0006.atlanta.hp.com (g5t0006.atlanta.hp.com. [15.192.0.43])
        by mx.google.com with ESMTPS id co8si3274048oec.47.2014.01.30.09.15.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 30 Jan 2014 09:15:33 -0800 (PST)
Message-ID: <1391102130.2931.14.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH] mm, hugetlb: gimme back my page
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Thu, 30 Jan 2014 09:15:30 -0800
In-Reply-To: <20140130095907.GA13574@dhcp22.suse.cz>
References: <1391063823.2931.3.camel@buesod1.americas.hpqcorp.net>
	 <20140130095907.GA13574@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Jonathan Gonzalez <jgonzalez@linets.cl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 2014-01-30 at 10:59 +0100, Michal Hocko wrote:
> On Wed 29-01-14 22:37:03, Davidlohr Bueso wrote:
> > From: Davidlohr Bueso <davidlohr@hp.com>
> > 
> > While testing some changes, I noticed an issue triggered by the libhugetlbfs
> > test-suite. This is caused by commit 309381fe (mm: dump page when hitting a
> > VM_BUG_ON using VM_BUG_ON_PAGE), where an application can unexpectedly OOM due
> > to another program that using, or reserving, pool_size-1 pages later triggers
> > a VM_BUG_ON_PAGE and thus greedly leaves no memory to the rest of the hugetlb
> > aware tasks. For example, in libhugetlbfs 2.14:
> > 
> > mmap-gettest 10 32783 (2M: 64): <---- hit VM_BUG_ON_PAGE
> > mmap-cow 32782 32783 (2M: 32):  FAIL    Failed to create shared mapping: Cannot allocate memory
> > mmap-cow 32782 32783 (2M: 64):  FAIL    Failed to create shared mapping: Cannot allocate memory
> > 
> > While I have not looked into why 'mmap-gettest' keeps failing, it is of no
> > importance to this particular issue. This problem is similar to why we have
> > the hugetlb_instantiation_mutex, hugepages are quite finite.
> > 
> > Revert the use of VM_BUG_ON_PAGE back to just VM_BUG_ON.
> 
> I do not understand what VM_BUG_ON_PAGE has to do with the above
> failure. Could you be more specific.
> 
> Hmm, now that I am looking into dump_page_badflags it shouldn't call
> mem_cgroup_print_bad_page for hugetlb pages because it doesn't make any
> sense. I will post a patch for that but that still doesn't explain the
> above changelog.

Yeah, I then looked closer at it and realized it doesn't make much
sense. I don't know why I thought a new page was being used. In any
case, bisection still shows the commit in question as the cause of the
regression. I will continue looking into it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
