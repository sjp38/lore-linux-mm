Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BC65FC43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 16:31:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 775802184D
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 16:31:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 775802184D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0388E8E0005; Tue, 26 Feb 2019 11:31:57 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F28748E0001; Tue, 26 Feb 2019 11:31:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E17BE8E0005; Tue, 26 Feb 2019 11:31:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id AE2C88E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 11:31:56 -0500 (EST)
Received: by mail-yw1-f72.google.com with SMTP id r8so9159967ywh.10
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 08:31:56 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=eliy+LXVAm/reO1JhBaGptnuIQdxQu+wUBgKDytlVvQ=;
        b=V+uxlHJzwqp2QME7q2Ftcmq7jdZXifq/d0ewmyvXggNQLSlvYarDrdHlGt1s3lse2W
         2oE6JKdARnpPjtVKlJ8ejwwXa31Z/PgHEiiUz3KZsF4V3+YWl8ECqTrd8Kmns0cSbruc
         3HIVYtOcoHrMv+OnE1Hg8PTjQsAeU1EV/q05EK+qwdtMZabAKxmeAaUK9Yyz8J37BYkQ
         KQXMo4WAtn2R7+Ef592v/G0mwHOOIqQ8o8JoMa6itsno8jHfN3hZoMxtPQXTGM88L6PS
         2D80TAFgkgONe2ShdgziSHt4GshS+jgrYNjtWlAe/6LxkcI7t5Cvb95JKlnHkyHBNBHz
         AeLQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuYeqYdydjR12KAIo8IumzcOpz4/2sddaybROt34LWd4OPOqHPB/
	qlduufDVQD/emkX2emQ6CHahSmKSluWmpE+rYF8aWxyQc2xRzxzvF7CNxbdUlRBsyCsYKc/RWy5
	Fxui8wLrUkI2uG+lU10Y0mbf1xMX6HJbYQ8zGFaHw7hmtfSlrmRn9DhLcV9iv0+IWPYkQ7qbsil
	T8DEgUVQEIsp4vknvC0gzBoCieiyQBoKlr9zyfRp+sqO4s8aobK7NHHDf34caCdelAg/kSDmHy6
	BOexPwsolY8fq/PPqyayYvIy7sV6WRXLesKMofMSIj8UkCtwz55cSRxODvsXmp6sOA6PNffY/+A
	MLRIANeNJLKjK2Z+EO81QfQM1i/XfA7+5hh4PF5nrU/Ij9Q28pLouVQTkjLwwCtgew+PXxdGJg=
	=
X-Received: by 2002:a25:bf82:: with SMTP id l2mr10252858ybk.15.1551198716390;
        Tue, 26 Feb 2019 08:31:56 -0800 (PST)
X-Received: by 2002:a25:bf82:: with SMTP id l2mr10252798ybk.15.1551198715665;
        Tue, 26 Feb 2019 08:31:55 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551198715; cv=none;
        d=google.com; s=arc-20160816;
        b=cuDgAa+OTNZokWD8XgxNC6G12ym2qLoyaVPVzx6M/yxYwGLbBHx1H2A8qylvQW3GQW
         osktyTGpZwmPR3QFKbrO9zs17qeMErlkCa1iADckvWplfFUm9dO3AydjdwqQQoqk+Ol3
         sFRIdnrV7LMaiw5F8q/7WnoCYzQz7tQwpPlWPwOWbNhg5KDBa9Q/7KpANFK4HxOpQr5R
         opqIF1xlCHz01/tfD3iwA0Zqw92u65i4NwbHOR8ymyYE3OdMIE4Jq7sWA4cmBm4XO6K0
         pFK25yxbc6TcA2RLR52Pr1sWVpECbd7QKITSytrwPp8/v3VQeK0nCiF4n/u63/fOG/fO
         E4Cw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=eliy+LXVAm/reO1JhBaGptnuIQdxQu+wUBgKDytlVvQ=;
        b=OkIY51pQuWhmraaOQth+7JqwjvFFX6DYPZGEUTa2fx9nInX9hPnHRUSDJCzgzaZvil
         fjflo4ud6k4Uf0Sth3TR87Q9LQdo/Jyo3FaJLS5d/CJ+Q2daqBgiERNBneeu8afyebmP
         R3CnA5HZPlV1wRetd0y7+nRSCmV2ryOFRAk7F/9clp0P0jTS0cYAwBcyA9T3FSvsacOi
         +3RQpDIx15U8uWZ1v72eN4cpU9GFraPa+XLsYX1f4WmpuAvbfHGVjR/ovSfLSxNacUaW
         An+kSabbPqVLwa/LUZ58EnjHKyfib7Ww+hZFq4xH/l+mZ7uayJlDky6z+ypD3E9EAXog
         +Z0g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t3sor6780130ybp.193.2019.02.26.08.31.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 26 Feb 2019 08:31:55 -0800 (PST)
Received-SPF: pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: AHgI3IaDYm6I0be+SHNf29F3AQM1X/gSL2A4NS43BZxsGCnY1RuKykUsFHiaOxgDbTdpbCjn9pPc2g==
X-Received: by 2002:a25:8882:: with SMTP id d2mr19048907ybl.381.1551198715061;
        Tue, 26 Feb 2019 08:31:55 -0800 (PST)
Received: from dennisz-mbp.dhcp.thefacebook.com ([2620:10d:c091:200::2:7f17])
        by smtp.gmail.com with ESMTPSA id f188sm4204686ywb.64.2019.02.26.08.31.53
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 08:31:53 -0800 (PST)
Date: Tue, 26 Feb 2019 11:31:51 -0500
From: Dennis Zhou <dennis@kernel.org>
To: Christopher Lameter <cl@linux.com>
Cc: "dennis@kernel.org" <dennis@kernel.org>, Peng Fan <peng.fan@nxp.com>,
	"tj@kernel.org" <tj@kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"van.freenix@gmail.com" <van.freenix@gmail.com>
Subject: Re: [PATCH 2/2] percpu: km: no need to consider pcpu_group_offsets[0]
Message-ID: <20190226163151.GA47262@dennisz-mbp.dhcp.thefacebook.com>
References: <20190224132518.20586-1-peng.fan@nxp.com>
 <20190224132518.20586-2-peng.fan@nxp.com>
 <20190225151616.GB49611@dennisz-mbp.dhcp.thefacebook.com>
 <010001692a605709-407cf476-e7b6-43be-8551-66c54059e92f-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <010001692a605709-407cf476-e7b6-43be-8551-66c54059e92f-000000@email.amazonses.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 26, 2019 at 03:15:50PM +0000, Christopher Lameter wrote:
> On Mon, 25 Feb 2019, dennis@kernel.org wrote:
> 
> > > @@ -67,7 +67,7 @@ static struct pcpu_chunk *pcpu_create_chunk(gfp_t gfp)
> > >  		pcpu_set_page_chunk(nth_page(pages, i), chunk);
> > >
> > >  	chunk->data = pages;
> > > -	chunk->base_addr = page_address(pages) - pcpu_group_offsets[0];
> > > +	chunk->base_addr = page_address(pages);
> > >
> > >  	spin_lock_irqsave(&pcpu_lock, flags);
> > >  	pcpu_chunk_populated(chunk, 0, nr_pages, false);
> > > --
> > > 2.16.4
> > >
> >
> > While I do think you're right, creating a chunk is not a part of the
> > critical path and subtracting 0 is incredibly minor overhead. So I'd
> > rather keep the code as is to maintain consistency between percpu-vm.c
> > and percpu-km.c.
> 
> Well it is confusing if there the expression is there but never used. It
> is clearer with the patch.
> 

Okay. I'll apply it with your ack if that's fine.

Thanks,
Dennis

