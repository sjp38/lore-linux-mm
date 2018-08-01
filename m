Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0CF036B0006
	for <linux-mm@kvack.org>; Wed,  1 Aug 2018 17:50:23 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id q12-v6so48547pls.13
        for <linux-mm@kvack.org>; Wed, 01 Aug 2018 14:50:23 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 1-v6si45297plj.411.2018.08.01.14.50.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Aug 2018 14:50:21 -0700 (PDT)
Date: Wed, 1 Aug 2018 14:50:20 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC 0/2] harden alloc_pages against bogus nid
Message-Id: <20180801145020.8c76a490c1bf9bef5f87078a@linux-foundation.org>
In-Reply-To: <20180801200418.1325826-1-jeremy.linton@arm.com>
References: <20180801200418.1325826-1-jeremy.linton@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeremy Linton <jeremy.linton@arm.com>
Cc: linux-mm@kvack.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, mhocko@suse.com, vbabka@suse.cz, Punit.Agrawal@arm.com, Lorenzo.Pieralisi@arm.com, linux-arm-kernel@lists.infradead.org, bhelgaas@google.com, linux-kernel@vger.kernel.org

On Wed,  1 Aug 2018 15:04:16 -0500 Jeremy Linton <jeremy.linton@arm.com> wrote:

> The thread "avoid alloc memory on offline node"
> 
> https://lkml.org/lkml/2018/6/7/251
> 
> Asked at one point why the kzalloc_node was crashing rather than
> returning memory from a valid node. The thread ended up fixing
> the immediate causes of the crash but left open the case of bad
> proximity values being in DSDT tables without corrisponding
> SRAT/SLIT entries as is happening on another machine.
> 
> Its also easy to fix that, but we should also harden the allocator
> sufficiently that it doesn't crash when passed an invalid node id.
> There are a couple possible ways to do this, and i've attached two
> separate patches which individually fix that problem.
> 
> The first detects the offline node before calling
> the new_slab code path when it becomes apparent that the allocation isn't
> going to succeed. The second actually hardens node_zonelist() and
> prepare_alloc_pages() in the face of NODE_DATA(nid) returning a NULL
> zonelist. This latter case happens if the node has never been initialized
> or is possibly out of range. There are other places (NODE_DATA &
> online_node) which should be checking if the node id's are > MAX_NUMNODES.
> 

What is it that leads to a caller requesting memory from an invalid
node?  A race against offlining?  If so then that's a lack of
appropriate locking, isn't it?

I don't see a problem with emitting a warning and then selecting a
different node so we can keep running.  But we do want that warning, so
we can understand the root cause and fix it?
