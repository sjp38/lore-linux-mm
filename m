Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 55645C433FF
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 08:18:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1459220818
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 08:18:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1459220818
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1B6366B0006; Mon,  5 Aug 2019 04:18:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1685C6B0007; Mon,  5 Aug 2019 04:18:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0088C6B0008; Mon,  5 Aug 2019 04:18:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id A4FE16B0006
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 04:18:15 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b3so51001043edd.22
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 01:18:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=CE+bWG9hnKQ4m3IuvGt2I5rkjF8/xbNfFbZvfzm3hkE=;
        b=BnIGch0KV5NK5vpC+fp7fDT5BPwpVbopRUqbR/l25uKQabE/Tw1TRZPCPReDYIalyb
         Oos1lmxsG/VsCm7tdo93I6E5zJfaT2t01WIVOClHDvLXaaFKWTyTXyDXeL6ucek6RIhN
         EW5gXAacgTJ7d+EoY6Q/2AL7dIZfWh4I3lKurZVypspb1iW7l1PxLgGjVJx1lazXpUsi
         bWt5bIrAIzH0MZcrYlAAl2tnmXY+4gN2Z8cZ8BXaFPpCsLDOujDH94BlnabxdefmEQTK
         mslkEsFLeibnPndOpg/pyUvZjcBsvv7fvstW/ICvqIUm57ppQK2FK6rRWtHUABlzrnV0
         7QAQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVAc8Cef1N2j4EFqp9O2gt/8E2dPD5IWl4t+g/IhQ7tx1kcCyU1
	lvxCYw/SMbhneU4VhFLG+CEG0FENpo9hb4dkFgncnFDPcZbzXdbw5ADQEtOcLxIU1qUtCNE6hB1
	PgnGrXiLbEVO831QB5KNfEhRqfAb+nwxkjZ8vDa1H9w3odYrtkdrE2eXr4uE6Xao=
X-Received: by 2002:a17:907:2177:: with SMTP id rl23mr117868443ejb.14.1564993095217;
        Mon, 05 Aug 2019 01:18:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxgG0DQjc4hJNki6MFtSnZMLHkA7rAb6VjvChszDF7tbO2kd7pLsO++J+vYPzTttdPSO+Np
X-Received: by 2002:a17:907:2177:: with SMTP id rl23mr117868381ejb.14.1564993094162;
        Mon, 05 Aug 2019 01:18:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564993094; cv=none;
        d=google.com; s=arc-20160816;
        b=0PmtF1xR2QGxiWg0p+lxgPmvduzmqsiVxp1LZHLtxYFTdx/e6DAVHYbdGG/axZrB6u
         BFplIlBEfg1CW1AUgMJMnUOaF619GMMrQ4DEFsxQ6vv4ovV9+BbrQoM9TKsHmwnuLN57
         fXLe6IRxJv2PQT3lEZZpUwxj9NmOuKA3jNjhyYh1vvGPAgLevDTNFLSC7a5878nJ2jw6
         qT3dTI+aCgxrd+CxnxNr/sQ6q8x/lSN+eMrDhggLg0nfPvryVRZY+oPp9nMmc4pGmnvh
         YLIjOzINcRAbMWjpVFv6DYZZitB1tpoMvVxsupsKPCRLfXMRpPma/1BtSxK8a+RKywEt
         7PPA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=CE+bWG9hnKQ4m3IuvGt2I5rkjF8/xbNfFbZvfzm3hkE=;
        b=exVlqFO6vzdLCAHDrjYNY5nkIPjqyA+52AXl+vyAddNwJAcyqAqJ2hB7cExhADk3r6
         GhljIdgc26JmghdXEK9Ln3IlvxMXwewLEiTWuPQNXHKK9GM8dna3ALNpkqyNUb2a/C1a
         jEpQRqtqAI9ThXf1Xm94+eYvQrKt9wDA1aBJEwONBNM+t8SZq7UTfjJjtgMJqY/MdNku
         bkDh1GixN/oND7NiBv84bCog5IYtv4L0Aovns6xQVE0lqrDGoWb+JXXDKG5L7U5w/rym
         NVaVOdOxQ6W6g6uen1o7/JJiJJFxi11mi4ZAY6xi1KqySTxRYkxtnIpe/N8xZJj/1juU
         gBTw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hh15si26735492ejb.151.2019.08.05.01.18.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Aug 2019 01:18:14 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 7B600ADDC;
	Mon,  5 Aug 2019 08:18:12 +0000 (UTC)
Date: Mon, 5 Aug 2019 10:18:10 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Masoud Sharbiani <msharbiani@apple.com>
Cc: Greg KH <gregkh@linuxfoundation.org>, hannes@cmpxchg.org,
	vdavydov.dev@gmail.com, linux-mm@kvack.org, cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: Possible mem cgroup bug in kernels between 4.18.0 and 5.3-rc1.
Message-ID: <20190805081810.GA7597@dhcp22.suse.cz>
References: <5659221C-3E9B-44AD-9BBF-F74DE09535CD@apple.com>
 <20190802074047.GQ11627@dhcp22.suse.cz>
 <7E44073F-9390-414A-B636-B1AE916CC21E@apple.com>
 <20190802144110.GL6461@dhcp22.suse.cz>
 <5DE6F4AE-F3F9-4C52-9DFC-E066D9DD5EDC@apple.com>
 <20190802191430.GO6461@dhcp22.suse.cz>
 <A06C5313-B021-4ADA-9897-CE260A9011CC@apple.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <A06C5313-B021-4ADA-9897-CE260A9011CC@apple.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 02-08-19 16:28:25, Masoud Sharbiani wrote:
> 
> 
> > On Aug 2, 2019, at 12:14 PM, Michal Hocko <mhocko@kernel.org> wrote:
> > 
> > On Fri 02-08-19 11:00:55, Masoud Sharbiani wrote:
> >> 
> >> 
> >>> On Aug 2, 2019, at 7:41 AM, Michal Hocko <mhocko@kernel.org> wrote:
> >>> 
> >>> On Fri 02-08-19 07:18:17, Masoud Sharbiani wrote:
> >>>> 
> >>>> 
> >>>>> On Aug 2, 2019, at 12:40 AM, Michal Hocko <mhocko@kernel.org> wrote:
> >>>>> 
> >>>>> On Thu 01-08-19 11:04:14, Masoud Sharbiani wrote:
> >>>>>> Hey folks,
> >>>>>> I’ve come across an issue that affects most of 4.19, 4.20 and 5.2 linux-stable kernels that has only been fixed in 5.3-rc1.
> >>>>>> It was introduced by
> >>>>>> 
> >>>>>> 29ef680 memcg, oom: move out_of_memory back to the charge path 
> >>>>> 
> >>>>> This commit shouldn't really change the OOM behavior for your particular
> >>>>> test case. It would have changed MAP_POPULATE behavior but your usage is
> >>>>> triggering the standard page fault path. The only difference with
> >>>>> 29ef680 is that the OOM killer is invoked during the charge path rather
> >>>>> than on the way out of the page fault.
> >>>>> 
> >>>>> Anyway, I tried to run your test case in a loop and leaker always ends
> >>>>> up being killed as expected with 5.2. See the below oom report. There
> >>>>> must be something else going on. How much swap do you have on your
> >>>>> system?
> >>>> 
> >>>> I do not have swap defined. 
> >>> 
> >>> OK, I have retested with swap disabled and again everything seems to be
> >>> working as expected. The oom happens earlier because I do not have to
> >>> wait for the swap to get full.
> >>> 
> >> 
> >> In my tests (with the script provided), it only loops 11 iterations before hanging, and uttering the soft lockup message.
> >> 
> >> 
> >>> Which fs do you use to write the file that you mmap?
> >> 
> >> /dev/sda3 on / type xfs (rw,relatime,seclabel,attr2,inode64,logbufs=8,logbsize=32k,noquota)
> >> 
> >> Part of the soft lockup path actually specifies that it is going through __xfs_filemap_fault():
> > 
> > Right, I have just missed that.
> > 
> > [...]
> > 
> >> If I switch the backing file to a ext4 filesystem (separate hard drive), it OOMs.
> >> 
> >> 
> >> If I switch the file used to /dev/zero, it OOMs: 
> >> …
> >> Todal sum was 0. Loop count is 11
> >> Buffer is @ 0x7f2b66c00000
> >> ./test-script-devzero.sh: line 16:  3561 Killed                  ./leaker -p 10240 -c 100000
> >> 
> >> 
> >>> Or could you try to
> >>> simplify your test even further? E.g. does everything work as expected
> >>> when doing anonymous mmap rather than file backed one?
> >> 
> >> It also OOMs with MAP_ANON. 
> >> 
> >> Hope that helps.
> > 
> > It helps to focus more on the xfs reclaim path. Just to be sure, is
> > there any difference if you use cgroup v2? I do not expect to be but
> > just to be sure there are no v1 artifacts.
> 
> I was unable to use cgroups2. I’ve created the new control group, but the attempt to move a running process into it fails with ‘Device or resource busy’.

Have you enabled the memory controller for the hierarchy? Please read
Documentation/admin-guide/cgroup-v2.rst for more information.
-- 
Michal Hocko
SUSE Labs

