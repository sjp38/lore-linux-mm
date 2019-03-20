Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 73090C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 19:53:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3EF9E2083D
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 19:53:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3EF9E2083D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CE65B6B0007; Wed, 20 Mar 2019 15:53:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C48176B0008; Wed, 20 Mar 2019 15:53:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AE98C6B000A; Wed, 20 Mar 2019 15:53:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4EB706B0007
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 15:53:25 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id d5so1333289edl.22
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 12:53:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=J0gFMNuQOIttPlDvgfSbIkR76jb+uXV7WTyeLdLEtjc=;
        b=TtowfaUmNDYaFzgsFbtvQghkjfpyZeEw26teWwjwkh28pWgQ5FurN5PNCalFfSBEf8
         rkz9ElXyMGjZYvTjZfjb2sy4Jl36c4fY2AeDjDLlTSozs6ARy+XN1Q42MAxLKt2rP+yD
         VOBQt4qyPvRMm0Kkwn/wwvqh8RAR20dKJBuOGqgA3BsbLDyoAjl46utqde+5sF3VMFp8
         WCrnD+yXiJDy9FKXXjhUf+N0TI8o5N9WcHiWpvqaSHJUZE3Loa+Oez37BM2QsyzYFsMH
         E70SiRUDV2E70OiIoR08F1sAlc8Ars/xb2wqx/eyC6YGoZQl62uVnU+m0i0jrJL8gvW+
         Q67g==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWXTvjWPIMj54ngauqIScK1b5CMh5znKoErF8xXxD6ISgoChj1n
	nkbHq2elxYyByr6GYGJlXTHq75IegM7ubj1yBsvhN43OChqrHmmnFyY+iX7+GQesQDirBsDPeiv
	Y9lb+BrVAtBnWGXoMSrZxSUlXYThBb7xMnxP+DiiZhZi5jBxC4+kZulxWPSinoAY=
X-Received: by 2002:a17:906:41b:: with SMTP id d27mr35348eja.69.1553111604882;
        Wed, 20 Mar 2019 12:53:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzr2gab+Pxc/gtar7ZRJfAp1kwFab4XXTpgPCiQH7m04mG0ytX3N53ReDoUT8+3yC9E4wWJ
X-Received: by 2002:a17:906:41b:: with SMTP id d27mr35312eja.69.1553111603930;
        Wed, 20 Mar 2019 12:53:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553111603; cv=none;
        d=google.com; s=arc-20160816;
        b=eXX6yM6Y7mTWxV0V4Tbv9ehWM+Dp0z9zxUjJF0z2SlsL2hK6EnF+BVKDNBCfLl0IOI
         OlmatweEzIiqL5kURT1pZEhi8y/xUOOOgypB+vL+eJF3lvWBO7A2ztAoRu9/iM/2m3Xy
         VRedYv+myNXcQXnYGC9TQFp+MawLeHO07WMdasE7XZ8prq+dVGHlmzGKSmTPqexdpkyf
         7sa6UfCkSECcK4Dz5KGFUrkLWrxlxTUJ162gQwq0xg8hcDv7wzQb6SlNZ5jV3iufKWIz
         F1JgoKSx112hRYeiOlGeVouKR2OM0gvqmQsvitRdlBu26gy1q1a0ZMb3xsCkLf3SC9pg
         ZGwA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=J0gFMNuQOIttPlDvgfSbIkR76jb+uXV7WTyeLdLEtjc=;
        b=ljX1y1hyoyRzJwqdfveKmczyr2/tTQP3lfs4vd53NsEUbiX7iENKaqAFf9IAwbVoQJ
         20ecGdwaiNAuWaFi57+XDAzHyJOgsFadP4fOU23ZUw0s9/wZbbegwsRM2gcv+Gz0P8cq
         sr5bcvGHO5ij9hJCc2829w5A8itOAQDd7nvJh9JCWZGZT/OLbfxZIARr0o4ky6VGweXk
         vvVap1XQo9JVEo/suI7lRInftnytG+W4rZ2F3x/kaK3MVeQcRnzjqWWslX9Bl3ydmz6a
         ac42y/cgNDBcaoadJsOo3pkeatuRFsCCFRcSNioaPy4kLD0DvV7C6rsdvnaKeOV/zJrV
         I0UQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m8si928348ejk.24.2019.03.20.12.53.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Mar 2019 12:53:23 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 2C219AEF5;
	Wed, 20 Mar 2019 19:53:23 +0000 (UTC)
Date: Wed, 20 Mar 2019 20:53:21 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Baoquan He <bhe@redhat.com>, linux-kernel@vger.kernel.org,
	osalvador@suse.de, david@redhat.com, richard.weiyang@gmail.com,
	rppt@linux.ibm.com, linux-mm@kvack.org
Subject: Re: [PATCH] mm, memory_hotplug: Fix the wrong usage of N_HIGH_MEMORY
Message-ID: <20190320195321.GE8696@dhcp22.suse.cz>
References: <20190320080732.14933-1-bhe@redhat.com>
 <20190320121209.5cd30d7b15f299df7d97d51e@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190320121209.5cd30d7b15f299df7d97d51e@linux-foundation.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 20-03-19 12:12:09, Andrew Morton wrote:
> On Wed, 20 Mar 2019 16:07:32 +0800 Baoquan He <bhe@redhat.com> wrote:
> 
> > In function node_states_check_changes_online(), N_HIGH_MEMORY is used
> > to substitute ZONE_HIGHMEM directly. This is not right. N_HIGH_MEMORY
> > always has value '3' if CONFIG_HIGHMEM=y, while ZONE_HIGHMEM's value
> > is not. It depends on whether CONFIG_ZONE_DMA/CONFIG_ZONE_DMA32 are
> > enabled. Obviously it's not true for CONFIG_ZONE_DMA32 on 32bit system,
> > and CONFIG_ZONE_DMA is also optional.
> > 
> > Replace it with ZONE_HIGHMEM.
> > 
> > Fixes: 8efe33f40f3e ("mm/memory_hotplug.c: simplify node_states_check_changes_online")
> 
> What are the runtime effects of this change?

There shouldn't be none. The code is just messy. The newer changelog
should make it more clear I believe.

> > --- a/mm/memory_hotplug.c
> > +++ b/mm/memory_hotplug.c
> > @@ -712,7 +712,7 @@ static void node_states_check_changes_online(unsigned long nr_pages,
> >  	if (zone_idx(zone) <= ZONE_NORMAL && !node_state(nid, N_NORMAL_MEMORY))
> >  		arg->status_change_nid_normal = nid;
> >  #ifdef CONFIG_HIGHMEM
> > -	if (zone_idx(zone) <= N_HIGH_MEMORY && !node_state(nid, N_HIGH_MEMORY))
> > +	if (zone_idx(zone) <= ZONE_HIGHMEM && !node_state(nid, N_HIGH_MEMORY))
> >  		arg->status_change_nid_high = nid;
> >  #endif
> >  }
> 

-- 
Michal Hocko
SUSE Labs

