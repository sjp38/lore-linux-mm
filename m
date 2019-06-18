Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 99349C31E5B
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 01:40:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5239B2082C
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 01:40:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="tAYxS8Cz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5239B2082C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ECAEA8E0005; Mon, 17 Jun 2019 21:40:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E7AEF8E0001; Mon, 17 Jun 2019 21:40:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D43CD8E0005; Mon, 17 Jun 2019 21:40:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9C3648E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 21:40:45 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id h27so1638738pfq.17
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 18:40:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=e8n1dhH05vKni7panA8EPqi7kyq4X1nEgLodhwt9/EE=;
        b=ceHRXJzTIEMfq6XUkoR+DlKx4+XZdTA69QYLYPD+GG4Z0GwBxfPhC/S004xIX7Qrkf
         XesCbrxIqUpbbNDsp596ciKfraW6+HpTqvlqqS1whGKAq6/HzVHX3wvwlUA29RURg4/2
         enUO7mpdOdt4nPaLZzNv0C3x1PJ9H9seSgMZSdLBgsckh5DjXsZaFjI2JSPeq2eHGX26
         Pyt+z0EKqqHgaqipSTS3u2U7y3T4iN3h56sU/wiJAur8VmXALr/xp056QhIOaQjwj1GN
         crpS0ELO3ntZ1ogkwCS4qORqK8WoMvL26eZcW74RSGGdo53Ydfp+tomJFl5CVkho+9KV
         vVkg==
X-Gm-Message-State: APjAAAUrRsWv1e+0zlyvdpbAjzBcKpsUhPe8I3Y8WaLzCx6aIZOy2pmq
	gGsD+n8gkjvuXBBQiAxeopwbAUAVpKxE6Lc7jOll+qGiGRsA5KyElfpuH9oxO7ycn/pYAGrXGUW
	Q1iX6ijhCWlGUq6skfyj/EMkw4tySXNiLkazzbfiMSV2jIQY/h4LZnSR+ntDvyJu98Q==
X-Received: by 2002:a62:4d04:: with SMTP id a4mr116829614pfb.177.1560822045250;
        Mon, 17 Jun 2019 18:40:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz6+nFbH5RnRwmC7BWPidnRq1MahclNQgmj/vu7N52Tafyk1N/1NXEbbfsqpu3d8fF+LDhn
X-Received: by 2002:a62:4d04:: with SMTP id a4mr116829586pfb.177.1560822044588;
        Mon, 17 Jun 2019 18:40:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560822044; cv=none;
        d=google.com; s=arc-20160816;
        b=j66RwlxPRrCEeW63sjn4k6q36Rv3SuOY/RIslKo1a3HYlvYS8HK69wW2VwQs8gB5on
         UhGL9Rg03RPYAJq1502NnS9YTifvhY3b1XtvL/FLKAFiacrQgxa8GvS4gwSgW08LtCrV
         e3jQcOq1tl9XEk3T1V4sWnaEeBVYCFm1FWGdqUCDJcPctVHDQO2814EdMlkVtuve7ydQ
         21FDGFB4D6WS1RVryRPFNgacYg2RbvuUUza5xFVygMKhIdm/+15r+lCCQHu6KoEVYsmL
         kfykuP2bHantxZV6l6PBuTfW4BRKm9hd9/yCjpEYDVGFEbq/bJC2AWHYTuicsjrLgZWY
         Xw+w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=e8n1dhH05vKni7panA8EPqi7kyq4X1nEgLodhwt9/EE=;
        b=m7ZQWUSUBWdrymX73XFRLMAniYN20LaPdEblvbjKsTsi0wc/GruFuKRdZKpKU48bVY
         v0VQOjcypua0/y9Qp/NrPqztLQfuNRgPn833kNRJpWpaouVQ6LoIIgKc2U+Z/kxGz4Cs
         kZYTiSwSHFvG+8E4ejywMRr9Jy4cpQsnSjSSJ9qKMs+oVmurpOH5rkLWPBkVd6VflVVm
         rArNkQW61lm6Ca5WEvxfl0wx+6KBYc5MLY/2+KvvTUDw3TX1liGiBL4vIeRPmi1soa0G
         ugMsFie+n9B7vpkggVhjNUFl7Cr8JVwO8Aev1vS8SGBWm1KJ5R+DJtTlxF3RqEYJ47db
         hoZw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=tAYxS8Cz;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id r3si12437063pgr.495.2019.06.17.18.40.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 18:40:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=tAYxS8Cz;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wm1-f48.google.com (mail-wm1-f48.google.com [209.85.128.48])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id EDB9321783
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 01:40:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1560822044;
	bh=KsbO8zqRDwjqNqLUKDtxw38bKGpR6/rXffGf+dHWdqY=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=tAYxS8CzDFuv2tQZHZR4A3RbB0atwX6vH4WU+fA+oZHmeDZ2QCd8tIftSy05dWYvx
	 Zr2+5L9RCAkPUy8diltaJF7/yaAZ9lLrLPKmiWFNUhWORvS5gl44MTXH5S00eMh8Dm
	 CARK3lbj5/kG+g8UA3DoM4IVv0LeK7RA1QPw8H0E=
Received: by mail-wm1-f48.google.com with SMTP id s3so1358987wms.2
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 18:40:43 -0700 (PDT)
X-Received: by 2002:a7b:cd84:: with SMTP id y4mr928755wmj.79.1560822042435;
 Mon, 17 Jun 2019 18:40:42 -0700 (PDT)
MIME-Version: 1.0
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
 <20190508144422.13171-46-kirill.shutemov@linux.intel.com> <CALCETrVCdp4LyCasvGkc0+S6fvS+dna=_ytLdDPuD2xeAr5c-w@mail.gmail.com>
 <3c658cce-7b7e-7d45-59a0-e17dae986713@intel.com> <CALCETrUPSv4Xae3iO+2i_HecJLfx4mqFfmtfp+cwBdab8JUZrg@mail.gmail.com>
 <5cbfa2da-ba2e-ed91-d0e8-add67753fc12@intel.com> <1560815959.5187.57.camel@linux.intel.com>
 <cbbc6af7-36f8-a81f-48b1-2ad4eefc2417@amd.com>
In-Reply-To: <cbbc6af7-36f8-a81f-48b1-2ad4eefc2417@amd.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Mon, 17 Jun 2019 18:40:31 -0700
X-Gmail-Original-Message-ID: <CALCETrWq98--AgXXj=h1R70CiCWNncCThN2fEdxj2ZkedMw6=A@mail.gmail.com>
Message-ID: <CALCETrWq98--AgXXj=h1R70CiCWNncCThN2fEdxj2ZkedMw6=A@mail.gmail.com>
Subject: Re: [PATCH, RFC 45/62] mm: Add the encrypt_mprotect() system call for MKTME
To: "Lendacky, Thomas" <Thomas.Lendacky@amd.com>
Cc: Kai Huang <kai.huang@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, 
	Andy Lutomirski <luto@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, 
	Andrew Morton <akpm@linux-foundation.org>, X86 ML <x86@kernel.org>, 
	Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, 
	Borislav Petkov <bp@alien8.de>, Peter Zijlstra <peterz@infradead.org>, David Howells <dhowells@redhat.com>, 
	Kees Cook <keescook@chromium.org>, Jacob Pan <jacob.jun.pan@linux.intel.com>, 
	Alison Schofield <alison.schofield@intel.com>, Linux-MM <linux-mm@kvack.org>, 
	kvm list <kvm@vger.kernel.org>, "keyrings@vger.kernel.org" <keyrings@vger.kernel.org>, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 17, 2019 at 6:34 PM Lendacky, Thomas
<Thomas.Lendacky@amd.com> wrote:
>
> On 6/17/19 6:59 PM, Kai Huang wrote:
> > On Mon, 2019-06-17 at 11:27 -0700, Dave Hansen wrote:

> >
> > And yes from my reading (better to have AMD guys to confirm) SEV guest uses anonymous memory, but it
> > also pins all guest memory (by calling GUP from KVM -- SEV specifically introduced 2 KVM ioctls for
> > this purpose), since SEV architecturally cannot support swapping, migraiton of SEV-encrypted guest
> > memory, because SME/SEV also uses physical address as "tweak", and there's no way that kernel can
> > get or use SEV-guest's memory encryption key. In order to swap/migrate SEV-guest memory, we need SGX
> > EPC eviction/reload similar thing, which SEV doesn't have today.
>
> Yes, all the guest memory is currently pinned by calling GUP when creating
> an SEV guest.

Ick.

What happens if QEMU tries to read the memory?  Does it just see
ciphertext?  Is cache coherency lost if QEMU writes it?

