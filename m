Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4981D6B0005
	for <linux-mm@kvack.org>; Mon, 12 Mar 2018 20:45:36 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id h33so10235060wrh.10
        for <linux-mm@kvack.org>; Mon, 12 Mar 2018 17:45:36 -0700 (PDT)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id z12si4022401wmh.127.2018.03.12.17.45.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Mar 2018 17:45:34 -0700 (PDT)
Date: Tue, 13 Mar 2018 00:45:32 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH 3/3] dcache: account external names as indirectly
 reclaimable memory
Message-ID: <20180313004532.GU30522@ZenIV.linux.org.uk>
References: <20180305133743.12746-1-guro@fb.com>
 <20180305133743.12746-5-guro@fb.com>
 <20180312211742.GR30522@ZenIV.linux.org.uk>
 <20180312223632.GA6124@castle>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180312223632.GA6124@castle>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Mon, Mar 12, 2018 at 10:36:38PM +0000, Roman Gushchin wrote:

> Ah, I see...
> 
> I think, it's better to account them when we're actually freeing,
> otherwise we will have strange path:
> (indirectly) reclaimable -> unreclaimable -> free
> 
> Do you agree?

> +static void __d_free_external_name(struct rcu_head *head)
> +{
> +	struct external_name *name;
> +
> +	name = container_of(head, struct external_name, u.head);
> +
> +	mod_node_page_state(page_pgdat(virt_to_page(name)),
> +			    NR_INDIRECTLY_RECLAIMABLE_BYTES,
> +			    -ksize(name));
> +
> +	kfree(name);
> +}

Maybe, but then you want to call that from __d_free_external() and from
failure path in __d_alloc() as well.  Duplicating something that convoluted
and easy to get out of sync is just asking for trouble.
