Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C79F5C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 17:14:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7B95B2183F
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 17:14:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Tj32NjeP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7B95B2183F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F0B278E0003; Tue, 12 Mar 2019 13:14:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EB8DC8E0002; Tue, 12 Mar 2019 13:14:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D82398E0003; Tue, 12 Mar 2019 13:14:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 995498E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 13:14:30 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 134so3701398pfx.21
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 10:14:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=230SxmBFj0CarYJqxw8BlXT5FM8fCROKpq+2bHkGdlo=;
        b=lbF2Ra54qB2fQlygLOiQuni69iQQmdlUW7YDybwLNAAXHYzyI3zJdt/QT16YknlZwP
         tZ+TueSQMVhGLMJ3OKc6nyvEoBQ1IyfAu1c7MUPhINBeV9uBI0IwAlmGLIEEO6CEmju+
         mYiTF1v8FjqJSLw+smew4IBeJuYPaUE99FJP3akOhpdVd+4paTzbwUwSWb1pcUuZigVp
         BiaC6qUlhhOLGMsgG1RxlbCnU1u/nW1Kca5Cvboid/WTbwBu+H9+NVaBuuw34GJON5zM
         eTHKA5PYzl8WypljRuiZWYwju8vWb9tdwbItpQQywmx9D5ow1GSK4I1QGRGfyXUl7Tai
         IfIA==
X-Gm-Message-State: APjAAAV24fX5VCt6TvLRi2kQl9eI0qLPJo44EqTsFCwGql+8NF0idG/O
	B9OFbqjhj8rNFETrLNRtEi1nxhHzYzKwAI33dG1yvhJf7PAyOzxu9JUlaG8+IBXErxeKbadLYyn
	yFJn65kuDPfLwb7UFvUdfYLd+JgRuk1wY7td1h84u9tupz8dKw1slnyCJAemBWwqYmQ==
X-Received: by 2002:aa7:8186:: with SMTP id g6mr39826897pfi.138.1552410870179;
        Tue, 12 Mar 2019 10:14:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzkd8pVNNCjZ7pPa4REp5u7SDVN0c7+6NF1xWZlUtykCjXQv3R0TWYJPXQQfM2nF9xIoLOR
X-Received: by 2002:aa7:8186:: with SMTP id g6mr39826810pfi.138.1552410869044;
        Tue, 12 Mar 2019 10:14:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552410869; cv=none;
        d=google.com; s=arc-20160816;
        b=Wh8CLBRek1Ez4ghUAEPzxgbARKASbSobnxzFtSCMF6eTQQeI094c29l5/CJHkWfL3C
         YdXWuAFbzNtBNIAXl90x9RWToz1myzzMdYLJk9RjkWUsw7lU5tP3lTL9g2iZe9MJWC9z
         Dj1GlyZCR8TgICrEeFo/k42FTh4poxovaYSK+lwyCp+7JwysfolfdxMuulX719WuZx1A
         Re3Ov7t1qgZo/4HsPVseNiGYLvjODgXcVTWbGS0PZEupXDU1O+TFBQKwDb3Y+LooTlfP
         eZ3cjCGDknc1DTIEvD/W1fSpt4LDcHoxRB5yNzlSkrSgSIZyoXrONlVHAZpJFEZ9jJ6I
         nBIg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=230SxmBFj0CarYJqxw8BlXT5FM8fCROKpq+2bHkGdlo=;
        b=bYHPmo75hPvW9OoLFnVY7KBQ9sOA+v1tIHHHmT4KcthSS8bSVCt8CIlQ/wDLm9pF9h
         Zw+bgKhkpTKeHJ3yfok15p6fyaF/MTnhyOVHB9Wn02AsA3eyk69FEeyqmb6TVERiPIfm
         jg8F6LSrxK1E8QpeXGuu7hJXiaew70gXAODw7Fz+7rYXtxq66/IjKOuWvEdQq3Gp/Pgt
         iHby2WBC8AwB3NMRBf5Qth4fMLd5dJRXK4J88+NSKY5IYWGZ+FwTPlkw0jIY+Cb16d41
         i97gAJpJuM/aAnxqZQe9r8RuRg/h2F2IaKteQurYw7mFZKv80IpG5gzPL+Bk8JpPsCW1
         GjXA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Tj32NjeP;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g186si8446301pfc.58.2019.03.12.10.14.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 12 Mar 2019 10:14:29 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Tj32NjeP;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=230SxmBFj0CarYJqxw8BlXT5FM8fCROKpq+2bHkGdlo=; b=Tj32NjePxjUsmkEjqkLxiHNw1
	Dq2MT3TJlBRfi3Y5NnjBDk0s0EweaLHROW2FkBIoagTnzjZwu+62Z2k4cmXZ6xvKO8tCqVCbwC89M
	O2TZMeFtNgncUjsUqA1sOGxk+SAcb02OrfpORBguPKFKQJ/hAusPAJWA6fW2vYc5q7UcQDbcEmG+S
	9JXb7vu5bfU6tS7C1pdEq2NV91qD7Kfb4ts7F82G3nJzFeoLZZnr4pJuMf9288awplKXHtCxo5dzu
	68dviPy441t94N5Oh+B+hxojBIzgjeJr2PJguSlyYWR8Zs61GC361dQWAHggIPssoaARwY7ZMqZpc
	aSxcGtrsQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1h3kyr-0002MN-ID; Tue, 12 Mar 2019 17:14:21 +0000
Date: Tue, 12 Mar 2019 10:14:21 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Julien Grall <julien.grall@arm.com>
Cc: osstest service owner <osstest-admin@xenproject.org>,
	xen-devel@lists.xenproject.org, Juergen Gross <jgross@suse.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Stefano Stabellini <sstabellini@kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Kees Cook <keescook@chromium.org>, david@redhat.com,
	k.khlebnikov@samsung.com, Julien Freche <jfreche@vmware.com>,
	Nadav Amit <namit@vmware.com>,
	"VMware, Inc." <pv-drivers@vmware.com>, linux-mm@kvack.org
Subject: Re: xen: Can't insert balloon page into VM userspace (WAS Re:
 [Xen-devel] [linux-linus bisection] complete test-arm64-arm64-xl-xsm)
Message-ID: <20190312171421.GJ19508@bombadil.infradead.org>
References: <E1h3Uiq-0002L6-Ij@osstest.test-lab.xenproject.org>
 <80211e70-5f54-9421-8e8f-2a4fc758ce39@arm.com>
 <46118631-61d4-adb6-6ffc-4e7c62ea3da9@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <46118631-61d4-adb6-6ffc-4e7c62ea3da9@arm.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 12, 2019 at 05:05:39PM +0000, Julien Grall wrote:
> On 3/12/19 3:59 PM, Julien Grall wrote:
> > It looks like all the arm test for linus [1] and next [2] tree
> > are now failing. x86 seems to be mostly ok.
> > 
> > The bisector fingered the following commit:
> > 
> > commit 0ee930e6cafa048c1925893d0ca89918b2814f2c
> > Author: Matthew Wilcox <willy@infradead.org>
> > Date:   Tue Mar 5 15:46:06 2019 -0800
> > 
> >      mm/memory.c: prevent mapping typed pages to userspace
> >      Pages which use page_type must never be mapped to userspace as it would
> >      destroy their page type.  Add an explicit check for this instead of
> >      assuming that kernel drivers always get this right.

Oh good, it found a real problem.

> It turns out the problem is because the balloon driver will call
> __SetPageOffline() on allocated page. Therefore the page has a type and
> vm_insert_pages will deny the insertion.
> 
> My knowledge is quite limited in this area. So I am not sure how we can
> solve the problem.
> 
> I would appreciate if someone could provide input of to fix the mapping.

I don't know the balloon driver, so I don't know why it was doing this,
but what it was doing was Wrong and has been since 2014 with:

commit d6d86c0a7f8ddc5b38cf089222cb1d9540762dc2
Author: Konstantin Khlebnikov <k.khlebnikov@samsung.com>
Date:   Thu Oct 9 15:29:27 2014 -0700

    mm/balloon_compaction: redesign ballooned pages management

If ballooned pages are supposed to be mapped into userspace, you can't mark
them as ballooned pages using the mapcount field.

