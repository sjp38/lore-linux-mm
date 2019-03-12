Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8F358C4360F
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 01:06:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 44CA8214AE
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 01:06:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=tobin.cc header.i=@tobin.cc header.b="FTG5XdsL";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="uXdN5KnI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 44CA8214AE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tobin.cc
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E393E8E0004; Mon, 11 Mar 2019 21:06:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DE7F58E0002; Mon, 11 Mar 2019 21:06:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CAF0C8E0004; Mon, 11 Mar 2019 21:06:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id A13B18E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 21:06:50 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id h11so864540qkg.18
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 18:06:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:date:from:to:cc
         :subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=SKFjXI0K92phygeb6zeAtC318FscuxRVk6ZzNAcru7Q=;
        b=ikAiyAxGDxZ5rJCbZ5JkEGaIXfQkkmHMvU1GGvh8TxfK1Pav2g1Z9GetzTjMyqwF3s
         1RrtKwcB+hxnGH4udvR6zAdYWjFNvNhA5XpBjs2f3apsRUgbnJecnCVOR2zwSlQLjP2Q
         RDQv35WqBYxLgMKWGKc+ejpMPX4Vq6WQpZgmedofe8axebmmX76si7UIsZ5h5wKBGqUr
         VUNkZOFbDP6Y7nmcW06TBAubTm6LeEc7gHcCLIcenfHZ71+w48AkhoUdRuKnp8Quf4Nb
         5PAK+Hq146oKE4uZ/Oddyu8l4UnqP1QpVIHTyRtcqtanvmL7ej2UADmg70zwNfhloVL7
         fbVQ==
X-Gm-Message-State: APjAAAUzkFcPONqCVNkrvKBFFrXEYmDxPwyzjPC5J10Uirsr+9Oi13t6
	a/XvPYWP/7Bu0ceBVxxf99rWGKl3IO24AJrIpd8yz3minBs/CgtGi/L8IxUABC4qcQzmCOfJkxj
	K3ULx244ZtLSc5zYPCrzDtesrovv0IEfzKL3cea6/unHwpx/AhkyIAYR8LxU+V4cc2Q==
X-Received: by 2002:ac8:2ea6:: with SMTP id h35mr28167601qta.181.1552352810448;
        Mon, 11 Mar 2019 18:06:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzTWtBA13wocSLUN2G2opvrP7zoh50HtQfUNR9UPp+PniL6l9J+DOdiRcOdcyr69jRFEdr4
X-Received: by 2002:ac8:2ea6:: with SMTP id h35mr28167570qta.181.1552352809833;
        Mon, 11 Mar 2019 18:06:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552352809; cv=none;
        d=google.com; s=arc-20160816;
        b=exSAVB3UjXo850ZFAf+D1fUOCqpfxqV/JvC8+niDGvqTgdOTDf2JUWQikwqVRbiprD
         DlyjaGNuWr8dW/dtl6u+fWLPb3EsOYrHpt+aYCiFlITF3Su6BWuYGJgz67XmVuLSiNAk
         bkXytBYJH0x8h7pMgFbQ2kzc99C3ESprwLSyddPHTzgmdFTxZYHLFMpPv/m65U/9+LVb
         6ia+xxr+veyEjUx4HSgpagajrjeKeO3rlzvWtPfbEr8qUksdyqSTVvUcNtMAKf5mfyt5
         FljptmCrK4X5BX84LsSkxrDz4Z8h2TDOD88nGbr9Nv1ot8rZx6VWh7Kbh0zwpJxTHEBp
         ezzw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature:dkim-signature;
        bh=SKFjXI0K92phygeb6zeAtC318FscuxRVk6ZzNAcru7Q=;
        b=IMhCuamcf4pdL+rG7JrUjUUKI5zp8utcJrwlBEvaWCPiZ1eRu29sY2tPqCcmbtLVIp
         brxp0t7iyTYGl/RytvRdIXjJmhih9UVheiLkRGjG8CSDBKle2CAjpxNbRm3Q1Hxt1AA2
         Tk/7+2Zy9uaVZrUOwQrCiHUGAkhRxIGAy0XAVM+cpOi8cCsU3/H5p9kHM6+OwN++Xefr
         xJ9I5SfvRRnKAsNdf2bfoDF+XUR2TbHpZH45hW3pJaVUcs8/yqTxeHpHEHI2PYpDBOXH
         9oSiAX7wH3Fc2w52WXCKWvm547JxxZxCSMTv4AYlUDZTfTrvAiR8/NQSYmmlzxOt972j
         PsvA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=FTG5XdsL;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=uXdN5KnI;
       spf=neutral (google.com: 66.111.4.26 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id g5si1425154qvo.25.2019.03.11.18.06.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 18:06:49 -0700 (PDT)
Received-SPF: neutral (google.com: 66.111.4.26 is neither permitted nor denied by best guess record for domain of me@tobin.cc) client-ip=66.111.4.26;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=FTG5XdsL;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=uXdN5KnI;
       spf=neutral (google.com: 66.111.4.26 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 60946226F4;
	Mon, 11 Mar 2019 21:06:49 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute5.internal (MEProxy); Mon, 11 Mar 2019 21:06:49 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tobin.cc; h=date
	:from:to:cc:subject:message-id:references:mime-version
	:content-type:in-reply-to; s=fm2; bh=SKFjXI0K92phygeb6zeAtC318Fs
	cuxRVk6ZzNAcru7Q=; b=FTG5XdsLeuGuBvKBeti0SgcdASf3754kkTOHhi/bBRF
	UOr245JLFX8HDfXZoouLZYIMXdjnSvy6F8UYtZwcS7/wQ508jo7dFkQQULoXitHG
	+ztnzs+RtS0UABYkcN+rR1VaXYcwhDqODdtXbUponza4JJNa8iRkHXiu9S+fVo/X
	6MTAIupieY+N3qniHBWcTmaCiEYLEKD6b4c2Ap7cAPiEmPMqUs061VvwfJqGo3Lk
	y3CVzbR1rcRyJQOcEE2BpUYad4mLBoc7KxH1JoDM3JiT6jgLW3jhFq+PhOhJmg0S
	GhRjFFUulubefDcY60ocenfTB5SkWo9R/4zhJqX1+yA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to:x-me-proxy
	:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=SKFjXI
	0K92phygeb6zeAtC318FscuxRVk6ZzNAcru7Q=; b=uXdN5KnIuWOlNl8kh72Or6
	BHgmlWp4Peo46kypXqnmghVuQQfbx/NWnQkyfMh/KE5wd2xfp+AMUEsyJYMwazc5
	gwZaM2es+vLhg6C470lfcrYMY0GJgtRw6L/sOXCbGCDgET/ebGiEgVLCBrf3+MAI
	axFUPOq/nM+2Kc4yy7r3vwc45rzGH9sh63Zd4tbRom6uSA1n6Fy25Z+UaqTuc+kh
	fIJHbYiBFRW4IvSvLf+5VSSpnF6lN+EhCm2DY+ZnSbTwa8AUP3j9Yp9sn6KO08Tv
	VJq9RLHLpaSYELDd/NobaWHJDT8fShqwaRl7eE3KaXtv9YXwJGlrLT6yvKrREPuQ
	==
X-ME-Sender: <xms:KQaHXIfnxJrjqwCg3PSbjinpiYWs7J4rCtq8Kqt2boohuKL8cLleYA>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddrgeejgddviecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenfg
    hrlhcuvffnffculdduhedmnecujfgurhepfffhvffukfhfgggtuggjofgfsehttdertdfo
    redvnecuhfhrohhmpedfvfhosghinhcuvedrucfjrghrughinhhgfdcuoehmvgesthhosg
    hinhdrtggtqeenucfkphepuddvgedrudeiledrvdefrddukeegnecurfgrrhgrmhepmhgr
    ihhlfhhrohhmpehmvgesthhosghinhdrtggtnecuvehluhhsthgvrhfuihiivgepud
X-ME-Proxy: <xmx:KQaHXAxjY6ihaD8lncdqOw4bPsk4qYLniXvr3_JA0mgBNbYPiIYqyg>
    <xmx:KQaHXG99elukCJtV9P0-X5KSt-WFBQFyjCiLIwvCzncD2qtcRqxgAA>
    <xmx:KQaHXOIFURdASVhkmNBemEHRD9wh8N6XiVkOu9xxT9FsGZ4h_6TvhA>
    <xmx:KQaHXOcGqFYhLHFATFYtl7PwLpoitJe4M4QfFTcRzPcAbPKMrw8BUw>
Received: from localhost (124-169-23-184.dyn.iinet.net.au [124.169.23.184])
	by mail.messagingengine.com (Postfix) with ESMTPA id 768191033A;
	Mon, 11 Mar 2019 21:06:48 -0400 (EDT)
Date: Tue, 12 Mar 2019 12:06:28 +1100
From: "Tobin C. Harding" <me@tobin.cc>
To: Roman Gushchin <guro@fb.com>
Cc: Matthew Wilcox <willy@infradead.org>,
	"Tobin C. Harding" <tobin@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 0/4] mm: Use slab_list list_head instead of lru
Message-ID: <20190312010628.GB9362@eros.localdomain>
References: <20190311010744.5862-1-tobin@kernel.org>
 <20190311204919.GA20002@tower.DHCP.thefacebook.com>
 <20190311231633.GF19508@bombadil.infradead.org>
 <20190312002217.GA31718@tower.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190312002217.GA31718@tower.DHCP.thefacebook.com>
X-Mailer: Mutt 1.11.3 (2019-02-01)
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 12, 2019 at 12:22:23AM +0000, Roman Gushchin wrote:
> On Mon, Mar 11, 2019 at 04:16:33PM -0700, Matthew Wilcox wrote:
> > On Mon, Mar 11, 2019 at 08:49:23PM +0000, Roman Gushchin wrote:
> > > The patchset looks good to me, however I'd add some clarifications
> > > why switching from lru to slab_list is safe.
> > > 
> > > My understanding is that the slab_list fields isn't currently in use,
> > > but it's not that obvious that putting slab_list and next/pages/pobjects
> > > fields into a union is safe (for the slub case).
> > 
> > It's already in a union.
> > 
> > struct page {
> >         union {
> >                 struct {        /* Page cache and anonymous pages */
> >                         struct list_head lru;
> > ...
> >                 struct {        /* slab, slob and slub */
> >                         union {
> >                                 struct list_head slab_list;     /* uses lru */
> >                                 struct {        /* Partial pages */
> >                                         struct page *next;
> > 
> > slab_list and lru are in the same bits.  Once this patch set is in,
> > we can remove the enigmatic 'uses lru' comment that I added.
> 
> Ah, perfect, thanks! Makes total sense then.
> 
> Tobin, can you, please, add a note to the commit message?
> With the note:
> Reviewed-by: Roman Gushchin <guro@fb.com>

Thanks for the review Roman, will add tag to v2.

	Tobin.

