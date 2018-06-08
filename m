Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3FBD36B0003
	for <linux-mm@kvack.org>; Fri,  8 Jun 2018 15:57:23 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id g6-v6so7890109plq.9
        for <linux-mm@kvack.org>; Fri, 08 Jun 2018 12:57:23 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d1-v6si17108484pgo.337.2018.06.08.12.57.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jun 2018 12:57:18 -0700 (PDT)
Date: Fri, 8 Jun 2018 12:57:17 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/madvise: allow MADV_DONTNEED to free memory that is
 MLOCK_ONFAULT
Message-Id: <20180608125717.c34d3e7125c62fc91ac427c8@linux-foundation.org>
In-Reply-To: <1528484212-7199-1-git-send-email-jbaron@akamai.com>
References: <1528484212-7199-1-git-send-email-jbaron@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Baron <jbaron@akamai.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Fri,  8 Jun 2018 14:56:52 -0400 Jason Baron <jbaron@akamai.com> wrote:

> In order to free memory that is marked MLOCK_ONFAULT, the memory region
> needs to be first unlocked, before calling MADV_DONTNEED. And if the region
> is to be reused as MLOCK_ONFAULT, we require another call to mlock2() with
> the MLOCK_ONFAULT flag.
> 
> Let's simplify freeing memory that is set MLOCK_ONFAULT, by allowing
> MADV_DONTNEED to work directly for memory that is set MLOCK_ONFAULT. The
> locked memory limits, tracked by mm->locked_vm do not need to be adjusted
> in this case, since they were charged to the entire region when
> MLOCK_ONFAULT was initially set.

Seems useful.

Is a manpage update planned?

Various updates to tools/testing/selftests/vm/* seem appropriate.

> Further, I don't think allowing MADV_FREE for MLOCK_ONFAULT regions makes
> sense, since the point of MLOCK_ONFAULT is for userspace to know when pages
> are locked in memory and thus to know when page faults will occur.

This sounds non-backward-compatible?
