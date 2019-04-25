Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 87F14C282E3
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 12:37:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 02DB920678
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 12:37:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 02DB920678
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D2D7D6B0003; Thu, 25 Apr 2019 08:37:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CDCA86B0010; Thu, 25 Apr 2019 08:37:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BF3B26B0269; Thu, 25 Apr 2019 08:37:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6C0756B0003
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 08:37:58 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id 18so198857eds.5
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 05:37:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=QulxoRwNErBFGDnN9XCRDP03oURJk+3jnZ+stohPrSk=;
        b=n2ymD58Ao57EK9R68cOsRUIZCSHD4nge9zuM3guRM4FCET1R1DM4GJ7r8HDIFweerg
         ym0ZuKSdm9F2X5+oZecrzIWdUkKkwW9g/C/chI58EiRENmqpOv5CKkHltGHtvgcz843k
         +66+ZL9bI/dBCPwWh6ZJ9M10QBfy0VstKsjZQhs54P2W2F4LgMmBty/oU2CN94K6rDoy
         A3UjKAx3TgOJ2ZAUXQHunCiy4isFraerp1Vt2PUPcGHURpPnJB8tecaJmFPLF6daWUem
         A/IQujSee39nKO/EjUZ26eIESCIiIQYtwIWDr6/r5eZi/NykU1idEJItSQtO1fsKiLj6
         mOkA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUFUu2aAuaiyxzDpy6lJnXFPRC0O1+AqrI4hfLOc0qeCmA/d0Td
	AkEyIxrEbZ8VWDfy6M/wjXfcUu5jj02gv4fYBYCAvBegphvvMqOm8+h8mo4PQqpFHCfYvSPM7lP
	DoLdJGp7GAbkNYi3SsPDvV81bvgosUubLeI/ecouz27KLWLy/C03aUyAEDnMWHRg=
X-Received: by 2002:a50:9103:: with SMTP id e3mr23095683eda.217.1556195877967;
        Thu, 25 Apr 2019 05:37:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw0F4PaqDCeDVk+G5YmTR7sjH513wA+nYgetlBaXzvIukIMnOrcYicZ1vJLbhoysZPWKXi6
X-Received: by 2002:a50:9103:: with SMTP id e3mr23095645eda.217.1556195877196;
        Thu, 25 Apr 2019 05:37:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556195877; cv=none;
        d=google.com; s=arc-20160816;
        b=g6L/jNGtuN5WL/URp+Yr97p4r0wof/34h/nT+Omh9CdOCOneLo/Cc6FmOESqVbcULq
         xDwtsvczXUgr1/XE+6h/ekK+1qtqVDOjvRLlKk5XaMMCgeyL+5mftu/4uC3G3S5m6VVA
         CDRO8zoUEDpEcy9D2Y4iZWUOsT4mjUVed1r5VIyPXyGj7HXZUpGqd9GO7nCehQIu5zhE
         IM7noG/dsdNMWHZtxl1ioKBA3+zQ5sbcsDhntW4L8jaD+b3QlYRVBoTG+7bE3L0o1pPC
         bWru2tcfk9zK91EZCRlbJup+/ruVbHxH28Awy7pyCN3vkSbLRK7YfOtsac+F6hOw4YJI
         W8BQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=QulxoRwNErBFGDnN9XCRDP03oURJk+3jnZ+stohPrSk=;
        b=Z/5JCViOK2rFfS0ZcVACP9Y4swiEwrSvEzNCGsr7Bj+V0s4B4+k3dVQVwROMjguwwA
         VPwVYteKDxRZ+7AnTW7nOl7QuFBuUuo30tG0AKU2XbnHZ9gEiARJAjK2FqBmexxEmH8D
         ZyemxcVFdG+zxfUPIPP3yTXoYNukpSW+al+uaZco5YQn3tl3oSR+RAe4oz49wMAZ1l3Z
         udR3d4VENZBH4Bj6L+hUSwJ1D0CZSycgyYA7MDAV1T+kC0rYtnHY6jRGD0uj2qn3ja6S
         NaXDrwfAEfO5OrP69/Gcac1HWursMMk4Mx+qBUDFJBik3SpsIciuUP6kgWUBPvdtENd8
         REoA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i12si1648640edk.333.2019.04.25.05.37.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 05:37:57 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 6120AAC3D;
	Thu, 25 Apr 2019 12:37:56 +0000 (UTC)
Date: Thu, 25 Apr 2019 14:37:55 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Matthew Garrett <matthewgarrett@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Matthew Garrett <mjg59@google.com>, linux-api@vger.kernel.org
Subject: Re: [PATCH V2] mm: Allow userland to request that the kernel clear
 memory on release
Message-ID: <20190425123755.GX12751@dhcp22.suse.cz>
References: <CACdnJuup-y1xAO93wr+nr6ARacxJ9YXgaceQK9TLktE7shab1w@mail.gmail.com>
 <20190424211038.204001-1-matthewgarrett@google.com>
 <20190425121410.GC1144@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190425121410.GC1144@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 25-04-19 14:14:10, Michal Hocko wrote:
> Please cc linux-api for user visible API proposals (now done). Keep the
> rest of the email intact for reference.
> 
> On Wed 24-04-19 14:10:39, Matthew Garrett wrote:
> > From: Matthew Garrett <mjg59@google.com>
> > 
> > Applications that hold secrets and wish to avoid them leaking can use
> > mlock() to prevent the page from being pushed out to swap and
> > MADV_DONTDUMP to prevent it from being included in core dumps. Applications
> > can also use atexit() handlers to overwrite secrets on application exit.
> > However, if an attacker can reboot the system into another OS, they can
> > dump the contents of RAM and extract secrets. We can avoid this by setting
> > CONFIG_RESET_ATTACK_MITIGATION on UEFI systems in order to request that the
> > firmware wipe the contents of RAM before booting another OS, but this means
> > rebooting takes a *long* time - the expected behaviour is for a clean
> > shutdown to remove the request after scrubbing secrets from RAM in order to
> > avoid this.
> > 
> > Unfortunately, if an application exits uncleanly, its secrets may still be
> > present in RAM. This can't be easily fixed in userland (eg, if the OOM
> > killer decides to kill a process holding secrets, we're not going to be able
> > to avoid that), so this patch adds a new flag to madvise() to allow userland
> > to request that the kernel clear the covered pages whenever the page
> > reference count hits zero. Since vm_flags is already full on 32-bit, it
> > will only work on 64-bit systems.

The changelog seems stale. You are hooking into unmap path where the
reference count might be still > 0 and the page still held by somebody.
A previous email from Willy said
"
It could be the target/source of direct I/O, or userspace could have
registered it with an RDMA device, or ...

It depends on the semantics you want.  There's no legacy code to
worry about here.  I was seeing this as the equivalent of an atexit()
handler; userspace is saying "When this page is unmapped, zero it".
So it doesn't matter that somebody else might be able to reference it --
userspace could have zeroed it themselves.
"

I am not sure this is really a bullet proof argumentation but it should
definitely be part of the changelog.

Besides that you inherently assume that the user would do mlock because
you do not try to wipe the swap content. Is this intentional?

Another question would be regarding the targeted user API. There are
some attempts to make all the freed memory to be zeroed/poisoned. Are
users who would like to use this feature also be interested in using
system wide setting as well?
-- 
Michal Hocko
SUSE Labs

