Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AC8F1C76191
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 13:08:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7046F206B8
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 13:08:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7046F206B8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 191356B0007; Mon, 15 Jul 2019 09:08:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 14B0B6B0008; Mon, 15 Jul 2019 09:08:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 00B6D6B000A; Mon, 15 Jul 2019 09:08:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id BB5D76B0007
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 09:08:52 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id l24so8879552wrb.0
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 06:08:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=YWSXzMBsR2TR6A1F1WRnPCvLrQf0rJZz8/hiYkd3cZY=;
        b=ZhnIlU5zelPDwWBR9O8Re93Vay7XzLt1AfSAh+J8Hgq3Ju3F+ABnXUa4gFphCN9izj
         mtvcnIR39pxgbjXYpgvBzGhRkPw/u+K3BsACpY3YK+YJN2BiZ/tRB1zoDyqNV7FUs1UG
         6vqozyC6XqwN7P/nLh3tq31mU9dEh3ydhtsmob7xkJxggbPeNpitTwSpOJzXdyJ+EBv0
         X/Q/aYAA5sVm/Y6uih0U68EW+qT32FnglfjZ+rVd0z7D94m6UBX87OIZgkqfB+fHcLHS
         wXDkWqFt2yfrnWz3oGwzpBJaja5NLWZK5lMxKVPtWmdKI2g4Qib0FnkgkqaKrvjpLWDz
         RykA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAV3nZZaVsxjuGg3LWMpiXiKqZF/KlIAxeme1ud6Pt49kj+rCgcl
	htOsRexyz31Vt13AOL638lEnggOrvSXxHgPCeshPILFPUO2xic55lIo1aK6pEeeg+Seo6qp9a90
	QoNWbN+GF+RGb2TZ8hLWjqkGg2H2OtQ90coBdlSalrCyH3GUJdLrqbdPeD8lJ2vNARA==
X-Received: by 2002:a5d:4206:: with SMTP id n6mr29406902wrq.110.1563196132265;
        Mon, 15 Jul 2019 06:08:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqylar5lOlgT8m2kZ2TYKod0yA3wMK/Me5d7+RicGCTKKDnIYTSLN0M4lwyqr+Msj34vlxRc
X-Received: by 2002:a5d:4206:: with SMTP id n6mr29406862wrq.110.1563196131653;
        Mon, 15 Jul 2019 06:08:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563196131; cv=none;
        d=google.com; s=arc-20160816;
        b=eolREpIY+KK4juW8tU4fr/wOHmopC65V0ly8pN6l2+qtAam7FRbCOpa2+3aAwX0XUV
         Wx0AoQBonSou9y2KvIsN7rMsUPYPa3BqiU0DncNQBNCkP+DGXujzXTLKgcT3v+3FtcIM
         oj0YOv64mDlq6ErWN9AsBYOLbNLMe6djvgClPMmtBEbzqeo/mvrlxWy9M2ACBLTDTnAn
         FO8I8qv5Z7j2jN9yK4yqNAwiDgGanrAxvJ0pYiFpcEoym/bMu9bNJX61M0IBWqOZdhzY
         2RKHDJOnN9XV8qoaF4S2gsUXr0fURW0N4ts9JvvqXO4REW/lGjm1WJzSSVPPn3B9Zwiv
         w2mA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=YWSXzMBsR2TR6A1F1WRnPCvLrQf0rJZz8/hiYkd3cZY=;
        b=eLglulKhXpiVH49EAhXFm8RL7EP3XZScMoU+u/qrsfN8bqiAnCY4zaOK6UUOJdlYDD
         xni8jRn0PMwYks8Pw4TJAQY4vf6c6CufakydY3OgaqY/ohGFYk0Y0dGv9GQyOhJUlrgi
         BBwbB9pX7BTxfSsEHqCyauyWpGzlYMvDMVhVWNaF3t4lIwiC4vVDjUjr58IbUjKI+ZF6
         kt1MoEuL+6l/+9g62S+y63WWmVFZRyVtbbuQ8+6nPk//HasgHlX/J9TVz08x4Pah5xC8
         C8d/BCqSkQUSzK4rBY3lv042LrXRQCoTXCnic7+2oAkWqjYQpJFR3reRua/o21fyVbbt
         kjng==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a0a:51c0:0:12e:550::1])
        by mx.google.com with ESMTPS id l3si10571380wrh.46.2019.07.15.06.08.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 15 Jul 2019 06:08:51 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) client-ip=2a0a:51c0:0:12e:550::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from [5.158.153.52] (helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hn0ih-0006Ku-9b; Mon, 15 Jul 2019 15:08:43 +0200
Date: Mon, 15 Jul 2019 15:08:42 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
To: Joerg Roedel <joro@8bytes.org>
cc: Dave Hansen <dave.hansen@linux.intel.com>, 
    Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, 
    Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, 
    Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, 
    linux-mm@kvack.org, Joerg Roedel <jroedel@suse.de>
Subject: Re: [PATCH 1/3] x86/mm: Check for pfn instead of page in
 vmalloc_sync_one()
In-Reply-To: <20190715110212.18617-2-joro@8bytes.org>
Message-ID: <alpine.DEB.2.21.1907151508210.1722@nanos.tec.linutronix.de>
References: <20190715110212.18617-1-joro@8bytes.org> <20190715110212.18617-2-joro@8bytes.org>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 15 Jul 2019, Joerg Roedel wrote:

> From: Joerg Roedel <jroedel@suse.de>
> 
> Do not require a struct page for the mapped memory location
> because it might not exist. This can happen when an
> ioremapped region is mapped with 2MB pages.
> 
> Signed-off-by: Joerg Roedel <jroedel@suse.de>

Lacks a Fixes tag, hmm?

