Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8CE94C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 08:32:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1A57020880
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 08:32:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1A57020880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D14468E0003; Wed, 20 Feb 2019 03:32:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CC28B8E0002; Wed, 20 Feb 2019 03:32:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BB2968E0003; Wed, 20 Feb 2019 03:32:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 77EAC8E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 03:32:00 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id i55so9711225ede.14
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 00:32:00 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=/QDSocDlJvv0aNiFBcPaUojGwk5TcNdD10Dh2agxmc4=;
        b=j+xEnJ4fEKMd0LJKvqS0G1CHAHC8l72zxr3uE4+Px0gT5Sea2oduQb6NtcpXTW6Fzu
         PS5p1Ri51OMtECuDoa/TvLWEMDKzUbBN+fFJCmiW5fzBbGLzWRE03WmbayMCvrX7lgGJ
         hDj/9aFni99tT9BMCIYDt5Z/7T/GfFTn2DEqxeZvwnZ7bkZ4qHz3AZOFKMupOiq9nSqb
         XULweKQHmM6kyDQMSBiV584F+Zm8StG1eq2jlnQJvTsC2uqb2uue+Ps/7PbL/j3VL+n4
         pNd+Tgr2UvumsFSJ0J1+HRfB2D0V6Vxogi7XoeXBICMwKP1ancqT4F7Xeyc+uQZv1AVv
         mFhw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuYDJV8euvGE+ju9UuCgVNKERR/4HuLM8nkpwKkhNYPhl/gr2+K/
	ZxI/H4HTDcGjQcDzeb+nT525QdxYlO8X/oT7M21v1MZ003TMcO2PRlhvOeoid6R6ysBEUPLA/Rp
	yd3SImUxSgpVx79HJaJNCXLyxUyHOn3vuFAoPeIrBum+Kp7h596Camf/BJ86Al3U=
X-Received: by 2002:a17:906:4d05:: with SMTP id r5mr12664469eju.24.1550651520045;
        Wed, 20 Feb 2019 00:32:00 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbyGyzMSJP1jBsBDughpjengkkRfFHE//CTyfKhtfpUMctoBIms0BOnYrwqXxPYYjuZYHpc
X-Received: by 2002:a17:906:4d05:: with SMTP id r5mr12664425eju.24.1550651518971;
        Wed, 20 Feb 2019 00:31:58 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550651518; cv=none;
        d=google.com; s=arc-20160816;
        b=RGQVBWJUgy1Zh/g6CCUeIGs18RzWSex1MQwujVAgdFJdxIlormL8S1jf1nkdHpd+wa
         yeQCGFnIxc32Pna+WCeYtmIY+n0rQBFKMSN91vgrr2WUwcTX1UBlv5NWLqQzV3m8C7vH
         x+fMpXV5+8hFH/3nzn4gbVRgnrkhrG6tQBSdq2uDvKvrJLfY4WPNrK9qi3ZvvjAxZIsa
         vmrE5p6AoblWPCy8QhwQlbMqqrlNvBr/g+JIk5rfC5TMZzYC+vLZxi1MQOh+MNlrI2Ip
         xQg4mOTt2P1KDMQW4RVkIb4+O4ijppxLhVVYCM35YScjre12alpASr3E4OJGPcRYXfNu
         EVhA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=/QDSocDlJvv0aNiFBcPaUojGwk5TcNdD10Dh2agxmc4=;
        b=kCpcUFry5OGDTGvugZOnrzLN/paDA096Sv/nVfPkVBzpmmY/1VTnTyIrnBDSatquhu
         hOfBgclRrKSRSlWT80LRL/S6BlZxMLN7yIwiOkxCaI1w49c/ClFxFfVtBbX6AGv1G3ez
         QVk85blKTf+uq/go1aFifCC8EsCMLGjLBmI7QiLuRk5CtJQgCJhMQ0Zgxu0NwmWnQRni
         qneDTa6wrU6eIZtHOt8Fl7Cr9pJhzh5X7WyrRuL/lJr6ou3Tn5DqdYyxOUTRWtdJ5rsP
         r830RVnJu0PDCryW2I1HXXYxTlQ+w76N7VCTNGETPHWTjsa1wUICZy3/HPNzp65cAVny
         vSlg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f54si2974079eda.138.2019.02.20.00.31.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Feb 2019 00:31:58 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 41739AEE3;
	Wed, 20 Feb 2019 08:31:58 +0000 (UTC)
Date: Wed, 20 Feb 2019 09:31:57 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Christopher Lameter <cl@linux.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org
Subject: Re: Memory management facing a 400Gpbs network link
Message-ID: <20190220083157.GV4525@dhcp22.suse.cz>
References: <01000168e2f54113-485312aa-7e08-4963-af92-803f8c7d21e6-000000@email.amazonses.com>
 <20190219122609.GN4525@dhcp22.suse.cz>
 <01000169062262ea-777bfd38-e0f9-4e9c-806f-1c64e507ea2c-000000@email.amazonses.com>
 <20190219173622.GQ4525@dhcp22.suse.cz>
 <0100016906fdc80b-4471de43-3f22-45ec-8f77-f2ff1b76d9fe-000000@email.amazonses.com>
 <20190219191325.GS4525@dhcp22.suse.cz>
 <0100016907829c4c-7593c8e2-1e01-4be4-8eec-a8aa3de00c18-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0100016907829c4c-7593c8e2-1e01-4be4-8eec-a8aa3de00c18-000000@email.amazonses.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 19-02-19 20:46:34, Cristopher Lameter wrote:
> On Tue, 19 Feb 2019, Michal Hocko wrote:
> 
> > On Tue 19-02-19 18:21:29, Cristopher Lameter wrote:
> > [...]
> > > I can make this more concrete by listing some of the approaches that I am
> > > seeing?
> >
> > Yes, please. We should have a more specific topic otherwise I am not
> > sure a very vague discussion would be any useful.
> 
> I dont like the existing approaches but I can present them?

Please give us at least some rough outline so that we can evaluate a
general interest and see how/whether to schedule such a topic.
-- 
Michal Hocko
SUSE Labs

