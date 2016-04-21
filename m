Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6FEDD830A8
	for <linux-mm@kvack.org>; Thu, 21 Apr 2016 19:44:56 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id vv3so131263138pab.2
        for <linux-mm@kvack.org>; Thu, 21 Apr 2016 16:44:56 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b7si3863158paw.32.2016.04.21.16.44.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Apr 2016 16:44:55 -0700 (PDT)
Date: Thu, 21 Apr 2016 16:44:54 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/memory-failure: fix race with compound page
 split/merge
Message-Id: <20160421164454.3da1afe01cc4f5adb6b9772c@linux-foundation.org>
In-Reply-To: <20160418231551.GA18493@hori1.linux.bs1.fc.nec.co.jp>
References: <146097982568.15733.13924990169211134049.stgit@buzz>
	<20160418231551.GA18493@hori1.linux.bs1.fc.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Mon, 18 Apr 2016 23:15:52 +0000 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> # CCed Andrew,

Thanks.

> On Mon, Apr 18, 2016 at 02:43:45PM +0300, Konstantin Khlebnikov wrote:
> > Get_hwpoison_page() must recheck relation between head and tail pages.
> > 
> > Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> 
> Looks good to me. Without this recheck, the race causes kernel to pin
> an irrelevant page, and finally makes kernel crash for refcount mismcach...

Thanks.  I'll add the above (important!) info to the changelog and
cc:stable.

> > -	return get_page_unless_zero(head);
> > +	if (get_page_unless_zero(head)) {
> > +		if (head == compound_head(page))
> > +			return 1;
> > +
> > +		pr_info("MCE: %#lx cannot catch tail\n", page_to_pfn(page));
> 
> Recently Chen Yucong replaced the label "MCE:" with "Memory failure:",
> but the resolution is trivial, I think.

Yup, that patch is in my (large) backlog.  Away at conferences for
seven days, receiving 100 actionable emails per day.  Give me a few
days ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
