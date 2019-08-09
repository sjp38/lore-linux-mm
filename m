Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A5F1BC32756
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 09:18:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 69E8B21882
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 09:18:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="guBuS1Zb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 69E8B21882
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linuxfoundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F2D5F6B0005; Fri,  9 Aug 2019 05:18:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EDDF16B0006; Fri,  9 Aug 2019 05:18:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D7DB66B0007; Fri,  9 Aug 2019 05:18:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9E7E76B0005
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 05:18:22 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id x1so14622877plm.9
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 02:18:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=+QGcWpSN/BRAudpaX/T2TeWXiisetAXH4pLxoBWqAjY=;
        b=hiUOZbZL0LToC2OlqTefc7IAjfYaZQRTRhlDFXWTAGNz5UBeOolvejhmWuZKANnZI6
         iGk9zZiLApB4LrdLjIwT83gYBW9s4XBrD6tVGcLDS+vxH/YrBcyf43orenuNtipvmQ7C
         sWSzVX3lIj6TBA0R2Aux6dZ9bTcxD/vcK3jsboGfrO47d6gj9EWOkUwyR5Qq6hUnTjj8
         Ky+WojoYrcxVOtjOv1BJ2bEmrr2tR1zqUq/FOGZRZY6BBsoY2FOkkYkjLtnObFqU6Tqr
         qXgXvvUPh988+SqcqBi8FhM/QvMzsGYgNczSK0p+5s0i0Y3wtVelkmkV0QgLdtN4j2Mm
         4fQw==
X-Gm-Message-State: APjAAAUeKNX6o++Hgwrq6z3wvyA4lM8pOtd6MOVFwqsqpm1l7WtB/Vex
	ldJie6WTxUcZoIsOLZGiHswZ9vGJEQUoFylhPlyFiLtw+UQIF+w/mJywzg4xS7NbEYGGl4wQ7Ox
	GN9uMHiQLppOBRikakHjE9XDyy1kt/xAVFz+gbdQMAFzOKnzrYc5rnT66MEKcNTS9xw==
X-Received: by 2002:a65:5b8e:: with SMTP id i14mr16556009pgr.188.1565342302117;
        Fri, 09 Aug 2019 02:18:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqygHcjA+O0blyvepFgCC2Na5zSPeZohNQp3texgUJDyHs7Xk/3EKrzV9t9ClNsdGlYWppjT
X-Received: by 2002:a65:5b8e:: with SMTP id i14mr16555954pgr.188.1565342301162;
        Fri, 09 Aug 2019 02:18:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565342301; cv=none;
        d=google.com; s=arc-20160816;
        b=iMwipmXOin0CzqxVTiZLZfLIXBTC/hxbyFzlnv2oEAo19h61QyYR6X0zuZG6EZ8Z9e
         tqi8zHMYwOlJC0hm8b4B6zAZCukF0F7T76hTanCX6Z1nf9a+7btlvaB+FOsv4zqcEg5j
         iAfoyLzhpRh+Vc+L14fP3uZfAN7JlfG4sEpHV3vlqMEtHuAkCQBBnQdjgI5AJE1FH4uN
         Qzjb0Nvsv++F/c1bduEFUm/chAHtTYr724KlNc4FC7su9K7yNOKxXAyleyX+j5CSRgCr
         8Q9tV3arDWY7e+ckOGBst3VqGDv6FRPDcsAHLFijy1jURgcoeHvAxs1RIRLGyoAKQhC2
         i4xA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=+QGcWpSN/BRAudpaX/T2TeWXiisetAXH4pLxoBWqAjY=;
        b=DqSDYVlaEgRdyimMLt4HexShQL4aybi3RCXDw7+IjF71V54Bj6NSjna0CPJkF2i56w
         pBhEOJsau4xjB6Dp+ZhqFReMie/NDdOwa5q6egKrec4PwaXl7U4tIAF2B/GU6cZfllb7
         H8uhhezBp+bsjFtU3Dt+LDimIWPOGnwt7noiobuWnOaXJA2CF/3D4IoKtH8JGm8vV3Pl
         FOWPdrXLnEPp/rB6xZdPql02RiccYmkSrLyObGA2mOac5GBLCSpfo91uT/4mb2FGWyxz
         M/SJNuwOtWbSwj0sIU3slmrbSuImc+wYTHWqVznvsRIdFg367ci33Ib47i95WjhcH94X
         zASg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=guBuS1Zb;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id m2si48779584pls.391.2019.08.09.02.18.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 02:18:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=guBuS1Zb;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from localhost (83-86-89-107.cable.dynamic.v4.ziggo.nl [83.86.89.107])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 53BA421783;
	Fri,  9 Aug 2019 09:18:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1565342300;
	bh=vDFk0iDv4uhF/mh6uYPLsEe3xs+segrrcnOWuXxQKms=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=guBuS1ZbRdjlgZXkIRMxo5T/SU/GeSbZSxdnKSL6erjXVJ68Ixg5GfFw48ZcAQDUJ
	 vTZF38S2BSeNjyyySFS+ew1qhyVgLU9/0UnNyatr/Z0JcgoD0Fmx/FRLRvGYhvhSGK
	 go/RU2KVvB6UqqPtB9Y439Cv67wUAgDcPXYyT1DU=
Date: Fri, 9 Aug 2019 10:55:45 +0200
From: Greg KH <gregkh@linuxfoundation.org>
To: Kees Cook <keescook@chromium.org>
Cc: syzbot <syzbot+45b2f40f0778cfa7634e@syzkaller.appspotmail.com>,
	Michael Hund <mhund@ld-didactic.de>, akpm@linux-foundation.org,
	andreyknvl@google.com, cai@lca.pw, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, linux-usb@vger.kernel.org,
	syzkaller-bugs@googlegroups.com, tglx@linutronix.de
Subject: Re: BUG: bad usercopy in ld_usb_read
Message-ID: <20190809085545.GB21320@kroah.com>
References: <0000000000005c056c058f9a5437@google.com>
 <20190808124654.GB32144@kroah.com>
 <201908081604.D1203D408@keescook>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201908081604.D1203D408@keescook>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 08, 2019 at 04:06:32PM -0700, Kees Cook wrote:
> On Thu, Aug 08, 2019 at 02:46:54PM +0200, Greg KH wrote:
> > On Thu, Aug 08, 2019 at 05:38:06AM -0700, syzbot wrote:
> > > Hello,
> > > 
> > > syzbot found the following crash on:
> > > 
> > > HEAD commit:    e96407b4 usb-fuzzer: main usb gadget fuzzer driver
> > > git tree:       https://github.com/google/kasan.git usb-fuzzer
> > > console output: https://syzkaller.appspot.com/x/log.txt?x=13aeaece600000
> > > kernel config:  https://syzkaller.appspot.com/x/.config?x=cfa2c18fb6a8068e
> > > dashboard link: https://syzkaller.appspot.com/bug?extid=45b2f40f0778cfa7634e
> > > compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
> > > 
> > > Unfortunately, I don't have any reproducer for this crash yet.
> > > 
> > > IMPORTANT: if you fix the bug, please add the following tag to the commit:
> > > Reported-by: syzbot+45b2f40f0778cfa7634e@syzkaller.appspotmail.com
> > > 
> > > ldusb 6-1:0.124: Read buffer overflow, -131383996186150 bytes dropped
> > 
> > That's a funny number :)
> > 
> > Nice overflow found, I see you are now starting to fuzz the char device
> > nodes of usb drivers...
> > 
> > Michael, care to fix this up?
> 
> This looks like the length in the read-from-device buffer is unchecked:
> 
>         /* actual_buffer contains actual_length + interrupt_in_buffer */
>         actual_buffer = (size_t *)(dev->ring_buffer + dev->ring_tail * (sizeof(size_t)+dev->interrupt_in_endpoint_size));
>         bytes_to_read = min(count, *actual_buffer);
>         if (bytes_to_read < *actual_buffer)
>                 dev_warn(&dev->intf->dev, "Read buffer overflow, %zd bytes dropped\n",
>                          *actual_buffer-bytes_to_read);
> 
>         /* copy one interrupt_in_buffer from ring_buffer into userspace */
>         if (copy_to_user(buffer, actual_buffer+1, bytes_to_read)) {
>                 retval = -EFAULT;
>                 goto unlock_exit;
>         }
> 
> I assume what's stored at actual_buffer is bogus and needs validation
> somewhere before it's actually used. (If not here, maybe where ever the
> write into the buffer originally happens?)

I think it should be verified here, as that's when it is parsed.  The
data is written to the buffer in ld_usb_interrupt_in_callback() but it
does not "know" how to parse it at that location.

thanks,

greg k-h

