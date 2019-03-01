Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B40A0C4360F
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 03:31:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 54E1620854
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 03:31:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 54E1620854
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BAEBD8E0003; Thu, 28 Feb 2019 22:31:37 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B37698E0001; Thu, 28 Feb 2019 22:31:37 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9FED18E0003; Thu, 28 Feb 2019 22:31:37 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 73B0C8E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 22:31:37 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id 207so17864655qkl.2
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 19:31:37 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=lFPHpRJUfoltX9ebWI0P8PXHnEsNhG49yHed1SYdFSA=;
        b=X/LNLaOh+ztDYJ5LX0WJhp6EptVj1oiMd7VjCQU9+6+xQrOvTNSCPMjestxSZvKin4
         ZIyGzSgz3WwSyKlRKGqm18eLjiSqKnUJpjxkNsriPr/d2ktaCpF9k4Nf5icuU7Q4ZToc
         9hL8wvMaYa1VQvA0Hf5KwWqoK5zPWxDffwrULxxPdEFiUgBWdX4AXH0laCPNxmeIac3q
         /hhzqbDXQHynaGBn/wx0WEz8p0unw+cpzxw5Mrvq60TTa4WmlifFSUPGi0GYxoTL51h1
         0lp9Yi/XARhlTNyCKCjothYqBiBN8PWGw59mdZC/OG9SVqI9H2c/byWvMeD+Z7O5eHPM
         Iapg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jpoimboe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jpoimboe@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVF8MxKryD6al7/v1KVKJfEn3okaemj7XhMemPTRdX3Iv0mdFE0
	KUAnX61r08mjhyA0tAGSqFBEyYv41LPvZi/7/Mf7La22tEOgN71aC+kBbghzoykzek8y3hIWa5N
	J6B++LoSBZWm+2h1yinifpJIZiz2NsUT4BbDpwbp4Pbreq2wrp0l/j6+fjSyRsOQYhA==
X-Received: by 2002:a0c:9848:: with SMTP id e8mr2150823qvd.80.1551411097155;
        Thu, 28 Feb 2019 19:31:37 -0800 (PST)
X-Google-Smtp-Source: APXvYqxbYAWl0ApFgWMBaXeQ/dgPAjnV6Z6/w/9s1VIqNGtNp+H0Cz0Bt3e7m0HdSCk6Laabwam8
X-Received: by 2002:a0c:9848:: with SMTP id e8mr2150784qvd.80.1551411096100;
        Thu, 28 Feb 2019 19:31:36 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551411096; cv=none;
        d=google.com; s=arc-20160816;
        b=kid0KuIkOpfgWhqmgZFM8Ku3QP2CV1Qd8NKSnxYOkYK+uDWWfjUsnsHuO8r0zM34KC
         2l6QOEOxK7dxEpvS0qpecFKwxlWoGyswblXtiCxKfTmvwvRMI+QbjVDb5TCnRZcLGAJU
         FX8WnH3EMo1bYGPkRRCKyGEDD6TOfeO8i2lMxgoeqtrMP3X6AtWSEDwFVdQVEFiNBkbR
         9Ir8FR/fKiGAbZ0S3FWdo23jpGhbySc9M6YKc6lfPsuApBfeFPlDq7kK6PTlCZ8/QtF0
         yBbvjmXrhRvSL2mxaMRz9PRRlcaXjqMApKMwLRuuAGiEusdrSrMFqrHN9cNGrET1lctl
         cZ2Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=lFPHpRJUfoltX9ebWI0P8PXHnEsNhG49yHed1SYdFSA=;
        b=SjeWi9IQQy7dQAPUk6vVTDVLUy55yesFyp+eLE9cIPKIv9feNCX5zhpkCzsBwguAMT
         Mpm0+FVAo+ikjzNOpY1t4uHsgzFNVlcVnpqK5p8tjfg4U1I518S+OgWfDlv2zUo87GVo
         ms7+YNkDm1TDvU/HQ6cj7WXc7vycfJpwtYhmXa3aBKynRryEU29KkWeSe8Nhh2pS/ICM
         Dn9hQ5Wd3xeR7BT9Si+pbnAcjLdozSHwHaPYcBLnWyBZZpBhbjzBK/kUs09FnhcG6d7q
         dYlAc7QB2vSRV2qA2valGRSdrejFPmGcc8cP6hJKsd3X5nxdSdYR4vtjxNFE1EGydRKP
         +JhQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jpoimboe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jpoimboe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i7si2985007qvi.199.2019.02.28.19.31.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Feb 2019 19:31:36 -0800 (PST)
Received-SPF: pass (google.com: domain of jpoimboe@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jpoimboe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jpoimboe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id DB64D30C2509;
	Fri,  1 Mar 2019 03:31:34 +0000 (UTC)
Received: from treble (ovpn-121-121.rdu2.redhat.com [10.10.121.121])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 1C3D6183D9;
	Fri,  1 Mar 2019 03:31:31 +0000 (UTC)
Date: Thu, 28 Feb 2019 21:31:29 -0600
From: Josh Poimboeuf <jpoimboe@redhat.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: syzbot <syzbot+ca95b2b7aef9e7cbd6ab@syzkaller.appspotmail.com>,
	amir73il@gmail.com, darrick.wong@oracle.com, david@fromorbit.com,
	hannes@cmpxchg.org, hughd@google.com, jrdr.linux@gmail.com,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	syzkaller-bugs@googlegroups.com, willy@infradead.org,
	Jan Kara <jack@suse.cz>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference in
 __generic_file_write_iter
Message-ID: <20190301033129.5tepij2g4lcbvk4s@treble>
References: <0000000000001aab8b0582689e11@google.com>
 <20190221113624.284fe267e73752639186a563@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190221113624.284fe267e73752639186a563@linux-foundation.org>
User-Agent: NeoMutt/20180716
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Fri, 01 Mar 2019 03:31:35 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 21, 2019 at 11:36:24AM -0800, Andrew Morton wrote:
> On Thu, 21 Feb 2019 06:52:04 -0800 syzbot <syzbot+ca95b2b7aef9e7cbd6ab@syzkaller.appspotmail.com> wrote:
> 
> > Hello,
> > 
> > syzbot found the following crash on:
> > 
> > HEAD commit:    4aa9fc2a435a Revert "mm, memory_hotplug: initialize struct..
> > git tree:       upstream
> > console output: https://syzkaller.appspot.com/x/log.txt?x=1101382f400000
> > kernel config:  https://syzkaller.appspot.com/x/.config?x=4fceea9e2d99ac20
> > dashboard link: https://syzkaller.appspot.com/bug?extid=ca95b2b7aef9e7cbd6ab
> > compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
> > 
> > Unfortunately, I don't have any reproducer for this crash yet.
> 
> Not understanding.  That seems to be saying that we got a NULL pointer
> deref in __generic_file_write_iter() at
> 
>                 written = generic_perform_write(file, from, iocb->ki_pos);
> 
> which isn't possible.
> 
> I'm not seeing recent changes in there which could have caused this.  Help.

FWIW, the panic happened in generic_perform_write() when it called
a_ops->write_begin, which was NULL.

I agree with Jann that the unwinders should handle this scenario better.

-- 
Josh

