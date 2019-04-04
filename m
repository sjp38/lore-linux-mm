Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A39F0C10F0E
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 16:51:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5DC82206DD
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 16:51:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5DC82206DD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 117A26B0266; Thu,  4 Apr 2019 12:51:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0C7DF6B026B; Thu,  4 Apr 2019 12:51:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EF85F6B026C; Thu,  4 Apr 2019 12:51:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id AF2926B0266
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 12:51:00 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id o4so1920457pgl.6
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 09:51:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=P6Jwr5rPFWCvB1382XNGeOQO5acHNEy8RoKd9/g0+Ds=;
        b=cTTmToH89oh5LaVhTNo0AsxqrdQtP4bPZqTbSf/9SQZB7k1eVguhwG2xqert+Stq+w
         cLgFJCkQu1LtsBF+ojJE3EmXP2KJoLDg0UFyzyOXIT0nVZfDP7g+idyBGuqny7rZcS5v
         WDsbO7rfGcW6oBqZWrW5VwNGot5m90UoV31aJidEfmEZAt2MWFszV/lwhRhB3wH15jES
         lUCsmgihQG7NG2bhKTdba1kaMusPTbM1ySAO/EySrhRS9WfhTv8iDgu9PDyyD3SZE0ef
         QqgJAuVj/LJgIgVIlWw8QLEoySDPU2I4xmlcbfYKxouspVfGRSVQnMNbUhEIBWSMgQBR
         i7xA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUpWgXie37+0NGS+amLWdSzJ5eSZZpBcDRBK0QQZbFrvPMBGfta
	e2mT8V93P3BRvR7BIRtsuIhjBJOBz3PwvF56rCInVRhuga43e6/gjbio+M2FnB5Uy62M/3HwGFw
	01CxigDM2mFjBbH1iBk8Km10mkQ82gFOTeU7qNRRSGGSJJ6mFq2EaDBvs7gc0HVkOPw==
X-Received: by 2002:a62:565c:: with SMTP id k89mr6854003pfb.175.1554396660258;
        Thu, 04 Apr 2019 09:51:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxuPaBRS1AZwa8DI/9fbYneDZqH9605NKYLzhfrjBB0WXpQoLoTRvV80eFNKqYrD6Z1l+Qi
X-Received: by 2002:a62:565c:: with SMTP id k89mr6853939pfb.175.1554396659542;
        Thu, 04 Apr 2019 09:50:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554396659; cv=none;
        d=google.com; s=arc-20160816;
        b=FWaGBHbO/SNza3Z+IFPAx6P7N7EAu4ghkXwIB8J8ePhgg1GmCeb3YZeyFSScssmY/J
         88Tfu0hABLPCCy6vk5GEhj5yvB2nrUuQo1Ew3szDQU5/JrPhJTSwOKz17KAOgNZPg0s4
         JG9Md5JZg2aRprbhT4d1rx2MEpinBd2YbTbDuOCp0SZaRgWWkkfRuB+yZnkxswFCHOD0
         nv/AkQxLtnyaU9IBj09dMRgSVn0Q4Y6kTxA6xqdSJ8xoVEKuDxvHmK54CJQVP21rfKN9
         RTPvZUIox0OunqPt/meNv1EnNWbSxI7HjxBf5YGnbRCnr0vWsKnUsgRJMpwSzIpmqJwC
         f3Vw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=P6Jwr5rPFWCvB1382XNGeOQO5acHNEy8RoKd9/g0+Ds=;
        b=lxKLb9CmJy+3WXj4VbUwhUSHKC4cRBewYXLvZndoJ7/uBsgdKhW9mbqMkJDGgiTUoE
         fYXz8mn63QoDXSjTKQg4wfENE10ln9kQ/TPlXW6xps4oi4v8lUX0fFnJpnvZIKu+C3Cb
         o2N2maCyc0Nib0xqPhdCb4mUX6G0a6juujr7aIpjAflMpWK2xkivNWgorrpnaK+BU4Wn
         4WZkmlRTVpfwxkdElwPDeLrN3AP9MZo52OCDzuo1pD/x53xLeqd4ajBRMbaBuY1la3eQ
         kV2/pcltNt6+WJQ2PyIJIjORBoIRyZPwPZTXKFB6IiRzBnm8mrc74/9w4wq0IPIoelbQ
         C2Zg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id e11si17855538plb.140.2019.04.04.09.50.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Apr 2019 09:50:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga008.fm.intel.com ([10.253.24.58])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 04 Apr 2019 09:50:58 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,308,1549958400"; 
   d="scan'208";a="137615681"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga008.fm.intel.com with ESMTP; 04 Apr 2019 09:50:58 -0700
Date: Thu, 4 Apr 2019 09:50:47 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Huang Shijie <sjhuang@iluvatar.ai>
Cc: akpm@linux-foundation.org, sfr@canb.auug.org.au, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/gup.c: fix the wrong comments
Message-ID: <20190404165046.GB1857@iweiny-DESK2.sc.intel.com>
References: <20190404072347.3440-1-sjhuang@iluvatar.ai>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190404072347.3440-1-sjhuang@iluvatar.ai>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 04, 2019 at 03:23:47PM +0800, Huang Shijie wrote:
> When CONFIG_HAVE_GENERIC_GUP is defined, the kernel will use its own
> get_user_pages_fast().
> 
> In the following scenario, we will may meet the bug in the DMA case:
> 	    .....................
> 	    get_user_pages_fast(start,,, pages);
> 	        ......
> 	    sg_alloc_table_from_pages(, pages, ...);
> 	    .....................
> 
> The root cause is that sg_alloc_table_from_pages() requires the
> page order to keep the same as it used in the user space, but
> get_user_pages_fast() will mess it up.

I wonder if there is something we can do to change sg_alloc_table_from_pages()
to work?  Reading the comment for it there is no indication of this limitation.
So should we update that comment as well?

> 
> So change the comments, and make it more clear for the driver
> users.
> 
> Signed-off-by: Huang Shijie <sjhuang@iluvatar.ai>
> ---
>  mm/gup.c | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/gup.c b/mm/gup.c
> index 22acdd0f79ff..b810d15d4db9 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -1129,10 +1129,6 @@ EXPORT_SYMBOL(get_user_pages_locked);
>   *  with:
>   *
>   *      get_user_pages_unlocked(tsk, mm, ..., pages);
> - *
> - * It is functionally equivalent to get_user_pages_fast so
> - * get_user_pages_fast should be used instead if specific gup_flags
> - * (e.g. FOLL_FORCE) are not required.
>   */
>  long get_user_pages_unlocked(unsigned long start, unsigned long nr_pages,
>  			     struct page **pages, unsigned int gup_flags)
> @@ -2147,6 +2143,10 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
>   * If not successful, it will fall back to taking the lock and
>   * calling get_user_pages().
>   *
> + * This function is different from the get_user_pages_unlocked():
> + *      The @pages may has different page order with the result
> + *      got by get_user_pages_unlocked().
> + *

I think I would word this a bit more generally.  Say:

<quote>
NOTE: Because get_user_pages_fast() walks the page tables to find the pages,
the order of pages returned may be different from those returned by other
get_user_pages_*() calls.
</quote>

Ira

>   * Returns number of pages pinned. This may be fewer than the number
>   * requested. If nr_pages is 0 or negative, returns 0. If no pages
>   * were pinned, returns -errno.
> -- 
> 2.17.1
> 

