Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 906416B02F2
	for <linux-mm@kvack.org>; Sun, 30 Apr 2017 00:57:15 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id j16so60228157pfk.4
        for <linux-mm@kvack.org>; Sat, 29 Apr 2017 21:57:15 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 92si11029926plc.124.2017.04.29.21.57.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 29 Apr 2017 21:57:14 -0700 (PDT)
Date: Sat, 29 Apr 2017 21:57:06 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC v3 05/17] RCU free VMAs
Message-ID: <20170430045706.GG27790@bombadil.infradead.org>
References: <1493308376-23851-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1493308376-23851-6-git-send-email-ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1493308376-23851-6-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com

On Thu, Apr 27, 2017 at 05:52:44PM +0200, Laurent Dufour wrote:
> @@ -359,6 +359,7 @@ struct vm_area_struct {
>  #endif
>  	struct vm_userfaultfd_ctx vm_userfaultfd_ctx;
>  	seqcount_t vm_sequence;
> +	struct rcu_head vm_rcu_head;
>  };
>  
>  struct core_thread {

It doesn't look like we examine the contents of the VMA until after we've
checked that the seqlock is good, so we should be able to union virtually
any entry in the VMA with the vm_rcu_head.  vm_next, vm_prev, perhaps?
Or anon_vma_chain since a list_head is the same size as an rcu_head.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
