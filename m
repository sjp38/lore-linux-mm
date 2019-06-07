Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 779EFC28CC3
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 07:47:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 21D34208C3
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 07:47:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="vCOYZfHI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 21D34208C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C5F466B0269; Fri,  7 Jun 2019 03:47:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C10936B026F; Fri,  7 Jun 2019 03:47:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AB24E6B0271; Fri,  7 Jun 2019 03:47:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 713266B0269
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 03:47:22 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id a13so875034pgw.19
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 00:47:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=pk7+TGVjtRz6ayURhW13Uv/LT+UErfa7VAtt4gHuM/4=;
        b=ah/ek6tviGVcqG1u5erFDD/lg7EdufLeOGKAOTmX/IEbRlFwgbodzx+oHPiR6rdMuv
         d1BwPg5svNQWeInJcy80FW2wz0EdoRuZfkshMac58I434P+uGzdfmh8SVHqpISvEc3XW
         cFuNruGevzLBXLG2GcqW7qim8jJv1/kWPXQPGUbMU6zjiJOeoJ7owadt8Bhso889mWXs
         1td637AtG5XXdZvVhJ9u7vjAFjsDDAixdN0bkZ0Sc4iFO0UucxgR/XAUnLtE6ySoLJzp
         ZqlKIunkOFvr7z1BQPa+EqJQFqfa58wtSWQ7CU/l6YwM9FQtGm0+eIEVsZMT4zmzeHBh
         UZiw==
X-Gm-Message-State: APjAAAVeliJEKeCm3Mbn01AwAs6hfqiHn6pN33WzVzmbx+n5JaWoTDfC
	UXHW6VAJprNOTR6GA5I6DEjq2gupoDRMzaE6urkBpkU910s42InXBWWedry0NhVoWSBmxn6wMCQ
	oOrtBpX7b9mtl+sYAR3GQXw8zXYcZE6SmZ7+KnfefGEGADWDtSpEBvlQS4mS0Q6ISRQ==
X-Received: by 2002:a17:902:a60d:: with SMTP id u13mr48953254plq.144.1559893641661;
        Fri, 07 Jun 2019 00:47:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx+JJfJNNwchaMcxTfv9AD7gyi27c9xisYoyrM56KCK3eoxVCfOoDVkamxi43YYYXtI7zwd
X-Received: by 2002:a17:902:a60d:: with SMTP id u13mr48953217plq.144.1559893641053;
        Fri, 07 Jun 2019 00:47:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559893641; cv=none;
        d=google.com; s=arc-20160816;
        b=eKFBxuXWiST5AGkvWGxaY1xSQ6tj0YgIgFY3XBRp+oo9qE9gNNUeovyhqZW/tUPkoI
         tnEYKI0SG0DUvOZLLBlFZkK7rd6aA3XGM1EMPw1JpIJNPfkToQRAtpy8+26df7OACF9R
         lc0AIracia/yuExEm6CLMSx20bX/rS9voiCd7GWYWLPO5/oY2RIWOW9DPJrg4vu6gjWL
         sCWaStVrbYNMkr3J+ad/SwHhO/DADvVgATx8nNnP/y8uYLx1VbkdTgy7Jl5fav7wTPs6
         sj68f0rADzfG5TzP+xWJoFqH68igvn286dBX2oEV3cSeunJAc/RKxc0snGp7pqyQaBIU
         JVPA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=pk7+TGVjtRz6ayURhW13Uv/LT+UErfa7VAtt4gHuM/4=;
        b=u4QOq22paoiKvxAupXrCyYjxsIA96MBdF/OJWGo+nHsJSRRrjUs/cQDymPLWJkOwwi
         iXFAWrrMXJNKacfqIMTbFKqPgizZ9DDwsYLh/WGtUOWzMArtBcZf0NQUt0DLmxErSFus
         svG/ci67btm3HRp5ESIch3SsD1aUujNtJMkYNUJC25fFfyXR/aQwZg5LUiNqLlIJKvy2
         ISGZToGeOjOozwW71LudsOntCehob+Q22ILUvzya/5Ok9CW/wNR5g06uhk+qgR4r4srw
         pX5ow4MQ1LopkdViPu8gxCY6+syQtOOEWjoHpQfXAHXFAltBpbWf2C3fuaeH8e4DuXnJ
         UT8A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=vCOYZfHI;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c1si1214635pla.122.2019.06.07.00.47.20
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 07 Jun 2019 00:47:21 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=vCOYZfHI;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=pk7+TGVjtRz6ayURhW13Uv/LT+UErfa7VAtt4gHuM/4=; b=vCOYZfHIc2QIziL0JfGkxJaye
	3oyYvYZZY9uswI49S/Md42reZoVcucBwoIpBbpwfmHykVF4iYUKs582hHrkdYALvJ95vfU2hqE53e
	lKssLDvhkYK+0EOhuEkc8gWlvF53pDCi5Eficx9GCTdMrOCmZG7xLjPhXOLuCtswvupFweGf/Kk2C
	b7vhADU5DCwIXZ2VG15bfFu+DhSUxXi9SPdcFU8mhbQsytzy/OJjV3MVzSwzddnNO+Me4Yhwzy3Wq
	GGakVd16gLKf/z129n4Bha66KFCnBCn/GYbM8MdPd8NhxjW2De6Ot+fQe9/kpt/U7MePndcm6cnhX
	3AoNPthrw==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hZ9af-0002pj-Ag; Fri, 07 Jun 2019 07:47:09 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id A5C27202CD6B2; Fri,  7 Jun 2019 09:47:07 +0200 (CEST)
Date: Fri, 7 Jun 2019 09:47:07 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-mm@kvack.org,
	linux-arch@vger.kernel.org, linux-api@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>,
	Andy Lutomirski <luto@amacapital.net>,
	Balbir Singh <bsingharora@gmail.com>,
	Borislav Petkov <bp@alien8.de>,
	Cyrill Gorcunov <gorcunov@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Eugene Syromiatnikov <esyr@redhat.com>,
	Florian Weimer <fweimer@redhat.com>,
	"H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>,
	Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>,
	Pavel Machek <pavel@ucw.cz>, Randy Dunlap <rdunlap@infradead.org>,
	"Ravi V. Shankar" <ravi.v.shankar@intel.com>,
	Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>,
	Dave Martin <Dave.Martin@arm.com>
Subject: Re: [PATCH v7 18/27] mm: Introduce do_mmap_locked()
Message-ID: <20190607074707.GD3463@hirez.programming.kicks-ass.net>
References: <20190606200646.3951-1-yu-cheng.yu@intel.com>
 <20190606200646.3951-19-yu-cheng.yu@intel.com>
 <20190607074322.GP3419@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190607074322.GP3419@hirez.programming.kicks-ass.net>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 07, 2019 at 09:43:22AM +0200, Peter Zijlstra wrote:
> On Thu, Jun 06, 2019 at 01:06:37PM -0700, Yu-cheng Yu wrote:
> > There are a few places that need do_mmap() with mm->mmap_sem held.
> > Create an in-line function for that.
> > 
> > Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
> > ---
> >  include/linux/mm.h | 18 ++++++++++++++++++
> >  1 file changed, 18 insertions(+)
> > 
> > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > index 398f1e1c35e5..7cf014604848 100644
> > --- a/include/linux/mm.h
> > +++ b/include/linux/mm.h
> > @@ -2411,6 +2411,24 @@ static inline void mm_populate(unsigned long addr, unsigned long len)
> >  static inline void mm_populate(unsigned long addr, unsigned long len) {}
> >  #endif
> >  
> > +static inline unsigned long do_mmap_locked(unsigned long addr,
> > +	unsigned long len, unsigned long prot, unsigned long flags,
> > +	vm_flags_t vm_flags)
> > +{
> > +	struct mm_struct *mm = current->mm;
> > +	unsigned long populate;
> > +
> > +	down_write(&mm->mmap_sem);
> > +	addr = do_mmap(NULL, addr, len, prot, flags, vm_flags, 0,
> > +		       &populate, NULL);
> 
> Funny thing how do_mmap() takes a file pointer as first argument and
> this thing explicitly NULLs that. That more or less invalidates the name
> do_mmap_locked().
> 
> > +	up_write(&mm->mmap_sem);
> > +
> > +	if (populate)
> > +		mm_populate(addr, populate);
> > +
> > +	return addr;
> > +}

You also don't retain that last @uf argument.

I'm thikning you're better off adding a helper to the cet.c file; call
it cet_mmap() or whatever.

