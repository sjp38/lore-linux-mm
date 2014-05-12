Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f46.google.com (mail-ee0-f46.google.com [74.125.83.46])
	by kanga.kvack.org (Postfix) with ESMTP id E13156B0035
	for <linux-mm@kvack.org>; Mon, 12 May 2014 04:35:47 -0400 (EDT)
Received: by mail-ee0-f46.google.com with SMTP id t10so4344297eei.33
        for <linux-mm@kvack.org>; Mon, 12 May 2014 01:35:47 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i47si2795186eev.321.2014.05.12.01.35.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 12 May 2014 01:35:46 -0700 (PDT)
Message-ID: <537087E1.6070703@suse.cz>
Date: Mon, 12 May 2014 10:35:45 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [patch v3 2/6] mm, compaction: return failed migration target
 pages back to freelist
References: <alpine.DEB.2.02.1404301744110.8415@chino.kir.corp.google.com> <alpine.DEB.2.02.1405011434140.23898@chino.kir.corp.google.com> <alpine.DEB.2.02.1405061920470.18635@chino.kir.corp.google.com> <alpine.DEB.2.02.1405061921040.18635@chino.kir.corp.google.com> <20140507141534.d4def933b3a9999e7826df5c@linux-foundation.org> <alpine.DEB.2.02.1405071420110.8454@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1405071420110.8454@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 05/07/2014 11:21 PM, David Rientjes wrote:
> On Wed, 7 May 2014, Andrew Morton wrote:
>
>>> Memory compaction works by having a "freeing scanner" scan from one end of a
>>> zone which isolates pages as migration targets while another "migrating scanner"
>>> scans from the other end of the same zone which isolates pages for migration.
>>>
>>> When page migration fails for an isolated page, the target page is returned to
>>> the system rather than the freelist built by the freeing scanner.  This may
>>> require the freeing scanner to continue scanning memory after suitable migration
>>> targets have already been returned to the system needlessly.
>>>
>>> This patch returns destination pages to the freeing scanner freelist when page
>>> migration fails.  This prevents unnecessary work done by the freeing scanner but
>>> also encourages memory to be as compacted as possible at the end of the zone.
>>>
>>> Reported-by: Greg Thelen <gthelen@google.com>
>>
>> What did Greg actually report?  IOW, what if any observable problem is
>> being fixed here?
>>
>
> Greg reported by code inspection that he found isolated free pages were
> returned back to the VM rather than the compaction freelist.  This will
> cause holes behind the free scanner and cause it to reallocate additional
> memory if necessary later.

More precisely, there shouldn't be holes as the free scanner restarts at 
highest pageblock where it isolated something, exactly to avoid making 
holes due to returned pages. But that can be now avoided, as my patch does.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
