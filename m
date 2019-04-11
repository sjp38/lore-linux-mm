Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D4B72C10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 08:19:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7911E205F4
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 08:19:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7911E205F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B34186B0005; Thu, 11 Apr 2019 04:19:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AE2796B0008; Thu, 11 Apr 2019 04:19:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9AADF6B000A; Thu, 11 Apr 2019 04:19:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4EF696B0005
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 04:19:03 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id f9so2691978edy.4
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 01:19:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=IpHH63rwu1N66g73R1NmJJuGOt1N+96SYUw/x8ZJSBs=;
        b=OOpyep471Bj3kGTrGp8kR1zVXskQdOG1i/TjEtg7v2EzJEW+5uM9WZ63blun/V0BDY
         8bmKONCwnTjvSBTenguvZBi5/VPvOeCQDdM22ACszwzpRKvC78Z/lWTyuANH/mb2FQti
         hNVPRhvvY9wJtPrWnyRDuaQTAqBHlKD+gD9ZCzN8TGGw6aHZis2c8BFTM8VoxJpln9Fc
         zMinJA5lYVVcrZSD9D9PWRYF9kfLdiWp5KOVZWEvqt+hf2dbP6BwuoJT8ak5hsalvOrP
         oMdetKZay6k/WD+ttxTDj+bS+wYCocdxgi5YIwkf1iEaCyEh516t9WHJz8RtrYbYlZoy
         HFEg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXSoAVLvg8PhNkCTSI1EKHW/qDQtlyK/fSMPpgL8FF525x9A3Bs
	oCgBAwWHYq9bjkDEcvw57Ob0rmwSfF9Hfo8QTTJiVZX8K1ScpR8+8o1l00LcEvRic4GI6GtJ9sA
	ovageSLkwqvljerNPEyU+0O7cSx+Pf1sVfpO0iF471ap/mVhtz9WVARyJleFfJIo=
X-Received: by 2002:a17:906:eb96:: with SMTP id mh22mr3126611ejb.186.1554970742741;
        Thu, 11 Apr 2019 01:19:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzdwUp7XtDVu2u2mg/wWi2429fWS+oy+i9Ox/js/asQUCk2+3hoF2qvZETkjY+ArFoW2AwA
X-Received: by 2002:a17:906:eb96:: with SMTP id mh22mr3126571ejb.186.1554970741836;
        Thu, 11 Apr 2019 01:19:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554970741; cv=none;
        d=google.com; s=arc-20160816;
        b=PM0sGf8hkZ0s/Pf2F9oSvX//RKi1H7XgE5eDxe8w54bZ/bf6Xljoxy7CJn1sse7G10
         ZR5U3ijPimkeje7ckQuH43MegJr8TsOsiutE62tCemWOhr1aGJ5wIiFdmg+avugQGUI5
         4wNHRJQ3pivRGy7oltYFSL7dJZopG9C02QoE9Xjo2L48VI9gf9WORqoVVqkkt+YUSivp
         UndbdPu4APN5i2M4J0pi3TpCqIvGLnJXsgCDMj6pR88Ck9rBGY/zU/4gws9dExqOm5SP
         Et2FRtR91uHgXdzM8qC74K0N7MtsFrJvPgnQgklI+yPCl7kDSCFU9V2C/Gr+xWkkBL3n
         st0g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=IpHH63rwu1N66g73R1NmJJuGOt1N+96SYUw/x8ZJSBs=;
        b=ggV7KwT9gkS4BVtisSAk90fTuoGEis8+uPpD+ZsEIReqbr1FUN54ZOcPK77OWEP0af
         /Uf/NaYh3oi1hBTyuv5UFfHZVg5XTjAYWBtCRUpoJ9DvZ1Q0lWZXbZvntQ+Rh6B2E+V+
         kczGnJkwoq8dBdFI1eBkFu3W5msq7BO01U7o8qBVwajKNv+4sMkd+5EaLo6pWALydzom
         Re2juq7PwNS9067iXWC2RjOjpmHldc6I/qagd65v3hjsz6RpFLYFdH8OrdE10J6er4zU
         sdNRovteP5NncN21kPWsKDB2kDjSEhglwTEQ2ztlmA6T8xwBwKCXlDV8KFqH1cRFQehi
         rrkg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 20si8219589edx.64.2019.04.11.01.19.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 01:19:01 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 3F6C4AD65;
	Thu, 11 Apr 2019 08:19:01 +0000 (UTC)
Date: Thu, 11 Apr 2019 10:19:00 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Yufen Yu <yuyufen@huawei.com>
Cc: mike.kravetz@oracle.com, linux-mm@kvack.org,
	kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com
Subject: Re: [PATCH v2] hugetlbfs: fix protential null pointer dereference
Message-ID: <20190411081900.GP10383@dhcp22.suse.cz>
References: <20190411035318.32976-1-yuyufen@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190411035318.32976-1-yuyufen@huawei.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 11-04-19 11:53:18, Yufen Yu wrote:
> This patch can avoid protential null pointer dereference for resv_map.
> 
> As Mike Kravetz say:
>     Even if we can not hit this condition today, I still believe it
>     would be a good idea to make this type of change.  It would
>     prevent a possible NULL dereference in case the structure of code
>     changes in the future.

What kind of change would that be and wouldn't it require much more
changes?

In other words it is not really clear why is this an improvement. Random
checks for NULL that cannot happen tend to be more confusing long term
because people will simply blindly follow them and build a cargo cult
around.

> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Suggested-by: Mike Kravetz <mike.kravetz@oracle.com>
> Signed-off-by: Yufen Yu <yuyufen@huawei.com>
> ---
>  mm/hugetlb.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 97b1e0290c66..fe74f94e5327 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -4465,6 +4465,8 @@ int hugetlb_reserve_pages(struct inode *inode,
>  	 */
>  	if (!vma || vma->vm_flags & VM_MAYSHARE) {
>  		resv_map = inode_resv_map(inode);
> +		if (!resv_map)
> +			return -EACCES;
>  
>  		chg = region_chg(resv_map, from, to);
>  
> -- 
> 2.16.2.dirty

-- 
Michal Hocko
SUSE Labs

