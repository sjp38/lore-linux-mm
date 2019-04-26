Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 43062C43218
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 08:08:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0EC312077B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 08:08:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0EC312077B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 925EC6B0292; Fri, 26 Apr 2019 04:08:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8ACA06B0294; Fri, 26 Apr 2019 04:08:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 726246B0295; Fri, 26 Apr 2019 04:08:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 26CD46B0292
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 04:08:14 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id x5so2615104wro.13
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 01:08:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=YLM+bpnD7HX1n9RHDbTE9FhZeZ5xuHY20RrgXBCSDe4=;
        b=gKDig9zTFDEbXGtzYeJfrH4Z00BCiUTaDa10egu+1og11YROQl7d1a1xvICzcpWMAE
         UdyWawA1Q+t0zfn4+EYo/klx+ajVaL3oatxHj7kQlzgsqGoLGMi0x0MMFQQViac7FPXn
         jjlzc+rnv/0NJQhGb50SCP5m39G5zADVlt2zLDkQPZSE7LY1+YzDfu9ob6ljEPQiCJaB
         sX7MdFXF2W99Yi0v/kKFSJvlil1FVIBDvit37LscIcR7439GVgTcNtn2bzL28VNQ6mvC
         B2HoIGYPBfu+hRbTFqgCX9JSw4UOAGwxSl33o/+7xxQ/8ZfDdTNUz6K0s8Rm3fbxQby6
         7VvQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning jikos@kernel.org does not designate 91.219.245.39 as permitted sender) smtp.mailfrom=jikos@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXBy4HonXEF2oUIDEkl9bmHKXYXHsk8DzPVHTDdysg9Gd4yF5BB
	zhxLUrRH4/TkYak5z1dWfzuKJ0cjMTvhGX3QGWpdOn7bGkEL1998lpGD1F6aV+8XhT1MC1v4D2i
	+5P3InTV3e4sjNe21zjLyezCD8SKa3l4h6+araIXVdNmm7HjTerafmaETknNgfLI=
X-Received: by 2002:adf:80c3:: with SMTP id 61mr4701498wrl.123.1556266093739;
        Fri, 26 Apr 2019 01:08:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzag6SbUbwlCtEorw8OWCgYWBrEtiXve1ood0LkowAJJF0c4rqd6PMP89WtwXBzUogLCEAV
X-Received: by 2002:adf:80c3:: with SMTP id 61mr4701448wrl.123.1556266093066;
        Fri, 26 Apr 2019 01:08:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556266093; cv=none;
        d=google.com; s=arc-20160816;
        b=v6rdKxD4rZFG4G/EoM2sUAV/8tXgyqJPP8DK4Vtcr2S+lM39XaUA+6kNk5hpevlTjv
         7850VNA9/qYxMYJuAYglLL4N3rzdxN2TwqmRzT0A9rpXqA4vXY7Ayd2/6vayGnO6Aidb
         DfWpX52o1Z3/DnLgZ/jqYTlRykIHQnIDFERTiUpufruZUpJdMeoj55snAytRzyQzZxGD
         Wfb6iuocSmKzsffEKKnZjbKRRN0kBz9sJpjO8GLcrG/2td/vhHqXhwwN0PKZXgtXrANv
         5CEneICgjukSvrdnNKsJkUSpEKfF6y3CyGH4Jp6A576o3BfGdUuuNqJ/Yr2JhbrTrxK2
         m13w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=YLM+bpnD7HX1n9RHDbTE9FhZeZ5xuHY20RrgXBCSDe4=;
        b=ZL1smEmpzZG7tln+YgdxJd54ayUplmaDZ6fouySSqEmXZylUp6I30UKM4Z4p9eO/BQ
         HYcPVWte5TE75YKeZYXvyoe9mj8x91SR+PupdFKhPiWx9XCZosPjFK7t2vWPUbKZE+pc
         2/3mECevUVo98x4nxkIYa9gJMzTUzfsS9TnJGkcbkwj7swcqkDRAGHrCoYDkOXCsFfl0
         QYaZtkYml9DWWTC0mwv1/vnw1y/p/ISPYgCPlJgtO1X0cJzsoeT71N4vDcHO6PXhkAGX
         5sb2KF8CF0Z2l4mqNqeDFtGRi3lhR0IrQwp/Wq3W37mhIAFDxdFKRBI3442IHihIKpgY
         o6Mw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning jikos@kernel.org does not designate 91.219.245.39 as permitted sender) smtp.mailfrom=jikos@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from twin.jikos.cz (twin.jikos.cz. [91.219.245.39])
        by mx.google.com with ESMTPS id 22si16639103wmi.44.2019.04.26.01.08.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 26 Apr 2019 01:08:13 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning jikos@kernel.org does not designate 91.219.245.39 as permitted sender) client-ip=91.219.245.39;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning jikos@kernel.org does not designate 91.219.245.39 as permitted sender) smtp.mailfrom=jikos@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from twin.jikos.cz (jikos@[127.0.0.1])
	by twin.jikos.cz (8.13.6/8.13.6) with ESMTP id x3Q87p6T000940
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO);
	Fri, 26 Apr 2019 10:07:52 +0200
Received: from localhost (jikos@localhost)
	by twin.jikos.cz (8.13.6/8.13.6/Submit) with ESMTP id x3Q87oY9000925;
	Fri, 26 Apr 2019 10:07:50 +0200
X-Authentication-Warning: twin.jikos.cz: jikos owned process doing -bs
Date: Fri, 26 Apr 2019 10:07:50 +0200 (CEST)
From: Jiri Kosina <jikos@kernel.org>
To: Andy Lutomirski <luto@kernel.org>
cc: Mike Rapoport <rppt@linux.ibm.com>, LKML <linux-kernel@vger.kernel.org>,
        Alexandre Chartre <alexandre.chartre@oracle.com>,
        Borislav Petkov <bp@alien8.de>,
        Dave Hansen <dave.hansen@linux.intel.com>,
        "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>,
        James Bottomley <James.Bottomley@hansenpartnership.com>,
        Jonathan Adams <jwadams@google.com>, Kees Cook <keescook@chromium.org>,
        Paul Turner <pjt@google.com>, Peter Zijlstra <peterz@infradead.org>,
        Thomas Gleixner <tglx@linutronix.de>, Linux-MM <linux-mm@kvack.org>,
        LSM List <linux-security-module@vger.kernel.org>,
        X86 ML <x86@kernel.org>
Subject: Re: [RFC PATCH 0/7] x86: introduce system calls addess space
 isolation
In-Reply-To: <CALCETrWkYYh=L1nSO7GYt0FvMhjCcEaQiM2JEi3FfkJbYJFh2g@mail.gmail.com>
Message-ID: <alpine.LRH.2.00.1904261006290.10464@gjva.wvxbf.pm>
References: <1556228754-12996-1-git-send-email-rppt@linux.ibm.com> <CALCETrWkYYh=L1nSO7GYt0FvMhjCcEaQiM2JEi3FfkJbYJFh2g@mail.gmail.com>
User-Agent: Alpine 2.00 (LRH 1167 2008-08-23)
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 25 Apr 2019, Andy Lutomirski wrote:

> The benefit seems to come from making sure that the RET instruction 
> actually goes somewhere that's already been faulted in.

Which doesn't seem to be really compatible with things like retpolines or 
anyone using FTRACE_WITH_REGS to modify stored instruction pointer.

-- 
Jiri Kosina
SUSE Labs

