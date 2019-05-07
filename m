Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	T_DKIMWL_WL_HIGH,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 38B3AC04AAD
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 07:04:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B8A4A21479
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 07:04:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="1NwSfNdi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B8A4A21479
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linuxfoundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1AC9A6B0005; Tue,  7 May 2019 03:04:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 15D6A6B0006; Tue,  7 May 2019 03:04:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F3FEA6B0007; Tue,  7 May 2019 03:04:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id BEC8C6B0005
	for <linux-mm@kvack.org>; Tue,  7 May 2019 03:04:34 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id 5so3610442pff.11
        for <linux-mm@kvack.org>; Tue, 07 May 2019 00:04:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=AZRk3rRqBTTychjO+BtavUXYIcxvQ60zWhwfPkgHSb8=;
        b=Hy9EkUOy8Ywh9IrIqwZypgZVws7CeXJIYVJXSOQzcFdTnshuXwqotZEVdHb3hIXxnT
         W+m6Ti7u0SYb9p6TH/dwXGijtXy66MMcmhsHonXWZjkH/D0EcBbX+R78kZRBJ0gpGTb+
         gji3G1iKcDs3PKQoAVNy76+tkjgwdBknA4PQ0prd7RQdYEia75Kuk3zx3UOuQW1xiADg
         PrgRAYhTOtLDCFQDHPPxZq7yyvBDnJi3QXSDlanKJHXSpEf5ce4QAQfqYq3vn0CmJYcl
         cLfZZx1EJB1nj15f6bd2P1Zo77D/ZqIje+KrYDviKfkdgNTSbIr7mLNdEFscctXdv0SK
         146A==
X-Gm-Message-State: APjAAAUyTqFHuqO3PzTuadETTgd6IPeqZL/dveluOV3PcG4X3sILr7r7
	r5w4CP6Bi002ltKaQJyxbZdFW76L7rGz4H+7uIxpZZvnswPP3PrXdeQxw29HOAU8mkNSS94Jkmb
	cJNXjP0gnQAcBXE5KyojmEK7jAOV/Nq/j6++l4KY0x7Dd0CTtF4yt9bQs0lQjU4D48A==
X-Received: by 2002:a17:902:8a81:: with SMTP id p1mr38265495plo.106.1557212674323;
        Tue, 07 May 2019 00:04:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqymY9ambRPOZpPUscsnwqTh6/bloDfgIY2mdafTmi/FZAeoit6yzCiN4XTi2XdMKpvybg60
X-Received: by 2002:a17:902:8a81:: with SMTP id p1mr38265408plo.106.1557212673389;
        Tue, 07 May 2019 00:04:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557212673; cv=none;
        d=google.com; s=arc-20160816;
        b=d8qMe20fxXmJH2DxsyMsRAtNYi+U04dHNhnZ9qpBqCwHxwmLQBK1RIt/AMgeWBmsPv
         kJQgPqsDpFxtuGkvdkLQMS9g3BZD7xNNgLoIL3LgjkOO0YOH35RpV/3SxX1RY1rmBSeO
         9KvQcpuV/mtkeFs2ZWA1tZ5gJCRJzv5U9CDMc7wSI2YxLtxv1fWL0NBcb8EhxfuQSdBx
         GGcbUcYhK9TW0tlc0JUcNCsbM8WCcNTLBtdEWbzshGHverEIuvphpEu2I8O004jt86Tx
         DtiO1Kbx16UyqA89v0w0wco2qh7Blaoc/T29xw9tUaIRMHqinkvwCr1+t53uzKUcPy79
         9+2g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=AZRk3rRqBTTychjO+BtavUXYIcxvQ60zWhwfPkgHSb8=;
        b=YPPsy2CY8mKtB8x4I26pZV/tcvCbh4yjt+OQ3zlgXdj0nIjV3UjqSVkdN535bYAa0p
         xEYkKSvG8JuVrUi0LbkYemxk6aqG6KJvd/3pWuoQf3EDm5KtgcZK/S9JDfor2aKbziug
         WhhULYJDwft2ChnpplfB4wnrQvD+H6/tHvYX3yYZ1yZKOptbFLsomXZjPilM0wak7l4w
         8BLV54ZA0ePctGQtdHMWi/xkU5wy9PYA/MDw2ZvQBlpDb65Vcz4wRnHVjTlTjRb//Xyc
         qcp0nZ12XQ73scbA4zc313qBY1kahpOQyEScI3JU44+x6/W3erlQsX4IlXSBtnuSQYxr
         ZR1A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=1NwSfNdi;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id t38si17598206pgl.497.2019.05.07.00.04.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 May 2019 00:04:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=1NwSfNdi;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from localhost (83-86-89-107.cable.dynamic.v4.ziggo.nl [83.86.89.107])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 7A59721019;
	Tue,  7 May 2019 07:04:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1557212673;
	bh=hNi2vt1qB3b6X3N9lBhgsKLvokmDdrvsjVx/J28EZ90=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=1NwSfNdiJdTpK3PxZVb09tk48+2+AXcgrQl+ONIUsuxrfaxWSH5EVRvzyWG0q5iZK
	 GoU2xj/aHaJYSzTAqERyT8jaORLr94yQ1si1oFuQ21nMGXDmmeQt8N0QaISagR8JcU
	 YXN8lw0eZwmxKlwz0uu4QBqj9nvLINBiTWHmBxHY=
Date: Tue, 7 May 2019 09:04:30 +0200
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: Sultan Alsawaf <sultan@kerneltoast.com>
Cc: "open list:ANDROID DRIVERS" <devel@driverdev.osuosl.org>,
	Daniel Colascione <dancol@google.com>,
	kernel-team <kernel-team@android.com>,
	Todd Kjos <tkjos@android.com>, Kees Cook <keescook@chromium.org>,
	Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Tim Murray <timmurray@google.com>, Michal Hocko <mhocko@kernel.org>,
	linux-mm <linux-mm@kvack.org>,
	Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve@android.com>,
	Ingo Molnar <mingo@redhat.com>, Martijn Coenen <maco@android.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Oleg Nesterov <oleg@redhat.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Suren Baghdasaryan <surenb@google.com>,
	Christian Brauner <christian@brauner.io>
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for Android
Message-ID: <20190507070430.GA24150@kroah.com>
References: <20190317015306.GA167393@google.com>
 <20190317114238.ab6tvvovpkpozld5@brauner.io>
 <CAKOZuetZPhqQqSgZpyY0cLgy0jroLJRx-B93rkQzcOByL8ih_Q@mail.gmail.com>
 <20190318002949.mqknisgt7cmjmt7n@brauner.io>
 <20190318235052.GA65315@google.com>
 <20190319221415.baov7x6zoz7hvsno@brauner.io>
 <CAKOZuessqcjrZ4rfGLgrnOhrLnsVYiVJzOj4Aa=o3ZuZ013d0g@mail.gmail.com>
 <20190319231020.tdcttojlbmx57gke@brauner.io>
 <20190320015249.GC129907@google.com>
 <20190507021622.GA27300@sultan-box.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190507021622.GA27300@sultan-box.localdomain>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 06, 2019 at 07:16:22PM -0700, Sultan Alsawaf wrote:
> This is a complete low memory killer solution for Android that is small
> and simple. Processes are killed according to the priorities that
> Android gives them, so that the least important processes are always
> killed first. Processes are killed until memory deficits are satisfied,
> as observed from kswapd struggling to free up pages. Simple LMK stops
> killing processes when kswapd finally goes back to sleep.
> 
> The only tunables are the desired amount of memory to be freed per
> reclaim event and desired frequency of reclaim events. Simple LMK tries
> to free at least the desired amount of memory per reclaim and waits
> until all of its victims' memory is freed before proceeding to kill more
> processes.
> 
> Signed-off-by: Sultan Alsawaf <sultan@kerneltoast.com>
> ---
> Hello everyone,
> 
> I've addressed some of the concerns that were brought up with the first version
> of the Simple LMK patch. I understand that a kernel-based solution like this
> that contains policy decisions for a specific userspace is not the way to go,
> but the Android ecosystem still has a pressing need for a low memory killer that
> works well.
> 
> Most Android devices still use the ancient and deprecated lowmemorykiller.c
> kernel driver; Simple LMK seeks to replace that, at the very least until PSI and
> a userspace daemon utilizing PSI are ready for *all* Android devices, and not
> just the privileged Pixel phone line.

Um, why can't "all" Android devices take the same patches that the Pixel
phones are using today?  They should all be in the public android-common
kernel repositories that all Android devices should be syncing with on a
weekly/monthly basis anyway, right?

thanks,

greg k-h

