Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 900EDC10F0C
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 13:08:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4D23B2075E
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 13:08:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="gH2HKKrq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4D23B2075E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E17FD6B0007; Thu,  4 Apr 2019 09:08:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DC5D36B0008; Thu,  4 Apr 2019 09:08:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CDDC66B000C; Thu,  4 Apr 2019 09:08:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id 69AEA6B0007
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 09:08:45 -0400 (EDT)
Received: by mail-lf1-f69.google.com with SMTP id w10so269845lfn.20
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 06:08:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=ydhQYDsYO5blITLWkKkMOKoBtLuqbWY/Tzn56seZhUY=;
        b=ImHe/mvKyfg4bHYFrv9H78zvt6whj1gCVpMJVv71p4Cuw/PrsR55k3aVJjVK+9w9hE
         lEVSseWKzEIY246Lf5kvigWvAFLkXyQdMuVkYsRlJFXE7dj2JYcevfVQrX1zMs7Y1ixY
         bPBlX1w0pbyJlDNlpzGuZ7BkEFfAfpsjm26eP7VMTRpqdrBSghEzyh90LaiSGHaESCDg
         iW/BIh8EJkY9BoL8DrToNG/YdXzqErtBdilinAJ+RyqPTzB8JqiJ2U5IgwWj7vcjbYNI
         yNVYEngJfbLUQjIzD37atBsld+DBcvUS5wx8D/zWciwIs3ipaFO62W7VLvEj3glWYx8A
         gSlQ==
X-Gm-Message-State: APjAAAWxWQlp7DnftAIP94RErNYg3KVvc0m1Oo+nbUoJc8zYnS2oWCHq
	C200mnc9q+0chh2lM4n9UmpgWt3P7BGOfLNCsr7vq0t+B4+KXZvyLJlDiTRbi4HnwfNkIoyiVFl
	ccfdgL03592cQsgIPLrQ74aHjAFa0uJf3gjS/ruqF1DpgPI78PGkP98Nn751pRJOe/w==
X-Received: by 2002:a2e:219:: with SMTP id 25mr3403472ljc.34.1554383324470;
        Thu, 04 Apr 2019 06:08:44 -0700 (PDT)
X-Received: by 2002:a2e:219:: with SMTP id 25mr3403417ljc.34.1554383323402;
        Thu, 04 Apr 2019 06:08:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554383323; cv=none;
        d=google.com; s=arc-20160816;
        b=AXxPlOvAky5QzcyStzYX3ozCnh7xJP7QUIe+87AzUm9wClaBiaNF9x74F/J5Dha8E0
         YBSmw9F7Kx/vU8r31RDlioAXRClmHIyK1l2lrWdHI+JotfRm9jmgCqNiZLpyb9nsGCuS
         0StbK323A6y7DrJA68fvnmtPk8x/tH4piQAwTYY8285hcyUeWcROtBw0L3nU6G1qMtTz
         IFGwJjLE+CQuBY2URHKR66LFPy6MQjceMf4K38UEMHxnSBNTpy4biy6IsoIed/E5+yqx
         N1ZrRJpnIWx4Alq0DjTExIumOhxwQlcaljql7HVgE7fkZtom9EtcYp6c8Tf/d/Ctvkcc
         mnTw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=ydhQYDsYO5blITLWkKkMOKoBtLuqbWY/Tzn56seZhUY=;
        b=XL4JEM3Pn0/9XQR809ntil37s2dZoMEz6pOA4K/UsNBcTYGMEvW0rKGlzVsUhNuA0h
         e7s+XsseTFypfydoVu0g2miydgmkRZkn/bgMtxuUOJnmLMhxTbe2Pi6Zskkuc5gAOitZ
         OF9pg0o+dGM9kJyXHZ9U4WO2sm1sE6u3+NU01Xf1irwYX4iWDl3Gosk/iyIxARg1XbwI
         y1oHT0zlH/sso+3O9jNS/XH1XB9y4EhYIRYeET4MpQzfxww8l78g/5TTJ5yLs28+L1UP
         pqycSRdFjdmkfQCXsJWAAjsyt7YVFMuITQDAYY+u3JHkgzh3XLmMm8TaIYWWcZMInG7u
         /w5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=gH2HKKrq;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z8sor5307583lfj.47.2019.04.04.06.08.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 04 Apr 2019 06:08:43 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=gH2HKKrq;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=ydhQYDsYO5blITLWkKkMOKoBtLuqbWY/Tzn56seZhUY=;
        b=gH2HKKrq1I97KbmXoHT0RPv9oGKzcranbkpFUNclk2IQ/PlMg+i+bBHEhKoYTJXg4e
         LtoEjliHav/Yfdhpq1UclvTyx4s8eb3Dnx63eGac0SrVNZ930iHOldoOoYvwMld/TWrO
         1wADWyFBeJ7EmzZlulI+klB53ianLFmNr8Y+DXSCqjyLWSp3oank3TR+VTki5vnNNKUS
         TvBQPMbhiWn/99s0PdvOiuUnfeIPzy639yCVMFKMb1sPm+avXRlvtTlo4ZHWx/q9d/Gi
         H92iFBioHoQJuSTW5sPfJwpDnPV1tFj+tsZZoE1zhYEJVhfxwrq3185bw/gPAF7l2ILZ
         PhfA==
X-Google-Smtp-Source: APXvYqzAwanZ+nskhouSYnB3oZZUeZzTzBAZAbOnXlbYnKQKzGspAQ0VLl1GDm/+7D/PYNzC/4Gt0g==
X-Received: by 2002:a19:5201:: with SMTP id m1mr3222474lfb.68.1554383322830;
        Thu, 04 Apr 2019 06:08:42 -0700 (PDT)
Received: from kshutemo-mobl1.localdomain ([178.127.198.154])
        by smtp.gmail.com with ESMTPSA id v26sm3970728lja.60.2019.04.04.06.08.41
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Apr 2019 06:08:41 -0700 (PDT)
Received: by kshutemo-mobl1.localdomain (Postfix, from userid 1000)
	id C004C30039B; Thu,  4 Apr 2019 16:08:39 +0300 (+03)
Date: Thu, 4 Apr 2019 16:08:39 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Jan Kara <jack@suse.cz>
Cc: bugzilla-daemon@bugzilla.kernel.org, linux-ext4@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [Bug 203107] New: Bad page map in process during boot
Message-ID: <20190404130839.5tkpwihuct4mex32@kshutemo-mobl1>
References: <bug-203107-13602@https.bugzilla.kernel.org/>
 <20190402101613.GF12133@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190402101613.GF12133@quack2.suse.cz>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 02, 2019 at 12:16:13PM +0200, Jan Kara wrote:
> Switching to email...
> 
> On Fri 29-03-19 20:46:22, bugzilla-daemon@bugzilla.kernel.org wrote:
> > https://bugzilla.kernel.org/show_bug.cgi?id=203107
> > 
> >             Bug ID: 203107
> >            Summary: Bad page map in process during boot
> >            Product: File System
> >            Version: 2.5
> >     Kernel Version: 5.0.5
> >           Hardware: All
> >                 OS: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: normal
> >           Priority: P1
> >          Component: ext4
> >           Assignee: fs_ext4@kernel-bugs.osdl.org
> >           Reporter: echto1@gmail.com
> >         Regression: No
> > 
> > Error occurs randomly at boot after upgrading kernel from 5.0.0 to 5.0.4.
> > 
> > https://justpaste.it/387uf
> 
> I don't think this is an ext4 error. Sure this is an error in file mapping
> of libblkid.so.1.1.0 (which is handled by ext4) but the filesystem has very
> little to say wrt how or which PTEs are installed. And the problem is that
> invalid PTE (dead000000000100) is present in page tables. So this looks
> more like a problem in MM itself. Adding MM guys to CC.

0xdead000000000100 and 0xdead000000000200 are LIST_POISON1 and
LIST_POISON2 repectively. Have no idea how would they end up in page table.

-- 
 Kirill A. Shutemov

