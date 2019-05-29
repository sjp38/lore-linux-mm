Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DE35AC28CC0
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 16:25:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B0C9023D60
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 16:25:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B0C9023D60
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4DD9D6B026A; Wed, 29 May 2019 12:25:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 48F836B026B; Wed, 29 May 2019 12:25:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 356FC6B026C; Wed, 29 May 2019 12:25:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id F2E936B026A
	for <linux-mm@kvack.org>; Wed, 29 May 2019 12:25:35 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id t58so4128997edb.22
        for <linux-mm@kvack.org>; Wed, 29 May 2019 09:25:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=vpCltnTpBBzrvMPQM2zJC6hyMjOFBNBiZffn1VFJGxk=;
        b=IICrfQIWGZgLfyp6HwiFd7JQtWP76FRrYeOrFKrMEveVSRUJ6OSxHMJRKhnI++OC0x
         YrfnS10sf0nfmjtAJiNF5nD2TRMjFOC6YLaywY0IZmgKckgAb7lGcO2tCccXOgCwirpx
         1AYxubE1G074Q6VLNYN07ax4eZjHBhaxWJEd//52XQ2ZkYliWoDEa+wdnZbqXJGEWWQv
         iO7RuUz5MF3iCzx6fXrnvqIXfb0Nz/mO8cOMkEy+KV/1FpZjzP5XsVU73Ni/SCXzfusb
         u/GHxLuyqxjHWtfzThRdy/WtLRmZMA7dhDTkAO3C2W4I/ELvRidAuekHu5ivtvraR+AG
         oS/Q==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWHfRVXiUk7ZGTUP9Y1brrrrA9q5w7SXCRt3IquGRTT8RGn60/u
	Ry0ZdEzq72RDFWuFcJa7conBT+cWaP+R5OSkGstzaAeBNd0KyxhI+lt5xkYUN4rXdpk2ELpKONI
	n5vd0IGqV6s1fs2U6gfW3CtJlb0M3jQ7xHbj/jVphzgX9iP6zQ6ScUpN6mcELBCg=
X-Received: by 2002:a17:906:1b57:: with SMTP id p23mr27810042ejg.24.1559147135575;
        Wed, 29 May 2019 09:25:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwOARDUhnpbBucygFH5THYwx5/b5qG1now2tuYAiNpxTZU1U3iMJv1YuJIw502NlvacFoMt
X-Received: by 2002:a17:906:1b57:: with SMTP id p23mr27809962ejg.24.1559147134617;
        Wed, 29 May 2019 09:25:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559147134; cv=none;
        d=google.com; s=arc-20160816;
        b=xyj2Cij/UARsxA+gws4MS+gAgCK1gbYhDpKGXiyYFjOexFTSH4zfi0WXhJBM6AE0+4
         8Fy5OOMZRjaaziXdB/6QWT/tVTUS6+lT1j62jYFFfQcuZdQ8E5P88HlmoQbY0rEoA3aa
         jTSv8Lv7q5ceAU1qvYGmjdBfXYuZisY0LGqSXMHDJzM5q+zm6wStUH7HUfH6HmwfPVg/
         5gy1xX4EEqY86wWpgH2sZhxqa1l5V6APCgkGAjutr8VhtZPGMo9INqmzbPYkPXrV8bkp
         +mYJMW8PDY4cK0l5JWUL9pWONPSxIarIr8uqs8mNXD9Jttn4xlKIcTN7D3ybdco0fNUX
         H3tA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=vpCltnTpBBzrvMPQM2zJC6hyMjOFBNBiZffn1VFJGxk=;
        b=RgoHwY3A0S7c9704MpOf3+SMDbzf024lwJ4/pzcZIrdf9X1XKQLMqxAhlTeOW/6KS0
         nYFuI7neHgy3IDDjLZBgakFo98vOz0s+qP/RPtwMPI2q91qwg5kaqXIJy2Je4DY5Jxj3
         33vWsLBT0pfiyHzbwHFjQRcPczR2Zqt3eaPR5XQ2U1h+B8eKKiE4JN5Pt81Vu5xPEroe
         xeDZ4HxeEaVEYN9+kHeVZLZmbwSubqTiaUZIbGNQbXSko3D9TB8iUVL2XBi6HsSRAcfU
         Y8xDPj3PyOzNJljJDGsVNsGemNToAFww8Eg0rXKZv355p6BuAPglh2SSZ7dNeeUy2SI4
         Yu3Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t1si28611ejz.165.2019.05.29.09.25.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 May 2019 09:25:34 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 206D5ADEA;
	Wed, 29 May 2019 16:25:34 +0000 (UTC)
Date: Wed, 29 May 2019 18:25:32 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Dianzhang Chen <dianzhangchen0@gmail.com>
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com,
	iamjoonsoo.kim@lge.com, akpm@linux-foundation.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/slab_common.c: fix possible spectre-v1 in
 kmalloc_slab()
Message-ID: <20190529162532.GG18589@dhcp22.suse.cz>
References: <1559133448-31779-1-git-send-email-dianzhangchen0@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1559133448-31779-1-git-send-email-dianzhangchen0@gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 29-05-19 20:37:28, Dianzhang Chen wrote:
[...]
> @@ -1056,6 +1057,7 @@ struct kmem_cache *kmalloc_slab(size_t size, gfp_t flags)
>  		if (!size)
>  			return ZERO_SIZE_PTR;
>  
> +		size = array_index_nospec(size, 193);
>  		index = size_index[size_index_elem(size)];

What is this 193 magic number?
-- 
Michal Hocko
SUSE Labs

