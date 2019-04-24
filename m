Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4CFD4C282CE
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 20:40:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E8EBC208E4
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 20:40:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E8EBC208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=iki.fi
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8A97F6B0005; Wed, 24 Apr 2019 16:40:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 857A56B0006; Wed, 24 Apr 2019 16:40:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6FB596B0007; Wed, 24 Apr 2019 16:40:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id 045106B0005
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 16:40:58 -0400 (EDT)
Received: by mail-lf1-f71.google.com with SMTP id h7so3246827lfm.20
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 13:40:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=k/hQxNrpeccwPxlrMKdsO/hMUl2vigAT2+BdSE01fIg=;
        b=DUjR5c/HYCNN2ur5m6G/OgkQnSwva87D0q5oIwNPj4dGrLiRHuZwNoWcNitf86eBbP
         zZndysTYhbRdkMyQixRFIIQ11bnY4JAEogAHp3eoEVx2cFE7eb7x/GBQf/wheyHA/TAU
         LrOG7kSURe4QxG8NhPoNFilGdRPmyjkfFdUwEtsIfO/OADZjL3TS/5amk2FlRGAB2o1n
         JWKTw4l89c/z9iPF9e2eJdaOt/IHibDNDlv0BvT44Yw1qtHQO6XuzGc9YJRJ29byOK/w
         vyIbYVnAHhwpOU0J27diEVlpAPU8hGj97+SLMqEAArMSrd2ZSi/tMWI1QkLb3lMepdja
         2PxA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 62.142.5.108 is neither permitted nor denied by domain of aaro.koskinen@iki.fi) smtp.mailfrom=aaro.koskinen@iki.fi;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=iki.fi
X-Gm-Message-State: APjAAAX+qhV1zMfsg1HO1nFpYozCYlkTrXjCDxZ4zZZY8Y7hWtytYc8q
	38aLNOkS1jbrfPwLZL2n0nV8UtFkNIR0L5j/5rG0C6nMlBksCj3r3p7xsTyh8nMllx4LWQixgy/
	/0xlcFWT71XnoBC4svdaLM85WYx0DdviThX5KLhCUPG6VaqHBZWOKmSUJMeygbYI=
X-Received: by 2002:a2e:8015:: with SMTP id j21mr7003814ljg.132.1556138457225;
        Wed, 24 Apr 2019 13:40:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw3PhrtdxWonf70aorYXqtnH9RHIYyC+NgV1lLN/pZMWqB31XXyAbuhftGH6XWk9k09tHGX
X-Received: by 2002:a2e:8015:: with SMTP id j21mr7003760ljg.132.1556138455981;
        Wed, 24 Apr 2019 13:40:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556138455; cv=none;
        d=google.com; s=arc-20160816;
        b=DWVt8QZ9ZcNIFOtjvaVwOHfDGGW2k5KZY1cp/fiECpCzkQxfqwhYZ6A5j6Q3xO+Zqv
         S2nLD6PY99cHEL5WQVUBEs1SkQsKc6IrZL2QBC1E5e5+I650p7SkCQZS4s3EGX6O5GZJ
         36mIaS0VGNtnQlm+rKG/w2vKRENsWAimwH2QWbEilifpxq2m9gEDuv2qpJuOY7KQMYSO
         HS5KHcwIXxsLgKtxLInpUa2YTeWIayefTU6Zya3RBgYMlworrioRKWKrJgBHyIhVLkhH
         ju5PsbmHujg79WfUUXq8Vt9T3ZZ9U/HzMAPqYbh7+ss7Tlf+SFlAgawLjSYKLdBL53ds
         Hq2A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=k/hQxNrpeccwPxlrMKdsO/hMUl2vigAT2+BdSE01fIg=;
        b=M9umqJyPuwmaIFM+S85assCcc897bLv4zjaw+28PSdH0Nb7sEbU8w6c2ID/pW2MWfH
         r3dicid2MfflNwFaYuoRMvc8xThopJh84aMVU2c0bAYxA6rYNIUTuO6+xO0QdBfR9a0w
         NkhCaeV8gVF5laZ8V9r4lXUW9EP3uCf4/V4vpCphpPfkwJEjXa6r/LSlPpnIoeNUcZQb
         K9fku+jGVn6v9oyv9xwad+WobpkW/B8f1nfEl8sc/xw6a7t/KlBHE4dz0Vcf9G58nmw3
         AFFIeoisYKGnRj1HfUgIkFLfXJfDVPO0l99sIgkS/mY//VQi9mrNneIgvfKt23f5tcPw
         s+tw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 62.142.5.108 is neither permitted nor denied by domain of aaro.koskinen@iki.fi) smtp.mailfrom=aaro.koskinen@iki.fi;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=iki.fi
Received: from emh02.mail.saunalahti.fi (emh02.mail.saunalahti.fi. [62.142.5.108])
        by mx.google.com with ESMTPS id j18si14825592ljc.29.2019.04.24.13.40.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 13:40:55 -0700 (PDT)
Received-SPF: neutral (google.com: 62.142.5.108 is neither permitted nor denied by domain of aaro.koskinen@iki.fi) client-ip=62.142.5.108;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 62.142.5.108 is neither permitted nor denied by domain of aaro.koskinen@iki.fi) smtp.mailfrom=aaro.koskinen@iki.fi;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=iki.fi
Received: from darkstar.musicnaut.iki.fi (85-76-5-198-nat.elisa-mobile.fi [85.76.5.198])
	by emh02.mail.saunalahti.fi (Postfix) with ESMTP id 51BDE2005E;
	Wed, 24 Apr 2019 23:40:55 +0300 (EEST)
Date: Wed, 24 Apr 2019 23:40:55 +0300
From: Aaro Koskinen <aaro.koskinen@iki.fi>
To: Paul Burton <paul.burton@mips.com>
Cc: "linux-mips@vger.kernel.org" <linux-mips@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Re: MIPS/CI20: BUG: Bad page state
Message-ID: <20190424204055.GB21072@darkstar.musicnaut.iki.fi>
References: <20190424182012.GA21072@darkstar.musicnaut.iki.fi>
 <20190424192922.ilnn3oxc7ryzhd3l@pburton-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190424192922.ilnn3oxc7ryzhd3l@pburton-laptop>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Apr 24, 2019 at 07:29:29PM +0000, Paul Burton wrote:
> On Wed, Apr 24, 2019 at 09:20:12PM +0300, Aaro Koskinen wrote:
> > I have been trying to get GCC bootstrap to pass on CI20 board, but it
> > seems to always crash. Today, I finally got around connecting the serial
> > console to see why, and it logged the below BUG.
> > 
> > I wonder if this is an actual bug, or is the hardware faulty?
> > 
> > FWIW, this is 32-bit board with 1 GB RAM. The rootfs is on MMC, as well
> > as 2 GB + 2 GB swap files.
> > 
> > Kernel config is at the end of the mail.
> 
> I'd bet on memory corruption, though not necessarily faulty hardware.
> 
> Unfortunately memory corruption on Ci20 boards isn't uncommon... Someone
> did make some tweaks to memory timings configured in the DDR controller
> which improved things for them a while ago:
> 
>   https://github.com/MIPS/CI20_u-boot/pull/18
> 
> Would you be up for testing with those tweaks? I'd be happy to help with
> updating U-Boot if needed.

Thanks, I wasn't aware of this, and seems like it could help.

I guess instructions here <https://elinux.org/CI20_Dev_Zone> are valid,
i.e. I can use MMC/SD card to re-flash the U-boot without the risk of
bricking the board, if I understood correctly?

BTW, would it be possible to re-adjust these timings from the kernel side?

> Do you know which board revision you have? (Is it square or a funny
> shape, green or purple, and does it have a revision number printed on
> the silkscreen?)

It's a purple one. Based on quick look all printings are identical to this
one:
https://images.anandtech.com/doci/8958/purple%20ci20_smaller_678x452.jpg

A.

