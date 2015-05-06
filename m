Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f53.google.com (mail-yh0-f53.google.com [209.85.213.53])
	by kanga.kvack.org (Postfix) with ESMTP id 84B136B0032
	for <linux-mm@kvack.org>; Wed,  6 May 2015 16:41:05 -0400 (EDT)
Received: by yhda23 with SMTP id a23so5680546yhd.2
        for <linux-mm@kvack.org>; Wed, 06 May 2015 13:41:05 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id h63si10236749yhq.76.2015.05.06.13.41.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 May 2015 13:41:04 -0700 (PDT)
Date: Wed, 6 May 2015 13:41:02 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [net-next PATCH 1/6] net: Add skb_free_frag to replace use of
 put_page in freeing skb->head
Message-Id: <20150506134102.b01faad32e07ff3d308e1a09@linux-foundation.org>
In-Reply-To: <554A793F.3070001@redhat.com>
References: <20150504231000.1538.70520.stgit@ahduyck-vm-fedora22>
	<20150504231448.1538.84164.stgit@ahduyck-vm-fedora22>
	<20150506123840.312f41000e8d46f1ef9ce046@linux-foundation.org>
	<554A793F.3070001@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Cc: linux-mm@kvack.org, netdev@vger.kernel.org, davem@davemloft.net, Eric Dumazet <eric.dumazet@gmail.com>

On Wed, 06 May 2015 13:27:43 -0700 Alexander Duyck <alexander.h.duyck@redhat.com> wrote:

> >> +void skb_free_frag(void *head)
> >> +{
> >> +	struct page *page = virt_to_head_page(head);
> >> +
> >> +	if (unlikely(put_page_testzero(page))) {
> >> +		if (likely(PageHead(page)))
> >> +			__free_pages_ok(page, compound_order(page));
> >> +		else
> >> +			free_hot_cold_page(page, false);
> >> +	}
> >> +}
> > Why are we testing for PageHead in here?  If the code were to simply do
> >
> > 	if (unlikely(put_page_testzero(page)))
> > 		__free_pages_ok(page, compound_order(page));
> >
> > that would still work?
> 
> My assumption was that there was a performance difference between 
> __free_pages_ok and free_hot_cold_page for order 0 pages.  From what I 
> can tell free_hot_cold_page will do bulk cleanup via free_pcppages_bulk 
> while __free_pages_ok just calls free_one_page.

Could be.  Plus there's hopefully some performance advantage if the
page is genuinely cache-hot.  I don't think that anyone has verified
the benefits of the hot/cold optimisation in the last decade or two,
and it was always pretty marginal..

Is the PageHead thing really "likely"?  We're usually dealing with
order>0 pages here?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
