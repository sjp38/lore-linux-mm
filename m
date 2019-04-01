Return-Path: <SRS0=sWz3=SD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 71C9DC43381
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 09:27:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1511D206BA
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 09:27:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="Z6KcNajs"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1511D206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A29D96B0006; Mon,  1 Apr 2019 05:27:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9D9326B0008; Mon,  1 Apr 2019 05:27:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8A05B6B000A; Mon,  1 Apr 2019 05:27:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5043F6B0006
	for <linux-mm@kvack.org>; Mon,  1 Apr 2019 05:27:25 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id v76so5769629pfa.18
        for <linux-mm@kvack.org>; Mon, 01 Apr 2019 02:27:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=TsLz8zOrgTjJFRX6XgktMpE0U8DYhh4MWryP3hoU+bg=;
        b=LFsKN9zn2H9VxRv31P9uRMDs/uR6ajjQYzVcnS2YsVn6qwI/RpE/q2H9BN6wqcgIDS
         H0OPBQkxUvs3L4/2IbfHFbRYGu9zpJpPdpSJxTNWcGePGA0gGOrC5J8PCjj1/T1M5wI1
         JCCzFSipSetJ89nYTmDCARAB6KJvmqIuQ4M8zH1LOpKFLzEE1fO3868Ur1Fy2nbVf2Ct
         rkvhPEszcje0ax/eTPQFPygOPf+1tIT8OVbOnX8eBBk6ce8FQh5Nc0oMqr0NGeqL+UbN
         A4Hynini1oW74t7iYh57y2k7M0XSjnTkf+20fDVv1vrtW1n49HW4XazL6/ppvT0qJj3o
         tH+w==
X-Gm-Message-State: APjAAAX40Z+zd1y4bHzgxOXhl7yaUW5MfY9gpGf3xI/2ZZo9pRwpOFXO
	/Yzp8cBqqnqrCXXxpL9jJxmNxm3V5Vu/YBq2fgjvxHUbLseEFb2aTo95neQq/zywEogTUnv3msG
	4B2evwxUTcpYdprbg4JE6bg5OGXzBtve+C7n/ac8ZBfMFp3z1dhNu1l58BMO3BL7c1A==
X-Received: by 2002:aa7:83c1:: with SMTP id j1mr6035498pfn.241.1554110844932;
        Mon, 01 Apr 2019 02:27:24 -0700 (PDT)
X-Received: by 2002:aa7:83c1:: with SMTP id j1mr6035459pfn.241.1554110844083;
        Mon, 01 Apr 2019 02:27:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554110844; cv=none;
        d=google.com; s=arc-20160816;
        b=FSFWY14fRsf3RTO8f+zAZ0wX/7FdAKA826MHIcJLVYBi2jEnTbiUMrtJQMkFn7rrdE
         mvwwxRWUdC+sEMumY2tyby7FXoJxGhSkgF2MNYHfzDLFBUcUDnf8pnpuWykAYMUyNxAH
         /ZVsv4Wxd/hu89HD7iybaJSqKQ4YMTpwc32CkTJqkZjiFu5q1A8++uyIh56zNaln5awu
         QevvbUJgio9NfabtNPrq8ntJg/LnoaCiwQ0ouyqPzak5QB4D52aJiRlTLRO0jKoAcL+H
         UJpDS0xpoiOuv7zX/K19YKV4VWjTI0wmG29Nmc9SEnWE3ibdlmiz4S2ujYisWLb1YjOH
         GCLw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=TsLz8zOrgTjJFRX6XgktMpE0U8DYhh4MWryP3hoU+bg=;
        b=k7aeJccYRIACzVSmPAAyYw9nkh+llfsiPAf7ldNSyipZBQ0Q5MC1UcWJ3CjkyYg/Uj
         LgeArEAFh/mMrlGIgH9b5Zpxt+BaJqeF72PiDaT0MYsszPSJyqCHH8VnhVQMaVofb8+0
         VG29Zg/I38Kb/8YvDQ13/3GXhJDzJp+g1Jc1D/cSGwnakka6Xd/WAq874KNgnezRNUQI
         04bP0qQn7BZ3FMFMn7jG7CSv9NrcgHVOdh23jmOhYuBTn+wpknJTaRTCpuHmw+4sVco/
         0Ir8gGYJfZt8kP+N7PcNrGMJWCDOrpln8E/0MppjY3BnFG6duLgZqCrlg7upogrM2sjx
         ZnBg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=Z6KcNajs;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y11sor9559151pfm.28.2019.04.01.02.27.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 01 Apr 2019 02:27:23 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=Z6KcNajs;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=TsLz8zOrgTjJFRX6XgktMpE0U8DYhh4MWryP3hoU+bg=;
        b=Z6KcNajs6aWWk/atx0tTM2jLXYMYz17l7Nep3I0xTbd2oBLTwwX9+xtRubh1/u8Ry0
         TicpWble1lzQwdmHTla5CETQ7NcHu4IYcFC2W1didNHJVPopT5ydjRyXs3VgKg2qO1lL
         c7aO4V5wDZColgt9oL1UC02KZ3Ql1+jVKsDXeqnZHYAJnqSChmJ1LnJUiy/ex5mI0Jsr
         vKvenAaEzoZXEM4SJX6KfuJZEA4eQG7UXRwpRJqynCXuxRJ8qKGkBwDe3YMXPk9hM1/S
         /Uo1IpaxGsSS/qPXZSUpRzLpKTsz8fEYE2BRRUDQ25y00N8NvLLfK5UfXYocGWEyd4yS
         Dpog==
X-Google-Smtp-Source: APXvYqxm/PY+ruZ6KEEsaNJdDyuEo1ammob61NsEOA5cFA6U2gjt04EUL7MDSl8KLRa3y4r6792Zng==
X-Received: by 2002:aa7:8589:: with SMTP id w9mr61276248pfn.97.1554110843469;
        Mon, 01 Apr 2019 02:27:23 -0700 (PDT)
Received: from kshutemo-mobl1.localdomain ([134.134.139.83])
        by smtp.gmail.com with ESMTPSA id i189sm13270797pfc.71.2019.04.01.02.27.21
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Apr 2019 02:27:22 -0700 (PDT)
Received: by kshutemo-mobl1.localdomain (Postfix, from userid 1000)
	id 9A55130C751; Mon,  1 Apr 2019 12:27:16 +0300 (+03)
Date: Mon, 1 Apr 2019 12:27:16 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Matthew Wilcox <willy@infradead.org>
Cc: Qian Cai <cai@lca.pw>, Huang Ying <ying.huang@intel.com>,
	linux-mm@kvack.org
Subject: Re: page cache: Store only head pages in i_pages
Message-ID: <20190401092716.mxw32y4sl66ywc2o@kshutemo-mobl1>
References: <20190324020614.GD10344@bombadil.infradead.org>
 <897cfdda-7686-3794-571a-ecb8b9f6101f@lca.pw>
 <20190324030422.GE10344@bombadil.infradead.org>
 <d35bc0a3-07b7-f0ee-fdae-3d5c750a4421@lca.pw>
 <20190329195941.GW10344@bombadil.infradead.org>
 <1553894734.26196.30.camel@lca.pw>
 <20190330030431.GX10344@bombadil.infradead.org>
 <20190330141052.GZ10344@bombadil.infradead.org>
 <20190331032326.GA10344@bombadil.infradead.org>
 <20190401091858.s7clitbvf46nomjm@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190401091858.s7clitbvf46nomjm@kshutemo-mobl1>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 01, 2019 at 12:18:58PM +0300, Kirill A. Shutemov wrote:
> On Sat, Mar 30, 2019 at 08:23:26PM -0700, Matthew Wilcox wrote:
> > On Sat, Mar 30, 2019 at 07:10:52AM -0700, Matthew Wilcox wrote:
> > > On Fri, Mar 29, 2019 at 08:04:32PM -0700, Matthew Wilcox wrote:
> > > > Excellent!  I'm not comfortable with the rule that you have to be holding
> > > > the i_pages lock in order to call find_get_page() on a swap address_space.
> > > > How does this look to the various smart people who know far more about the
> > > > MM than I do?
> > > > 
> > > > The idea is to ensure that if this race does happen, the page will be
> > > > handled the same way as a pagecache page.  If __delete_from_swap_cache()
> > > > can be called while the page is still part of a VMA, then this patch
> > > > will break page_to_pgoff().  But I don't think that can happen ... ?
> > > 
> > > Oh, blah, that can totally happen.  reuse_swap_page() calls
> > > delete_from_swap_cache().  Need a new plan.
> > 
> > I don't see a good solution here that doesn't involve withdrawing this
> > patch and starting over.  Bad solutions:
> > 
> >  - Take the i_pages lock around each page lookup call in the swap code
> >    (not just the one you found; there are others like mc_handle_swap_pte()
> >    in memcontrol.c)
> >  - Call synchronize_rcu() in __delete_from_swap_cache()
> >  - Swap the roles of ->index and ->private for swap pages, and then don't
> >    clear ->index when deleting a page from the swap cache
> > 
> > The first two would be slow and non-scalable.  The third is still prone
> > to a race where the page is looked up on one CPU, while another CPU
> > removes it from one swap file then moves it to a different location,
> > potentially in a different swap file.  Hard to hit, but not a race we
> > want to introduce.
> > 
> > I believe that the swap code actually never wants to see subpages.  So if
> > we start again, introducing APIs (eg find_get_head()) which return the
> > head page, then convert the swap code over to use those APIs, we don't
> > need to solve the problem of finding the subpage of a swap page while
> > not holding the page lock.
> > 
> > I'm obviously reluctant to withdraw the patch, but I don't see a better
> > option.  Your testing has revealed a problem that needs a deeper solution
> > than just adding a fix patch.
> 
> Hm. Isn't the problem with VM_BUGs themself? I mean find_subpage()
> produces right result (or am I wrong here?), but VM_BUGs flags it as wrong.

Yeah, I'm wrong. :P

What about patch like this? (completely untested)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index f939e004c5d1..e3b9bf843dcb 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -335,12 +335,12 @@ static inline struct page *grab_cache_page_nowait(struct address_space *mapping,
 
 static inline struct page *find_subpage(struct page *page, pgoff_t offset)
 {
-	unsigned long index = page_index(page);
+	unsigned long mask;
 
 	VM_BUG_ON_PAGE(PageTail(page), page);
-	VM_BUG_ON_PAGE(index > offset, page);
-	VM_BUG_ON_PAGE(index + (1 << compound_order(page)) <= offset, page);
-	return page - index + offset;
+
+	mask = (1UL << compound_order(page)) - 1;
+	return page + (offset & mask);
 }
 
 struct page *find_get_entry(struct address_space *mapping, pgoff_t offset);
-- 
 Kirill A. Shutemov

