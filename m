Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C1C36C04AAC
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 01:45:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 705E72171F
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 01:45:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=tobin.cc header.i=@tobin.cc header.b="aVzZIMke";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="wogBIOI9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 705E72171F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tobin.cc
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1AFCA6B0006; Mon, 20 May 2019 21:45:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1616B6B0007; Mon, 20 May 2019 21:45:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0511C6B0008; Mon, 20 May 2019 21:45:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id DA70B6B0006
	for <linux-mm@kvack.org>; Mon, 20 May 2019 21:45:41 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id l37so15899732qtc.8
        for <linux-mm@kvack.org>; Mon, 20 May 2019 18:45:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:date:from:to:cc
         :subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=zSyPy+Mn5LVlJ+FlCj33Ng1Vj0N3aj5sXaJqqEQXdJg=;
        b=ANmRxvnkzBf2yRptVKaZ1fxFmL54/f8pv9HRWVhyibPrYjzzjbEH3Cs8MxEbm+1Asj
         BxcaZB8InXDmL1nt7tbGQy2NxpIvEY/v4BlAx6Ee2eAN8/b3LO9TJJpYLEoy6c+o73PC
         kB2D+eCDFGvD6o2wqjxyIiF7TFV/moWLK+7iePIxBV1kF7QARBrx94FeFdv+Q+pTac/3
         FZY0v37jduHMBAlQ+v2e5UepRk1ZnNxcdsSDJPD+yxWiG3MmV3kQjuj3b+3xFe+UQ37w
         UI6UtR2hywm0V3ZWpr6jmXv2TZ7JNhPgc9uNt6rcEBy3Mrwk9ci0C/9K1MQDEC6qFIdw
         jGcQ==
X-Gm-Message-State: APjAAAVY/xxWVMHA1Psf7ny5uj/dd9cFnSbAmJA29jlK6T8zN+E7xvH7
	pHb8WiFJ5WkU0buZd+ye0CYtd2yPfF0bi1CcWIz5100A5Gi1G6+Yk0qVZUlAjmIWFoCKgbk+8vu
	UJvSsdsf4l6785YVTsfMBvuRhSTb47LvBEm+5Oz22UvOYf2rsgtiz01PiqSbtoupIxQ==
X-Received: by 2002:ac8:2bcf:: with SMTP id n15mr54569318qtn.215.1558403141691;
        Mon, 20 May 2019 18:45:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxT6QG8SVRelGy9gCM5XZj5dBPN+9KazCtV4qbiXQ+EdE+HgLfdzLrODHkfS8Gh/QodXWOA
X-Received: by 2002:ac8:2bcf:: with SMTP id n15mr54569291qtn.215.1558403141217;
        Mon, 20 May 2019 18:45:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558403141; cv=none;
        d=google.com; s=arc-20160816;
        b=dFpFIzS19+OySqQsXP0dKQxJY/IXgwxoARSdSysHoBLrL9Ca+CB0oK9QPCDd8euqSr
         8ZkuZlIxxaSiPYqizGWF8KeSAY5XvDne9ikSkND12l/TxjmKSHaw6JlpYwneb38UjxlQ
         CpPKZZyHWu8bdgd9h1Is4+kdcI+TnO922LV4Y2hX3LmBelRGTa2PD4sRve+gerwq74Se
         YBjIpX1sR8OcfDhcSZsSe9O8m9dYMoWAaTR9KCkeh3pDsTbqUVp6GGf1fN/r1z4j+YCf
         99bkxkJJ1FTSsy5c3PSweKByrX+NaY/47nqvsrbJ0SRTAqqqY+2RSCSuAZ6A+GPfgrUt
         d9eg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature:dkim-signature;
        bh=zSyPy+Mn5LVlJ+FlCj33Ng1Vj0N3aj5sXaJqqEQXdJg=;
        b=oscdMwiSMXWlqfHhE+fNcJXfAoRuQMxRxFWN2qTnla6oFyMjofOATjcq1EArm7qtm9
         PCM6rOYuToVxX6SJejLGNMGPqQd0TpXx8vPFSKZDBrfmP+hTT59ScQQoU+OccELBFhy4
         G28Stu2ruQY3MS24F0itT01M3PFgwY6Y7WuEaYoEPem+dpHpQHJVoNzRFwwgOKRHuSsL
         yp6bKMZP3S2KjWmsrpCJrEgv3UpT5JQpvoVdY9YLna6qEB+3WolODVnMDFtT9q4sUCYt
         wHxnDOfbPt56bwtiUBeCIleFExfRHRodwg/D32ahrIv5FeaV7jCDlrNOuIMERssLp6JX
         u8Bg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm3 header.b=aVzZIMke;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=wogBIOI9;
       spf=neutral (google.com: 66.111.4.221 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from new1-smtp.messagingengine.com (new1-smtp.messagingengine.com. [66.111.4.221])
        by mx.google.com with ESMTPS id x37si5272597qtc.286.2019.05.20.18.45.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 18:45:41 -0700 (PDT)
Received-SPF: neutral (google.com: 66.111.4.221 is neither permitted nor denied by best guess record for domain of me@tobin.cc) client-ip=66.111.4.221;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm3 header.b=aVzZIMke;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=wogBIOI9;
       spf=neutral (google.com: 66.111.4.221 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailnew.nyi.internal (Postfix) with ESMTP id ADF3BBFD1;
	Mon, 20 May 2019 21:45:40 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute5.internal (MEProxy); Mon, 20 May 2019 21:45:40 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tobin.cc; h=date
	:from:to:cc:subject:message-id:references:mime-version
	:content-type:in-reply-to; s=fm3; bh=zSyPy+Mn5LVlJ+FlCj33Ng1Vj0N
	3aj5sXaJqqEQXdJg=; b=aVzZIMke8RgIn6fgRezyJIRNTdJNmy5BsAfcf1rzNh9
	kfmmri+unp7PyZsnxtkTgHSaodOlSW0TTlKw/4fzSUEUmmtotFcMflrouEawmetl
	yMmjYklNKZ2LGYBcwcppzbcYXLRiwTA4QcWSB/ZX7H9FsqXPJxD/cRXvqR7HSnbl
	zmsZE4Ph1MtGXYkMjSGtQYC7AFO14uXoLyZbbHwa5QkUlBhb3yBrrCFILt19iBEf
	kwl8tl11sbo2aN+IhYgJFA3CPgZgs+3qDPLfVBdw4eJznoV2b2tluB4D4CqOi8Cz
	8hEcWr+0tr06AIlzR9mIdoTTxdmg5oLtQIMgMM4lQRA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to:x-me-proxy
	:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=zSyPy+
	Mn5LVlJ+FlCj33Ng1Vj0N3aj5sXaJqqEQXdJg=; b=wogBIOI9ILp8CO+jyYf2m/
	4O6hf7ZDRufCxFGdAvGp6xsRPd+RZznXygF6h6C8FzaK2UCm+jexQBRPR5a036PZ
	ragLxfROMNdB/0r9JMwaS38EjvpdLnYb6fIAMRTYkPNQkcbQryDr2NjG42OxjcBW
	byUfI68V1yvb882goJR9nc6oZZ2w4KokjWRhkD9kaYfk1ROH6zxZnlbBDN2gDvJO
	7blXnkWpM6kS89cTpb9wYgh63AMAU4w6AKN4L9TLTCXZXNm6HDKxrTN6+h/1QAZv
	nk5lOnZ1kaxo4AMVAoe6nuYv6JnFpbD1aDar6wzuzMu+RpE4pza1gfrJUfw8GXDw
	==
X-ME-Sender: <xms:QFjjXGtb0C56eqETPYVgual6pqtTl3Xv4VQd2dU88ZWfBDZlqDgMDw>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddruddtledggeelucetufdoteggodetrfdotf
    fvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfqfgfvpdfurfetoffkrfgpnffqhgen
    uceurghilhhouhhtmecufedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmne
    gfrhhlucfvnfffucdlfedtmdenucfjughrpeffhffvuffkfhggtggujgfofgesthdtredt
    ofervdenucfhrhhomhepfdfvohgsihhnucevrdcujfgrrhguihhnghdfuceomhgvsehtoh
    gsihhnrdgttgeqnecukfhppeduvdegrdduieelrdduheeirddvtdefnecurfgrrhgrmhep
    mhgrihhlfhhrohhmpehmvgesthhosghinhdrtggtnecuvehluhhsthgvrhfuihiivgeptd
X-ME-Proxy: <xmx:QFjjXGIUKhDO5k2QKvBTG4W_hsJowdoztPZE9oKq0Iey0Y_y7DE0TQ>
    <xmx:QFjjXKeDFCQTJi5XPVg3TWkSTJwYsjmcT--3DtyGNqhPO6u28SGLQA>
    <xmx:QFjjXIW67bTni76x_zcwROybxmtiemrH031fommHrIE4s3RokU4WTA>
    <xmx:RFjjXCYvXZUddiAM0f0wNqhYLLKvySulEgfuHrNdsxa024x5Zp9wow>
Received: from localhost (124-169-156-203.dyn.iinet.net.au [124.169.156.203])
	by mail.messagingengine.com (Postfix) with ESMTPA id B78C810378;
	Mon, 20 May 2019 21:45:35 -0400 (EDT)
Date: Tue, 21 May 2019 11:44:57 +1000
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
Subject: Re: [RFC PATCH v5 13/16] slub: Enable balancing slabs across nodes
Message-ID: <20190521014457.GA27676@eros.localdomain>
References: <20190520054017.32299-1-tobin@kernel.org>
 <20190520054017.32299-14-tobin@kernel.org>
 <20190521010404.GB9552@tower.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190521010404.GB9552@tower.DHCP.thefacebook.com>
X-Mailer: Mutt 1.11.4 (2019-03-13)
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 21, 2019 at 01:04:10AM +0000, Roman Gushchin wrote:
> On Mon, May 20, 2019 at 03:40:14PM +1000, Tobin C. Harding wrote:
> > We have just implemented Slab Movable Objects (SMO).  On NUMA systems
> > slabs can become unbalanced i.e. many slabs on one node while other
> > nodes have few slabs.  Using SMO we can balance the slabs across all
> > the nodes.
> > 
> > The algorithm used is as follows:
> > 
> >  1. Move all objects to node 0 (this has the effect of defragmenting the
> >     cache).
> 
> This already sounds dangerous (or costly). Can't it be done without
> cross-node data moves?
>
> > 
> >  2. Calculate the desired number of slabs for each node (this is done
> >     using the approximation nr_slabs / nr_nodes).
> 
> So that on this step only (actual data size - desired data size) has
> to be moved?

This is just the most braindead algorithm I could come up with.  Surely
there are a bunch of things that could be improved.  Since I don't know
the exact use case it seemed best not to optimize for any one use case.

I'll review, comment on, and test any algorithm you come up with!

thanks,
Tobin.

