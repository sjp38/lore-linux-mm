Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id A82FC6B006E
	for <linux-mm@kvack.org>; Tue,  5 May 2015 19:28:54 -0400 (EDT)
Received: by pdbqd1 with SMTP id qd1so212266767pdb.2
        for <linux-mm@kvack.org>; Tue, 05 May 2015 16:28:54 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id qk1si26507445pbb.80.2015.05.05.16.28.53
        for <linux-mm@kvack.org>;
        Tue, 05 May 2015 16:28:53 -0700 (PDT)
Date: Tue, 05 May 2015 19:28:51 -0400 (EDT)
Message-Id: <20150505.192851.1294286421369630011.davem@davemloft.net>
Subject: Re: [net-next PATCH 0/6] Add skb_free_frag to replace
 put_page(virt_to_head_page(ptr))
From: David Miller <davem@davemloft.net>
In-Reply-To: <20150504231000.1538.70520.stgit@ahduyck-vm-fedora22>
References: <20150504231000.1538.70520.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: alexander.h.duyck@redhat.com
Cc: linux-mm@kvack.org, netdev@vger.kernel.org, akpm@linux-foundation.org

From: Alexander Duyck <alexander.h.duyck@redhat.com>
Date: Mon, 04 May 2015 16:14:42 -0700

> This patch set cleans up some of the handling of page frags used in the skb
> allocation.  The issue was we were having to use a number of calls to
> virt_to_head_page in a number of places and then following that up with
> put_page.  Both calls end up being expensive, the first due to size, and
> the second due to the fact that we end up having to call a number of other
> functions before we finally see the page freed in the case of compound
> pages.
> 
> The skb_free_frag function is meant to resolve that by providing a
> centralized location for the virt_to_head_page call and by coalesing
> several checks such as the check for PageHead into a single check so that
> we can keep the instruction cound minimal when freeing the page frag.
> 
> With this change I am seeing an improvement of about 5% in a simple
> receive/drop test.

I'm going to need to see some buyin from the mm folks on this series.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
