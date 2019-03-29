Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2687AC4360F
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 13:42:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DEA1A217F5
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 13:42:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DEA1A217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7E77A6B000D; Fri, 29 Mar 2019 09:42:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 794766B000E; Fri, 29 Mar 2019 09:42:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 684706B0010; Fri, 29 Mar 2019 09:42:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1B0F26B000D
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 09:42:48 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id s27so1101422eda.16
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 06:42:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=j4HggFgP/KO2utS67OktA0Sgrokl0I7flKv0+nEEwt4=;
        b=E5A/Ug3axxDueuLcXmgv8rq2wLoNjp2/xJxFxtHTMQ19dl73swEWROb1xX7O9x0Okn
         kFkSaU+/rN1yKmZCYmVklEerC3/onwk11nBFwyv5UuQfAIsUyDLWbFwOJ5Q+P8JMUi24
         NHTHd9M2N4e0TE08hhAY3MgjOf3J8jltX1GO2KQE6KwRsZG4flF9FXZK6qOnoLhpLXHW
         kZeqrUtqyHlQ7VNVowwpECImdSomocy5xrVNsTr9g9uDK0g8axgKrfaZ9Urw1Kcz0ID+
         Pbvc7AUaugMGQ9iygok906tacmEg5YIIHrpnU5qhsOCf7BjSbaDezx9499IWdNjihXh/
         LLmg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVYRBDiN65u/n8GdFEHbtxo+qGq4SU9LVjXYLus8M6Am6qevMgL
	NeGTJj0DeLYeSDtPplJUDIA6RO38UTx2ragvF7xfSZG+E7CnD3BQjWZtvRTbZdMdg4Z4bpwiu7T
	0rLPsDx+z6Bqe0oEb7tY3L3fdJPXWHYHFeAcRCHR25v3NYGGXMvSS0QGLIX8UV5I=
X-Received: by 2002:a17:906:b756:: with SMTP id fx22mr27662483ejb.192.1553866967648;
        Fri, 29 Mar 2019 06:42:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyMSdH5KTPXdIWcw7DYJl/MwX5FgntB2vi66h0zU5/kqpbOJpdvp31NVHLkEzvl1IduL7kn
X-Received: by 2002:a17:906:b756:: with SMTP id fx22mr27662386ejb.192.1553866965537;
        Fri, 29 Mar 2019 06:42:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553866965; cv=none;
        d=google.com; s=arc-20160816;
        b=MzsEUJ+CtC5e5drepDLYKxuOwuVluo2cUsmGho8WZ6PApHgZ2QvIUiQGcntpXwk+2n
         dxUff0DqKb8wtxAy2n59oD//R3KG0i4A8N00tVeN3l2WXp/dl5Jx9cCL7/RaCo0t9VYK
         cJaR8gq9YTt+Vx1lBRE3U8dz6JKXrekPs5ZYPOC8ilCmP+7MZ9jSnsU5wOfTK8wQTxTt
         xmyFy2UN/sWue0jqiZgd+CTN9z/iKe/40AO9z22sMmaVaYTaeZGip9gJxzFqRepL+UdD
         mSz1DsoVZuKg3daW3syL/cIS05ImySLmdRQH7rhMNJaMeiOB39A9Xsy81kY6+6z9nl2k
         l6Ew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=j4HggFgP/KO2utS67OktA0Sgrokl0I7flKv0+nEEwt4=;
        b=vl2Fc/GUSldyEnmbWSMAmCRz9UBy8EMFO5DHEtiQ6eVw8cDybKZ0u8RapkCwJ5JYzx
         rzxPwriHk2E4H0Q7sXZCo0gQnZEq1XYOFxPACuV7RCU1pdj5rPUpogbvkV3iUWSxLk14
         XxwBQeaBTF/t2eIfSc1hF41avJ7+VwPWtGd4WVAozHlLVe2EP8FCLV/wnClmofg/tZ3x
         MvzJK9f3LzDgAjr8eifIaILFkvqJjfswtqJm+mXRByykSnwQLq/TvSvH/OFD7UZuPUTX
         nOnUQMZkYrexcN2c32dEYOhiNe3vBnBv9acvahNuNGfrU8m8+0+DEUc3vfDQWH+FxRS5
         zkNQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z27si1122148edl.146.2019.03.29.06.42.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Mar 2019 06:42:45 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id E8E5CB00F;
	Fri, 29 Mar 2019 13:42:44 +0000 (UTC)
Date: Fri, 29 Mar 2019 14:42:43 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Oscar Salvador <osalvador@suse.de>
Cc: David Hildenbrand <david@redhat.com>, akpm@linux-foundation.org,
	dan.j.williams@intel.com, Jonathan.Cameron@huawei.com,
	anshuman.khandual@arm.com, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH 0/4] mm,memory_hotplug: allocate memmap from hotadded
 memory
Message-ID: <20190329134243.GA30026@dhcp22.suse.cz>
References: <20190328134320.13232-1-osalvador@suse.de>
 <cc68ec6d-3ad2-a998-73dc-cb90f3563899@redhat.com>
 <efb08377-ca5d-4110-d7ae-04a0d61ac294@redhat.com>
 <20190329084547.5k37xjwvkgffwajo@d104.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190329084547.5k37xjwvkgffwajo@d104.suse.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 29-03-19 09:45:47, Oscar Salvador wrote:
[...]
> * memblock granularity 128M
> 
> (qemu) object_add memory-backend-ram,id=ram0,size=256M
> (qemu) device_add pc-dimm,id=dimm0,memdev=ram0,node=1
> 
> This will create two memblocks (2 sections), and if we allocate the vmemmap
> data for each corresponding section within it section(memblock), you only get
> 126M contiguous memory.
> 
> So, the taken approach is to allocate the vmemmap data corresponging to the
> whole DIMM/memory-device/memory-resource from the beginning of its memory.
> 
> In the example from above, the vmemmap data for both sections is allocated from
> the beginning of the first section:
> 
> memmap array takes 2MB per section, so 512 pfns.
> If we add 2 sections:
> 
> [  pfn#0  ]  \
> [  ...    ]  |  vmemmap used for memmap array
> [pfn#1023 ]  /  
> 
> [pfn#1024 ]  \
> [  ...    ]  |  used as normal memory
> [pfn#65536]  /
> 
> So, out of 256M, we get 252M to use as a real memory, as 4M will be used for
> building the memmap array.

Having a larger contiguous area is definitely nice to have but you also
have to consider the other side of the thing. If we have a movable
memblock with unmovable memory then we are breaking the movable
property. So there should be some flexibility for caller to tell whether
to allocate on per device or per memblock. Or we need something to move
memmaps during the hotremove.
-- 
Michal Hocko
SUSE Labs

