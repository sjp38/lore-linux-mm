Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A7BE0C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 23:06:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 61FD820657
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 23:06:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="uwHmDfLq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 61FD820657
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DF2F18E0003; Wed, 31 Jul 2019 19:06:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D7A998E0001; Wed, 31 Jul 2019 19:06:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C1B398E0003; Wed, 31 Jul 2019 19:06:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 899F78E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 19:06:48 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id b18so43822801pgg.8
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 16:06:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=049t7JxvZTTTjSKZ1poKKugPV6OSOy/7hb4LReWg88o=;
        b=fjZ4muedzayDEwysSyq1DlGjgDO3VoARRpQkDeuCOndPW4Au2xWUR5i+w2NCxnUYKi
         51cyF6VOAvnuLgukk6oVgsAuQDM4vprWNNY9W02K8jGS8i1tJodcWqkNXG24IhnN959A
         bLbSinSfmK9JqNKb+V0fgHZ8APoG68rTiHbBUHcHtwyHQL5Ls5FSONj0ro6S0r2tmY13
         Qbh0bMpdjyFe5KKpcX1QelvHoMLT0BH9yazt30Qf8cR2kGsSJTiX/WB9st9U17khEH8I
         ScUoQlFMmg29VmM6iJdSFGzoKIeH5QZmBbO6ONCXLmJ1bDaqQdOSlcRz9zCnn4zbLRqi
         Qy1g==
X-Gm-Message-State: APjAAAVOVlt4reH0QyJYFZ4tO9X90XyzUs3c5idOBtC22op/iKi5j/84
	J2TB5FWZSZB4hX39rAtLVNaIGQ4Xr2YR5tJ+14012tPBl4n8cBCisCoPncr4wGlf7w+5sA9XrMn
	dh5jCrq0QJs0wlPDg6m0bV+aVQjDWysWpXvIKcwWH95ln1Xi3gHe9VrRImwHqA+4bvA==
X-Received: by 2002:a17:902:e287:: with SMTP id cf7mr121830183plb.32.1564614408152;
        Wed, 31 Jul 2019 16:06:48 -0700 (PDT)
X-Received: by 2002:a17:902:e287:: with SMTP id cf7mr121830141plb.32.1564614407514;
        Wed, 31 Jul 2019 16:06:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564614407; cv=none;
        d=google.com; s=arc-20160816;
        b=vHcqnwqy85lUFfSfshrUpSVM78RLH2R8845WcNw+ySdkMTCWfTdImrxLqTqaLdy1LH
         wCoqaun0plZbXUXCuqOGfvS6sznn5E1SJmGi3JKxNaW8yyaolA0Wi6b7DbakNsgB4kbK
         RRvZM7YEIHS9W2ewE3/s0GSIzicqwjKCjNjSLHzb0ed84wZlBLH88hNp43/VZFjcsNQ/
         DSYTvSlIDIjSv6arMUD+Ivgtl2I+vF0Gv4xSR8gIuByvkV/ulIzDAYSMCqv9biIGwSHA
         M3dKsqkn3eY4ngk6tGdA7oeVhnZFD2st8BnbfpRsmFTqYnRBKK/4gRUCymg8RZKLBib6
         9TZw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:date:cc:to:from:subject:message-id:dkim-signature;
        bh=049t7JxvZTTTjSKZ1poKKugPV6OSOy/7hb4LReWg88o=;
        b=mBkkUUyBDJKoTKNgRDagFsHF/8R7j/4Xb/XqwI+4c6ajd3yLfaQacwLl0I7Zg/pFAZ
         klXlgaPUGBO1kb9hVPrOWQUEFWkPpaHuixb4ZtmzpcW3P7tLlCBuYlIUDIu2KDHtttVu
         V3n8KapffSI5mU3Z9S1EsIjOq1Q3Zs9/lKnVVhJ0UZHWpMu8bAymFAz1xKgiConEXCEX
         ScgUhOkpEvgrKKjOucxDuqxiXhWVR72cajrGMukH2ko0mGohWSRRzPqid5M7L+KQi3dw
         lRJPwFHSY8HBqCYOfy0x/kE+mx/7pzYRvHq6PUbXjppc8NnItxj6tI/QnvhUN1V7gfby
         l39g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=uwHmDfLq;
       spf=pass (google.com: domain of rashmica.g@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rashmica.g@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y131sor50881204pfb.27.2019.07.31.16.06.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 16:06:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of rashmica.g@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=uwHmDfLq;
       spf=pass (google.com: domain of rashmica.g@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rashmica.g@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=049t7JxvZTTTjSKZ1poKKugPV6OSOy/7hb4LReWg88o=;
        b=uwHmDfLq0KdRRrIpXBZ7eh2E2Di7CZCsc7Q4ENgQh9pTHk3z1+zjKf7oTZBOymsGIS
         mnqtFBhdLcW/vLb9BKhOsF1r8tKUhH2SZyNqHdaOOW4EhxFLBdByJFXqYtU3rct1sR8x
         DQ4pUSojQb0BZPBAzWpkCE8DfLkjinN+3dMTHyT3vVnRNHra0YbWT/Gfw69nX8iJwdAi
         Lseiy9WWaE54CJg+RUrgeDBd7td8wHWw3TPatkiaa6sOTqPXRZqBLfjOGpLkCJMfxHJm
         RnJ2r6c81O9ZleTk+YaUC2O/dZPpRL18733LECbGGYlK9s72ycaGCqYaL4b1Gc0DEXYt
         w3Ng==
X-Google-Smtp-Source: APXvYqxp2QruKLqLy7023Eu9qytL/7DmpVnAriEavxnn4B49X9D6LXrlXTRhvHAAadOvWaRD1E0HQA==
X-Received: by 2002:a62:f20b:: with SMTP id m11mr50144512pfh.125.1564614407259;
        Wed, 31 Jul 2019 16:06:47 -0700 (PDT)
Received: from rashmica.ozlabs.ibm.com ([122.99.82.10])
        by smtp.googlemail.com with ESMTPSA id p187sm110668968pfg.89.2019.07.31.16.06.43
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 31 Jul 2019 16:06:46 -0700 (PDT)
Message-ID: <4ddee0dd719abd50350f997b8089fa26f6004c0c.camel@gmail.com>
Subject: Re: [PATCH v2 0/5] Allocate memmap from hotadded memory
From: Rashmica Gupta <rashmica.g@gmail.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: Oscar Salvador <osalvador@suse.de>, David Hildenbrand
 <david@redhat.com>,  Andrew Morton <akpm@linux-foundation.org>, Dan
 Williams <dan.j.williams@intel.com>, pasha.tatashin@soleen.com, 
 Jonathan.Cameron@huawei.com, anshuman.khandual@arm.com, Vlastimil Babka
 <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Date: Thu, 01 Aug 2019 09:06:40 +1000
In-Reply-To: <20190731120859.GJ9330@dhcp22.suse.cz>
References: <20190625075227.15193-1-osalvador@suse.de>
	 <2ebfbd36-11bd-9576-e373-2964c458185b@redhat.com>
	 <20190626080249.GA30863@linux>
	 <2750c11a-524d-b248-060c-49e6b3eb8975@redhat.com>
	 <20190626081516.GC30863@linux>
	 <887b902e-063d-a857-d472-f6f69d954378@redhat.com>
	 <9143f64391d11aa0f1988e78be9de7ff56e4b30b.camel@gmail.com>
	 <20190702074806.GA26836@linux>
	 <CAC6rBskRyh5Tj9L-6T4dTgA18H0Y8GsMdC-X5_0Jh1SVfLLYtg@mail.gmail.com>
	 <20190731120859.GJ9330@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2019-07-31 at 14:08 +0200, Michal Hocko wrote:
> On Tue 02-07-19 18:52:01, Rashmica Gupta wrote:
> [...]
> > > 2) Why it was designed, what is the goal of the interface?
> > > 3) When it is supposed to be used?
> > > 
> > > 
> > There is a hardware debugging facility (htm) on some power chips.
> > To use
> > this you need a contiguous portion of memory for the output to be
> > dumped
> > to - and we obviously don't want this memory to be simultaneously
> > used by
> > the kernel.
> 
> How much memory are we talking about here? Just curious.

From what I've seen a couple of GB per node, so maybe 2-10GB total.

