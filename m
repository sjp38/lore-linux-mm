Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BF89DC28CC3
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 06:23:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6B302208C0
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 06:23:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6B302208C0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=units.it
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E99446B0269; Fri,  7 Jun 2019 02:23:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E49FC6B026F; Fri,  7 Jun 2019 02:23:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D60906B0273; Fri,  7 Jun 2019 02:23:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9E8766B0269
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 02:23:04 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id f8so757449pgp.9
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 23:23:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:to:from:cc
         :subject:in-reply-to:mime-version:content-id
         :content-transfer-encoding:date:message-id;
        bh=oQ6rHYlBlNpfA1InKbVIJO2UyqUXtFm41nERPbLrDOE=;
        b=JSxFl2OnlHOYgkLc8CPBzMgjmweXU4fRkEoJcjjvQNKee0cH03tgU0KqKJizIU1v01
         qvCyfOKkYiEFLowWdmHxK0pSIvx8udEEa7jbGthRr+nVgt73zsiVgtP49CSCcUfNvBCZ
         ADgAC3FGg3gRYNyZttZQTlY8sswQL9CbF3zT9Qsf37hIDQ2dVvA7PJAVXtT9pO+o+3QZ
         K8bkkpRTy73RyFbiT1DspNk+VJ6qTVzfrLSrql/oQ0BxTNm5FM7KNc3KSoFmu2Z2lcQC
         wg+4vFjJbn5p7PGeAlDdeAF2bCtVOEaZ7L7ab3M4D/HmHSNGoE/inWU8vFbNZwlkc2w+
         Xj3g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of balducci@units.it designates 140.105.55.81 as permitted sender) smtp.mailfrom=balducci@units.it
X-Gm-Message-State: APjAAAU49crmK9nmLJsEleDRkJuSKeL++EZoq7+B/YKm8f/xDWqXE7DH
	HDVBC7breJdmdrAtjXlM0rGLvRLcix2G5ANSd81Q6/lp2InyMhaGsja2rIfPqQ04+239NjtsNia
	NzNSzTvSizIG+t/ewWciSVktN2bDWfHVZG8j6bKmlV/seoxUwX7LQcU4rzVtiDTvBOA==
X-Received: by 2002:a17:902:b497:: with SMTP id y23mr29840415plr.309.1559888584307;
        Thu, 06 Jun 2019 23:23:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw7DmY9H1R0AXueabFby/JZtYrzdUNmGCywJQs261qPwzgpmeXqLCu5fcpEHFI3l9fCU/+L
X-Received: by 2002:a17:902:b497:: with SMTP id y23mr29840374plr.309.1559888583642;
        Thu, 06 Jun 2019 23:23:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559888583; cv=none;
        d=google.com; s=arc-20160816;
        b=gu77OOaenecYkArTlFtKwMsqsdzxvgE2FSPMx9CzYdKs8NftnWYt8+i1CX/bMylFfk
         LwbN5NhrXthnUoaaYSTl8pzHDas2+EfwfAULo7W817TZLy38YSiCXQ7rHpPSXOoXrJsP
         7i2NZNp5HSw6niZwG2PuAzLKamwc9cQMS+v6+I5etQgMadPIaxowDgtJACueULs008jf
         6Y+1OfDJTpXxX7IkFCjkwhTZF/UbE49+RmgRaDB+giXp7/6WfbCZMjushALUh/mVTcpA
         MdyiR6DJPsvG1A55iRWui4jtkvu7UnLvIChRjaiWmckaAc2WePmZvtPNZx2OYm7RxT+E
         7Cuw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:content-transfer-encoding:content-id:mime-version
         :in-reply-to:subject:cc:from:to;
        bh=oQ6rHYlBlNpfA1InKbVIJO2UyqUXtFm41nERPbLrDOE=;
        b=F5Xh9nEz+QGL97WfQkQOg1a4YG9WU/Z/SGuzWrKsr+nRInYnH3akQKPt0cdfpnrctT
         suMeLgFkO9amzT9WR/GfU3lHidFQoKSOSilxz1qfSw4PvjPPqOOloHSonPMYh6ivBNCb
         uP06ER4mMAfpDZn4RM+T99IjE6tKSYMx9rO3CvYamBO0+bcEGBBxCiqkn4UpJmVam8vK
         BF0SJNYqf7Gn2m1OvDfpeV76qY6blugWNQLgJVE2HKBSinWp1eq679jJGXVaryOS7MId
         nFJni2VbSFunbcJ8e8YYs2jaI6wB7J2REDKxmPEkyfuBsKIkI2kkAmDKNcbtN9nLcks5
         1LIg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of balducci@units.it designates 140.105.55.81 as permitted sender) smtp.mailfrom=balducci@units.it
Received: from dschgrazlin2.units.it (dschgrazlin2.univ.trieste.it. [140.105.55.81])
        by mx.google.com with ESMTP id t5si1041641pgj.258.2019.06.06.23.23.02
        for <linux-mm@kvack.org>;
        Thu, 06 Jun 2019 23:23:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of balducci@units.it designates 140.105.55.81 as permitted sender) client-ip=140.105.55.81;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of balducci@units.it designates 140.105.55.81 as permitted sender) smtp.mailfrom=balducci@units.it
Received: from dschgrazlin2.units.it (loopback [127.0.0.1])
	by dschgrazlin2.units.it (8.15.2/8.15.2) with ESMTP id x576MWHs024423;
	Fri, 7 Jun 2019 08:22:32 +0200
To: bugzilla-daemon@bugzilla.kernel.org
From: balducci@units.it
CC: linux-mm@kvack.org, akpm@linux-foundation.org
Subject: Re: [Bug 203715] BUG: unable to handle kernel NULL pointer dereference under stress (possibly related to https://lkml.org/lkml/2019/5/24/292 ?)
In-reply-to: Your message of "Thu, 06 Jun 2019 14:44:31 -0000."
             <bug-203715-9581-JKJKlU0qlh@https.bugzilla.kernel.org/>
X-Mailer: MH-E 8.6+git; nmh 1.7.1; GNU Emacs 26.2
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <24421.1559888576.1@dschgrazlin2.units.it>
Content-Transfer-Encoding: quoted-printable
Date: Fri, 07 Jun 2019 08:22:32 +0200
Message-ID: <24422.1559888576@dschgrazlin2.units.it>
X-Greylist: inspected by milter-greylist-4.6.2 (dschgrazlin2.units.it [0.0.0.0]); Fri, 07 Jun 2019 08:22:33 +0200 (CEST) for IP:'127.0.0.1' DOMAIN:'loopback' HELO:'dschgrazlin2.units.it' FROM:'balducci@units.it' RCPT:''
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.6.2 (dschgrazlin2.units.it [0.0.0.0]); Fri, 07 Jun 2019 08:22:33 +0200 (CEST)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> Please try the following on top of 5.2-rc3
>
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 9e1b9acb116b..69f4ddfddfa4 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -277,8 +277,7 @@ __reset_isolation_pfn(struct zone *zone, unsigned lo=
ng pf
> n,
> bool check_source,
>         }
>
>         /* Ensure the end of the pageblock or zone is online and valid *=
/
> -       block_pfn +=3D pageblock_nr_pages;
> -       block_pfn =3D min(block_pfn, zone_end_pfn(zone) - 1);
> +       block_pfn =3D min(pageblock_end_pfn(block_pfn), zone_end_pfn(zon=
e) - 1)
> ;
>         end_page =3D pfn_to_online_page(block_pfn);
>         if (!end_page)
>                 return false;
> @@ -289,7 +288,7 @@ __reset_isolation_pfn(struct zone *zone, unsigned lo=
ng pf
> n,
> bool check_source,
>          * is necessary for the block to be a migration source/target.
>          */
>         do {
> -               if (pfn_valid_within(pfn)) {
> +               if (pfn_valid(pfn)) {
>                         if (check_source && PageLRU(page)) {
>                                 clear_pageblock_skip(page);
>                                 return true;
>

no joy; I left the FF build running and found the machine frozen this
morning; however, firefox build could apparently complete successfully;
I can't say when exactly the problem happened, as I haven't found any
message in the logs

thanks
ciao
-g

