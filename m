Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C358DC433FF
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 22:21:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 772272173E
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 22:21:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=shipmail.org header.i=@shipmail.org header.b="Js30zXpc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 772272173E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shipmail.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0ED5B6B0007; Thu,  8 Aug 2019 18:21:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 075EE6B0008; Thu,  8 Aug 2019 18:21:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E325B6B000A; Thu,  8 Aug 2019 18:21:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7C7A76B0007
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 18:21:31 -0400 (EDT)
Received: by mail-lf1-f70.google.com with SMTP id i12so2917679lfp.1
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 15:21:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=A+owftgg6ciRMxMAA6PqstMhK9e//nAGDN3c1g//Qyw=;
        b=G2JgFKPIPFPGarIUaQy7NRagulpXRt8ViOsk9HJWPEWkohLnJRETfQZeQhb+gwU8NI
         vKGDGcCX+MbWTYoZ28qqohSLUFnmXTR2RvKHap5wcNyAaATeW9zYQOMGvWnLduXhArt8
         HU9zGRksrSTvToqZVSqhgnf6XxEZywzT/C8CdDcZK+DJdHINx+hdOHggT0MJGMWW8HVH
         GNTx3T+w2TBXwDP72kLg9s9xF+ksY4/pNRNhFquo8nzzRadp6WBmmlhCso4psh1aImID
         z9hbr4AxCiwa/4GoZ42YhjgMZawXnC4QqS++Qg7FxZhANDG0p7XeiNhFWPb+uvxRStgf
         +t0Q==
X-Gm-Message-State: APjAAAWLNpdtGiBJ/ItWe4NSqU9dQghgLR+12LcKk4JukdmkCBD3qeLt
	X65BqF3RskuVDr2OUgWesYxOdBiX4DtIhm18iNUPwHG1tKUcpSShgio/T9TSR4me8JyAx24FvpR
	JjuvEcmLNRKYskYtjHN6bvb5v1NZCk2xYX39q+hxXhCVqRBx5n1ZEkj70lxZFCt2n+Q==
X-Received: by 2002:ac2:46ea:: with SMTP id q10mr10486532lfo.118.1565302890538;
        Thu, 08 Aug 2019 15:21:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyx/xchXWbQPOzjqB9Iy921CroG/OoXnBebPh5sFzBlwHQbEWk1gsBr6IsRtT6wpBdOvt05
X-Received: by 2002:ac2:46ea:: with SMTP id q10mr10486505lfo.118.1565302889738;
        Thu, 08 Aug 2019 15:21:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565302889; cv=none;
        d=google.com; s=arc-20160816;
        b=CSZcLdRJE20GcupRQ6KHnTa+uozKu/+WAzIDJCxVbqgAw63IINSbAA+auwZUd7mf6r
         ytN10x9Iu1YHeWTxTuH/qPO15fgfIUB4FcnO2tvXhKWOOWFUG6zZLkgYU13jk1peLywR
         wU3WULsiDvD96aXLbnWlcdWRXkrpcoEpqYKt7UJUzEZcxCmT89JXNr5n4i4lox15t0gn
         XJbWdoSAhFwhC2HT2VWvYas+Yo1eZy6jP8m2yEM0bDo0GbWv1SHTdXq6FjW7sFRmiJ3l
         Fge1+XoNEvLbmrjNkXVN1aMPaYMLX8MqATCbiyTc4xP4slYFrT2vlWhuSYjQC4LDb5iE
         Qw9g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=A+owftgg6ciRMxMAA6PqstMhK9e//nAGDN3c1g//Qyw=;
        b=zW7pL++UDio1E6Di4zCC+fimnstxwgxrSXpNDX1PlOEFEVTbTg7ifhv2SXZ9vGySAy
         +t4FKEPuut3OhQ1bltpN6luUZQiuwenZTRpcJ3ANLd5wn7rLrifmIKTx9AILNSKJDCrt
         QvZ4+/aSqhdjOdvuEJU8wTbr5tfpFHFoLrMPKEfM42fikYUBT0F6m9M/+JlrB8BOuZHg
         33jvVK/5TV4VkEvw6C4nuM8+hS7u423ZBHYijlJyAcjqsjUY/AFXSwQb2PeX8MlHXuiR
         8fujcS3vj0XxF9yMVczYyUlxcm8gIIxx/fzKtwqsuqGwRSya3ym7D2tTetoCT6llPtUE
         5mDQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass (test mode) header.i=@shipmail.org header.s=mail header.b=Js30zXpc;
       spf=pass (google.com: domain of thomas@shipmail.org designates 79.136.2.40 as permitted sender) smtp.mailfrom=thomas@shipmail.org
Received: from pio-pvt-msa1.bahnhof.se (pio-pvt-msa1.bahnhof.se. [79.136.2.40])
        by mx.google.com with ESMTPS id v10si14542204lfd.54.2019.08.08.15.21.27
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 08 Aug 2019 15:21:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of thomas@shipmail.org designates 79.136.2.40 as permitted sender) client-ip=79.136.2.40;
Authentication-Results: mx.google.com;
       dkim=pass (test mode) header.i=@shipmail.org header.s=mail header.b=Js30zXpc;
       spf=pass (google.com: domain of thomas@shipmail.org designates 79.136.2.40 as permitted sender) smtp.mailfrom=thomas@shipmail.org
Received: from localhost (localhost [127.0.0.1])
	by pio-pvt-msa1.bahnhof.se (Postfix) with ESMTP id C00AF3F3CA;
	Fri,  9 Aug 2019 00:21:27 +0200 (CEST)
Authentication-Results: pio-pvt-msa1.bahnhof.se;
	dkim=pass (1024-bit key; unprotected) header.d=shipmail.org header.i=@shipmail.org header.b="Js30zXpc";
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at bahnhof.se
Received: from pio-pvt-msa1.bahnhof.se ([127.0.0.1])
	by localhost (pio-pvt-msa1.bahnhof.se [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id aL-YyBR6tXjE; Fri,  9 Aug 2019 00:21:26 +0200 (CEST)
Received: from mail1.shipmail.org (h-205-35.A357.priv.bahnhof.se [155.4.205.35])
	(Authenticated sender: mb878879)
	by pio-pvt-msa1.bahnhof.se (Postfix) with ESMTPA id CD18A3F398;
	Fri,  9 Aug 2019 00:21:25 +0200 (CEST)
Received: from localhost.localdomain (h-205-35.A357.priv.bahnhof.se [155.4.205.35])
	by mail1.shipmail.org (Postfix) with ESMTPSA id 16C1136015E;
	Fri,  9 Aug 2019 00:21:25 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=shipmail.org; s=mail;
	t=1565302885; bh=RVaCu1C5tAq3VjSBjXkZ1UBuhKLiLy/Tpb94K/nrtEA=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=Js30zXpcy30+ZBx1NEVIkzvBdlmXRihLBZvVid2tt64zg/qVBCw5XIppSy+A4/doJ
	 S/Q+ly9RkbBXM53IERB8Qzr0uGGHeOvMLz8hKp5L7qJTDmfveaf3yO1s/0j0tOGStZ
	 5qDimRq6xCm3+fuzaPD+XJtHGufRdRJ3+QCW7L9g=
Subject: Re: cleanup the walk_page_range interface
To: Christoph Hellwig <hch@lst.de>,
 Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
 Jerome Glisse <jglisse@redhat.com>, Jason Gunthorpe <jgg@mellanox.com>,
 Steven Price <steven.price@arm.com>, Linux-MM <linux-mm@kvack.org>,
 Linux List Kernel Mailing <linux-kernel@vger.kernel.org>
References: <20190808154240.9384-1-hch@lst.de>
 <CAHk-=wh3jZnD3zaYJpW276WL=N0Vgo4KGW8M2pcFymHthwf0Vg@mail.gmail.com>
 <20190808215632.GA12773@lst.de>
From: Thomas Hellstrom <thomas@shipmail.org>
Message-ID: <c5e7dbac-2d40-60fa-00cc-a275b3aa8373@shipmail.org>
Date: Fri, 9 Aug 2019 00:21:24 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190808215632.GA12773@lst.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/8/19 11:56 PM, Christoph Hellwig wrote:
> On Thu, Aug 08, 2019 at 10:50:37AM -0700, Linus Torvalds wrote:
>>> Note that both Thomas and Steven have series touching this area pending,
>>> and there are a couple consumer in flux too - the hmm tree already
>>> conflicts with this series, and I have potential dma changes on top of
>>> the consumers in Thomas and Steven's series, so we'll probably need a
>>> git tree similar to the hmm one to synchronize these updates.
>> I'd be willing to just merge this now, if that helps. The conversion
>> is mechanical, and my only slight worry would be that at least for my
>> original patch I didn't build-test the (few) non-x86
>> architecture-specific cases. But I did end up looking at them fairly
>> closely  (basically using some grep/sed scripts to see that the
>> conversions I did matched the same patterns). And your changes look
>> like obvious improvements too where any mistake would have been caught
>> by the compiler.
> I did cross compile the s390 and powerpc bits, but I do not have an
> openrisc compiler.
>
>> So I'm not all that worried from a functionality standpoint, and if
>> this will help the next merge window, I'll happily pull now.
> That would help with this series vs the others, but not with the other
> series vs each other.

Although my series doesn't touch the pagewalk code, it rather borrowed 
some concepts from it and used for the apply_to_page_range() interface.

The reason being that the pagewalk code requires the mmap_sem to be held 
(mainly for trans-huge pages and reading the vma->vm_flags if I 
understand the code correctly). That is fine when you scan the vmas of a 
process, but the helpers I wrote need to instead scan all vmas pointing 
into a struct address_space, and taking the mmap_sem for each vma will 
create lock inversion problems.

/Thomas


