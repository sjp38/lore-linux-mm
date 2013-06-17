Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 42FFB6B0031
	for <linux-mm@kvack.org>; Mon, 17 Jun 2013 17:37:05 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id kq13so3249071pab.25
        for <linux-mm@kvack.org>; Mon, 17 Jun 2013 14:37:04 -0700 (PDT)
Date: Mon, 17 Jun 2013 14:37:02 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: Add unlikely for current_order test
In-Reply-To: <51BE6BFC.3030009@cn.fujitsu.com>
Message-ID: <alpine.DEB.2.02.1306171431470.20631@chino.kir.corp.google.com>
References: <51BC4A83.50302@gmail.com> <alpine.DEB.2.02.1306161103020.22688@chino.kir.corp.google.com> <51BE6BFC.3030009@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Cc: Zhang Yanfei <zhangyanfei.yes@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon, 17 Jun 2013, Zhang Yanfei wrote:

> > I don't understand the justification at all, current_order being unlikely 
> > greater than or equal to pageblock_order / 2 doesn't imply at all that 
> > it's unlikely that current_order is greater than or equal to 
> > pageblock_order.
> > 
> 
> hmmm... I am confused. Since current_order is >= pageblock_order / 2 is unlikely,
> why current_order is >= pageblock_order isn't unlikely. Or there are other
> tips?
> 
> Actually, I am also a little confused about why current_order should be
> unlikely greater than or equal to pageblock_order / 2. When borrowing pages
> with other migrate_type, we always search from MAX_ORDER-1, which is greater
> or equal to pageblock_order.
> 

Look at what is being done in the function: current_order loops down from 
MAX_ORDER-1 to the order passed.  It is not at all "unlikely" that 
current_order is greater than pageblock_order, or pageblock_order / 2.

MAX_ORDER is typically 11 and pageblock_order is typically 9 on x86.  
Integer division truncates, so pageblock_order / 2 is 4.  For the first 
eight iterations, it's guaranteed that current_order >= pageblock_order / 
2 if it even gets that far!

So just remove the unlikely() entirely, it's completely bogus.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
