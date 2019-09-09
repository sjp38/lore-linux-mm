Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0DA8CC4740A
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 17:00:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C372A21479
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 17:00:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="bC1iKUUA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C372A21479
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 766726B0008; Mon,  9 Sep 2019 13:00:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 73CB56B000A; Mon,  9 Sep 2019 13:00:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 67A256B000C; Mon,  9 Sep 2019 13:00:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0032.hostedemail.com [216.40.44.32])
	by kanga.kvack.org (Postfix) with ESMTP id 4B9766B0008
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 13:00:40 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id E5C048414
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 17:00:39 +0000 (UTC)
X-FDA: 75915996198.27.wheel80_3fef1aaf86654
X-HE-Tag: wheel80_3fef1aaf86654
X-Filterd-Recvd-Size: 4261
Received: from mail-ed1-f66.google.com (mail-ed1-f66.google.com [209.85.208.66])
	by imf47.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 17:00:39 +0000 (UTC)
Received: by mail-ed1-f66.google.com with SMTP id i1so13641986edv.4
        for <linux-mm@kvack.org>; Mon, 09 Sep 2019 10:00:39 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=ndNymM6S7tmHE+n2EfAPZaAIl9m2k/Hd15vX5tVSFn0=;
        b=bC1iKUUAEbStsWoLLyFmH5e3Rn8L60J3eOAqn15+XFheVcXT1DobBZSZOvDsKrkPto
         BZiYeUcnpJuBt0piDhdzCsqC3hIod7bQagzUG9EjXBu0ESLXWCVV2X7T0c81KPLM1Uf5
         0f7ixvlLeBdwKRO29lKj8JclH/y5G451SsJIj+y1zKjGQqQ4t1XF2xWUTa0iI02AECtm
         UGFfXMsdzSC33aaEpg621gISPu5F5vPOIUSC4aFqzcjw2P7AvkYRRZ7AgQ3ewr5RQp3C
         b5f90jb1+egIK7q+SbO3Y6RqrcCAr280k27p746RhVM2R7SGmgTERnkk1Axx5L/3rZx+
         Tu5w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=ndNymM6S7tmHE+n2EfAPZaAIl9m2k/Hd15vX5tVSFn0=;
        b=RGY9iqTxWxbDz4COc4w4MIMZDB3HeTH+e/8JrCWe1LElNez1tw01fS2WMxjH0WMHOn
         HD02yHYaQ31G7rHXIPw3HVBvdgiocjWdE6nttQ3FVOuZzJQAPEehDkjcKxlT3VLE1tSr
         +t+EPeTrggHsz+zlMNZ4MtnTuKnRVoRtwOqMK9eUEiDw9oV8RFw/ZD0ibrst/ZLl8Ute
         udQZ0RVZJRFCpvgfc9cARxIrh2f8QlohzUGCv3u7OjVbgbKenJuAnF2IuJP0oPnAHvlq
         47RqyRI2F/WotBHoeyAJV2+2+byhQ+qRsj5Vgev1ADXJXFyUXdLIrLfAS97b78ZKYXM3
         +Yew==
X-Gm-Message-State: APjAAAU+hOrlMKiOyhFTNbcdjODmb7dl/EXL5iZ+RDSpYL3eQj15o/tS
	BFPbZk94m2QaKXk63UDi+f/vRg==
X-Google-Smtp-Source: APXvYqwrMgzfqO4cc8VaH4OYBbPyjLCLYVUXkYW0y564TeNoEu15jhrHaKYbf96/6CjMmoqhLR3q1Q==
X-Received: by 2002:a17:906:35c2:: with SMTP id p2mr10087253ejb.241.1568048438153;
        Mon, 09 Sep 2019 10:00:38 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id ot4sm1832093ejb.43.2019.09.09.10.00.37
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Sep 2019 10:00:37 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 4F3861029C4; Mon,  9 Sep 2019 20:00:36 +0300 (+03)
Date: Mon, 9 Sep 2019 20:00:36 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org,
	mst@redhat.com, catalin.marinas@arm.com, david@redhat.com,
	dave.hansen@intel.com, linux-kernel@vger.kernel.org,
	willy@infradead.org, mhocko@kernel.org, linux-mm@kvack.org,
	akpm@linux-foundation.org, will@kernel.org,
	linux-arm-kernel@lists.infradead.org, osalvador@suse.de,
	yang.zhang.wz@gmail.com, pagupta@redhat.com, konrad.wilk@oracle.com,
	nitesh@redhat.com, riel@surriel.com, lcapitulino@redhat.com,
	wei.w.wang@intel.com, aarcange@redhat.com, ying.huang@intel.com,
	pbonzini@redhat.com, dan.j.williams@intel.com,
	fengguang.wu@intel.com, kirill.shutemov@linux.intel.com
Subject: Re: [PATCH v9 2/8] mm: Adjust shuffle code to allow for future
 coalescing
Message-ID: <20190909170036.t3gvjar3qjywjquc@box>
References: <20190907172225.10910.34302.stgit@localhost.localdomain>
 <20190907172520.10910.83100.stgit@localhost.localdomain>
 <20190909094700.bbslsxpuwvxmodal@box>
 <171e0e86cde2012e8bda647c0370e902768ba0b5.camel@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <171e0e86cde2012e8bda647c0370e902768ba0b5.camel@linux.intel.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 09, 2019 at 09:43:00AM -0700, Alexander Duyck wrote:
> I'm not sure I follow what you are saying about the free_area definition.
> It looks like it is a part of the zone structure so I would think it still
> needs to be defined in the header.

Yeah, you are right. I didn't noticed this.

-- 
 Kirill A. Shutemov

