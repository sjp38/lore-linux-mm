Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 647236B005A
	for <linux-mm@kvack.org>; Wed,  7 May 2014 17:21:13 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id hz1so1674349pad.16
        for <linux-mm@kvack.org>; Wed, 07 May 2014 14:21:13 -0700 (PDT)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id vw5si14424255pab.251.2014.05.07.14.21.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 07 May 2014 14:21:12 -0700 (PDT)
Received: by mail-pa0-f45.google.com with SMTP id ey11so1720710pad.4
        for <linux-mm@kvack.org>; Wed, 07 May 2014 14:21:12 -0700 (PDT)
Date: Wed, 7 May 2014 14:21:10 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v3 2/6] mm, compaction: return failed migration target
 pages back to freelist
In-Reply-To: <20140507141534.d4def933b3a9999e7826df5c@linux-foundation.org>
Message-ID: <alpine.DEB.2.02.1405071420110.8454@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1404301744110.8415@chino.kir.corp.google.com> <alpine.DEB.2.02.1405011434140.23898@chino.kir.corp.google.com> <alpine.DEB.2.02.1405061920470.18635@chino.kir.corp.google.com> <alpine.DEB.2.02.1405061921040.18635@chino.kir.corp.google.com>
 <20140507141534.d4def933b3a9999e7826df5c@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 7 May 2014, Andrew Morton wrote:

> > Memory compaction works by having a "freeing scanner" scan from one end of a 
> > zone which isolates pages as migration targets while another "migrating scanner" 
> > scans from the other end of the same zone which isolates pages for migration.
> > 
> > When page migration fails for an isolated page, the target page is returned to 
> > the system rather than the freelist built by the freeing scanner.  This may 
> > require the freeing scanner to continue scanning memory after suitable migration 
> > targets have already been returned to the system needlessly.
> > 
> > This patch returns destination pages to the freeing scanner freelist when page 
> > migration fails.  This prevents unnecessary work done by the freeing scanner but 
> > also encourages memory to be as compacted as possible at the end of the zone.
> > 
> > Reported-by: Greg Thelen <gthelen@google.com>
> 
> What did Greg actually report?  IOW, what if any observable problem is
> being fixed here?
> 

Greg reported by code inspection that he found isolated free pages were 
returned back to the VM rather than the compaction freelist.  This will 
cause holes behind the free scanner and cause it to reallocate additional 
memory if necessary later.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
