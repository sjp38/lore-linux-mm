Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6F24BC31E44
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 07:57:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 228B721BE3
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 07:57:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (4096-bit key) header.d=d-silva.org header.i=@d-silva.org header.b="VqhZZ2C9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 228B721BE3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=d-silva.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B0AE68E0003; Mon, 17 Jun 2019 03:57:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ABAB28E0001; Mon, 17 Jun 2019 03:57:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9AB6E8E0003; Mon, 17 Jun 2019 03:57:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7AE0E8E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 03:57:25 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id f69so11401761ywb.21
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 00:57:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:references:in-reply-to
         :subject:date:message-id:mime-version:content-transfer-encoding
         :thread-index:content-language;
        bh=Ye/e+AaXa2i+xoXcCuIxSUX/e1DcwloLi9hS4ElTXDU=;
        b=nID1CQdyngnPE5Vi8ggL+1Sep7ZXmOL/Ajm8ruV6WeX31lZmMTBnmVVjqvHmNsFbDX
         8j7jNvtx7cZi4JGEWPwqBzoMcxtz9JAbI0CJh2hefGLUyCfbTKVbK1Vm15WsLvmtcLjn
         9GmLG2bl7wlqFxeVY2Xd4XnJOl05E/YG2k/O30SGzczSCxIFwNj1Rb6nZm4pt16WnBuC
         fK4SqoQmG7CvYNr/pVuTfRzO1JPiSRJ7rNnTButP+MKhX9PDCO4bqIBxs2SLojv9Zgs7
         HDmFf+SPZNFYf8VerLeLNjGrxl79lerSzUtC+ywdCSxe1KBuaIcWK6Swi/rdPioF9dXp
         Zm+A==
X-Gm-Message-State: APjAAAVoFuT7b0yqYCY0pTrrll7CDuNeQMBjplHXlk6mwC6hcTlxd2sF
	GuFH4kyx1R1PxqszYTJ4Dd2+qUFHHnW4RZ13H4cJMSo/ibtruNz6nVB0xYqeHNg2uWqW4RK/jmG
	6cV1TB5g6lSJyX2veXmKfnabvIDWctPegWjfdoL8H+eWHJK43ai3842eyAnDl3os7TQ==
X-Received: by 2002:a81:1bc8:: with SMTP id b191mr42189926ywb.120.1560758245212;
        Mon, 17 Jun 2019 00:57:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxR67AkbroV+qAIw90yvsw3YwHXBZ6BNKOV5aHHrXZ9HPPpRtQkf2P5po0UjgWVw6hOFRCC
X-Received: by 2002:a81:1bc8:: with SMTP id b191mr42189921ywb.120.1560758244702;
        Mon, 17 Jun 2019 00:57:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560758244; cv=none;
        d=google.com; s=arc-20160816;
        b=ED9DiVYun9IwLDuju1Y4JssAWAHYqF97U/KGhx+0RlKl8Z2pYfstOtXVa4+9sz2tHU
         50JvlD9VWilKxstOZhUWlCrQsMoTkbsbZSQgNDAfBAeInWGHbO0UCLzlSlsvZy7be3t7
         U/7/S6auyDp4NOuqdwYvt5zL0iwQUSe2ORoEmIIIYIa1Foi5xSIYtSL4cLiQuquu4aUn
         +z+mP8xf1Bmtsn1yS/CkbTQnzsEZZG9B+/ldulpiDtxKYS36wQSQuPwbdzKm7MgcImxS
         iKRob7R/I9X1nx2cBzOv2kgq8Ur2WCZkUjSu6W44XxJYno4Xdcw/VPhqnUat4bcDyTBo
         Do0Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:thread-index:content-transfer-encoding
         :mime-version:message-id:date:subject:in-reply-to:references:cc:to
         :from:dkim-signature;
        bh=Ye/e+AaXa2i+xoXcCuIxSUX/e1DcwloLi9hS4ElTXDU=;
        b=o1nTZzGEU1TCIYFvIlw8YZKXmHKrsDvfu4zTFbb3mZtcsx8aUbFtRGCbaL1a00e9t1
         zxWdg2cgm9Add+3Sp4AE6olrtgIIsCQIX/zuMGo4Nz7IDT+4d3BhwzBuRAtkvNmqTOIk
         vmRGKmPHhFfmZL+No4LF1dYh3BMUKtWFmn7uqF5VXqXAKmFtL2jtbHdVOjT6OcRtJuSz
         7zznzY+qm6TfARhcxoIDheV5mKs9X/62qgeu7pQKb70CQ0DXe+vgOqGpMnmihoOwVXBe
         qLhlRAje0v8DjBPKPfvUp3CYHZZ7XivsKp2++XNEC7QKu0pbSWxoosFsd7U7KHXPxjRF
         AJ6g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@d-silva.org header.s=201810a header.b=VqhZZ2C9;
       spf=pass (google.com: domain of alastair@d-silva.org designates 66.55.73.32 as permitted sender) smtp.mailfrom=alastair@d-silva.org
Received: from ushosting.nmnhosting.com (ushosting.nmnhosting.com. [66.55.73.32])
        by mx.google.com with ESMTP id 84si3577493ywo.186.2019.06.17.00.57.24
        for <linux-mm@kvack.org>;
        Mon, 17 Jun 2019 00:57:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of alastair@d-silva.org designates 66.55.73.32 as permitted sender) client-ip=66.55.73.32;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@d-silva.org header.s=201810a header.b=VqhZZ2C9;
       spf=pass (google.com: domain of alastair@d-silva.org designates 66.55.73.32 as permitted sender) smtp.mailfrom=alastair@d-silva.org
Received: from mail2.nmnhosting.com (unknown [202.169.106.97])
	by ushosting.nmnhosting.com (Postfix) with ESMTPS id 8FFB42DC007F;
	Mon, 17 Jun 2019 03:57:23 -0400 (EDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=d-silva.org;
	s=201810a; t=1560758243;
	bh=rFbuhIFz/h0VCo487ij807TQPU9Ah/028l0pxfTo07M=;
	h=From:To:Cc:References:In-Reply-To:Subject:Date:From;
	b=VqhZZ2C9MXgQs4mWEU46L5rHGLqpnIRoTGpY24OzxvqlwI7dZXTTYB8Y5aUj0N7mi
	 6yh2PHcCD4RfBeHo5jvQ47NUczbORBQk3PkDSmo0jUSECUTG14CVtDdBzTYggcARMs
	 ov0YKiTLAO9aKWJjhBp9+yr2QFbljJZ+8UwThAaOO0lDNzeYbMHgWl7G+uH4KMs+R9
	 6P+FvhFcIo9JRvwTFwUBGFHUqAqMYuaAVNL71EdG28Qfhl5nw+kdcbduv4/FvViN8a
	 VPig2zlIymRNN+WfjFAG8fNGX2J5noMfMWQY1v7hZEThQ3EOebgS1hJMHT9TU6wleJ
	 V63ouJV7+Kf8gM5pf+YXMm8lRQQJ8yHcRMdtsVuzkB/7rULa6In1JGZs9CFF9IKBA7
	 rb8/aEtc1NIl36SEebXTOj/vqlZL/CnUsE+10n65b9mfGfkaThusbbMYO16F6wF5uW
	 iUBE/dndXK+Qeu8nUEmyp3n65aao0p/EtXy5SrDrlWgfuy73yQi0kv0hG5U+z9/69Y
	 Nkjsh+e7W9pQzI70dFHUMNZXX+c4L6DsME6TgMN8FOmM2JuYE3UUTOIt3P+m/xo4jY
	 hWza4hDgNn56Xyq7292bmWLpXV9CpzI7TpkQAo107TJeWQMj0kaJFWM1/ddpmQhfkf
	 nwLifMmxknexkWaFavoo+4Sw=
Received: from Hawking (ntp.lan [10.0.1.1])
	(authenticated bits=0)
	by mail2.nmnhosting.com (8.15.2/8.15.2) with ESMTPSA id x5H7vGaN057238
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Mon, 17 Jun 2019 17:57:16 +1000 (AEST)
	(envelope-from alastair@d-silva.org)
From: "Alastair D'Silva" <alastair@d-silva.org>
To: "'Michal Hocko'" <mhocko@kernel.org>,
        "'Alastair D'Silva'" <alastair@au1.ibm.com>
Cc: "'Arun KS'" <arunks@codeaurora.org>,
        "'Mukesh Ojha'" <mojha@codeaurora.org>,
        "'Logan Gunthorpe'" <logang@deltatee.com>,
        "'Wei Yang'" <richard.weiyang@gmail.com>,
        "'Peter Zijlstra'" <peterz@infradead.org>,
        "'Ingo Molnar'" <mingo@kernel.org>, <linux-mm@kvack.org>,
        "'Qian Cai'" <cai@lca.pw>, "'Thomas Gleixner'" <tglx@linutronix.de>,
        "'Andrew Morton'" <akpm@linux-foundation.org>,
        "'Mike Rapoport'" <rppt@linux.vnet.ibm.com>,
        "'Baoquan He'" <bhe@redhat.com>,
        "'David Hildenbrand'" <david@redhat.com>,
        "'Josh Poimboeuf'" <jpoimboe@redhat.com>,
        "'Pavel Tatashin'" <pasha.tatashin@soleen.com>,
        "'Juergen Gross'" <jgross@suse.com>,
        "'Oscar Salvador'" <osalvador@suse.com>,
        "'Jiri Kosina'" <jkosina@suse.cz>, <linux-kernel@vger.kernel.org>
References: <20190617043635.13201-1-alastair@au1.ibm.com> <20190617043635.13201-5-alastair@au1.ibm.com> <20190617074715.GE30420@dhcp22.suse.cz>
In-Reply-To: <20190617074715.GE30420@dhcp22.suse.cz>
Subject: RE: [PATCH 4/5] mm/hotplug: Avoid RCU stalls when removing large amounts of memory
Date: Mon, 17 Jun 2019 17:57:16 +1000
Message-ID: <068b01d524e2$4a5f5c30$df1e1490$@d-silva.org>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
X-Mailer: Microsoft Outlook 16.0
Thread-Index: AQKozGZqZYmaEl7M6DfiQR95qivs4QInXwcPAp6henSk0fuP8A==
Content-Language: en-au
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.6.2 (mail2.nmnhosting.com [10.0.1.20]); Mon, 17 Jun 2019 17:57:19 +1000 (AEST)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> -----Original Message-----
> From: Michal Hocko <mhocko@kernel.org>
> Sent: Monday, 17 June 2019 5:47 PM
> To: Alastair D'Silva <alastair@au1.ibm.com>
> Cc: alastair@d-silva.org; Arun KS <arunks@codeaurora.org>; Mukesh Ojha
> <mojha@codeaurora.org>; Logan Gunthorpe <logang@deltatee.com>; Wei
> Yang <richard.weiyang@gmail.com>; Peter Zijlstra <peterz@infradead.org>;
> Ingo Molnar <mingo@kernel.org>; linux-mm@kvack.org; Qian Cai
> <cai@lca.pw>; Thomas Gleixner <tglx@linutronix.de>; Andrew Morton
> <akpm@linux-foundation.org>; Mike Rapoport <rppt@linux.vnet.ibm.com>;
> Baoquan He <bhe@redhat.com>; David Hildenbrand <david@redhat.com>;
> Josh Poimboeuf <jpoimboe@redhat.com>; Pavel Tatashin
> <pasha.tatashin@soleen.com>; Juergen Gross <jgross@suse.com>; Oscar
> Salvador <osalvador@suse.com>; Jiri Kosina <jkosina@suse.cz>; linux-
> kernel@vger.kernel.org
> Subject: Re: [PATCH 4/5] mm/hotplug: Avoid RCU stalls when removing large
> amounts of memory
> 
> On Mon 17-06-19 14:36:30,  Alastair D'Silva  wrote:
> > From: Alastair D'Silva <alastair@d-silva.org>
> >
> > When removing sufficiently large amounts of memory, we trigger RCU
> > stall detection. By periodically calling cond_resched(), we avoid
> > bogus stall warnings.
> >
> > Signed-off-by: Alastair D'Silva <alastair@d-silva.org>
> > ---
> >  mm/memory_hotplug.c | 3 +++
> >  1 file changed, 3 insertions(+)
> >
> > diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c index
> > e096c987d261..382b3a0c9333 100644
> > --- a/mm/memory_hotplug.c
> > +++ b/mm/memory_hotplug.c
> > @@ -578,6 +578,9 @@ void __remove_pages(struct zone *zone, unsigned
> long phys_start_pfn,
> >  		__remove_section(zone, __pfn_to_section(pfn),
> map_offset,
> >  				 altmap);
> >  		map_offset = 0;
> > +
> > +		if (!(i & 0x0FFF))
> > +			cond_resched();
> 
> We already do have cond_resched before __remove_section. Why is an
> additional needed?

I was getting stalls when removing ~1TB of memory.


-- 
Alastair D'Silva           mob: 0423 762 819
skype: alastair_dsilva     msn: alastair@d-silva.org
blog: http://alastair.d-silva.org    Twitter: @EvilDeece



