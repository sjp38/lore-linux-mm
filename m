Return-Path: <SRS0=HJeg=QJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AF924C282D8
	for <linux-mm@archiver.kernel.org>; Sat,  2 Feb 2019 03:27:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3DCAD2148D
	for <linux-mm@archiver.kernel.org>; Sat,  2 Feb 2019 03:27:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3DCAD2148D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=perches.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7D1628E0012; Fri,  1 Feb 2019 22:27:29 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 757C08E0001; Fri,  1 Feb 2019 22:27:29 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5D4288E0012; Fri,  1 Feb 2019 22:27:29 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2A42C8E0001
	for <linux-mm@kvack.org>; Fri,  1 Feb 2019 22:27:29 -0500 (EST)
Received: by mail-io1-f72.google.com with SMTP id q23so7339612ior.6
        for <linux-mm@kvack.org>; Fri, 01 Feb 2019 19:27:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=HsKGTVvTXit6Qvw72M7meMZhHQt5NbvO0YTcuf0mwJA=;
        b=GdursxB0IMoMXcdIBiD6be4HAKMT5rFLipO4aN/FWMPa6Yoz+3Q7LRCaSUVB6CXdpc
         bcidCkLoq3t+zfCql61XtofAIDkfBAbK4Gm5nVRrDXNiSBC+R7heF6XBELNEaaS9lbPc
         9QfgcsbBYr9OgrEA5WVWmaHW42uVgY3oe4DcWfZtJ4y63jlMcyBALLkXV0YFpZF8CSDK
         jEEGuejuPgS/65/xi0dllNYxpIV8wyujGW45w0Lfd6vznIrslOF38Eb0ZODh4z6tr5MC
         E7Cj455NS+MZoaISkBjpqSTzSq17pn7WqVDTCS2+b2HTvXaR6FAYSdm2xgCU9JOdVbHg
         FDTw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 216.40.44.141 is neither permitted nor denied by best guess record for domain of joe@perches.com) smtp.mailfrom=joe@perches.com
X-Gm-Message-State: AHQUAubTeiHHDlO3H7KTCZ4fZkYoIXH6Us5OC/AHq1M2ctvPoZuR3LNX
	cizjIIdiksGcnZf88nShKs5Zj77qfGg9Iq5Dp49eIFbrKV2MQbwJ3o2J4JjDmAUa/Qq2UJ2n5f9
	lNgyoDxbPYO9Xo8Jj8mYxFZhYoNLgPmqyfgTDU81lr30yx5RlNqooniksYujBW5U=
X-Received: by 2002:a6b:7903:: with SMTP id i3mr24255977iop.273.1549078048956;
        Fri, 01 Feb 2019 19:27:28 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4+T8+w9cBp05qkcHc3ATNutmv2nq5G2SjqIymI/vFduHQooOgpBIqSQldijLYlUB1bxkbN
X-Received: by 2002:a6b:7903:: with SMTP id i3mr24255968iop.273.1549078048263;
        Fri, 01 Feb 2019 19:27:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549078048; cv=none;
        d=google.com; s=arc-20160816;
        b=Jm+OBbHLH1Hw/S53Bo5v/ChGN7iY3qVajj66PGPm7JGAxW7CqrywXQ72WbkQLaj6Dx
         DDgLFlB1Vzv4BN/ArorHnQUe7CjuWRdi8xA98vbO7I8RdldbyVBaT2IDMenm9UO6JWM4
         Z4zsV1aDnJJmsHVlzbY3wKg2dEiq5289azNW6to/dLItrPtkkdInBA+xcMYKJSvMcYXN
         qzXQ0pps/OoamgM83V8kfOIBN/DLQqJ82BvlU0Wwvwrydpofk4H1V3mTiVitAfMscZJQ
         T1kjjAltKwgKrOTGeTlYk/LpL6NRoHVdcdHSAoTeQLtGWDTktr1+sUEuqL9bW2XfPOBY
         AQAQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:date:cc:to:from:subject:message-id;
        bh=HsKGTVvTXit6Qvw72M7meMZhHQt5NbvO0YTcuf0mwJA=;
        b=X3xwzD/VobVrBJbyhStYI1GaYGsgcHGFJl1tsMINN8uOvFBX4yEAe5TuZU6QxOLPoK
         rTNG2Lsv1g2x8C9kWgmwnuRZa0XWVYYoJyI8dk2xeITzqLAC/q4EYCpWw1QETgwNhq3h
         p7Tz+/Wv9LevvcoFlNjMseHR5DvSbLSY/cu/pbRZVGauG7nyliHBzZeBzUVmxJMbWrA/
         tFJl3QIss4OdwK5ht/nbbvhGwlt5KKKiZ/TGS3AUi4xQEwQP73/cHNQuanfd3BEKPkiR
         a/cx4+h1r+NCKrOGyNj3GYitp2rl+SOC0Lbf1p83n+V+VVZtWH+g7KJWZd4xM3zcqvHE
         3pBA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 216.40.44.141 is neither permitted nor denied by best guess record for domain of joe@perches.com) smtp.mailfrom=joe@perches.com
Received: from smtprelay.hostedemail.com (smtprelay0141.hostedemail.com. [216.40.44.141])
        by mx.google.com with ESMTPS id k188si480175itc.22.2019.02.01.19.27.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Feb 2019 19:27:28 -0800 (PST)
Received-SPF: neutral (google.com: 216.40.44.141 is neither permitted nor denied by best guess record for domain of joe@perches.com) client-ip=216.40.44.141;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 216.40.44.141 is neither permitted nor denied by best guess record for domain of joe@perches.com) smtp.mailfrom=joe@perches.com
Received: from filter.hostedemail.com (clb03-v110.bra.tucows.net [216.40.38.60])
	by smtprelay02.hostedemail.com (Postfix) with ESMTP id 7356816E28;
	Sat,  2 Feb 2019 03:27:27 +0000 (UTC)
X-Session-Marker: 6A6F6540706572636865732E636F6D
X-HE-Tag: song38_6b343b192310
X-Filterd-Recvd-Size: 1227
Received: from XPS-9350.home (unknown [47.151.153.53])
	(Authenticated sender: joe@perches.com)
	by omf02.hostedemail.com (Postfix) with ESMTPA;
	Sat,  2 Feb 2019 03:27:25 +0000 (UTC)
Message-ID: <089b1025c5e81410b6b608290becd6f609ca03b4.camel@perches.com>
Subject: Re: [PATCH] mm/slab: Increase width of first /proc/slabinfo column
From: Joe Perches <joe@perches.com>
To: "Tobin C. Harding" <tobin@kernel.org>, Christoph Lameter <cl@linux.com>,
  Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>,
 Joonsoo Kim <iamjoonsoo.kim@lge.com>,  Andrew Morton
 <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Date: Fri, 01 Feb 2019 19:27:24 -0800
In-Reply-To: <20190201004242.7659-1-tobin@kernel.org>
References: <20190201004242.7659-1-tobin@kernel.org>
Content-Type: text/plain; charset="ISO-8859-1"
User-Agent: Evolution 3.30.1-1build1 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2019-02-01 at 11:42 +1100, Tobin C. Harding wrote:
> Increase the width of the first column (cache name) in the output of
> /proc/slabinfo from 17 to 30 characters.

Do you care if this breaks any parsing of /proc/slabinfo?

I don't but someone might.

