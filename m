Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 93B236B0292
	for <linux-mm@kvack.org>; Mon, 29 May 2017 06:11:37 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id d127so12501568wmf.15
        for <linux-mm@kvack.org>; Mon, 29 May 2017 03:11:37 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id z24si10130211edc.188.2017.05.29.03.11.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 May 2017 03:11:36 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4TA8pom053439
	for <linux-mm@kvack.org>; Mon, 29 May 2017 06:11:34 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2arha48thm-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 29 May 2017 06:11:34 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Mon, 29 May 2017 11:11:32 +0100
Date: Mon, 29 May 2017 12:11:28 +0200
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [-next] memory hotplug regression
References: <20170524082022.GC5427@osiris>
 <20170524083956.GC14733@dhcp22.suse.cz>
 <20170526122509.GB14849@osiris>
 <20170529085231.GE19725@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170529085231.GE19725@dhcp22.suse.cz>
Message-Id: <20170529101128.GA12975@osiris>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, May 29, 2017 at 10:52:31AM +0200, Michal Hocko wrote:
> > Why is it a problem to change the default for 'online'? As far as I can see
> > that doesn't have too much to do with the order of zones, no?
> 
> `online' (aka MMOP_ONLINE_KEEP) should always inherit its current zone.
> The previous implementation made an exception to allow to shift to
> another zone if it is on the border of two zones. This is what I wanted
> to get rid of because it is just too ugly to live.
> 
> But now I am not really sure what is the usecase here. I assume you know
> how to online the memoery. That's why you had to play tricks with the
> zones previously. All you need now is to use the proper MMOP_ONLINE*

Yes, however that implies that existing user space has to be changed to
achieve the same semantics as before. That's the usecase I'm talking about.

On the other hand this change would finally make s390 behave like all other
architectures, which is certainly not a bad thing. So, while thinking again
I think you convinced me to agree with this change.

> > 2) Another oddity is that after a memory block was brought online it's
> > association to ZONE_NORMAL or ZONE_MOVABLE seems to be fixed. Even if it
> > is brought offline afterwards:
> 
> This is intended behavior because I got rid of the tricky&ugly zone
> shifting code. Ultimately I would like to allow for overlapping zones
> so the explicit online_{movable,kernel} will _always_ work.

Ok, I see. This change (fixed memory block to zone mapping after first
online) is a bit surprising. On the other hand I can't think of a sane
usecase why one wants to change the zone a memory block belongs to.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
