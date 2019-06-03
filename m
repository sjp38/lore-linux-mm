Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0D6B5C04AB6
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 07:44:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CD96C27CF1
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 07:44:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CD96C27CF1
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6AB756B000E; Mon,  3 Jun 2019 03:44:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6357E6B0266; Mon,  3 Jun 2019 03:44:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4FDED6B0269; Mon,  3 Jun 2019 03:44:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id F37876B000E
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 03:44:47 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id v125so534714wmf.4
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 00:44:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Zq0TlFVqpGlHA1w4BG24ieDdl6ltC675/Z0nEmifqpU=;
        b=LcP4ZOLccSLJiuyO/p9T0h5SmY8t+92464RMGtkhdah6UEBhCLr8zMEGulPjDHKMKV
         sdVSjy+wyYrXEvHs+e0pXm3E96BwIsGVPY0jtgXUaX6v2irjUxBekDAmKEeajPuc/tMK
         WXqePStIdX08FB9gCC3F8pcPsDehdB055UJfBHj4pusfUnMV+ze1BPM9cigNL77VFriP
         U0kV+Ms2tB4hBdXn0nh2xxTidw3dsakTgJ66WHM5MWHMMhtkb/kkAyGdpoSsCxf0pM/m
         U0AkiaMAHXt5eIqqk37IQ2X1YckuwFyS1CrOq3NZ0ZL45C7eNgrZeyCFF/9jJyii+zDM
         p5hw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAWZ/UPfCo9WstqWjAIw7NSWI0f7Z2j/x0I12LwkHwgM0an4kijk
	uN/9OgqIXN9dR6K7/h9i+3rydeBHIlGZJDD3atYoHtHYiOmzPmQkOMma9NII0bCrega+Jvvp8DT
	PUiNdB8is1EkhT5U6N1KQbyDnAlRJNCTn6/ebZ0R4gOV59TXtOewhrihnl1YWOEwZFg==
X-Received: by 2002:a1c:9dc5:: with SMTP id g188mr1361930wme.93.1559547887519;
        Mon, 03 Jun 2019 00:44:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw2woIvH5dbMfU3CkJpbkrYXdu3d66/nf++l8DcSLwo5/tqWx+eGmcCTTBx+lLNiMkrIxEz
X-Received: by 2002:a1c:9dc5:: with SMTP id g188mr1361878wme.93.1559547886581;
        Mon, 03 Jun 2019 00:44:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559547886; cv=none;
        d=google.com; s=arc-20160816;
        b=EdfPGL6rZNRBxJw5Ln6UJRgEUhPpQsEl54PjzfEBjIuxWui/fzqVDyFzQ/7GrEZTKZ
         eiwTPjGAd5vCW5Rz7ibelPTS/MFHoq563VZWYBAqfEd98O8JJUouRoBe3FmV5//YAe8I
         4sypHVO6J/dNKAsg4s8uUrQoH1MFZBasbb0w8otDHj8gtShdkOpR8qX4ewYqvNFzT5FJ
         DmQjhmKGij4Li6V+KmkaaESjKDjV3pJK8i9yNVBD8ZaVbCrnu3ivGoOzdOSmNfZKzQn0
         RvNo+WryLiYWswd8+WxvOqFGoW6TikGApR0BGpLFM2x9p0b8vPGLjGydbYPaDFnfp+7Z
         1d0A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Zq0TlFVqpGlHA1w4BG24ieDdl6ltC675/Z0nEmifqpU=;
        b=BSXXvTjQLldTt8J1LIPvMq8zu8JQMR/0LAFZXOm12yGelIdsBP5Xw7ZxwRDIxLznl3
         fTzpl/dL+QLC6XW5N4f878C5Flf1Va+J4nfI4cD+0IjTyiYZg9IMdqSJaBj8ZeWEPHND
         caIgt3JdbOTmkEmHtapyK9fkJJB8Kcmjay0gvfo2Q0dS8LN3+qm/yOKbb6ofPI99pfiN
         rle48qYXQNfoB012BWGfrPhtSQPBct5X/67xB47mTshbelJ0/87rHsRUt79kA45ZcVmj
         bZ4KytbDCjmF8M/rZtSga6n3hrmH4Q3oaF1+NF/3cPQzSLQ5JUPYryoxQqYDdaekfA25
         VVbQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id q9si8740930wmc.49.2019.06.03.00.44.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Jun 2019 00:44:46 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 74D3067358; Mon,  3 Jun 2019 09:44:21 +0200 (CEST)
Date: Mon, 3 Jun 2019 09:44:21 +0200
From: Christoph Hellwig <hch@lst.de>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Hellwig <hch@lst.de>, Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>,
	"David S. Miller" <davem@davemloft.net>,
	Nicholas Piggin <npiggin@gmail.com>,
	Khalid Aziz <khalid.aziz@oracle.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>, linux-mips@vger.kernel.org,
	Linux-sh list <linux-sh@vger.kernel.org>,
	sparclinux@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	Linux-MM <linux-mm@kvack.org>,
	the arch/x86 maintainers <x86@kernel.org>,
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 08/16] sparc64: add the missing pgd_page definition
Message-ID: <20190603074421.GB22920@lst.de>
References: <20190601074959.14036-1-hch@lst.de> <20190601074959.14036-9-hch@lst.de> <CAHk-=wj9w5NxTcJsqpvYUiL3OBOH-J3=4-vXcc3GaG_U8H-gJw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHk-=wj9w5NxTcJsqpvYUiL3OBOH-J3=4-vXcc3GaG_U8H-gJw@mail.gmail.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jun 01, 2019 at 09:28:54AM -0700, Linus Torvalds wrote:
> Both sparc64 and sh had this pattern, but now that I look at it more
> closely, I think your version is wrong, or at least nonoptimal.

I bet it is.  Then again these symbols are just required for the code
to compile, as neither sparc64 nor sh actually use the particular
variant of huge pages we need it for.  Then again even actually dead
code should better be not too buggy if it isn't just a stub.

> So I thgink this would be better done with
> 
>      #define pgd_page(pgd)    pfn_to_page(pgd_pfn(pgd))
> 
> where that "pgd_pfn()" would need to be a new (but likely very
> trivial) function. That's what we do for pte_pfn().
> 
> IOW, it would likely end up something like
> 
>   #define pgd_to_pfn(pgd) (pgd_val(x) >> PFN_PGD_SHIFT)

True.  I guess it would be best if we could get most if not all
architectures to use common versions of these macros so that we have
the issue settled once.

