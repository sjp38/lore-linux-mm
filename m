Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8FC98C31E44
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 11:55:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 50DE42133D
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 11:55:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="SxtEFaoe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 50DE42133D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E27216B0269; Fri, 14 Jun 2019 07:55:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DAFB66B026A; Fri, 14 Jun 2019 07:55:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C50776B026B; Fri, 14 Jun 2019 07:55:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8AC696B0269
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 07:55:25 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id b127so1634108pfb.8
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 04:55:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=2Scd2Bpf0fSHqxbPEw6UkC56OpyXzshQKSbLT1BGTuQ=;
        b=W0UCdEtFXFxxY8M+LtVRmXfBjAK8J/MrQkIL2YpRiScPZo3gCDZH6O4RrIh16iZVtk
         GMNRXjzJai9MSqKYghZq+nEsW7VD+P+sLWmNwpK/S9qHDcoCyIsS4+u4OY+vUcnp9WEN
         I4fO/7CJ5AeBXWwUGr3KNTJSfNemMAYqB2cEbddp1UKp77Kcvu9+g/F4vG8GOhDd3PuW
         UKxIyXgZyuPrFhWimO3UlgXqbXHntA9YsZflJbCMAAhUSdl/I9rTeznuZxPymF12UEdn
         ZgslP3VyPBONKA7JHWY6SIF/SGzTC/24hUW5GupdYgjYm9tYkj12NGxZGXZdTOlNjuBC
         x+6w==
X-Gm-Message-State: APjAAAWjlJh8TfyKBCqZOIyVM85LZR3gorEcWzwqdjNQYd9FsGh57SgP
	+Sn4XtZMr9GG+BrAHh/hsNkgeHBUe7flyA/CT8I0U5I2nWVMK3bycIyRyuJ3YAK4D6Aj/cxASwV
	Lkm1DLGxB9NekKWuQ3KefUspZSkfJztS9zvDXpXL6DhmG2ZjodS+QBudThlB1LjRvYw==
X-Received: by 2002:a17:90a:aa0d:: with SMTP id k13mr10214618pjq.53.1560513325153;
        Fri, 14 Jun 2019 04:55:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx7UFdGa4n2seqbgUaPAArTY/D8RMq57u/mAZxbi59aERys5jdA84vFfQIvYHOLL+Qtg+UI
X-Received: by 2002:a17:90a:aa0d:: with SMTP id k13mr10214570pjq.53.1560513324463;
        Fri, 14 Jun 2019 04:55:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560513324; cv=none;
        d=google.com; s=arc-20160816;
        b=igoRoa+f8w+t7/wn0+jAr6y/YU+8EvzPJcWykJPM1PDiO/9baGpiv56YLlmTCpD4+i
         JVuWMYA1QU93m8A4dMMvXEqEUMgQpyiDb7mHao9bMQU5NcPaeBTdrj8J8w6erLAkongF
         dCzYORm0i9kYIqjXjfHwxBqHGin/2+r/YY1RAC+s97n4ntuNmDbIZCGUTH5MjjAxyoFB
         vmHYuhHSG/g7lK4T0Q5vHMKooVOQp5BeRYqA7uIqWZcgvk3cz7hDBOq2Vo5IvGbU+CGY
         vSq4EcoE8L5t4yXvFyRddVnF/prC4/jziornDjWaPwXOmva8jrrW3/JTL3RrQTXlcSn5
         Sr1g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=2Scd2Bpf0fSHqxbPEw6UkC56OpyXzshQKSbLT1BGTuQ=;
        b=gXe5PkBHia+67S+Ov6YazterUVT79CgzVm1zYV740g1JORHpGcXSNYxaZgMvG1qtbU
         GmwGa9wekI7O53ceF60bzSG1enE66jy/Tu2Rk3fCMmvcftOtCj7T0BGCt6EOaCRKPs92
         umIi1wbIIMhI6URMSlp8GQYBEkX2HolmcmVccyQ4iygmkuUxDbdollHfN0qnDUOvk0Z6
         hnq5syhharrPRQ29UyrMAXo/hstrf7wRWw/Lc/Lf+y2FP3pk38aySnijE3+53iMt3n35
         VlC/LABunrZNyv4bPjwdL/nGXFaIAYWspyHNijCc3N1bvF6tQyy/BLoxia6EWpiLghLD
         tPXA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=SxtEFaoe;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g7si2425132pgd.32.2019.06.14.04.55.24
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 14 Jun 2019 04:55:24 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=SxtEFaoe;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=2Scd2Bpf0fSHqxbPEw6UkC56OpyXzshQKSbLT1BGTuQ=; b=SxtEFaoeA/gGdI45bl5WDh0rm
	I8rqVc2P6Ire31B/frJwfn3BZevD8+rTnnPsW81DmL1vcwL3Oroa/WTa+06mMLBfAOMXsESaJhjN9
	a9NGVOQTEB6X4Aegoqbb+TFZ99HagBthuhA9vzvY3S3/iNX7uvOOd7X/pg1x/2Dxmzp8e8uTgxpL9
	81ZTEgZxdLhnxb1L/1gBwZxfkS1ckTGyswxvZA/SieYXCt8MGN1t7v6waleq9Im39RATa/Tn5UiUr
	bFkXoa/Xp8tXJFJ6bva0NaMeh+vFMplN6lhH4kyKzdO9MMzyrWkt7X+2fLBI74i70KerNv8GQjFws
	GHtEJZjzA==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hbknh-0003ZT-QN; Fri, 14 Jun 2019 11:55:21 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 5BB0620A15636; Fri, 14 Jun 2019 13:55:20 +0200 (CEST)
Date: Fri, 14 Jun 2019 13:55:20 +0200
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
Subject: Re: [PATCH, RFC 47/62] mm: Restrict MKTME memory encryption to
 anonymous VMAs
Message-ID: <20190614115520.GH3436@hirez.programming.kicks-ass.net>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
 <20190508144422.13171-48-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190508144422.13171-48-kirill.shutemov@linux.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 08, 2019 at 05:44:07PM +0300, Kirill A. Shutemov wrote:
> From: Alison Schofield <alison.schofield@intel.com>
> 
> Memory encryption is only supported for mappings that are ANONYMOUS.
> Test the VMA's in an encrypt_mprotect() request to make sure they all
> meet that requirement before encrypting any.
> 
> The encrypt_mprotect syscall will return -EINVAL and will not encrypt
> any VMA's if this check fails.
> 
> Signed-off-by: Alison Schofield <alison.schofield@intel.com>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

This should be folded back into the initial implemention, methinks.

