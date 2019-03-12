Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 73D24C4360F
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 16:17:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3A635214AE
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 16:17:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3A635214AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 91ACB8E0007; Tue, 12 Mar 2019 12:17:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8A2608E0002; Tue, 12 Mar 2019 12:17:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 743348E0007; Tue, 12 Mar 2019 12:17:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2F4FE8E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 12:17:09 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id o9so1315472edh.10
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 09:17:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=+RbjKu/99KkMjVZ7JEAAIWOOj9MvfWz0DNvu3AS+26Y=;
        b=eyW5YG0dApstIbpBrmJ6VR9bccUjDpUvZUbzB+1BmDmn02FSIjXgYaKTXjb8q9FfxA
         GlpfN1vT9mbnT5Kv+CJJXIP+Kckbenf4uWCs50r0Z3LpE4LNQzpnda3EgjgJrJQ2WONg
         jqJAaFIM6W8b6ohcQNV+rpg3AordvVsI4T2RwJo4Dvj83/ozgRDqRQpxPCwYM18/si9G
         XZPBwz/+LRAKhnAkQjOdnmj5d6Z0SzIDPjyBzMnE7wBS4Z9g7cX5I999m2EtLwCtA0Dc
         Z6lk5OLxa9xk43B3Yj4RkK9lqSTx5Fmxmq0gL8EIc18FM+Zjx7kHsJ391L5OidO2Sd17
         yheQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXofRO0oFsZUE2jhompHtpLTp4yTqXbjZLm7HuTN+4ZPLIULPAe
	X852ClKUErWyo5e0j3RegKGAHm+RjElJPX6RGLTf/Z93q7N6a850XWWO7iKA2WtUUD3kypKXtip
	a2XgSVjU8NkcyGbjDpByVUFE28rdaMdYfjA28Qkv8h/bnQtGP1g2zLbEaCvZJTIk=
X-Received: by 2002:a50:b397:: with SMTP id s23mr4142591edd.219.1552407428760;
        Tue, 12 Mar 2019 09:17:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy2Vcou4SYEx4TBxlnk2GiBflLwSxoqZvCpp+C9KXNXYBYEpJpKi+0/yUErLG2cd+aH7hfk
X-Received: by 2002:a50:b397:: with SMTP id s23mr4142528edd.219.1552407427912;
        Tue, 12 Mar 2019 09:17:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552407427; cv=none;
        d=google.com; s=arc-20160816;
        b=Eis5K5GEogHdekwHmREIZMCc4Y9rL7CbttoaJXz0XD2d4nAOK8hdZSE4ZcwXhA6w7o
         eWJRBd1Flhlbvtgssefy2pfRzu5vwtbw+AyXi/xahixGnUI16/kCz/14PmnllLQdBUo+
         qJ74xXz37KFKAXbz632PVhgBwHMz/jZfEXxpV09AaX/la08KPxe+1tu87C+CVurps0CN
         35GDTEGkm+RIW68K34DzOu5JS8/D94Yle0DeZBDQwwi2bqD5mlWlHxuTmClBxYuwy/Nx
         11MEOnPyn7jVqJ1gGRfY7oqTDUE0VIVGnohgXuz2o8IspAKVrZA99eoBvgOwpG+hTF0w
         n+MA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=+RbjKu/99KkMjVZ7JEAAIWOOj9MvfWz0DNvu3AS+26Y=;
        b=ap35fXTXDOgnBGLcuMbFZ3vMJP7iJVf9IMjpbw1nJF3anoUTEXIXuclUQMpP1BV4qK
         MnPVbM9fgomD2eRgDgAZdIxn4b6JAg7oYOl6YD+i8TplM3HRj8nWKZIoX7uMc27Yd5uH
         dW7YjVMvdYk9bLY9D6cGc1CDTkBYPs1lsuMm14LVr8Jtf9oUvlH1uXvIBYWfmeFtOyuI
         ifcoqRy2TtcoCp5JDY9WGZ7x1XopJ0fQrJXSlaZrWy/qg3VvK43JvEpXhFsH8+rrt4kC
         Kco9xXtxBHhabLzeZmOjKMVTT1/AqFSsKIWG6elxG+/+d2a9KaDXRCCw8b2ZoecytsIA
         zqzQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x49si1179369edm.255.2019.03.12.09.17.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 09:17:07 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 25416AC3C;
	Tue, 12 Mar 2019 16:17:07 +0000 (UTC)
Date: Tue, 12 Mar 2019 17:17:05 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: vbabka@suse.cz, jrdr.linux@gmail.com, akpm@linux-foundation.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	shaoyafang@didiglobal.com
Subject: Re: [PATCH] mm: compaction: show gfp flag names in
 try_to_compact_pages tracepoint
Message-ID: <20190312161705.GB5721@dhcp22.suse.cz>
References: <1551501538-4092-1-git-send-email-laoar.shao@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1551501538-4092-1-git-send-email-laoar.shao@gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat 02-03-19 12:38:57, Yafang Shao wrote:
> show the gfp flag names instead of the gfp_mask could make the trace
> more convenient.

Agreed

> Signed-off-by: Yafang Shao <laoar.shao@gmail.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/trace/events/compaction.h | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/include/trace/events/compaction.h b/include/trace/events/compaction.h
> index 6074eff..e66afb818 100644
> --- a/include/trace/events/compaction.h
> +++ b/include/trace/events/compaction.h
> @@ -189,9 +189,9 @@
>  		__entry->prio = prio;
>  	),
>  
> -	TP_printk("order=%d gfp_mask=0x%x priority=%d",
> +	TP_printk("order=%d gfp_mask=%s priority=%d",
>  		__entry->order,
> -		__entry->gfp_mask,
> +		show_gfp_flags(__entry->gfp_mask),
>  		__entry->prio)
>  );
>  
> -- 
> 1.8.3.1
> 

-- 
Michal Hocko
SUSE Labs

