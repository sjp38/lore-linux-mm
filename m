Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 716A3C433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 10:58:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 34E5B206A2
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 10:58:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 34E5B206A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=amzn.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D32CD6B0003; Tue,  6 Aug 2019 06:58:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CE3726B0008; Tue,  6 Aug 2019 06:58:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BD2616B000A; Tue,  6 Aug 2019 06:58:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9EE0E6B0003
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 06:58:27 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id c1so75205299qkl.7
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 03:58:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=KByFyY8Nu0xmGzscsk8mLuSGQZQbwYNExSEpDy0pBks=;
        b=tZyMkjrgO8sk9SGodfD0U2xdQKzAKbuFHqz8s7/10cyyi5lJqOvj/spGXW9+OE0lEt
         8EEaj7KWJ62/5vvfAJMEAeHvmoIbNOvGMhf2s5t6tMqSR1ZIsdnsdawgo4Ji4KOtf8Ud
         9+ZjYWCBDy8Ba3Z+0HZTkqrx45Nn2eEUudWh9Q5PtkauNTs18EY/HL4XiXh1RL45jEiZ
         CafjaEFWR6TTItojsk8qT6Q/WCfI2PQz8n2pxUd4Xs/PHfHgahwIuIx1PJkTItPm1DYd
         WLUJsqe70kruXGyvgF2DNxGLqgR1kk4a6X9VbwHiyjbK6OjhDjDXvNogOQ0tvdO1/6BO
         2FWg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of prvs=114c2f425=sblbir@amzn.com designates 207.171.184.29 as permitted sender) smtp.mailfrom="prvs=114c2f425=sblbir@amzn.com";       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=amzn.com
X-Gm-Message-State: APjAAAWT2gGgRvpPp3QzBG2wz14iTJF7eWBhGvm+9p5dvsktEiBN8HJW
	X1qltGTfgj+iE9LV7snMqciIdd2ZyqyrwOmXbWa9Xn/wVtd415sB8ouxJR6jRFf1e2TMXjLWwo1
	BsDGoQdoPPlzg45HKclKPRlsdj1IHVV0ON/0ETFyZMKOo0lYQU/LTIuwZb0BKl21TNQ==
X-Received: by 2002:a37:d247:: with SMTP id f68mr2645365qkj.177.1565089107401;
        Tue, 06 Aug 2019 03:58:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw9VlD2PhmyoWGk7RMueVw6yHlhGAf72wWFuTtZXU8PKO6hmJ484nf6S5j2+IDU2FCmec+t
X-Received: by 2002:a37:d247:: with SMTP id f68mr2645345qkj.177.1565089106827;
        Tue, 06 Aug 2019 03:58:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565089106; cv=none;
        d=google.com; s=arc-20160816;
        b=odXX+Xtl9MF2+ncDtG7ClR4nIO0jQAoB+++48kCXPYxnna29PyUy/xodrb6ia+VFOR
         ErFwLSmYfQf5HAEUg0UzS17k781pHFsqbstb20Qtz4EOxFqDbMXX0PJ4BWjfDLBXptda
         L651Ta/r95bzEQU/dNbq6NKo+jatQpjvK0tJj7IDleuLP1UXoGOLb8NOLT8KpDSI7g8N
         9TtFO7ZbBXjWtNX/GVWHkO6L27EVJpp+uL0RXlTJRvN45NM4oX32pFbQU3ex0qBBJPgd
         ZQqjW64N+CP6UpjvN8QH79xruVF2egFE3/vyAC6Q/GPnj3RoNRhCs74T4idsFw3lo2wD
         9t3A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=KByFyY8Nu0xmGzscsk8mLuSGQZQbwYNExSEpDy0pBks=;
        b=Z6haZg7ELIJKwJLdNDVhP8lAH2GRAjfue1qgHhRhWaZoKbN5FxfLfboR6AYcAK4kVA
         NcepJ4e01LgQogR0iY4dtBDc/IirAt10//YKruM+eiK9QK8sl6NrqYEHTj65Od4e0yYx
         LYlC/y/Dyc4wJYQ2R7Nvv6tA0+iztADXZmqBBhaQxy29gV+mc2YQ5NeV4wORadoK+8cC
         iw1S8s4WnWL8oPmdrp7k6sLCkhYdCEM4yvAsf+1VNFmYUtWFl05t0jAEX60SFSAkVmYi
         0h5HPxe3e6uhkygd3ffCDGk+G4aj1xd1ugS7E+c5cZqrjhW7pXrvbiwsvOKn7omCuztw
         nsAQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of prvs=114c2f425=sblbir@amzn.com designates 207.171.184.29 as permitted sender) smtp.mailfrom="prvs=114c2f425=sblbir@amzn.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=amzn.com
Received: from smtp-fw-9102.amazon.com (smtp-fw-9102.amazon.com. [207.171.184.29])
        by mx.google.com with ESMTPS id d35si50382287qte.177.2019.08.06.03.58.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 03:58:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=114c2f425=sblbir@amzn.com designates 207.171.184.29 as permitted sender) client-ip=207.171.184.29;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of prvs=114c2f425=sblbir@amzn.com designates 207.171.184.29 as permitted sender) smtp.mailfrom="prvs=114c2f425=sblbir@amzn.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=amzn.com
X-IronPort-AV: E=Sophos;i="5.64,353,1559520000"; 
   d="scan'208";a="691286792"
Received: from sea3-co-svc-lb6-vlan2.sea.amazon.com (HELO email-inbound-relay-2b-4ff6265a.us-west-2.amazon.com) ([10.47.22.34])
  by smtp-border-fw-out-9102.sea19.amazon.com with ESMTP; 06 Aug 2019 10:58:23 +0000
Received: from EX13MTAUEA001.ant.amazon.com (pdx4-ws-svc-p6-lb7-vlan3.pdx.amazon.com [10.170.41.166])
	by email-inbound-relay-2b-4ff6265a.us-west-2.amazon.com (Postfix) with ESMTPS id 6EC1FA27C0;
	Tue,  6 Aug 2019 10:58:23 +0000 (UTC)
Received: from EX13D16UEA003.ant.amazon.com (10.43.61.183) by
 EX13MTAUEA001.ant.amazon.com (10.43.61.243) with Microsoft SMTP Server (TLS)
 id 15.0.1367.3; Tue, 6 Aug 2019 10:58:23 +0000
Received: from EX13MTAUEA001.ant.amazon.com (10.43.61.82) by
 EX13D16UEA003.ant.amazon.com (10.43.61.183) with Microsoft SMTP Server (TLS)
 id 15.0.1367.3; Tue, 6 Aug 2019 10:58:22 +0000
Received: from localhost (172.23.204.141) by mail-relay.amazon.com
 (10.43.61.243) with Microsoft SMTP Server id 15.0.1367.3 via Frontend
 Transport; Tue, 6 Aug 2019 10:58:22 +0000
Date: Tue, 6 Aug 2019 10:58:22 +0000
From: Balbir Singh <sblbir@amzn.com>
To: Wei Yang <richardw.yang@linux.intel.com>
CC: <akpm@linux-foundation.org>, <mhocko@suse.com>, <vbabka@suse.cz>,
	<kirill.shutemov@linux.intel.com>, <linux-mm@kvack.org>,
	<linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] mm/mmap.c: refine data locality of find_vma_prev
Message-ID: <20190806105822.GA25354@dev-dsk-sblbir-2a-88e651b2.us-west-2.amazon.com>
References: <20190806081123.22334-1-richardw.yang@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20190806081123.22334-1-richardw.yang@linux.intel.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 06, 2019 at 04:11:23PM +0800, Wei Yang wrote:
> When addr is out of the range of the whole rb_tree, pprev will points to
> the biggest node. find_vma_prev gets is by going through the right most
> node of the tree.
> 
> Since only the last node is the one it is looking for, it is not
> necessary to assign pprev to those middle stage nodes. By assigning
> pprev to the last node directly, it tries to improve the function
> locality a little.
> 
> Signed-off-by: Wei Yang <richardw.yang@linux.intel.com>
> ---
>  mm/mmap.c | 7 +++----
>  1 file changed, 3 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 7e8c3e8ae75f..284bc7e51f9c 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -2271,11 +2271,10 @@ find_vma_prev(struct mm_struct *mm, unsigned long addr,
>  		*pprev = vma->vm_prev;
>  	} else {
>  		struct rb_node *rb_node = mm->mm_rb.rb_node;
> -		*pprev = NULL;
> -		while (rb_node) {
> -			*pprev = rb_entry(rb_node, struct vm_area_struct, vm_rb);
> +		while (rb_node && rb_node->rb_right)
>  			rb_node = rb_node->rb_right;
> -		}
> +		*pprev = rb_node ? NULL
> +			 : rb_entry(rb_node, struct vm_area_struct, vm_rb);

Can rb_node ever be NULL? assuming mm->mm_rb.rb_node is not NULL when we
enter here

Balbir Singh

