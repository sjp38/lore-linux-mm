Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 338EBC04AB5
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 17:47:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E26A32705E
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 17:47:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="zyV8dwkC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E26A32705E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 92D656B0276; Mon,  3 Jun 2019 13:47:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8B4A96B0278; Mon,  3 Jun 2019 13:47:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 72F066B0279; Mon,  3 Jun 2019 13:47:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1E2C96B0276
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 13:47:09 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id a21so13339025edt.23
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 10:47:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=dXNJh93VKnrDRoV3p7QeHW/6uh2W1UxKfkBC3L76x5Y=;
        b=t4kLrHUOyr6eKKjPSsU2VlAEu8cxiTLgYLkNHFGA6Begrj2hP7MSs/cvQrEdOSf8BV
         OfelEW0Q+bYVJ3Mbo8zlxBBHeaq8vxjwILzMi5QmbJUnmeCTMka4fyk5ppy/jK1ZurXB
         Xc6sYZtWwihE96K9dMj4TH59JLPX/cK/kyK3riaW8zOnzzplNf3z26zFBVW21IAZIUyb
         MxoDq7toMx08RwHV3+4w6MpbQzy2JvKZDdq1cxINHReiGaKTyfBQSJH0wM5ibgZ6U61S
         0PMLVo3TAwrsKpoj/gtwwmkCDQwWRJEviXzS1wZuZ01CeqrCyZRhNVxeJ/5O/SEgxt2N
         KLrw==
X-Gm-Message-State: APjAAAU6/H4XdMiAUzny6t/R68X7YAh0rqFuzgQrmjL/GfsI/q3GaLsg
	ELFqsKlGfgqLOELUJlRorwSONNrKd309eItCcusDdiU8iU9X9ae9iI0JHwnOMo9mM1kT0rN4W5t
	VmhIQ83w6pdNHV3+mB8Ae+zy7YqQazRMjo53sEm1HpAp/UwJRrQCOvKRFZ4bw5uazbA==
X-Received: by 2002:a17:906:90cf:: with SMTP id v15mr2380056ejw.77.1559584028692;
        Mon, 03 Jun 2019 10:47:08 -0700 (PDT)
X-Received: by 2002:a17:906:90cf:: with SMTP id v15mr2379996ejw.77.1559584027853;
        Mon, 03 Jun 2019 10:47:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559584027; cv=none;
        d=google.com; s=arc-20160816;
        b=DoYA0eQEfMxlVaMvi6ZvxXOGnUVczBiGXuPhmG+om3brUghwHG4/4TD5iSWe+fYsgh
         1Wu36MQhkbkWsRrQLmVwxKmSh12LdzcvqgUjgh0UtDti8og2WXWoonyE+iqC0gPbdLXK
         q3EDk06QnpMUGTd7pFtZbxNX61vEAdzbWq8wZ/z6zWcrXWCZY45px4QzB3/+YZdwkZ9N
         3USoLc1XvBE78Xai4kUlgzs7BZzhpxWWcRTP2YtvQgyDWlOVxKDdzXL2yfdTh7kXH/6/
         m2sMtIv1San6w3nfo+4Xxv9fGNjSN1C5IcG0C84wvtzLI9WrN8gp1nO9IWqXpUvZ0NrB
         7uTg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=dXNJh93VKnrDRoV3p7QeHW/6uh2W1UxKfkBC3L76x5Y=;
        b=wlr//j1YXE9b248yniR+1vsG91JrFloOzUlisJF52BViA4aFVh9iKlRk0LPe0gTJmW
         kku5LvbjccTrBiKrVgxbqFezBkXNXuagz+51VBV4nkx5wYQTb4Ia9OA39t9wyzz7iiAu
         PPLvF/UXIddHnbCIsA8jyf/bNOWh0XCFnmqspJbTeDEMmDZpA3byiNtnuY9Qusidbk0x
         XXgisDlrh9LJUbjEylULlKk6eQbxsMHnSxU0GzIiOwgkBWP7LO2ZF5FjIxafkOYuoQRn
         R9QNLaVNFLO4DqLbkz/yOgaO3A6TPnOOq88dZxJvCAgiVFa3Led0zSu8XxyYbdIdLSp1
         /Scg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=zyV8dwkC;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i27sor4783140ejg.40.2019.06.03.10.47.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Jun 2019 10:47:07 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=zyV8dwkC;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=dXNJh93VKnrDRoV3p7QeHW/6uh2W1UxKfkBC3L76x5Y=;
        b=zyV8dwkC82UjElwqhhNjiSRV3X89XUMQWmNIMYTdd6EyIBa1IFcNKjF7ZAXDYGRZfk
         tfc5lTMfAnYU0qTOOqK9kfJovtKnJhFX6D6BX0YOHAJ3LBeVRXL7Nr1VH/QZB7Q3WCnu
         hELQcbnUz1l/ZAcBillS1G3mHzX7MYKFGj5pSWqhtBN3WDd704uw6cBBs7ftJHxd37DI
         zXkHPUwknm1r8pGxDYgOFbH9rfEgcEgRipNQqvtbA49GiP1HZ8ebvVG272SxMRQNQrM2
         2v3A3zxoOLhUdg7w9CnnbEVubXFowGKItH98uxZff6gHcM/+InqD/hvOwkaTGOoN8Iql
         HxTA==
X-Google-Smtp-Source: APXvYqzchOzG2a90eyb97gNmeNZ+rcpDZlbNkRv/65YitVUDISDtqqNHz7rRPcSXIJV7hRryVBAxnw==
X-Received: by 2002:a17:906:63c1:: with SMTP id u1mr24787573ejk.173.1559584027481;
        Mon, 03 Jun 2019 10:47:07 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id d20sm2697588ejr.21.2019.06.03.10.47.06
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Jun 2019 10:47:06 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 0E37C10406D; Mon,  3 Jun 2019 20:47:06 +0300 (+03)
Date: Mon, 3 Jun 2019 20:47:06 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: akpm@linux-foundation.org, dan.j.williams@intel.com, mhocko@suse.com,
	keith.busch@intel.com, kirill.shutemov@linux.intel.com,
	alexander.h.duyck@linux.intel.com, ira.weiny@intel.com,
	andreyknvl@google.com, arunks@codeaurora.org, vbabka@suse.cz,
	cl@linux.com, riel@surriel.com, keescook@chromium.org,
	hannes@cmpxchg.org, npiggin@gmail.com,
	mathieu.desnoyers@efficios.com, shakeelb@google.com, guro@fb.com,
	aarcange@redhat.com, hughd@google.com, jglisse@redhat.com,
	mgorman@techsingularity.net, daniel.m.jordan@oracle.com,
	jannh@google.com, kilobyte@angband.pl, linux-api@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH v2 0/7] mm: process_vm_mmap() -- syscall for duplication
 a process mapping
Message-ID: <20190603174706.t4cby7f5ni4gvvom@box>
References: <155836064844.2441.10911127801797083064.stgit@localhost.localdomain>
 <20190522152254.5cyxhjizuwuojlix@box>
 <4228b541-d31c-b76a-2570-1924df0d4724@virtuozzo.com>
 <5ae7e3c1-3875-ea1e-54b3-ac3c493a11f0@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5ae7e3c1-3875-ea1e-54b3-ac3c493a11f0@virtuozzo.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 03, 2019 at 05:56:32PM +0300, Kirill Tkhai wrote:
> On 03.06.2019 17:38, Kirill Tkhai wrote:
> > On 22.05.2019 18:22, Kirill A. Shutemov wrote:
> >> On Mon, May 20, 2019 at 05:00:01PM +0300, Kirill Tkhai wrote:
> >>> This patchset adds a new syscall, which makes possible
> >>> to clone a VMA from a process to current process.
> >>> The syscall supplements the functionality provided
> >>> by process_vm_writev() and process_vm_readv() syscalls,
> >>> and it may be useful in many situation.
> >>
> >> Kirill, could you explain how the change affects rmap and how it is safe.
> >>
> >> My concern is that the patchset allows to map the same page multiple times
> >> within one process or even map page allocated by child to the parrent.
> > 
> > Speaking honestly, we already support this model, since ZERO_PAGE() may
> > be mapped multiply times in any number of mappings.
> 
> Picking of huge_zero_page and mremapping its VMA to unaligned address also gives
> the case, when the same huge page is mapped as huge page and as set of ordinary
> pages in the same process.
> 
> Summing up two above cases, is there really a fundamental problem with
> the functionality the patch set introduces? It looks like we already have
> these cases in stable kernel supported.

It *might* work. But it requires a lot of audit to prove that it actually
*does* work.

For instance, are you sure it will not break KSM? What does it mean for
memory accounting? memcg?

My point is that you breaking long standing invariant in Linux MM and it
has to be properly justified.

I would expect to see some strange deadlocks or permanent trylock failure
as result of such change.

-- 
 Kirill A. Shutemov

