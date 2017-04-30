Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 209176B02F2
	for <linux-mm@kvack.org>; Sun, 30 Apr 2017 01:05:39 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id j16so60280744pfk.4
        for <linux-mm@kvack.org>; Sat, 29 Apr 2017 22:05:39 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id n2si11341022pgn.19.2017.04.29.22.05.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 29 Apr 2017 22:05:38 -0700 (PDT)
Date: Sat, 29 Apr 2017 22:05:29 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC v3 05/17] RCU free VMAs
Message-ID: <20170430050529.GH27790@bombadil.infradead.org>
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
> +static inline bool vma_is_dead(struct vm_area_struct *vma, unsigned int sequence)
> +{
> +	int ret = RB_EMPTY_NODE(&vma->vm_rb);
> +	unsigned seq = ACCESS_ONCE(vma->vm_sequence.sequence);
> +
> +	/*
> +	 * Matches both the wmb in write_seqlock_{begin,end}() and
> +	 * the wmb in vma_rb_erase().
> +	 */
> +	smp_rmb();
> +
> +	return ret || seq != sequence;
> +}

Hang on, this isn't vma_is_dead().  This is vma_has_changed() (possibly
from live to dead, but also possibly grown or shrunk; see your earlier
patch).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
