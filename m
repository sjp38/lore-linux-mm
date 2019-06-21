Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 68F24C43613
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 13:36:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2225E208C3
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 13:36:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="zrrtFvrl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2225E208C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A914E6B0005; Fri, 21 Jun 2019 09:36:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A41098E0003; Fri, 21 Jun 2019 09:36:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 909938E0001; Fri, 21 Jun 2019 09:36:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 464EA6B0005
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 09:36:13 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b21so9195330edt.18
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 06:36:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=cnC3suzlgwD62Q8O7FoLN2Bc0yj3F9CWcR6TgaR1LLc=;
        b=rh+GxJP/hzMdL+zFPTayk5aIGlS/4pY/HGTgoGdoeQye6UbufyUli/KWeqoiu26YXh
         +/EY5mAkUSebqcSmgOagt5AO69XV4AoRReSuyX2JvTiNCoZ6Y3sbIXnctRrMFAiMRKcV
         bQj+aZ782hpfL0JvA+xjGcif4TXYzkmjA20UUaBRdTJkH7KqlhLMg/Rk5DD7KUUZGnRe
         x1NVjAFBTCwqiKle63j5zqmYsMFjzOpWg+Vr5mhaJFCzH900fOoFUUYA5AZ0s/3xMM5R
         Ua5yxKVB0oj5DEr51oqIl4K/o/t6xUFFDGk2w29rIjvB0UyVJirfVJl/s2UaAZ1OYVue
         k1mg==
X-Gm-Message-State: APjAAAWSPtEjSFXVwG5x3EUrhzmthvZ4sqhVecf18xBxDULF9evGfMXO
	ZrmoGblVDcHeRwHj/q8A92A2QHbkXuYq44l5wH0spuJcnhFamr9HOFDP0uVKT/9Hm/cbpY/m67Q
	mS/LZz75hwIk6FxhkNIiLPoAFXUHGpjpCANZgrDC5eiWGCJHhEg3niVYeSJNlxJer6Q==
X-Received: by 2002:a50:b3b8:: with SMTP id s53mr65037628edd.61.1561124172720;
        Fri, 21 Jun 2019 06:36:12 -0700 (PDT)
X-Received: by 2002:a50:b3b8:: with SMTP id s53mr65037560edd.61.1561124172062;
        Fri, 21 Jun 2019 06:36:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561124172; cv=none;
        d=google.com; s=arc-20160816;
        b=gZvsYzYHoCFs8saM/EIMLQr2k7daUGJqa/vnVpPj1hPgOsroPQZlLdZ2DJRykKO6NR
         m/2m5AY5RUPsyhRPmTKMQ9vSlQtX77YrSasIwdBBxe5CI3oMvEfHwfhgyXsBYvGsqLr7
         QxcRiXh8og+4GL7Feb4cClUVZoGFlqtHTBPTfGemqG0SL4IEsGKjJ1XgbHJZTRO6laLN
         C5mMc60+URlT7DUXD14WEIMvAmlDFFV+MsWYrIFtmMh935dpaS+C+RK1qSYgZx1EdNo+
         o71PNTUD2dqAWhFO5ff/AwlazaXbMHcC3mEmkcRZYcqVu3SkzDiLL52pm0Qn7fvuQpDu
         NOKA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=cnC3suzlgwD62Q8O7FoLN2Bc0yj3F9CWcR6TgaR1LLc=;
        b=KiLe9JZ/BqbAc7MGDXVh3EXltr1E/JIPze5vl8HvuBzlV9siknJ0xf+99+MC0qlkUa
         ROJ8pR/8+9bXdeW2pf2xQMqm5ZcoLPIPux371/Ak1pAq0BTV2YQifY6Fwo7VFTYW6mxD
         JyZ9BdlEunlGdcvUo7NXoeToxBra0SbAZMNPR7ue1Ci2MFzkKd/hw7nPQxheavUwRKIC
         TAQiN1OM23WR9+6kVU6U+Opxz755IwoMZqvAgzwlrf6HZrQhYKwuTOBfjViFYdJpVC3t
         lQgf9vVNQIdRN7DtlbuGJCYSBlf7xwuozW6Tq+lyZR5hv9BEpjTN57rOAcWXczeZkMTl
         VF/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=zrrtFvrl;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s12sor1026082ejl.47.2019.06.21.06.36.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Jun 2019 06:36:12 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=zrrtFvrl;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=cnC3suzlgwD62Q8O7FoLN2Bc0yj3F9CWcR6TgaR1LLc=;
        b=zrrtFvrl4p7uTqycYUBHGqaztc91HANl9u9PpKLY7U7rcWsCOOeWiEDqlASL4SSEuY
         ZqqicXW/nV5z+021k5EusmejEXXNNfgLn3AvyKy6M71xezPYdXaG0rCj9wTdkWiMDHkG
         /Cl3PE8EUukQhj0s9A9WX3zqTgEwNaIZaXQQnVAE/2/gc7JSt8hB0gS4w2ympIr1Yrxy
         mmZzOvlxL/7bfRgFnthfff+zVrJS39UskfbFNPwu7sXRX8oj+Ufgl3BNlkqQMt6o9YAN
         jqRYeFjPL/z3fsImc5/ifslgFZuK7s81erlgqIukiir0X2pl9WFKyjdvldE9MDFxGJ+Y
         EpPA==
X-Google-Smtp-Source: APXvYqylF/ZGnoajREjtqJ3qd8ZnbSjXbf2NB4U/xNXjWS/QwEe58V6Y8Ny7PU80e6ICaU6cNuj7qg==
X-Received: by 2002:a17:906:5008:: with SMTP id s8mr80542081ejj.308.1561124171736;
        Fri, 21 Jun 2019 06:36:11 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id e1sm432826ejl.2.2019.06.21.06.36.10
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jun 2019 06:36:11 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 39A5410289C; Fri, 21 Jun 2019 16:36:13 +0300 (+03)
Date: Fri, 21 Jun 2019 16:36:13 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Song Liu <songliubraving@fb.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
	"oleg@redhat.com" <oleg@redhat.com>,
	"rostedt@goodmis.org" <rostedt@goodmis.org>,
	"mhiramat@kernel.org" <mhiramat@kernel.org>,
	"matthew.wilcox@oracle.com" <matthew.wilcox@oracle.com>,
	"kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>,
	Kernel Team <Kernel-team@fb.com>
Subject: Re: [PATCH v4 5/5] uprobe: collapse THP pmd after removing all
 uprobes
Message-ID: <20190621133613.xnzpdlicqvjklrze@box>
References: <20190613175747.1964753-1-songliubraving@fb.com>
 <20190613175747.1964753-6-songliubraving@fb.com>
 <20190621124823.ziyyx3aagnkobs2n@box>
 <B72B62C9-78EE-4440-86CA-590D3977BDB1@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <B72B62C9-78EE-4440-86CA-590D3977BDB1@fb.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 21, 2019 at 01:17:05PM +0000, Song Liu wrote:
> 
> 
> > On Jun 21, 2019, at 5:48 AM, Kirill A. Shutemov <kirill@shutemov.name> wrote:
> > 
> > On Thu, Jun 13, 2019 at 10:57:47AM -0700, Song Liu wrote:
> >> After all uprobes are removed from the huge page (with PTE pgtable), it
> >> is possible to collapse the pmd and benefit from THP again. This patch
> >> does the collapse.
> >> 
> >> An issue on earlier version was discovered by kbuild test robot.
> >> 
> >> Reported-by: kbuild test robot <lkp@intel.com>
> >> Signed-off-by: Song Liu <songliubraving@fb.com>
> >> ---
> >> include/linux/huge_mm.h |  7 +++++
> >> kernel/events/uprobes.c |  5 ++-
> >> mm/huge_memory.c        | 69 +++++++++++++++++++++++++++++++++++++++++
> > 
> > I still sync it's duplication of khugepaged functinallity. We need to fix
> > khugepaged to handle SCAN_PAGE_COMPOUND and probably refactor the code to
> > be able to call for collapse of particular range if we have all locks
> > taken (as we do in uprobe case).
> > 
> 
> I see the point now. I misunderstood it for a while. 
> 
> If we add this to khugepaged, it will have some conflicts with my other 
> patchset. How about we move the functionality to khugepaged after these
> two sets get in? 

Is the last patch of the patchset essential? I think this part can be done
a bit later in a proper way, no?

-- 
 Kirill A. Shutemov

