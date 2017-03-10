Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id D8CB96B038F
	for <linux-mm@kvack.org>; Fri, 10 Mar 2017 16:54:28 -0500 (EST)
Received: by mail-lf0-f72.google.com with SMTP id n62so31429653lfn.7
        for <linux-mm@kvack.org>; Fri, 10 Mar 2017 13:54:28 -0800 (PST)
Received: from mail.ispras.ru (mail.ispras.ru. [83.149.199.45])
        by mx.google.com with ESMTP id r41si2285411lfi.193.2017.03.10.13.54.26
        for <linux-mm@kvack.org>;
        Fri, 10 Mar 2017 13:54:27 -0800 (PST)
Subject: Re: z3fold: suspicious return with spinlock held
References: <1489180932-13918-1-git-send-email-khoroshilov@ispras.ru>
 <20170310213419.GD16328@bombadil.infradead.org>
From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Message-ID: <82e268d4-22fa-3e33-8988-a3a367fae7b1@ispras.ru>
Date: Sat, 11 Mar 2017 00:54:26 +0300
MIME-Version: 1.0
In-Reply-To: <20170310213419.GD16328@bombadil.infradead.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Vitaly Wool <vitalywool@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Streetman <ddstreet@ieee.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org

On 11.03.2017 00:34, Matthew Wilcox wrote:
> On Sat, Mar 11, 2017 at 12:22:12AM +0300, Alexey Khoroshilov wrote:
>> Hello!
>>
>> z3fold_reclaim_page() contains the only return that may
>> leave the function with pool->lock spinlock held.
>>
>> 669 	spin_lock(&pool->lock);
>> 670 	if (kref_put(&zhdr->refcount, release_z3fold_page)) {
>> 671 		atomic64_dec(&pool->pages_nr);
>> 672 		return 0;
>> 673 	}
>>
>> May be we need spin_unlock(&pool->lock); just before return?
> 
> I would tend to agree.  sparse warns about this, and also about two
> other locking problems ... which I'm not sure are really problems so
> much as missing annotations?
> 
> mm/z3fold.c:467:35: warning: context imbalance in 'z3fold_alloc' - unexpected unlock
> mm/z3fold.c:519:26: warning: context imbalance in 'z3fold_free' - different lock contexts for basic block
> mm/z3fold.c:581:12: warning: context imbalance in 'z3fold_reclaim_page' - different lock contexts for basic block
> 

I also do not see problems in z3fold_alloc() and z3fold_free().
But I am unaware of sparse annotations that can help here.

--
Alexey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
