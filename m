Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 77386C10F0E
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 16:54:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2406C2063F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 16:54:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2406C2063F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C38496B0266; Thu,  4 Apr 2019 12:54:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BEB616B026B; Thu,  4 Apr 2019 12:54:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ADAA36B026C; Thu,  4 Apr 2019 12:54:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 732846B0266
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 12:54:02 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id j184so1923756pgd.7
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 09:54:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:dlp-product
         :dlp-version:dlp-reaction:content-transfer-encoding:mime-version;
        bh=G5vlB9ogY7qE5fRXXrp3YzuRT1HiyOjIVjli+m0ivrE=;
        b=KRKT3Mrwtu9FEPYMiyKaDeumHFrdqPjIMetEmCVC7h1y73+VraPHOlAFV/czvCIbfs
         tI9b91U/va2gBQRwK+DdozBUuf8zXiMHs0nm3V79p4mEJGpI26gJwioVTBZ8aNfOk5Mn
         zRiZZzHdEUlXWjvO/vGYyytvnF49bRVldkfP7a+eX6IB5ftRHyl6Vb77ZbvXyCDTSMwN
         pbfqxprIXPnF8iLyg81da04/BDPhRIo2o4fJ2DJmAJQFGKel19WMQvcFg2D8J8zr2Cao
         54J5fORw2sTUadQ+S0mf2hKmAAtse2K6HqrsRq0EQ1WYWVBG7rQ4zUJKinKNWaEiIyFs
         xy5g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWDnzCY/SEVt1XSEE6U/vo20wHpJ2A1XY1CYcTS0uGlC7Wopz5v
	T+M+1Bw6gNb0JKhhU0shx4/162+/4iSXOt4B9owG1PKI0Jc8v3TAaIL5QJAM6OXLSnIdrDjMoLz
	WmFZvt3gL3KKzkJvR7ZOcA82ekTJyJ2n/TV1lcZVAXCntxFtH+q3MbSRRS5FqZWhhDA==
X-Received: by 2002:a17:902:70c8:: with SMTP id l8mr7586547plt.177.1554396842057;
        Thu, 04 Apr 2019 09:54:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzdG3Jqgczwo5NqskAjr88puDBfhpoETGcZIHKrXiDOBOnUv2n2M92CS6Mu1b7zMfJeedeX
X-Received: by 2002:a17:902:70c8:: with SMTP id l8mr7586492plt.177.1554396841456;
        Thu, 04 Apr 2019 09:54:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554396841; cv=none;
        d=google.com; s=arc-20160816;
        b=NXOZzgMpXdWhxFfbKCLnhwBin1zDpNMR0nY0H9ve4GRZ6xhcRa7HqlUdXYhA6hOreX
         BTedHKUNklGhbaWlquEeJTLxtt7Z6wTe0mK9aUz3XJBu6WoGn1tLK38A2cou+KowxN5+
         JFpNKm9KFZQBKL07Dmt/0JlDA+8Zb0u9PBKA8PYe7KTM2EqRXYV+LZDuzqT99R4ohIQl
         LO06pwwIXOeYYt3kmsO7fpqb7HZLMphApoFe27Mn6GZhoyhZbAtJrRqn+lqCAeZxV0XZ
         Y4BFH1ei2EfXIt29A0lOjuF16oxcQ2F1eQzLw37zu7TEa/4oacqhKhYV3w4SPaNuIQiM
         wWng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:dlp-reaction:dlp-version
         :dlp-product:content-language:accept-language:in-reply-to:references
         :message-id:date:thread-index:thread-topic:subject:cc:to:from;
        bh=G5vlB9ogY7qE5fRXXrp3YzuRT1HiyOjIVjli+m0ivrE=;
        b=byFfZzaHVl6vR7NASyV1AuWrLL26yAI2NPPszmQhC5gMI3EKfaXpAbTJLXa8l5vvdD
         l8XAFfAFidgb4nUWQuuGb0U0Wfj58hkroGzQGjkAA42EZIVQ7jHpyxqGlBHWMd/B0H2P
         sdcSjdwXGI2L1esox8B1ZT2huBS7pChlRQ1rCBPlOpKFs38nb3ap1OP0I2jw5BkE5C6g
         RybuNXbmoDG+TVFBxdqvmNZOwS6SWJV9uaIGfzfUlfS90X2AK2+PDgYAQzOtFfr570LH
         /Ren0n/+MzNgnxJMD7dq2Z+kxoUnDfkSWPqyZ2/C//Ew+JVGYVHqOuDPL1bsmEbkdrC6
         xMfQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id h11si17385084plb.38.2019.04.04.09.54.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Apr 2019 09:54:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 04 Apr 2019 09:54:00 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,308,1549958400"; 
   d="scan'208";a="131480547"
Received: from fmsmsx103.amr.corp.intel.com ([10.18.124.201])
  by orsmga008.jf.intel.com with ESMTP; 04 Apr 2019 09:53:57 -0700
Received: from fmsmsx123.amr.corp.intel.com (10.18.125.38) by
 FMSMSX103.amr.corp.intel.com (10.18.124.201) with Microsoft SMTP Server (TLS)
 id 14.3.408.0; Thu, 4 Apr 2019 09:53:57 -0700
Received: from crsmsx152.amr.corp.intel.com (172.18.7.35) by
 fmsmsx123.amr.corp.intel.com (10.18.125.38) with Microsoft SMTP Server (TLS)
 id 14.3.408.0; Thu, 4 Apr 2019 09:53:56 -0700
Received: from crsmsx101.amr.corp.intel.com ([169.254.1.94]) by
 CRSMSX152.amr.corp.intel.com ([169.254.5.30]) with mapi id 14.03.0415.000;
 Thu, 4 Apr 2019 10:53:54 -0600
From: "Weiny, Ira" <ira.weiny@intel.com>
To: William Kucharski <william.kucharski@oracle.com>, Huang Shijie
	<sjhuang@iluvatar.ai>
CC: "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"sfr@canb.auug.org.au" <sfr@canb.auug.org.au>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>
Subject: RE: [PATCH] mm/gup.c: fix the wrong comments
Thread-Topic: [PATCH] mm/gup.c: fix the wrong comments
Thread-Index: AQHU6rdootqQqf6MVU2Y2vuXC43Qn6YsVAoA///ka7A=
Date: Thu, 4 Apr 2019 16:53:53 +0000
Message-ID: <2807E5FD2F6FDA4886F6618EAC48510E79C99E19@CRSMSX101.amr.corp.intel.com>
References: <20190404072347.3440-1-sjhuang@iluvatar.ai>
 <3D9A544A-D447-4FD2-87A5-211588D6F3E5@oracle.com>
In-Reply-To: <3D9A544A-D447-4FD2-87A5-211588D6F3E5@oracle.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-titus-metadata-40: eyJDYXRlZ29yeUxhYmVscyI6IiIsIk1ldGFkYXRhIjp7Im5zIjoiaHR0cDpcL1wvd3d3LnRpdHVzLmNvbVwvbnNcL0ludGVsMyIsImlkIjoiNWUxNTc1MTUtNzE0Yy00ZDI0LWI3OWMtMDlmNGMyZWI3YzJhIiwicHJvcHMiOlt7Im4iOiJDVFBDbGFzc2lmaWNhdGlvbiIsInZhbHMiOlt7InZhbHVlIjoiQ1RQX05UIn1dfV19LCJTdWJqZWN0TGFiZWxzIjpbXSwiVE1DVmVyc2lvbiI6IjE3LjEwLjE4MDQuNDkiLCJUcnVzdGVkTGFiZWxIYXNoIjoicTBnNXhTUlFqVktYb0lncnA4QVJsSFlLaHZIQ3VUTHdDUUVzQVJ0ODd6ZHFLVUtBYnlxZ09SNXkraEFZQXBcL2UifQ==
x-ctpclassification: CTP_NT
dlp-product: dlpe-windows
dlp-version: 11.0.400.15
dlp-reaction: no-action
x-originating-ip: [172.18.205.10]
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> > On Apr 4, 2019, at 1:23 AM, Huang Shijie <sjhuang@iluvatar.ai> wrote:
> >
> >
> > + * This function is different from the get_user_pages_unlocked():
> > + *      The @pages may has different page order with the result
> > + *      got by get_user_pages_unlocked().
> > + *
>=20
> I suggest a slight rewrite of the comment, something like:
>=20
> * Note this routine may fill the pages array with entries in a
> * different order than get_user_pages_unlocked(), which may cause
> * issues for callers expecting the routines to be equivalent.

This is good too.  :-D

Ira

