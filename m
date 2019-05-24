Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_NEOMUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5D93C282E3
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 11:52:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 64DD720673
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 11:52:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="fj/ve63S"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 64DD720673
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B83416B0005; Fri, 24 May 2019 07:52:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B32D86B0006; Fri, 24 May 2019 07:52:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9FA9D6B0007; Fri, 24 May 2019 07:52:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4ACB46B0005
	for <linux-mm@kvack.org>; Fri, 24 May 2019 07:52:41 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id i3so13791823edr.12
        for <linux-mm@kvack.org>; Fri, 24 May 2019 04:52:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=ByWnRi5xnahJzCvKHvwWbU8X9Zsko8eu1QbpfSkepcI=;
        b=DhQGqlbEvH+/BtnS7l82Hz9G6HG5gkWq0qUqxOFSyJRHSByn26nMqJO8eN5TRtANt9
         LjXP2gPuwzlCVc8x43Rhoe7BWjRFWQs1b+DEtezkw10xZs4DxpWflAUodomugk+wunFd
         1eHRrxw75DnRJAkaUvdMzTWQL2T5ROV4/uoAMMsDVJagx/B9TmGOKD0LYEb1qGzUHbac
         +6PuTKJkEkpIK5znPn4Oa36oS7KiQM2nonktljmWlc596Tpf/BxYodlouwJVzZofmxPP
         HG4+nqbdHS6uHsSA1kF6zONZZ+27+j4anPzagB532CChVeXdS+i4FNQuuG84wcBoCqqc
         6rLA==
X-Gm-Message-State: APjAAAX6C70J7vMJUf9+wPY4eMmyzH+8oCD0Zuzz2HzcNIM6ow2xkVAI
	W2hyhResda7djywjPbO1aaEVxjcv8kdY3DrJt3NBz5SyTjCmnFNhs5oIMLtEne9Fc6BNfzdegcd
	KKKriSs1Dq1aywfWhJ86gUk5sYumHmrM7MKsh35/t7fuqlpGNzfr0nH90wNC1F5feGg==
X-Received: by 2002:a17:906:eca3:: with SMTP id qh3mr49434389ejb.139.1558698760647;
        Fri, 24 May 2019 04:52:40 -0700 (PDT)
X-Received: by 2002:a17:906:eca3:: with SMTP id qh3mr49434323ejb.139.1558698759731;
        Fri, 24 May 2019 04:52:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558698759; cv=none;
        d=google.com; s=arc-20160816;
        b=Zpt/6vncBgwN5ObjbSHnfvGCUvOulUkwuENz/4tBq37gNI3ZVplX5sco7n9qxZ87H3
         V16UITdxBcGR0+TtsDyL4Q8Sdal/7VvrKTyh3gl3YGuUNn8iEPtyGLnLF3+JM+FNnyct
         ERe31sBE/xeAa+nDmI7dxSBQh5/sgak4sFHiWplshCNy5NlJ00XokCYAoFCjQkRH5qVF
         FPLFdGy5drAba6tWlwARkmP50/FPKBYiTfLyquDMWbQRazuF4HWbwkDMH07OEkds3qG+
         hOEcOQfvoFdaqWTa/sT0+XJ9gtf7OU7BS1QEqtn2djfS9d5uunumtFstT62UdfbROX2G
         9n7Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=ByWnRi5xnahJzCvKHvwWbU8X9Zsko8eu1QbpfSkepcI=;
        b=uHafgdD6/qZAWMgvVB/xXX3xoP9GNrvZaviOftdG18Lw28AbO6RyHrJvXC3WiBAYja
         H80C1XrVlazs8X77suMF5AkWl4IpXvEnwz89Znhrton38Bdjgv7hnC79NHD+fMnFWnqc
         IIyOioRzVkic4o9sBqz/nhXxdEbuyN25Cox3mJr+WJuuchQMov0pxreCS+9HykSLK68U
         m3I6qYKsHkdpjfCBH7NXvoB9mk1DMPvxWJk6BjYY0ESPncitnSJ1ZuYq8VBvRwOq2h25
         42zVnFAnyU2rsV2k0IZg1dm6/onX2PINuzK0DKNMxUJg5TaF/qQ4TWvlvssnfSc6tkg/
         ztMA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b="fj/ve63S";
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g14sor674017ejw.48.2019.05.24.04.52.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 24 May 2019 04:52:39 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b="fj/ve63S";
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=ByWnRi5xnahJzCvKHvwWbU8X9Zsko8eu1QbpfSkepcI=;
        b=fj/ve63SAS6LbkLj3/2xSc53dNUmA1kW4LO4gSD8p2pPsVcJ9mLN+PvcWiX5chYCXi
         FwvB06ka0Un2UzcVw5StRa2fV3jOhanfDBaa2eLmuewTaYIk8Nyh2G/FBud9KdNKUPgD
         BnxdtzszrHmfqrRG6uZekWuGnfjzPJrl4G2hrnGkkSsXmhH/cL5dq4U7IQYqfuSQUa9q
         RoO0oAnWL3q712yci1RgE/ECkQYR0eHQ7n277ogD1Y/aDZ4+t4XeirJcK65N2OuHolOa
         gtM+Nl6z8WIZHPK/9i/SanpcCLzXIlgQ3an9r/HSECyPuRkRdPMF5GypCCnheChJ6uIc
         +cMg==
X-Google-Smtp-Source: APXvYqy+YBb8phwRTTasGpoCAhen7qTO3dYqvPQ/V2KcTvAargF0eTRh095ZIIytNdKz6fMRQTOaDg==
X-Received: by 2002:a17:906:2447:: with SMTP id a7mr1078163ejb.235.1558698759336;
        Fri, 24 May 2019 04:52:39 -0700 (PDT)
Received: from box.localdomain (mm-192-235-121-178.mgts.dynamic.pppoe.byfly.by. [178.121.235.192])
        by smtp.gmail.com with ESMTPSA id l19sm683637edc.84.2019.05.24.04.52.38
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 May 2019 04:52:38 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 1BED8102F25; Fri, 24 May 2019 14:52:39 +0300 (+03)
Date: Fri, 24 May 2019 14:52:39 +0300
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
Message-ID: <20190524115239.ugxv766doolc6nsc@box>
References: <155836064844.2441.10911127801797083064.stgit@localhost.localdomain>
 <20190522152254.5cyxhjizuwuojlix@box>
 <358bb95e-0dca-6a82-db39-83c0cf09a06c@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <358bb95e-0dca-6a82-db39-83c0cf09a06c@virtuozzo.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 24, 2019 at 01:45:50PM +0300, Kirill Tkhai wrote:
> On 22.05.2019 18:22, Kirill A. Shutemov wrote:
> > On Mon, May 20, 2019 at 05:00:01PM +0300, Kirill Tkhai wrote:
> >> This patchset adds a new syscall, which makes possible
> >> to clone a VMA from a process to current process.
> >> The syscall supplements the functionality provided
> >> by process_vm_writev() and process_vm_readv() syscalls,
> >> and it may be useful in many situation.
> > 
> > Kirill, could you explain how the change affects rmap and how it is safe.
> > 
> > My concern is that the patchset allows to map the same page multiple times
> > within one process or even map page allocated by child to the parrent.
> > 
> > It was not allowed before.
> > 
> > In the best case it makes reasoning about rmap substantially more difficult.
> > 
> > But I'm worry it will introduce hard-to-debug bugs, like described in
> > https://lwn.net/Articles/383162/.
> 
> Andy suggested to unmap PTEs from source page table, and this make the single
> page never be mapped in the same process twice. This is OK for my use case,
> and here we will just do a small step "allow to inherit VMA by a child process",
> which we didn't have before this. If someone still needs to continue the work
> to allow the same page be mapped twice in a single process in the future, this
> person will have a supported basis we do in this small step. I believe, someone
> like debugger may want to have this to make a fast snapshot of a process private
> memory (when the task is stopped for a small time to get its memory). But for
> me remapping is enough at the moment.
> 
> What do you think about this?

I don't think that unmapping alone will do. Consider the following
scenario:

1. Task A creates and populates the mapping.
2. Task A forks. We have now Task B mapping the same pages, but
write-protected.
3. Task B calls process_vm_mmap() and passes the mapping to the parent.

After this Task A will have the same anon pages mapped twice.

One possible way out would be to force CoW on all pages in the mapping,
before passing the mapping to the new process.

Thanks,
Kirill.

