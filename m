Return-Path: <SRS0=rp0W=VN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8D272C76195
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 15:33:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5F2482054F
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 15:33:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5F2482054F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F3A778E000D; Tue, 16 Jul 2019 11:33:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EEA3C8E0006; Tue, 16 Jul 2019 11:33:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E00948E000D; Tue, 16 Jul 2019 11:33:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id BF6308E0006
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 11:33:41 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id d26so18391229qte.19
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 08:33:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=GlZTBehAAbyYvBp4ybBRCKYJZRzjwNpajDhz3ULS2Ss=;
        b=qjACSABL448DV5aHtKKIfa/Ye948+qsqPCrsBm/8ANQsCvMx724khm0KzouA6tqa83
         n4b+fcTTLPXbzJE3BrQOiV2/cmLerNdo/JNo78aDM7YFqM9SusOVJWFaaLq+ssDBww+2
         miljjho7QWh66gc7CXcLc7r3v2ezlYOD8ftA2cDGBfzBRKCsSMwUgH2ruweJLs2dknNo
         6m3w5koBGKL+UsnPZoUc9EOjPvpl34iEJuf8w19y8hFW6pI7CqNd2b7mCWLZl4XHr9Xi
         DEqdD7jnNDzGXw0imYVuaR/+bmApaBcw3fGlTV+grvDOppmxPFxLB9de0tqYza4685DT
         WkPg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW9kCZvCXkVzGfps5a2G4eMyNeKIuiLeP4e55WUCOAC2EcE7KE0
	AO6DWjOgrJuGlHIOPqRfA/DZY+1BYcEh0mUlY5LVBGwisLPlAlVM5fdrHzHj9jOoTrAKVTBooyn
	/ztA0TOmcLdHw9Dh/huUAh22s6bTSuk9JWL11yfwUt6R15EPpO8CS7OcUxasynb+G9g==
X-Received: by 2002:a0c:818f:: with SMTP id 15mr23217566qvd.162.1563291221547;
        Tue, 16 Jul 2019 08:33:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwySLpwBAAgJeFm5dQvu1mjBoOwHsKqNgWDYjfTH2wZ+DVSH3gyZEZYC13tV/tf5ERM+S6l
X-Received: by 2002:a0c:818f:: with SMTP id 15mr23217489qvd.162.1563291220595;
        Tue, 16 Jul 2019 08:33:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563291220; cv=none;
        d=google.com; s=arc-20160816;
        b=ZxEZCQQl4GEDeztM0ZQG8CbFR+qBPlPBIvkEHWSn7B/XQSdHlXWectt/IR0lnoz1Sb
         kB6GcocDlyhoPwp9YKLRF0udIdmKbSzGTMHdM1MDV9f1SK8DmQhabAaP9jn1aj1g8c4/
         481GVyK7J18YcupdGY9UB1QxSsDNi80n6hAOoyTgOUWVEyo0WAKo+QWEmzPRLNqB/wS5
         QPzOuArDjL3KuYWvVgEl4XxvKwC5ZWt7W3Iwp7mP6Y9X8L7Fqraz47TeUq/Zog8NKWym
         vgFmieubRU6oWtb1Zd+AtDTiXKK5CMe3K4FHzKEmx23+WYqd8Rma4y5/x66AjmkSK2PF
         ZmKw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=GlZTBehAAbyYvBp4ybBRCKYJZRzjwNpajDhz3ULS2Ss=;
        b=EHCYACTyS7mM69YfaIVuvYK9NbCzz3D9jVRxcTghYG+JsoJ9fMhymSeF589X7Ao4d8
         nCTSrRLokv8bQjW5pNqJXEqqpIcH5RoIQc7NUPKbBcPz9hh+ZFJwE+PIF6iLvHnBfsy3
         6hxpjlgsOOImkkcW9yAIMT47Uf0uLWL7HagqLStwbpzaXYqFeLSao6IdAHAhauuTF9+r
         MNUbZTSlU6E94V5yYS+Wb9dfjrN0Q7VhLK7/4POiPasebsZ3vKNahQKh5COdiOeQPmwk
         gNH8fm49MbpfVupFmaG8dkTQ0ivO3lWzvNPNgZB6l/xmWZ7YijnyDhj+AFS5eipWSrAE
         j2yA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h9si12402155qkg.313.2019.07.16.08.33.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jul 2019 08:33:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id C4A73C034DF3;
	Tue, 16 Jul 2019 15:33:39 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.178])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 09C221001B00;
	Tue, 16 Jul 2019 15:33:38 +0000 (UTC)
Date: Tue, 16 Jul 2019 11:33:37 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Jason Gunthorpe <jgg@mellanox.com>
Subject: Re: [PATCH] mm/hmm: Fix bad subpage pointer in try_to_unmap_one
Message-ID: <20190716153337.GA3490@redhat.com>
References: <20190709223556.28908-1-rcampbell@nvidia.com>
 <20190709172823.9413bb2333363f7e33a471a0@linux-foundation.org>
 <05fffcad-cf5e-8f0c-f0c7-6ffbd2b10c2e@nvidia.com>
 <20190715150031.49c2846f4617f30bca5f043f@linux-foundation.org>
 <0ee5166a-26cd-a504-b9db-cffd082ecd38@nvidia.com>
 <8dd86951-f8b0-75c2-d738-5080343e5dc5@nvidia.com>
 <6a52c2a0-8d27-2ce4-e797-7cae653df21a@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <6a52c2a0-8d27-2ce4-e797-7cae653df21a@nvidia.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Tue, 16 Jul 2019 15:33:39 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 15, 2019 at 11:14:31PM -0700, John Hubbard wrote:
> On 7/15/19 5:38 PM, Ralph Campbell wrote:
> > On 7/15/19 4:34 PM, John Hubbard wrote:
> > > On 7/15/19 3:00 PM, Andrew Morton wrote:
> > > > On Tue, 9 Jul 2019 18:24:57 -0700 Ralph Campbell <rcampbell@nvidia.com> wrote:
> > > > 
> > > >   mm/rmap.c |    1 +
> > > >   1 file changed, 1 insertion(+)
> > > > 
> > > > --- a/mm/rmap.c~mm-hmm-fix-bad-subpage-pointer-in-try_to_unmap_one
> > > > +++ a/mm/rmap.c
> > > > @@ -1476,6 +1476,7 @@ static bool try_to_unmap_one(struct page
> > > >                * No need to invalidate here it will synchronize on
> > > >                * against the special swap migration pte.
> > > >                */
> > > > +            subpage = page;
> > > >               goto discard;
> > > >           }
> > > 
> > > Hi Ralph and everyone,
> > > 
> > > While the above prevents a crash, I'm concerned that it is still not
> > > an accurate fix. This fix leads to repeatedly removing the rmap, against the
> > > same struct page, which is odd, and also doesn't directly address the
> > > root cause, which I understand to be: this routine can't handle migrating
> > > the zero page properly--over and back, anyway. (We should also mention more
> > > about how this is triggered, in the commit description.)
> > > 
> > > I'll take a closer look at possible fixes (I have to step out for a bit) soon,
> > > but any more experienced help is also appreciated here.
> > > 
> > > thanks,
> > 
> > I'm not surprised at the confusion. It took me quite awhile to
> > understand how migrate_vma() works with ZONE_DEVICE private memory.
> > The big point to be aware of is that when migrating a page to
> > device private memory, the source page's page->mapping pointer
> > is copied to the ZONE_DEVICE struct page and the page_mapcount()
> > is increased. So, the kernel sees the page as being "mapped"
> > but the page table entry as being is_swap_pte() so the CPU will fault
> > if it tries to access the mapped address.
> 
> Thanks for humoring me here...
> 
> The part about the source page's page->mapping pointer being *copied*
> to the ZONE_DEVICE struct page is particularly interesting, and belongs
> maybe even in a comment (if not already there). Definitely at least in
> the commit description, for now.
> 
> > So yes, the source anon page is unmapped, DMA'ed to the device,
> > and then mapped again. Then on a CPU fault, the zone device page
> > is unmapped, DMA'ed to system memory, and mapped again.
> > The rmap_walk() is used to clear the temporary migration pte so
> > that is another important detail of how migrate_vma() works.
> > At the moment, only single anon private pages can migrate to
> > device private memory so there are no subpages and setting it to "page"
> > should be correct for now. I'm looking at supporting migration of
> > transparent huge pages but that is a work in progress.
> 
> Well here, I worry, because subpage != tail page, right? subpage is a
> strange variable name, and here it is used to record the page that
> corresponds to *each* mapping that is found during the reverse page
> mapping walk.
> 
> And that makes me suspect that if there were more than one of these
> found (which is unlikely, given the light testing that we have available
> so far, I realize), then there could possibly be a problem with the fix,
> yes?

No THP when migrating to device memory so no tail vs head page here.

Cheers,
Jérôme

