Return-Path: <SRS0=GuKW=WG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C6A2EC433FF
	for <linux-mm@archiver.kernel.org>; Sat, 10 Aug 2019 18:23:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 777D3208C3
	for <linux-mm@archiver.kernel.org>; Sat, 10 Aug 2019 18:23:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="CfXBw9LL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 777D3208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 11F806B0006; Sat, 10 Aug 2019 14:23:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0D15D6B0008; Sat, 10 Aug 2019 14:23:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F03856B000A; Sat, 10 Aug 2019 14:23:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id BB58B6B0006
	for <linux-mm@kvack.org>; Sat, 10 Aug 2019 14:23:21 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id u1so61746364pgr.13
        for <linux-mm@kvack.org>; Sat, 10 Aug 2019 11:23:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=1wMbnmcvYThr8v75tXw+NLJxxgTL8aTm8bPoijuWeXk=;
        b=eNgTPQMCKk2Gq+c2uNAgEQ4LnGGt206qlTJzDD+LUwPSHNIUf0ay/flhhiQ0qrH3ZB
         TfWdFkWlvOeRDPcqauvlG4aK3dHd6WtBYE3n1C18VLEtTarvdhER9F4NXO/IBVT73tSc
         MJTK9vMi4pT7F2tiruC4zl9ZqmLMi/75pVp9o1nHvTX4+/lXymRwIHzYDCdJqAlJRDwk
         FZtx7CJnTqRgvs81a9quaep2Jdb+oi76CMN+lC8f178J8of3duCmMSPpT06QkgH1VgVF
         3hCY/GYjOaUsTtjSFCv33YDqVseUCPSvOmF1dcxgTQMB+b35wnXCNFNQFSSOTPmXvIcr
         TThA==
X-Gm-Message-State: APjAAAVHcXI/cA6xZU0fNnbCvF2vDmRXTNboxbPy2McQPaSTAxTdgFa2
	qHLCH1xWdSMT4pZ8EE5Y1bPrA+ym6qa43z/6/r1snjdVmoI8rQIyYHr4/JgcmwQBMGvEGxETJ7h
	NG1ucmHlZ4SkGukIW4RdPx6UqsND4Nd+bnsdy3jm6SFVZPhMYNikKsOj+Yqrt/W95NA==
X-Received: by 2002:a17:90a:220a:: with SMTP id c10mr15809102pje.33.1565461401383;
        Sat, 10 Aug 2019 11:23:21 -0700 (PDT)
X-Received: by 2002:a17:90a:220a:: with SMTP id c10mr15809069pje.33.1565461400682;
        Sat, 10 Aug 2019 11:23:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565461400; cv=none;
        d=google.com; s=arc-20160816;
        b=H+nocRFqtc/0Ab7bbD8fOopnVY5reye72rvE963k9WRkoAf8IZCVHJ5JB/Ow9A0cT/
         Jb2URpe8rN9zE7YqEqJ0b6NZjY9uuBEP+z12erIHFwHZ4VyEfdpVHfyfZ8OUcQMoZlN4
         cwaAbz0BY19R8pOLCHTcyby9QQA4T248Mk2XgoVWgfylvHxY6mASN++lZlPfx+pvcQBn
         6Nsy3SS+Ha58v8LrY8fFgdTi02URehNTq5pdlxlkul9jT6T2WlFNtquK6twgHls8CJJp
         FF8EDLXk0FGTaG+gb2EOhxrs86sih4VBzOuIXIKS3QesKVgjeoQhQG7E1Zb9Vd+dD8S8
         Wppw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=1wMbnmcvYThr8v75tXw+NLJxxgTL8aTm8bPoijuWeXk=;
        b=racuzQeejhAtZss9huK/Etovxp31GrCDgpw5Rzz61fCeqTGW0bKsrxkJ/sUDdSZ3sG
         uK5N7o0CGhYXt3zL4W1aY5AixN12A8BOv3CqA9boblTGYSQ8hNZx3T48DnEcaKh9NEao
         spNCjd8gzVaXK4ykanblGFCPHISXTV6xQtsjj/oocRRRRE4OowwTWavgcOODXm6fajiq
         tXxIcVGLV9nwn+KPzEAqAjDkP/FsJyvRVKbl1k2jI2npdyvvEjEVvz+OSJwfh7bocpOF
         AgXKFw997gfpxoh82W3ZlruKp915ztbm/elBUEb1kiVLKXbWOc9vbuYdBzJQ9lGMwDru
         Au2g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=CfXBw9LL;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f41sor10790922pjg.15.2019.08.10.11.23.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 10 Aug 2019 11:23:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=CfXBw9LL;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=1wMbnmcvYThr8v75tXw+NLJxxgTL8aTm8bPoijuWeXk=;
        b=CfXBw9LLS2F5CcDSorlej7BcL3a8HeAP9pALu5KvwWwkMSPiuKBuVIY9XQmieFUYCE
         lFxYg0yhxmEmzZCTXKoFTjfqBxXQsPTI1k2u20Amu4jFI6EvtZeKX7o+G7ygYkeu9GJf
         w/8ZmCDP/svUHzPv4FGiys1oJaPjVepGIg1vo=
X-Google-Smtp-Source: APXvYqwv9kKazhsFHfQH/poO6zFrpDEO8Q9vVz6A2xAvqR+Dr3CXy+nbi3/t+heCuUrDlMSmH7frYw==
X-Received: by 2002:a17:90a:bf03:: with SMTP id c3mr14911536pjs.112.1565461400408;
        Sat, 10 Aug 2019 11:23:20 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id a1sm72180032pgh.61.2019.08.10.11.23.19
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 10 Aug 2019 11:23:19 -0700 (PDT)
Date: Sat, 10 Aug 2019 11:23:18 -0700
From: Kees Cook <keescook@chromium.org>
To: Alan Stern <stern@rowland.harvard.edu>
Cc: Greg KH <gregkh@linuxfoundation.org>,
	syzbot <syzbot+45b2f40f0778cfa7634e@syzkaller.appspotmail.com>,
	Michael Hund <mhund@ld-didactic.de>, akpm@linux-foundation.org,
	andreyknvl@google.com, cai@lca.pw, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, linux-usb@vger.kernel.org,
	syzkaller-bugs@googlegroups.com, tglx@linutronix.de
Subject: Re: BUG: bad usercopy in ld_usb_read
Message-ID: <201908101120.BE5034521A@keescook>
References: <20190809085545.GB21320@kroah.com>
 <Pine.LNX.4.44L0.1908091100580.1630-100000@iolanthe.rowland.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44L0.1908091100580.1630-100000@iolanthe.rowland.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 09, 2019 at 11:13:00AM -0400, Alan Stern wrote:
> In fact, I don't see why any of the computations here should overflow
> or wrap around, or even give rise to a negative value.  If syzbot had a
> reproducer we could get more debugging output -- but it doesn't.

Yeah, this is odd. The only thing I could see here with more study was
that ring_tail is used/updated outside of the rbsl lock in
ld_usb_read(). I couldn't convince myself there wasn't a race against
the interrupt, but I also couldn't think of a way it could break...

-- 
Kees Cook

