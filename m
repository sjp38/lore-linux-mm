Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4DBE5C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 15:31:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 128C12082C
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 15:31:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="rrUSOFkA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 128C12082C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A420E6B0006; Thu, 13 Jun 2019 11:31:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9F30A6B0008; Thu, 13 Jun 2019 11:31:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8BAC06B000C; Thu, 13 Jun 2019 11:31:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 575DE6B0006
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 11:31:46 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id y7so14718171pfy.9
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 08:31:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=f/0g5Z9NCQMhWfThA5zJkOmPa2ERnbPBpaXYsJjVOvs=;
        b=SIxj40onkaJrRjfpVk/iIR1vU15PUqe4DxpGTjmv6oJHHBlz3pPaWQOmhC4XF7bdcW
         K9pfwJxFeBI57jAIDpFT489TF1KfQ6qeZbyYnPQD2nH4+GpLO++/SbWKqHxgv2ltYDsW
         gYkX7Riv2HeEW0qBDZEkholxVh5tg+JC8gw03KAmDg6Mh2lKIjl1osZrW+3pqfrZuVxM
         p0nABYf/97tCDDikf8YOFejwG/jnuPEweMtYJgutvaejIAAZX5fP1DslLdfcaKBV5Mhf
         0JJ2krKJ+25/plBrEcB4xxBCJoH+zsCW6ycOXO2R/GhDJfCGotlNFXq5tNMZNRxkAP10
         /VNw==
X-Gm-Message-State: APjAAAX/QwlglKx0xWZ900lheO9fwGucdZEKwfHQvsc+9ilU2yZ6p4Sw
	hojX4eLDfy/NEoVYs/757DSICwCIJl168mp/x8EDfiAicL0iKJSC/zpn6JD6wbzj8tEQA7Xc0Km
	Rzb4GHQ8xK2bThSxL+GSkISjQL47cbXmIj995zwvMkhSgLah8yJ1OI9DyjhbsnqogCA==
X-Received: by 2002:a17:90a:950d:: with SMTP id t13mr6145652pjo.81.1560439906050;
        Thu, 13 Jun 2019 08:31:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqygVS2zV9hSFw6rVGw0S95lJ9r4oznh2rQ5sKW2sm2EjQ/0hkLJbSR61dl2JV8obShwdDCZ
X-Received: by 2002:a17:90a:950d:: with SMTP id t13mr6145609pjo.81.1560439905389;
        Thu, 13 Jun 2019 08:31:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560439905; cv=none;
        d=google.com; s=arc-20160816;
        b=R49FuD08FUg1CuB1IBT92sC6l7F7DbBlQBLEILRqq554F3x66chxxP5QGHa1O2Aq1Q
         f9aNyZdV1eq8ayEvtzIiqlgo1y2Gzreue9jmn5nn+JRJJ7Z9HWwJyokrCWAAiyzmmHMp
         ZKZOj8pOMir/CJksbzLrD19gCc9UgBAcNoYGsQD77jSRLti3+R4tdvXYmpqlu3ExTdR5
         FRx8akxAVf5s+y4so/Z1YOKhMjJAABy7yTl16vEpxAKmHPA5fw2sZUf8eNcOY2KNPfPJ
         wo00gtcuBDHSWKEIE29P3hoJRfsyCtHfXi6vBcBy96H5+Y30YXx2e6fKB13N3k1pCFgc
         RDww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=f/0g5Z9NCQMhWfThA5zJkOmPa2ERnbPBpaXYsJjVOvs=;
        b=QttVkhiSZBaSDkaKCxNWJJ141NJardkvCfrbW4M500zlaILNKeCzweB3Sh8EM8wPF4
         /CV5V20I+vH9ydnv0QU/Hxk2AKN6oc3Kfn8IMY/x59ayCy8fL1juAfnTe5gpjZEywepq
         idlOgTfJA8eTDr8AuYANwED0MNaY9wX8chbto1AYSgom+xQvOz9LHBjl+c0GzWbOt5ZC
         xIXl8NQ3BOiz2aMlWomI5MC+1vrdPC2jGf6Oui0YJg5ECp7JZBGJIWv+kh4itlY+EcZo
         bfYAbcR7fz20SFojOr+qlgevlO/u1kfy8bsqwZu05PNdCat8ujJts0HZ9gB+8/GdBzOO
         tseQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=rrUSOFkA;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b4si3585331pfg.49.2019.06.13.08.31.45
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 13 Jun 2019 08:31:45 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=rrUSOFkA;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=f/0g5Z9NCQMhWfThA5zJkOmPa2ERnbPBpaXYsJjVOvs=; b=rrUSOFkA3S2in8Oua2Q2eIa5p
	6vhNTVYFFi/ghkWdgxaCW0yJp0jbeyCulDj+Nn+PUaRBMr5xamODS2KwatiQV94wvOAyx3eXbN6Rj
	ZaMWu1gO/mRtKncIIT45SX0x4ifL7b7W4wWa2kRkcN7oTJOm9FZC+sTjzvQd8JBYwByl1A9YcXAjq
	GKTcXlQklPDdbSO1giVKuIfu+HyxDIQrX5SnMNAMSj+2u5vnKQEW315RLfzh/6t++MYIPh6MSCFgf
	+Ka/ICJfh2gvI3eTBnvav7r2GMPVXweED7fJ9HpNfXBNOmkAlYDQTI+7/2WorUMzc4iZYm08fcm32
	9mXFyZ4ig==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hbRhW-0004n9-0S; Thu, 13 Jun 2019 15:31:42 +0000
Date: Thu, 13 Jun 2019 08:31:41 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Roman Penyaev <rpenyaev@suse.de>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Rick Edgecombe <rick.p.edgecombe@intel.com>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Mike Rapoport <rppt@linux.ibm.com>, Roman Gushchin <guro@fb.com>,
	Michal Hocko <mhocko@suse.com>,
	"Uladzislau Rezki (Sony)" <urezki@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/vmalloc: Check absolute error return from
 vmap_[p4d|pud|pmd|pte]_range()
Message-ID: <20190613153141.GJ32656@bombadil.infradead.org>
References: <1560413551-17460-1-git-send-email-anshuman.khandual@arm.com>
 <7cc6a46c50c2008bfb968c5e48af5a49@suse.de>
 <406afc57-5a77-a77c-7f71-df1e6837dae1@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <406afc57-5a77-a77c-7f71-df1e6837dae1@arm.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 08:51:17PM +0530, Anshuman Khandual wrote:
> acceptable ? What we have currently is wrong where vmap_pmd_range() could
> just wrap EBUSY as ENOMEM and send up the call chain.

It's not wrong.  We do it in lots of places.  Unless there's a caller
which really needs to know the difference, it's often better than
returning the "real error".

