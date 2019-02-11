Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E8854C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 19:28:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AFD29222A2
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 19:28:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AFD29222A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 46B168E0147; Mon, 11 Feb 2019 14:28:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 418AF8E0134; Mon, 11 Feb 2019 14:28:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 32EB58E0147; Mon, 11 Feb 2019 14:28:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 04A7B8E0134
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 14:28:07 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id 43so71937qtz.8
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 11:28:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=/oF7MB61/9b6c1O5qyvHJGO7XlPNLHdWV5AzzoYEEXE=;
        b=qca+s+QAb7ovuqDO7ZFVlz54GGGza5k9ArNgsTrhV/jZzIAoWpAjYORF8bGmfPLxdG
         J+e7BJbXmnZhghT39U065TO6hnOTRxR9i2JApOL0dL3K0Vio0pYTiTMpCGtk+e6vbsj6
         GzehgbiPSv5hQAEFNZZ0ECsVf3mVre2FB9wTC5B7OLPWLpo8IDUkfqAjm+QuJ4oraKcE
         WNyi2wHz/x0bsl1QutWAzgsio0c1U6uGc1rLf63gnRybHL4LnoRZPd4OnfG5RFw7IyeY
         Qji4W3ljTWIyTwS12w9SQrQh9KsotW3CfGoVjG7DwfglCpp5zKhW++m2OL9xS9zVwuE1
         NWpg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZ5UXpmo0YZM6ennVzw6c1QbBnpW2CLgIFnEWUAC6XwUFpe95DN
	CGjptl6EV//gAF5Zw+ftZ9GkVBRJ+QUYviSQL6AHEioAATeK9iznt7hYA86N1Z9eR5RUoQgCCFp
	++cjFkaJKms/c4u/mRFbRMA5rrxtEwWDTfYN5WU1KDeUt0jBWpSCA1LwO+ysPjyL8Lg==
X-Received: by 2002:ae9:c106:: with SMTP id z6mr26723104qki.197.1549913286779;
        Mon, 11 Feb 2019 11:28:06 -0800 (PST)
X-Google-Smtp-Source: AHgI3IazB20vNU1+t8cE2xeKY3/AOda6OVI1pJlKXuyESBRfxVETccAVIfR5PjAx0YrKqAr6JpGS
X-Received: by 2002:ae9:c106:: with SMTP id z6mr26723069qki.197.1549913286246;
        Mon, 11 Feb 2019 11:28:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549913286; cv=none;
        d=google.com; s=arc-20160816;
        b=Lvqsm8mlmlSMbPAYMWi49QoQ+t6Ib4YmcGK+aj4x05eCfLvYhNhp36+5y6C1RAo8hG
         jQXnrWknKoIdlhVQ53OqdmJK+xH54r7MlqDqoySNr4XkPUYOBh5JwLMKk9mhxlp4dh7u
         NqqjK5UbvUIcV+A3HIkvcw3Sdg99brrCt4Mkqip41F/XJf+vyFxvlfgH7hZDJnOJ4OVa
         Ytjhbt4HRyHYCGTLmlADFCzwYAqNKXmoxs6ctGrHoT68IY+GYJagm5JqET1dJOyUFJcf
         DoVn8tJqBzHDM5lepPFzIGOpgs8ruao37h9C4uYSxjyqsvksaM9Xtup4ldEJEplaTrH/
         Gy3g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=/oF7MB61/9b6c1O5qyvHJGO7XlPNLHdWV5AzzoYEEXE=;
        b=krOpGxXVrvaSittc5Mlr9OSXgQSSu8istY919J9f8w4wOx3MK2lS5BWPTD5e0UoaHo
         BZp3ucyLDG0mgIvh+l40pYAd28a6kBC++Q1Kc4LPPrWy48bWEGsrVI4pBOnSNwk7wCBg
         LGpNKTncq744FatOfght/sqRSCDL0dkeQio1g9gRM6q6p/q9VA7grqGISvaGFS9k+GSM
         v+2dk+WIaVwmciyH7nmR6Zf/xbg3HGaR99TZYyJvlEJnfXtPP+h3hbimj+2l56pcr9ZT
         I9chT1dUsu3/QfsE/AIVQnAK5wY7az1yBWace7mhYHl3XKS4PXIgCfMqEAifQ4KW5dt2
         9O+w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u125si1469748qkf.140.2019.02.11.11.28.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 11:28:06 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 4A055C05001B;
	Mon, 11 Feb 2019 19:28:05 +0000 (UTC)
Received: from redhat.com (ovpn-123-21.rdu2.redhat.com [10.10.123.21])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 402F760A9A;
	Mon, 11 Feb 2019 19:27:58 +0000 (UTC)
Date: Mon, 11 Feb 2019 14:27:56 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Peter Xu <peterx@redhat.com>, Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>,
	Arnaldo Carvalho de Melo <acme@kernel.org>,
	Alexander Shishkin <alexander.shishkin@linux.intel.com>,
	Jiri Olsa <jolsa@redhat.com>, Namhyung Kim <namhyung@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Paolo Bonzini <pbonzini@redhat.com>,
	Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>,
	Michal Hocko <mhocko@kernel.org>, kvm@vger.kernel.org
Subject: Re: [RFC PATCH 1/4] uprobes: use set_pte_at() not set_pte_at_notify()
Message-ID: <20190211192755.GC3908@redhat.com>
References: <20190131183706.20980-1-jglisse@redhat.com>
 <20190131183706.20980-2-jglisse@redhat.com>
 <20190202005022.GC12463@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190202005022.GC12463@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Mon, 11 Feb 2019 19:28:05 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Background we are discussing __replace_page() in:
    kernel/events/uprobes.c

and wether this can be call on page that can be written too through
its virtual address mapping.

On Fri, Feb 01, 2019 at 07:50:22PM -0500, Andrea Arcangeli wrote:
> On Thu, Jan 31, 2019 at 01:37:03PM -0500, Jerome Glisse wrote:
> > @@ -207,8 +207,7 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
> >  
> >  	flush_cache_page(vma, addr, pte_pfn(*pvmw.pte));
> >  	ptep_clear_flush_notify(vma, addr, pvmw.pte);
> > -	set_pte_at_notify(mm, addr, pvmw.pte,
> > -			mk_pte(new_page, vma->vm_page_prot));
> > +	set_pte_at(mm, addr, pvmw.pte, mk_pte(new_page, vma->vm_page_prot));
> >  
> >  	page_remove_rmap(old_page, false);
> >  	if (!page_mapped(old_page))
> 
> This seems racy by design in the way it copies the page, if the vma
> mapping isn't readonly to begin with (in which case it'd be ok to
> change the pfn with change_pte too, it'd be a from read-only to
> read-only change which is ok).
> 
> If the code copies a writable page there's no much issue if coherency
> is lost by other means too.

I am not sure the race exist but i am not familiar with the uprobe
code so maybe the page is already write protected and thus the copy
is fine and in fact that is likely the case but there is not check
for that. Maybe there should be a check ?

Maybe someone familiar with this code can chime in.

> 
> Said that this isn't a worthwhile optimization for uprobes so because
> of the lack of explicit read-only enforcement, I agree it's simpler to
> skip change_pte above.
> 
> It's orthogonal, but in this function the
> mmu_notifier_invalidate_range_end(&range); can be optimized to
> mmu_notifier_invalidate_range_only_end(&range); otherwise there's no
> point to retain the _notify in ptep_clear_flush_notify.

We need to keep the _notify for IOMMU otherwise it would break IOMMU.
IOMMU can walk the page table at any time and thus we need to first
clear the table then notify the IOMMU to flush TLB on all the devices
that might have a TLB entry. Only then can we set the new pte.

But yes the mmu_notifier_invalidate_range_end can be optimized to
only end. I will do a separate patch for this. As it is orthogonal as
you pointed out :)

Cheers,
Jérôme

