Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 554806B02E1
	for <linux-mm@kvack.org>; Wed, 26 Apr 2017 04:59:10 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id f5so40686930pff.13
        for <linux-mm@kvack.org>; Wed, 26 Apr 2017 01:59:10 -0700 (PDT)
Received: from mail-pf0-x236.google.com (mail-pf0-x236.google.com. [2607:f8b0:400e:c00::236])
        by mx.google.com with ESMTPS id y40si3808088pla.289.2017.04.26.01.59.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Apr 2017 01:59:09 -0700 (PDT)
Received: by mail-pf0-x236.google.com with SMTP id a188so39265544pfa.0
        for <linux-mm@kvack.org>; Wed, 26 Apr 2017 01:59:09 -0700 (PDT)
Message-ID: <1493197141.16329.1.camel@gmail.com>
Subject: Re: [PATCH v2 1/2] mm: Uncharge poisoned pages
From: Balbir Singh <bsingharora@gmail.com>
Date: Wed, 26 Apr 2017 18:59:01 +1000
In-Reply-To: <20170426044608.GA32451@hori1.linux.bs1.fc.nec.co.jp>
References: <1493130472-22843-1-git-send-email-ldufour@linux.vnet.ibm.com>
	 <1493130472-22843-2-git-send-email-ldufour@linux.vnet.ibm.com>
	 <1493171698.4828.1.camel@gmail.com>
	 <20170426023410.GA11619@hori1.linux.bs1.fc.nec.co.jp>
	 <1493178300.4828.5.camel@gmail.com>
	 <20170426044608.GA32451@hori1.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Laurent Dufour <ldufour@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

On Wed, 2017-04-26 at 04:46 +0000, Naoya Horiguchi wrote:
> On Wed, Apr 26, 2017 at 01:45:00PM +1000, Balbir Singh wrote:
> > > > >  static int delete_from_lru_cache(struct page *p)
> > > > >  {
> > > > > +	if (memcg_kmem_enabled())
> > > > > +		memcg_kmem_uncharge(p, 0);
> > > > > +
> > > > 
> > > > The changelog is not quite clear, so we are uncharging a page using
> > > > memcg_kmem_uncharge for a page in swap cache/page cache?
> > > 
> > > Hi Balbir,
> > > 
> > > Yes, in the normal page lifecycle, uncharge is done in page free time.
> > > But in memory error handling case, in-use pages (i.e. swap cache and page
> > > cache) are removed from normal path and they don't pass page freeing code.
> > > So I think that this change is to keep the consistent charging for such a case.
> > 
> > I agree we should uncharge, but looking at the API name, it seems to
> > be for kmem pages, why are we not using mem_cgroup_uncharge()? Am I missing
> > something?
> 
> Thank you for pointing out.
> Actually I had the same question and this surely looks strange.
> But simply calling mem_cgroup_uncharge() here doesn't work because it
> assumes that page_refcount(p) == 0, which is not true in hwpoison context.
> We need some other clearer way or at least some justifying comment about
> why this is ok.
>

We should call mem_cgroup_uncharge() after isolate_lru_page()/put_page().
We could check if page_count() is 0 or force if required (!MF_RECOVERED &&
!MF_DELAYED). We could even skip the VM_BUG_ON if the page is poisoned.

Balbir Singh. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
