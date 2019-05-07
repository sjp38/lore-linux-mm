Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 63393C46460
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 17:32:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2448F20989
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 17:32:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2448F20989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CA5CD6B0005; Tue,  7 May 2019 13:32:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C557D6B0007; Tue,  7 May 2019 13:32:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B1EF86B0008; Tue,  7 May 2019 13:32:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 667496B0005
	for <linux-mm@kvack.org>; Tue,  7 May 2019 13:32:26 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id p14so5833189edc.4
        for <linux-mm@kvack.org>; Tue, 07 May 2019 10:32:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=xUFlq6ieDM/DBTmG0i31Huyc63kW9fpny2rN0ro6jaE=;
        b=Uv6/K10+NmMyziCT/iNzWgyQPWx9YngMSfxdcO1pRSrMXJmWz8xDetUsHdvAsXIe7z
         LS1SrXyePLto4hTJOw03p+V8AF6P9wT10h+P7VWcc2UJkNC/WBtifJ8lFm4NrY7uc8KP
         JaSlcKitNrW1VTlKT3TbkWPpQgl2PyTiGFaRjQVC199LYJyle9tNndttAIOMfFoUs7B1
         nhm5TsuSsJqeE3NgiEX+fWACH5xmzSnpdMTKKSlFqMduwImYJFkX5MIVV7yLy6g3Gb/P
         FmW4EKuQ9Ldba1lGzQnUtr5cEZfkVZexHw21RyCYnJUsbvFzUzTIppBdvZ8mfTtl4gHl
         xbmA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVtxEGuo33mQ8v5X4ltKDmm9oW7avuQxyr8pwHxmdDxNazB6Nk3
	MawA3IGaN7eWbaTK1u44wNMIPFY0osrNtL1wA4/SIGXF1yegLm57Nk8Efblv0C3yQnDwEwRPsfo
	gwo42m4RZ6zMvuWdxMoKAzI6g97X0LVeYHZS01EtwZHCPiTE2uaeBERgI0P/Sf+g=
X-Received: by 2002:aa7:d381:: with SMTP id x1mr35000890edq.251.1557250345947;
        Tue, 07 May 2019 10:32:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxb2UNX6GwGhUeV+GJPXtjYR2IbTOnewYQesab6O18peUX/7t11/Zruh8AjMozzS8ymWGeD
X-Received: by 2002:aa7:d381:: with SMTP id x1mr35000822edq.251.1557250345322;
        Tue, 07 May 2019 10:32:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557250345; cv=none;
        d=google.com; s=arc-20160816;
        b=QvksfPd96/orj9r4PVrcLz3v9ssp487ttira1tS3ZpktVOXykWYImyumaI18TCYFPZ
         NBTRIOTggoxKZeu2C9gQPXWFjYVknFYYJu8DQ0u+WDsq8IvvzNzk4FotOhTbQ5NN31yG
         Ya+lDPUfgLLsozOMrNJvV5prYVRidmw5PtuwsALaG2prW6lUDHjsxkW7RwxnS6M7q+Bb
         HSvqa8PXTfY3QVOeEpMy7XD8jBEABknt16m8AsnyMcampGipTiNWpQxO+roqbzSd4lVB
         o92Pf/Xg4tUpnOiH0Gj6zq+7L40rtVSe7bJs5ytGJMvuJg3haSB0r5KZjr8AA60mVPB8
         xcWQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=xUFlq6ieDM/DBTmG0i31Huyc63kW9fpny2rN0ro6jaE=;
        b=iROkN/4nFq0hU7KUrgdDwnW9n0ltuLcXH7f96cnTvK64Wm48jjw1yFKptqgWQ8ysgw
         J8otpLC+MVxztckTDGQ7D5mrwUgfwAUI0JWECiRh3jZbRFEQNirZhfLpahSDwEmquSqT
         hEm9aEfbkSqtPHavo3IRk39fNftMvYD1gRxt04KIs+DpPhofJxfzGmAN40JJT+vZ/Ijp
         QakiiP91kvostUXFLnCFJ1pTYcb0uBY1+FLI+gFQAhZtLaQc7DUo4XXXhvEo/GPXNR9y
         tq6Dlr7VsGYuEblNURSaYb+uB8bsAvgxjHELPrmGMcIMXhu6fq/swByQdHCc3etMod0Q
         QIPg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z10si6605940edl.150.2019.05.07.10.32.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 May 2019 10:32:25 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id E641BAEA3;
	Tue,  7 May 2019 17:32:24 +0000 (UTC)
Date: Tue, 7 May 2019 19:32:24 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Sasha Levin <sashal@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>,
	stable <stable@vger.kernel.org>,
	Mikhail Zaslonko <zaslonko@linux.ibm.com>,
	Gerald Schaefer <gerald.schaefer@de.ibm.com>,
	Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>,
	Dave Hansen <dave.hansen@intel.com>,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>,
	Pasha Tatashin <Pavel.Tatashin@microsoft.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Sasha Levin <alexander.levin@microsoft.com>,
	linux-mm <linux-mm@kvack.org>
Subject: Re: [PATCH AUTOSEL 4.14 62/95] mm, memory_hotplug: initialize struct
 pages for the full memory section
Message-ID: <20190507173224.GS31017@dhcp22.suse.cz>
References: <20190507053826.31622-1-sashal@kernel.org>
 <20190507053826.31622-62-sashal@kernel.org>
 <CAKgT0Uc8ywg8zrqyM9G+Ws==+yOfxbk6FOMHstO8qsizt8mqXA@mail.gmail.com>
 <CAHk-=win03Q09XEpYmk51VTdoQJTitrr8ON9vgajrLxV8QHk2A@mail.gmail.com>
 <20190507170208.GF1747@sasha-vm>
 <CAHk-=wi5M-CC3CUhmQZOvQE2xJgfBgrgyAxp+tE=1n3DaNocSg@mail.gmail.com>
 <20190507171806.GG1747@sasha-vm>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190507171806.GG1747@sasha-vm>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 07-05-19 13:18:06, Sasha Levin wrote:
> On Tue, May 07, 2019 at 10:15:19AM -0700, Linus Torvalds wrote:
> > On Tue, May 7, 2019 at 10:02 AM Sasha Levin <sashal@kernel.org> wrote:
> > > 
> > > I got it wrong then. I'll fix it up and get efad4e475c31 in instead.
> > 
> > Careful. That one had a bug too, and we have 891cb2a72d82 ("mm,
> > memory_hotplug: fix off-by-one in is_pageblock_removable").
> > 
> > All of these were *horribly* and subtly buggy, and might be
> > intertwined with other issues. And only trigger on a few specific
> > machines where the memory map layout is just right to trigger some
> > special case or other, and you have just the right config.
> > 
> > It might be best to verify with Michal Hocko. Michal?
> 
> Michal, is there a testcase I can plug into kselftests to make sure we
> got this right (and don't regress)? We care a lot about memory hotplug
> working right.

As said in other email. The memory hotplug tends to work usually. It
takes unexpected memory layouts which trigger corner cases. This makes
testing really hard.
-- 
Michal Hocko
SUSE Labs

