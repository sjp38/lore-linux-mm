Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DB07AC28CC6
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 11:23:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 910F620717
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 11:23:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ZxNl0qOQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 910F620717
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2A0716B000E; Wed,  5 Jun 2019 07:23:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 24FEA6B0010; Wed,  5 Jun 2019 07:23:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 118526B0266; Wed,  5 Jun 2019 07:23:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id CBCB06B000E
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 07:23:36 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id f8so14603989pgp.9
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 04:23:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=sVN3EHsvpO4JEKTL1zRRHRBKbHxUnSg7DWieN951vaQ=;
        b=PV8jrqoMZ+8t+BPhnYh30Du0G25Dfwp0NsErsZADpKNxMvjn5A7Q0f1qlogtglcClb
         aZslVZTEYc+NuCTDD8Vdo5r91FU3DEVuhDisPeDLlOG7f5TNm4X5erzBgmGntXsg7lXH
         UjQWnU6BngM5Oa0SquZh1GEF65dJhvjeGWy1RrL4w9lzH1oETVPjcq+CbP8jukrvACti
         c2CmDdGcB7ONrG1t0uxiO0iXQQoe2yx+JYp0z+GZMDLDyAMo0VjYlNas2veIlfwkmUen
         uzfFhw9LrnPzCA8I7WLcBysQazGyxqYwlc5hKwwLBit2GXNIW5rRRw3MZYPaddbScgis
         VtHg==
X-Gm-Message-State: APjAAAWG4Ndm8/P3vn1lvoKyjjlAK8oeY4SJtgudAVq6E0fNXB7BKxY0
	0xQjfDrP5lcKXvY67o4UxRCocnXsDnVPGQ0dB288srTVQFmt2aRlCZYch5h1luKYpPT5qNP/9Pj
	ituxT54ANw33/VhZXN6muNdMGRi03PU1cQzxHpbCNac2+FQOlWqfvFCuLnK5xHmgWHg==
X-Received: by 2002:a63:fd50:: with SMTP id m16mr3601990pgj.192.1559733816379;
        Wed, 05 Jun 2019 04:23:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx9Voc4hY42cbYwvmkWeWgDgC+yJ69+YrElTdyZ1mmU56bsTcZSelsU+VlZ7kOpcm+5EFXm
X-Received: by 2002:a63:fd50:: with SMTP id m16mr3601946pgj.192.1559733815844;
        Wed, 05 Jun 2019 04:23:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559733815; cv=none;
        d=google.com; s=arc-20160816;
        b=kcUqH5Q4JFSR1mf44TlvHT1Dn1l4Y00TlkgDpY203C+eH4c6JwHlIuUHk4oQQ+fdsi
         DxIlIYwEODSlRz/YgJHR3cGR/77Lqv/nljTTuI6oC1g5sFVC7vjrrmHi50AfsIrWRVwF
         KGtF+YUtkNw8tsjPX0ByuN4FfE6aMPSLQDE82PpGkBBFlZxjAOeLxKs0l3Tpd4OKc1uL
         qy3zlkCgCWrysBK5A0DmTKqMSd8pf7oPe2tu7hdqC3F7qMOStzWFOtdZy0fH5pMKSb8z
         xa9WS7vCRAWRg9DbRVFb+RNocrfLzbdX1/R1QlJJ9JFAPlo8FBxBpE+DRiLWEZIMHA8J
         ynhg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=sVN3EHsvpO4JEKTL1zRRHRBKbHxUnSg7DWieN951vaQ=;
        b=XwdUm1sM+1bhqQaJqaREG81eMiQe2FADDS1TxumE+jMYInLY5QFeMJMxI2QH8to6GI
         pp1Eh02sJ6r37XTBMyhKrWSJFLwIAGYZtam0lHDek+A2Qo5pQxiuGhdqhEzvHyHkEcK6
         7UgwLNGFMfR826Jj+VhPEqXrQ17M/ojvitJHqUOFZUzIpr3oIg9ugFO/PDbNX2Zntv52
         Wz1KoutAQ/8pAihE3FKuIRGOq/uJlUFafuqRopB1mSMvxPiedN16QNdMb1PIXitfALxY
         5pY7KODIL4bRG4GJMSba+DHVrzI+cZtWcZtAdCckAtGJZC+TAk5MRjKlRw1oh7CypFgJ
         7cYA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ZxNl0qOQ;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id y1si24573906pjr.109.2019.06.05.04.23.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 05 Jun 2019 04:23:35 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ZxNl0qOQ;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=sVN3EHsvpO4JEKTL1zRRHRBKbHxUnSg7DWieN951vaQ=; b=ZxNl0qOQMb2nfXeNThDfWARnO
	IjMcoH4MbKtQUU/nYGjzXO/SzWGoG4bwvM6cBsqxqnboCmwXwdmrZT6ztabNtnUgigfRmXDx8fQga
	0rKqTEt4/6uc2AluHwNMT79+xCxIagqOb/We+wKGSyrnU5U0zj89HIUQ91CjDb3ocZFKE34NA73Xt
	ht21jsc6XZzCEdyBsoxDu/s7ytcLxb6tZ+TqSKkA+jPRHteOcwa78zZTOL6egPiRNwQtvKPfLFnxB
	43TAXA7rZyGVZ8LyRQz4qMmoOohTstIupqEoWtffXXODQJqZlI73n1KFz6tSlAtnVI5oGHg9JPstG
	ajfQGCbTw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hYU0u-0005Bg-TM; Wed, 05 Jun 2019 11:23:28 +0000
Date: Wed, 5 Jun 2019 04:23:28 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Anshuman Khandual <anshuman.khandual@arm.com>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
	x86@kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>, Mark Rutland <mark.rutland@arm.com>,
	Christophe Leroy <christophe.leroy@c-s.fr>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Andrey Konovalov <andreyknvl@google.com>,
	Paul Mackerras <paulus@samba.org>,
	Russell King <linux@armlinux.org.uk>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>, Tony Luck <tony.luck@intel.com>,
	Fenghua Yu <fenghua.yu@intel.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>,
	Dave Hansen <dave.hansen@linux.intel.com>
Subject: Re: [RFC V2] mm: Generalize notify_page_fault()
Message-ID: <20190605112328.GB2025@bombadil.infradead.org>
References: <1559630046-12940-1-git-send-email-anshuman.khandual@arm.com>
 <87sgsomg91.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87sgsomg91.fsf@concordia.ellerman.id.au>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 05, 2019 at 09:19:22PM +1000, Michael Ellerman wrote:
> Anshuman Khandual <anshuman.khandual@arm.com> writes:
> > Similar notify_page_fault() definitions are being used by architectures
> > duplicating much of the same code. This attempts to unify them into a
> > single implementation, generalize it and then move it to a common place.
> > kprobes_built_in() can detect CONFIG_KPROBES, hence notify_page_fault()
> > need not be wrapped again within CONFIG_KPROBES. Trap number argument can
> > now contain upto an 'unsigned int' accommodating all possible platforms.
> ...
> 
> You've changed several of the architectures from something like above,
> where it disables preemption around the call into the below:
> 
> 
> Which skips everything if we're preemptible. Is that an equivalent
> change? If so can you please explain why in more detail.

See the discussion in v1 of this patch, which you were cc'd on.

I agree the description here completely fails to mention why the change.
It should mention commit a980c0ef9f6d8c.

> Also why not have it return bool?
> 
> cheers
> 

