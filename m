Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7D752C2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 01:57:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 467C7208E4
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 01:57:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="JKvNpstA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 467C7208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C9F1D6B0307; Thu,  6 Jun 2019 21:57:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C50056B0308; Thu,  6 Jun 2019 21:57:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B172C6B0309; Thu,  6 Jun 2019 21:57:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 79C176B0307
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 21:57:42 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id s12so405456plr.5
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 18:57:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=fMmuJCA3LCdg91iSc6/9qeFXRSKlknMhuRfQX7ASOjc=;
        b=CUuTqQQjwaru4qGSPdDrd0kEBG5gIFxtlwm+FWoM+PQrsckoSlTHBJcpbGWGtwE/4J
         SsgCFz5w2oORBDcF5SaNs69/GHPVsMXKEvIUR5vL4mqLTQckLKWaiFzI8vdNpNQoWPtA
         LtsttsXmfpu3G/lnfDjz8NrWdbpGGuR7wbtf4uRmN9faaeYDLqonloMqMzCorI35nF1P
         tpw+qv/HfaUWKeSy/LF7rSuGHGiBFDZh0xY37Dah8G77/QdqUDIxiS8wFnDlPYiR1XMY
         g42bmUHXOw/orH+xLs7+r1TNhzGJlSAupGsooyD5b4/E+vE5vwHa6bP0tGWKNP/Q9q7T
         vQQQ==
X-Gm-Message-State: APjAAAUB3FrPxYn8q7xNCf7E4Dd/I6A2PPo28DQbCOoVCD6Z85MRoKST
	blB5PDqP2GBlSnjKdUjjMKrbt0HAxMJbHqXomim1T3Ean+tFtUmxuuzDuUb0Wl78CxtXnzlaMLZ
	qDGbhq6i4JxSyBUxB55ZunN2E0tigQDHXNWyrX+bytIa6g3qZBdfWMEEgz0HPLV2vSw==
X-Received: by 2002:a17:90a:af8e:: with SMTP id w14mr2962874pjq.89.1559872662001;
        Thu, 06 Jun 2019 18:57:42 -0700 (PDT)
X-Received: by 2002:a17:90a:af8e:: with SMTP id w14mr2962840pjq.89.1559872661307;
        Thu, 06 Jun 2019 18:57:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559872661; cv=none;
        d=google.com; s=arc-20160816;
        b=Y3QbPT7fmZ+AexDthELBy1KtwZq9f5EPWH6G7RjbexD4GWfNVfgjzSbFSer4znw0HM
         oM/dzuJ2KrD6RDpkn3idCKlN7ppToJDtlPd2qTJ+rUTG6WpjYmAUfOISss7GHJ+orZXl
         wcXbA8ApInWnivmArIER5HdKbnb66khlEkQCzMxx4rRoiApdHpvwyGSXKMF02nWUO1KD
         X7Qwn6/rS6jeDc80ja3xSrFt9VbCdpCKv6jBtSpSbHfrSJSeq7W0uL0M+1+EqsAgnMJC
         mVSQzOq3W5KZd94TurL7SHe3s/63zUmFhUwGOoU4evWxAR6hOZ5dKl8gNs4Svu+VXlZ4
         DFvQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=fMmuJCA3LCdg91iSc6/9qeFXRSKlknMhuRfQX7ASOjc=;
        b=veUkP1kgCKAZs9A5fydhpqmKq78h7OvFCOvPQyzP+5rcfvb/F8LqQ3fxuzorjgGSEu
         IgzKQxliMMDO7jd75PwAGj6uKpiJ+d7Z2UO2gsr8O5cW1BHOroR4/LqtIiiT1sd+kzS/
         z8B6tR6WBLLkruMLjpCoztJb59yUDfkQ8Dbgf8/pwxj2tB2QRdokWyaaH/s2R2tln51w
         6/ZLh5mcvJBfbalJ0ucNT4KoGPLteXJE5Q+zYnxWSvK4si1riPoiXJZNy6c5GMYuxyvl
         +o3+PHrx6QywTwW+NU180XuWg2z0mDDLxCZ36h6TUes9zaJf3dBHmHAVzIqM3Mj98UEJ
         AYuA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=JKvNpstA;
       spf=pass (google.com: domain of yury.norov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=yury.norov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s65sor665850pfb.30.2019.06.06.18.57.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Jun 2019 18:57:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of yury.norov@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=JKvNpstA;
       spf=pass (google.com: domain of yury.norov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=yury.norov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=fMmuJCA3LCdg91iSc6/9qeFXRSKlknMhuRfQX7ASOjc=;
        b=JKvNpstAHFdgappvoFZTSBTYlIL3/rZ47hg8HWoFbIEqVkiV0EhBBZRLRpyoICFyrS
         ClCg438cs5YejBJpHXQckK0pyK/nX11Mbv0+5nKGWykE5lZ3jpOuxeVRFnlLKbW87lcG
         bewtkILSMTIQJO7EetY0lF6sRJUs+8uhC1RbETeTx8z2OBcWkDlJX8xMnfs/FngxD9je
         npdlOr57+ayjx56h+5W94hdtUiDJMVs9Pyj5fGRTYXGLjXwkFhCFeOws4+ZwA/7nmOcz
         UYma0uNuuj6tU25IwM5aMXHiCF1uwqjvpSLHw6IOmKy/ZVxAahFu17CHyfSoUMsaCxjk
         DrJQ==
X-Google-Smtp-Source: APXvYqzOGmPQ+4bSZiqeJZcCwiv/ZjmMksHt7GIGid5GMzyY0FfrS/4RyF2iuz/q9m86aoMdGrLu4w==
X-Received: by 2002:aa7:9256:: with SMTP id 22mr43149580pfp.69.1559872660804;
        Thu, 06 Jun 2019 18:57:40 -0700 (PDT)
Received: from localhost ([2601:648:8300:77e8:e0fc:fdfa:3d2e:ab5a])
        by smtp.gmail.com with ESMTPSA id 85sm408342pgb.52.2019.06.06.18.57.38
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 06 Jun 2019 18:57:39 -0700 (PDT)
Date: Thu, 6 Jun 2019 18:57:37 -0700
From: Yury Norov <yury.norov@gmail.com>
To: Qian Cai <cai@lca.pw>, g@yury-thinkpad.kvack.org
Cc: Yuri Norov <ynorov@marvell.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Re: "lib: rework bitmap_parse()" triggers invalid access errors
Message-ID: <20190607015737.GA11592@yury-thinkpad>
References: <1559242868.6132.35.camel@lca.pw>
 <1559672593.6132.44.camel@lca.pw>
 <BN6PR1801MB20655CFFEA0CEA242C088C25CB160@BN6PR1801MB2065.namprd18.prod.outlook.com>
 <1559837386.6132.47.camel@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1559837386.6132.47.camel@lca.pw>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 06, 2019 at 12:09:46PM -0400, Qian Cai wrote:
> On Wed, 2019-06-05 at 08:01 +0000, Yuri Norov wrote:
> > (Sorry for top-posting)
> > 
> > I can reproduce this on next-20190604. Is it new trace, or like one you've
> > posted before?
> 
> Same thing, "nbits" causes an invalid access.
> 
> # ./scripts/faddr2line vmlinux bitmap_parse+0x20c/0x2d8
> bitmap_parse+0x20c/0x2d8:
> __bitmap_clear at lib/bitmap.c:280
> (inlined by) bitmap_clear at include/linux/bitmap.h:390
> (inlined by) bitmap_parse at lib/bitmap.c:662
> 
> This line,
> 
> while (len - bits_to_clear >= 0) {

[...]

The problem is in my code, and the fix is:

diff --git a/lib/bitmap.c b/lib/bitmap.c
index ebcf4700ebed..6b3e921f4e91 100644
--- a/lib/bitmap.c
+++ b/lib/bitmap.c
@@ -664,7 +664,7 @@ int bitmap_parse(const char *start, unsigned int buflen,
 
 	unset_bit = (BITS_TO_U32(nmaskbits) - chunks) * 32;
 	if (unset_bit < nmaskbits) {
-		bitmap_clear(maskp, unset_bit, nmaskbits);
+		bitmap_clear(maskp, unset_bit, nmaskbits - unset_bit);
 		return 0;
 	}
 
I'll add a test for this case and submit v3 soon.

Yury

