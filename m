Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4546AC169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 10:15:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 13A91218DE
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 10:15:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 13A91218DE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AC4F78E0002; Thu, 31 Jan 2019 05:15:31 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A75118E0001; Thu, 31 Jan 2019 05:15:31 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 98A8D8E0002; Thu, 31 Jan 2019 05:15:31 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4226B8E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 05:15:31 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id b3so1129323edi.0
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 02:15:31 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=q44yXp2qtyMLV0reBS5F6bb3hI7xFpLPdhkhjxqtFv8=;
        b=WSWNM5mm0RA7aDaeariOeditm6AVT4I2MHj5+o8FT7ylkzODipmdr1DHidSEmgcAZh
         MrrCHx7fdsxUUWeXM5dEEdzb2CYpwOWct5cBlEaHnaW+gOZCLCxiuyht/DnKySFJo8Vd
         gSXETMIgPd40wRx9Xy+UYFwnlaBK63gPp7I0Vu165WILiik1dqbWnTTay5CPvkknh+CN
         oIVdrtgP7eq6vtvzaFo1eUvh1W7JA4jXAZFTn2yvwfGQ2fv/4URetS5wNb+bmK9c4EFP
         x0xG3WpoXhrQYGDUlkmHeffA2T6vN1tWxf0nl50aCA9HzVP/CejH1qBu7y1aX0iRsldQ
         Bxxw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=jikos@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukeDUaqOm0gtMuLjh3OekXwFot2TZ++PiWqmRH7np4+Myv0+yuwi
	rCuEBiVTk4gukSOYGe0UJOmDLl0qp3rqSJIXj667XuWQAgkKCEaah5yz71sJ8LHdNJJfX6eZAyX
	6K90F9JK9m8NZ3dM9IZSi6fC/MN6a2FubNeYCTuS1accjU0ZfBkovuiHNoI2Jy4w=
X-Received: by 2002:a50:94f4:: with SMTP id t49mr34003070eda.24.1548929730845;
        Thu, 31 Jan 2019 02:15:30 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5VrFGIdTpc6V02H2NAA1HXB4klfO8meP9VdV2AOyCTChNKA+EkLQ2JdWlqL2iptoXfjbBQ
X-Received: by 2002:a50:94f4:: with SMTP id t49mr34003032eda.24.1548929730083;
        Thu, 31 Jan 2019 02:15:30 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548929730; cv=none;
        d=google.com; s=arc-20160816;
        b=oBAnoRk7qJK5fW4nScITW779JnzKmeneIbJpmcN1x0puhiz7nzltRw2N4vCY48pJ68
         JmwztB6jksSKvI3IzRST5Dtt0RyEjKlVninmTTDa9tu6z0+HJ8o4TcUa4X3IOAFJNyGV
         q+rcVArAPaNLJgXvo/pl6mJakMgr0VMWLrUbaMm1sjmgguF/Kriv6rkk4pX/ehaNBtcU
         tPGx+cf4Apf5VDI3ctuqebiOoE4VnY0RhoaHvsMwiL9Wh06M9pJu6u3UZiPSYuNssnGm
         ggWvvrcJb/0FjH0TtG2+3hi0WQino17r0hWhUpdb3itU7/J1KBuAL4xUGwW+UJYyFVUP
         JkOw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=q44yXp2qtyMLV0reBS5F6bb3hI7xFpLPdhkhjxqtFv8=;
        b=O22kIDQ2uw//esZaQg5wrZNrUD3/UuAcyRnpLVmyk/NMY/yhaMu+dGWEoRbILWHa0v
         2BO1LGHuFvsWdCwyMplEEZm882K3CIcH9oXoKfMi8a15u1AQFRl2yTShXpm/wyt5RIK6
         2XpHlJydlftmbbMnMqo/+7j3G88j4/hIgC+2J3i2/3J7H/q3+w+qJPBgmDNabw45kJBn
         hvQLk7RpmOUzVAhafm7TsrAhegJ9aXu1z9oBLAC0CwQFh762/86GgXzsBGzHLwl+W4M3
         bzkDTAJ9tOXiU2I2H7ATW3a+6+JTluv3IOUBNG8IO7Z8g9SxzGvVEmmwUVv5xfzObIme
         k2ew==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=jikos@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 21-v6si501337ejn.160.2019.01.31.02.15.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 02:15:30 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=jikos@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 7BF68B010;
	Thu, 31 Jan 2019 10:15:29 +0000 (UTC)
Date: Thu, 31 Jan 2019 11:15:28 +0100 (CET)
From: Jiri Kosina <jikos@kernel.org>
To: Michal Hocko <mhocko@kernel.org>
cc: Vlastimil Babka <vbabka@suse.cz>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Linus Torvalds <torvalds@linux-foundation.org>, 
    linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
    linux-api@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, 
    Greg KH <gregkh@linuxfoundation.org>, Jann Horn <jannh@google.com>, 
    Dominique Martinet <asmadeus@codewreck.org>, 
    Andy Lutomirski <luto@amacapital.net>, Dave Chinner <david@fromorbit.com>, 
    Kevin Easton <kevin@guarana.org>, Matthew Wilcox <willy@infradead.org>, 
    Cyril Hrubis <chrubis@suse.cz>, Tejun Heo <tj@kernel.org>, 
    "Kirill A . Shutemov" <kirill@shutemov.name>, 
    Daniel Gruss <daniel@gruss.cc>, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 2/3] mm/filemap: initiate readahead even if IOCB_NOWAIT
 is set for the I/O
In-Reply-To: <20190131095644.GR18811@dhcp22.suse.cz>
Message-ID: <nycvar.YFH.7.76.1901311114260.6626@cbobk.fhfr.pm>
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm> <20190130124420.1834-1-vbabka@suse.cz> <20190130124420.1834-3-vbabka@suse.cz> <20190131095644.GR18811@dhcp22.suse.cz>
User-Agent: Alpine 2.21 (LSU 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 31 Jan 2019, Michal Hocko wrote:

> > diff --git a/mm/filemap.c b/mm/filemap.c
> > index 9f5e323e883e..7bcdd36e629d 100644
> > --- a/mm/filemap.c
> > +++ b/mm/filemap.c
> > @@ -2075,8 +2075,6 @@ static ssize_t generic_file_buffered_read(struct kiocb *iocb,
> >  
> >  		page = find_get_page(mapping, index);
> >  		if (!page) {
> > -			if (iocb->ki_flags & IOCB_NOWAIT)
> > -				goto would_block;
> >  			page_cache_sync_readahead(mapping,
> >  					ra, filp,
> >  					index, last_index - index);
> 
> Maybe a stupid question but I am not really familiar with this path but
> what exactly does prevent a sync read down page_cache_sync_readahead
> path?

page_cache_sync_readahead() only submits the read ahead request(s), it 
doesn't wait for it to finish.

-- 
Jiri Kosina
SUSE Labs

