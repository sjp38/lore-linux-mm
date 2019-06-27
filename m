Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EC17DC48BD6
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 08:10:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A8EFB2064A
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 08:10:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A8EFB2064A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 437788E0005; Thu, 27 Jun 2019 04:10:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3E7CA8E0002; Thu, 27 Jun 2019 04:10:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2AF8B8E0005; Thu, 27 Jun 2019 04:10:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id D3CE18E0002
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 04:10:32 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id o13so5440475edt.4
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 01:10:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=OvkpaT13+U9RC+12hlu8+eTrBlFQ6hiinJeT+5oS8VA=;
        b=qTbDR/l89FEZR8Gw5Ck0bZAvI6xaMTj9u51ttTJvxzaPb/z/wvGuwbf1Jaos+zVcJp
         G4EOT3NM4JLOHPV+BIx8szhnEBZhx6iVO1/p1md4i1/796Kq+tIAgxh8s6Jh2zkkgsV+
         7I4smtloJJxd7e3504CCvrMdEa9cTgwBk+jGncqJ12z4PXO0cK9T6NvVEdjR9Msd0USG
         lJ+lji2+oNG2whgF1+R1X0RwmCPs8xNTDmDLY4/EsHYdWwWhLimfvInZ1QE+fFM14j2D
         2twOIGTAM/1Eoiefr2z1O2vSYGlkHjm63wIoVx6EnrVsZUWS+euQGfTGVPTHk6JTvtE7
         Qhtw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWc4LjUZ2YmMnH6L9d7aOlKrdsn+BZuekj80Zer9Qg1SnNCg4Rj
	eD6CEnLM8PGbU8Te01E9yYE0MMz/wvfaYBPnrETT6RWGcIgmpeTS4OqSuszuXQJR1qjGnPxVDPH
	RJqxWsGyxwZtoNjdOsR3dyTgq96wo67TytIrcTtycdOpX/QvHNMF9V4It5EvvXC0=
X-Received: by 2002:a17:906:4a10:: with SMTP id w16mr1850436eju.299.1561623032308;
        Thu, 27 Jun 2019 01:10:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyI6JtzwxINwFAa8TF6kZyDjLuvaK+zr0t2BGuumbZa8zL1TLZn1kPyCoj0R2gFEEXpHD+M
X-Received: by 2002:a17:906:4a10:: with SMTP id w16mr1850393eju.299.1561623031477;
        Thu, 27 Jun 2019 01:10:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561623031; cv=none;
        d=google.com; s=arc-20160816;
        b=hy3yltkoCb8opdcq1gyi5wznO/TvvC4r+gpo0Z50KeSoWMW9B0TJCSvQEbC8Ivgtzp
         1ZxNOhyNLKgcWBtZ4nO8AQ9Ov8EhbGDeYVV0XVLWUyJtZ13dPwhDFkyOJF2gO9aa4pgR
         frr7ZH7RjJbGgMiseumFq158UKW/yOvn0q0JiOYR35NCxCyuZj94cTV6yJrXdRaEW9Nd
         c1VEDw9K/6DKOqLvA6BeYBKaE/ie39TYRToDkxkv7Z4TfQJXgE92mwvePaSrvT0d4RfI
         zFhpE8MZb77E79AnToslhgN5MSw/l2Di8B2BiDPJegPHJBPaSvHz1cNTjEs3Mke1r2U1
         UjHQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=OvkpaT13+U9RC+12hlu8+eTrBlFQ6hiinJeT+5oS8VA=;
        b=uSEB55mjylPVIIRR9GauUUYKQimmtxLOqmB4R6k1INRp85hZW/t22mdD1vaNsgfkAq
         pZG0tOrs6s3x5O3NNOf/FiXROVlZqQNcNbADtvU+Lcx7wKCjP6vaszYfBgTqx55sgGFX
         yGJ5Tepn5a/E5uaXYAS1J5S1ksB/Bnr08XG0kJ82/D33DEvaDxSvjBrc98qtbaY9lUlx
         BdlellX6ZO7Bj/+7Ld8+uZFKtoCGdCr6VUoyxq9OwMpaoNTT9SHKWF4Lnb0NsEsRNgip
         TifludEQM3AUg5w7+q+e+aa8NVy0vI1B4t+0X+eSfXXQ7lQ/W4mV/pbBq4FbiMF84w7S
         7PBA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i14si923078ejr.299.2019.06.27.01.10.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jun 2019 01:10:31 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id CEFC3AF3E;
	Thu, 27 Jun 2019 08:10:30 +0000 (UTC)
Date: Thu, 27 Jun 2019 10:10:29 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Alastair D'Silva <alastair@d-silva.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Pavel Tatashin <pasha.tatashin@oracle.com>,
	Oscar Salvador <osalvador@suse.de>,
	Mike Rapoport <rppt@linux.ibm.com>, Baoquan He <bhe@redhat.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Logan Gunthorpe <logang@deltatee.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH v2 1/3] mm: Trigger bug on if a section is not found in
 __section_nr
Message-ID: <20190627080724.GK17798@dhcp22.suse.cz>
References: <20190626061124.16013-1-alastair@au1.ibm.com>
 <20190626061124.16013-2-alastair@au1.ibm.com>
 <20190626062113.GF17798@dhcp22.suse.cz>
 <d4af66721ea53ce7df2d45a567d17a30575672b2.camel@d-silva.org>
 <20190626065751.GK17798@dhcp22.suse.cz>
 <e66e43b1fdfbff94ab23a23c48aa6cbe210a3131.camel@d-silva.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e66e43b1fdfbff94ab23a23c48aa6cbe210a3131.camel@d-silva.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 27-06-19 10:50:57, Alastair D'Silva wrote:
> On Wed, 2019-06-26 at 08:57 +0200, Michal Hocko wrote:
> > On Wed 26-06-19 16:27:30, Alastair D'Silva wrote:
> > > On Wed, 2019-06-26 at 08:21 +0200, Michal Hocko wrote:
> > > > On Wed 26-06-19 16:11:21, Alastair D'Silva wrote:
> > > > > From: Alastair D'Silva <alastair@d-silva.org>
> > > > > 
> > > > > If a memory section comes in where the physical address is
> > > > > greater
> > > > > than
> > > > > that which is managed by the kernel, this function would not
> > > > > trigger the
> > > > > bug and instead return a bogus section number.
> > > > > 
> > > > > This patch tracks whether the section was actually found, and
> > > > > triggers the
> > > > > bug if not.
> > > > 
> > > > Why do we want/need that? In other words the changelog should
> > > > contina
> > > > WHY and WHAT. This one contains only the later one.
> > > >  
> > > 
> > > Thanks, I'll update the comment.
> > > 
> > > During driver development, I tried adding peristent memory at a
> > > memory
> > > address that exceeded the maximum permissable address for the
> > > platform.
> > > 
> > > This caused __section_nr to silently return bogus section numbers,
> > > rather than complaining.
> > 
> > OK, I see, but is an additional code worth it for the non-development
> > case? I mean why should we be testing for something that shouldn't
> > happen normally? Is it too easy to get things wrong or what is the
> > underlying reason to change it now?
> > 
> 
> It took me a while to identify what the problem was - having the BUG_ON
> would have saved me a few hours.
> 
> I'm happy to just have the BUG_ON 'nd drop the new error return (I
> added that in response to Mike Rapoport's comment that the original
> patch would still return a bogus section number).

Well, BUG_ON is about the worst way to handle an incorrect input. You
really do not want to put a production environment down just because
there is a bug in a driver, right? There are still many {VM_}BUG_ONs
in the tree and there is a general trend to get rid of many of them
rather than adding new ones.

Now back to your patch. You are adding an error handling where we simply
do not expect invalid data. This is often the case for the core kernel
functionality because we do expect consumers of the code to do the right
thing. E.g. __section_nr already takes a pointer to struct section which
assumes that this core data structure is already valid. Adding a check
here adds an unnecessary overhead so this doesn't really sound like a
good idea to me.
-- 
Michal Hocko
SUSE Labs

