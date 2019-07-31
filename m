Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0614AC433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 11:32:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8DAFB206A3
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 11:32:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="YMOvsFC4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8DAFB206A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 043EB8E0003; Wed, 31 Jul 2019 07:32:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F375B8E0001; Wed, 31 Jul 2019 07:32:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E25568E0003; Wed, 31 Jul 2019 07:32:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id AC3868E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 07:32:26 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id u10so37340049plq.21
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 04:32:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=UBmJR5zweJmbyxzgPM4EX3clHHa7sH38d5P57nUcKTc=;
        b=BhoTxMVBHvSmEJLBoQA0JNwbnkUhyp1kFxv1Jg4uoAUAwv8G7nJs7YAZpgDLszTWMH
         73qYw2cku8gZapMIQwuu++nmKfMjckxg77/t2SYF+dpKYwz0nm6auD5KyGi+4SJDEFZp
         e+qQ5IO8Wm1Xy6h00LSWbKmQvcvoZNwrvbdn7D6wRLrPE/2VLtCcfLsFzZ3u102P/YMh
         2OaggTT9b/+XdR/xdelAsj0efblgntTbJdhh2vXQ034FPZkd/hd5OkQPaQNplE8IlF7Q
         Hm+XviXhXxf9jZBGjVrGLW7Qed7fumcFHxk7R+nKiIFQRdnZVv6ZSq9gO/hw0j5iXv6g
         NfBg==
X-Gm-Message-State: APjAAAXwCu64VPizE5739GBlgAfx3/Jv2vHFvm/3SJBAORlMKrqQBmvk
	g0FM/BzAtwrUyzpozU0wzPahRTpmPWvjsEFkCyQN7TEs97+VgLnwHzollbhLoSPRKHXHFR6kvi0
	MXrjheqmmHDntBZ+OVbGrymnolQ776aixGwHvgw9iH/ux/moNKTTYSFRvdwOT4llY4Q==
X-Received: by 2002:a17:90b:8c8:: with SMTP id ds8mr2546718pjb.89.1564572746204;
        Wed, 31 Jul 2019 04:32:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwC4qKQEAjG3EWTKk5jTK+aSFfEqXsYEapGS5V/wb+ffbESb7kq1wjertojmBtZO6ISS1Qi
X-Received: by 2002:a17:90b:8c8:: with SMTP id ds8mr2546656pjb.89.1564572745452;
        Wed, 31 Jul 2019 04:32:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564572745; cv=none;
        d=google.com; s=arc-20160816;
        b=XdvlCZ94Q3iCm6N0OoL19l25s+rMmwj5WgFaQF8CMYHUDhEs1AfIF6oasEhUeI8vfe
         yuOMXN0kfApTcll+g0H2u5Tb/cOry8UKyasYtnX9+FUTd5Xf6BipFwYSxyDduzomjjwn
         +/aheJiJdyzkLQAzdOpNHsVi8kJjl+h9koZqbTuzosovkueiVMzQOmeeyR+eR0H2A1ru
         GOaQBsn7xMzCN1liTrZbir1r4YPIHsDle75yMRlrBaOCjSCCBrMyZdwUFP9EsaR+Ug6Y
         PurflUVSyOKzFADHi+OFAxggjN7SH5VZKxKVQuaJklGdNTrFTWS/MUPh9Ki7/wrcxDrp
         z6FA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=UBmJR5zweJmbyxzgPM4EX3clHHa7sH38d5P57nUcKTc=;
        b=LSWVkN9VLVlq1SYstHkwJg2H/ZBg9Q3T16AqQy6AESUlEqtx/NA6NUH92LQKqjYx6t
         5Olu5swA/OEVlk5FzEHwpcw+10aaW4AC+GogBXythx3kZ8HtsU3IDOZfzjYrwkjLqlNx
         mzHixiCBR5W+cxNv9Ocmp87QtC4EHOWLeVGad+qpqTqVL7CtdtyIWbeax5nr1/g5JtIu
         zzerhICgRn+1Pm4yQxEU9MA7gp3/7RdIdjoN4jwbPwnKfzMi5umv6NJFZ0VgPrV+nf7z
         hm6cVtL0uVbrWedeKx3LI+yrVn/j/97rN7JFm6NJ1fv6OHJy7h+vFzdCIKqhL2tyQG0x
         4pxQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=YMOvsFC4;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id x25si32996539pfn.13.2019.07.31.04.32.24
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 31 Jul 2019 04:32:24 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=YMOvsFC4;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=UBmJR5zweJmbyxzgPM4EX3clHHa7sH38d5P57nUcKTc=; b=YMOvsFC4AP/jXLYB3P4JjOlOq
	wkafVCBzpXR/1dsglZwKBYrDvkk0nQCHFOsIEJwJt8ECIgcRv20gyK4w0yfv1zKR2MUnIXp/eiwAc
	A578VmoZuy99oHmsTorQc5DxjM+GxHfElwrIOyV8KSETO1bc7Fu//KDuJyqWQpsgWtk0pusToFZl5
	PCMIvccTiP+xc6WLSWwCTk1XlnzrlhjC7xxByj+65xatNSj5KLh8Gb3cCXlhpz4o3X3RfMK2GFp3U
	4RlVbA53/IfbkZ0+HE8B8dH5VYcITL3YJRZzWhR0YbrHzYBjZjZosaAoaGCGqA8aJgwCJBOArUxP5
	OGx+lYw9w==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hsmqD-0005hK-DX; Wed, 31 Jul 2019 11:32:21 +0000
Date: Wed, 31 Jul 2019 04:32:21 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Dave Chinner <david@fromorbit.com>
Cc: William Kucharski <william.kucharski@oracle.com>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Song Liu <songliubraving@fb.com>,
	Bob Kasten <robert.a.kasten@intel.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Chad Mynhier <chad.mynhier@oracle.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Johannes Weiner <jweiner@fb.com>
Subject: Re: [PATCH v3 0/2] mm,thp: Add filemap_huge_fault() for THP
Message-ID: <20190731113221.GE4700@bombadil.infradead.org>
References: <20190731082513.16957-1-william.kucharski@oracle.com>
 <20190731102053.GZ7689@dread.disaster.area>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190731102053.GZ7689@dread.disaster.area>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 31, 2019 at 08:20:53PM +1000, Dave Chinner wrote:
> On Wed, Jul 31, 2019 at 02:25:11AM -0600, William Kucharski wrote:
> > This set of patches is the first step towards a mechanism for automatically
> > mapping read-only text areas of appropriate size and alignment to THPs
> > whenever possible.
> > 
> > For now, the central routine, filemap_huge_fault(), amd various support
> > routines are only included if the experimental kernel configuration option
> > 
> > 	RO_EXEC_FILEMAP_HUGE_FAULT_THP
> > 
> > is enabled.
> > 
> > This is because filemap_huge_fault() is dependent upon the
> > address_space_operations vector readpage() pointing to a routine that will
> > read and fill an entire large page at a time without poulluting the page
> > cache with PAGESIZE entries
> 
> How is the readpage code supposed to stuff a THP page into a bio?
> 
> i.e. Do bio's support huge pages, and if not, what is needed to
> stuff a huge page in a bio chain?

I believe that the current BIO code (after Ming Lei's multipage patches
from late last year / earlier this year) is capable of handling a
PMD-sized page.

> Once you can answer that question, you should be able to easily
> convert the iomap_readpage/iomap_readpage_actor code to support THP
> pages without having to care about much else as iomap_readpage()
> is already coded in a way that will iterate IO over the entire THP
> for you....

Christoph drafted a patch which illustrates the changes needed to the
iomap code.  The biggest problem is:

struct iomap_page {
        atomic_t                read_count;
        atomic_t                write_count;
        DECLARE_BITMAP(uptodate, PAGE_SIZE / 512);
};

All of a sudden that needs to go from a single unsigned long bitmap (or
two on 64kB page size machines) to 512 bytes on x86 and even larger on,
eg, POWER.

It's egregious because no sane filesystem is going to fragment a PMD
sized page into that number of discontiguous blocks, so we never need
to allocate the 520 byte data structure this suddenly becomes.  It'd be
nice to have a more efficient data structure (maybe that tracks uptodate
by extent instead of by individual sector?)  But I don't understand the
iomap layer at all, and I never understood buggerheads, so I don't have
a useful contribution here.

