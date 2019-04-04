Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8954CC10F0C
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 21:18:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2581621741
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 21:18:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=tobin.cc header.i=@tobin.cc header.b="PdEV3E10";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="m3O8CmWU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2581621741
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tobin.cc
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B95CF6B000E; Thu,  4 Apr 2019 17:18:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B1CDC6B0266; Thu,  4 Apr 2019 17:18:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9BDDF6B0269; Thu,  4 Apr 2019 17:18:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7858D6B000E
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 17:18:43 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id t22so3527411qtc.13
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 14:18:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:date:from:to:cc
         :subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=MZAuKYKhVUdXNXP8VDdaXdcH3xxr14eBQKAZ0V3Br2Y=;
        b=XBUke95VEK345vVQQ+wUFJid23OeTnedOPeaS+nMCuVke3Hck6+8oAcY50DpvNrrrj
         U2NTqkGzUHtEXbU/eQyTgzOdgbQUMSHrbajyuW0LCADakz1hf8TUtYQblfR852TPdFje
         j+1FI/SmRnSB3y5hOwu1rfV5t4eM1RLYN1eBVhjrueW3WeJ2x4WB8m/R2smqcaE9kYrm
         a1QFoX1zWsUyh5bB8Sn5n2ZpjkysFrEIsGy7QrD27lkgzOCAHSXYz29ahC9XUVfDabd0
         4icBu/COtVsGgCR9kahfPiNLqkFFQZnYO5npO7vecKIJm1xogWmhCC+p1ugVwrGxqEPs
         SxRg==
X-Gm-Message-State: APjAAAWTomtP9V6VcQ8AIjL0MkmgoRgYkR8K8pB78CVFpHyMnVC7r/OK
	M9LcyK6kDn3Bhn4U4vgZU5Mb2qyAgnEWRHtizP3Hq9j4cWc/3/PjZmvEUF0jR/Jmqc+HCMG208O
	0DUOAcXdSNMKRHf1QM1u2ZcuKSIL9f+v0NTfP7q5pOwEXzGukX8OFMZLgHIS56d566g==
X-Received: by 2002:ac8:5518:: with SMTP id j24mr7748860qtq.183.1554412723238;
        Thu, 04 Apr 2019 14:18:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzRWrBr6NpF6+PJ9bgLYpmBKkrNHzS6frMTCRwVqG42iEav96xRbY7KpvFoVKuA0NfQccB7
X-Received: by 2002:ac8:5518:: with SMTP id j24mr7748755qtq.183.1554412721776;
        Thu, 04 Apr 2019 14:18:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554412721; cv=none;
        d=google.com; s=arc-20160816;
        b=P9Y3FeGR99KXfmCMYYTB901iM+mHmEb4yAaftEXS4brjQJRl1S3WdBXWZ8Ej+GEuFc
         5ox47a/SQon5XF2+vq3ltgfl7Aj4sv7/iAYxUMnx4MpDHSdrZKUj1DTZ/9bjIgUXRR5x
         f1EZoD4f5xa/mkSoswTMFKPtEI231OtvU0elrgm0EtGR9Ey11oF8YdjXwBexPS3wRYQX
         IEOUyq3/wQ6h+58V0yClRqKFPgXfWTuRy8P8EmKWTh+u+SiPLOWIjUK2MFjFruoxlKpJ
         DP6ToZ+vA7bn9apEt5u8P3FEVb6iu7l777U3fZmPKoxdY/4LM90ZshIZgFzlDaBlc76x
         nqng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature:dkim-signature;
        bh=MZAuKYKhVUdXNXP8VDdaXdcH3xxr14eBQKAZ0V3Br2Y=;
        b=trqLPT68wnuuwymI4h4S3pUUx+NYn+o0DoWfzVoU8OLPFODorfLhawbX2ngb68GWA8
         SKwV1ogm6FqsA15pvHhmL6MHDb6KER8FzXb0huxC+XXSZs2QofkWDqMpoXHvzkCtJt+N
         nFuwVYVALxKujxXTe7dnBdDUy9cNcmMDi37oDWE8TPNa8JkRvalPVBHmtVkbGOX1rtqM
         pgaTakbeyns0xyk2ragyHJz8daDDJMxNm1ytaASS1BEPenu2aDzorj3EHJokxbdeFo3u
         EmY/pGxhgLZwthsKvW3fXzQjOKbTCkaZu1xk3wQHd2GabtrYcyNhwE1Vljl3DX13rSXj
         EGuw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=PdEV3E10;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=m3O8CmWU;
       spf=neutral (google.com: 66.111.4.29 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from out5-smtp.messagingengine.com (out5-smtp.messagingengine.com. [66.111.4.29])
        by mx.google.com with ESMTPS id e15si923739qkl.77.2019.04.04.14.18.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Apr 2019 14:18:41 -0700 (PDT)
Received-SPF: neutral (google.com: 66.111.4.29 is neither permitted nor denied by best guess record for domain of me@tobin.cc) client-ip=66.111.4.29;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=PdEV3E10;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=m3O8CmWU;
       spf=neutral (google.com: 66.111.4.29 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 32F4D22074;
	Thu,  4 Apr 2019 17:18:41 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute5.internal (MEProxy); Thu, 04 Apr 2019 17:18:41 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tobin.cc; h=date
	:from:to:cc:subject:message-id:references:mime-version
	:content-type:in-reply-to; s=fm2; bh=MZAuKYKhVUdXNXP8VDdaXdcH3xx
	r14eBQKAZ0V3Br2Y=; b=PdEV3E10YP6K3/Bkgib8IGcQODXjDSUsxxb2QyRq5xV
	sz7bTuhNmDxvRcXfdwbnlauiwj8w8sdwWcbO4sLt77PXP8/VK/XTKu/wYVLf/5mC
	JlfmY32L3yJkpkXC40GR85A9Otq5ufQtIz9IaHpVElJTvwgb1B3V2KE0C+L17uVb
	b4vTX0gFTGE8Y+kwcQ+kDuFh/LT487ESuTJIDS41V6iedrYDAvyVVKxm52gZQtvS
	F3HYEfFh5rSvfqjHq8x4OiyCh8UYcAA4K/A5ULMOe9ye6tfAEoflrSBNEh6D2m7j
	kj/oLAjhLP7053bS3VCiZ0Zj1Z+qGECzm60nd0Rqnrw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to:x-me-proxy
	:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=MZAuKY
	KhVUdXNXP8VDdaXdcH3xxr14eBQKAZ0V3Br2Y=; b=m3O8CmWUzxxiAnfloEO0Pq
	iHKChmfTn5frqDm3x9G2hs1BgP5ODO9a+u4J3KY2d6x+YtxlEu1SA7qd50rPZCVO
	CkMdziTlOwHjs/bPJR7FcAaRYvv5nwQLxm6yz4CvFIKr4KXgIEmaRQa0Gyke2H1w
	K/ixQn9VL0cYtfILWP+f6mH07VVnca3I5/alHZ4RJyTC8PtNZa9apDj3mvrA0vnC
	hNTQhT9JVk6hw7QBHxEw4wddmPPJgnbpQkQVPlLmlI19Ro8K4aj7fffaANW0b/1V
	g296sTlzIFIbXaNBDztfhjebPGKAQTtKQ8Jpm2Xb2YZLX5l4Q738c7s90jXi1D+A
	==
X-ME-Sender: <xms:rnSmXMQOT-4xXQH_9G_a-LoGG-aWEv2YT8_jLIwIwnldX5F5SdVbfA>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrtdehgdduheekucdltddurdeguddtrddttd
    dmucetufdoteggodetrfdotffvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfqfgfv
    pdfurfetoffkrfgpnffqhgenuceurghilhhouhhtmecufedttdenucesvcftvggtihhpih
    gvnhhtshculddquddttddmnegfrhhlucfvnfffucdludehmdenucfjughrpeffhffvuffk
    fhggtggujgfofgesthdtredtofervdenucfhrhhomhepfdfvohgsihhnucevrdcujfgrrh
    guihhnghdfuceomhgvsehtohgsihhnrdgttgeqnecukfhppeduvdegrddugeelrdduudeg
    rdekieenucfrrghrrghmpehmrghilhhfrhhomhepmhgvsehtohgsihhnrdgttgenucevlh
    hushhtvghrufhiiigvpedt
X-ME-Proxy: <xmx:rnSmXEtVS12_VP5WszENUZ4bY5TKnmAy2DGEOUwOzz522sc8uGIaQg>
    <xmx:rnSmXIyDnvRPhhXFqbkNxfFBdmZ4SFfSCxZVwkUb8GiCs95JOHfJ1w>
    <xmx:rnSmXEeHbRnOiSkzO0dBc6_D728D8JNbnHVOvBo1baSbL97gn6Yw8A>
    <xmx:sXSmXMdwZa3bMDHk41AhHkzesONUJFSVW8sfH_hqRdOvITTT2nZNEw>
Received: from localhost (124-149-114-86.dyn.iinet.net.au [124.149.114.86])
	by mail.messagingengine.com (Postfix) with ESMTPA id AB3CA100E5;
	Thu,  4 Apr 2019 17:18:36 -0400 (EDT)
Date: Fri, 5 Apr 2019 08:18:05 +1100
From: "Tobin C. Harding" <me@tobin.cc>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Roman Gushchin <guro@fb.com>,
	Alexander Viro <viro@ftp.linux.org.uk>,
	Christoph Hellwig <hch@infradead.org>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Christopher Lameter <cl@linux.com>,
	Matthew Wilcox <willy@infradead.org>,
	Miklos Szeredi <mszeredi@redhat.com>,
	Andreas Dilger <adilger@dilger.ca>,
	Waiman Long <longman@redhat.com>, Tycho Andersen <tycho@tycho.ws>,
	Theodore Ts'o <tytso@mit.edu>, Andi Kleen <ak@linux.intel.com>,
	David Chinner <david@fromorbit.com>,
	Nick Piggin <npiggin@gmail.com>, Rik van Riel <riel@redhat.com>,
	Hugh Dickins <hughd@google.com>, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RFC PATCH v2 14/14] dcache: Implement object migration
Message-ID: <20190404211805.GA18488@eros.localdomain>
References: <20190403042127.18755-1-tobin@kernel.org>
 <20190403042127.18755-15-tobin@kernel.org>
 <20190403170811.GR2217@ZenIV.linux.org.uk>
 <20190403171920.GS2217@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190403171920.GS2217@ZenIV.linux.org.uk>
X-Mailer: Mutt 1.11.4 (2019-03-13)
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 03, 2019 at 06:19:21PM +0100, Al Viro wrote:
> On Wed, Apr 03, 2019 at 06:08:11PM +0100, Al Viro wrote:
> 
> > Oh, *brilliant*
> > 
> > Let's do d_invalidate() on random dentries and hope they go away.
> > With convoluted and brittle logics for deciding which ones to
> > spare, which is actually wrong.  This will pick mountpoints
> > and tear them out, to start with.
> > 
> > NAKed-by: Al Viro <viro@zeniv.linux.org.uk>
> > 
> > And this is a NAK for the entire approach; if it has a positive refcount,
> > LEAVE IT ALONE.  Period.  Don't play this kind of games, they are wrong.
> > d_invalidate() is not something that can be done to an arbitrary dentry.
> 
> PS: "try to evict what can be evicted out of this set" can be done, but
> you want something like
> 	start with empty list
> 	go through your array of references
> 		grab dentry->d_lock
> 		if dentry->d_lockref.count is not zero
> 			unlock and continue
> 		if dentry->d_flags & DCACHE_SHRINK_LIST
> 			ditto, it's not for us to play with
>                 if (dentry->d_flags & DCACHE_LRU_LIST)
>                         d_lru_del(dentry);
> 		d_shrink_add(dentry, &list);
> 		unlock
> 
> on the collection phase and
> 	if the list is not empty by the end of that loop
> 		shrink_dentry_list(&list);
> on the disposal.

Implemented as suggested, thanks.  RFCv3 to come when we have some stats
for you :)

thanks,
Tobin.

