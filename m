Return-Path: <SRS0=O33Z=PL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F1C7EC43444
	for <linux-mm@archiver.kernel.org>; Thu,  3 Jan 2019 19:30:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B5D30217F5
	for <linux-mm@archiver.kernel.org>; Thu,  3 Jan 2019 19:30:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B5D30217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 555E48E00A5; Thu,  3 Jan 2019 14:30:16 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 505798E0002; Thu,  3 Jan 2019 14:30:16 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 41C9B8E00A5; Thu,  3 Jan 2019 14:30:16 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 135778E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 14:30:16 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id w1so42249724qta.12
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 11:30:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=Gyf/2ED2WcX+j9ToB4jaF+aqjdKrwOnc6XfEisUggWg=;
        b=Yxx5i+yDcc5PljslpalK4i0CbUXLt2k5tVt6+IXVsL5LxlHppfyCii+6lT6wJtt/UP
         7RcfAj9IGyDrx3y6FXhmaZ57hJdJBLyXlpS5Sa7uIDQcFg165Mhy3tMgLI1TVTQaDh0m
         0PDvHtUrhXNlbniBRPY0UTimXTzUQbLcldZl6EoEGBk2YXeK/5+KNL4nyaYpq0tXsl6o
         EhPwA1i5sZezxonTSwQWYZ9RBy7YnpHMGOoB2PS2WbiFVUw0/LdIezY17r4lT2QMZIQ5
         oeGElt94hp2Cd9PJl9ik1+DTWIYR6KxkMzGghc8yGUz1qf9hWfCJQ4jAd5KtW10Jwnkm
         v/CA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukeLgA7F7swKULvyFZvLCzEZRxmKDDIwoYAWp+9ZiPWcqyzIPMX8
	ZG5XGD2CaLt5KbuBh/aFZrikO5WOg1fdzdYM0GYY92raapSIdm8bu1JjNRIlYmttiuSqGYOfT1Y
	SB0ftnaLGFRMttcwbuPkgS8hkl6OyanAdpnvrc4kwxMONqfCZmYD2b6czKKXCzB2o2A==
X-Received: by 2002:a0c:87dd:: with SMTP id 29mr48770807qvk.212.1546543815853;
        Thu, 03 Jan 2019 11:30:15 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6wozneCAsylwmeaRUDfADC+E4dxKo/LKw2YbLfOuY5TDp7ZuMPD4OlZsCAQ6gfYdhC05hR
X-Received: by 2002:a0c:87dd:: with SMTP id 29mr48770777qvk.212.1546543815282;
        Thu, 03 Jan 2019 11:30:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546543815; cv=none;
        d=google.com; s=arc-20160816;
        b=Raq7oz2iFAIr75PZxxhVnH0PTbguue2X51dv6a0ZbiMn5XM4Vmn2aGipydgXEVWCUC
         r3QaOXybMq0jDa/tv7HT2P39BnwjYpqHOXsORJIPdi1pGlBymO5Zh8kOsuFjwVDmI1Sm
         ZMq6W7BFme9q8hN3JDMU7twXJKdkPNLPBX8wH8r/fYt7fTumxuwqEx7L3D7Hc5FnU1Do
         mXFD6GobR7L0ZUgncZPja4VUbAguRI8WV+BxF374huH0c94vWTPmr832fSA02SEaM9Bz
         sn/9nFQOlf8I2t3B24NCUMisUpw8aDTiplSfXIp99GI+JCh2gKXOHhg3JGACPKZrPttx
         ryTQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=Gyf/2ED2WcX+j9ToB4jaF+aqjdKrwOnc6XfEisUggWg=;
        b=Kox2+qOw7K+l6lMs8XK2Lgsd4UgRz4h1TTV5GE2o3DX3w1ZUVE27mipn6ZXKTHhJb7
         Dk/005ZvC8rLqyzuoyceGYa80yWiJpVWqnw2WgZ4N8QxkbzoZ9r1xRLcoGSgfDtGRsfP
         mqUEVGcaZpi7RtW4On1luPUq5n5syBcfEj0x9BfvaBcMmXi36PbtCZXlV5gxJ3FAeacL
         wOpD9KWAUOtO7WUL1xOuWfXtk3pU2P+hdkwlEGqJDxkC3nwwHp3w1cxM2cR6tGAqxQzm
         m+9CLsA/QP/Gc8Zfh6XuVRAYlpyhLkiKFW0JypFG6rZXg8D5ER/1Izl8C+rARZVOr8Or
         UAGQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v17si8339498qvi.56.2019.01.03.11.30.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jan 2019 11:30:15 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 0D4212D6E41;
	Thu,  3 Jan 2019 19:30:14 +0000 (UTC)
Received: from redhat.com (ovpn-123-124.rdu2.redhat.com [10.10.123.124])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 98EB95D6A6;
	Thu,  3 Jan 2019 19:30:12 +0000 (UTC)
Date: Thu, 3 Jan 2019 14:30:10 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Dave Chinner <david@fromorbit.com>,
	Matthew Wilcox <willy@infradead.org>,
	linux-xfs <linux-xfs@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [BUG, TOT] xfs w/ dax failure in __follow_pte_pmd()
Message-ID: <20190103193009.GG3395@redhat.com>
References: <20190102211332.GL4205@dastard>
 <20190102212531.GK6310@bombadil.infradead.org>
 <20190102225005.GL6310@bombadil.infradead.org>
 <20190103000354.GM4205@dastard>
 <CAPcyv4jTWyYLEn+NcmVObscB9hArdsfxNL0YSMrHi_QDCOEkfQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAPcyv4jTWyYLEn+NcmVObscB9hArdsfxNL0YSMrHi_QDCOEkfQ@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Thu, 03 Jan 2019 19:30:14 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190103193010.tGzwqIYYs2f5OnBZRMRQRapeaivHtz2OKAgwfdtNxbk@z>

On Thu, Jan 03, 2019 at 11:11:49AM -0800, Dan Williams wrote:
> On Wed, Jan 2, 2019 at 4:04 PM Dave Chinner <david@fromorbit.com> wrote:
> >
> > On Wed, Jan 02, 2019 at 02:50:05PM -0800, Matthew Wilcox wrote:
> > > On Wed, Jan 02, 2019 at 01:25:31PM -0800, Matthew Wilcox wrote:
> > > > On Thu, Jan 03, 2019 at 08:13:32AM +1100, Dave Chinner wrote:
> > > > > Hi folks,
> > > > >
> > > > > An overnight test run on a current TOT kernel failed generic/413
> > > > > with the following dmesg output:
> > > > >
> > > > > [ 9487.276402] RIP: 0010:__follow_pte_pmd+0x22d/0x340
> > > > > [ 9487.305065] Call Trace:
> > > > > [ 9487.307310]  dax_entry_mkclean+0xbb/0x1f0
> > > >
> > > > We've only got one commit touching dax_entry_mkclean and it's Jerome's.
> > > > Looking through ac46d4f3c43241ffa23d5bf36153a0830c0e02cc, I'd say
> > > > it's missing a call to mmu_notifier_range_init().
> > >
> > > Could I persuade you to give this a try?
> >
> > Yup, that fixes it.
> >
> > And looking at the code, the dax mmu notifier code clearly wasn't
> > tested. i.e. dax_entry_mkclean() is the *only* code that exercises
> > the conditional range parameter code paths inside
> > __follow_pte_pmd().  This means it wasn't tested before it was
> > proposed for inclusion and since inclusion no-one using -akpm,
> > linux-next or the current mainline TOT has done any filesystem DAX
> > testing until I tripped over it.
> >
> > IOws, this is the second "this was never tested before it was merged
> > into mainline" XFS regression that I've found in the last 3 weeks.
> > Both commits have been merged through the -akpm tree, and that
> > implies we currently have no significant filesystem QA coverage on
> > changes being merged through this route. This seems like an area
> > that needs significant improvement to me....
> 
> Yes, this is also part of a series I explicitly NAK'd [1] because
> there are no upstream users for it. I didn't bother to test it because
> I thought the NAK was sufficient.
> 
> Andrew, any reason to not revert the set? They provide no upstream
> value and actively break DAX.
> 
> [1]: https://www.spinics.net/lists/linux-fsdevel/msg137309.html

I tested it but with the patch that was not included and that
extra patch did properly initialize the range struct. So the
patchset had a broken step.

Cheers,
Jérôme

