Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 50F95C43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 15:16:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1541D20842
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 15:16:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1541D20842
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A54798E000F; Mon, 25 Feb 2019 10:16:20 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A04C88E000B; Mon, 25 Feb 2019 10:16:20 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8F24F8E000F; Mon, 25 Feb 2019 10:16:20 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 61B8F8E000B
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 10:16:20 -0500 (EST)
Received: by mail-yw1-f70.google.com with SMTP id v67so6463015ywe.7
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 07:16:20 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=SukbM8CMAxoSkIyo1H69YojjlibI/3WJVBKhZOY9v1E=;
        b=Z2IKqQzeoyvPoutdY9Nm7xsoXSns8INPy2gW7rKwEOlRinQPjKL1MtHT0Bcprnkqu0
         5t39/Q8DfQs2Nyso9BHkzjP+VkiTFV1yngKuHjHQD9wafoIbI/KYso6u+fuR0x9mw8tZ
         ijsHg4NGAirPX1m2hyaZz/vZw4PPVRh73iwevhp9Gj1y4UfNSClr9l9rQUsp+in3/M1t
         vcsTgLirK/Z1VYw0uT8AG5VGET/6IprpY2MtSgBdD17cZLGW8Yne0C26WcO1bQ0FmpFp
         WV+36XMIfFbh7hc4Pagv223qGtXsibXWfbB+qnaobBSGuualS8GnOrQp3S+U2+0nPLgQ
         AC4w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuaZbv4vl2sDWKacbzVJ0mTYObresOL6p9KzPHSa48aBw9RwQoed
	hyrUBIVz/HsX/DgdBmQ+poSDaioVkabgJhqIsB1u37h4kfrxpzZqFY98mGcpVO8KUDvxczO48oz
	faOxK+VgLti5TFp9FucWoNRtpG/ashYuaQTxUia+nSoS5O7YemLut9v90tVjyyiNas0ek6rdW4I
	sTFE6GBHdeA1JdJJa8patfmRfGdrw8XsPgrxdsMuXbdA3TBkN2LPM0mZ/MEHXazZIVnVGf0/L/j
	v97avgYgeXlWNGhGVGtKt0miR7t6YcJUGAKLpQSwnuzqCWSfljFrhwepD4ACUuioyo2QYLXQ6Xk
	Xg8H9cqC+AOSjcRNvSwjE3jwutw31PWoJF8fAYE6RjAt6RJTKoO5LiqvEV31IZ3GqnEnptHiiw=
	=
X-Received: by 2002:a81:290c:: with SMTP id p12mr14521781ywp.62.1551107780139;
        Mon, 25 Feb 2019 07:16:20 -0800 (PST)
X-Received: by 2002:a81:290c:: with SMTP id p12mr14521742ywp.62.1551107779563;
        Mon, 25 Feb 2019 07:16:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551107779; cv=none;
        d=google.com; s=arc-20160816;
        b=r7sEIiXj1esiNT48fslIcnvDOTo+0ENdHtAKdJPtG5eOIpBIDa/4N+xuIZ4K60NZoB
         8YFk6HEe+mO3QBnVZGiDwKEVWnwnbJ2TSklX0AaYiZy+LWJZT3dR1Am6NostDHqo9Anb
         LP8zHgHOLuiQWFPTXP6xaKg4m4jhS39RlFDUHf+HA3aq4/FgJVsiL+8GrXalG4dhr19x
         QDEa0CMtysUi/8us253031s/hI2N2SVf0+B+XWT0agv/jwd4L2ygyvq63u7GqqK2YAff
         kvKkOTYz7nvW+mpL3bm4p9LpGjeB1KrwV8YCZriQWlbZiBqrBlWBqIwsSQDc8AOwX09H
         Tddw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=SukbM8CMAxoSkIyo1H69YojjlibI/3WJVBKhZOY9v1E=;
        b=zsidUpY6jZ1cj1X+2nLQiSc+NHLiR1OTat2cEliVJGXAjXJN9CDIHPE2eryxz7MgPo
         EW7wTGseihbl9/a05WJxA0rz+umD11kkWipAg1Om+MLQumvhFsVpjqjNQUkmXnuScMX5
         sH4pnuKWxO+Pjem0Gyepmo50wBPOrtmG8BUpD/OQUzmnrHpVKoRrBn64M0kR+MY8AoSW
         zMcWGKrVuobdabxg+eFOhVWqsIKvqPcmXa2SYZhewg3CpEE/ZkZ+/+K2M6GDgT/exn4E
         k9NL0NW0ksbCZ5sfSBp+TkogqPJeH/kDQcIoaoE30ZowCCU9C/qU9vDDmFJXoEBnNxne
         ykzg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e123sor2369791ybb.190.2019.02.25.07.16.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Feb 2019 07:16:19 -0800 (PST)
Received-SPF: pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: AHgI3IbPQDBBJv5dmRbrs6BvonMys2urOn/4rMhLOBnGs/VbY7xZxJp+i6QbgO4LmkeqW5c9WftOFg==
X-Received: by 2002:a25:23ce:: with SMTP id j197mr6003459ybj.145.1551107779237;
        Mon, 25 Feb 2019 07:16:19 -0800 (PST)
Received: from dennisz-mbp.dhcp.thefacebook.com ([2620:10d:c091:200::1:8bb9])
        by smtp.gmail.com with ESMTPSA id d138sm1986291ywa.43.2019.02.25.07.16.17
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 07:16:18 -0800 (PST)
Date: Mon, 25 Feb 2019 10:16:16 -0500
From: "dennis@kernel.org" <dennis@kernel.org>
To: Peng Fan <peng.fan@nxp.com>
Cc: "tj@kernel.org" <tj@kernel.org>, "cl@linux.com" <cl@linux.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"van.freenix@gmail.com" <van.freenix@gmail.com>
Subject: Re: [PATCH 2/2] percpu: km: no need to consider pcpu_group_offsets[0]
Message-ID: <20190225151616.GB49611@dennisz-mbp.dhcp.thefacebook.com>
References: <20190224132518.20586-1-peng.fan@nxp.com>
 <20190224132518.20586-2-peng.fan@nxp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190224132518.20586-2-peng.fan@nxp.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Feb 24, 2019 at 01:13:50PM +0000, Peng Fan wrote:
> percpu-km is used on UP systems which only has one group,
> so the group offset will be always 0, there is no need
> to subtract pcpu_group_offsets[0] when assigning chunk->base_addr
> 
> Signed-off-by: Peng Fan <peng.fan@nxp.com>
> ---
>  mm/percpu-km.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/percpu-km.c b/mm/percpu-km.c
> index 66e5598be876..8872c21a487b 100644
> --- a/mm/percpu-km.c
> +++ b/mm/percpu-km.c
> @@ -67,7 +67,7 @@ static struct pcpu_chunk *pcpu_create_chunk(gfp_t gfp)
>  		pcpu_set_page_chunk(nth_page(pages, i), chunk);
>  
>  	chunk->data = pages;
> -	chunk->base_addr = page_address(pages) - pcpu_group_offsets[0];
> +	chunk->base_addr = page_address(pages);
>  
>  	spin_lock_irqsave(&pcpu_lock, flags);
>  	pcpu_chunk_populated(chunk, 0, nr_pages, false);
> -- 
> 2.16.4
> 

While I do think you're right, creating a chunk is not a part of the
critical path and subtracting 0 is incredibly minor overhead. So I'd
rather keep the code as is to maintain consistency between percpu-vm.c
and percpu-km.c.

Thanks,
Dennis

