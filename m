Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 72FAD6B0038
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 23:45:08 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id o3so30151261pgn.13
        for <linux-mm@kvack.org>; Tue, 25 Apr 2017 20:45:08 -0700 (PDT)
Received: from mail-pg0-x22a.google.com (mail-pg0-x22a.google.com. [2607:f8b0:400e:c05::22a])
        by mx.google.com with ESMTPS id f20si23850004pgn.275.2017.04.25.20.45.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Apr 2017 20:45:07 -0700 (PDT)
Received: by mail-pg0-x22a.google.com with SMTP id v1so25963560pgv.1
        for <linux-mm@kvack.org>; Tue, 25 Apr 2017 20:45:07 -0700 (PDT)
Message-ID: <1493178300.4828.5.camel@gmail.com>
Subject: Re: [PATCH v2 1/2] mm: Uncharge poisoned pages
From: Balbir Singh <bsingharora@gmail.com>
Date: Wed, 26 Apr 2017 13:45:00 +1000
In-Reply-To: <20170426023410.GA11619@hori1.linux.bs1.fc.nec.co.jp>
References: <1493130472-22843-1-git-send-email-ldufour@linux.vnet.ibm.com>
	 <1493130472-22843-2-git-send-email-ldufour@linux.vnet.ibm.com>
	 <1493171698.4828.1.camel@gmail.com>
	 <20170426023410.GA11619@hori1.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Laurent Dufour <ldufour@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

> > >  static int delete_from_lru_cache(struct page *p)
> > >  {
> > > +	if (memcg_kmem_enabled())
> > > +		memcg_kmem_uncharge(p, 0);
> > > +
> > 
> > The changelog is not quite clear, so we are uncharging a page using
> > memcg_kmem_uncharge for a page in swap cache/page cache?
> 
> Hi Balbir,
> 
> Yes, in the normal page lifecycle, uncharge is done in page free time.
> But in memory error handling case, in-use pages (i.e. swap cache and page
> cache) are removed from normal path and they don't pass page freeing code.
> So I think that this change is to keep the consistent charging for such a case.

I agree we should uncharge, but looking at the API name, it seems to
be for kmem pages, why are we not using mem_cgroup_uncharge()? Am I missing
something?

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
