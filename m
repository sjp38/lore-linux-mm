Return-Path: <SRS0=5q+O=TJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3EAF0C04AB3
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 16:48:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F2B6C2177E
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 16:48:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F2B6C2177E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A4AA16B0005; Thu,  9 May 2019 12:48:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9FBB16B0008; Thu,  9 May 2019 12:48:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 911546B000A; Thu,  9 May 2019 12:48:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5DA7B6B0005
	for <linux-mm@kvack.org>; Thu,  9 May 2019 12:48:44 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id bg6so1882370plb.8
        for <linux-mm@kvack.org>; Thu, 09 May 2019 09:48:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:dlp-product
         :dlp-version:dlp-reaction:content-transfer-encoding:mime-version;
        bh=CcplOEA58I9A9LKH/m/9sE+I+WbpLEYM/Bu2MwgVwqo=;
        b=tV4+Mil1I35Hxo6NTWN95y3qwMTQR8NmxeeFbx9Pf6qF7dpb/PUdwYTvdnsIdsBPoy
         P+le7PD0ddH+mQnhr7xtGN0fAVhl7NXwVqGRUa/By6IywVUXmqyp7/A/5JlyL+WwKy50
         aHFjhCELJMD8ouitGw4oSMKAUZBE2e5dz8a9eoNyGUHgCk1AbP7Ry5n0RJdFAaZ9cCTi
         c1iDc2rGz5xqQcBTqV7N7TOi4JSgNw6I0tDceEAamxWoXPafg+/RTmanIFKnHtPvS4co
         +NZ4aNfenAkiG5g5I2zn1hxDfm/mn1ZHRg9dUdkEJbuH75mKf28poNBhtN4D5QX/u+Pu
         atmA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUID0WjBHySeRHa+7+KJJ9mZdvY0VhowNpLkDzxx3sMsVtaFMti
	wDxSjkzWkws2cBe0Op37aG2B/2vG7Y71c1Bt0YW7WI9P0RevmjmFfgy30nF2a5YCHxk8HUqC4G/
	LrC/8mBk0qxYsX5jzgRFaDA5t2pV29FqybQd/Fqu58RezpKWWAEfKwMkDhmqQ6YNT4g==
X-Received: by 2002:aa7:8d81:: with SMTP id i1mr6669538pfr.127.1557420524073;
        Thu, 09 May 2019 09:48:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqywiUC2GgGK49EM8RrUimF+E7QzjxCDIFcIK9n4y8ievai3B+itQaROGDzUAf8UmX5PRqeS
X-Received: by 2002:aa7:8d81:: with SMTP id i1mr6669449pfr.127.1557420523336;
        Thu, 09 May 2019 09:48:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557420523; cv=none;
        d=google.com; s=arc-20160816;
        b=Q7ExuLXWjTM9/ofxvuLXVetwCn7drkuEWM/I5B7BgcN82D0LyEQ9dlpuRMDqa+zIE0
         PP84TY33fDhId65zYzr3PrL6yT0IRgouw42nPy7B+Wd/SNa7CE2SGayDvYH81m545iXN
         VqRGwn2/E7QGEf/oSeYHVBj2PVLVhqs3DNv2PvWn6xpZTcwy/e3T0y0iXduLnTvyNgEx
         0YMVGKboW/XyJ20rxgWOyKd75Jx7jxzX4UsOljCRf3o85N/oj+4fM5x28yPvKYd3r6tz
         03BmjuYrVA4n28jYbFtdoHArpOFxRWmUDi2BHV3Du7Z2Db5CEs2xyYVuMTM//Ogah+GL
         6khA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:dlp-reaction:dlp-version
         :dlp-product:content-language:accept-language:in-reply-to:references
         :message-id:date:thread-index:thread-topic:subject:cc:to:from;
        bh=CcplOEA58I9A9LKH/m/9sE+I+WbpLEYM/Bu2MwgVwqo=;
        b=GLGpA7kHLzQJ6Epasn7KomDetPMd6a8HTlvZ9/eJV1AsrpK536wOIOHfJ1pAbm8146
         C7SjOIaXfjlG2adI0GgN39tp3m6+wL7F3LjyM2EvJiVhFh3i/wC/3VU9ApvPfTmFyyZo
         eda0htvcWvgay79BMpgoQXKWS1tUrxJJAtLF0kWkHJ2WxpqDrHv16rLY1ZXdcjLL1WO5
         Hebemg37qqJHZrfo2qVESB9OT20momSlkQZydhJ7TrInR5hG8V3qnYwJeDd3FvHp5Non
         u7XLeUilsuILFJrty8FtX6ZgIk3a5dDk7wpya7DbWxDy1UnLLn5ATFDgJrR7K/y+AOR8
         MIuA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id co15si3774082plb.330.2019.05.09.09.48.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 May 2019 09:48:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga008.fm.intel.com ([10.253.24.58])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 May 2019 09:48:42 -0700
X-ExtLoop1: 1
Received: from fmsmsx105.amr.corp.intel.com ([10.18.124.203])
  by fmsmga008.fm.intel.com with ESMTP; 09 May 2019 09:48:42 -0700
Received: from crsmsx151.amr.corp.intel.com (172.18.7.86) by
 FMSMSX105.amr.corp.intel.com (10.18.124.203) with Microsoft SMTP Server (TLS)
 id 14.3.408.0; Thu, 9 May 2019 09:48:42 -0700
Received: from crsmsx101.amr.corp.intel.com ([169.254.1.116]) by
 CRSMSX151.amr.corp.intel.com ([169.254.3.202]) with mapi id 14.03.0415.000;
 Thu, 9 May 2019 10:48:40 -0600
From: "Weiny, Ira" <ira.weiny@intel.com>
To: Matthew Wilcox <willy@infradead.org>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: RE: [RFC 00/11] Remove 'order' argument from many mm functions
Thread-Topic: [RFC 00/11] Remove 'order' argument from many mm functions
Thread-Index: AQHVBIpK9Pwsdx9BbkOGUkIop65yuaZh+3SAgAFBDID//8MJwA==
Date: Thu, 9 May 2019 16:48:39 +0000
Message-ID: <2807E5FD2F6FDA4886F6618EAC48510E79D0CFDA@CRSMSX101.amr.corp.intel.com>
References: <20190507040609.21746-1-willy@infradead.org>
 <20190509015809.GB26131@iweiny-DESK2.sc.intel.com>
 <20190509140713.GB23561@bombadil.infradead.org>
In-Reply-To: <20190509140713.GB23561@bombadil.infradead.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-titus-metadata-40: eyJDYXRlZ29yeUxhYmVscyI6IiIsIk1ldGFkYXRhIjp7Im5zIjoiaHR0cDpcL1wvd3d3LnRpdHVzLmNvbVwvbnNcL0ludGVsMyIsImlkIjoiNTFkOGZlMmEtNTk2OC00M2ZhLTkyNDEtOTIxODU3ZDVjNDUwIiwicHJvcHMiOlt7Im4iOiJDVFBDbGFzc2lmaWNhdGlvbiIsInZhbHMiOlt7InZhbHVlIjoiQ1RQX05UIn1dfV19LCJTdWJqZWN0TGFiZWxzIjpbXSwiVE1DVmVyc2lvbiI6IjE3LjEwLjE4MDQuNDkiLCJUcnVzdGVkTGFiZWxIYXNoIjoiY3VUbEdOYVdoaUNuUlwvZFVXV2Z2QThRc1pnT25ad1JVdFFKZ0RrbmJPenBhWkVUS3lVendcL3doZXIzRkRzM0U5In0=
x-ctpclassification: CTP_NT
dlp-product: dlpe-windows
dlp-version: 11.0.600.7
dlp-reaction: no-action
x-originating-ip: [172.18.205.10]
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.001374, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> On Wed, May 08, 2019 at 06:58:09PM -0700, Ira Weiny wrote:
> > On Mon, May 06, 2019 at 09:05:58PM -0700, Matthew Wilcox wrote:
> > > It's possible to save a few hundred bytes from the kernel text by
> > > moving the 'order' argument into the GFP flags.  I had the idea
> > > while I was playing with THP pagecache (notably, I didn't want to add=
 an
> 'order'
> > > parameter to pagecache_get_page())
> ...
> > > Anyway, this is just a quick POC due to me being on an aeroplane for
> > > most of today.  Maybe we don't want to spend five GFP bits on this.
> > > Some bits of this could be pulled out and applied even if we don't
> > > want to go for the main objective.  eg rmqueue_pcplist() doesn't use
> > > its gfp_flags argument.
> >
> > Over all I may just be a simpleton WRT this but I'm not sure that the
> > added complexity justifies the gain.
>=20
> I'm disappointed that you see it as added complexity.  I see it as reduci=
ng
> complexity.  With this patch, we can simply pass GFP_PMD as a flag to
> pagecache_get_page(); without it, we have to add a fifth parameter to
> pagecache_get_page() and change all the callers to pass '0'.

I don't disagree for pagecache_get_page().

I'm not saying we should not do this.  But this seems odd to me.

Again I'm probably just being a simpleton...
Ira
=20

