Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D6F9FC282C2
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 13:54:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9513721907
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 13:54:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="dTixeQLV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9513721907
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3328D8E002D; Thu,  7 Feb 2019 08:54:43 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2E3B98E0002; Thu,  7 Feb 2019 08:54:43 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 185438E002D; Thu,  7 Feb 2019 08:54:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id C8C4D8E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 08:54:42 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id y2so7501702plr.8
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 05:54:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=MslmhBf6sHBX+lTIZiGv5oF8ktq/q6NsQm5zdWGHpTQ=;
        b=OqZNzNoFBc1q0R20rZWxsq6/P6DUFZJHqG+nev/EKUxlv84LhM7UBmGXmBKU2tY/Y/
         MIDqVc10i7ElrpC2w5Ui1Y+8CpD/dtAf8cSuDQsg4j7rVR7jPyUeAVF2ngn2rWs+t00K
         agjJ265BFj9f4WKXFlHPP8a2VuMWGPgugfRfyjujsur8w8bJ+tgqgeKPTjXd5jZURJp+
         M9n2LMRwcoHPoGRmX4iff9LsOMnpurfcYdzHtVppQqm7e2WJu/txdTtXNSGoNT0aNFC9
         saua+s0wDyIO8MbIoAUqvr1ZO50zqoVZuzW+RzZ6FZ5d/jYIHvqHP66fPLU4OONSCtnu
         AURQ==
X-Gm-Message-State: AHQUAuZpfqJOQs1NH6me4AqYieKEaGblfDUc7G7r19AkY+bzJv3NID3b
	aOHAIknlqoOcL6qyviW1pctMyCJBpfKtZ0cZH8ZGyOfzkqn6nqod2v8kUMbVYYqQlBEXLs382qh
	pVsHPjipE8m2U8DjAjy7BpL7UVLCFqGiwpDv76Uy2fKHhPzHBiVZZ/it/FdZC9WXj+A==
X-Received: by 2002:a62:f5da:: with SMTP id b87mr16505121pfm.253.1549547682458;
        Thu, 07 Feb 2019 05:54:42 -0800 (PST)
X-Google-Smtp-Source: AHgI3IavnqPXH90MgpcdVYE/HqcSNVb557BAGAiImooUcjiztjL2CTmbUfu0aCohKG2HGBznKMsT
X-Received: by 2002:a62:f5da:: with SMTP id b87mr16505081pfm.253.1549547681814;
        Thu, 07 Feb 2019 05:54:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549547681; cv=none;
        d=google.com; s=arc-20160816;
        b=R+IL9a0mSYlhvUUW9gzkrY4jDqKKXX1PfFRnNDCn2YSIykmRF0+2oevvZY33tosYlF
         JPrHG/KwZACCyZVM8Ei0chIO7he7h3uFHTsc8XpjKAHffHE33rJ7CNgBpQSUZX+MUKfb
         UGGYa/j0FBAJ6L+xkryo9KLwQtkObniQxjz2smDhgQHPrhICi4FUsmoEOSPLkAwZf6wj
         w3wmszKs7X2mqG8ji7OF2l0GCd8j/XzIGFHgAO3gfBMbzok6+MCduDkNLbhpHctML5Wx
         GU/zmHnKNtwMw8O1hi9enBrA9JE7Ii5FyfOwXix3CKr4St5OXRHRr3r4+V7bF7JZjY+r
         bJlw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=MslmhBf6sHBX+lTIZiGv5oF8ktq/q6NsQm5zdWGHpTQ=;
        b=AiBBnSfsIoqg/ENwpRXTquHUoo2d5IkCAN/9RWUpLD0lB8KOHpSwgXqvfHux3qP+ON
         21LzQ+qLM+CQJkCnfDTLsoEAhcLtRcNF1xsHvUZQH5dhRsgAlDp9wJMazcLBVPq7S9Vk
         Fazh2D530+DYD15O0E+ELPLtsT03VFb0hfrMvy4iHvXG/XeqgBS/3+FjK9mNamiQNxTk
         6oOaoaz0rYimSPoh9HwoRDQ09s2Ep3r+moAQ4BzNA0WPmKiCsaCayiO1tmHRRl/I96Xe
         yosnzki/ZVjRsMumUQg/Gy8gS2CAUFM5FLxrHLAmkND2CoE4v7ae6sI4baQMCAxecUfR
         er9w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=dTixeQLV;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l8si8534604pgm.250.2019.02.07.05.54.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 07 Feb 2019 05:54:41 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=dTixeQLV;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=MslmhBf6sHBX+lTIZiGv5oF8ktq/q6NsQm5zdWGHpTQ=; b=dTixeQLVu7KVSglvTuT6y6NrB
	rYgagcrHhJjihyiiIkRYAiB55rstLOlgOmT/ytB6+MR4UHv2vN/3TX71ojKEKepM8SM2PM6G+vVRM
	SSi1Bqwl0MYMHTVCwd25Tkg7CkQwvFOQ1e5S8dLp8+Mo2W2npAnkDWxmP00Jx0CmqZmL7ayCGsO5k
	bopYRxg/SUtKwzZ3xaha6RLVrjXS93Tq3k7TytGPy6iLX1acucpccOyvne5HPEFRbNf5FPihb2+bX
	W4dPTweVdsHFZUub8DYpjK75j3A37u79TwYV91pIW4rBFkGuleAtWDlckD64Rgal0bkx4q9IA739A
	2OqF0klUA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1grk7n-0003OL-U6; Thu, 07 Feb 2019 13:53:55 +0000
Date: Thu, 7 Feb 2019 05:53:55 -0800
From: Matthew Wilcox <willy@infradead.org>
To: Christophe Leroy <christophe.leroy@c-s.fr>
Cc: Kees Cook <keescook@chromium.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Mike Rapoport <rppt@linux.ibm.com>, linux-kernel@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org
Subject: Re: [PATCH v3 1/2] mm: add probe_user_read()
Message-ID: <20190207135355.GU21860@bombadil.infradead.org>
References: <39fb6c5a191025378676492e140dc012915ecaeb.1547652372.git.christophe.leroy@c-s.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <39fb6c5a191025378676492e140dc012915ecaeb.1547652372.git.christophe.leroy@c-s.fr>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 16, 2019 at 04:59:27PM +0000, Christophe Leroy wrote:
>  v3: Moved 'Returns:" comment after description.
>      Explained in the commit log why the function is defined static inline
> 
>  v2: Added "Returns:" comment and removed probe_user_address()

The correct spelling is 'Return:', not 'Returns:':

Return values
~~~~~~~~~~~~

The return value, if any, should be described in a dedicated section
named ``Return``.

