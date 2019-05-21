Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B6730C04AAF
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 16:35:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 83C61208C3
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 16:35:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 83C61208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2BD776B0003; Tue, 21 May 2019 12:35:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 26C746B0006; Tue, 21 May 2019 12:35:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 15CEE6B0007; Tue, 21 May 2019 12:35:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id EAEB56B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 12:35:18 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id l20so17826701qtq.21
        for <linux-mm@kvack.org>; Tue, 21 May 2019 09:35:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=pCz9gKqcj+/Dcz8f2gINoX4g8k301BXCGCDjDcUfDUo=;
        b=XlnAK7Q3YHDvK1JbrH9w6OoKC/iSLL38P6+R0fA8ZdwRZRiEJmhEaRmbX0MEHDjE7S
         16UstkF7sV+A83RNhYuXWRPTFzth+DsJ28Bo5p7RFMgmkbSX2f1ROtGdjychwIW5DJdl
         qwxj2KbWFZOjjFjkQXIa4ptWPIdNwlOAAiMcZREPTcG2ddRE3dWPIHe9ZyP6WC3eTaU1
         wIZQOjpE3UeL81DDVJnyZmB8u5V9oJ3nnzqwrBN3coEyI68Zn+ljppjs6N1yU5SC6k5j
         ogxfEI7h3KJBvV+/E6oVT0jTleRxJOVOEG263tLc5BPy5Mm0APLRFcxdt7u1WQzf/d5+
         JUKA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUAoV5tHmURP7rwO0YdOnhi2UghaETTe3ZWEQL1/rxSbHRAUHRu
	3xUHAaHqVWfvAEzcbKzX1mgYjxZ5CEl/MOHyMJ/8EiWlkqW0m8o02fVVJXSpfH00vsgme1qn2rk
	2+hStcf0QPqw8zkU0aozRJTBbO9OYRiotAdhxtzrL9qsDLpm9qmy4qgOMWIPmkf5wXQ==
X-Received: by 2002:ac8:18b8:: with SMTP id s53mr64051158qtj.232.1558456518742;
        Tue, 21 May 2019 09:35:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyLTuKswSdv23dOpAZIBLAjSVGsbRJPOtpmDbkLSq1zS+Bm/tJypD0GWpOdvlan8P3k3M2b
X-Received: by 2002:ac8:18b8:: with SMTP id s53mr64051049qtj.232.1558456517355;
        Tue, 21 May 2019 09:35:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558456517; cv=none;
        d=google.com; s=arc-20160816;
        b=wqweswh2hj9bXV2aC8fE/9qCJ0+sZVcJeKJyzB2AN5WIIVv3u2peiU9i2tZQauNorC
         Vk3f+qIdvV3CdPaj1S7a2S8KV7amEtDo1SxcZ/NuZ3j8qpJiwBmejLoQJEplEZEA1Pjz
         e5PUtHjTqUrbSjEb9lPcv3EmHehjkjiIKS3Np7HLAqZ5OEfbHpOWafzzuzIv6KOhTXki
         IOVCLeSANCLEKAlAgAj2WYJ9iRjWzyAVDf40AYEKmj3M1lPHn8Wt77k+6lK2fTyu+ZMr
         QbjTt2r7d5Rldw37bnlY/F2EhQ9JYKzX3KIxEZhEmqBqAEcFD8Z8UURko4wo3jpm2SEy
         H1Iw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=pCz9gKqcj+/Dcz8f2gINoX4g8k301BXCGCDjDcUfDUo=;
        b=UrWxdHiweqf5AkD6pgB1c4MLQLKf0pPsxlNAUKeVkI4l5nnl0rMIO+DQ46EaBDLgV+
         bc5dQNyoDUphoZxU5NCB3iYoXIIN8jkL0KPs5We1LAdEztzl8U2YO6AfnBhifMhJekCw
         poAwf+QwPvW+gCGuEwzpvCSkDbVj0BfRt2fvRbbRMlekhzSoZac/g5UHKzjTEJOdRQkp
         ogfxAk8HqOng4/41xcazABWVmo1ZCUhGKFxhqzK9X0zcuNJfBd3w6VgvSr0SUhQt2gx8
         0m/YUBDw0tKLLND/q23+efnPQOZXLosh50oVkONaC27ArSxbDpR0utfrRuadICV0N5xy
         LZlg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y16si8025981qty.288.2019.05.21.09.35.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 May 2019 09:35:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9F7A9C057E37;
	Tue, 21 May 2019 16:35:16 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.178])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 2B23559156;
	Tue, 21 May 2019 16:35:16 +0000 (UTC)
Date: Tue, 21 May 2019 12:35:14 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Randy Dunlap <rdunlap@infradead.org>, Linux MM <linux-mm@kvack.org>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: fix Documentation/vm/hmm.rst Sphinx warnings
Message-ID: <20190521163514.GF3836@redhat.com>
References: <c5995359-7c82-4e47-c7be-b58a4dda0953@infradead.org>
 <20190521082118.GC3589@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190521082118.GC3589@rapoport-lnx>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Tue, 21 May 2019 16:35:16 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 21, 2019 at 11:21:18AM +0300, Mike Rapoport wrote:
> On Mon, May 20, 2019 at 02:24:01PM -0700, Randy Dunlap wrote:
> > From: Randy Dunlap <rdunlap@infradead.org>
> > 
> > Fix Sphinx warnings in Documentation/vm/hmm.rst by using "::"
> > notation and inserting a blank line.  Also add a missing ';'.
> > 
> > Documentation/vm/hmm.rst:292: WARNING: Unexpected indentation.
> > Documentation/vm/hmm.rst:300: WARNING: Unexpected indentation.
> > 
> > Fixes: 023a019a9b4e ("mm/hmm: add default fault flags to avoid the need to pre-fill pfns arrays")
> > 
> > Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
> > Cc: Jérôme Glisse <jglisse@redhat.com>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> 
> Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>

Reviewed-by: Jérôme Glisse <jglisse@redhat.com>


> 
> > ---
> >  Documentation/vm/hmm.rst |    8 +++++---
> >  1 file changed, 5 insertions(+), 3 deletions(-)
> > 
> > --- lnx-52-rc1.orig/Documentation/vm/hmm.rst
> > +++ lnx-52-rc1/Documentation/vm/hmm.rst
> > @@ -288,15 +288,17 @@ For instance if the device flags for dev
> >      WRITE (1 << 62)
> > 
> >  Now let say that device driver wants to fault with at least read a range then
> > -it does set:
> > -    range->default_flags = (1 << 63)
> > +it does set::
> > +
> > +    range->default_flags = (1 << 63);
> >      range->pfn_flags_mask = 0;
> > 
> >  and calls hmm_range_fault() as described above. This will fill fault all page
> >  in the range with at least read permission.
> > 
> >  Now let say driver wants to do the same except for one page in the range for
> > -which its want to have write. Now driver set:
> > +which its want to have write. Now driver set::
> > +
> >      range->default_flags = (1 << 63);
> >      range->pfn_flags_mask = (1 << 62);
> >      range->pfns[index_of_write] = (1 << 62);
> > 
> > 
> 
> -- 
> Sincerely yours,
> Mike.
> 

