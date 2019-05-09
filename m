Return-Path: <SRS0=5q+O=TJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6250EC04AB1
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 16:47:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 23A1F21019
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 16:47:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="kkjYqCrQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 23A1F21019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B354B6B0005; Thu,  9 May 2019 12:47:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AE5F36B0007; Thu,  9 May 2019 12:47:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9AD706B0008; Thu,  9 May 2019 12:47:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f197.google.com (mail-vk1-f197.google.com [209.85.221.197])
	by kanga.kvack.org (Postfix) with ESMTP id 788A76B0005
	for <linux-mm@kvack.org>; Thu,  9 May 2019 12:47:26 -0400 (EDT)
Received: by mail-vk1-f197.google.com with SMTP id v22so1194538vkv.12
        for <linux-mm@kvack.org>; Thu, 09 May 2019 09:47:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=TOD9m5ani8ZrZtUR06eegEmPqO4qUZMEv0GTuqKapM0=;
        b=kHGUpvgHEG1HQVbVdF3FyVDsO8cq7A6LwRGU6yygyFAag5wmU1e/OaTLmm22yEUk2N
         5bbSSIIQBYiFFVMdq/JW9kuGmGwZtfUUUgPqbMILdgfO+1FgQQl6LyZzgr24eo+jYOYa
         JxB0x+0XhBcrE9nt6Kc5RxduK6XtJWoIWwr4L9LH3ORCRQp9WPLfmM3SPiA30Vv+vTGR
         8xmGFIRUD19SO3qZEtJvptwS/QiylCWFc8BLcilL9BjlrR5Kb5TiWKLuIG+BZ0DFHeON
         xwEufZRaSMslYk6f/DfL0gjh3hFJ3OPtvyJPVL0S+GHzCd5WLNF7+0XYozXicjrQVu5S
         p3Sg==
X-Gm-Message-State: APjAAAXMoS5dZjHlIeJ5+fW/J8+aI8SPzBmwmk7qko6sTd861vNkU2Oo
	R8d6vbpA/+7S7n9o+4+UAkp+h+frzIPuV6nk3AgksmKtdlkIiyR4f2QhRS/Ek+rgVM955tMVryp
	rQM/okgz88OZ6emMEyjZy1R86zKLrL8T//7Z0E8ofCaPaesu8Rh5A1uJO72LWIHNGog==
X-Received: by 2002:a67:7b8c:: with SMTP id w134mr3104673vsc.219.1557420446205;
        Thu, 09 May 2019 09:47:26 -0700 (PDT)
X-Received: by 2002:a67:7b8c:: with SMTP id w134mr3104638vsc.219.1557420445451;
        Thu, 09 May 2019 09:47:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557420445; cv=none;
        d=google.com; s=arc-20160816;
        b=ITbvM0Pxpd1YBviegjyinZhkfAdQHPnECI0e2/lKS6LC5w7+nyBhr9SHU+WAhcqw87
         ulU+pbi8nhI1q1dR6xga+PYHiDAstkH8QJLdmnkgQfeoH7UniZeKSX2qzeuYb5cVEVRa
         sFN+9JjtT8T+wJ8TPYiTyxOvTJHuTzOqpTV5ZdQgWPn1nDyvmA7bO/ftlwmywXyWreTt
         7eUsVGtCGd3LyM6ArAJezp1K1PZGLxgpVCjJ0N0WOVlbLYIZcxypn+Cto0hrLS2jthv+
         eNfbwYZyJGqiRLQG2bRJbUObKltKR4LB3B0k59qM1DAv5vVZ0EzMhnqpJbNURqccUvdA
         Uo9A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=TOD9m5ani8ZrZtUR06eegEmPqO4qUZMEv0GTuqKapM0=;
        b=uzPlcdsf1KMMj8Rm1ahCQH0HCnFgZR/BhRhhDF1mygMAVYaMKoAO0P0QTTIgQvzGPA
         vnYHtCe9pcoRsOAqIGQyeRIpa5bWMToUwStvPaCKzepRVQ0Wk6MSBWPaBeeS+Tx5aqkP
         Rh2VAniGFoBMeJ13o9Rt+oNYB/2SIExn970L0+/p5lOqWHNevwwhPFeOGQZyeJOpeLyV
         UuChxUU4Fdqwm4UMm6zjMJJcsRoOHavPxq0yXQ8aboYqPtv056xcdKs47yqlDkg05z9A
         BRPIIZour0i6J0SnIh/cxE+eOwAA20Xo0RWFbQTSWscBGNnS3YEpS91JKTa0bIidaoL3
         ZHkQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=kkjYqCrQ;
       spf=pass (google.com: domain of pankajssuryawanshi@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=pankajssuryawanshi@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id p25sor1361977uao.15.2019.05.09.09.47.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 09 May 2019 09:47:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of pankajssuryawanshi@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=kkjYqCrQ;
       spf=pass (google.com: domain of pankajssuryawanshi@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=pankajssuryawanshi@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=TOD9m5ani8ZrZtUR06eegEmPqO4qUZMEv0GTuqKapM0=;
        b=kkjYqCrQ5OGG+/hCecsHd/H7hfbb1ksW7F69CkE1T1fE/5SY4riNBHew4FB6VanXBT
         0q34uNp/dmGT6m+bSTfegYUWOf+aomEL0P+nmoAMfj7VrtIzqqhT/mYv9AWZPbe/LuJR
         8/tOJXs83BhT+kiebbDIUIoO5crI7NtpvWyTj6KBh7EBuf0ZV7vPJSwQftIYiGY+XxEy
         ONdbfoYirAiggeNSGVmQq7Ab7YIrv7JEOHQ1o9QNkSZ1hnAXnfzSNj1typ+mnA63ouoo
         e9i/zpLln4H5BtdPaqcvRDQC3RpJ2YGKaK4RH/AjZ4YVVaRKqxjFTPna9oCcbuq4Oocp
         U3yQ==
X-Google-Smtp-Source: APXvYqzIZa4LzmjuxILdnDq1vkqq826kSC1u+DR9Z3NyiMKZfQXFRoCQ354oIVUkTTl9N6h7IJPL5vktO9I0O4rujQI=
X-Received: by 2002:ab0:1410:: with SMTP id b16mr1999491uae.1.1557420445101;
 Thu, 09 May 2019 09:47:25 -0700 (PDT)
MIME-Version: 1.0
References: <CACDBo57s_ZxmxjmRrCSwaqQzzO5r0SadzMhseeb9X0t0mOwJZA@mail.gmail.com>
 <11029.1556774479@turing-police> <CACDBo54xXk-68MTsxw2K12gD0eGO0Xpq0rw60E3AX+2OEi3igw@mail.gmail.com>
 <26e83e08-3249-e73f-2049-f36b44af8d8a@suse.cz>
In-Reply-To: <26e83e08-3249-e73f-2049-f36b44af8d8a@suse.cz>
From: Pankaj Suryawanshi <pankajssuryawanshi@gmail.com>
Date: Thu, 9 May 2019 22:17:14 +0530
Message-ID: <CACDBo56LBKsxqsHAi=Jd6ZJoZsSpFJ5a_DbwEx9h+=FJjr0rhw@mail.gmail.com>
Subject: Re: Page Allocation Failure and Page allocation stalls
To: Vlastimil Babka <vbabka@suse.cz>
Cc: =?UTF-8?Q?Valdis_Kl=C4=93tnieks?= <valdis.kletnieks@vt.edu>, 
	linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
	kernelnewbies@kernelnewbies.org, Michal Hocko <mhocko@kernel.org>, minchan@kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 6, 2019 at 2:35 PM Vlastimil Babka <vbabka@suse.cz> wrote:
>
> On 5/3/19 7:44 PM, Pankaj Suryawanshi wrote:
> >> First possibility that comes to mind is that a usermodehelper got launched, and
> >> it then tried to fork with a very large active process image.  Do we have any
> >> clues what was going on?  Did a device get hotplugged?
> >
> > Yes,The system is android and it tries to allocate memory for video
> > player from CMA reserved memory using custom octl call for dma apis.
>
> The stacktrace doesn't look like a CMA allocation though. That would be
> doing alloc_contig_range(), not kmalloc(). Could be some CMA area setup
> issue?
>
I know cma uses alloc_contig_range() but using dma api it will uses
many functions.
the failure is coming from dma_common_contiguous_remap() for kmalloc ,
and which is called by dma_alloc_attr for cma allocation.

Please let me know, how to avoid page allocation stalls. any reason ?
Cpu Utilization issue ? or I am running out of memory ?

My System configuration is
2GB RAM
Memory Spilt 2G/2G
vmalloc=1024M
CMA=1024
Max contiguous memory required 390M

> > Please let me know how to overcome this issues, or how to reduce
> > fragmentation of memory so that higher order allocation get suuceed ?
> >
> > Thanks
> >
>

