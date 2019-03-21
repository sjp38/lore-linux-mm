Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 47367C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 02:24:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E43CD218D3
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 02:24:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="LJBelv/N"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E43CD218D3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7EAA56B0007; Wed, 20 Mar 2019 22:24:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7A4366B0008; Wed, 20 Mar 2019 22:24:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 68BB76B000A; Wed, 20 Mar 2019 22:24:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2C3616B0007
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 22:24:00 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id f12so4455787pgs.2
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 19:24:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=VeDSfNZVcKF/dmMd18yaoimKM6Z0qfa8XNDM5mZkkgM=;
        b=CHn5NF6MxUesoEFQSwf/td7sSScHlw2r+DRSmZrtUGtEGfKxnfOmdnfibrs0dulU5w
         vEiv6W5zTD7bM2z5A99dVcmzuryN7M7Xmf/afZoyQvxlVDwLnGwyYaHDaFkROoS/SiD8
         0KvmsLYtzKTFhcyS+WMVOXT9afE/p/AlWFwIRn+7Mc5c2pOtH0wzHcMVbRhVCPB2xRBU
         US9ta+Gp337+O+9FuPnGX4NJCQP3KDDGJfsHYT0hRVsuxKk3jZHd0uax1fUo3oeo+yzA
         oxVuvOOeTVphHyqEMcq6KB2lYu1mBLfDKfDycFXotul2ZNRpidgdNuITw0kdmxTJ1r0E
         /BpQ==
X-Gm-Message-State: APjAAAX6pYnb8ZNZgoWty2aHZoJ7ko0YLCYAtql+cF3aammCYHD+pItf
	stfaSCt+Fwyh0vwb64oEY7PV/pSoooVkLeJHSWssEhqP5IccMNXi3T8rRuNckSYMKDyfMI7zmg6
	fAERSePMzKVeYvsJbwnnLRU0HWxGcfI/Rg/duvbEiT753HJIGoKLyAtIHAuU6GfnRXg==
X-Received: by 2002:a62:4586:: with SMTP id n6mr1025920pfi.43.1553135039773;
        Wed, 20 Mar 2019 19:23:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwcDy8QuZh63EFlk/dgcFC1OwxwP0WSu1Gsm8IdPQUXT3seVEOPRb5Lp0jNUvC+3SyF1cBO
X-Received: by 2002:a62:4586:: with SMTP id n6mr1025878pfi.43.1553135038889;
        Wed, 20 Mar 2019 19:23:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553135038; cv=none;
        d=google.com; s=arc-20160816;
        b=dUzm/hnb8vhZ1dCBceANZAc3CL6GGqNRiOmkRi+FxEyqBLpTgVYoQG0L3N8fPRJoaN
         h5+7+aITjZxMkjc1s3J83ExsX4UVFyWRgG0Edqaio0CIf8zypacsdwnd+Nusw9ac33v6
         sPVoWVOc0/Z9lay7+VXCs7tHjbgm84l1QTkjPe9j+86d5jqx85i5h8ka9DWHmCAaWIy4
         m9cbeniO4nqfjFKCDKqrJVV6zal6ix6u9Re0uwi15HjsBAMmylHmXz6KF3FLP9Y6Qzbo
         Tcr61vfNLrS/8H2PTPHR7QXW3ISkuOqKNTlYlPpJcLIole3ujKC7Ne+c+MqLYNZ0en0L
         F+ww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=VeDSfNZVcKF/dmMd18yaoimKM6Z0qfa8XNDM5mZkkgM=;
        b=MY8AQ3mKXQTCDgspAI6jfsoEA15FnyidlWO4SeJwAXz0EtFJP97iay5sunxfPIx5Tp
         eGa1cDH+8Mwv9Ql9tt+8MT5s+QG4owWRpScxRMButQFUelCQhnlZYN+FvQauyM4lYvYI
         KLR/bNd6vuHeqbYtb82BH/oHWZynQ3FLUsqOJJxa+mqJz41I0Qi9Db90WuYiyCEpElYL
         6bKonz0wDYl0xHrKJCmRcjgrcfdrcQYDs2bJ229NGFpqubt/SK3SlHTTbpJA0RbEytZh
         6o8f2Ttx94jinByCAd53qMPbjuGA0CvmrKITxJOhls4GZ4NV9dxtbFnLiFgC8RzMyDdM
         9ztQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="LJBelv/N";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a1si2936083pgq.38.2019.03.20.19.23.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 20 Mar 2019 19:23:58 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="LJBelv/N";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=VeDSfNZVcKF/dmMd18yaoimKM6Z0qfa8XNDM5mZkkgM=; b=LJBelv/NWrJP+46sNa0Z0Cxvm
	Wfe6QsPQy3cLQeSqK18OOxmRL4ocKWa1kpssRKzWLWThOItpi0fQsmjWau7ObsaO14iFhD8LvPVDV
	3TNYfRczHJ52/nnWnMukdEvMXIEtu4gnUhE27YHTjnUzWgAbc3g91Np08MiV5f3DdJJg/7auDFG1u
	ut2WxSoDVNcb5g0jaANLgtFLRISck2fV34uP/kQae4h9lG4sjmEHpKQjLiJHWC3ujqf+9kYzJUvjH
	9uz5Uc+Y+3flPehLFAbvQnp4y0pAZQ6VCBal9pnL7jRGOgoLmT5RO/s8XVy+6rJZykRd5DvwXNAE+
	SLUxRCAkg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1h6nN5-0005Us-Vg; Thu, 21 Mar 2019 02:23:55 +0000
Date: Wed, 20 Mar 2019 19:23:55 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Christopher Lameter <cl@linux.com>, linux-mm@kvack.org,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Ming Lei <ming.lei@redhat.com>, Dave Chinner <david@fromorbit.com>,
	"Darrick J . Wong" <darrick.wong@oracle.com>,
	Christoph Hellwig <hch@lst.de>, Michal Hocko <mhocko@kernel.org>,
	linux-kernel@vger.kernel.org, linux-xfs@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org
Subject: Re: [RFC 0/2] guarantee natural alignment for kmalloc()
Message-ID: <20190321022355.GA19508@bombadil.infradead.org>
References: <20190319211108.15495-1-vbabka@suse.cz>
 <01000169988d4e34-b4178f68-c390-472b-b62f-a57a4f459a76-000000@email.amazonses.com>
 <5d7fee9c-1a80-6ac9-ac1d-b1ce05ed27a8@suse.cz>
 <20190320185347.GZ19508@bombadil.infradead.org>
 <b5290e04-6f29-c237-78a7-511821183efe@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b5290e04-6f29-c237-78a7-511821183efe@suse.cz>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 20, 2019 at 10:48:03PM +0100, Vlastimil Babka wrote:
> On 3/20/2019 7:53 PM, Matthew Wilcox wrote:
> > On Wed, Mar 20, 2019 at 09:48:47AM +0100, Vlastimil Babka wrote:
> >> Natural alignment to size is rather well defined, no? Would anyone ever
> >> assume a larger one, for what reason?
> >> It's now where some make assumptions (even unknowingly) for natural
> >> There are two 'odd' sizes 96 and 192, which will keep cacheline size
> >> alignment, would anyone really expect more than 64 bytes?
> > 
> > Presumably 96 will keep being aligned to 32 bytes, as aligning 96 to 64
> > just results in 128-byte allocations.
> 
> Well, looks like that's what happens. This is with SLAB, but the alignment
> calculations should be common: 
> 
> slabinfo - version: 2.1
> # name            <active_objs> <num_objs> <objsize> <objperslab> <pagesperslab> : tunables <limit> <batchcount> <sharedfactor> : slabdata <active_slabs> <num_slabs> <sharedavail>
> kmalloc-96          2611   4896    128   32    1 : tunables  120   60    8 : slabdata    153    153      0
> kmalloc-128         4798   5536    128   32    1 : tunables  120   60    8 : slabdata    173    173      0

Hmm.  On my laptop, I see:

kmalloc-96         28050  35364     96   42    1 : tunables    0    0    0 : slabdata    842    842      0

That'd take me from 842 * 4k pages to 1105 4k pages -- an extra megabyte of
memory.

This is running Debian's 4.19 kernel:

# CONFIG_SLAB is not set
CONFIG_SLUB=y
# CONFIG_SLOB is not set
CONFIG_SLAB_MERGE_DEFAULT=y
CONFIG_SLAB_FREELIST_RANDOM=y
CONFIG_SLAB_FREELIST_HARDENED=y
CONFIG_SLUB_CPU_PARTIAL=y


