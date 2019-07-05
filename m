Return-Path: <SRS0=h0DJ=VC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3C33C46499
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 16:15:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4CAE421721
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 16:15:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="HD7pQmVh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4CAE421721
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linuxfoundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C142D8E0003; Fri,  5 Jul 2019 12:15:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BEA428E0001; Fri,  5 Jul 2019 12:15:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B00888E0003; Fri,  5 Jul 2019 12:15:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 761F08E0001
	for <linux-mm@kvack.org>; Fri,  5 Jul 2019 12:15:33 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id a5so5230961pla.3
        for <linux-mm@kvack.org>; Fri, 05 Jul 2019 09:15:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=bB7tPE7hqLlAva7htma6kYD2uO8NKU7bxioyM7J7/h0=;
        b=WWM5bbCnahASWAH4sPZvV1gPhdTIKMMkS2q+ekMYHakZKCcyZxk0EexsK15Cs8xfIP
         RwdAaecUESzQJv/wk5R5xMzVruYB+MLuAGVdS8Bz1oCyMcPh07BT+QR1fHrPKZBGEPaV
         WJD2gkbqIN94/CZa1prHg8MwNztGKv7MpTJXBbCfe6BjLAHNoWBDIyyCHw5QN7dJIY1a
         SP+K6mc+snXCh4H7YjvNlpt3y1/6dGd9d43vl9jHdHPuM1xJKIK52RwJV5+PNKphyBNr
         EAL1V9K/xCqoTt4KLMPsim7vwFGWI/tzlZWh1YHY/O3aKAamntk4w8z/3VxEryEPtWNs
         oViA==
X-Gm-Message-State: APjAAAWp6AqvJ+cj30UBAJt7yy3SBEMKEgjsCSY/eyibRS6IuMJKYRN2
	V8DBN/PxrY++Hd7C91ZG9R9VI4lzy9e4pq4NwzfLySlQc8X7j6U04FjZsIet9cIS9XJdlUp/NJz
	9OgD249m1gg4QjeW0fzqRF9bH3BbOfGCQx9IF5mBtmaqt5CMI17Fr1HRarLZlgqVcWg==
X-Received: by 2002:a17:902:6a2:: with SMTP id 31mr6264972plh.296.1562343333021;
        Fri, 05 Jul 2019 09:15:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqznyyvIa3qxN80M+M4nEzzg65b3PYmKhYXE1YhYyZZorXiC+P3m/IELsrTLPIrcl+UQ71YV
X-Received: by 2002:a17:902:6a2:: with SMTP id 31mr6264916plh.296.1562343332345;
        Fri, 05 Jul 2019 09:15:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562343332; cv=none;
        d=google.com; s=arc-20160816;
        b=yoqfwSLPEOggRdcgUfvBUJEAjFefO1A1OzzZJnE5yStRbN/V1sgHyOKFJTB+QN8BMW
         GtNoZfmZrv6gZCzjLNEmrk0JPIvUj7ARsIk1zJq72uuHce4YbkQ9n6PIf0u5uHZmecrE
         7mcdKpr23hM1XpkLi2RNk6fyYqdo4sc7oC4gZGNQ3KPS7vESpVvVrAI6XydHCl7kjSsU
         QytxxoPF0vN17jwjemwR2ZskGe163C02YLGtFbBT3zSXUN662LZRPTACwYwBd3KtLcxL
         AsP25YwpLGd6O296yGycHB3FOVJG15hxM3GXZm6uwmhqGinrHdx3qrWxBpzvPW8CXX94
         /bTw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=bB7tPE7hqLlAva7htma6kYD2uO8NKU7bxioyM7J7/h0=;
        b=fXEbAAj5Hopw1AEg3oMCg/YtVpFE+sMmg/4Aix8Q0kDiG4sOe0LqGSIGa9rNU2Pbmv
         bPZAgJuteQinmvlx6NW49wSCdyfQ1DX+96uRQPMfA7iWDGd8nGmr9bUD9clG4kZrCcZz
         2C3CPMJgCK0cNj3tnmQrM99h+tX9Yn08wui136akBd4wYAGacQnvF2qgVTF24STCjuER
         qLuC4DEJN8tmVffPyWSO6tRKQhruuEInqO22EOt2lh9Qw7zavQRnWMSn3vRLWKd9T2qR
         WAjJjvnHNtEdo+F5c107ifY7LQTaYPWvgAUzrr/H7/TBiHZ3nlTuXtza114KXWTqlxt+
         U22w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=HD7pQmVh;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id t129si9936144pfb.16.2019.07.05.09.15.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Jul 2019 09:15:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=HD7pQmVh;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from localhost (83-86-89-107.cable.dynamic.v4.ziggo.nl [83.86.89.107])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 7E2DF216FD;
	Fri,  5 Jul 2019 16:15:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1562343332;
	bh=uz3vKdXHCRDuwxCpo/gmy28Nv28WN+Qdj7WXmvD8wjc=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=HD7pQmVh1inEfFSFSehmtf7FDlbacwDHNYisB4T6EHTBlOUg9Hb1zokdgLxHZxFWo
	 sh9+JVipCxzunb+9dfI0NxRrXVySthf3xelK2J/xe7Z8beWuZDY+qxSulmpp6Xq/O6
	 Cw/6XwDBATF6pT+ywaUG7OCAi58Y4fQDxXyrqPsI=
Date: Fri, 5 Jul 2019 18:15:29 +0200
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: kbuild test robot <lkp@intel.com>
Cc: Arnd Bergmann <arnd@arndb.de>, kbuild-all@01.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Memory Management List <linux-mm@kvack.org>,
	Sasha Levin <alexander.levin@microsoft.com>
Subject: Re: [linux-stable-rc:linux-4.9.y 9986/9999] ptrace.c:undefined
 reference to `abort'
Message-ID: <20190705161529.GA8626@kroah.com>
References: <201907060045.bQY0GTP0%lkp@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201907060045.bQY0GTP0%lkp@intel.com>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jul 06, 2019 at 12:08:59AM +0800, kbuild test robot wrote:
> tree:   https://kernel.googlesource.com/pub/scm/linux/kernel/git/stable/linux-stable-rc.git linux-4.9.y
> head:   af13e6db0db43996e060d2b9ca57f60b09d08cb8
> commit: 273b0e9d8a3e0970fab8ad1b037adf9e3a9fc63b [9986/9999] bug.h: work around GCC PR82365 in BUG()
> config: arc-defconfig (attached as .config)
> compiler: arc-elf-gcc (GCC) 7.4.0
> reproduce:
>         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         git checkout 273b0e9d8a3e0970fab8ad1b037adf9e3a9fc63b
>         # save the attached .config to linux build tree
>         GCC_VERSION=7.4.0 make.cross ARCH=arc 
> 
> If you fix the issue, kindly add following tag
> Reported-by: kbuild test robot <lkp@intel.com>
> 
> All errors (new ones prefixed by >>):
> 
>    arch/arc/built-in.o: In function `genregs_set':
> >> ptrace.c:(.text+0x9bc): undefined reference to `abort'
> >> ptrace.c:(.text+0x9bc): undefined reference to `abort'
>    arch/arc/built-in.o: In function `genregs_get':
>    ptrace.c:(.text+0x2de8): undefined reference to `abort'
>    ptrace.c:(.text+0x2de8): undefined reference to `abort'
>    arch/arc/built-in.o: In function `arc_pmu_device_probe':
> >> perf_event.c:(.text+0x99e6): undefined reference to `abort'
>    arch/arc/built-in.o:perf_event.c:(.text+0x99e6): more undefined references to `abort' follow

I've queued up af1be2e21203 ("ARC: handle gcc generated __builtin_trap
for older compiler") to hopefully resolve this now.

thanks,

greg k-h

