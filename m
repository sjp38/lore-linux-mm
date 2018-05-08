Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 160346B028B
	for <linux-mm@kvack.org>; Tue,  8 May 2018 10:45:32 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id b10-v6so24373314qto.5
        for <linux-mm@kvack.org>; Tue, 08 May 2018 07:45:32 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id n12-v6si3171774qtb.361.2018.05.08.07.45.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 May 2018 07:45:31 -0700 (PDT)
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w48EgkZI136222
	for <linux-mm@kvack.org>; Tue, 8 May 2018 14:45:30 GMT
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by userp2120.oracle.com with ESMTP id 2hs5938x4n-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Tue, 08 May 2018 14:45:30 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w48EjTle001149
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Tue, 8 May 2018 14:45:29 GMT
Received: from abhmp0019.oracle.com (abhmp0019.oracle.com [141.146.116.25])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w48EjT5h023601
	for <linux-mm@kvack.org>; Tue, 8 May 2018 14:45:29 GMT
Received: by mail-ot0-f180.google.com with SMTP id l22-v6so36373858otj.0
        for <linux-mm@kvack.org>; Tue, 08 May 2018 07:45:29 -0700 (PDT)
MIME-Version: 1.0
References: <20180426202619.2768-1-pasha.tatashin@oracle.com> <20180430162658.598dd5dcdd0c67e36953281c@linux-foundation.org>
In-Reply-To: <20180430162658.598dd5dcdd0c67e36953281c@linux-foundation.org>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Tue, 08 May 2018 14:44:51 +0000
Message-ID: <CAGM2reauOET_PUPA94WXhjKgL1cUHcKyY+R+auxvTfd4srhaFw@mail.gmail.com>
Subject: Re: [PATCH v2] mm: access to uninitialized struct page
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, LKML <linux-kernel@vger.kernel.org>, tglx@linutronix.de, Michal Hocko <mhocko@suse.com>, Linux Memory Management List <linux-mm@kvack.org>, mgorman@techsingularity.net, mingo@kernel.org, peterz@infradead.org, Steven Rostedt <rostedt@goodmis.org>, Fengguang Wu <fengguang.wu@intel.com>, Dennis Zhou <dennisszhou@gmail.com>

> Gulp.  Let's hope that nothing in mm_init() requires that trap_init()
> has been run.  What happens if something goes wrong during mm_init()
> and the architecture attempts to raise a software exception, hits a bus
> error, div-by-zero, etc, etc?  Might there be hard-to-discover
> dependencies in such a case?

Hi Andrew,

Unfortunately, mm_init() requires trap_init(). And, because trap_init() is
arch specific, I do not see a way to simply fix  trap_init(). So, we need
to find a different fix for the above problem. And, the current fix needs
to be removed from mm.

BTW, the bug was not introduced by:
c9e97a1997fb ("mm: initialize pages on demand during boot")

Fengguang Wu, reproduced this bug with builds prior to when this patch was
added. So, I think that while my patch may make this problem happen more
frequently, the problem itself is older. Basically, it depends on value of
KASLR.

One way to quickly fix this issue is to disable deferred struct pages when
the following combination is true:
CONFIG_RANDOMIZE_BASE && CONFIG_SPARSEMEM && !CONFIG_SPARSEMEM_VMEMMAP

RANDOMIZE_BASE means we do not know from what PFN struct pages are going to
be required before mm_init().
CONFIG_SPARSEMEM && !CONFIG_SPARSEMEM_VMEMMAP means that page_to_pfn() will
use information from page->flags to get section number, and thus require
accessing "struct pages"

Pavel
