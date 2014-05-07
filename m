Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id C52436B0073
	for <linux-mm@kvack.org>; Wed,  7 May 2014 17:39:26 -0400 (EDT)
Received: by mail-ig0-f178.google.com with SMTP id hl10so1697616igb.5
        for <linux-mm@kvack.org>; Wed, 07 May 2014 14:39:26 -0700 (PDT)
Received: from mail-ie0-x249.google.com (mail-ie0-x249.google.com [2607:f8b0:4001:c03::249])
        by mx.google.com with ESMTPS id nx5si14360177icb.206.2014.05.07.14.39.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 07 May 2014 14:39:26 -0700 (PDT)
Received: by mail-ie0-f201.google.com with SMTP id rd18so358766iec.4
        for <linux-mm@kvack.org>; Wed, 07 May 2014 14:39:26 -0700 (PDT)
References: <alpine.DEB.2.02.1404301744110.8415@chino.kir.corp.google.com> <alpine.DEB.2.02.1405011434140.23898@chino.kir.corp.google.com> <alpine.DEB.2.02.1405061920470.18635@chino.kir.corp.google.com> <alpine.DEB.2.02.1405061921040.18635@chino.kir.corp.google.com> <20140507141534.d4def933b3a9999e7826df5c@linux-foundation.org>
From: Greg Thelen <gthelen@google.com>
Subject: Re: [patch v3 2/6] mm, compaction: return failed migration target pages back to freelist
In-reply-to: <20140507141534.d4def933b3a9999e7826df5c@linux-foundation.org>
Date: Wed, 07 May 2014 14:39:24 -0700
Message-ID: <xr93ha512rqr.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org


On Wed, May 07 2014, Andrew Morton <akpm@linux-foundation.org> wrote:

> On Tue, 6 May 2014 19:22:43 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:
>
>> Memory compaction works by having a "freeing scanner" scan from one end of a 
>> zone which isolates pages as migration targets while another "migrating scanner" 
>> scans from the other end of the same zone which isolates pages for migration.
>> 
>> When page migration fails for an isolated page, the target page is returned to 
>> the system rather than the freelist built by the freeing scanner.  This may 
>> require the freeing scanner to continue scanning memory after suitable migration 
>> targets have already been returned to the system needlessly.
>> 
>> This patch returns destination pages to the freeing scanner freelist when page 
>> migration fails.  This prevents unnecessary work done by the freeing scanner but 
>> also encourages memory to be as compacted as possible at the end of the zone.
>> 
>> Reported-by: Greg Thelen <gthelen@google.com>
>
> What did Greg actually report?  IOW, what if any observable problem is
> being fixed here?

I detected the problem at runtime seeing that ext4 metadata pages (esp
the ones read by "sbi->s_group_desc[i] = sb_bread(sb, block)") were
constantly visited by compaction calls of migrate_pages().  These pages
had a non-zero b_count which caused fallback_migrate_page() ->
try_to_release_page() -> try_to_free_buffers() to fail.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
