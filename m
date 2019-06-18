Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1DEE0C31E51
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 12:56:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D094220665
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 12:56:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="NFww7+43"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D094220665
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 63FFE6B0003; Tue, 18 Jun 2019 08:56:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5CA648E0005; Tue, 18 Jun 2019 08:56:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 41C7B8E0001; Tue, 18 Jun 2019 08:56:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 070CB6B0003
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 08:56:42 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id 14so9859730pgo.14
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 05:56:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=PYbrunDp8avnP39gEYH1AHS83LwzriBAbK/nP8h6WlU=;
        b=XL560Rz+vP8YcOKqeZsaL9WKLHdK6wgridse+Q87Lc3jTRdSAoi6XRw6N9A/na6kyp
         ftkqPCSTZ2TAyzjsocSMzdlXECCFsCwlHLSVYmuf0g9vHoKikI1qEURFCoVIX6AyhDbl
         FXnoMQF4qOxMkMmK+Uid9eIE/WqHXhd6QyMx7zoB031Beug/JMz1u5/aIneFv4AKpdaQ
         BuOf0zYPRO3yU/+JBard9SoV3/f5qaQ68a8ivXANV+io/DsJt084fLRpE/25zwAk6eo5
         1/0pf2v+XoYgliPiAaHnjeztX9/hiFV0J84hp8S66d9yxVufRUd6F7bEDMI1WIYIZ+a2
         bm9w==
X-Gm-Message-State: APjAAAWntgiVJL/B8GdT93MAitNVqXRbBPONqtoaMkge2Az7Tg2aA+h1
	bdD1H6hiBO2fd6yK3fU4RzmhgJm1qYs8vzxtubRcVS9nMkr6MLH/Fxhge6J9+2lAB7QTDkMaD7i
	zowuCwPb0ks4no4+cOc5WSTMlvwszM2u7BJXeNI/V3H8qadw3oA+LNpvbKWbf8SUFNQ==
X-Received: by 2002:a17:90a:bb8a:: with SMTP id v10mr5128541pjr.78.1560862601561;
        Tue, 18 Jun 2019 05:56:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqweMKhVbwdZeBEFJR2+9Uzj1ZF0+k3fsN34thyjE50u1FHdhHXqvezK3eLO8lgwQYdEmCAM
X-Received: by 2002:a17:90a:bb8a:: with SMTP id v10mr5128507pjr.78.1560862600953;
        Tue, 18 Jun 2019 05:56:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560862600; cv=none;
        d=google.com; s=arc-20160816;
        b=ITv0y314T6rNqYXozMPtXiJLZecL7LNOgB3p6xDWQL9hd/DLsPPsPUxZFEXCROHmfC
         iG3eznkS+4tRW72HgccqRUyNy+MXixw5aJ0yNXZwiZvaYgruk4i1yyE/kdfjkIJz/DeA
         H76uTxYYVmFJWtABZubafT/f7ZhRzXLuXoI/sOdGYxBrhVCVdJOLPiy2wNlS4E5wAzpr
         OHx4FZzgvM5/QCcEFvLE+2tVoEc5KyVOCk+/pd5wvHHG1t9bNVpBmvB/DAI7gIC2+E0R
         cdGciIs1mMd4UvAn6vea+1CqUymj/wNlA5doW3MfixOlraqQHRqHoLUboGfxi+yS7nQ4
         pb6Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=PYbrunDp8avnP39gEYH1AHS83LwzriBAbK/nP8h6WlU=;
        b=iyVQgo0q+s8F4V/amncIQtB3NkyU9/wCKvgZ9LMDkezV3xeuIoniHoMhQq2wqhwOsl
         5OaAuj6POi59WCs8PVq+1VM7tQgYh+UdVE0vAbjZzklNlaVNNi6nD/39MhXT3ba3yTwK
         UruEYKjoFxi/AclCD2UbKJSgmslbKCi5hleBY5/uzlNSUYjoufoH7ql2sCmHeZrfNa81
         ZFWyZgPUa5x25bz87vecTg0DmIkroOsU6zT1slXKe9xD5eCl1AKjJdkg7yw3dlLG4M+z
         Lt7sDA/sKpErsbIKJ7yyxgjhPaXNkk5NP1Z4fXfe2Q9LnabLXSeCH1rzYwhlD/aMktUT
         RlDQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=NFww7+43;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c6si161056pgw.166.2019.06.18.05.56.40
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 18 Jun 2019 05:56:40 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=NFww7+43;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=PYbrunDp8avnP39gEYH1AHS83LwzriBAbK/nP8h6WlU=; b=NFww7+43UaA1stlBZehQjCp02
	Y7PtLUydx/okAC0L065bNSF4kxrjfybpYCytKhBCt/18SskmlAZk54VtmxcTdjaV6l1FMFthC5b0i
	g9LFyUYpap0oM0WUfvOC+uNl0RB8e9btq4wFuWLqtjMG8DydgEMXYlnpOjjh5PK3JwigOIcp8y1qA
	XFJOPsNh/gPO5nCfvM+zPvS4/0w5arjT21lzZ1nIwVKocPkNGOuTqKfPxDJTast1+Si3zME1zgiU5
	V4a5T1WO4eAk1zwJCyZ9GHLBiN9Dqu3GL3wCSnYDNDs1SQpeh8dJAPay0ARexe8rwh5RbgmCRJM2l
	qYBjy0PXQ==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hdDdr-0002GP-Ll; Tue, 18 Jun 2019 12:55:16 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 15A3D209C8915; Tue, 18 Jun 2019 14:55:12 +0200 (CEST)
Date: Tue, 18 Jun 2019 14:55:12 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Florian Weimer <fweimer@redhat.com>
Cc: Dave Martin <Dave.Martin@arm.com>, Thomas Gleixner <tglx@linutronix.de>,
	Yu-cheng Yu <yu-cheng.yu@intel.com>, x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>,
	linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org,
	linux-mm@kvack.org, linux-arch@vger.kernel.org,
	linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>,
	Andy Lutomirski <luto@amacapital.net>,
	Balbir Singh <bsingharora@gmail.com>,
	Borislav Petkov <bp@alien8.de>,
	Cyrill Gorcunov <gorcunov@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Eugene Syromiatnikov <esyr@redhat.com>,
	"H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>,
	Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>,
	Pavel Machek <pavel@ucw.cz>, Randy Dunlap <rdunlap@infradead.org>,
	"Ravi V. Shankar" <ravi.v.shankar@intel.com>,
	Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>
Subject: Re: [PATCH v7 22/27] binfmt_elf: Extract .note.gnu.property from an
 ELF file
Message-ID: <20190618125512.GJ3419@hirez.programming.kicks-ass.net>
References: <94b9c55b3b874825fda485af40ab2a6bc3dad171.camel@intel.com>
 <87lfy9cq04.fsf@oldenburg2.str.redhat.com>
 <20190611114109.GN28398@e103592.cambridge.arm.com>
 <031bc55d8dcdcf4f031e6ff27c33fd52c61d33a5.camel@intel.com>
 <20190612093238.GQ28398@e103592.cambridge.arm.com>
 <87imt4jwpt.fsf@oldenburg2.str.redhat.com>
 <alpine.DEB.2.21.1906171418220.1854@nanos.tec.linutronix.de>
 <20190618091248.GB2790@e103592.cambridge.arm.com>
 <20190618124122.GH3419@hirez.programming.kicks-ass.net>
 <87ef3r9i2j.fsf@oldenburg2.str.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87ef3r9i2j.fsf@oldenburg2.str.redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 18, 2019 at 02:47:00PM +0200, Florian Weimer wrote:
> * Peter Zijlstra:
> 
> > I'm not sure I read Thomas' comment like that. In my reading keeping the
> > PT_NOTE fallback is exactly one of those 'fly workarounds'. By not
> > supporting PT_NOTE only the 'fine' people already shit^Hpping this out
> > of tree are affected, and we don't have to care about them at all.
> 
> Just to be clear here: There was an ABI document that required PT_NOTE
> parsing.

URGH.

> The Linux kernel does *not* define the x86-64 ABI, it only
> implements it.  The authoritative source should be the ABI document.
>
> In this particularly case, so far anyone implementing this ABI extension
> tried to provide value by changing it, sometimes successfully.  Which
> makes me wonder why we even bother to mainatain ABI documentation.  The
> kernel is just very late to the party.

How can the kernel be late to the party if all of this is spinning
wheels without kernel support?

