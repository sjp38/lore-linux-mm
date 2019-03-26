Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 816FCC43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 09:33:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4B42820856
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 09:33:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4B42820856
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C93A06B0005; Tue, 26 Mar 2019 05:33:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C1CBC6B0006; Tue, 26 Mar 2019 05:33:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ABF5E6B0007; Tue, 26 Mar 2019 05:33:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 591336B0005
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 05:33:17 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id c41so4993847edb.7
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 02:33:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=jVoUHmJ8f+FtyN16Bp1lvQUUjmrUkhoInYu66uuw1kQ=;
        b=ESGRxpxP/+r/WdZlCrr3tP8+ozR3EkEe5/mNKj07wKN1RjpMG+DKc0Zpck/GRUo+i4
         Ux5YifsBzKkF61xH+jStK2jbIO3xkXju+HVZb3GCF55vGaHfKkMolcUH6lkr2f8SbYph
         9HjFopvudc6/Y7jcylgynAJZbA1iFZkJAxtlrBjUpWGg/MdEAdnMBpwjMYUhdnBuxQhw
         y5uplxJRgGBa+tb22aBe7lmTz4mUIJwzbN/gvgdqRvg0LPZI/q7fnF22pRi7bjl0V0WD
         PjKoXLrQ3Yf+8G6fuQHShJ8GledVebj6zYdfY4/Dctiak+8EmDJWLyC4a0PAaOYu7hhL
         PuGw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUkCl61/oWkha5mcc/cn5pHyfl69irqe91lf1j08z3k+lw6F7g5
	ImxSn0MGqYDzDBqdNzZxsb5FokDzxMTX36zTSiwNeieNjWXxiXTqxIIxBq1yP6mMmJrgbt8ishL
	oGgbLWUgSfVANzLFnyCN0Tx7FoySAJ/AOPgBqkwtjHFw5TLA4rMGIimJIUwQqCDg=
X-Received: by 2002:a17:906:498a:: with SMTP id p10mr16951355eju.158.1553592796929;
        Tue, 26 Mar 2019 02:33:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxokvyyYj5bRAbP3e7/f4/CXiBx1gfIqG/pICaiBreCx8cR9L5acuWpoxVgR5ubdZzQytgD
X-Received: by 2002:a17:906:498a:: with SMTP id p10mr16951326eju.158.1553592796194;
        Tue, 26 Mar 2019 02:33:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553592796; cv=none;
        d=google.com; s=arc-20160816;
        b=sqOoQihZFfjIkH1i2redxIPeNUuLNzHHDlCthuaM0oeTdrkQtljNfsouSTOkiPHlq1
         Up6rv1ieGvWJZQpCJ9IZ6HLmCVfejizoAaa4NHs/Soj2Wllfrw0iVHEm+9Yo1QlA1DEg
         4HBr3PEOMRGjv352/u/ZjazjIUk0pFQvLl1wh+YaefhfGQam3+ow7pQGMxbO3p1uxjsZ
         KYez0xKcdXxkMwDVbl6GREVth47shxummL+iKg253uyzgwj3STxVPnteQnBp/VQE9pOY
         PgGwrzv2b24h5X8Vp4/sNcxrQ0F1lOjPanlbppvvRMN3GUiwgMKI9AJzHJimfeMWVGnL
         +hJQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=jVoUHmJ8f+FtyN16Bp1lvQUUjmrUkhoInYu66uuw1kQ=;
        b=DjJ8AVkjC3hnG3QBa3ymFF5YLlhCX7pWUOpKDXMi7il53BaozI+bfIMKYqv0fXxmlr
         gRyTYzvzgzZSOHTgrNIAt0VK3jJfqpi/5JaYB8EErPaYRz5xnZNmUpotgTD+F/vefYMM
         fTsOJ1dmvB7H2HLEOYFQblh1S0+pJGf1HhKkrECFD4sAhezhYf/HTftFyy1M83Gkg1/a
         UcUky+FDMPYiJS5MCJiEqKAixsEGGCJ2bOIlAdWTLJVYAVvtxYJikaILhLeBRMPS9Qjb
         hQPoNcb6zQR8ccDlGHaTc91sQFkU0k8c1XrI2l3HNCiUce4qDpNgqx9QzftdDWBsyoRl
         HNNw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j3si658384edc.3.2019.03.26.02.33.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Mar 2019 02:33:16 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id B393FAD65;
	Tue, 26 Mar 2019 09:33:15 +0000 (UTC)
Date: Tue, 26 Mar 2019 10:33:15 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Baoquan He <bhe@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	akpm@linux-foundation.org, rppt@linux.ibm.com, osalvador@suse.de,
	willy@infradead.org, william.kucharski@oracle.com,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>
Subject: Re: [PATCH v2 4/4] drivers/base/memory.c: Rename the misleading
 parameter
Message-ID: <20190326093315.GL28406@dhcp22.suse.cz>
References: <20190326090227.3059-1-bhe@redhat.com>
 <20190326090227.3059-5-bhe@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190326090227.3059-5-bhe@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 26-03-19 17:02:27, Baoquan He wrote:
> The input parameter 'phys_index' of memory_block_action() is actually
> the section number, but not the phys_index of memory_block. Fix it.

phys_index is a relict from the past and it indeed denotes the section
number which is exported as phys_index via sysfs. start_section_nr would
be a better name IMHO but nothing to really bike shed about.

> Signed-off-by: Baoquan He <bhe@redhat.com>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: "Rafael J. Wysocki" <rafael@kernel.org>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  drivers/base/memory.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index cb8347500ce2..184f4f8d1b62 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -231,13 +231,13 @@ static bool pages_correctly_probed(unsigned long start_pfn)
>   * OK to have direct references to sparsemem variables in here.
>   */
>  static int
> -memory_block_action(unsigned long phys_index, unsigned long action, int online_type)
> +memory_block_action(unsigned long sec, unsigned long action, int online_type)
>  {
>  	unsigned long start_pfn;
>  	unsigned long nr_pages = PAGES_PER_SECTION * sections_per_block;
>  	int ret;
>  
> -	start_pfn = section_nr_to_pfn(phys_index);
> +	start_pfn = section_nr_to_pfn(sec);
>  
>  	switch (action) {
>  	case MEM_ONLINE:
> @@ -251,7 +251,7 @@ memory_block_action(unsigned long phys_index, unsigned long action, int online_t
>  		break;
>  	default:
>  		WARN(1, KERN_WARNING "%s(%ld, %ld) unknown action: "
> -		     "%ld\n", __func__, phys_index, action, action);
> +		     "%ld\n", __func__, sec, action, action);
>  		ret = -EINVAL;
>  	}
>  
> -- 
> 2.17.2
> 

-- 
Michal Hocko
SUSE Labs

