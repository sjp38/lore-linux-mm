Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 31B61C43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 14:54:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DE104205C9
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 14:54:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="TEa6RtLe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DE104205C9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 79AB66B0005; Mon, 24 Jun 2019 10:54:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 74A398E0007; Mon, 24 Jun 2019 10:54:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6385F8E0002; Mon, 24 Jun 2019 10:54:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 192276B0005
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 10:54:50 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b12so20805608eds.14
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 07:54:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=JQKwzZzBKlwQ+GJcTJXniJHeeWGAGIRp9LxyTrF6c7w=;
        b=uco0yYyok7ee6IKdv2Vl7HUAi/wxow+m8N01tV7rCkq2sOuw/ACr22NVGONDBO+C7/
         SMdsRUl/vUsHitrDei0MuS6RVoq8gOf7tJk1jBaizSyWB0Ps8ftO6RHEgDf3/MYumFU/
         SbKGWC3wf/yJDK7Ox0RqHMP6CPmxCSqrJmDvpqM+pD9tULqTWMByP8aaG5ZvMEgWIlzT
         43P/oH0386H0dwzEcbHsCIdSiNuZCG48Mpqi11s4OZ5/X3WQFbKIuyNhi6V2URLYGC0R
         r4uEiFpZg7022YyD5KER4HMtcrAtif/o+FYcR49nc7FCSBBM5KC2Yx6uYBcOeQlahxn8
         gK6Q==
X-Gm-Message-State: APjAAAUPpFg4GBWM4zMNw5K3T8wo0lMKyRpWW1T3NKIvA37lP6ML+UA4
	ZwjLo14DytyRyRQNFZdoKtP2ryH+vP5LB1Me7pneey/DWERt5l5oC2YoVXQlp/Zmz/L5Ui8UrPT
	iCFG7v85byAjQ53Nah8DsE7whrZynr2eqVSS++WuTpveQCg97G33bPMf1bfgfEfnTKg==
X-Received: by 2002:a50:addc:: with SMTP id b28mr68657238edd.174.1561388089580;
        Mon, 24 Jun 2019 07:54:49 -0700 (PDT)
X-Received: by 2002:a50:addc:: with SMTP id b28mr68657175edd.174.1561388088968;
        Mon, 24 Jun 2019 07:54:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561388088; cv=none;
        d=google.com; s=arc-20160816;
        b=yOM70wunWdrBZZWRtQpA2/b1v8XwLULYWw4uVAU0zS7LDoZCmbWKeRGPlig4fPQ7NV
         zjmSf5q+hr6SdtLCPRAE6VxsT2YZEgYx6sX2fStCM6ZK13TyBlEI0kj2wO9saJmgAikp
         DN2V84En06+ohcj93ImD726sad3/S13+2Lxe2cD/d+ooAVLN/H0TmVP5mXEEvAwKO3aK
         x4ja0MqOySuOvsCXl0bDKu4/Fqigk0ejOw/WE44sSzY9pOsSzB12ZhcK+qwp0qvSimyS
         5w28Km6rvOIJczG5rr3IF76ohhBhiw5XCLtoxkUPrvQ5G5E0YdIBwjTGajWiE5dAy/gl
         UaJg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=JQKwzZzBKlwQ+GJcTJXniJHeeWGAGIRp9LxyTrF6c7w=;
        b=Tfph96PWQWW/jeRoOqyX1dq8/oBBuz1leKGF7BoNh6pj5eopEDszh2NwO6BCz772fc
         2+IoEpSNarR/YrqHXUx5/WqeZ6IrT/Yna4DBkubF+YXnICLDTMfSajmg+R6DktirTTpM
         VCP++GEklcvflsbUUnM/NfnkeZBEayCGiQ4l/E8/hQaqUdnCz32VkfduqGsuhOt724aO
         0azn+D3STxU2NhREMHd25VsAeeRO5DC3zRH/71XTyUvXoDwaIUes8/Ei5BgcGTehPtKo
         odiCGwggZW2gqXq7BYf4MWyRt0SECtaWkar44wePa+GCZDLivYxyr3uNxUZjZlMZ+EN7
         eqhw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=TEa6RtLe;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 7sor3457259ejq.33.2019.06.24.07.54.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Jun 2019 07:54:48 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=TEa6RtLe;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=JQKwzZzBKlwQ+GJcTJXniJHeeWGAGIRp9LxyTrF6c7w=;
        b=TEa6RtLeTmBGp82xwRDf+v4B/mbgMCa1ukkDRBoDCFWuekkzUvLEhP9StjpXQsD32p
         EO8YXGJR1q79xVvaiZsfbkVWI1obKLoqEJSR0thzI605NpIL/WEYUunrk+/KYbqptWNq
         q6TzCS+oJiUn+xtxjMylWBJyIZZ9N97TEIAbC61s8Op5BGrb4EidBKQTaFnSMOvqe/WP
         VlTzBnFUk9aIJohzFF2v1eryC6+d4hKpOmTK98Zb+rdhe+1fIu4K6jAdGpYp9zOj4edg
         JHPgXiM/BXdR4tzQr498EpVUJocjyiNrbE1ByohItU9px/lzfUvdL6tJXMHAd+FVEKgq
         B3Lw==
X-Google-Smtp-Source: APXvYqwpr/VG3RXa+GEBk10H3MUxE0Vu79XPyJZVrItMjUzVoSUnCSoiB5NZP13/iLswEhQVhC+FoQ==
X-Received: by 2002:a17:906:24c2:: with SMTP id f2mr10410756ejb.233.1561388088581;
        Mon, 24 Jun 2019 07:54:48 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id q14sm1981165eju.47.2019.06.24.07.54.47
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jun 2019 07:54:47 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 6887E1043B3; Mon, 24 Jun 2019 17:54:53 +0300 (+03)
Date: Mon, 24 Jun 2019 17:54:53 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Song Liu <songliubraving@fb.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"matthew.wilcox@oracle.com" <matthew.wilcox@oracle.com>,
	"kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>,
	Kernel Team <Kernel-team@fb.com>,
	"william.kucharski@oracle.com" <william.kucharski@oracle.com>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"hdanton@sina.com" <hdanton@sina.com>
Subject: Re: [PATCH v7 5/6] mm,thp: add read-only THP support for (non-shmem)
 FS
Message-ID: <20190624145453.u4ej3e4ktyyqjite@box>
References: <20190623054749.4016638-1-songliubraving@fb.com>
 <20190623054749.4016638-6-songliubraving@fb.com>
 <20190624124746.7evd2hmbn3qg3tfs@box>
 <52BDA50B-7CBF-4333-9D15-0C17FD04F6ED@fb.com>
 <20190624142747.chy5s3nendxktm3l@box>
 <C3161C66-5044-44E6-92F4-BBAD42EDF4E2@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <C3161C66-5044-44E6-92F4-BBAD42EDF4E2@fb.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 24, 2019 at 02:42:13PM +0000, Song Liu wrote:
> 
> 
> > On Jun 24, 2019, at 7:27 AM, Kirill A. Shutemov <kirill@shutemov.name> wrote:
> > 
> > On Mon, Jun 24, 2019 at 02:01:05PM +0000, Song Liu wrote:
> >>>> @@ -1392,6 +1403,23 @@ static void collapse_file(struct mm_struct *mm,
> >>>> 				result = SCAN_FAIL;
> >>>> 				goto xa_unlocked;
> >>>> 			}
> >>>> +		} else if (!page || xa_is_value(page)) {
> >>>> +			xas_unlock_irq(&xas);
> >>>> +			page_cache_sync_readahead(mapping, &file->f_ra, file,
> >>>> +						  index, PAGE_SIZE);
> >>>> +			lru_add_drain();
> >>> 
> >>> Why?
> >> 
> >> isolate_lru_page() is likely to fail if we don't drain the pagevecs. 
> > 
> > Please add a comment.
> 
> Will do. 
> 
> > 
> >>>> +			page = find_lock_page(mapping, index);
> >>>> +			if (unlikely(page == NULL)) {
> >>>> +				result = SCAN_FAIL;
> >>>> +				goto xa_unlocked;
> >>>> +			}
> >>>> +		} else if (!PageUptodate(page)) {
> >>> 
> >>> Maybe we should try wait_on_page_locked() here before give up?
> >> 
> >> Are you referring to the "if (!PageUptodate(page))" case? 
> > 
> > Yes.
> 
> I think this case happens when another thread is reading the page in. 
> I could not think of a way to trigger this condition for testing. 
> 
> On the other hand, with current logic, we will retry the page on the 
> next scan, so I guess this is OK. 

What I meant that calling wait_on_page_locked() on !PageUptodate() page
will likely make it up-to-date and we don't need to SCAN_FAIL the attempt.

-- 
 Kirill A. Shutemov

