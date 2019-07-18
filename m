Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 31EF0C76195
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 20:38:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0192F2184B
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 20:38:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0192F2184B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AA1896B000A; Thu, 18 Jul 2019 16:37:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A51D48E0003; Thu, 18 Jul 2019 16:37:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 940C48E0001; Thu, 18 Jul 2019 16:37:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f71.google.com (mail-vs1-f71.google.com [209.85.217.71])
	by kanga.kvack.org (Postfix) with ESMTP id 735B66B000A
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 16:37:59 -0400 (EDT)
Received: by mail-vs1-f71.google.com with SMTP id k10so7344268vso.5
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 13:37:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=qMFLEC+KYuc8hLgaovJsIk7Em0POZCTUKP8jS8Cej/c=;
        b=aXig6IHQcl14hD1Mkq5Dz1WP60aazwJqcHPg6mIt/g6Ss1g4IAx6JDYutU2fglgOdw
         jOK66F3r+Im3lnDoEicYO3F0LdlAfWksoBFqcmqARrEwsu+mCA7PaAJiV/JEW10mhhk8
         iW6slAlgjYYXAbUcyaIsGiH7JPJdthJk0ijQi9fSC2AF14hqbPyqoXwurIxXVTipBfSQ
         y/kq6LbzvSqNQg6Ou+MBVjSVjUWry8sTWtW8JU3Rop/folaIjeI9iiuxxWYQToDokw23
         l7qnCclDB6YVARWCEPOnwVyqUrPhydNq0tWK8EPbPLocj8wU+hHs2/MwC+ZdVRNr4PpL
         autA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVkF6f30XXf0tzH0kbwpRMAUvLpTi9yp09L6jxGmqQ4ee6KW80W
	+6uhJtV/hOwoSaf4OdaZyJHBGrc/i/9w66jhGKNB+FY3T28fgHI9fyu/x9+Kq2YUF4TIapvbLnd
	LswlzrhfhZ/p8L7ihibb5UclEJ61TtjmLLCgCQF5G/LrBY04PKouWSXfU6707UuRKaA==
X-Received: by 2002:a67:d590:: with SMTP id m16mr30989312vsj.76.1563482279209;
        Thu, 18 Jul 2019 13:37:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwUKRf4PpBPPlHxETFQ2W7UbsLB37h4SKG6qRT7bfh9tjkXs9BQzC3sNmdPLpn1I21A4sqp
X-Received: by 2002:a67:d590:: with SMTP id m16mr30989274vsj.76.1563482278759;
        Thu, 18 Jul 2019 13:37:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563482278; cv=none;
        d=google.com; s=arc-20160816;
        b=sGn8wq0lut8vzMp7lRQhT+hDpNI2TuKPzTEWH1CHeWR4C2vNM2q8NueKVIyu7ZfFAT
         5G/bsmck/G+x7mJx77yvsl7vCFUKZp0eK17m75cdero1AsxTILFZOH/f2MZoGHqCLsSZ
         GweS4swOTGyOzT582xbfTL94hiF1NJwGRLk0a8KEjrbxp8Ep+sME0oeUwwdISOHYCeZf
         pu9yKifAGHYaiIxIiiv07MejfjI/pGSJUW46TqF9TqJRPGbRGVhNE8IGKQUz4kR2eUvc
         4bpPpY5ewwiY/38j8FT/rih700cTgAMb8a2ZGGCNB9XHtZJjHU/165wh4EIy1Iu8Mdhe
         JQQA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=qMFLEC+KYuc8hLgaovJsIk7Em0POZCTUKP8jS8Cej/c=;
        b=B1cUUf6i8JyUhkX3BoqGCzG6cdadkzGdwwENpdmhuGOQa63C4Jvdtz+DJDQIbqaNM/
         W18g3y0CEYbisDPTT3gLgPwz0QuLzs9iKGeV0CSjrE6MbQVFC9XXfT9nlKOYUa5dJOhO
         9tjcm+aaFInDaoNFqaC5wrdirw0Sf8zr5tWrolmBcTj+yPd+1COuyAuYHV0KlYNkmVpG
         +o6/0o3kDw/5OYnFahPyU4BKwyHVRt2llSP2S9ei2w/Uzv7t1SQz8ZQlwuqnEtTbwG7K
         mD6OPtItN6VjdlmWWQTSqGIiUwC5rp9XgeMxLgLySpuzi89CakeVVVAyzTFhpo1dVW8w
         yKoA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n10si2958397uao.24.2019.07.18.13.37.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 13:37:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E683881F0C;
	Thu, 18 Jul 2019 20:37:57 +0000 (UTC)
Received: from redhat.com (ovpn-120-147.rdu2.redhat.com [10.10.120.147])
	by smtp.corp.redhat.com (Postfix) with SMTP id 7D93B1001B35;
	Thu, 18 Jul 2019 20:37:45 +0000 (UTC)
Date: Thu, 18 Jul 2019 16:37:44 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: Nitesh Narayan Lal <nitesh@redhat.com>, kvm list <kvm@vger.kernel.org>,
	David Hildenbrand <david@redhat.com>,
	Dave Hansen <dave.hansen@intel.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Yang Zhang <yang.zhang.wz@gmail.com>, pagupta@redhat.com,
	Rik van Riel <riel@surriel.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	lcapitulino@redhat.com, wei.w.wang@intel.com,
	Andrea Arcangeli <aarcange@redhat.com>,
	Paolo Bonzini <pbonzini@redhat.com>, dan.j.williams@intel.com,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>
Subject: Re: [PATCH v1 6/6] virtio-balloon: Add support for aerating memory
 via hinting
Message-ID: <20190718163325-mutt-send-email-mst@kernel.org>
References: <20190716115535-mutt-send-email-mst@kernel.org>
 <CAKgT0Ud47-cWu9VnAAD_Q2Fjia5gaWCz_L9HUF6PBhbugv6tCQ@mail.gmail.com>
 <20190716125845-mutt-send-email-mst@kernel.org>
 <CAKgT0UfgPdU1H5ZZ7GL7E=_oZNTzTwZN60Q-+2keBxDgQYODfg@mail.gmail.com>
 <20190717055804-mutt-send-email-mst@kernel.org>
 <CAKgT0Uf4iJxEx+3q_Vo9L1QPuv9PhZUv1=M9UCsn6_qs7rG4aw@mail.gmail.com>
 <20190718003211-mutt-send-email-mst@kernel.org>
 <CAKgT0UfQ3dtfjjm8wnNxX1+Azav6ws9zemH6KYc7RuyvyFo3fQ@mail.gmail.com>
 <20190718113548-mutt-send-email-mst@kernel.org>
 <CAKgT0UeRy2eHKnz4CorefBAG8ro+3h4oFX+z1JY2qRm17fcV8w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKgT0UeRy2eHKnz4CorefBAG8ro+3h4oFX+z1JY2qRm17fcV8w@mail.gmail.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Thu, 18 Jul 2019 20:37:58 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 18, 2019 at 01:29:14PM -0700, Alexander Duyck wrote:
> So one thing that is still an issue then is that my approach would
> only work on the first migration. The problem is the logic I have
> implemented assumes that once we have hinted on a page we don't need
> to do it again. However in order to support migration you would need
> to reset the hinting entirely and start over again after doing a
> migration.

Well with precopy at least it's simple: just clear the
dirty bit, it won't be sent, and then on destination
you get a zero page and later COW on first write.
Right?

With precopy it is tricker as destination waits until it gets
all of memory. I think we could use some trick to
make source pretend it's a zero page, that is cheap to send.

-- 
MST

