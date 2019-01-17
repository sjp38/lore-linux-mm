Return-Path: <SRS0=SJ39=PZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EA48FC43612
	for <linux-mm@archiver.kernel.org>; Thu, 17 Jan 2019 16:29:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ADD5820855
	for <linux-mm@archiver.kernel.org>; Thu, 17 Jan 2019 16:29:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ADD5820855
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4A9CB8E000B; Thu, 17 Jan 2019 11:29:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 42F9A8E0002; Thu, 17 Jan 2019 11:29:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2F7FB8E000B; Thu, 17 Jan 2019 11:29:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 024688E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 11:29:15 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id d31so9610513qtc.4
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 08:29:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version;
        bh=sF4B3kTinlBQONTKYJIx0PSeVWK4itW9iPsPCWk5Cg4=;
        b=qB1IyhOUOthX0LCDRAeJYN8/rSZkK0hF/o36U6bMSKLgoQvuEN15ClHy2pcRUbDysX
         poTwVBi3Y4ankLx66h/MXjFQNpJdeganitoq73ehp2uNQyjjn94Jp7d8Y89K/gII7Rm8
         651WRT+USwoA4P3gDk4acaFlP7PHhyPissOLMdJ5RkI0sl0T9o1KKjc8UbNlwv112M5f
         6yANIxO8BlL6EDCpUTP/1A4RhXTNLUYmY1TwUqa7rVXO75tCqJG4mNk0MPGop2ryqDLu
         lieYCAwxdoG4V+HB9JEVzMYDS15sxJ2qTmh0HaifYigHbTRhgqRJvn5dhNlIxEWV4/rQ
         zP1Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jmoyer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jmoyer@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukcq55Jljv9oe75gCE/a3y5xT+YUWKRSQQdBsITilFqevpejksym
	AAi+vrtcZ0DizRHS+PDyl4EsACkeHVy+Pc/lLEDvbtLHxBiA0g19jDqXqfgYb/heByPEX4/tNaR
	BLcnYMG4sZ9fV+QzU349YA6lCxXCHETOlHmNuyW3YMd25/xVvG+Nx8Y473WJv/MR9zw==
X-Received: by 2002:a37:4e58:: with SMTP id c85mr11671195qkb.27.1547742554735;
        Thu, 17 Jan 2019 08:29:14 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6zq/EcOQAvZ9lQZVHHgXqqj1p2gxACeYZMzWAI0G50nWYZeUtbeiRzQDNrQ6qx3WwwcqeY
X-Received: by 2002:a37:4e58:: with SMTP id c85mr11671154qkb.27.1547742554238;
        Thu, 17 Jan 2019 08:29:14 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547742554; cv=none;
        d=google.com; s=arc-20160816;
        b=thN4hDmhoVRpVuvtI98P+hTWhprOujTRigKs40x5TUhepJWhpu/czt1KbS520m1Otc
         WiaaNPZ6z/CV4dgQV8CMWKjTQhagonqGA9ilVNNY+tFTb1wz+72MaGZNo8/RrFbhsAh8
         y7mwu3W4cVFBv7euFjTrGN+ctIzcRhUkRn/IWCcwvxg1AAa2hg9fPwPfAUMYEn/qAHzd
         X6NIWhr5PC3L+11Etwx8VChWVN4+dHdeBH3BA8KI5X430xjVdIXS2Vix1O2JjMnW2yg5
         xvYFpVD+2sAQ+GR4WIn9oIjKGAAvKWhBwcEZNDDBOJmX+aIG77DO6Ges2dwUTUWJe8oc
         dNMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :subject:cc:to:from;
        bh=sF4B3kTinlBQONTKYJIx0PSeVWK4itW9iPsPCWk5Cg4=;
        b=ePN/VOu2BYnUTmCvpO8RmbkDiEfrr4E2p8Lku2nNbfTBgedtI3A7b6WmJFnpucdHBC
         jPR3i9tDNO9GU79bkgaCuxYse7KarBbFQPRsL5tauq1x2z/j8lcY98w4S5Vj0fL5hBYJ
         cILLSj4/ZJZjm8dXUT9n7rYaVMait22uKtu16loWOYl59MkbiSOcAlv3Hlwrq+B9AFCA
         7IHkGO3tYv72e/wnk/0HHshGfKPeGMq+yM7vIaGcdm1b3IToaQXqikTbDp+1o3lqifcA
         XB71jI2dkIf82y/6sDFXM7gzOuPL7qhsu7p4Mn7pVSLIFKOJa2GNo7jhnm2im6Ha58Qi
         SJ5A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jmoyer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jmoyer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u4si315473qkc.197.2019.01.17.08.29.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Jan 2019 08:29:14 -0800 (PST)
Received-SPF: pass (google.com: domain of jmoyer@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jmoyer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jmoyer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 22911804F8;
	Thu, 17 Jan 2019 16:29:13 +0000 (UTC)
Received: from segfault.boston.devel.redhat.com (segfault.boston.devel.redhat.com [10.19.60.26])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 9CD1C60933;
	Thu, 17 Jan 2019 16:29:11 +0000 (UTC)
From: Jeff Moyer <jmoyer@redhat.com>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: dave@sr71.net,  thomas.lendacky@amd.com,  mhocko@suse.com,  linux-nvdimm@lists.01.org,  tiwai@suse.de,  ying.huang@intel.com,  linux-kernel@vger.kernel.org,  linux-mm@kvack.org,  bp@suse.de,  baiyaowei@cmss.chinamobile.com,  zwisler@kernel.org,  bhelgaas@google.com,  fengguang.wu@intel.com,  akpm@linux-foundation.org
Subject: Re: [PATCH 0/4] Allow persistent memory to be used like normal RAM
References: <20190116181859.D1504459@viggo.jf.intel.com>
X-PGP-KeyID: 1F78E1B4
X-PGP-CertKey: F6FE 280D 8293 F72C 65FD  5A58 1FF8 A7CA 1F78 E1B4
Date: Thu, 17 Jan 2019 11:29:10 -0500
In-Reply-To: <20190116181859.D1504459@viggo.jf.intel.com> (Dave Hansen's
	message of "Wed, 16 Jan 2019 10:18:59 -0800")
Message-ID: <x49sgxr9rjd.fsf@segfault.boston.devel.redhat.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Thu, 17 Jan 2019 16:29:13 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190117162910.s8_4djPiooye4V9HrZIrWQF6fVdnnyHohgmqiSV_K-8@z>

Dave Hansen <dave.hansen@linux.intel.com> writes:

> Persistent memory is cool.  But, currently, you have to rewrite
> your applications to use it.  Wouldn't it be cool if you could
> just have it show up in your system like normal RAM and get to
> it like a slow blob of memory?  Well... have I got the patch
> series for you!

So, isn't that what memory mode is for?
  https://itpeernetwork.intel.com/intel-optane-dc-persistent-memory-operating-modes/

Why do we need this code in the kernel?

-Jeff

