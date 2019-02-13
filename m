Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7A58DC4151A
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 07:37:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 352E8222D0
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 07:37:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="GlCMdEMn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 352E8222D0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linuxfoundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B7E148E0002; Wed, 13 Feb 2019 02:37:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B2CBE8E0001; Wed, 13 Feb 2019 02:37:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A1C6F8E0002; Wed, 13 Feb 2019 02:37:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 61D4F8E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 02:37:11 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id a2so1112598pgt.11
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 23:37:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=fzCeo6n4ZUjm3fXg/tNlLRDlNmc+rl1d5vBdDMbJWkk=;
        b=kOdFltBRIagjUhUClRF7gMcaoBsCLIXo0/l9HIoeZWZjUGqiqrzb11H4i8yBPpizJ7
         rqfQNWop5fwQVGWXUoS7t9X+pTKEtZE3uL//JyDftJNxX8yFi/nY3hM7tjtKmfbpbhXc
         6J8WwkniWGHtlDw+1IzvF2y0A6yeL0OL6zQPY8s8n2rudeA4ZHFuUBGjub2YLKldy5OF
         fl8sKvE9WsD3ujNICMQmKxcZPbGTDAAGZpeAlvjA0EyBN9h7TqlbyPgR9Sn9b0/fRtK6
         1vTssibcAR62ZON0bXMWID+nmbK+gzFOHpuXPbNt8Pai4+QFbTGhQDqBOZq2NJKMSeka
         LmWw==
X-Gm-Message-State: AHQUAuZ7z/7BKQeUqdqRNZqxC/zWiPuuIorLoAVxANHiM2nrEKE2xoZz
	HhANCLYv0+jKk69hki9t7U0Wj7MqzNDAuJcDtWJhU5HrIeZdVOYXA7OQb7WWdFVXOZgXJrmxRm0
	vPN/k/hZZJK6ofceGElO9HenrIWB4pOtHWktnikwRprqgWDq7ArDPrb8/PyFFDXg=
X-Received: by 2002:a17:902:8504:: with SMTP id bj4mr8214316plb.200.1550043430812;
        Tue, 12 Feb 2019 23:37:10 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZX+A9uI92hGAmQ8+g65oFdihpQgUzONJ8aSeEkzpd590UuRAjsHzzb6DKBrn7TRzexErL3
X-Received: by 2002:a17:902:8504:: with SMTP id bj4mr8214276plb.200.1550043430094;
        Tue, 12 Feb 2019 23:37:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550043430; cv=none;
        d=google.com; s=arc-20160816;
        b=CYIE4hbPA+Uel05lDiKO0GB6bJKbyWbSyJfPBcY5fvZKOvEHdd4MZ0mv61W2ocDZnT
         zkfS9sUkvfrKF47lAXuMzqm8sd0an+nDu09tVd67pzkynVXhOT4raHVhcF9XABGqXwte
         e+yWLFtoWxSaZeCI23P+5VI3qVZ9FdOz+YOb2z0LiUV9071zPszZh5u7WxWJk0tHTcij
         BcYo0/OKShs4l+VJk0JEp+dkJRr97+tFY7bwxT9EGpOm2xDsU+wzBCt1SwrrgRmBLd3C
         ErZ2czEIIlucShfIdixN368rMR8lKKqY4G52H4y7ASeKjxcRPX8Aoj4znaoZgm7kdZAy
         OW+A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=fzCeo6n4ZUjm3fXg/tNlLRDlNmc+rl1d5vBdDMbJWkk=;
        b=kaD3Bb1Lp4OE1JEHhPNrzdtZLPvflJApNFix0Ik5wV++CRPNJgjPxy9Z59UsJkgHXI
         c8KsUjI8DT+wXCk3UJWEyx6PiaCokmd8vRfjFMqTwfmDReUo2EKoIBqgpaHaRuY8laEV
         Eg66gBJiTR8AcLdEZ3CxMZPAbKnNeFOHLM3zKZCDgNQ35e45p23EjVopCSk8GXmE7FRO
         qQvs6u8rj7kkWUBygRh4Xqjm9e3PbWcy5Ywx0g7bMdxdM6lUzxQX3lGiS9Ei6aF0UNID
         e2VY2Yzrwr/lxh5KkWt9LlGxSTclr3hlX3S69i0koWRegzQ+vrY7xSJSBIxdm6Lxh9Z1
         vcpw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=GlCMdEMn;
       spf=pass (google.com: domain of srs0=8kuc=qu=linuxfoundation.org=gregkh@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=8KUc=QU=linuxfoundation.org=gregkh@kernel.org"
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id g1si14983418plo.406.2019.02.12.23.37.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 23:37:10 -0800 (PST)
Received-SPF: pass (google.com: domain of srs0=8kuc=qu=linuxfoundation.org=gregkh@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=GlCMdEMn;
       spf=pass (google.com: domain of srs0=8kuc=qu=linuxfoundation.org=gregkh@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=8KUc=QU=linuxfoundation.org=gregkh@kernel.org"
Received: from localhost (5356596B.cm-6-7b.dynamic.ziggo.nl [83.86.89.107])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 38997222BE;
	Wed, 13 Feb 2019 07:37:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1550043429;
	bh=rLC96h+IaoAKtg2aAZt3L5CQwkA1Kp6RMQaIhg05jE8=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=GlCMdEMnH2dX4qAEhclGf01Eui8Giyb9rQEvI+I+3G4Oy4kq6T1w4krxxTxxf4/OY
	 FteCuRDhBeenFUYzCul1dka2Fh9xgMhoIbVpCQozCpWX3LYHp6fa29xZ5hD1NFiYUN
	 vCHBF9UGRMehYWTzavVBX7F40/lpS0ltw8ATpUKk=
Date: Wed, 13 Feb 2019 08:37:07 +0100
From: Greg KH <gregkh@linuxfoundation.org>
To: Amir Goldstein <amir73il@gmail.com>
Cc: Steve French <smfrench@gmail.com>, Sasha Levin <sashal@kernel.org>,
	lsf-pc@lists.linux-foundation.org,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	"Luis R. Rodriguez" <mcgrof@kernel.org>
Subject: Re: [LSF/MM TOPIC] FS, MM, and stable trees
Message-ID: <20190213073707.GA2875@kroah.com>
References: <20190212170012.GF69686@sasha-vm>
 <CAH2r5mviqHxaXg5mtVe30s2OTiPW2ZYa9+wPajjzz3VOarAUfw@mail.gmail.com>
 <CAOQ4uxjMYWJPF8wFF_7J7yy7KCdGd8mZChfQc5GzNDcfqA7UAA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOQ4uxjMYWJPF8wFF_7J7yy7KCdGd8mZChfQc5GzNDcfqA7UAA@mail.gmail.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 13, 2019 at 09:20:00AM +0200, Amir Goldstein wrote:
> I never saw an email from you or Greg saying, the branch "stable-xxx" is
> in review. Please run your tests.

That is what my "Subject: [PATCH 4.9 000/137] 4.9.156-stable review"
type emails are supposed to kick off.  They are sent both to the stable
mailing list and lkml.

This message already starts the testing systems going for a number of
different groups out there, do you want to be added to the cc: list so
you get them directly?

thanks,

greg k-h

