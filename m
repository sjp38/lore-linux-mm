Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 800DFC7618F
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 16:40:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4646521849
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 16:40:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4646521849
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BC76A8E0006; Thu, 18 Jul 2019 12:40:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B77C08E0005; Thu, 18 Jul 2019 12:40:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A3FC18E0006; Thu, 18 Jul 2019 12:40:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 57A7E8E0005
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 12:40:47 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id c31so20336212ede.5
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 09:40:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Da3G7LpOehglJSLF7wForjwsDEQFbruvA+yCYqnq9VA=;
        b=aLv1B5gA5Nn6VzMZ8oMJVSYRReAztczXQV3IU3IcvXF4/2Tkyl8+h+kc622j6zn4CC
         uDo0z1QJmY6ic1CCK5gEPNM+PUblLfEAlBIX3aW8OTCOcAwsmcdmshyA4po6s+JCjMwg
         KbfscHqjzyVaCz7Q1p/OKcoYn+zzuTt/FdhzwpepYdbHqQSMCpUxde0QNLyT1oX2U8Ff
         zQhKvVkA5T4L7tE5QQQOUMYzBHvu/hFAV+NgxLVpcnVltIb+b1+QpfkB+Z5ffvUCSgNI
         tNCO+OJJPKEdIk++WFHW9ian4w4YonWSyLx/ox9yMoWPVQDl67tKZYqZfjQZLZQTa26P
         AERg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAW0pqQY8HfImgwVHrYU3XvvWIPUFPw81jMmjy7FXvHWg0M8uAX4
	b5T1sKUFTEgxahrERhwCdp6Y2Mfaq7WtPmnUyViPRemeKQZIQ3//z9jqGIARTSrGvxColqBgJL1
	nFOnqhZitrqtlSb5moX9Jq9K5/JecUwY8fm2ui6yltJa7WkhB8mngNP31dgS9fT0=
X-Received: by 2002:a50:9468:: with SMTP id q37mr41197911eda.163.1563468046911;
        Thu, 18 Jul 2019 09:40:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxC0l9N9WI0hkOwzwPHfA/dDt8ZF+niUeEb+kcJxG+70lvNXXgmbRu/Mota2Ro95qoUtPGG
X-Received: by 2002:a50:9468:: with SMTP id q37mr41197837eda.163.1563468046029;
        Thu, 18 Jul 2019 09:40:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563468046; cv=none;
        d=google.com; s=arc-20160816;
        b=i59/lSleZCJ2U857Pt4POa1APAGy6tg0MtN6R0l8Np0IOU7hwzjR9R40vTkZnCaVeH
         wtuupBtLzInRZ/bCJ/+GK/OdNRMwAI5fF/+itGPDWrlW7Jjz6tZouPpsAJKctsGVbtQd
         GjnGnBfd46dmDpJ5IZVegCQA0C7tZzReJ++GoPX2Ayl3JV0g5KyHgMNGgFThhLyovO9U
         LoeaA75MIsAR2lSjIb2oIep7mPOKhvCFTqoKjYgi4PNky1HTTB5sRkPCuFPoShqcLUi5
         pCjbeLlnu7ycLf01ZAzdUhMrEySrQasXrV+fmmdV0YyqJPNhqWuSxM1Q2jxQwtLqtUzS
         H1iA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Da3G7LpOehglJSLF7wForjwsDEQFbruvA+yCYqnq9VA=;
        b=UT5BEAm9q4Mm33xeQlbaXSr2bCW2m0uFRxRLR9HHIUjNllwmYA81nB/aapYp5+Qc7d
         zIUu38tZsje7cmYbJqCs5XYuhcyN1kOyGA8focJEsqjZ++x4igDPjf1wzlpw2r/SxsHq
         hoaWpDNqICTMPlMP8pAa2co9te0tFTnqrUp7yG/ByjjpnkjkvJBwVHJML/tHJ6O3iIh6
         Mst0EbstUXtfOjmuXrI4v/EZUTMSvEPX1ednUe1sWjHO3bUT+iopwUp1x7CKvCymL26l
         qychUs6+OmgOruBZepFoykhEK4jVH3Nkb/0CN/A4MC8HQJ2hXAIPUublXbQ1rYUrz09F
         FZcw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e52si18212ede.345.2019.07.18.09.40.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 09:40:46 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id F0A6CAD07;
	Thu, 18 Jul 2019 16:40:44 +0000 (UTC)
Date: Thu, 18 Jul 2019 18:40:43 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Leonardo Bras <leonardo@linux.ibm.com>,
	Oscar Salvador <osalvador@suse.de>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Pavel Tatashin <pasha.tatashin@oracle.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Pasha Tatashin <Pavel.Tatashin@microsoft.com>,
	Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: Re: [PATCH 1/1] mm/memory_hotplug: Adds option to hot-add memory in
 ZONE_MOVABLE
Message-ID: <20190718164043.GE30461@dhcp22.suse.cz>
References: <20190718024133.3873-1-leonardo@linux.ibm.com>
 <1563430353.3077.1.camel@suse.de>
 <0e67afe465cbbdf6ec9b122f596910cae77bc734.camel@linux.ibm.com>
 <20190718155704.GD30461@dhcp22.suse.cz>
 <CA+CK2bBU72owYSXH10LTU8NttvCASPNTNOqFfzA3XweXR3gOTw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+CK2bBU72owYSXH10LTU8NttvCASPNTNOqFfzA3XweXR3gOTw@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 18-07-19 12:11:25, Pavel Tatashin wrote:
> On Thu, Jul 18, 2019 at 11:57 AM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Thu 18-07-19 12:50:29, Leonardo Bras wrote:
> > > On Thu, 2019-07-18 at 08:12 +0200, Oscar Salvador wrote:
> > > > We do already have "movable_node" boot option, which exactly has that
> > > > effect.
> > > > Any hotplugged range will be placed in ZONE_MOVABLE.
> > > Oh, I was not aware of it.
> > >
> > > > Why do we need yet another option to achieve the same? Was not that
> > > > enough for your case?
> > > Well, another use of this config could be doing this boot option a
> > > default on any given kernel.
> > > But in the above case I agree it would be wiser to add the code on
> > > movable_node_is_enabled() directly, and not where I did put.
> > >
> > > What do you think about it?
> >
> > No further config options please. We do have means a more flexible way
> > to achieve movable node onlining so let's use it. Or could you be more
> > specific about cases which cannot use the command line option and really
> > need a config option to workaround that?
> 
> Hi Michal,
> 
> Just trying to understand, if kernel parameters is the preferable
> method, why do we even have
> 
> MEMORY_HOTPLUG_DEFAULT_ONLINE

I have some opinion on this one TBH. I have even tried to remove it. The
config option has been added to workaround hotplug issues for some
memory balloning usecases where it was believed that the memory consumed
for the memory hotadd (struct pages) could get machine to OOM before
userspace manages to online it. So I would be more than happy to remove
it but there were some objections in the past. Maybe the work by Oscar
to allocate memmaps from the hotplugged memory can finally put an end to
this gross hack.

In any case, I do not think we want to repeat that pattern again.
-- 
Michal Hocko
SUSE Labs

