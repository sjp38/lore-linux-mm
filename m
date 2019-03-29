Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 076EDC43381
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 10:43:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AAB8C2075E
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 10:43:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="key not found in DNS" (0-bit key) header.d=codeaurora.org header.i=@codeaurora.org header.b="UrDWV3nZ";
	dkim=fail reason="key not found in DNS" (0-bit key) header.d=codeaurora.org header.i=@codeaurora.org header.b="gPTr+dtC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AAB8C2075E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=codeaurora.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5B02B6B026A; Fri, 29 Mar 2019 06:43:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 538556B026B; Fri, 29 Mar 2019 06:43:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3DAE46B026C; Fri, 29 Mar 2019 06:43:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 04A0D6B026A
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 06:43:39 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id z7so1405479pgc.1
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 03:43:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:dmarc-filter
         :subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=2g1J53+eUOYqgNYb8xE4yjRBXuTLahFiOGHbhrIi3RI=;
        b=Sk6Gpjv96QGgPGd2x9NsFLH2hximzwr0dUmyEoeAngZv+M0WXRoG4E6sDqtEQzydgP
         ZXQWyUMtVkpy1ulpqtX7M1jwh6sCZxTwpuwD8AEgTGxQVKPggvNajW3FZWc/Odzab/yQ
         NnBx/ZrTkVUE44bl4Xsk0+qbyEyC7OQxcnhMOD4RKmf6Daqts3yfN0Y9jbO5KOMcud4g
         uTxp3kwe64XqgZze2/3RF5S6Bo3epX7rVGYzoWsXxwL4Fy9S0qbhfq1PVG7RmS7lcnu0
         ZVhUjzLZP1RFidRAhcYUwyqyzkzgptIX4A3r2K8QxTfoqka+DEWg0WwYpLoe+almE8X0
         e4uw==
X-Gm-Message-State: APjAAAWaResH1Ic0hUC9VLevl8zBGjI8JOe6spHQSSLm1o0NaEnZifBu
	ywBwQcSTKEChRkpRzDyJoTyhr+GeJJqPlNOtwIGTKbYz4ppgZwDHlbhsrkPi6bYQWsbSka5rTrY
	qTqJfqRel42i7ildXS+zNvVdJU49LhGbd32Y3p6KOlqZmp/W7Qw4h1gZEAbsdy9Y5JQ==
X-Received: by 2002:a17:902:2f43:: with SMTP id s61mr48588866plb.158.1553856218673;
        Fri, 29 Mar 2019 03:43:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwTpfDjw7KQy00C2f6IdKapFHQ4NBEsb6LlbS3tbhov3F4xSJItKaFEbNkTfQ9us0yYqzs/
X-Received: by 2002:a17:902:2f43:: with SMTP id s61mr48588830plb.158.1553856218024;
        Fri, 29 Mar 2019 03:43:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553856218; cv=none;
        d=google.com; s=arc-20160816;
        b=RBpumGzoPGmaRecNkiwK77UmuY7JaqxQaPx2Ix7I4eI+nd3lxPqJ8a8JlvHfP/K3fw
         QJU5rpst6bJPKBgUnRwD4mEbfJdOLI1IQYfwEsE+WY/WflFWu7MyL4v2ab2lzAdFt1uh
         vU5q9WxTcQNV5XRzU6AoSq2x2rEvHb99pRAj081xTK/6Kmn/z2xq8skgOdrXbA8Yf3nZ
         8iDmkptZ0n0yySFm4nl9S5O6qauL+REesVbsPlnKjXtIj75R2pjTqJ+RvGE9LgHHtNB3
         0J4CTtCgsFgHkK+3GDZ/X5rDkFkKWjr8qdEhocBtmJ341qGngh0gb+b/Ls6eKmqyMZ7J
         36NQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dmarc-filter:dkim-signature:dkim-signature;
        bh=2g1J53+eUOYqgNYb8xE4yjRBXuTLahFiOGHbhrIi3RI=;
        b=dcLRNI03PPTCfdBINwBGBpLUl5805OzjYQrFX7E6cE1jJ/4u2otwgmAjN612/iII5E
         xLRPyzp7Sw33DL29u5v8zeGqWp9R1oxsTUWd/1R3m5ha8GrOU3lkQpaMAKEBC5jAwExv
         ZYuly9+LJLWGuE1V9p+GsoKqsHcHhrSbqm0HfxCXrdgmsYgKt1OkCwhHAUk+e/IV1jHl
         orFfSEKpJwZvk/rqF02hQF8/yvqJVJmsZ+DW2RndzhstHJs9hUxhnJamoOt/MT596uwG
         KNAPVnv5oJezGOt2bNJnCPuh0SNXyR1p5PJ31xm3NqPH0xW5J2I8rQ1TW0OhEnABerBS
         I5Gw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@codeaurora.org header.s=default header.b=UrDWV3nZ;
       dkim=pass header.i=@codeaurora.org header.s=default header.b=gPTr+dtC;
       spf=pass (google.com: domain of mojha@codeaurora.org designates 198.145.29.96 as permitted sender) smtp.mailfrom=mojha@codeaurora.org
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id e5si1615552pgk.150.2019.03.29.03.43.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Mar 2019 03:43:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of mojha@codeaurora.org designates 198.145.29.96 as permitted sender) client-ip=198.145.29.96;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@codeaurora.org header.s=default header.b=UrDWV3nZ;
       dkim=pass header.i=@codeaurora.org header.s=default header.b=gPTr+dtC;
       spf=pass (google.com: domain of mojha@codeaurora.org designates 198.145.29.96 as permitted sender) smtp.mailfrom=mojha@codeaurora.org
Received: by smtp.codeaurora.org (Postfix, from userid 1000)
	id 4F58D609CD; Fri, 29 Mar 2019 10:43:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=codeaurora.org;
	s=default; t=1553856217;
	bh=llaMkjdyBdsEZbV7SmieM0AVvKTgsZ3IEIReE0vnbNU=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=UrDWV3nZu/X5u3kLGiW78+YQZriQxaCWkfC57ZjKaDBDcn/pfuJ18BY1Ur/Uxy6YO
	 2ceW52zDsaovcAq//mqR6ssPcTaBm1OJMDvGGJKJow0B5xLvxJnsaAoIrGdXcc6Nve
	 wMeZDWYJWCAy+Qhdeoq7jBgF7LUB6UIkCF1GqY2U=
Received: from [10.204.79.83] (blr-c-bdr-fw-01_globalnat_allzones-outside.qualcomm.com [103.229.19.19])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: mojha@smtp.codeaurora.org)
	by smtp.codeaurora.org (Postfix) with ESMTPSA id C3AE0608CC;
	Fri, 29 Mar 2019 10:43:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=codeaurora.org;
	s=default; t=1553856215;
	bh=llaMkjdyBdsEZbV7SmieM0AVvKTgsZ3IEIReE0vnbNU=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=gPTr+dtCIr2NUcXjeoHgxRysKE60tI7EJ8q2W9F90xWGIhU7G89CRI2xWh/huk0lX
	 qI0HG98Y99V47Ght1sJRfE+dZphqbuvIyZkidPLUWpzenWLRA20irm1WlMjKJXd4Oc
	 XTTM+jb4FXU3c0KGBplaF37asK09qwK1Lh3oyawc=
DMARC-Filter: OpenDMARC Filter v1.3.2 smtp.codeaurora.org C3AE0608CC
Authentication-Results: pdx-caf-mail.web.codeaurora.org; dmarc=none (p=none dis=none) header.from=codeaurora.org
Authentication-Results: pdx-caf-mail.web.codeaurora.org; spf=none smtp.mailfrom=mojha@codeaurora.org
Subject: Re: [PATCH v4 2/2] drivers/base/memory.c: Rename the misleading
 parameter
To: Baoquan He <bhe@redhat.com>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, rafael@kernel.org, akpm@linux-foundation.org,
 mhocko@suse.com, osalvador@suse.de, rppt@linux.ibm.com, willy@infradead.org,
 fanc.fnst@cn.fujitsu.com
References: <20190329082915.19763-1-bhe@redhat.com>
 <20190329082915.19763-2-bhe@redhat.com>
 <20190329093659.GG7627@MiWiFi-R3L-srv>
From: Mukesh Ojha <mojha@codeaurora.org>
Message-ID: <029aac79-37d6-c118-b2b4-f536d0368d60@codeaurora.org>
Date: Fri, 29 Mar 2019 16:13:27 +0530
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190329093659.GG7627@MiWiFi-R3L-srv>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 3/29/2019 3:06 PM, Baoquan He wrote:
> The input parameter 'phys_index' of memory_block_action() is actually
> the section number, but not the phys_index of memory_block. This is
> a relict from the past when one memory block could only contain one
> section.
>
> Rename it to start_section_nr.
>
> Signed-off-by: Baoquan He <bhe@redhat.com>
> Acked-by: Michal Hocko <mhocko@suse.com>
> Reviewed-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>


Reviewed-by: Mukesh Ojha <mojha@codeaurora.org>

Cheers,
-Mukesh

> ---
>   drivers/base/memory.c | 7 ++++---
>   1 file changed, 4 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index cb8347500ce2..9ea972b2ae79 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -231,13 +231,14 @@ static bool pages_correctly_probed(unsigned long start_pfn)
>    * OK to have direct references to sparsemem variables in here.
>    */
>   static int
> -memory_block_action(unsigned long phys_index, unsigned long action, int online_type)
> +memory_block_action(unsigned long start_section_nr, unsigned long action,
> +		    int online_type)
>   {
>   	unsigned long start_pfn;
>   	unsigned long nr_pages = PAGES_PER_SECTION * sections_per_block;
>   	int ret;
>   
> -	start_pfn = section_nr_to_pfn(phys_index);
> +	start_pfn = section_nr_to_pfn(start_section_nr);
>   
>   	switch (action) {
>   	case MEM_ONLINE:
> @@ -251,7 +252,7 @@ memory_block_action(unsigned long phys_index, unsigned long action, int online_t
>   		break;
>   	default:
>   		WARN(1, KERN_WARNING "%s(%ld, %ld) unknown action: "
> -		     "%ld\n", __func__, phys_index, action, action);
> +		     "%ld\n", __func__, start_section_nr, action, action);
>   		ret = -EINVAL;
>   	}
>   

