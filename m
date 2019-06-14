Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9FF0DC31E44
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 11:44:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6306921473
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 11:44:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="RU+fVwU0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6306921473
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EA40D6B000A; Fri, 14 Jun 2019 07:44:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E546C6B000D; Fri, 14 Jun 2019 07:44:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D43966B000E; Fri, 14 Jun 2019 07:44:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9B7716B000A
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 07:44:16 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id a5so1478241pla.3
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 04:44:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=N2usWe+DF5bPKJZPBYT2JLd/gE3UHs5gaod0EYiWn0I=;
        b=YUx3y21fp1hz3CCR/Jbeyset6KDW0AvF9KFOt8Z+fbOZPx/wreMzFreFBn2O37+hwf
         Dn2QTcxmBUkyzQf7buFj7lUeeBGQkpvi8JO0BfEu/xngjNe2bWco1GGAjkKbFHAJ/P0F
         nJuw7a9ALrbdimdqo4N8RO3mGUxobJG8d912CBcyNJRkr+u++YOogF2kWzLIns2iJ8ML
         RL0VN37eKRxfWwtIuvcBAXGXFrYdbZtwvuqP14Io2pgpcRWIXfGePGe0RvMFVUNdY+t/
         B7ToGnfZQPRSvMMKnoPfpp9sHmPEdXfC7ErKiaYYmH1lHumhFS3AHhPncwAjBpIinMXK
         Tssw==
X-Gm-Message-State: APjAAAUy8TResRMIODEeOvYX4HsQylJNmAvagWsYtZxHmSySQqQowfCJ
	FmEvEBG3DwCeQbGxxwWY9X3w9499utaDs3fespt7m8f5RGfd8k5gzFUGt/IA4uieWsQn5pjBZPx
	14qZ+B8lKzWgDx+48ui5YyZHfW7Tj20yoB0GRz2nrDhigYbu94dXjsiCoyzsQOMMMeg==
X-Received: by 2002:a17:902:21:: with SMTP id 30mr91649437pla.302.1560512656189;
        Fri, 14 Jun 2019 04:44:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwBzd6JswbxBCcZQNz8Fm225Q4gAzY8Wqcb1znSsFbGsQF4bIeg6IUxC65sP5dM3JkjOj9R
X-Received: by 2002:a17:902:21:: with SMTP id 30mr91649386pla.302.1560512655440;
        Fri, 14 Jun 2019 04:44:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560512655; cv=none;
        d=google.com; s=arc-20160816;
        b=wLUzCwdWi/ztV3np3tbj8LRgFmn0t8CTOZkSAOxth8mPjlPTvqYi31Si5JT3VokGCy
         +mgWDVglWyRWg3+Mgp1myM63NnazC3Qf8fjGD3c+BcJK2pCGKIDb9pnSEjr09E0zg75Q
         P3NOF+MK0gtM5YPl+6cyeqr0sRtfH5QmdTVbIMtrzbJm0ujjN9t1awZ+fSlcwbKkkRB8
         XDbSaYlO+gBeBl1rBXju0OFbqhnAWtplEqJTkVo3VfwA5glG/20eVqJXAxm2aHSQFrZg
         yEC84f+6AYs1RWjDCDTt68nX9yMYCzp3EAZyyxxBVjVhph4z2hPb86EQOVWk35l8xdji
         ziYA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=N2usWe+DF5bPKJZPBYT2JLd/gE3UHs5gaod0EYiWn0I=;
        b=s90FOjo830eaFwX47xRZXlVJ18RjIVijKuXF2wV9W/DlcIrZkqmej4ms3F56sSLfgs
         UmR+UjR77Pjgdf1cyqVOZ3R11ZAmJLcpGta5u3syq8Wa62Bn/GXT/CnlMQqDoMpwcJbW
         l4FqA2JMkjpjw3WRtEOy/AiOFagc45bXw3/Z6K8BwQjMZtCJgFb8NQjJImuki5tFSzy7
         vbIg8Umd85ISf3IfNNzyQHEBBJ/m0dmw0W7exTZFZ9p9qoywgQRq7T46nucYEsUmr90Z
         JXiS8Wewml7EXt6DtM/gLEXcbKxy1bJ6OZcShuxePdQawnw3b92HTTZo6wcqnoAmU3Lv
         CsJw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=RU+fVwU0;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id k5si2092194plt.355.2019.06.14.04.44.15
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 14 Jun 2019 04:44:15 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=RU+fVwU0;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=N2usWe+DF5bPKJZPBYT2JLd/gE3UHs5gaod0EYiWn0I=; b=RU+fVwU0SYHwiXwH3G6btplv7
	94vsmIFwwr6JKRMHE8Vhsf9s3IPtIBAKx3bYr8fllCl7dNM2KjaU2Ck39tgmbkvDsQj9tLDetB/7k
	n8pTUI9EtYfOM5vyiXCkqsn4+lCUBNvcqBpDENJ/5TSplSzFREpI++eQsfzY3W1GhxU1+D8KK3Csd
	ZdIXoyKpcc3MvU/d1a35GmWl6W15jux52vcYY18wyhJbBn9lte1Zdk9V2ot6MDtwmvqZUVEXBwifJ
	Rsc+A4k4vJUkGYzEbn4jotLhBC2vQkoiOPF6BiRXn6iIMcaaM+IXMl4ahCy7+hlaNyO0xvo6roEMl
	GU/cB+sbg==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hbkcs-0005tV-Fc; Fri, 14 Jun 2019 11:44:11 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id D3C9020A15636; Fri, 14 Jun 2019 13:44:08 +0200 (CEST)
Date: Fri, 14 Jun 2019 13:44:08 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>,
	Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@amacapital.net>,
	David Howells <dhowells@redhat.com>,
	Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Kai Huang <kai.huang@linux.intel.com>,
	Jacob Pan <jacob.jun.pan@linux.intel.com>,
	Alison Schofield <alison.schofield@intel.com>, linux-mm@kvack.org,
	kvm@vger.kernel.org, keyrings@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH, RFC 44/62] x86/mm: Set KeyIDs in encrypted VMAs for MKTME
Message-ID: <20190614114408.GD3436@hirez.programming.kicks-ass.net>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
 <20190508144422.13171-45-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190508144422.13171-45-kirill.shutemov@linux.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 08, 2019 at 05:44:04PM +0300, Kirill A. Shutemov wrote:
> From: Alison Schofield <alison.schofield@intel.com>
> 
> MKTME architecture requires the KeyID to be placed in PTE bits 51:46.
> To create an encrypted VMA, place the KeyID in the upper bits of
> vm_page_prot that matches the position of those PTE bits.
> 
> When the VMA is assigned a KeyID it is always considered a KeyID
> change. The VMA is either going from not encrypted to encrypted,
> or from encrypted with any KeyID to encrypted with any other KeyID.
> To make the change safely, remove the user pages held by the VMA
> and unlink the VMA's anonymous chain.

This does not look like a transformation that preserves content; is
mprotect() still a suitable name?

