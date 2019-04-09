Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ACD85C10F0E
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 13:37:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7812B2064B
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 13:37:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7812B2064B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 08D686B000E; Tue,  9 Apr 2019 09:37:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 03BE36B0010; Tue,  9 Apr 2019 09:37:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E6FD46B0266; Tue,  9 Apr 2019 09:37:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id C1B756B000E
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 09:37:58 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id v2so14410978qkf.21
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 06:37:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=NrH0wRjSc274UknaC3QIC9X+7Oupxwsgd4xWd2VOIbE=;
        b=SjQxCXMLz6Cx28tK7CZnK1uHHfzVxipZCX/y5pv351BWS0BQDjOURgj/tr2eWK7xUU
         ZClX/LgecfP82oVC3N9On8eWXVLanA1FBRIafgSlqcHtrVnKWzB0Yz5ag0CVaimrZoXB
         fOSQ4IecpBhgV2yIZRFGL9TbECCFxCaYoa+dMxJ0AbClqeLee2+c2pmexHsWO1Y22df6
         4s4uSZQTXKa5JsC0lPze/Um9Gw8zjDHkSUW6OL1MxOoGao4AFoVu8A2B3NH2oyBPs/a6
         31fF1Kxn3NO0lssBt2z6u9U3Va0GRgL+aG313S9nEPUvNRj++uHYYtjktYsUNa7hrcic
         IBpA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUUYmqlIK5RIjozIThWzEJ9AhKQWEOSm0f6ZB8W8Yw8nm8MCaM0
	gOnUrNJXLWLgsvhdg9Ymk2yOPbX1i2vAN4sVWfZtkXdaNZ9xgbxCznK5Pw6nkbarYV+B/e7dJoW
	LD5LsjD2cVjbEA0ocvRv7Vp6bMtujKa9ZiqnT7OKw593NX1tqpfnAyY1c/XE8eSDLbA==
X-Received: by 2002:a37:7c86:: with SMTP id x128mr28871885qkc.124.1554817078595;
        Tue, 09 Apr 2019 06:37:58 -0700 (PDT)
X-Received: by 2002:a37:7c86:: with SMTP id x128mr28871851qkc.124.1554817078144;
        Tue, 09 Apr 2019 06:37:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554817078; cv=none;
        d=google.com; s=arc-20160816;
        b=HlHoS+DIVlDC5DDkO5pSc5zOGuJ84CaRhlkdi2g76zG7dBnoTmMV8ADDOm948ay5tL
         ke4qZS+PuS1P66YQ6qLSOOF2vIFL+tMLWQBYw1Y7szoPWRUvPD8HJMeo6+dlmF3tKTLT
         13qjnqv6R7osuMNkAoSsN8OIL5G0v23FWOWcG+qaU+GQE0ET97JytBeq+y7JcnNALOju
         89ZGtPKWOjUrmisF7IFID7L3daSiXWLBTJLym4Zs7dzXLoTVhGdQAzB23pcusuNILkZz
         TK2lTkC/RBzzdazJkge2P/LgbRzDmw7wYkNI2WjhrGCI9l7pgoqf2fESLgRBtMgCwtDY
         Ib/w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=NrH0wRjSc274UknaC3QIC9X+7Oupxwsgd4xWd2VOIbE=;
        b=RONy/Fm2+x6JddwasqSQDNgxhA1JsTNXEKn9dXfwxX+ltqx/p7AaqT1nJU5cpzLbvl
         XvvqWHDheJuJZQTjgNFQzhQe0KeEl72USUhRqaMCpqyeqOuSP3JXNNgHZ1MU7lRrp6rR
         vO8H2AmUthNyp0JQeA8lP7An4wHoUyxNBRu3IeGB6O6+6EaKO+TxHqFXDXFvLPMU7CL3
         LoUGAbY+mouyjq0rq1XLHjjnJRzAlTTbhHqJjBMnLSVEyusWby5RPQqz2AD6u4FpCtxq
         0lVaGkpT8kcGvAnqFmMFp5Om4JG7tubGPCateKHPm0NsIzBv+OdKWmOf61BFKWcFiy/d
         Z6Zg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f6sor11008450qkd.41.2019.04.09.06.37.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Apr 2019 06:37:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqz0P59G4x2QFXgYvEOPGfKQvp0965gG/JLcggQUBLhwcwZLsi2c+wfUIMH4hZuN9U4Kbzx3ew==
X-Received: by 2002:a05:620a:15e7:: with SMTP id p7mr26856717qkm.283.1554817077928;
        Tue, 09 Apr 2019 06:37:57 -0700 (PDT)
Received: from redhat.com (pool-173-76-246-42.bstnma.fios.verizon.net. [173.76.246.42])
        by smtp.gmail.com with ESMTPSA id v4sm17179402qtq.94.2019.04.09.06.37.56
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 09 Apr 2019 06:37:57 -0700 (PDT)
Date: Tue, 9 Apr 2019 09:37:54 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: David Hildenbrand <david@redhat.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	Nitesh Narayan Lal <nitesh@redhat.com>,
	kvm list <kvm@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-mm <linux-mm@kvack.org>, Paolo Bonzini <pbonzini@redhat.com>,
	lcapitulino@redhat.com, pagupta@redhat.com, wei.w.wang@intel.com,
	Yang Zhang <yang.zhang.wz@gmail.com>,
	Rik van Riel <riel@surriel.com>, dodgen@google.com,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, dhildenb@redhat.com,
	Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: Thoughts on simple scanner approach for free page hinting
Message-ID: <20190409093642-mutt-send-email-mst@kernel.org>
References: <CAKgT0Ue4LufT4q4dLwjqhGRpDbVnucNWhmhwWxbwtytgjxx+Kw@mail.gmail.com>
 <d2413648-8943-4414-708a-9442ab4b9e65@redhat.com>
 <20190409092625-mutt-send-email-mst@kernel.org>
 <43aa1bd2-4aac-5ac4-3bd4-fe1e4a342c79@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <43aa1bd2-4aac-5ac4-3bd4-fe1e4a342c79@redhat.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 09, 2019 at 03:36:08PM +0200, David Hildenbrand wrote:
> On 09.04.19 15:31, Michael S. Tsirkin wrote:
> > On Tue, Apr 09, 2019 at 11:20:36AM +0200, David Hildenbrand wrote:
> >> BTW I like the idea of allocating pages that have already been hinted as
> >> last "choice", allocating pages that have not been hinted yet first.
> > 
> > OK I guess but note this is just a small window during which
> > not all pages have been hinted.
> 
> Yes, good point. It might sound desirable but might be completely
> irrelevant in practice.
> 
> > 
> > So if we actually think this has value then we need
> > to design something that will desist and not drop pages
> > in steady state too.
> 
> By dropping, you mean dropping hints of e.g. MAX_ORDER - 1 or e.g. not
> reporting MAX_ORDER - 3?

I mean the issue is host unmaps the pages from guest right?  That is
what makes hinted pages slower than non-hinted ones.  If we do not want
that to happen for some pages, then either host can defer acting on the
hint, or we can defer hinting.

> -- 
> 
> Thanks,
> 
> David / dhildenb

