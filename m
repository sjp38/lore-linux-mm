Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E6E4DC282C8
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 20:08:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9FA9F214DA
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 20:08:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="JvuLOphC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9FA9F214DA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 389DC8E0004; Mon, 28 Jan 2019 15:08:25 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 339C78E0001; Mon, 28 Jan 2019 15:08:25 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 22BF88E0004; Mon, 28 Jan 2019 15:08:25 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id ECC598E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 15:08:24 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id y27so19292601qkj.21
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 12:08:24 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=9mwZ0QBxPH2S8WD7jA1qNlfu8xYBuTJXO/drTZkzxVE=;
        b=Eq09hnQC4zYB4cgcne4iCAU0UdEtmrN4jHi/0N1wvNnMtf6FCG4lfm9ELWSw5rwlU9
         dqaPFrWW8wZ3tIwqhjFQTNf//pPu6w/K+5fyB3+eDM41l+mEBN8ZoD9DyrsFnbj3jWDl
         lSUxu0jUSgQsfEK4nqcA8ljesAuJhP7WO/wTR7Ai0mqaC2aAPH4ZDUjOo1ho7MwKG4kb
         8BeUXF+mg0ZH6uTODZ4W2E7Doi8edBMkI7rZpdEf9MtYTwPbd94FYSIERQjayLmYVVUX
         hnUnqcUyK7Ja1f34Fnfe6ZQqbXP9oGbjXziu737++jpL8egng+mPpaF/bSZG8P8o4OuQ
         WTHw==
X-Gm-Message-State: AJcUukdgGp8ARbYHN1uhQ+w2tASsjZNiHW+Kq9tR1Ibs+WVnFs8GvGUI
	nN7yyeY6MgjAAuyT5AjnCAW8Gm9KvSauKq8HIStB1Meuid2xgOhp4dyisuk7GrGG/mbLbIvYNrM
	hZrBSvtsHI6I0VONGNiBAURlQ5forLQTpsy26G3Qs7y3HmpJZvnKOaCiFmLy88fs=
X-Received: by 2002:ac8:3879:: with SMTP id r54mr21980317qtb.69.1548706104674;
        Mon, 28 Jan 2019 12:08:24 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4BmsWLy7xtAoSFEuSB9kYP85mqkmUfe3xmetTTCYXZwAvs3eKGONiPCsWp73Yd1lCV55Ny
X-Received: by 2002:ac8:3879:: with SMTP id r54mr21980287qtb.69.1548706104205;
        Mon, 28 Jan 2019 12:08:24 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548706104; cv=none;
        d=google.com; s=arc-20160816;
        b=tQOxVTpY6FTtcq+74CSomzd64AhlUP3dKsQ6EQU6KqxTr7TxG6jHlSB3WKlf8rp8tr
         PShwFf4W2uzpEwbB8C0VVMzE935jc+zBbjGTHGGAcBnPkxY134uJc5EgCYzcxpzKps5W
         FCnJnljtiETpjbcDiG2eMDQhUGFBwIGEJibPEy3v+Nj+7gFKjIIUwcyJt6wXqU/WeAsD
         H0wf/a0mDQJD2YaSzipkX4e7eO8YjTwPDqzQrmnESPRSDckIcbLII2AKAOXz+n0CgHGg
         WH/RbGi1w77ay/wdmRkp4UNxYNzZu9oGuuWFf3dE+f+MGYF3/9LSvgF+Cilvtmc/Ykf7
         iFRw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=9mwZ0QBxPH2S8WD7jA1qNlfu8xYBuTJXO/drTZkzxVE=;
        b=sQGviagN9hllUDbR0EvDuaHkRIkGvN6p6fKMT8djsslmvbVp+kdHRR6uFFz9TITUhZ
         9OA6jbSdVmvcMPnZoMlrp3Vpo8gG2RwAA739hhcNPgNUi/b9KuY2lc/OZNu81ed24bF6
         5juzHUzP+YB6L4DS33rD3LB3n2NRTAS6Y8vqwNbXIYKNNj69K5nMzMXuq3HGQ/ysMEXL
         rD/GRmDKVXW6Pv8PhOVuDjVNwh6ilwoQHjiw9h+c5dY36DaESEjJYDzvLNflLILwsFCe
         7QdbHM3Zz8atqLNRWbzLhEdevTF2ghDiii7HORW5kffUfp7vlbV6FQRTYPjtoFoGkZGC
         RtBw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=JvuLOphC;
       spf=pass (google.com: domain of 010001689613c1b5-6539225d-b74e-4248-8d8f-5b801c1a333b-000000@amazonses.com designates 54.240.9.35 as permitted sender) smtp.mailfrom=010001689613c1b5-6539225d-b74e-4248-8d8f-5b801c1a333b-000000@amazonses.com
Received: from a9-35.smtp-out.amazonses.com (a9-35.smtp-out.amazonses.com. [54.240.9.35])
        by mx.google.com with ESMTPS id l2si1233002qtf.302.2019.01.28.12.08.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 28 Jan 2019 12:08:24 -0800 (PST)
Received-SPF: pass (google.com: domain of 010001689613c1b5-6539225d-b74e-4248-8d8f-5b801c1a333b-000000@amazonses.com designates 54.240.9.35 as permitted sender) client-ip=54.240.9.35;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=JvuLOphC;
       spf=pass (google.com: domain of 010001689613c1b5-6539225d-b74e-4248-8d8f-5b801c1a333b-000000@amazonses.com designates 54.240.9.35 as permitted sender) smtp.mailfrom=010001689613c1b5-6539225d-b74e-4248-8d8f-5b801c1a333b-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug; d=amazonses.com; t=1548706103;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=1NG3+0lQa0q2Lu/ZORmD6juh0aS+X9Cwa2FxEX8RMho=;
	b=JvuLOphCesaanzYNk2yM9XIrCg8OE4Qh4sCo18E9Z0kGk7JsPqj0bkQIJ2M/Ci7n
	ujgpayRrjhDy93POKRUV/LxnIrm6AqQvzzItZPceVL2P9YvWKR5t8S4XLX2Ynw2/a4j
	hFPE9hRjARLr1mq6WcwXquSeFwonhBqoN7teIcz0=
Date: Mon, 28 Jan 2019 20:08:23 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Kees Cook <keescook@chromium.org>
cc: Andrew Morton <akpm@linux-foundation.org>, 
    Matthew Wilcox <willy@infradead.org>, Linux-MM <linux-mm@kvack.org>, 
    LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@surriel.com>, 
    Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, 
    Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
    Kernel Hardening <kernel-hardening@lists.openwall.com>, 
    Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH] mm: Prevent mapping slab pages to userspace
In-Reply-To: <CAGXu5jJkf4pKr0WVUcFitZnnUbq3annautZxzYPC0TQaB5HaGA@mail.gmail.com>
Message-ID: <010001689613c1b5-6539225d-b74e-4248-8d8f-5b801c1a333b-000000@email.amazonses.com>
References: <20190125173827.2658-1-willy@infradead.org> <20190128102055.5b0790549542891c4dca47a3@linux-foundation.org> <CAGXu5jJkf4pKr0WVUcFitZnnUbq3annautZxzYPC0TQaB5HaGA@mail.gmail.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.01.28-54.240.9.35
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 29 Jan 2019, Kees Cook wrote:

> It seems like a fatal condition to me? There's nothing to check that
> such a page wouldn't get freed by the slab while still mapped to
> userspace, right?

Lets just fail the code.  Currently this may work with SLUB. But SLAB and
SLOB overlay fields with mapcount. So you would have a corrupted page
struct if you mapped a slab page to user space.

