Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 572F76B051F
	for <linux-mm@kvack.org>; Tue,  1 Aug 2017 07:05:24 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id t37so5868468qtg.6
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 04:05:24 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u62si5395700qkl.518.2017.08.01.04.05.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Aug 2017 04:05:23 -0700 (PDT)
Message-ID: <1501585521.4073.80.camel@redhat.com>
Subject: Re: [PATCH v5 2/3] mm: migrate: fix barriers around
 tlb_flush_pending
From: Rik van Riel <riel@redhat.com>
Date: Tue, 01 Aug 2017 07:05:21 -0400
In-Reply-To: <20170731164325.235019-3-namit@vmware.com>
References: <20170731164325.235019-1-namit@vmware.com>
	 <20170731164325.235019-3-namit@vmware.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <namit@vmware.com>, linux-mm@kvack.org
Cc: nadav.amit@gmail.com, mgorman@suse.de, luto@kernel.org, Minchan Kim <minchan@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Mon, 2017-07-31 at 09:43 -0700, Nadav Amit wrote:
> Reading tlb_flush_pending while the page-table lock is taken does not
> require a barrier, since the lock/unlock already acts as a barrier.
> Removing the barrier in mm_tlb_flush_pending() to address this issue.
> 
> However, migrate_misplaced_transhuge_page() calls
> mm_tlb_flush_pending()
> while the page-table lock is already released, which may present a
> problem on architectures with weak memory model (PPC). To deal with
> this
> case, a new parameter is added to mm_tlb_flush_pending() to indicate
> if it is read without the page-table lock taken, and calling
> smp_mb__after_unlock_lock() in this case.
> 
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> Cc: Andy Lutomirski <luto@kernel.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Rik van Riel <riel@redhat.com>
> 
> Signed-off-by: Nadav Amit <namit@vmware.com>
> 
Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
