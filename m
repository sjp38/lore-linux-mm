Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9AEB6C43219
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 11:32:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4997020651
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 11:32:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hansenpartnership.com header.i=@hansenpartnership.com header.b="DcoPWb0p";
	dkim=pass (1024-bit key) header.d=hansenpartnership.com header.i=@hansenpartnership.com header.b="qUwpVC0Q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4997020651
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=HansenPartnership.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E322B6B0006; Mon, 29 Apr 2019 07:32:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DE17C6B0007; Mon, 29 Apr 2019 07:32:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CD1466B0008; Mon, 29 Apr 2019 07:32:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id A50A56B0006
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 07:32:20 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id v83so8420413ywa.1
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 04:32:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:message-id:subject
         :from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ReG62YdWM/GmSHNWkGuIA3GWIr1NGSmXDWkfid57eUM=;
        b=VlN3m1gb+Tw/YzIoj1VEUjlJW5uIO0OXE+TQFpuUP1w0fqeq/RP1kvw5oyNgQ2Rg2s
         X8oskBllLanb+cD4meB7vFh4+sDekWPVo5CFDqDVVN0U8tulrddTxY483FbbEC8mT/S3
         z9i3CI51BC5uWLHP9E27v+TkccaLiCBtR3svNw3oz2oSL5K7dZmqFNuIMBIHa9zVuvpC
         dB//5gu1gypxFpzAMZlFNESuLkpRz3ccH7fayIWOBDAoiI3CbG3fjQAVOv32bts5Fw6w
         ulNBdo1WFaLtTElVQjReY0MkCIrFPBiJNJX9pg2yOB7a17yOJRpWWwWMDDvXP+EOdSFs
         I9kQ==
X-Gm-Message-State: APjAAAXQbzrKXJSCVFgO6uSBIKL/GpocSxtG01hgmdrmAyixXrnt4en6
	UVT/tfA1sWLW3TQvMV/6IsyLxW28rqveuDhdpb1qf/mjjaGVfYw3ECbTY2Gsxl3l3wmvQjLot3v
	TGKqQ9NS3kpFViDNve4p+ooowExS8GXXQ9V453Qp4Eanu+tvEcdKAvjnxKOvr40uujA==
X-Received: by 2002:a25:354:: with SMTP id 81mr47036104ybd.295.1556537540394;
        Mon, 29 Apr 2019 04:32:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyjHIRs7BlyJGqQLQYtDF6CBwB/IC7aXY6BvtgHl5dIp5dDbEBzlh+W9HX5q/gEp90s64xc
X-Received: by 2002:a25:354:: with SMTP id 81mr47036046ybd.295.1556537539755;
        Mon, 29 Apr 2019 04:32:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556537539; cv=none;
        d=google.com; s=arc-20160816;
        b=GF/NOwGbuzuZvG7QQ+olWFaWvRZq7hxsMe9uElzZSERnzENDO3WwbWk9cXPNZKYdO/
         P25LuUMYNztCuD70BdtbN5bHqvSvODkK14pXSCWlPMPCmc7GO/Xa9GJxZ0/YUIMVvZjm
         YE0Tn4W+qRW7eG0Hgcs5nNe2S7pfDwOI6aKj5zI8faciUb2VM3AIgaaaaAogWJR8pM+U
         xDnp1FDV+I+r0pbCQQicvJW7NOMF2P111WAxJBTt/FTEw21Mxb1brceQDH/cIdWPFtsM
         cvLc1o1bgIgvaF7LEcUtpTBspX6Kd+P0buGg5SdTf/SashbmdhP4haG139i7Rd6Hq+DX
         LoWA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature:dkim-signature;
        bh=ReG62YdWM/GmSHNWkGuIA3GWIr1NGSmXDWkfid57eUM=;
        b=HD3Y5f2eU57tOqy2Z9hCc127Q4ntSEDuIOJT4i28Ple0tn7AHVeMA1v+J9EhrDjAes
         AS5/T26sHgYtzwp8mOoh5z5LCrLvW74d3h6VOEBsyN9g1baYxFVgLU1fHqa1VQjTlLx+
         EE0eRb+MBzRTBDn8Crvbzr9qgcm+7AvXEXMjnEh3YMVHrffq6MzZRvamcoK10NZfM6xL
         sKh17T2tluOW42X0FglPul4Iq70bEEJzZXUjFl/EzVmVMgtKgscdJn3YRIRP7RuysJlW
         kMm2EKXoEq0b4o7UjVcRwpEg3l6+CwfHYXHL5VMPUrIbEuVCZxWAonThdJpDV0CvM9D2
         BnDw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@hansenpartnership.com header.s=20151216 header.b=DcoPWb0p;
       dkim=pass header.i=@hansenpartnership.com header.s=20151216 header.b=qUwpVC0Q;
       spf=pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) smtp.mailfrom=James.Bottomley@hansenpartnership.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=hansenpartnership.com
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTPS id i5si15253853ybi.389.2019.04.29.04.32.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 29 Apr 2019 04:32:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) client-ip=66.63.167.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@hansenpartnership.com header.s=20151216 header.b=DcoPWb0p;
       dkim=pass header.i=@hansenpartnership.com header.s=20151216 header.b=qUwpVC0Q;
       spf=pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) smtp.mailfrom=James.Bottomley@hansenpartnership.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=hansenpartnership.com
Received: from localhost (localhost [127.0.0.1])
	by bedivere.hansenpartnership.com (Postfix) with ESMTP id 02B9A8EE22B;
	Mon, 29 Apr 2019 04:32:18 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=hansenpartnership.com;
	s=20151216; t=1556537538;
	bh=2iZtI0VfLKpV5ObRkGVTpE3g4x9tbWBVvjAs7KDcmSg=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
	b=DcoPWb0p2NZ40MoDPNrf3ci9S9jsAy/NUbXb5d5odKyojCic8qw5oGZ5rdYCavvdp
	 yZDWqj3sA5kvj17oQq4vXreyHDIa935b/sEjIaXp8SeqcGdXCHo6o+pRJV6WyPWGWP
	 Rxrm7sI7f7OxXXoXKPBP1us/9a6WvuLNuVebB8rk=
Received: from bedivere.hansenpartnership.com ([127.0.0.1])
	by localhost (bedivere.hansenpartnership.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id K-7FVscySGeW; Mon, 29 Apr 2019 04:32:17 -0700 (PDT)
Received: from [192.168.100.227] (unknown [24.246.103.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by bedivere.hansenpartnership.com (Postfix) with ESMTPSA id C338E8EE03B;
	Mon, 29 Apr 2019 04:32:16 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=hansenpartnership.com;
	s=20151216; t=1556537537;
	bh=2iZtI0VfLKpV5ObRkGVTpE3g4x9tbWBVvjAs7KDcmSg=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
	b=qUwpVC0QJuutvZlqdtgObuMf5BV9POiAAXyZCN9P2HmjcRGX8+KOi8BLr/4oZo/+S
	 qHplN5NkWkxuuOmvHzNKiHFHdR2/CjbL851psO4zifniklhjbFcZMLINdzL0eLebm1
	 3T8oJrams382HTXWYrPU4VoMYP79BEswcW7wv2L8=
Message-ID: <1556537518.3119.6.camel@HansenPartnership.com>
Subject: Re: [Lsf] [LSF/MM] Preliminary agenda ? Anyone ... anyone ? Bueller
 ?
From: James Bottomley <James.Bottomley@HansenPartnership.com>
To: "Martin K. Petersen" <martin.petersen@oracle.com>, Vlastimil Babka
	 <vbabka@suse.cz>
Cc: Jens Axboe <axboe@kernel.dk>, lsf@lists.linux-foundation.org, 
 linux-kernel@vger.kernel.org, linux-block@vger.kernel.org,
 linux-mm@kvack.org,  Jerome Glisse <jglisse@redhat.com>,
 linux-fsdevel@vger.kernel.org, lsf-pc@lists.linux-foundation.org
Date: Mon, 29 Apr 2019 07:31:58 -0400
In-Reply-To: <yq1v9yx2inc.fsf@oracle.com>
References: <20190425200012.GA6391@redhat.com>
	 <83fda245-849a-70cc-dde0-5c451938ee97@kernel.dk>
	 <503ba1f9-ad78-561a-9614-1dcb139439a6@suse.cz> <yq1v9yx2inc.fsf@oracle.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.26.6 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-04-29 at 06:46 -0400, Martin K. Petersen wrote:
> Vlastimil,
> 
> > In previous years years there also used to be an attendee list,
> > which is now an empty tab. Is that intentional due to GDPR?
> 
> Yes.

Actually, GDPR doesn't require this.  What it requires is informed
consent and legitimate purpose (and since LSF/MM usually publishes the
attendee list for attendee co-ordination, that's a legitimate purpose).
 If you look at the LF form you filled in, you already gave "informed
consent": it was the "receive email from sponsors or partners".  That's
an agreement to share your email address.  This is also sufficient
consent to share with attendees since they're also "event partners".

Next year, simply expand the blurb to "sponsors, partners and
attendees" to make it more clear ... or better yet separate them so
people can opt out of partner spam and still be on the attendee list.

James

