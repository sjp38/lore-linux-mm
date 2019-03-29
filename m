Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 11675C10F05
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 09:19:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CCB402173C
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 09:19:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CCB402173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6B27C6B026A; Fri, 29 Mar 2019 05:19:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 660666B026B; Fri, 29 Mar 2019 05:19:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 54F906B026C; Fri, 29 Mar 2019 05:19:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 339BD6B026A
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 05:19:40 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id g48so1584084qtk.19
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 02:19:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=eQYryy6sb2c50zaATDbp2MBpcQ5pGs0XoycQMFxst60=;
        b=Zg9VFPHD5qA25zEz7gJc+S0sKKNn/+5XmGwhPJxHy/1LJYIYvuI1F4C8MsYBsOLlG2
         YDlBwMR+iEm8cvFZBZajhEZxKww3Q+9ZpoVyNgb1so4zCzbW+RZlkUUmEQSHX15SXrCt
         G+81lSn+jkQchpzxS6i1YD52BD8pZuHM43T/tW5egoxKfFUKjCtQs8IX4P2hNxqkbbeL
         VoYGyZwFpgWH+/XtzBvJli8XEkYmgKC9swHpblYRx9rICowNiN3vRW/m5b/G8GjXbrUs
         bhBNcY4bKDV44FrqAAErTxAwvUg3kFqsA5kc/SvaNou3YlE6EYW8P7GMyH9ZOsS7AwTH
         jBsg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXjHx4TEHG5icwGmWjT6kRHmt6mo2xFz4SVUkJ2lOzAjP6U5Xr8
	a1TdXRSbisEjjaSMmOFBbfQim6agrk7AX5ANStqbydP047NvulOoODA6D+35bPduDkcpAAlmctH
	hx5tRg1DKSztUZVzg+OoS1wgqyN1uCg/eYq1cRWgd+a5qkTR1htK6AFobzCVFgtWg4A==
X-Received: by 2002:ae9:eb41:: with SMTP id b62mr802463qkg.309.1553851179978;
        Fri, 29 Mar 2019 02:19:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxmiaS/XeXaOSWkAJMaU/HpX7nANXp2J2jfgfigekJSG2Y3FKe3Y9tWotw15zpJv13ZLLLu
X-Received: by 2002:ae9:eb41:: with SMTP id b62mr802438qkg.309.1553851179442;
        Fri, 29 Mar 2019 02:19:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553851179; cv=none;
        d=google.com; s=arc-20160816;
        b=KXJ9RwZdJg2fhFggPKBRKUOK8Ll5bczQ5SQy39ttYiGfwdxs+wjquxZ9AvifJMFAwo
         2Ri77XSZduwfYgnR4zKdxJiBa37Ax8g5cn4u3MWhbBf6BENhZCx+xQLXnZBr4LKC1qk3
         lmjvvWXINEAMQLth/Dt4b7LlnrpiPJ1rbKOGZWwxlyux77hPffVVz1ltKiiQUvdO+h2P
         Zxzeoqf9voFP0KukXf4VEYIKvSRM0x6oqjZnzH9EXQcKakB7XSSaoh5ohxbWhiP4Wjjb
         slEXBV5Jf7EHNnsexRl5M/RamjXeELmKnxLm/1JounlshRiRxZAbLdf9ogVXzrgpxReD
         LCXQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=eQYryy6sb2c50zaATDbp2MBpcQ5pGs0XoycQMFxst60=;
        b=pPejDjncNgKliODTN1lIaT1gJujOBjpYWM7RbuEQiSjImOpcfECD4dFQ6Qh0VlvJm8
         0oVM9SufGAmWbNG0NesFxGyXGOAhS1sYpCSV2rkNHzIUkB6l2muyhbN/HSF3N/yzNaKD
         JC6moV6mwg/F1zSsNjVZQTD7RfimgZiIfGsdoHMMKmlqsnfvpNMbJp6dm1KwROCvWpvs
         TgtaY2o8czeGbfAXJOaLlYYKT6YfLJSl8MAaWVyRMCTdwSuaG2eJ0/SoJ2e1rZinSaij
         qfLl6ra11ki/JWX760FnSyL03aZBUytEC4/QOOeJu10HsAvq/lsZQm7JGk2W1JUszGAL
         fMjQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y138si799337qkb.144.2019.03.29.02.19.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Mar 2019 02:19:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 7FABD307CDED;
	Fri, 29 Mar 2019 09:19:38 +0000 (UTC)
Received: from localhost (ovpn-12-24.pek2.redhat.com [10.72.12.24])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id DC4521EE;
	Fri, 29 Mar 2019 09:19:37 +0000 (UTC)
Date: Fri, 29 Mar 2019 17:19:35 +0800
From: Baoquan He <bhe@redhat.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, rafael@kernel.org,
	akpm@linux-foundation.org, osalvador@suse.de, rppt@linux.ibm.com,
	willy@infradead.org, fanc.fnst@cn.fujitsu.com
Subject: Re: [PATCH v3 2/2] drivers/base/memory.c: Rename the misleading
 parameter
Message-ID: <20190329091935.GF7627@MiWiFi-R3L-srv>
References: <20190329082915.19763-1-bhe@redhat.com>
 <20190329082915.19763-2-bhe@redhat.com>
 <20190329091325.GD28616@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190329091325.GD28616@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Fri, 29 Mar 2019 09:19:38 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 03/29/19 at 10:13am, Michal Hocko wrote:
> On Fri 29-03-19 16:29:15, Baoquan He wrote:
> > The input parameter 'phys_index' of memory_block_action() is actually
> > the section number, but not the phys_index of memory_block. Fix it.
> 
> I have tried to explain that the naming is mostly a relict from the past
> than really a misleading name http://lkml.kernel.org/r/20190326093315.GL28406@dhcp22.suse.cz
> Maybe it would be good to reflect that in the changelog
>  
> > Signed-off-by: Baoquan He <bhe@redhat.com>
> 
> btw. I've acked the previous version as well.

Sure, will rewrite the log and add people's Acked-by tag. Thanks.

> 
> > ---
> > v2->v3:
> >   Rename the parameter to 'start_section_nr' from 'sec'.
> > 
> >  drivers/base/memory.c | 7 ++++---
> >  1 file changed, 4 insertions(+), 3 deletions(-)
> > 
> > diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> > index cb8347500ce2..9ea972b2ae79 100644
> > --- a/drivers/base/memory.c
> > +++ b/drivers/base/memory.c
> > @@ -231,13 +231,14 @@ static bool pages_correctly_probed(unsigned long start_pfn)
> >   * OK to have direct references to sparsemem variables in here.
> >   */
> >  static int
> > -memory_block_action(unsigned long phys_index, unsigned long action, int online_type)
> > +memory_block_action(unsigned long start_section_nr, unsigned long action,
> > +		    int online_type)
> >  {
> >  	unsigned long start_pfn;
> >  	unsigned long nr_pages = PAGES_PER_SECTION * sections_per_block;
> >  	int ret;
> >  
> > -	start_pfn = section_nr_to_pfn(phys_index);
> > +	start_pfn = section_nr_to_pfn(start_section_nr);
> >  
> >  	switch (action) {
> >  	case MEM_ONLINE:
> > @@ -251,7 +252,7 @@ memory_block_action(unsigned long phys_index, unsigned long action, int online_t
> >  		break;
> >  	default:
> >  		WARN(1, KERN_WARNING "%s(%ld, %ld) unknown action: "
> > -		     "%ld\n", __func__, phys_index, action, action);
> > +		     "%ld\n", __func__, start_section_nr, action, action);
> >  		ret = -EINVAL;
> >  	}
> >  
> > -- 
> > 2.17.2
> > 
> 
> -- 
> Michal Hocko
> SUSE Labs

