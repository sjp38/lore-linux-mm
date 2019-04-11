Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8D0A1C10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 05:06:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 16A6921841
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 05:06:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=tobin.cc header.i=@tobin.cc header.b="l1Qloyy0";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="LDugmDy9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 16A6921841
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tobin.cc
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8B8B06B0005; Thu, 11 Apr 2019 01:06:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 866A26B0006; Thu, 11 Apr 2019 01:06:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 72DD06B0007; Thu, 11 Apr 2019 01:06:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4D9206B0005
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 01:06:20 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id x18so4055654qkf.8
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 22:06:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:date:from:to:cc
         :subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=45Iu1B+qpnB39VRdP0Ukhw/nt2qEjdh6GzIe7gVrsbQ=;
        b=DEBhdItLfQHuuIvV1moBkL1EFJDuOjSu4NAHkbmEiUwFkoAawwOts4La9bXhzWwCUp
         Z6wVD7D6GkTd2rLR4DesfsV7HJWEF1FiBH6UMw9PsoRV6Bs1Ge8FgIfcZj/ayS87nuuW
         zKlhLOnlKj/2J71+mgopJJRO03FUEENMEwXc/VIfWxo8/oOGoFZA6NSQeGOwajemPmfK
         QTlJXFLfu5s3qUzFuqXJzPby6b1fFO8+5oh8xefuo58971V7sUdWNCqK7PZpJmCUucdq
         Z/8LKHattv08zyBXJ6Y31GJ6TBWpMwMvMMDjcEVIDrq58YngdtDyRMM3JnfocUtgZpPV
         EeDg==
X-Gm-Message-State: APjAAAWOxr62yF9veQRwwx5+HoYOZgKlijfRbqEzVEaS8BFKTbTtVg1H
	Nh0TpZaPWPLQaYpDJZ2Gh8F6YBLvRtiR3crVHpUKCmB4T5VdZRj5+dut4pElFLkTOYHvtz0F4IN
	IPqdWYyteO3IFSob+TiKVwigU+eAOStHfdFRjQkKE84g7I3v+h0s0/+9iGZQJPwwfpw==
X-Received: by 2002:a0c:b9af:: with SMTP id v47mr37141145qvf.213.1554959180065;
        Wed, 10 Apr 2019 22:06:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwgOBYDgPfTE9sDfF8kOJnZnkB6ZSZJE/71NBdALA60YKVWPtZW9HmYaGR0JyUcd+1DGYXk
X-Received: by 2002:a0c:b9af:: with SMTP id v47mr37141108qvf.213.1554959179404;
        Wed, 10 Apr 2019 22:06:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554959179; cv=none;
        d=google.com; s=arc-20160816;
        b=TKr8RxBHuPa6egICAV37couqpBZ4wuk5ORLVMtLhkOVOf4dVQUobyri3dOx48oL4lT
         uzUuGGDyJvMpclRKoYAB1yv5QfaCJCYaFCjO38dxBVDapozWlhMyg7Yhzojz+UPqtQZO
         /K82XbLoiAjXkvN6JRgtcDgmAnBH8EEBmhJdVveC4VzmswS8U74Skn1cS2LlCCmANFaZ
         c6zk59ItKgc1oVwnuF5esNHmbHcsFtQ7JbhaLQpg8AD2O6XDx/bHhmr1kXYgXDl9lS8d
         rhxr+xkRdqznQuFlFOyXrlm30+zu3ndQfa0QtfTFJ5/TpSAOC8fmmzDJoRVLrp57dP62
         hxvg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature:dkim-signature;
        bh=45Iu1B+qpnB39VRdP0Ukhw/nt2qEjdh6GzIe7gVrsbQ=;
        b=czgfntu9CwleHK+NUmykl27bioMZ3TVIrs6RTJVCoJgamiL37LRr0iVWqgjKnT4EzH
         wAd5McpjxMKTmW4FDPcK2wTi5tT7a38zwqlecYhiatlez5vzSrzTETUo4LwjhEQuoEnN
         vVWtP23mGrUAy5X6FhOMiAUyzdAzw4rQQUVfircFxqsNTQnOxzeLPXRGBUDJCowwbXFy
         xi+gHlXqc+Jk8L7WiOZb41YC2g+jAOYN2X5EW2qkc+0jagdEUfefVhbPi9iIXmH6Ac7r
         5AVpVJdXEoDjkGu8PzF4sjSo+jCKScATFVVdARhsXJJFtRMG3kp1DzSz5SZvLf+dJBxH
         Byjw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=l1Qloyy0;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=LDugmDy9;
       spf=neutral (google.com: 66.111.4.224 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from new2-smtp.messagingengine.com (new2-smtp.messagingengine.com. [66.111.4.224])
        by mx.google.com with ESMTPS id d16si6645053qtj.301.2019.04.10.22.06.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Apr 2019 22:06:19 -0700 (PDT)
Received-SPF: neutral (google.com: 66.111.4.224 is neither permitted nor denied by best guess record for domain of me@tobin.cc) client-ip=66.111.4.224;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=l1Qloyy0;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=LDugmDy9;
       spf=neutral (google.com: 66.111.4.224 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailnew.nyi.internal (Postfix) with ESMTP id F0346811D;
	Thu, 11 Apr 2019 01:06:18 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute5.internal (MEProxy); Thu, 11 Apr 2019 01:06:19 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tobin.cc; h=date
	:from:to:cc:subject:message-id:references:mime-version
	:content-type:in-reply-to; s=fm2; bh=45Iu1B+qpnB39VRdP0Ukhw/nt2q
	Ejdh6GzIe7gVrsbQ=; b=l1Qloyy0N3NHG+Dq0uWHfSP1OKFv/mKAVBCPkyEHVsF
	khWJ7QW6Y2ab+w/ruKn2bTyhyAPZVlrDTwsgZfv2DDrR3GmhF1k2f5X+cVLmixQT
	UOmBTgGFiS74q2CQOrzpfvMaQQruhGfoK6cSOPLpCGbQH915K+wF/SDpsbLrR+wz
	e3PnqfTJsXkyroOlekc0MS54591i2DUGor1XsJ7nkqHwE8UrROJRBvMwVepD9ZQn
	6Dw1t7CRJi194GhPb99WAUs+4c7GHykYH8z8AV8e3YtPJEoaBjp8JIB5PeEhzpxu
	fOHWMEHmAXwVAcY5jSDq/OwwEeaKolvolCIhd9CFf2Q==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to:x-me-proxy
	:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=45Iu1B
	+qpnB39VRdP0Ukhw/nt2qEjdh6GzIe7gVrsbQ=; b=LDugmDy9EBTwh4CG8C7fil
	/6JFtb2Nnvkw60p1kiPX4Fqk55/URBvvR2foHoQyHR/49WVhc4ZgkKMTPFh/XI+M
	CAuI/YgPDtX2JDPGDVzbphhJ6xBE4Vduc91udjqsDhbJUd+tC4/cJoFDZ7fISkUs
	4DmVq0f3fESCMty96WWKPij40BI2+bNHf+h3yvapFVGN9/8Z8bXBP/70QIpoqitt
	8DLa5xqBzacmFOmANvRAONIn2ydNwWdCJ15cybFY8L02h6GdvT76VXYNcRePDLOk
	vJtfmdyFnEndwTSkKqXTki7lAiTmWUkJl9j7aYLDxrCBz8vkmp6DojVWN1VxIP/g
	==
X-ME-Sender: <xms:R8uuXL9Mck2N9mrFeLNhbAvkEWJDw-A6mD4QlvkdinyR_Wi4uFbjcA>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrudekgdekiecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenfg
    hrlhcuvffnffculdeftddmnecujfgurhepfffhvffukfhfgggtuggjofgfsehttdertdfo
    redvnecuhfhrohhmpedfvfhosghinhcuvedrucfjrghrughinhhgfdcuoehmvgesthhosg
    hinhdrtggtqeenucfkphepuddvgedrudejuddrudelrdduleegnecurfgrrhgrmhepmhgr
    ihhlfhhrohhmpehmvgesthhosghinhdrtggtnecuvehluhhsthgvrhfuihiivgeptd
X-ME-Proxy: <xmx:R8uuXC47zZxSq_HzhxcXeeVrqEsUUOaxb5BVLY_jHr3rIPXwav961w>
    <xmx:R8uuXILhC61rHkW4KsT9OJ6ei8rB12WF6sMOvoVbwrGCra8Z3JK1wA>
    <xmx:R8uuXHuOGcj6-WZQxGDxEPFTdZ9iErwVl5p3JMiE1sDgyQnEDecJCg>
    <xmx:SsuuXNnbR3gffchT_Am5_yg3m9p7t5_SXsPkKZS0Wg4-55CrmOW4hA>
Received: from localhost (124-171-19-194.dyn.iinet.net.au [124.171.19.194])
	by mail.messagingengine.com (Postfix) with ESMTPA id D9FDBE40FF;
	Thu, 11 Apr 2019 01:06:14 -0400 (EDT)
Date: Thu, 11 Apr 2019 15:05:38 +1000
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
	Hugh Dickins <hughd@google.com>, Jonathan Corbet <corbet@lwn.net>,
	linux-mm@kvack.org, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [RFC PATCH v3 14/15] dcache: Implement partial shrink via Slab
 Movable Objects
Message-ID: <20190411050538.GA22216@eros.localdomain>
References: <20190411013441.5415-1-tobin@kernel.org>
 <20190411013441.5415-15-tobin@kernel.org>
 <20190411023322.GD2217@ZenIV.linux.org.uk>
 <20190411024821.GB6941@eros.localdomain>
 <20190411044746.GE2217@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190411044746.GE2217@ZenIV.linux.org.uk>
X-Mailer: Mutt 1.11.4 (2019-03-13)
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 11, 2019 at 05:47:46AM +0100, Al Viro wrote:
> On Thu, Apr 11, 2019 at 12:48:21PM +1000, Tobin C. Harding wrote:
> 
> > Oh, so putting entries on a shrink list is enough to pin them?
> 
> Not exactly pin, but __dentry_kill() has this:
>         if (dentry->d_flags & DCACHE_SHRINK_LIST) {
>                 dentry->d_flags |= DCACHE_MAY_FREE;
>                 can_free = false;
>         }
>         spin_unlock(&dentry->d_lock);
>         if (likely(can_free))
>                 dentry_free(dentry);
> and shrink_dentry_list() - this:
>                         if (dentry->d_lockref.count < 0)
>                                 can_free = dentry->d_flags & DCACHE_MAY_FREE;
>                         spin_unlock(&dentry->d_lock);
>                         if (can_free)
>                                 dentry_free(dentry);
> 			continue;
> so if dentry destruction comes before we get around to
> shrink_dentry_list(), it'll stop short of dentry_free() and mark it for
> shrink_dentry_list() to do just dentry_free(); if it overlaps with
> shrink_dentry_list(), but doesn't progress all the way to freeing,
> we will
> 	* have dentry removed from shrink list
> 	* notice the negative ->d_count (i.e. that it has already reached
> __dentry_kill())
> 	* see that __dentry_kill() is not through with tearing the sucker
> apart (no DCACHE_MAY_FREE set)
> ... and just leave it alone, letting __dentry_kill() do the rest of its
> thing - it's already off the shrink list, so __dentry_kill() will do
> everything, including dentry_free().
> 
> The reason for that dance is the locking - shrink list belongs to whoever
> has set it up and nobody else is modifying it.  So __dentry_kill() doesn't
> even try to remove the victim from there; it does all the teardown
> (detaches from inode, unhashes, etc.) and leaves removal from the shrink
> list and actual freeing to the owner of shrink list.  That way we don't
> have to protect all shrink lists a single lock (contention on it would
> be painful) and we don't have to play with per-shrink-list locks and
> all the attendant headaches (those lists usually live on stack frame
> of some function, so just having the lock next to the list_head would
> do us no good, etc.).  Much easier to have the shrink_dentry_list()
> do all the manipulations...
> 
> The bottom line is, once it's on a shrink list, it'll stay there
> until shrink_dentry_list().  It may get extra references after
> being inserted there (e.g. be found by hash lookup), it may drop
> those, whatever - it won't get freed until we run shrink_dentry_list().
> If it ends up with extra references, no problem - shrink_dentry_list()
> will just kick it off the shrink list and leave it alone.
> 
> Note, BTW, that umount coming between isolate and drop is not a problem;
> it call shrink_dcache_parent() on the root.  And if shrink_dcache_parent()
> finds something on (another) shrink list, it won't put it to the shrink
> list of its own, but it will make note of that and repeat the scan in
> such case.  So if we find something with zero refcount and not on
> shrink list, we can move it to our shrink list and be sure that its
> superblock won't go away under us...

Man, that was good to read.  Thanks for taking the time to write this.


	Tobin

