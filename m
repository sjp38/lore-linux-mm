Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id F37B46B0003
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 07:53:40 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id g5-v6so1278294pgv.12
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 04:53:40 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m37-v6si19561476pla.148.2018.07.11.04.53.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jul 2018 04:53:39 -0700 (PDT)
Date: Wed, 11 Jul 2018 13:53:32 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC v4 0/3] mm: zap pages with read mmap_sem in munmap for
 large mapping
Message-ID: <20180711115332.GM20050@dhcp22.suse.cz>
References: <1531265649-93433-1-git-send-email-yang.shi@linux.alibaba.com>
 <20180711103312.GH20050@dhcp22.suse.cz>
 <20180711111311.hrh5kxdottmpdpn2@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180711111311.hrh5kxdottmpdpn2@kshutemo-mobl1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, willy@infradead.org, ldufour@linux.vnet.ibm.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 11-07-18 14:13:12, Kirill A. Shutemov wrote:
> On Wed, Jul 11, 2018 at 12:33:12PM +0200, Michal Hocko wrote:
> > this is not a small change for something that could be achieved
> > from the userspace trivially (just call madvise before munmap - library
> > can hide this). Most workloads will even not care about races because
> > they simply do not play tricks with mmaps and userspace MM. So why do we
> > want to put the additional complexity into the kernel?
> 
> As I said before, kernel latency issues have to be addressed in kernel.
> We cannot rely on userspace being kind here.

Those who really care and create really large mappings will know how to
do this properly. Most others just do not care enough. So I am not
really sure this alone is a sufficient argument.

I personally like the in kernel auto tuning but as I've said the
changelog should be really clear why all the complications are
justified. This would be a lot easier to argue about if it was a simple
	if (len > THARSHOLD)
		do_madvise(DONTNEED)
	munmap().
approach. But if we really have to care about parallel faults and munmap
consitency this will always be tricky
-- 
Michal Hocko
SUSE Labs
