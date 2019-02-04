Return-Path: <SRS0=bR/Z=QL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5C35CC282C4
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 16:12:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1AD61205C9
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 16:12:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="IIH8Libj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1AD61205C9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9F1B88E0049; Mon,  4 Feb 2019 11:12:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9A0E98E001C; Mon,  4 Feb 2019 11:12:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8B7DA8E0049; Mon,  4 Feb 2019 11:12:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 46EBC8E001C
	for <linux-mm@kvack.org>; Mon,  4 Feb 2019 11:12:06 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id d18so252576pfe.0
        for <linux-mm@kvack.org>; Mon, 04 Feb 2019 08:12:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=oFN+KQoRP/AZ1fMH9/ahgnepZfE4l2bgG1MGqmiAXis=;
        b=FesMos5vHk+/UGTrzeN1igpbRRbfZoKvZYuuKEE6fkA9oZQC7wE4S6mrsNouiCVLwd
         ozIuxOEe1AvheFZtBsO2h7JFqOYXR+1nuKcm/PRWBeoSdQUQxZUrA6aLAMlAEUN0avoC
         n2D4jn4kkUELDlb4ZKmlUUyHFeRQer2r7wI5c4xz518PgqCBpsC43ibS59cYNfu7KHSW
         m798ynUQBnCsCxaoDLpsr9eljVBfyllTkDe28TZ9ctPwTbxrdW2ne7tVjK7bqab665sa
         AlzzIvS+D2Eme3H2AAmHeyATfWzlBP8XwC86kevYvtskYzHnn3aNwFLugSvnwM+wbQU1
         ZhLw==
X-Gm-Message-State: AHQUAublaZ8e+iBPMF34DbiTaMUjpNBV4HivB4Ze9DkNdoGxr0an7+OK
	cNHkVTRB1KSBWpIS1TM97CQTFmOAUy7txEnYp579C6VLpEioCfrFfttYcpihruxBEEo+0wXOJFJ
	4aY5y0m0EhTcYAzpndTOaBm5N3BixdUGc6gKZfVmNNocIv7zTwbERqlaSEpe9rqbfQA==
X-Received: by 2002:a63:e051:: with SMTP id n17mr133672pgj.258.1549296725930;
        Mon, 04 Feb 2019 08:12:05 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbcR6rAAYXBk5F0gpqk/gjVo3r7jwrdSdVZTrT0OBjMjUPQgC6Ufhn8cbNzY4k0ZsxZRYXG
X-Received: by 2002:a63:e051:: with SMTP id n17mr133604pgj.258.1549296725143;
        Mon, 04 Feb 2019 08:12:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549296725; cv=none;
        d=google.com; s=arc-20160816;
        b=1CeP4j/Xn5RpHenlEI301DW+6hXL+JaC5l5Km2Oiut6F6LrWpjCU/n/vpXcJWl4tct
         YREois/3w++Pu3FjTe6ddjgyH5w8MaYvjDQnhUagTbhqTq58GOqimiWpbkguomFe0KD3
         h2Q4HvCBPRwH8WEEiqqK2EyIWu1SrqNYq+KAIoRFsv9HdB9OBjPjmC1HK2v+BN14JRE5
         i/5SCs1/orWKXbuuQht60qKJq2/EPgpD8qCLNPRsI1TWAZv9Vy7IuwjwtVBr+1EXTrOD
         TUv+4JZ9aM1pY2wzOHUBrfXnAVV64FMRj1zPE/PGtf1lQ7/cuRPD+UEN3KKq8eRj4rQE
         NRmA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=oFN+KQoRP/AZ1fMH9/ahgnepZfE4l2bgG1MGqmiAXis=;
        b=ezqaebUl2jqzPbUv8gEzNP/VJywBZeDcLdZwCa60UusWnCcolnJxV9saU4EiTJaeb5
         6wAXcs5+i+LADTuO65frOvyitheduvyR5MFjxDCAy11xoVwpR+aVhy+jFVMKpCSL/9Br
         sLaNwB1tGk7ZOyQ6LlSOGdoqRyeLYaOPAsZWT2ntrzokIwNTeu3I4Ee10Ez+d+L2KYVL
         kaqV+u0BI0Ww/1WObhjwuMnhj3uz/THCRuoc6a6swxYRPmnrgyD9NfKHmDxDDHZuQAkO
         tokbTt2KHXomT41C4o/mr/d5Jbq7E7MiuwG3d9GCqbBC7fT3bxuamBMVDz5MOuXHnysh
         EMPw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=IIH8Libj;
       spf=pass (google.com: best guess record for domain of batv+4d538b5499ac5f299814+5643+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+4d538b5499ac5f299814+5643+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id h10si363823pgp.4.2019.02.04.08.12.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 04 Feb 2019 08:12:05 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of batv+4d538b5499ac5f299814+5643+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=IIH8Libj;
       spf=pass (google.com: best guess record for domain of batv+4d538b5499ac5f299814+5643+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+4d538b5499ac5f299814+5643+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=oFN+KQoRP/AZ1fMH9/ahgnepZfE4l2bgG1MGqmiAXis=; b=IIH8LibjpIBarmSURFAhpGGHO
	6jYB4GH/OrYb9bjQOV28kRqaV6jviv7pI2JsEQkNq5Im+9xjCZSveKgs6GrOHfZzOr1/P43ErwTbY
	qOecBn0wKyQUfSn6ZzCiVF76G4UcuU1P5zYtisBhgJMcHcILQwUuVd54UkZm/uug0wIpRdDcySrbk
	HOARpCDt5dxiOqD7Awl+Y5kwvZwZQhuPkX7NUjT7pNTbk8bzFRA7FJ0KgOFYJIcDoh27sWeHUeuf2
	cmfW6x/FNFlkLG8XNrxLiN1O9frNiXmpaAFsSkg6uf3THD8RCKMPXagf4+CMDyz0bYlS3cel/Crh1
	AjXfAJ9ow==;
Received: from hch by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gqgqn-0003SS-Di; Mon, 04 Feb 2019 16:12:01 +0000
Date: Mon, 4 Feb 2019 08:12:01 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Christopher Lameter <cl@linux.com>
Cc: john.hubbard@gmail.com, Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org, Al Viro <viro@zeniv.linux.org.uk>,
	Christian Benvenuti <benve@cisco.com>,
	Christoph Hellwig <hch@infradead.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Doug Ledford <dledford@redhat.com>, Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>,
	Matthew Wilcox <willy@infradead.org>,
	Michal Hocko <mhocko@kernel.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Ralph Campbell <rcampbell@nvidia.com>, Tom Talpey <tom@talpey.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH 0/6] RFC v2: mm: gup/dma tracking
Message-ID: <20190204161201.GA6840@infradead.org>
References: <20190204052135.25784-1-jhubbard@nvidia.com>
 <01000168b94439c0-28d5e096-718d-4e39-a7af-20d0a6d7b768-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <01000168b94439c0-28d5e096-718d-4e39-a7af-20d0a6d7b768-000000@email.amazonses.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 04, 2019 at 04:08:02PM +0000, Christopher Lameter wrote:
> It may be worth noting a couple of times in this text that this was
> designed for anonymous memory and that such use is/was ok. We are talking
> about a use case here using mmapped access with a regular filesystem that
> was not initially intended. The mmapping of from the hugepages filesystem
> is special in that it is not a device that is actually writing things
> back.
> 
> Any use with a filesystem that actually writes data back to a medium
> is something that is broken.

Saying it was not intended seems rather odd, as it was supported
since day 0 and people made use of it.

