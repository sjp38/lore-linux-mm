Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8F859C04AAC
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 01:16:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3A63B2173C
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 01:16:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=tobin.cc header.i=@tobin.cc header.b="j4LseY1X";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="s4fSs2Sb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3A63B2173C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tobin.cc
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B3B076B0003; Mon, 20 May 2019 21:16:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AEC6A6B0005; Mon, 20 May 2019 21:16:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9B3616B0006; Mon, 20 May 2019 21:16:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 77CC66B0003
	for <linux-mm@kvack.org>; Mon, 20 May 2019 21:16:10 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id h16so14214391qke.11
        for <linux-mm@kvack.org>; Mon, 20 May 2019 18:16:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:date:from:to:cc
         :subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Bb3i2g5iLhW0rmPyvqaurkiFFVnYGWCbB02MW+Mdyaw=;
        b=nd8+SHKTrEkoy6jTzbV1AF0AbtWZcWHXMZSyQAwaqAkn7LsdPdFG4v5ZieiFmmLtDa
         40MIJ6jVktbMsR9amEhbB2HeWM2Cg222WAw/ZLp6iawYilsre18SnvRhHMYPnu91tW1F
         6XcR1/Q/2vstQH+bxiiRl1qhbT0Em6x4aGjzqLaH7lBa1FM6ujzASoYRRLAAro8pftaK
         h71ALv9d22SA0uy2K3ptXNUUQe+qrH+JOC0nluUhBY3FRKU/iycOV5EwS0klMyPxeEJT
         3madeAOg6f22dUZYAgoTHrR5NFcwq4sbvUcqvqw6zOKa5MEBn2pWzmMD5drM9KIs5Xjo
         M9LQ==
X-Gm-Message-State: APjAAAUtcPLjoUCuYWQxXHMP87XaR02i3J1YTbMJzYAoY5xZp64zRVFx
	xHb72HyPuK3zOpoy5Eb2FC6ZPPV7K8dzf9NZG9U/4HgawsGtBEEnNIXOoUETf6bIA4aZJDi/SnE
	siH+EIrDTJnzL+meDW8ku0EMFjmZcLHn5uFvifHN1r1lSmzRjaZiBj/fJfPTGqFTQqA==
X-Received: by 2002:a0c:d941:: with SMTP id t1mr62571145qvj.204.1558401370204;
        Mon, 20 May 2019 18:16:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx/HGe72rTAvDQ28mnxAWX+HaErURFai1wKxuZAkVp6ni9wQwoaIsvDpgv2836kpqZzGBut
X-Received: by 2002:a0c:d941:: with SMTP id t1mr62571107qvj.204.1558401369548;
        Mon, 20 May 2019 18:16:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558401369; cv=none;
        d=google.com; s=arc-20160816;
        b=UstkfEBXqTAEWrIhOFaUjfYmnopySN4mOLUyRWjzuXdleUlqIjRyqWLx+7pL1u2MWj
         Cz2MG1e+Kva54LehSxifwJDmTlGBtTCsOpETXOZpsVeoMrYgb7Hz7TpRgZKRLw55kOpi
         6tluOYV/3i1RbIeXrNRm0Aat5ShrEWkcSPZvPLr/O0oeAaAlKiTV8I9m5Xm4ZhlO3+1M
         1vKaiBB/cRo2FImtLjVwQRFFV2DMmXl1dXia021wm4wY/SWYI0UU0/u0vy3M2YFEGaQV
         5TNOClwMZoRUahlvjOxNipAe+ZOfb93WGI/J343n4ksUdzLtxv2+xSq5VzG7JUFt1+pa
         YdZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature:dkim-signature;
        bh=Bb3i2g5iLhW0rmPyvqaurkiFFVnYGWCbB02MW+Mdyaw=;
        b=UTgPzAAigPw3/DJloFsFV72jGgpiqSUcfYu9M6qQRiFdHDXDGhW2zMuUgzkLBQwDHf
         YrCXg7URJWSDKtNFD/IepEiMsKqwwQTibu3H8al/u/mqr5ZvtdxeGQTOxa9CgG8sfIXI
         WV7ClFE7Lh/2wsk4GO4jdIii0RcIaw1SgooAvg0pET+IKThR7wBNYzORtz9CpJsk64B/
         KsGsdRXuW31VIUJ/iewQPOmd5udVbvZ4XYDrgYjNuY8M8BDWd9mReXiJDF1uRCsp9EGN
         v0wb2F0lgHN+y8PD+I9EB1jQcs0KVszq3J1GU8b8F6f7Y/qncXxLZq7xXs7+8LRawtBO
         7+fw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm3 header.b=j4LseY1X;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=s4fSs2Sb;
       spf=neutral (google.com: 66.111.4.221 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from new1-smtp.messagingengine.com (new1-smtp.messagingengine.com. [66.111.4.221])
        by mx.google.com with ESMTPS id 4si1538584qtr.271.2019.05.20.18.16.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 18:16:09 -0700 (PDT)
Received-SPF: neutral (google.com: 66.111.4.221 is neither permitted nor denied by best guess record for domain of me@tobin.cc) client-ip=66.111.4.221;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm3 header.b=j4LseY1X;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=s4fSs2Sb;
       spf=neutral (google.com: 66.111.4.221 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailnew.nyi.internal (Postfix) with ESMTP id 22CAF1553F;
	Mon, 20 May 2019 21:16:09 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute5.internal (MEProxy); Mon, 20 May 2019 21:16:09 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tobin.cc; h=date
	:from:to:cc:subject:message-id:references:mime-version
	:content-type:in-reply-to; s=fm3; bh=Bb3i2g5iLhW0rmPyvqaurkiFFVn
	YGWCbB02MW+Mdyaw=; b=j4LseY1XOGAJNMMt7eUBUwX3kkfceM1KRv7Rjk+0nXL
	VcXZFU216iMv12ehaUrMVquDtpvjclKcLDSKfpoe/e0cwc7XFF0GghXcaakp29ot
	mX5bN2R8BvJVgEIp9O5o1Xz7rxjmNEPHLIqibb8tY09jU1YNSfLWTce31Q4GS81q
	tZEoyc9KeoUfurL2X3ZCCeSf7KLfC6CqsVGLUyOKBR+TK6Xq6vXav67S11VtEyPQ
	+y7PcGR+0IbWi4Ub37UDd78A4+AZLh9FEb8+4bHKqqRB2NmAinU6h0OFvRLMBouJ
	HEyzBGPHSCCCrXsGsKQTToj9Yynl9yWqCZ2sEJzQAVw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to:x-me-proxy
	:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=Bb3i2g
	5iLhW0rmPyvqaurkiFFVnYGWCbB02MW+Mdyaw=; b=s4fSs2SbLddlRxt/R2eqDF
	x4j1USTUxMBO7rKXmhWWp352gttz3T2G4t4mB9jSGRNmkYbcXh+5VvxMdpV5eSWo
	QmeUmpGNsN5yGDEVF6uosl+huN7/4/ve8JmcKxPzv9NWAJnajMqPkl/hyXjr62jb
	mQNKC3uSBDxRUaxCUmZLq+uyhfi5JDbwKPwUv7czDUOoj4dBAz59RNADGioyn9UO
	qaziTaEz4bQIRf87VkAzZmziMQKLvAhSkEcxYTQ7hNhMEdTyhxRHoA8im8tHi97C
	VqRrtUdwaHK2BYQulVMDv5HDWnmXpuDk4+od6KdH0RYNt1TwrJrLQsFb+lBr2Z9w
	==
X-ME-Sender: <xms:VlHjXMCMgW9cifHQrSoUiw6Xd-Gve4Vg4FmEb0GITuHOouVq9Y8znA>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddruddtledggeefucetufdoteggodetrfdotf
    fvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfqfgfvpdfurfetoffkrfgpnffqhgen
    uceurghilhhouhhtmecufedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmne
    gfrhhlucfvnfffucdluddtmdenucfjughrpeffhffvuffkfhggtggujgfofgesthdtredt
    ofervdenucfhrhhomhepfdfvohgsihhnucevrdcujfgrrhguihhnghdfuceomhgvsehtoh
    gsihhnrdgttgeqnecukfhppeduvdegrdduieelrdduheeirddvtdefnecurfgrrhgrmhep
    mhgrihhlfhhrohhmpehmvgesthhosghinhdrtggtnecuvehluhhsthgvrhfuihiivgeptd
X-ME-Proxy: <xmx:VlHjXPQ8E4bf48I8mgqL1Pjq5EDtFiOKT0sVAsbxWw1gz0h9b4tFRg>
    <xmx:VlHjXLtKFLfaCkp7NXzhd5df9CDRIt-SqGjb6BEs0zo2nlBAX8X4ww>
    <xmx:VlHjXD1KNEs5xxsUJ-SESozYPYsaPR-wemp0Bjt09okhJEQUHzSijQ>
    <xmx:WVHjXKeEHxTZWxeQFZjkOfT5TnyoE6otRKm1_2cJP0uzkUGY9pEEdQ>
Received: from localhost (124-169-156-203.dyn.iinet.net.au [124.169.156.203])
	by mail.messagingengine.com (Postfix) with ESMTPA id C3AB68005C;
	Mon, 20 May 2019 21:16:05 -0400 (EDT)
Date: Tue, 21 May 2019 11:15:25 +1000
From: "Tobin C. Harding" <me@tobin.cc>
To: Roman Gushchin <guro@fb.com>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Matthew Wilcox <willy@infradead.org>,
	Alexander Viro <viro@ftp.linux.org.uk>,
	Christoph Hellwig <hch@infradead.org>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Christopher Lameter <cl@linux.com>,
	Miklos Szeredi <mszeredi@redhat.com>,
	Andreas Dilger <adilger@dilger.ca>,
	Waiman Long <longman@redhat.com>, Tycho Andersen <tycho@tycho.ws>,
	Theodore Ts'o <tytso@mit.edu>, Andi Kleen <ak@linux.intel.com>,
	David Chinner <david@fromorbit.com>,
	Nick Piggin <npiggin@gmail.com>, Rik van Riel <riel@redhat.com>,
	Hugh Dickins <hughd@google.com>, Jonathan Corbet <corbet@lwn.net>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [RFC PATCH v5 04/16] slub: Slab defrag core
Message-ID: <20190521011525.GA25898@eros.localdomain>
References: <20190520054017.32299-1-tobin@kernel.org>
 <20190520054017.32299-5-tobin@kernel.org>
 <20190521005152.GC21811@tower.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190521005152.GC21811@tower.DHCP.thefacebook.com>
X-Mailer: Mutt 1.11.4 (2019-03-13)
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 21, 2019 at 12:51:57AM +0000, Roman Gushchin wrote:
> On Mon, May 20, 2019 at 03:40:05PM +1000, Tobin C. Harding wrote:
> > Internal fragmentation can occur within pages used by the slub
> > allocator.  Under some workloads large numbers of pages can be used by
> > partial slab pages.  This under-utilisation is bad simply because it
> > wastes memory but also because if the system is under memory pressure
> > higher order allocations may become difficult to satisfy.  If we can
> > defrag slab caches we can alleviate these problems.
> > 
> > Implement Slab Movable Objects in order to defragment slab caches.
> > 
> > Slab defragmentation may occur:
> > 
> > 1. Unconditionally when __kmem_cache_shrink() is called on a slab cache
> >    by the kernel calling kmem_cache_shrink().
> > 
> > 2. Unconditionally through the use of the slabinfo command.
> > 
> > 	slabinfo <cache> -s
> > 
> > 3. Conditionally via the use of kmem_cache_defrag()
> > 
> > - Use Slab Movable Objects when shrinking cache.
> > 
> > Currently when the kernel calls kmem_cache_shrink() we curate the
> > partial slabs list.  If object migration is not enabled for the cache we
> > still do this, if however, SMO is enabled we attempt to move objects in
> > partially full slabs in order to defragment the cache.  Shrink attempts
> > to move all objects in order to reduce the cache to a single partial
> > slab for each node.
> > 
> > - Add conditional per node defrag via new function:
> > 
> > 	kmem_defrag_slabs(int node).
> > 
> > kmem_defrag_slabs() attempts to defragment all slab caches for
> > node. Defragmentation is done conditionally dependent on MAX_PARTIAL
> > _and_ defrag_used_ratio.
> > 
> >    Caches are only considered for defragmentation if the number of
> >    partial slabs exceeds MAX_PARTIAL (per node).
> > 
> >    Also, defragmentation only occurs if the usage ratio of the slab is
> >    lower than the configured percentage (sysfs field added in this
> >    patch).  Fragmentation ratios are measured by calculating the
> >    percentage of objects in use compared to the total number of objects
> >    that the slab page can accommodate.
> > 
> >    The scanning of slab caches is optimized because the defragmentable
> >    slabs come first on the list. Thus we can terminate scans on the
> >    first slab encountered that does not support defragmentation.
> > 
> >    kmem_defrag_slabs() takes a node parameter. This can either be -1 if
> >    defragmentation should be performed on all nodes, or a node number.
> > 
> >    Defragmentation may be disabled by setting defrag ratio to 0
> > 
> > 	echo 0 > /sys/kernel/slab/<cache>/defrag_used_ratio
> > 
> > - Add a defrag ratio sysfs field and set it to 30% by default. A limit
> > of 30% specifies that more than 3 out of 10 available slots for objects
> > need to be in use otherwise slab defragmentation will be attempted on
> > the remaining objects.
> > 
> > In order for a cache to be defragmentable the cache must support object
> > migration (SMO).  Enabling SMO for a cache is done via a call to the
> > recently added function:
> > 
> > 	void kmem_cache_setup_mobility(struct kmem_cache *,
> > 				       kmem_cache_isolate_func,
> > 			               kmem_cache_migrate_func);
> > 
> > Co-developed-by: Christoph Lameter <cl@linux.com>
> > Signed-off-by: Tobin C. Harding <tobin@kernel.org>
> > ---
> >  Documentation/ABI/testing/sysfs-kernel-slab |  14 +
> >  include/linux/slab.h                        |   1 +
> >  include/linux/slub_def.h                    |   7 +
> >  mm/slub.c                                   | 385 ++++++++++++++++----
> >  4 files changed, 334 insertions(+), 73 deletions(-)
> 
> Hi Tobin!
> 
> Overall looks very good to me! I'll take another look when you'll post
> a non-RFC version, but so far I can't find any issues.

Thanks for the reviews.

> A generic question: as I understand, you do support only root kmemcaches now.
> Is kmemcg support in plans?

I know very little about cgroups, I have no plans for this work.
However, I'm not the architect behind this - Christoph is guiding the
direction on this one.  Perhaps he will comment.

> Without it the patchset isn't as attractive to anyone using cgroups,
> as it could be. Also, I hope it can solve (or mitigate) the memcg-specific
> problem of scattering vfs cache workingset over multiple generations of the
> same cgroup (their kmem_caches).

I'm keen to work on anything that makes this more useful so I'll do some
research.  Thanks for the idea.

Regards,
Tobin.

