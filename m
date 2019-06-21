Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 28FB9C43613
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 13:11:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D6E8D2083B
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 13:11:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="Gg0bojnn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D6E8D2083B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6F9E48E0003; Fri, 21 Jun 2019 09:11:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6AA948E0001; Fri, 21 Jun 2019 09:11:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 599588E0003; Fri, 21 Jun 2019 09:11:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0F6038E0001
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 09:11:34 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id y24so9205364edb.1
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 06:11:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=AyLAEHAoTiHsTh4Ci9HQnMyYQMtGJRt5b9Z5HyIMkcg=;
        b=XW5UpWZe4L9MEZNe9GxJBUEzAmsbV007qaCZIKjiaBVCdqHNpqesvSFkwblL6ZsAMB
         BlizQBoIIoUZX8NUl178VU3TpJZV1hvHEFK2dlpOMRdts3HeW/Z2GevM5ZXtUtv777yU
         N8BiUpZCmmet3wEWmNgRpiUgHkofMycQbS2Aleqrq4LCzMxDWyqKH+P5Cfb60y3lUB6p
         /5yRXj8S9b/6jE40pJpEzpv85cR56Y03uycZJfouPdpYutw1piqBm8v+LD7v5LSstCld
         7uOux5B9Se6Zv5HGK5vFyZx4ozewBEOvAhoqVEz4nnWmDe+J7Ny10NLOo5frtH5A5qXQ
         SnTw==
X-Gm-Message-State: APjAAAVKiR8EyqvElIif6yTZsm0cLIRKP79O7CVHHaz2UpKnHnwEBlI1
	83A2zzwUdmrdliypkHf3ABPrf1CRDr+u71nSp2K6CN85v8lRsjbvdZIQbbUpeTJc2opCNqHsf3S
	E+y8UUOIV2C9wlJpd11XC/iKqGKh4XHa1OIQwrn3ab3iU+/Bmty4WyU/kpx5d2UB1Xw==
X-Received: by 2002:a50:8974:: with SMTP id f49mr91323071edf.95.1561122693597;
        Fri, 21 Jun 2019 06:11:33 -0700 (PDT)
X-Received: by 2002:a50:8974:: with SMTP id f49mr91322970edf.95.1561122692828;
        Fri, 21 Jun 2019 06:11:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561122692; cv=none;
        d=google.com; s=arc-20160816;
        b=IomvHRKbHb1rfpky39vpQQ+OSsFUolmqBG3L4zosusB3vw0Y9+Rzqya83A7rMjgMs/
         nUD8X+uTJjUs/AqW8WafOdS141BCQUHGyTOdwWwlPykUw9nCJl4pd1Ar29pmG6V1MMU0
         92eM4iaNbPa2LqSagsnD+HwrC8FnkFWlsiiTTqUtkvEk6qpms1E9d1OME3pREcm7NQsI
         yAS7MxTozrttC1fJ99JDsKbwxMdvOUhZSyoCFXd7o7hZyi/DA/vWTyW+v6PpqkwIJ3O1
         ivRbzWadb9+OfEFkRvHyUqhJNzgZkvzNBF6trDaWuIQBT0aT6T/zhfSU6u8yuetSs6Rf
         xkew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=AyLAEHAoTiHsTh4Ci9HQnMyYQMtGJRt5b9Z5HyIMkcg=;
        b=GMUxTK1l90ZHJHQ2ES2r8FR7k1jWdJ3BjBj5nbTM5HhiIWRB5mqF+1xMqexao3hfaa
         7DdU43mpdyAJWjiDblgy0BhPMHnDJWpcmnUSnyLduWWoanhNtX6ur3dr8/7XDnPj07D0
         EhFe8xSvqjxUwKz26JZtUyoKAe0+59Nd4C3N/W9UM66ksoqusMu/v5KtLFJNN1X3iiE8
         MWyaG+irmT/fVveiNQfdJQcLj0697dLbqVXBVdmXcmfifXOS2B53/ageWVGivoDZKbRu
         TIXb1IrZ8x5yzmA8RtNiExCv4JEqfVjbNAxvOarjcptmEpWPfsMY8MiGjp5IPV1/A7oa
         4ASw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=Gg0bojnn;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id gx1sor1029160ejb.7.2019.06.21.06.11.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Jun 2019 06:11:32 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=Gg0bojnn;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=AyLAEHAoTiHsTh4Ci9HQnMyYQMtGJRt5b9Z5HyIMkcg=;
        b=Gg0bojnnmyLsVpVHlHmQK5Rq2yABGcbSrhP3lr0P29TW76t6OcDQtuHceiGumBraAd
         fwz+RX/bkOQuE1QMOCbikS4QJ+4zxOlVkI/kjvrtqEcGQHXds0WCPTbgZkWFcOGvcGWh
         SajZY/Z2zE3zKgpf3teOVufX6RzHjWX1Z5IKX2ECjvJWihN7LyrSZ/kR2jIeOAwIm4uV
         fSFCzZW5UJCcOJaXboNsSIXjvNyAlQBJ2QUYa659g59e+Z239njxJB8xTydym2bP2eKq
         wR9udhVcvLtBYFap4PTsevfBr24LFs03sfaBzpdiyIz8xkx+SgxhdqDTyDMqgMDByjsD
         d0wg==
X-Google-Smtp-Source: APXvYqx818Q25ywCLb9OOtkAH2lVPMpvmHlzZZl1H4Krc2wN2O9tizzeSxH0Tedf2y5rHaEO3xikcw==
X-Received: by 2002:a17:906:a394:: with SMTP id k20mr95857655ejz.46.1561122692425;
        Fri, 21 Jun 2019 06:11:32 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id d8sm787817edi.90.2019.06.21.06.11.31
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jun 2019 06:11:31 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id DDD2010289C; Fri, 21 Jun 2019 16:11:33 +0300 (+03)
Date: Fri, 21 Jun 2019 16:11:33 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Song Liu <songliubraving@fb.com>
Cc: Linux-MM <linux-mm@kvack.org>,
	Matthew Wilcox <matthew.wilcox@oracle.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Kernel Team <Kernel-team@fb.com>,
	William Kucharski <william.kucharski@oracle.com>,
	Chad Mynhier <chad.mynhier@oracle.com>,
	Mike Kravetz <mike.kravetz@oracle.com>
Subject: Re: [PATCH v2 3/3] mm,thp: add read-only THP support for (non-shmem)
 FS
Message-ID: <20190621131133.tafbzskbvquaaa7m@box>
References: <20190614182204.2673660-1-songliubraving@fb.com>
 <20190614182204.2673660-4-songliubraving@fb.com>
 <20190621125810.llsqslfo52nfh5g7@box>
 <B83B2259-7CF5-411E-BC4C-7112657FC48E@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <B83B2259-7CF5-411E-BC4C-7112657FC48E@fb.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 21, 2019 at 01:08:39PM +0000, Song Liu wrote:
> 
> Hi Kirill,
> 
> > On Jun 21, 2019, at 5:58 AM, Kirill A. Shutemov <kirill@shutemov.name> wrote:
> > 
> > On Fri, Jun 14, 2019 at 11:22:04AM -0700, Song Liu wrote:
> >> This patch is (hopefully) the first step to enable THP for non-shmem
> >> filesystems.
> >> 
> >> This patch enables an application to put part of its text sections to THP
> >> via madvise, for example:
> >> 
> >>    madvise((void *)0x600000, 0x200000, MADV_HUGEPAGE);
> >> 
> >> We tried to reuse the logic for THP on tmpfs. The following functions are
> >> renamed to reflect the new functionality:
> >> 
> >> 	collapse_shmem()	=>  collapse_file()
> >> 	khugepaged_scan_shmem()	=>  khugepaged_scan_file()
> >> 
> >> Currently, write is not supported for non-shmem THP. This is enforced by
> >> taking negative i_writecount. Therefore, if file has THP pages in the
> >> page cache, open() to write will fail. To update/modify the file, the
> >> user need to remove it first.
> >> 
> >> An EXPERIMENTAL config, READ_ONLY_THP_FOR_FS, is added to gate this
> >> feature.
> > 
> > Please document explicitly that the feature opens local DoS attack: any
> > user with read access to file can block write to the file by using
> > MADV_HUGEPAGE for a range of the file.
> > 
> > As is it only has to be used with trusted userspace.
> > 
> > We also might want to have mount option in addition to Kconfig option to
> > enable the feature on per-mount basis.
> 
> This behavior has been removed from v3 to v5. 

Yes, I've catch up with that. :P

-- 
 Kirill A. Shutemov

