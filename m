Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_NEOMUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7F88CC282DD
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 15:08:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 411732175B
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 15:08:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 411732175B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DEE6F6B026D; Thu, 23 May 2019 11:08:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D9F466B026E; Thu, 23 May 2019 11:08:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C8DCC6B026F; Thu, 23 May 2019 11:08:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7D7C76B026D
	for <linux-mm@kvack.org>; Thu, 23 May 2019 11:08:29 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b22so9518456edw.0
        for <linux-mm@kvack.org>; Thu, 23 May 2019 08:08:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ILz0DiqYRzeI063TKSdM5MgGJ1Ad4VRyn5X85ka81N8=;
        b=TE+U8h4stuan3UHZTSA7fZ6sEp+1Vj9tSXMGvG5KM4nC/CXQhcRP8BjxkZOUGRimzo
         VJR2+chSWIBJ+dD30IzPAZHpPUBR6EEjIJPQnaNqKICwUtKnqRkoLUUGe2/ELjaJTfhS
         27+AVHftuZtvEoHWJx+j7c+ZW24FNmjWSBJdepCUGTohs0SW3S4Sqg2NCI7k2OX6D8xi
         c2w+HfoFKCeA5WAm1xmLSrMUGJhet/SCY5NSU6tfY25LzEQM0LVIQf7sLCWosxrOipcU
         3ad4LvPuy4xuqNl57Hu9X8x6n5X7ZZsQuaTmcWRS6Bv4ZVVHevQ/uCKMxwYcuB1GsLi2
         /I4g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAVeGY87+aQxpO+AcdybS59dc95vcT8+PNivOlICuEJ5Ryt29tcE
	5nWSPARY6wcgLdslZHZ/xbSugQafQsjWpIhw1JyE9zWkKJZdvTmu2dKXTBBXkYiRArXEq+AWNXY
	jV6nIL+cOVcShkamRDE3hVhGGbngEDzAJjZQdkW28F7BYIjXCQ4A5i8LHH/teeuOuKQ==
X-Received: by 2002:a50:f593:: with SMTP id u19mr97585716edm.37.1558624109093;
        Thu, 23 May 2019 08:08:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyBxua+XYoJHnRNEDLWAOSJr5UxdKKke2K6mqwc4Xtj/9abtGqKlcfdXPfx4PwPmblAJPko
X-Received: by 2002:a50:f593:: with SMTP id u19mr97585573edm.37.1558624107931;
        Thu, 23 May 2019 08:08:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558624107; cv=none;
        d=google.com; s=arc-20160816;
        b=MPDRiHbJaBRFdyIJaUGgTYKiJL3/x6q2mKz+Y6yXx1SxRS+QXAPVoCt4NXh+GiGc2k
         xgtF8Jn2PHUoo9KULbvql1wjnMVzyGXKPnfbW8gJFXuRWt2rIrtlYOZs2pv6w+F6klft
         CoEMjluMFCt5ceIuGAAg46rfdVAqI5ZKNL+5gLnJdx76rWtcX+JdTWa0vchXNxc6t0Ju
         f8ro/7Jsfdw22KgrpsRvKJ8dSBPs7YuzvAaEtObVsKF55KkVIOrP+ew8jtFsOrfI5+5g
         isSmnNtUzCqE+AfUEAv6gIEK3CdoSpEr42edI/rWXNCThBqS77LLGSNKRgyD5rHRpzK9
         bQ5Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ILz0DiqYRzeI063TKSdM5MgGJ1Ad4VRyn5X85ka81N8=;
        b=vYUmOPJUK2QqZ3w1fVswACP4Mi3UWFZUVoRH1RuqucUH8p0EnAjHAx4lY50jSHGUMq
         fuwlIiuo0Gi12f1qRpn2K2RyCl2g4Rkw5C8sSH5dGrAN802wrtrdjVrxO3bHnoiMmnBp
         IHrkoJtOk/oA215R6HbZFkOVb0P3+XZK03WKpMqXMFRZM0/jzIC9xVspqQQpdG0XjBQx
         jeve+nnkAWSJS7paXqplGQbrgmOee2CMgp8Jg12xwQb105/fCqiY5/VHPcYHTy1dpfTi
         ++hQoIi6vEYNhCVwTlfKkFf+gpO8PHvR1yFZVsdaASdE32gB+U1j1891zNdgZH8bjW0i
         is2w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id s27si4203554edm.307.2019.05.23.08.08.27
        for <linux-mm@kvack.org>;
        Thu, 23 May 2019 08:08:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id C7E5C80D;
	Thu, 23 May 2019 08:08:26 -0700 (PDT)
Received: from mbp (usa-sjc-mx-foss1.foss.arm.com [217.140.101.70])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id B63863F690;
	Thu, 23 May 2019 08:08:20 -0700 (PDT)
Date: Thu, 23 May 2019 16:08:14 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Kees Cook <keescook@chromium.org>
Cc: enh <enh@google.com>, Evgenii Stepanov <eugenis@google.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Khalid Aziz <khalid.aziz@oracle.com>,
	Linux ARM <linux-arm-kernel@lists.infradead.org>,
	Linux Memory Management List <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>, amd-gfx@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org, kvm@vger.kernel.org,
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Yishai Hadas <yishaih@mellanox.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Christian Koenig <Christian.Koenig@amd.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	Leon Romanovsky <leon@kernel.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>, Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v15 00/17] arm64: untag user pointers passed to the kernel
Message-ID: <20190523150813.x4btg5zxa4gl5o4q@mbp>
References: <cover.1557160186.git.andreyknvl@google.com>
 <20190517144931.GA56186@arrakis.emea.arm.com>
 <CAFKCwrj6JEtp4BzhqO178LFJepmepoMx=G+YdC8sqZ3bcBp3EQ@mail.gmail.com>
 <20190521182932.sm4vxweuwo5ermyd@mbp>
 <201905211633.6C0BF0C2@keescook>
 <20190522101110.m2stmpaj7seezveq@mbp>
 <CAJgzZoosKBwqXRyA6fb8QQSZXFqfHqe9qO9je5TogHhzuoGXJQ@mail.gmail.com>
 <201905221157.A9BAB1F296@keescook>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201905221157.A9BAB1F296@keescook>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 22, 2019 at 12:21:27PM -0700, Kees Cook wrote:
> If a process wants to not tag, that's also up to the allocator where
> it can decide not to ask the kernel, and just not tag. Nothing breaks in
> userspace if a process is NOT tagging and untagged_addr() exists or is
> missing. This, I think, is the core way this doesn't trip over the
> golden rule: an old system image will run fine (because it's not
> tagging). A *new* system may encounter bugs with tagging because it's a
> new feature: this is The Way Of Things. But we don't break old userspace
> because old userspace isn't using tags.

With this series and hwasan binaries, at some point in the future they
will be considered "old userspace" and they do use pointer tags which
expect to be ignored by both the hardware and the kernel. MTE breaks
this assumption.

-- 
Catalin

