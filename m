Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AFB47C433FF
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 07:24:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7385A206A2
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 07:24:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7385A206A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1CF478E0003; Thu,  1 Aug 2019 03:24:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 159678E0001; Thu,  1 Aug 2019 03:24:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F3B2E8E0003; Thu,  1 Aug 2019 03:24:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id A44848E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 03:24:34 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id r21so44158402edc.6
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 00:24:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=zLvXsQ8HNdjBM+AzuizHneH7ApFl7WVGHvnSGmFW7Lg=;
        b=cWreAR9qfugaSlfyBNkOpZvHgfsmvDR67gZrj38UnRLqGWP6qM8Rx/Wi0G9SkLpNIE
         WriQ81dOrC4Z5f60Ze5mIwcmY0+xAF1W7tBGWgAP+gACkpw3z9L30nLNdp7Gvxc9l27H
         eJeEArIgJ3N+UaPzF/Mi5Q41IjGyMwVe3uCKmCHoMQczDSuabsxI2kwyEXBfZ+yhRgz6
         gXmW9eEADT9XvLG4exg7Y6mxUR1bHO6a79BnhISzOyEthhDW6LCOkboRyuaLt6bg93Dx
         VkNY+Dd2lulixC0vpphEelRHiAN8PhLG2gEb1hST8nvMzSuNMKQv11ELmZx17RKDpFVc
         uGPQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUCVR85afEyHaOZ3QNQpwFNzfnw4qapKsNFWEPBOrnH2dzw/vxs
	7gmwWjSZiDTCQXak/nJjaNUaxdCpuW7Tuql+dHn3aO32nAOnjn5S2sosUOfr9wP3f6c7z2Gws+G
	tjJyTRzX0XXX9ZYsHZeSE9OQsNQfvhRAn8YpiLhSraaqc6RVy0vgQP6bLBAQRX/c=
X-Received: by 2002:a17:907:217b:: with SMTP id rl27mr98305417ejb.154.1564644274227;
        Thu, 01 Aug 2019 00:24:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwF9oIxXu/hqxsjaiYeO0Bmii/rCHzVuKUyKyvCNlbMm/RTpZMcubcR54/VBMDrP7ku0IUu
X-Received: by 2002:a17:907:217b:: with SMTP id rl27mr98305363ejb.154.1564644273583;
        Thu, 01 Aug 2019 00:24:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564644273; cv=none;
        d=google.com; s=arc-20160816;
        b=RZ0yjSAZm+de26ffck/4KFfLluOU6fgtIh8E/v0D6aXHPyoztCBQo+BkMsqHYsGh+E
         TJfd7JSr2II6Y0wVPc5w6+89XR35J3LtfKKClWGaB11dpAm0jGDSf9dJhHqP+WXGpkXz
         oMDzm5S/WddsXUUMhMQWiMrcDGSwcG853P1KZTK74CROr+Kcm5nYVQDCCJxkdoTVzq/6
         VRk2J7Lnb3Df8FybkILLn+KuiIXhesjVC+MGGPrWObfUqIEs/nQk11G8ImelxGEtuX1c
         cJt6MJmwuZk7Rc7hU8QPF5eZmk7ko8QAjzctMqw6mOWdQ+Xs8WwViPuocp20ahup0bA9
         In7Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=zLvXsQ8HNdjBM+AzuizHneH7ApFl7WVGHvnSGmFW7Lg=;
        b=gY6tmf0Jm26xX59ZcMAHSDjLaPZ3j0MHauxWGY4eDWmPFt6plR0dADxPUit8sNdKcd
         P4K1nATk+mrTRKGXZ635JWiPck0xcJvMq1W5Vta/dyOjhFIMnGk+38hsty4jwY9iLvri
         +u77zh/HSLtEKt9+/o6Ekv3ot9xEM21oPtV+IsRX+p9P7qQRCIItozhxE3beFVzX7n5S
         BHYeZyzUTPIkLp8OS8+BrPiIKDVWZDBlupc9LTJe51/rpyJUaFXqvpw+UmQhs7WY/RvY
         J5ULgtBecuWV361BNGSvlfzFfdl7gxcuqSsJF2SMS1M86JewVzGSzhPUcA4fv1iXVp12
         QiMw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q25si20375632ejs.275.2019.08.01.00.24.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 00:24:33 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id C8CFDB022;
	Thu,  1 Aug 2019 07:24:32 +0000 (UTC)
Date: Thu, 1 Aug 2019 09:24:30 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Hildenbrand <david@redhat.com>
Cc: Rashmica Gupta <rashmica.g@gmail.com>,
	Oscar Salvador <osalvador@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>, pasha.tatashin@soleen.com,
	Jonathan.Cameron@huawei.com, anshuman.khandual@arm.com,
	Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 0/5] Allocate memmap from hotadded memory
Message-ID: <20190801072430.GF11627@dhcp22.suse.cz>
References: <2750c11a-524d-b248-060c-49e6b3eb8975@redhat.com>
 <20190626081516.GC30863@linux>
 <887b902e-063d-a857-d472-f6f69d954378@redhat.com>
 <9143f64391d11aa0f1988e78be9de7ff56e4b30b.camel@gmail.com>
 <20190702074806.GA26836@linux>
 <CAC6rBskRyh5Tj9L-6T4dTgA18H0Y8GsMdC-X5_0Jh1SVfLLYtg@mail.gmail.com>
 <20190731120859.GJ9330@dhcp22.suse.cz>
 <4ddee0dd719abd50350f997b8089fa26f6004c0c.camel@gmail.com>
 <20190801071709.GE11627@dhcp22.suse.cz>
 <9bcbd574-7e23-5cfe-f633-646a085f935a@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9bcbd574-7e23-5cfe-f633-646a085f935a@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 01-08-19 09:18:47, David Hildenbrand wrote:
> On 01.08.19 09:17, Michal Hocko wrote:
> > On Thu 01-08-19 09:06:40, Rashmica Gupta wrote:
> >> On Wed, 2019-07-31 at 14:08 +0200, Michal Hocko wrote:
> >>> On Tue 02-07-19 18:52:01, Rashmica Gupta wrote:
> >>> [...]
> >>>>> 2) Why it was designed, what is the goal of the interface?
> >>>>> 3) When it is supposed to be used?
> >>>>>
> >>>>>
> >>>> There is a hardware debugging facility (htm) on some power chips.
> >>>> To use
> >>>> this you need a contiguous portion of memory for the output to be
> >>>> dumped
> >>>> to - and we obviously don't want this memory to be simultaneously
> >>>> used by
> >>>> the kernel.
> >>>
> >>> How much memory are we talking about here? Just curious.
> >>
> >> From what I've seen a couple of GB per node, so maybe 2-10GB total.
> > 
> > OK, that is really a lot to keep around unused just in case the
> > debugging is going to be used.
> > 
> > I am still not sure the current approach of (ab)using memory hotplug is
> > ideal. Sure there is some overlap but you shouldn't really need to
> > offline the required memory range at all. All you need is to isolate the
> > memory from any existing user and the page allocator. Have you checked
> > alloc_contig_range?
> > 
> 
> Rashmica mentioned somewhere in this thread that the virtual mapping
> must not be in place, otherwise the HW might prefetch some of this
> memory, leading to errors with memtrace (which checks that in HW).

Does anything prevent from unmapping the pfn range from the direct
mapping?
-- 
Michal Hocko
SUSE Labs

