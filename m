Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A13EBC04E87
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 11:05:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 662EE20856
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 11:05:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="fF9P8PNh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 662EE20856
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linuxfoundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E069C6B0005; Mon, 20 May 2019 07:05:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DB7516B0006; Mon, 20 May 2019 07:05:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CA61A6B0007; Mon, 20 May 2019 07:05:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 94DB56B0005
	for <linux-mm@kvack.org>; Mon, 20 May 2019 07:05:12 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id t16so9592136pgv.13
        for <linux-mm@kvack.org>; Mon, 20 May 2019 04:05:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=0IHyllcFTLquqmW3lU8GUzF69Xv7K89ReeV8NDDRKj4=;
        b=FKdMzfF6KCNlfqGiyWEr5uUsBzLdhb3JHMMBYiUbibhHazlh/vCF/rHxuYFJTxWfH+
         OwzydTlN0B98maBvKu+nZGLL0FcCOH1eukDL5+t6bFSUKRhu513mwjpndW1AntzsBtYk
         mI3bApWaPGLhGRyJ+Av60TeAlD1SPQoDB1D/1TGNNp1jt6VlbCcXUa7NhebmUeYZqtCU
         p8fPPug3aqM1//4AjDVEuT+Gq6+dBAviN1Sho7JSqdjhaT/DIJGrPZ/D9S9ZR8OtiE5k
         w6XdJpEOD5AQIh+S7PhwBnss33MnUrJ0QKfd1vm1g3LCHK5QROatVreRztvatBjUUtz/
         qvPw==
X-Gm-Message-State: APjAAAWcX+oVQM5nEHWjZeTOTeCesFyxuJhYz2CRBB1ufB+Xtr+k+8GD
	NnOxezGQpOzFDDV+M4A6hjxmMvkPY3DPbZdKcmF0NBIIjDwAOd7c7nHVVbGo59pzTr8AuWGTP5L
	XF9yqkTy5h7fMz3yfWOdIywXpqIhq94xN2XpAYTnCAIBWdzIDyxN8I00o1+pjfWB4Lg==
X-Received: by 2002:a65:41c7:: with SMTP id b7mr50530386pgq.165.1558350312283;
        Mon, 20 May 2019 04:05:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzde+5OwHlscWnO2Zqb5CvkWTvsoxEt2AcC7cTFkghwNA0W3BFsfgEvxGi54XDMaalqm2Qm
X-Received: by 2002:a65:41c7:: with SMTP id b7mr50530283pgq.165.1558350311151;
        Mon, 20 May 2019 04:05:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558350311; cv=none;
        d=google.com; s=arc-20160816;
        b=A2v5nAWnIvPakKUlY5vOYiFKixurEIrCQDPiqSQyG3vHqub7aGMPkvE7OM54l53MPK
         7iFEDSWd/mc0gW4aleTDj4YcsJIefmgZNzzkDXnfyFlMdriSyOM/ZWXU7rpHQVkyEJa5
         jjmC+rjBeYzYUHtYZzqxmvdo1Wuj7fqzRxr8j7fYRKiOBkPoKORe8JSqYO7IsrNHvyzo
         JfUcqtj1JoQoWqsZo/J6WVK5wfW2xwCVf3sXLupEc31yvbF7EARdgx1pSxPhVVPfizzL
         wvwgQqoOvYYn3c1Pj2otXHlNyl29ckfRQq73R2PlicWhH+S926i+tgEQqutIEPssuT0q
         l4Uw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=0IHyllcFTLquqmW3lU8GUzF69Xv7K89ReeV8NDDRKj4=;
        b=rgqtvsfC+wM3+Td45bXaFgGlmSlLx2KlVv3uFSXOyE1BdGJkgnE1Mtzpc44IcF8dzY
         xKppIvAhTyieoM15eO+qduupSXKjy5NCBsGwIpOCSJ8IAXPxZua3IkBJfJDALerl7yFl
         ZiIfK/FvKYtO9H/B/86Tl8db6byT3Jt7mNF5Qm++ByzLkwaCMxAIEA5ishmpW1kVV12q
         55ymud1u2GyOcg1xC/yLCB5l7Os9r8k6Y2xKJIbGlXA4npn4iHFkQw15QBNaUo1bA0Er
         q0nCN++FalNsA4A3DaVsTE1cbIh+mi7k8U98zFk2rNbEJSntqIirBKEGXMc0tM9vF+hK
         3fPA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=fF9P8PNh;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id j23si17360594pgj.85.2019.05.20.04.05.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 04:05:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=fF9P8PNh;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from localhost (83-86-89-107.cable.dynamic.v4.ziggo.nl [83.86.89.107])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 41B2A206B6;
	Mon, 20 May 2019 11:05:10 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1558350310;
	bh=VwQSMr5Rvx+iTC5OoVTUamKLhLW6uSee5o3V25yr4TY=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=fF9P8PNhrc6oWUssYT1FD3oqgs7I5ECIp9YF3zNo77k9bLGVbFI+SbCOjbHjn9Syf
	 zeb2/LeLpac4nqYDKzrZFfOByIPFnWqxIFvvn7A/RBJ1m8X1IJ67qBnOT2m3wJuWOn
	 LA7yOl3IQbLmLAAdWusF0cdD9LkXYGrJmYLpogGo=
Date: Mon, 20 May 2019 13:05:08 +0200
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Lech Perczak <l.perczak@camlintechnologies.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Eric Dumazet <edumazet@google.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Piotr Figiel <p.figiel@camlintechnologies.com>,
	Krzysztof =?utf-8?Q?Drobi=C5=84ski?= <k.drobinski@camlintechnologies.com>,
	Pawel Lenkow <p.lenkow@camlintechnologies.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Re: Recurring warning in page_copy_sane (inside copy_page_to_iter)
 when running stress tests involving drop_caches
Message-ID: <20190520110508.GA20211@kroah.com>
References: <d68c83ba-bf5a-f6e8-44dd-be98f45fc97a@camlintechnologies.com>
 <14c9e6f4-3fb8-ca22-91cc-6970f1d52265@camlintechnologies.com>
 <011a16e4-6aff-104c-a19b-d2bd11caba99@camlintechnologies.com>
 <20190515144352.GC31704@bombadil.infradead.org>
 <20190515150406.GA22540@kroah.com>
 <20190515152035.GE31704@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190515152035.GE31704@bombadil.infradead.org>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 15, 2019 at 08:20:35AM -0700, Matthew Wilcox wrote:
> On Wed, May 15, 2019 at 05:04:06PM +0200, Greg Kroah-Hartman wrote:
> > > Greg, can you consider 6daef95b8c914866a46247232a048447fff97279 for
> > > backporting to stable?  Nobody realised it was a bugfix at the time it
> > > went in.  I suspect there aren't too many of us running HIGHMEM kernels
> > > any more.
> > > 
> > 
> > Sure, what kernel version(s) should this go to?  4.19 and newer?
> 
> Looks like the problem was introduced with commit
> a90bcb86ae700c12432446c4aa1819e7b8e172ec so 4.14 and newer, I think.

Thanks, now queued up.

greg k-h

