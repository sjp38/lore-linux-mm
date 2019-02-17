Return-Path: <SRS0=1HZa=QY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 81336C43381
	for <linux-mm@archiver.kernel.org>; Sun, 17 Feb 2019 06:23:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 145942196F
	for <linux-mm@archiver.kernel.org>; Sun, 17 Feb 2019 06:23:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ifcnmcwM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 145942196F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3F9988E0002; Sun, 17 Feb 2019 01:23:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3A91D8E0001; Sun, 17 Feb 2019 01:23:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2BF598E0002; Sun, 17 Feb 2019 01:23:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id DF7628E0001
	for <linux-mm@kvack.org>; Sun, 17 Feb 2019 01:23:40 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id g13so10106082plo.10
        for <linux-mm@kvack.org>; Sat, 16 Feb 2019 22:23:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=nm7Mpr2bFzDsTZtDgyvgfnqAVAhEse/hD66HPwpevYI=;
        b=FD0MwVsyO00ibrkGhtF/xvVXXj+ixZHNQzw/atawd/68Y4oTMF7cLTxJ4fmCByoGAA
         17mGehbNw/dcieS+T1lsZyNCredZIZjCtmOrbE8XcpC9xrwrUwMvO3QDrzxVj1Lqy6gv
         4KtXtWzli6tVvjVO5WzeMLbgSuaHcnWVTbI49V5eJuTGa6neUC5zTOxwperjQquE5kI2
         zvBvnp4HDVJlMuQ6q6kIQelTpu3P0/zTfd1Hf21gRa3XIH4BlLhf0D4tRVaVAG3n1cON
         13cuE8ItdOSaEtwthYToEzz9RP/md380nQF+C7/YxO+sIkbtWhmtcG7Oq4LEaitv+4tO
         uoJg==
X-Gm-Message-State: AHQUAuZifr3rjcSva1YLk/kskxr/owP3sWi06bYtnf8i+vnZ+l4qjIaL
	0TlowR8x4dv7IK+YhxrDv96OXbZAn7iuIT7+25XZqKJP+9jq6QnzAMq8oabjtxYEd86yyIRAffE
	ABFbsKUZRMywS+g2GbR+pwdqSFdThZdS6Ufln/LPwpjX0gh3I7FaEe2DGK18tsfxG2EAGdA4D5I
	cI8vsR/WkafeK8yuMtlh2IzGkyn4FPFp87YaTdnQSj7OMR2a4hrQAhXwmOnub8aYxOd5cwXyRzo
	khBNacBkxiW5o7juuuYhqNdQUQ9n+Iqy80NpU0yMGUxmqlgAasf188JoXApQ3UyeM46aX5c5hJX
	SC9mxhPT7CIRQdJGM7iAMFg0roKUyfKJUFfd8XafGWb0LDIAtJrEcYhxCHpBOrK/8lnOWy0D/ru
	l
X-Received: by 2002:a63:e84c:: with SMTP id a12mr16800476pgk.241.1550384620462;
        Sat, 16 Feb 2019 22:23:40 -0800 (PST)
X-Received: by 2002:a63:e84c:: with SMTP id a12mr16800437pgk.241.1550384619733;
        Sat, 16 Feb 2019 22:23:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550384619; cv=none;
        d=google.com; s=arc-20160816;
        b=RbBU+lBjA2AAa3j0LgwIq4Qss6qwbHKCiN8ZNiYnOQUU4wKS1hWSpaecJmxRl/REdJ
         Bqt7zoxad5u7+gV3Qf+rD5I3tdTTwQCVCsbu8GOn/sSVI4C4EJQOEfbcH12IOwCjhWv2
         klp7vWMe+/uN9D8DdceYnbnv+YTQQTiijcFFqhfW6OCvzjsZ9oZar7hhWVU5hVgrkqNI
         0PZiIAbJMVRKqOx30LkbPtmL3fTi5JQTc+IoETA+MSutcvgybQJxd4G+xJfoNAhDdXe2
         5bexkI+UP+icEpizFESQycwqdy7rZAK/RT5u0JJVEU3io1BaIeqrZi/eBCDkJi4RGlGh
         gv4Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=nm7Mpr2bFzDsTZtDgyvgfnqAVAhEse/hD66HPwpevYI=;
        b=aNBFHVBtLXZhRhClu37ThcI6rlwW236BlU1y4k8aS98uN49dUtQq5lKchHNffZzxkC
         YwCdgEcwGMGFvjerqBhUUfS+yT1nTCD79rrSEBLgYUjwUE+MA3xCuW3gjZbmVDztPrMZ
         s4htWAWhLCoVvW+VsW+ZHUFSFPymWfpj2+YfSlTOPVhNyKq5dJbauaTB8efIZw4vRCwx
         3ipv/UosbmKDFkhncWXCas1tgW7migE6CymNt+gkLnqfu2dChgTJnkShNGw1bPPy52M/
         jp6xz4OHRxHc/pc7U2QavcXX664+0qGYPFcsf+uyomTe15fL8dPNspjrh9H0YokGbpex
         BLNw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ifcnmcwM;
       spf=pass (google.com: domain of bsingharora@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bsingharora@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c13sor15808136pfn.21.2019.02.16.22.23.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 16 Feb 2019 22:23:39 -0800 (PST)
Received-SPF: pass (google.com: domain of bsingharora@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ifcnmcwM;
       spf=pass (google.com: domain of bsingharora@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bsingharora@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=nm7Mpr2bFzDsTZtDgyvgfnqAVAhEse/hD66HPwpevYI=;
        b=ifcnmcwMlqknwcmblNlaOdEKIdi2A7JylegsmM4qPX6LKXhT0ZDMyL5XKSNZUgZ1ol
         mbTn8MatZvfW5RlESuur/dZZzaVRaepLswtWfvSL93RWTQhoKtUMHJWKOU/QNCNchpSq
         Lu/svA4tSsxsI85nS1x9uShfXffajFxM2Df+Mdl4vi3qRz8X6Aqpo0XR/+GbJkZzCj3o
         NrvzGzrRqu5fKqZmH5Bo49rKdOqKBSjfMxBPMNGzaNhsrFFesFV6le1PgjnnT6AA94Jy
         T015qKwtZu05dS2Hm8uFvn5dZTIBkwQrJe1YESNzYmnhfz/SujlmJTpbMmLCkpdxS5A1
         LbgQ==
X-Google-Smtp-Source: AHgI3IbaL+qoncpcwlKwPaLrZSlwDbREXbJesWUb4jxQUmO9VmgguFlB3LYaCIFe0NomUSbpOkUzig==
X-Received: by 2002:a62:b40b:: with SMTP id h11mr313568pfn.108.1550384618640;
        Sat, 16 Feb 2019 22:23:38 -0800 (PST)
Received: from localhost (220-245-128-230.tpgi.com.au. [220.245.128.230])
        by smtp.gmail.com with ESMTPSA id f13sm13736786pfa.132.2019.02.16.22.23.36
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 16 Feb 2019 22:23:37 -0800 (PST)
Date: Sun, 17 Feb 2019 17:23:33 +1100
From: Balbir Singh <bsingharora@gmail.com>
To: Segher Boessenkool <segher@kernel.crashing.org>
Cc: Michael Ellerman <mpe@ellerman.id.au>, erhard_f@mailbox.org,
	jack@suse.cz, linuxppc-dev@ozlabs.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, aneesh.kumar@linux.vnet.ibm.com
Subject: Re: [PATCH] powerpc/64s: Fix possible corruption on big endian due
 to pgd/pud_present()
Message-ID: <20190217062333.GC31125@350D>
References: <20190214062339.7139-1-mpe@ellerman.id.au>
 <20190216105511.GA31125@350D>
 <20190216142206.GE14180@gate.crashing.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190216142206.GE14180@gate.crashing.org>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Feb 16, 2019 at 08:22:12AM -0600, Segher Boessenkool wrote:
> Hi all,
> 
> On Sat, Feb 16, 2019 at 09:55:11PM +1100, Balbir Singh wrote:
> > On Thu, Feb 14, 2019 at 05:23:39PM +1100, Michael Ellerman wrote:
> > > In v4.20 we changed our pgd/pud_present() to check for _PAGE_PRESENT
> > > rather than just checking that the value is non-zero, e.g.:
> > > 
> > >   static inline int pgd_present(pgd_t pgd)
> > >   {
> > >  -       return !pgd_none(pgd);
> > >  +       return (pgd_raw(pgd) & cpu_to_be64(_PAGE_PRESENT));
> > >   }
> > > 
> > > Unfortunately this is broken on big endian, as the result of the
> > > bitwise && is truncated to int, which is always zero because
> 
> (Bitwise "&" of course).
> 
> > Not sure why that should happen, why is the result an int? What
> > causes the casting of pgd_t & be64 to be truncated to an int.
> 
> Yes, it's not obvious as written...  It's simply that the return type of
> pgd_present is int.  So it is truncated _after_ the bitwise and.
>

Thanks, I am surprised the compiler does not complain about the truncation
of bits. I wonder if we are missing -Wconversion

Balbir

