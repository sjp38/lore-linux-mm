Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CE0E2C43381
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 16:59:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8AA9F20857
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 16:59:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8AA9F20857
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 33A158E0004; Fri,  1 Mar 2019 11:59:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2EB378E0001; Fri,  1 Mar 2019 11:59:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 202308E0004; Fri,  1 Mar 2019 11:59:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id BBF708E0001
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 11:59:18 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id h37so8658650eda.7
        for <linux-mm@kvack.org>; Fri, 01 Mar 2019 08:59:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=FOUGz1ICVnNqYtnbV0Q7jJXXd1UcUGnj1080uMWB6yo=;
        b=It3JbJB54ZaIplVbZrwF8iv0A5FP/CNuPgmOC1u8NMpYOLzVj+1+pAF9/CVipzErk9
         SUVNV3r9El6yCZBST0R0fp+R6kiw0iXUwx1Kj7vK2sZa61ZsM1uEzEp1Rf/kkDQI+9xF
         mjZoC/uM+HAB+DHWbdTbT4QjfGa6DMMjluRtCT+u426OZ8LZhUMa0gV5lmtxC/cQDxQs
         KTv+aRgfw2pMSvAEVB3tLpDuoOqICLurWWGeCg8Vbkhw/YlaY7N2GsUi9asscuRdyQJ0
         MBWMvPXfz/2y3vMslnxURQmsrlOpzvUnNqaWs3kl9uQlvvWtHSzm9Z7KMsNpdfP7tdLb
         24RA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAXolgjowKh93JT1VzUF3Al2k3qUSQTrLL1Q6Lf2ZzztNxaRCypo
	9Vkb+6C4K4DCFjbwDv7Jb4pwmv/cdN/Cd+wjDp/lrcWV7hFIhRQRpZekxWzOFTv+DsAcE2mBdu/
	daU0eKIdDnfbiSkjVucTaO4G3Jv7Jy6c6apAZSRNxqBTJYaZU3svEEQkhz6BtEhdjDQ==
X-Received: by 2002:a50:b3cd:: with SMTP id t13mr4998643edd.150.1551459558340;
        Fri, 01 Mar 2019 08:59:18 -0800 (PST)
X-Google-Smtp-Source: APXvYqzGGK71ypbBtDkl1mLkwspXXIQc6oMnXbBWOG0A3HJgQhc3y9g2pqjaArxBvkh9DkhIJzR+
X-Received: by 2002:a50:b3cd:: with SMTP id t13mr4998571edd.150.1551459556935;
        Fri, 01 Mar 2019 08:59:16 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551459556; cv=none;
        d=google.com; s=arc-20160816;
        b=fvSa8gzPrC+/aJcAssyaGxu1lekOgLCBJBEPQSYfS4Xb2g1wqcDVzTBUD2M0zEqX8S
         EauFrpMON60UXcMrkFT4S/MU4Hk6ILsj6lJ2m65DzfZ83M/vsv8X34jj3kh2QJHYthTQ
         nEM6QFe+jjHcX3IKAnpjmxEo8tqSviLHAXznTklAQ6IVN/hL+Zn/vpXk09Wq4OiJiO/C
         8tPg1jvUaMPNQDOdR6FOoIAdictcs9MYvbvp8cOhZhAd4pqsd9doPEpBPZbAd+2gdpMk
         SkePN9deWgGEIeSLt6ryMmdwH+czct1Z56kS+E02P2aCs42P8qdRKGbXBmgwEUElNAdJ
         YWUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=FOUGz1ICVnNqYtnbV0Q7jJXXd1UcUGnj1080uMWB6yo=;
        b=YB+oRZmH4z7yNeSk3X1sXULTf4WJ/Wa2zxIH+Sp1Ll2aJDjL9t/j93KCnWeIpQiYmk
         Pq77VgFUJJmkagEZbXv5mzaeNyqrxhRgxUCeb71++HnJ7xWieHLuywFJPF71RnZM9PX+
         oMSTz542nUmYxPeAgGxQTKrlq19id4j+X2+W7cXDAeVMvUtGLrJov/m+zCHnQweTbNC9
         5D+vuv/gF1KaPlLfI1CaE1aULhJCKwMGKeT/xMsikAEYficARw4bMv8MHAc5IQjLMTXs
         WgH/1u39s9xPpHF3Tni1GLV6jVuAPboqSqWA8t54oH1I0IBH1QWqmOnenSRY+4vva+z7
         fJsw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id v20si602306edm.292.2019.03.01.08.59.16
        for <linux-mm@kvack.org>;
        Fri, 01 Mar 2019 08:59:16 -0800 (PST)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id D6B7080D;
	Fri,  1 Mar 2019 08:59:15 -0800 (PST)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 0CD8F3F575;
	Fri,  1 Mar 2019 08:59:10 -0800 (PST)
Date: Fri, 1 Mar 2019 16:59:08 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Kees Cook <keescook@chromium.org>,
	Kate Stewart <kstewart@linuxfoundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ingo Molnar <mingo@kernel.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Shuah Khan <shuah@kernel.org>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Linux ARM <linux-arm-kernel@lists.infradead.org>,
	"open list:DOCUMENTATION" <linux-doc@vger.kernel.org>,
	Linux Memory Management List <linux-mm@kvack.org>,
	linux-arch <linux-arch@vger.kernel.org>,
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Chintan Pandya <cpandya@codeaurora.org>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v10 07/12] fs, arm64: untag user pointers in
 fs/userfaultfd.c
Message-ID: <20190301165908.GA130541@arrakis.emea.arm.com>
References: <cover.1550839937.git.andreyknvl@google.com>
 <8343cd77ca301df15839796f3b446b75ce5ffbbf.1550839937.git.andreyknvl@google.com>
 <73f2f3fe-9a66-22a1-5aae-c282779a75f5@intel.com>
 <CAAeHK+yQU8khtOoyDKqmHterCa16P7oWe9AMiPnrxE+Gyb_7aw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAeHK+yQU8khtOoyDKqmHterCa16P7oWe9AMiPnrxE+Gyb_7aw@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 26, 2019 at 03:39:08PM +0100, Andrey Konovalov wrote:
> On Sat, Feb 23, 2019 at 12:06 AM Dave Hansen <dave.hansen@intel.com> wrote:
> >
> > On 2/22/19 4:53 AM, Andrey Konovalov wrote:
> > > userfaultfd_register() and userfaultfd_unregister() use provided user
> > > pointers for vma lookups, which can only by done with untagged pointers.
> >
> > So, we have to patch all these sites before the tagged values get to the
> > point of hitting the vma lookup functions.  Dumb question: Why don't we
> > just patch the vma lookup functions themselves instead of all of these
> > callers?
> 
> That might be a working approach as well. We'll still need to fix up
> places where the vma fields are accessed directly. Catalin, what do
> you think?

Most callers of find_vma*() always follow it by a check of
vma->vma_start against some tagged address ('end' in the
userfaultfd_(un)register()) case. So it's not sufficient to untag it in
find_vma().

-- 
Catalin

