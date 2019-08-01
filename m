Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59EC8C19759
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 07:34:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 165B2205F4
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 07:34:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 165B2205F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9DEC78E0003; Thu,  1 Aug 2019 03:34:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 968398E0001; Thu,  1 Aug 2019 03:34:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 82FDF8E0003; Thu,  1 Aug 2019 03:34:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 311AB8E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 03:34:11 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id a5so44161043edx.12
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 00:34:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=LgmDCj7NppHPA9RsqC4Nxn789W2qoYvTcOHty3OjxLw=;
        b=Rx4jKtrILc3NowlBgwyEDqk6hS56Vr/4KIJTIhZVDu++sQ+hliwXZOjff7E4KbxWir
         7JaPHQo2expDiS3mLCmGUHJPEwH8gSZPtFYimGlVSdo6exXsaMC36oypha9mja5LZo8H
         vfQZGzsueRL24/nonII99RxpGpVDN7oQQHs6+/HxvoJ3Yj/oHV7EeKI4hKLu2/MAqV1Q
         5JbdBbOkZ/f90QkqbcmoX4Uq/2wrnHvhJ0Try7i479Ju2/g2cv81lWhEJeMnQNcg5nGz
         wLBVev0STRFsPGWe04NOotlCDoavkA3p1ISB2oJT0LvR5r30bb3AR8POOUXYlNrmpcXK
         mMCQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAV2hgtmWnyh3wWbJJbBFVO6Ikw9xKr23/4JNpt4NlHj89oPKGBp
	ondcS20K/rbZLO3TPudiVbN7hj7BQ845N9SqcxLQgilhDcDjZxMGBK6P77q9BxEd2n4s8cqqm27
	2x9bMBEEa+isnglySfagGlf99Wi4ko0tQRyfyj6A3kylgMz+sJ0tTZUttkq5MOoI=
X-Received: by 2002:a05:6402:896:: with SMTP id e22mr107672093edy.202.1564644850761;
        Thu, 01 Aug 2019 00:34:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzfkcqOyVF1j4PJX9X9Re+JV6FwDTh8yJpQqLNrFmQ16TGH2MEbYwJxPvOYAJhTkZqi28T9
X-Received: by 2002:a05:6402:896:: with SMTP id e22mr107672047edy.202.1564644850159;
        Thu, 01 Aug 2019 00:34:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564644850; cv=none;
        d=google.com; s=arc-20160816;
        b=hIJ0qLFOzNMp+CbOUUom7SVBS5k7oH/VL9hP9D+iWUBh4R1udZ89G2efX67p6oF4O0
         bEF8CH7PWX9oYFetP7ELINNvKyQMszhCJ3zHZIcKRSqOExrQ7/HcabtTn311qNXkiWxv
         rXiQM0XB2kuOpc4CsDnUXTnnmV8kOEcMVQ0MpOsmrYWSHmNddwcDfySa4FffLd8G4Nzo
         rNJ/MwQt998PiVXpqviraA5hlv9ObC3xodUdLbIEWX/xqH7UcSp52zfyjCjJd51VY6CM
         unQjXLdm2zL0j4IDauTFEMGgcx4LY5He9wCwsAB3Gax5fkIZD0P1Wl1TF5NeQm2jr1vQ
         xvyg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=LgmDCj7NppHPA9RsqC4Nxn789W2qoYvTcOHty3OjxLw=;
        b=eCX6BnDSio+ge/s+3pIMQ4Q6WcnXEsB1sPVZR80p/HmRACapH13rvhgit+UMpJw4aI
         1ER1PHQucXv8nAjEn1qXTGtzetuB/tzIWFybnGhREadZFzoMituzqaCdyb6UDHPir+Gk
         PSyCFu9fnCH8RFK8QWM9EdXj8HimiVXiDR0GpGBKcu8s4Ob7guzlg0YBcv8CF1e5vdEq
         3zHSF0ncyicnI5txb9VI0nPcd5DdaTAkcloiF7rUBx2El6dWK+kAFYIYkf/P37y2BMUF
         Vh/6XEQWNY2rNTUGs/Szs637dYh8f4C4qNrJBkO0BTB6oOm/l1wilcmK0sqwjiI4gaes
         tY6Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i12si21995109edq.333.2019.08.01.00.34.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 00:34:10 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A0F2CAC91;
	Thu,  1 Aug 2019 07:34:09 +0000 (UTC)
Date: Thu, 1 Aug 2019 09:34:07 +0200
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
Message-ID: <20190801073407.GG11627@dhcp22.suse.cz>
References: <887b902e-063d-a857-d472-f6f69d954378@redhat.com>
 <9143f64391d11aa0f1988e78be9de7ff56e4b30b.camel@gmail.com>
 <20190702074806.GA26836@linux>
 <CAC6rBskRyh5Tj9L-6T4dTgA18H0Y8GsMdC-X5_0Jh1SVfLLYtg@mail.gmail.com>
 <20190731120859.GJ9330@dhcp22.suse.cz>
 <4ddee0dd719abd50350f997b8089fa26f6004c0c.camel@gmail.com>
 <20190801071709.GE11627@dhcp22.suse.cz>
 <9bcbd574-7e23-5cfe-f633-646a085f935a@redhat.com>
 <20190801072430.GF11627@dhcp22.suse.cz>
 <e654aa97-6ab1-4069-60e6-fc099539729e@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e654aa97-6ab1-4069-60e6-fc099539729e@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 01-08-19 09:26:35, David Hildenbrand wrote:
> On 01.08.19 09:24, Michal Hocko wrote:
> > On Thu 01-08-19 09:18:47, David Hildenbrand wrote:
> >> On 01.08.19 09:17, Michal Hocko wrote:
> >>> On Thu 01-08-19 09:06:40, Rashmica Gupta wrote:
> >>>> On Wed, 2019-07-31 at 14:08 +0200, Michal Hocko wrote:
> >>>>> On Tue 02-07-19 18:52:01, Rashmica Gupta wrote:
> >>>>> [...]
> >>>>>>> 2) Why it was designed, what is the goal of the interface?
> >>>>>>> 3) When it is supposed to be used?
> >>>>>>>
> >>>>>>>
> >>>>>> There is a hardware debugging facility (htm) on some power chips.
> >>>>>> To use
> >>>>>> this you need a contiguous portion of memory for the output to be
> >>>>>> dumped
> >>>>>> to - and we obviously don't want this memory to be simultaneously
> >>>>>> used by
> >>>>>> the kernel.
> >>>>>
> >>>>> How much memory are we talking about here? Just curious.
> >>>>
> >>>> From what I've seen a couple of GB per node, so maybe 2-10GB total.
> >>>
> >>> OK, that is really a lot to keep around unused just in case the
> >>> debugging is going to be used.
> >>>
> >>> I am still not sure the current approach of (ab)using memory hotplug is
> >>> ideal. Sure there is some overlap but you shouldn't really need to
> >>> offline the required memory range at all. All you need is to isolate the
> >>> memory from any existing user and the page allocator. Have you checked
> >>> alloc_contig_range?
> >>>
> >>
> >> Rashmica mentioned somewhere in this thread that the virtual mapping
> >> must not be in place, otherwise the HW might prefetch some of this
> >> memory, leading to errors with memtrace (which checks that in HW).
> > 
> > Does anything prevent from unmapping the pfn range from the direct
> > mapping?
> 
> I am not sure about the implications of having
> pfn_valid()/pfn_present()/pfn_online() return true but accessing it
> results in crashes. (suspend, kdump, whatever other technology touches
> online memory)

If those pages are marked as Reserved then nobody should be touching
them anyway.
 
> (sounds more like a hack to me than just going ahead and
> removing/readding the memory via a clean interface we have)

Right, but the interface that we have is quite restricted in what it can
really offline.
-- 
Michal Hocko
SUSE Labs

