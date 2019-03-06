Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4D64DC10F00
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 12:11:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E6F0820684
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 12:11:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="PlEMSfIY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E6F0820684
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 606098E0005; Wed,  6 Mar 2019 07:11:47 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5B44E8E0004; Wed,  6 Mar 2019 07:11:47 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4C9CE8E0005; Wed,  6 Mar 2019 07:11:47 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0D2538E0004
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 07:11:47 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id w16so13249875pfn.3
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 04:11:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=HO2FVV3s3+gu7HhzXsc5YZvRD9XgD7vWiglwP/Nj1rc=;
        b=bR1FI1UJp84UP4wv+hcW7VhE1+uEMfo7TBn2EuxGnbMey3I2kFgl2avtU6cNqxnp21
         AktXsHK0cxNYoveyg54s2DaFv4QSDyLQwTY+0P2tIbl7ochRdeJ7PAzK42xJrmpUkUf2
         swLZED5mPOgojNrzTWllqawnk9wWSjT6cOsbuGTC1W7IOjYjMkcMlSVvY9zT4JH4tU9O
         GxO0R8G4bXQu2KPs4ZCww1khPPHVO9clDeb8b1+XkqwzSUXgcklofozF2evIjMdY4wq2
         HMTyyY8FB2csNcai1v/eRcJZCziewPn3dgk0/7a8oGdVJAWKqiCb4dIx/JlBFTsN5ef8
         8mAg==
X-Gm-Message-State: APjAAAVLcBq0ZKihNEwm778Ne3dQqHDdStuhEIHLBoJumXrYQ5DMQaUj
	dN4hunacJcvUmFYD4D1ljub6FyEoWJHI/MhUg48ishTMfiw+544Gj2sUZVOYSTDC+23BLoW9jLH
	qPlg9Y2Hk7ozl3nLis2eBiKhEsTlPjlXlaj220lQrAOq3WxIpdFPr5L5rB51ylw/76g==
X-Received: by 2002:a63:cc05:: with SMTP id x5mr5961069pgf.31.1551874306642;
        Wed, 06 Mar 2019 04:11:46 -0800 (PST)
X-Google-Smtp-Source: APXvYqxFIijSoszNRlqegGV/zomzlDBbImgr6sM6lo8NxTatS5cXB5oxKbL9zRLLyAWuRx6qy4b8
X-Received: by 2002:a63:cc05:: with SMTP id x5mr5961001pgf.31.1551874305711;
        Wed, 06 Mar 2019 04:11:45 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551874305; cv=none;
        d=google.com; s=arc-20160816;
        b=WqfwzPkZa+sLMd0UAJ1Y/HAtoeYAp0Wl2joESd8P/hLhFSwZ67ZyyXwlGmQhldrHpx
         IAE5b56LjdgjWn/GK0YNBhIvJAZAYz6DJV75j67d/Bft7CEDbmbT8GLqhLDPBZEc7FtU
         NqeZgV58fxmhbAyD82qNlyjpKqcTmFLQL/aV5BlzxQJbER6iyZsJOxgTkCWjnwlHgTyk
         hNPCJgQY785RTDLmisq20Xk/r8YWXdJfLh9LqT5bEJmRRb0w4XNBveA1IZSxnqlMf5Kw
         0u3uOxzVhSApyeP43UcqL6QfW8ZZob1Q0D6ytf96PuXKPD/0lRV9soZc4UO/AoML5QaL
         dwDw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=HO2FVV3s3+gu7HhzXsc5YZvRD9XgD7vWiglwP/Nj1rc=;
        b=FNViLKpPkeiep2SZ2fgbrNCrPdW+arhJJw90gdqVvIiZtPIn8DfdQ1PE88DSVhocZa
         xRBSegnPAE7Ydj6/m/24td9O43B4hlxU0r6+SEt+L81kVc7EiNN66V3LQ0xzn8oVSSP0
         0jCHpPHBkWPA7UBI7xIwmz3ZTE49F1VZ7W68Ik1G2airWkvoxcxsSem2SvyqkTcAqon6
         Dld5kDC/mX1+J8nv1XhtSeKsUN7XadeMu95qe8Iljdw2XAs6QS4cXQ4grn8gLwhYcYPA
         IwQmP9rNTI1pN8VMBrddAaiFBK4Jsjiji95qo/QYpVANMRTJu/duDl3qWvNgOYS9fGRR
         lPQw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=PlEMSfIY;
       spf=pass (google.com: domain of jikos@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=jikos@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id v3si1290524pgr.11.2019.03.06.04.11.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Mar 2019 04:11:45 -0800 (PST)
Received-SPF: pass (google.com: domain of jikos@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=PlEMSfIY;
       spf=pass (google.com: domain of jikos@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=jikos@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from pobox.suse.cz (prg-ext-pat.suse.com [213.151.95.130])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 0535A204EC;
	Wed,  6 Mar 2019 12:11:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1551874305;
	bh=tBnhCSlqLgwmBPyAmakrTsJfwyq/CWP9Ej0xMCJAKnk=;
	h=Date:From:To:cc:Subject:In-Reply-To:References:From;
	b=PlEMSfIYj3VIj20iNGIDIhCSALkxRH8E1gNsF4aE7mQfqYOIIKLAvfX4MXRpQP8Xj
	 gnmDKbdWO9OVXEwOWECFgOGxzl/nYuCOkRdUsGUs+XlQmJMRZhyRe0OQ9OfBOhZeMI
	 1qrdOpBdKnBYmpNV3LvEO/al1TcWEoJBSBHyc2XA=
Date: Wed, 6 Mar 2019 13:11:39 +0100 (CET)
From: Jiri Kosina <jikos@kernel.org>
To: Vlastimil Babka <vbabka@suse.cz>, 
    Andrew Morton <akpm@linux-foundation.org>
cc: Linus Torvalds <torvalds@linux-foundation.org>, 
    linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
    linux-api@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, 
    Greg KH <gregkh@linuxfoundation.org>, Jann Horn <jannh@google.com>, 
    Andy Lutomirski <luto@amacapital.net>, Cyril Hrubis <chrubis@suse.cz>, 
    Daniel Gruss <daniel@gruss.cc>, Dave Chinner <david@fromorbit.com>, 
    Dominique Martinet <asmadeus@codewreck.org>, 
    Kevin Easton <kevin@guarana.org>, 
    "Kirill A. Shutemov" <kirill@shutemov.name>, 
    Matthew Wilcox <willy@infradead.org>, Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 0/3] mincore() and IOCB_NOWAIT adjustments
In-Reply-To: <20190130124420.1834-1-vbabka@suse.cz>
Message-ID: <nycvar.YFH.7.76.1903061310170.19912@cbobk.fhfr.pm>
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm> <20190130124420.1834-1-vbabka@suse.cz>
User-Agent: Alpine 2.21 (LSU 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 30 Jan 2019, Vlastimil Babka wrote:

> I've collected the patches from the discussion for formal posting. The first
> two should be settled already, third one is the possible improvement I've
> mentioned earlier, where only in restricted case we resort to existence of page
> table mapping (the original and later reverted approach from Linus) instead of
> faking the result completely. Review and testing welcome.
> 
> The consensus seems to be going through -mm tree for 5.1, unless Linus wants
> them alredy for 5.0.
> 
> Jiri Kosina (2):
>   mm/mincore: make mincore() more conservative
>   mm/filemap: initiate readahead even if IOCB_NOWAIT is set for the I/O
> 
> Vlastimil Babka (1):
>   mm/mincore: provide mapped status when cached status is not allowed

Andrew,

could you please take at least the correct and straightforward fix for 
mincore() before we figure out how to deal with the slightly less 
practical RWF_NOWAIT? Thanks.

-- 
Jiri Kosina
SUSE Labs

