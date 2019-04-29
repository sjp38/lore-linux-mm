Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6DC69C43219
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 21:45:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 37A3F2067D
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 21:45:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 37A3F2067D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ABA7C6B000E; Mon, 29 Apr 2019 17:45:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A6A4F6B0010; Mon, 29 Apr 2019 17:45:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9801F6B0266; Mon, 29 Apr 2019 17:45:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4A57E6B000E
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 17:45:03 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id p26so5416217edy.19
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 14:45:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=i5aiNtFTFcmxdxwrKzK0L0MXrkvsougNq80KlI7MAxs=;
        b=AglYi2pAxgC5SvrnRQ009FVyDJTQKSxqDOpByFxkC70hf0BS4OwvZLYyIVdzF+Zj8i
         7iNCs4/E0O5e5D3GwRUR+3YssquP/20iBBDzEIo76UJs/sFWCWWDIprCvtdLU9SLZte1
         QzN9WKt2Y8GYLe33mnAhB1p7I06eJ8EEH1d2WwBSdDfOZRagxfALr2mboQL6aDoYXeOe
         eaflcHSNOGjXwf90haCGds32jZRILntIEoZEif7GMzHF5oR6XOJQeV26asDtDXfEb6mE
         qWH8Y8BulQHMUBiI3cGGNlDTS3ffFo0QBmOsJSDhrkf4EdH1N44UGtDKHq+gcbIvYmCp
         geIw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAV+SehHekiw7Cj8eY9uedYCAMMoZ/UwXEBqj8QZB0j2WYfIFrB0
	CBLDmZQSDKTQfpGKCwrhVCJNwi0fIXbXrw20V+0JVfmfc1LlFw14dRwZjqXrZKb75kYOmMK5IfZ
	xc79N/FvJHKz+uvd+OqSYle+XONyrnbi8QZTjM/QtBFJ37Z+1j6eORxV3lCeERzc=
X-Received: by 2002:a17:906:5c0f:: with SMTP id e15mr5813079ejq.151.1556574302817;
        Mon, 29 Apr 2019 14:45:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzue9ukEG1tqWp3TrLW1yIOhFLO2a8rS8DmAeSyjbHU097KIZ76+TGmtpTQDchqDclx8yAo
X-Received: by 2002:a17:906:5c0f:: with SMTP id e15mr5813062ejq.151.1556574301971;
        Mon, 29 Apr 2019 14:45:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556574301; cv=none;
        d=google.com; s=arc-20160816;
        b=Vg8suBZve2ETRoIinw9VcfwtTYgNaAZPciO2WfdJ3GBKkgInID35gOnEP0R75lWSb8
         zOWWOeZvNGpObfq688JC3ha2a8tubvcpdonQnUWRwprpwzYezfgVr+bMPbzbPO7eigk/
         U3RC9y9BmkFlDZ02dFjp7+Bz+THl3tCCiFi8Zr8uSyRtJpqNpBs0YYflzIGYFGOgIHTe
         636+9oULt2QFanIgAbIU8Qs+dVB86Hwb5TvQGTV26T3LMRfzZsBjcOHPaOGietnPYej8
         0Fe+DgwYFVou1KYVtWKEIXCpPHscZOZVpBWjfJSALarvLKTVKJ1q86y4hyFhIis7gDQL
         sAiQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=i5aiNtFTFcmxdxwrKzK0L0MXrkvsougNq80KlI7MAxs=;
        b=SE2DVaZFuVsbKZ8wy/U/6GO1ayn5sfaZyupUpbR4Gwp6MpGyxYWT4uAHYLVRubShCA
         lPLu67Kp+LVFK8OH69SxIIcZmMOXTHTOYFnmfP5PvAoRdS7KxW8TwZSXSIceGgCskAZ+
         BDIo6hF8fOJAb0VPVnTWESe/HYYMO5bzNLJ8+otCek8yMh6e4PHa5XIVETHuEHLFVKKF
         Zb02RZq2SsM3KN1pJZPQcZCuNBYeZ8/+IUVV4pTXIlcNPyh6OZ5SxHmaDjbbFSyAuJrr
         kbNz1rKD5JFYFHjtDJqHrTmNjnfqIhIwKYRTW7B/xUiat2EntvBOn82gaUYJ9lfy0HnD
         wS2Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t50si6012717edd.451.2019.04.29.14.45.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Apr 2019 14:45:01 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 95B8DABD7;
	Mon, 29 Apr 2019 21:45:01 +0000 (UTC)
Date: Mon, 29 Apr 2019 17:44:58 -0400
From: Michal Hocko <mhocko@kernel.org>
To: Matthew Garrett <mjg59@google.com>
Cc: linux-mm@kvack.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux API <linux-api@vger.kernel.org>
Subject: Re: [PATCH V2] mm: Allow userland to request that the kernel clear
 memory on release
Message-ID: <20190429214458.GB3715@dhcp22.suse.cz>
References: <CACdnJuup-y1xAO93wr+nr6ARacxJ9YXgaceQK9TLktE7shab1w@mail.gmail.com>
 <20190424211038.204001-1-matthewgarrett@google.com>
 <20190425121410.GC1144@dhcp22.suse.cz>
 <20190425123755.GX12751@dhcp22.suse.cz>
 <CACdnJuutwmBn_ASY1N1+ZK8g4MbpjTnUYbarR+CPhC5BAy0oZA@mail.gmail.com>
 <20190426052520.GB12337@dhcp22.suse.cz>
 <CACdnJutweLKsir_r9EgP9g=Eih-hbhq20N8zHzKawR8=awnENw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACdnJutweLKsir_r9EgP9g=Eih-hbhq20N8zHzKawR8=awnENw@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 26-04-19 11:08:44, Matthew Garrett wrote:
> On Thu, Apr 25, 2019 at 10:25 PM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Thu 25-04-19 13:39:01, Matthew Garrett wrote:
> > > Yes, given MADV_DONTDUMP doesn't imply mlock I thought it'd be more
> > > consistent to keep those independent.
> >
> > Do we want to fail madvise call on VMAs that are not mlocked then? What
> > if the munlock happens later after the madvise is called?
> 
> I'm not sure if it's strictly necessary. We already have various
> combinations of features that only make sense when used together and
> which can be undermined by later actions. I can see the appeal of
> designing this in a way that makes it harder to misuse, but is that
> worth additional implementation complexity?

If the complexity is not worth the usual usecases then this should be
really documented and noted that without an mlock you are not getting
the full semantic and you can leave memory behind on the swap partition.

I cannot judge how much that matter but it certainly looks half feature
to me but if nobody is going to use the madvise without mlock then it
looks certainly much easier to implement.
-- 
Michal Hocko
SUSE Labs

