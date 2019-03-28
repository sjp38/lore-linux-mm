Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 25A5AC4360F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 09:02:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DFE132082F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 09:02:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DFE132082F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 580D06B0003; Thu, 28 Mar 2019 05:02:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 531026B0006; Thu, 28 Mar 2019 05:02:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 421C06B0007; Thu, 28 Mar 2019 05:02:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id EA2816B0003
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 05:02:29 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id n24so7752226edd.21
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 02:02:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=KQWrAI9k1+Cl/Bv9k7/+wrpe+ZWwOfL7pZJGNvBlpZs=;
        b=qhNc4Od9Q2myx3gOmcoV4HP1bNg0/5C4q9gAzB2U12JcGpu2YtfIVOsw0s20gCwoGY
         TavN/helfWgkDSuLMNW+kirUs8NLvKFUu8Wa2mkrtlgoeK4cWm+J4k9yulpdrq2W9i9T
         d+MiZAEtbNsweuOrsrRW+9hSsj0gvSWcdiELqhy6da1rcoGTsKvCOmeAw4tjB4fg9ebO
         XOjsenB7fD09l7ntmI6XOupw0pflISqca8ipTu9WpnEoq5D5NtjM87nZRiZhW8TVfRmH
         TIuEKHx47oBTxG9V89GiTqXKScbqybHV81A3lTcKcCXUStHDG+uu4uUsKvA83fhfUN0j
         ScKw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAXhAEHba2Zf4Q5eXtWjSjzVnCXGzBzZsiPY+V7qZCzgnma2Ga4E
	LFn1Xaam4xbOX8mNqNpDhHbfsVYUEkd7Eiou34am0cJoVHvbOdvUJVUAr6Am3nDZg+Ymig4vdkU
	IlUdLWcg+ziltW3lCfHA0TBbE6P68eE/XOG8gjzDmWhCUinIkmNorm4md11NtwDkAPw==
X-Received: by 2002:a50:92f6:: with SMTP id l51mr28372965eda.15.1553763749465;
        Thu, 28 Mar 2019 02:02:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzCxokIL7WmARvXMEWrOZnmUZbaWK0BRN7zi0Zut2mZsrklo6gi6PrWE5U4m+zrTOLLMSHZ
X-Received: by 2002:a50:92f6:: with SMTP id l51mr28372910eda.15.1553763748450;
        Thu, 28 Mar 2019 02:02:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553763748; cv=none;
        d=google.com; s=arc-20160816;
        b=b6Dze0zpe7GC7DDjCZaHJB6oB577Qq72tmpaNDjTadLN0i5LD1Vh3mDAbRv0ZAUQT7
         ntCbs21lTR6GDHp/jaSQP/DYU/P2C4Ytow/CQw4VVLVYiQ7a5FoWlTcEDemEe/0aARBC
         7hd3oudlEQgaHJLdwl1MkpUlMFgr8+e+MmBND3wEsAvioSVSmjGFdxQ+JxovvKFJvZ4A
         g6G42GLZSYwgfQYnjCFfLpL+siZZS6g7T+dMu4NgBTcQPnSby2Nyrcp4lLsGtwzwXJqr
         1YbYoPBIyYS3Dyl8TQZ+H4+FT+zmB3JY0024/hIPZTNCz05EWp+bfgB87vhWeJVfb1SY
         2upg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=KQWrAI9k1+Cl/Bv9k7/+wrpe+ZWwOfL7pZJGNvBlpZs=;
        b=aVxb/cOgbuFzlUPblwfyimuVDv9dmFa03mwJolDr9RrFVodgW0lJX6sIXc8KoNzRmq
         veihWsOQvmTGo1+TwjqpHtVX3L1d18eQSKQtlnhLNzhK6YU9jLdlFzz2olKxhTph+r/0
         m/sYIhbtjbZPbGHtI4P3ExSaoQF2/LQLla1f85IAT5mMPrI5t52XFvvsPcwMj5YjMX0H
         pEpGN69STauhHqJ/0uMbjXdIabhFW/vcXfUOtkhTqGJNv+ZwAnZTjosVIf1oz+iCRTan
         aJqsMAu11lWEnkrnIA+HAMX/EB6IG4eaUrZe7r7gmVZavYgucQIQB3JIFV02aE0SaCpY
         IDXA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m25si1914164edj.256.2019.03.28.02.02.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 02:02:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 15AFFAC97;
	Thu, 28 Mar 2019 09:02:28 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id B1D271E424A; Thu, 28 Mar 2019 10:02:27 +0100 (CET)
Date: Thu, 28 Mar 2019 10:02:27 +0100
From: Jan Kara <jack@suse.cz>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Linux MM <linux-mm@kvack.org>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	Chandan Rajendra <chandan@linux.ibm.com>,
	stable <stable@vger.kernel.org>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH] mm: Fix modifying of page protection by insert_pfn()
Message-ID: <20190328090227.GB22915@quack2.suse.cz>
References: <20190311084537.16029-1-jack@suse.cz>
 <CAPcyv4gBhTXs3Lf1ESgtaT4JUV8xiwNnM_OQU3-0ENB0hpAPng@mail.gmail.com>
 <20190327173332.GA15475@quack2.suse.cz>
 <20190327141414.ad663db479afa8694ed270c6@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190327141414.ad663db479afa8694ed270c6@linux-foundation.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 27-03-19 14:14:14, Andrew Morton wrote:
> On Wed, 27 Mar 2019 18:33:32 +0100 Jan Kara <jack@suse.cz> wrote:
> 
> > On Mon 11-03-19 10:22:44, Dan Williams wrote:
> > > On Mon, Mar 11, 2019 at 1:45 AM Jan Kara <jack@suse.cz> wrote:
> > > >
> > > > Aneesh has reported that PPC triggers the following warning when
> > > > excercising DAX code:
> > > >
> > > > [c00000000007610c] set_pte_at+0x3c/0x190
> > > > LR [c000000000378628] insert_pfn+0x208/0x280
> > > > Call Trace:
> > > > [c0000002125df980] [8000000000000104] 0x8000000000000104 (unreliable)
> > > > [c0000002125df9c0] [c000000000378488] insert_pfn+0x68/0x280
> > > > [c0000002125dfa30] [c0000000004a5494] dax_iomap_pte_fault.isra.7+0x734/0xa40
> > > > [c0000002125dfb50] [c000000000627250] __xfs_filemap_fault+0x280/0x2d0
> > > > [c0000002125dfbb0] [c000000000373abc] do_wp_page+0x48c/0xa40
> > > > [c0000002125dfc00] [c000000000379170] __handle_mm_fault+0x8d0/0x1fd0
> > > > [c0000002125dfd00] [c00000000037a9b0] handle_mm_fault+0x140/0x250
> > > > [c0000002125dfd40] [c000000000074bb0] __do_page_fault+0x300/0xd60
> > > > [c0000002125dfe20] [c00000000000acf4] handle_page_fault+0x18
> > > >
> > > > Now that is WARN_ON in set_pte_at which is
> > > >
> > > >         VM_WARN_ON(pte_hw_valid(*ptep) && !pte_protnone(*ptep));
> > > >
> > > > The problem is that on some architectures set_pte_at() cannot cope with
> > > > a situation where there is already some (different) valid entry present.
> > > >
> > > > Use ptep_set_access_flags() instead to modify the pfn which is built to
> > > > deal with modifying existing PTE.
> > > >
> > > > CC: stable@vger.kernel.org
> > > > Fixes: b2770da64254 "mm: add vm_insert_mixed_mkwrite()"
> > > > Reported-by: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
> > > > Signed-off-by: Jan Kara <jack@suse.cz>
> > > 
> > > Acked-by: Dan Williams <dan.j.williams@intel.com>
> > > 
> > > Andrew, can you pick this up?
> > 
> > Andrew, ping?
> 
> I merged this a couple of weeks ago and it's in the queue for 5.1.

Ah, sorry. I didn't find any email about this in my archives. Not sure what
happened. Thanks for merging the patch!

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

