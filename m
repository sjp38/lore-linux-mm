Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B154AC3A5A2
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 09:31:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7185B20872
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 09:31:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="SSNNjgPQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7185B20872
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 14C116B0003; Tue, 10 Sep 2019 05:31:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 123776B0007; Tue, 10 Sep 2019 05:31:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0121F6B0008; Tue, 10 Sep 2019 05:31:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0029.hostedemail.com [216.40.44.29])
	by kanga.kvack.org (Postfix) with ESMTP id D307C6B0003
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 05:31:05 -0400 (EDT)
Received: from smtpin20.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 8C81252D2
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 09:31:05 +0000 (UTC)
X-FDA: 75918492090.20.car30_7ddfafc61ea41
X-HE-Tag: car30_7ddfafc61ea41
X-Filterd-Recvd-Size: 5206
Received: from mail-ed1-f65.google.com (mail-ed1-f65.google.com [209.85.208.65])
	by imf46.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 09:31:04 +0000 (UTC)
Received: by mail-ed1-f65.google.com with SMTP id i1so16429299edv.4
        for <linux-mm@kvack.org>; Tue, 10 Sep 2019 02:31:04 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=nPUEYX1NKslohD2E+roi3GND2/I3OUXfvQ3XAcK+/GA=;
        b=SSNNjgPQ1LSHIFhAfZd4y0wYr0+CC4ozBTywesC/p7SttOr6N2R7mXpSTeUG7e5Asp
         r8Y/5rQ+0c4hRlG2zqaksGhlUOxOHvFvcWaPcfWbBQRLfk9F4xEpKsfnIlW6rWvwKohN
         RNGw0IM/rKcv+cvba+nXEbQz0fbZXP6AHWb68cHXdh8ePHUYqx+2OqRBCekHgvlyW+Sw
         P8Vkg+ZokeeLku2jJcT4X/bYAzCp+7R5R7yHqtsOA3sn6/NIShlu4GVTrZyZ9adTF5QC
         J0N4aHa7o44cenXBoTu5Me3EkOwY3YbZwKPp5kN8YgRpX8rQ34t4N+SuVkQb/4NR5Mgv
         w3HA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=nPUEYX1NKslohD2E+roi3GND2/I3OUXfvQ3XAcK+/GA=;
        b=QWm2s7K0RY5KBIFNeNMKcKrI8bMuXp29IReA/ze7Rhk1+NIFedQc6wyhPdIs/qaLsb
         fo6RMTaHNbFNn/5282J4vUmOEnFws1c4s8rMDF5h6HdYp1zfU5jvqY84qdkEWnqzz71t
         wNFZA8nRH/uYazq5xS/odAmDzLqIXqLH/uBLxkqgq2M7jHZCDFx7XsJy6QR0eNALI3hD
         MFZP2dCnPQCUiQNV7k/tCnYXSE9GrOoDgjxUnX4m11ge5FPXG//SOLqq96mvENe7FPNz
         fl15X3WTrnmY3y5Ha+c3OI7yRqo5pC0dQfICdVtYWq+T5piHyyeUZRCKT2BjARohy0Mc
         wbrA==
X-Gm-Message-State: APjAAAWRfLq5l80sNyEJrGZsPwW+7TdS6MVvDAFHwJ3+pPoROU2WX3I3
	fRA1BqjqYk8xtqZvLlkgzN4KZA==
X-Google-Smtp-Source: APXvYqxCHutpkbRJfLAOgIJs9EabO82Ve9zSCkPCIkSC3X5ZdrOL0QaU2or0dKk75rTzC1h9BCUrgw==
X-Received: by 2002:a17:906:4f04:: with SMTP id t4mr23891798eju.190.1568107863856;
        Tue, 10 Sep 2019 02:31:03 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id u27sm3463898edb.48.2019.09.10.02.31.03
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Sep 2019 02:31:03 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 9F3511009F6; Tue, 10 Sep 2019 12:31:03 +0300 (+03)
Date: Tue, 10 Sep 2019 12:31:03 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Walter Wu <walter-zh.wu@mediatek.com>
Cc: David Hildenbrand <david@redhat.com>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Alexander Potapenko <glider@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Matthias Brugger <matthias.bgg@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Will Deacon <will@kernel.org>,
	Andrey Konovalov <andreyknvl@google.com>,
	Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>,
	Michal Hocko <mhocko@kernel.org>, Qian Cai <cai@lca.pw>,
	linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com,
	linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org,
	linux-mediatek@lists.infradead.org, wsd_upstream@mediatek.com
Subject: Re: [PATCH v2 1/2] mm/page_ext: support to record the last stack of
 page
Message-ID: <20190910093103.4cmqk4semlhgpmle@box.shutemov.name>
References: <20190909085339.25350-1-walter-zh.wu@mediatek.com>
 <36b5a8e0-2783-4c0e-4fc7-78ea652ba475@redhat.com>
 <1568077669.24886.3.camel@mtksdccf07>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1568077669.24886.3.camel@mtksdccf07>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 10, 2019 at 09:07:49AM +0800, Walter Wu wrote:
> On Mon, 2019-09-09 at 12:57 +0200, David Hildenbrand wrote:
> > On 09.09.19 10:53, Walter Wu wrote:
> > > KASAN will record last stack of page in order to help programmer
> > > to see memory corruption caused by page.
> > > 
> > > What is difference between page_owner and our patch?
> > > page_owner records alloc stack of page, but our patch is to record
> > > last stack(it may be alloc or free stack of page).
> > > 
> > > Signed-off-by: Walter Wu <walter-zh.wu@mediatek.com>
> > > ---
> > >  mm/page_ext.c | 3 +++
> > >  1 file changed, 3 insertions(+)
> > > 
> > > diff --git a/mm/page_ext.c b/mm/page_ext.c
> > > index 5f5769c7db3b..7ca33dcd9ffa 100644
> > > --- a/mm/page_ext.c
> > > +++ b/mm/page_ext.c
> > > @@ -65,6 +65,9 @@ static struct page_ext_operations *page_ext_ops[] = {
> > >  #if defined(CONFIG_IDLE_PAGE_TRACKING) && !defined(CONFIG_64BIT)
> > >  	&page_idle_ops,
> > >  #endif
> > > +#ifdef CONFIG_KASAN
> > > +	&page_stack_ops,
> > > +#endif
> > >  };
> > >  
> > >  static unsigned long total_usage;
> > > 
> > 
> > Are you sure this patch compiles?
> > 
> This is patchsets, it need another patch2.
> We have verified it by running KASAN UT on Qemu.

Any patchset must be bisectable: do not break anything in the middle of
patchset.

-- 
 Kirill A. Shutemov

